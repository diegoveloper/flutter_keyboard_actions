import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

void enableKeyboardActionsForTests() {
  KeyboardActionsState.debugForceAvailable = true;
  addTearDown(() => KeyboardActionsState.debugForceAvailable = null);
}

Future<void> pumpKeyboardApp(
  WidgetTester tester, {
  required Widget child,
  ThemeData? theme,
  Widget Function(Widget app)? wrap,
}) async {
  enableKeyboardActionsForTests();
  final Widget app = MaterialApp(
    theme: theme ?? ThemeData(useMaterial3: true),
    home: Scaffold(body: child),
  );
  await tester.pumpWidget(wrap == null ? app : wrap(app));
  await tester.pumpAndSettle();
}
