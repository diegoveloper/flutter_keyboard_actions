import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

Future<void> _pause([Duration duration = const Duration(seconds: 2)]) =>
    Future<void>.delayed(duration);

Future<void> _openDemo(WidgetTester tester, String title) async {
  await tester.pumpWidget(const KeyboardActionsGalleryApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('readme: done only', (tester) async {
    await _openDemo(tester, 'Done only');
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await _pause();
  });

  testWidgets('readme: navigation', (tester) async {
    await _openDemo(tester, 'Form + navigation');
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    await _pause();
  });

  testWidgets('readme: integrated bar', (tester) async {
    await _openDemo(tester, 'Integrated bar');
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await _pause();
  });

  testWidgets('readme: custom keyboard', (tester) async {
    await _openDemo(tester, 'Custom keyboards');
    await tester.tap(find.byType(KeyboardCustomInput<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await _pause();
  });

  testWidgets('readme: large list', (tester) async {
    await _openDemo(tester, 'Large ListView');
    await tester.scrollUntilVisible(
      find.text('Field 40'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Field 40'));
    await tester.pumpAndSettle();
    await _pause(const Duration(seconds: 3));
  });

  testWidgets('readme: dialog', (tester) async {
    await _openDemo(tester, 'Dialog');
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await _pause();
  });
}
