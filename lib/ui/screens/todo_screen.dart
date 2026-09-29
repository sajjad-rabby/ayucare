import 'package:flutter/material.dart';
import '../../data/todo_repository.dart';
import '../../services/reminder_service.dart';
import '../../theme/ayu_theme.dart';

/// Todo lists entry: create named lists, delete, open for checklist +
/// per-list one-shot reminder (date + 12h time).
class TodoListsScreen extends StatefulWidget {
  const TodoListsScreen({super.key});
  @override
  State<TodoListsScreen> createState() => _TodoListsScreenState();
}

class _TodoListsScreenState extends State<TodoListsScreen> {
  List<TodoList>? _lists;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final l = await TodoRepository.load();
    if (mounted) setState(() => _lists = l);
  }

  Future<void> _createDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    var ok = false;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: const Text('New todo list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (_) => setD(() {})),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: titleCtrl.text.trim().isEmpty
                  ? null
                  : () {
                      ok = true;
                      Navigator.of(context).pop();
                    },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (!ok || !mounted) {
      titleCtrl.dispose();
      descCtrl.dispose();
      return;
    }
    final lists = await TodoRepository.load();
    lists.add(TodoList(
      id: TodoRepository.newId(),
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      items: [],
      reminderOn: false,
    ));
    await TodoRepository.save(lists);
    titleCtrl.dispose();
    descCtrl.dispose();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Todo Lists')),
        floatingActionButton: FloatingActionButton(
          onPressed: _lists == null ? null : _createDialog,
          tooltip: 'Create list',
          child: const Icon(Icons.add),
        ),
        body: _lists == null
            ? const Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading'))
            : _lists!.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No todo lists yet. Tap + to create one with its own reminder.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AyuSpacing.m),
                    itemCount: _lists!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AyuSpacing.s),
                    itemBuilder: (context, i) {
                      final t = _lists![i];
                      final done = t.items.where((e) => e.done).length;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.checklist_outlined),
                          title: Text(t.title),
                          subtitle: Text('${t.items.length} items · $done done'
                              '${t.reminderOn && t.reminderAt != null ? ' · reminds ${formatTodoWhen(t.reminderAt!)}' : ''}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete list',
                            onPressed: () async {
                              await ReminderService.cancelOneShot(
                                  1000 + (t.id % 1000));
                              final lists = await TodoRepository.load();
                              lists.removeWhere((e) => e.id == t.id);
                              await TodoRepository.save(lists);
                              await _refresh();
                            },
                          ),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (_) => TodoDetailScreen(id: t.id)))
                              .then((_) => _refresh()),
                        ),
                      );
                    },
                  ),
      );

  static String _fmt(DateTime d) => formatTodoWhen(d);
}

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({super.key, required this.id});
  final int id;
  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  TodoList? _todo;
  final _itemCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _itemCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final lists = await TodoRepository.load();
    if (!mounted) return;
    setState(() => _todo = lists.where((e) => e.id == widget.id).firstOrNull);
  }

  Future<void> _save(TodoList t) async {
    final lists = await TodoRepository.load();
    final i = lists.indexWhere((e) => e.id == t.id);
    if (i >= 0) lists[i] = t;
    await TodoRepository.save(lists);
    if (t.reminderOn && t.reminderAt != null) {
      await ReminderService.scheduleOneShot(
        id: 1000 + (t.id % 1000),
        title: 'AyuCare · ${t.title}',
        body:
            t.description.isEmpty ? 'Your todo list reminder.' : t.description,
        at: t.reminderAt!,
      );
    } else {
      await ReminderService.cancelOneShot(1000 + (t.id % 1000));
    }
    await _refresh();
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _todo!.reminderAt ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    // Forced 12-hour time picker.
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_todo!.reminderAt ?? now),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (time == null) return;
    await _save(_todo!.copyWith(
      reminderIso:
          DateTime(date.year, date.month, date.day, time.hour, time.minute)
              .toIso8601String(),
      reminderOn: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = _todo;
    if (t == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: ListView(
        padding: const EdgeInsets.all(AyuSpacing.m),
        children: [
          if (t.description.isNotEmpty) ...[
            Text(t.description),
            const SizedBox(height: AyuSpacing.s),
          ],
          Card(
            child: SwitchListTile(
              title: const Text('Reminder for this list'),
              subtitle: Text(t.reminderOn && t.reminderAt != null
                  ? formatTodoWhen(t.reminderAt!)
                  : 'Off — set day & time'),
              value: t.reminderOn,
              onChanged: (v) async {
                if (v && t.reminderAt == null) {
                  await _pickReminder();
                } else {
                  await _save(t.copyWith(reminderOn: v));
                }
              },
            ),
          ),
          if (t.reminderOn)
            TextButton.icon(
              icon: const Icon(Icons.schedule_outlined),
              label: const Text('Change day & time'),
              onPressed: _pickReminder,
            ),
          const SizedBox(height: AyuSpacing.s),
          Text('Checklist', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AyuSpacing.s),
          for (var i = 0; i < t.items.length; i++)
            Card(
              child: CheckboxListTile(
                title: Text(t.items[i].text),
                value: t.items[i].done,
                onChanged: (v) async {
                  final items = List<TodoItem>.from(t.items);
                  items[i] = TodoItem(text: items[i].text, done: v ?? false);
                  await _save(t.copyWith(items: items));
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete item',
                  onPressed: () async {
                    final items = List<TodoItem>.from(t.items)..removeAt(i);
                    await _save(t.copyWith(items: items));
                  },
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemCtrl,
                  decoration: const InputDecoration(labelText: 'New item'),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add item',
                onPressed: _addItem,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    final text = _itemCtrl.text.trim();
    if (text.isEmpty || _todo == null) return;
    _itemCtrl.clear();
    await _save(_todo!
        .copyWith(items: [..._todo!.items, TodoItem(text: text, done: false)]));
  }
}

String formatTodoWhen(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '${d.day}/${d.month}/${d.year} $h:${d.minute.toString().padLeft(2, '0')} $ap';
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
