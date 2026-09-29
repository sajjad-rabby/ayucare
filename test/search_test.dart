import 'package:ayucare/data/content_repository.dart';
import 'package:ayucare/data/models.dart';
import 'package:ayucare/data/skin_articles.dart';
import 'package:ayucare/data/todo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _cond(
  String id,
  String letter,
  String name,
  List<String> symptoms,
  List<String> keywords,
) =>
    {
      'id': id,
      'letter': letter,
      'name': name,
      'slug': name.toLowerCase(),
      'category': 'Test',
      'short': 's',
      'overview': 'o',
      'symptoms': symptoms,
      'less_common': [],
      'causes': [],
      'risks': [],
      'care': 'c',
      'red_flags': [],
      'diagnosis': 'd',
      'management': 'm',
      'ayurveda': 'a',
      'herbs': [],
      'evidence': 'Traditional use',
      'evidence_note': 'e',
      'safety': 's',
      'contra': [],
      'interactions': '',
      'pregnancy': '',
      'children': '',
      'elderly': '',
      'related_conditions': [],
      'related_symptoms': symptoms,
      'keywords': keywords,
      'last_reviewed': '',
      'version': '1.0',
      'sources': [],
    };

void main() {
  ContentRepository repo() {
    final r = ContentRepository();
    r.conditions = [
      Condition.fromJson(_cond(
          '1', 'F', 'Fever', ['headache', 'chills'], ['fever', 'temperature'])),
      Condition.fromJson(_cond('2', 'G', 'Gastritis',
          ['stomach pain', 'nausea'], ['gastritis', 'acidity'])),
    ];
    return r;
  }

  test('symptom query returns educational matches', () {
    final hits = repo().search('stomach pain');
    expect(hits.map((c) => c.name), contains('Gastritis'));
  });

  test('headache matches fever (symptom index)', () {
    final hits = repo().search('headache');
    expect(hits.map((c) => c.name), contains('Fever'));
  });

  test('short/empty queries return nothing', () {
    expect(repo().search(''), isEmpty);
    expect(repo().search('a'), isEmpty);
  });

  test('plurals and stop-words tolerated', () {
    final hits = repo().search('Do I have headaches?');
    expect(hits.map((c) => c.name), contains('Fever'));
  });

  test('todo list round-trips with reminder', () {
    final t = TodoList(
      id: 42,
      title: 'Vitamins',
      description: 'Morning routine',
      items: [TodoItem(text: 'Drink water', done: true)],
      reminderIso: DateTime(2026, 10, 1, 8, 30).toIso8601String(),
      reminderOn: true,
    );
    final back = TodoList.fromJson(
        Map<String, Object?>.from((t.toJson()).map((k, v) => MapEntry(k, v))));
    expect(back.title, 'Vitamins');
    expect(back.items.single.done, isTrue);
    expect(back.reminderAt?.hour, 8);
  });

  test('skin library holds 10 complete in-app articles', () {
    expect(skinArticles.length, 10);
    for (final a in skinArticles) {
      expect(a.sections.length, greaterThanOrEqualTo(3), reason: a.id);
    }
  });
}
