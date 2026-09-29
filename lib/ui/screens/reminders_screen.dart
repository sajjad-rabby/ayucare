import 'package:flutter/material.dart';
import '../../services/reminder_service.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_widgets.dart';

/// Daily reminders: water check-in (8 PM) + movement (7 AM), device timezone.
/// Tapping a notification opens the app; tracking stays on-device.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _water = true;
  bool _exercise = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final w = await ReminderService.waterOn;
    final e = await ReminderService.exerciseOn;
    if (!mounted) return;
    setState(() {
      _water = w;
      _exercise = e;
      _loaded = true;
    });
    await ReminderService.requestPermission();
  }

  String get _zone {
    try {
      return ReminderService.zoneName;
    } catch (_) {
      return 'device timezone';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Daily Reminders')),
        body: !_loaded
            ? const Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading'))
            : ListView(
                padding: const EdgeInsets.all(AyuSpacing.m),
                children: [
                  const SafetyNotice(
                    title: 'Gentle nudges, on your device',
                    body:
                        'Reminders are scheduled on this phone in its own timezone. '
                        'No account, no server, no location tracking.',
                    level: NoticeLevel.info,
                  ),
                  const SizedBox(height: AyuSpacing.s),
                  SwitchListTile(
                    title: const Text('Water check-in · 8:00 PM'),
                    subtitle: const Text('“Did you drink enough water today?”'),
                    value: _water,
                    onChanged: (v) async {
                      await ReminderService.setWater(v);
                      if (mounted) setState(() => _water = v);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Daily movement · 7:00 AM'),
                    subtitle:
                        const Text('A short walk or stretch to start the day.'),
                    value: _exercise,
                    onChanged: (v) async {
                      await ReminderService.setExercise(v);
                      if (mounted) setState(() => _exercise = v);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AyuSpacing.m),
                    child: Text('Times shown in $_zone.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
      );
}
