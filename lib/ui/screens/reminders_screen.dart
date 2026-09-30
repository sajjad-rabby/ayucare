import 'package:flutter/material.dart';
import '../../services/reminder_service.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_icons.dart';
import '../widgets/ayu_widgets.dart';

/// Reminder list: toggle, delete, and add new ones at any 12-hour time.
/// Times display + pick in 12h format; scheduled daily in device timezone.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<ReminderItem>? _items;
  // Same dialog-lifecycle rule as todo lists: controllers are State-owned,
  // disposed only in dispose() — never right after Navigator.pop.
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final items = await ReminderService.load();
    if (!mounted) return;
    setState(() => _items = items);
    await ReminderService.requestPermission();
  }

  Future<void> _persist() async {
    await ReminderService.save(_items!);
    await ReminderService.rescheduleAll(_items!);
    if (mounted) setState(() {});
  }

  Future<void> _addDialog() async {
    if (_items!.length >= ReminderService.maxReminders) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum reminders reached.')));
      return;
    }
    _titleCtrl.text = 'AyuCare · Reminder';
    _bodyCtrl.text = 'A gentle health nudge.';
    TimeOfDay when = const TimeOfDay(hour: 20, minute: 0);
    var kind = 'custom';
    var picked = false;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: const Text('New reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: _bodyCtrl,
                    decoration: const InputDecoration(labelText: 'Message')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: kind,
                  items: const [
                    DropdownMenuItem(value: 'water', child: Text('Water')),
                    DropdownMenuItem(
                        value: 'exercise', child: Text('Exercise')),
                    DropdownMenuItem(value: 'custom', child: Text('General')),
                  ],
                  onChanged: (v) => setD(() => kind = v ?? 'custom'),
                  decoration: const InputDecoration(labelText: 'Icon'),
                ),
                const SizedBox(height: 8),
                // Forced 12-hour picker regardless of system setting.
                MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: false),
                  child: Builder(
                    builder: (ctx) => OutlinedButton.icon(
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(_fmt12(when)),
                      onPressed: () async {
                        final t = await showTimePicker(
                            context: ctx, initialTime: when);
                        if (t != null) {
                          setD(() {
                            when = t;
                            picked = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: picked
                  ? () {
                      _items!.add(ReminderItem(
                        id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
                        title: _titleCtrl.text.trim().isEmpty
                            ? 'AyuCare · Reminder'
                            : _titleCtrl.text.trim(),
                        body: _bodyCtrl.text.trim(),
                        hour: when.hour,
                        minute: when.minute,
                        enabled: true,
                        kind: kind,
                      ));
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    await _persist();
  }

  static String _fmt12(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ap = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:${t.minute.toString().padLeft(2, '0')} $ap';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Daily Reminders')),
        floatingActionButton: FloatingActionButton(
          onPressed: _items == null ? null : _addDialog,
          tooltip: 'Add reminder',
          child: const Icon(Icons.add),
        ),
        body: _items == null
            ? const Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading'))
            : ListView(
                padding: const EdgeInsets.all(AyuSpacing.m),
                children: [
                  const SafetyNotice(
                    title: 'Gentle nudges, on your device',
                    body: 'Reminders repeat daily in your timezone. '
                        'No account, no server, no location tracking.',
                    level: NoticeLevel.info,
                  ),
                  const SizedBox(height: AyuSpacing.s),
                  for (final r in _items!)
                    Card(
                      child: ListTile(
                        leading: r.kind == 'water'
                            ? const AyuGlyph.drop()
                            : Icon(r.icon,
                                color: Theme.of(context).colorScheme.primary),
                        title: Text(r.title),
                        subtitle: Text('${r.time12} · daily'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: r.enabled,
                              onChanged: (v) async {
                                final i = _items!.indexOf(r);
                                _items![i] = ReminderItem(
                                    id: r.id,
                                    title: r.title,
                                    body: r.body,
                                    hour: r.hour,
                                    minute: r.minute,
                                    enabled: v,
                                    kind: r.kind);
                                await _persist();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete reminder',
                              onPressed: () async {
                                _items!.remove(r);
                                await _persist();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AyuSpacing.m),
                    child: Text(
                        'Times in ${ReminderService.zoneName}. Tap + to add more.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
      );
}
