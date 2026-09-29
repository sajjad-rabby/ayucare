import 'dart:convert';
import 'package:flutter/services.dart';
import 'models.dart';

/// LocalContentRepository — offline-first bundle loader + search index.
/// RemoteContentRepository can later implement the same interface.
class ContentRepository {
  List<Condition> conditions = [];
  List<Herb> herbs = [];
  List<Product> products = [];
  String contentVersion = '?';

  Future<void> load() async {
    final c = jsonDecode(
      await rootBundle.loadString('assets/content/conditions.json'),
    ) as List;
    conditions = c
        .map((e) => Condition.fromJson((e as Map).cast<String, Object?>()))
        .toList();
    final h = jsonDecode(
      await rootBundle.loadString('assets/content/herbs.json'),
    ) as List;
    herbs = h
        .map((e) => Herb.fromJson((e as Map).cast<String, Object?>()))
        .toList();
    final p = jsonDecode(
      await rootBundle.loadString('assets/content/products.json'),
    ) as List;
    products = p
        .map((e) => Product.fromJson((e as Map).cast<String, Object?>()))
        .toList();
    final m = jsonDecode(
      await rootBundle.loadString('assets/content/meta.json'),
    ) as Map;
    contentVersion = (m['content_version'] ?? '?').toString();
  }

  List<Condition> byLetter(String letter) =>
      conditions.where((c) => c.letter == letter).toList();

  Condition? byId(String id) => conditions.where((c) => c.id == id).firstOrNull;
  Herb? herbById(String id) => herbs.where((h) => h.id == id).firstOrNull;

  List<Product> productsFor(String condId) =>
      products.where((p) => p.condIds.contains(condId)).take(3).toList();

  List<String> get letters => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  /// Educational search — NEVER diagnostic. Returns matches + fixed notice.
  List<Condition> search(String query) {
    final toks = _tokens(query);
    if (toks.isEmpty) return [];
    final scored = <Condition, int>{};
    for (final c in conditions) {
      var score = 0;
      final name = c.name.toLowerCase();
      for (final t in toks) {
        if (name == t) {
          score += 100;
        } else if (name.startsWith(t)) {
          score += 50;
        } else if (name.contains(t)) {
          score += 25;
        }
        if (c.keywords.any((k) => k.toLowerCase() == t)) score += 40;
        if (c.keywords.any((k) => k.toLowerCase().contains(t))) score += 15;
        final symHay = (c.symptoms + c.relatedSymptoms).join(' ').toLowerCase();
        if (symHay.contains(t)) score += 20;
        final herbHay = c.herbIds.join(' ').toLowerCase();
        if (herbHay.contains(t)) score += 10;
        if (c.category.toLowerCase().contains(t)) score += 8;
      }
      if (score > 0) scored[c] = score;
    }
    final out = scored.keys.toList()
      ..sort((a, b) => scored[b]!.compareTo(scored[a]!));
    return out;
  }

  static List<String> _tokens(String q) {
    var s = q.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), ' ');
    const stop = {'do', 'i', 'have', 'what', 'is', 'the', 'a', 'my', 'me'};
    return s
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2 && !stop.contains(t))
        .map(_singular)
        .toSet()
        .toList();
  }

  static String _singular(String t) {
    if (t.endsWith('ies') && t.length > 4) {
      return '${t.substring(0, t.length - 3)}y';
    }
    if (t.endsWith('es') && t.length > 4) return t.substring(0, t.length - 2);
    if (t.endsWith('s') && t.length > 4) return t.substring(0, t.length - 1);
    return t;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
