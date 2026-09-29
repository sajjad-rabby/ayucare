import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Todo lists with checklist items + one-shot date-time reminders.
/// All on-device; lists keyed by stable int ids (notification ids).
class TodoItem {
  TodoItem({required this.text, required this.done});
  final String text;
  final bool done;

  Map<String, Object?> toJson() => {'text': text, 'done': done};
  factory TodoItem.fromJson(Map<String, Object?> j) =>
      TodoItem(text: j['text'] as String, done: j['done'] as bool);
}

class TodoList {
  TodoList({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
    this.reminderIso,
    required this.reminderOn,
  });

  final int id;
  final String title, description;
  final List<TodoItem> items;
  final String? reminderIso; // local ISO-8601, null = none
  final bool reminderOn;

  DateTime? get reminderAt =>
      reminderIso == null ? null : DateTime.tryParse(reminderIso!);

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'items': items.map((e) => e.toJson()).toList(),
        'reminderIso': reminderIso,
        'reminderOn': reminderOn,
      };

  factory TodoList.fromJson(Map<String, Object?> j) => TodoList(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String,
        description: (j['description'] as String?) ?? '',
        items: ((j['items'] as List?) ?? [])
            .map((e) => TodoItem.fromJson((e as Map).cast<String, Object?>()))
            .toList(),
        reminderIso: j['reminderIso'] as String?,
        reminderOn: (j['reminderOn'] as bool?) ?? false,
      );

  TodoList copyWith({
    String? title,
    String? description,
    List<TodoItem>? items,
    String? reminderIso,
    bool clearReminder = false,
    bool? reminderOn,
  }) =>
      TodoList(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        items: items ?? this.items,
        reminderIso: clearReminder ? null : (reminderIso ?? this.reminderIso),
        reminderOn: reminderOn ?? this.reminderOn,
      );
}

class TodoRepository {
  static const _k = 'todos.v1';

  static Future<List<TodoList>> load() async {
    final raw = (await SharedPreferences.getInstance()).getStringList(_k) ?? [];
    return raw
        .map((s) =>
            TodoList.fromJson((jsonDecode(s) as Map).cast<String, Object?>()))
        .toList();
  }

  static Future<void> save(List<TodoList> lists) async {
    (await SharedPreferences.getInstance())
        .setStringList(_k, lists.map((e) => jsonEncode(e.toJson())).toList());
  }

  static int newId() => DateTime.now().microsecondsSinceEpoch % 2000000000;
}
