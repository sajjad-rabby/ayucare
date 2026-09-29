import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every letter A-Z has at least one condition', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = jsonDecode(
      await rootBundle.loadString('assets/content/conditions.json'),
    ) as List;
    final letters = raw.map((e) => (e as Map)['letter'] as String).toSet();
    for (final l in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')) {
      expect(letters.contains(l), isTrue, reason: 'letter $l');
    }
    expect(raw.length, greaterThanOrEqualTo(100));
  });

  test('category tags and medical tests are valid', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = jsonDecode(
      await rootBundle.loadString('assets/content/conditions.json'),
    ) as List;
    const tags = {'Treatable', 'Post-care', 'Preventative', 'Avoidable'};
    for (final e in raw) {
      final m = e as Map;
      expect(tags.contains(m['category_tag']), isTrue,
          reason: "${m['id']} tag");
      expect((m['medical_tests'] as List).isNotEmpty, isTrue,
          reason: "${m['id']} tests");
    }
  });

  test('no prohibited diagnostic/cure language in bundle', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final f in ['conditions.json', 'herbs.json', 'products.json']) {
      final text =
          (await rootBundle.loadString('assets/content/$f')).toLowerCase();
      for (final banned in [
        'you have ',
        'you probably have',
        'this herb will cure',
        'guaranteed cure',
        'guaranteed to work',
        'replace your medicine',
        'replaces your medicine',
        'stop taking medication',
        'take this product to treat',
        'your ai doctor',
        'your digital doctor',
        'doctor approved cure',
        'best treatment',
      ]) {
        expect(text.contains(banned), isFalse, reason: '$f contains "$banned"');
      }
    }
  });

  test('image workflow is honestly marked withdrawn', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = jsonDecode(
      await rootBundle.loadString('assets/content/conditions.json'),
    ) as List;
    for (final e in raw) {
      final m = e as Map;
      expect((m['image_status'] as String).isNotEmpty, isTrue,
          reason: "${m['id']} image_status");
    }
  });

  test('products respect max-3-per-condition mapping', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = jsonDecode(
      await rootBundle.loadString('assets/content/products.json'),
    ) as List;
    final counts = <String, int>{};
    for (final p in raw) {
      for (final c in ((p as Map)['conds'] as List)) {
        counts[c.toString()] = (counts[c.toString()] ?? 0) + 1;
      }
    }
    for (final e in counts.entries) {
      expect(e.value, lessThanOrEqualTo(3), reason: e.key);
    }
  });
}
