import 'package:ayucare/data/content_repository.dart';
import 'package:ayucare/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentRepository repo;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    repo = ContentRepository();
    await repo.load();
  });

  testWidgets('theme switch on every tab + pushed pages does not throw',
      (tester) async {
    await tester.pumpWidget(AyuCareApp(repo: repo));
    await tester.pump(const Duration(seconds: 1));
    // Visit Explore (wheel), Search, Saved tabs first.
    for (final tab in ['Explore', 'Search', 'Saved']) {
      await tester.tap(find.text(tab));
      await tester.pump(const Duration(seconds: 1));
    }
    // Switch theme from More tab.
    await tester.tap(find.text('More'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byType(DropdownButton<ThemeMode>));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Dark').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byType(DropdownButton<ThemeMode>));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Light').last);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('More'), findsWidgets);
  });
}
