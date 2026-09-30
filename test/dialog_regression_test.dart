import 'package:ayucare/ui/screens/reminders_screen.dart';
import 'package:ayucare/ui/screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('create todo list flow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TodoListsScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Create list'));
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Vitamins');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Create'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Vitamins'), findsOneWidget);
  });

  testWidgets('reminder add flow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RemindersScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Add reminder'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('New reminder'), findsOneWidget);
  });
}
