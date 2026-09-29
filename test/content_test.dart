import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundle covers every letter A-Z exactly once', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = jsonDecode(
      await rootBundle.loadString('assets/content/conditions.json'),
    ) as List;
    final letters = raw.map((e) => (e as Map)['letter'] as String).toList()
      ..sort();
    expect(letters.join(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
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

  test('every condition ships a bundled image with credit', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = jsonDecode(
      await rootBundle.loadString('assets/content/conditions.json'),
    ) as List;
    for (final e in raw) {
      final m = e as Map;
      expect((m['image'] as String).isNotEmpty, isTrue,
          reason: "${m['id']} image");
      expect((m['image_credit'] as String).isNotEmpty, isTrue,
          reason: "${m['id']} credit");
    }
  });

  test('bundled image files exist on disk', () {
    final dir = Directory('assets/content/images');
    expect(dir.existsSync(), isTrue);
    expect(dir.listSync().whereType<File>().length, greaterThanOrEqualTo(26));
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
