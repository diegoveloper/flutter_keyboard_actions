import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
// KeyboardBar is internal: reach for it directly to assert resolved sizing.
import 'package:keyboard_actions/src/bar/keyboard_bar.dart';

import 'helpers.dart';

void main() {
  Color? doneColor(WidgetTester tester) =>
      tester.widget<Text>(find.text('Done')).style?.color;

  testWidgets('KeyboardActionsTheme styles the bar app-wide', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      wrap: (app) => KeyboardActionsTheme(
        data: const KeyboardActionsThemeData(
          doneText: 'Listo',
          doneTextStyle: TextStyle(color: Colors.green),
        ),
        child: app,
      ),
      child: KeyboardActions.done(child: TextField(focusNode: focus)),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Listo'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    expect(
      tester.widget<Text>(find.text('Listo')).style?.color,
      Colors.green,
    );
  });

  testWidgets('ThemeData extension styles the bar', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      theme: ThemeData(
        useMaterial3: true,
        extensions: const [
          KeyboardActionsThemeData(doneTextStyle: TextStyle(color: Colors.red)),
        ],
      ),
      child: KeyboardActions.done(child: TextField(focusNode: focus)),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(doneColor(tester), Colors.red);
  });

  testWidgets('widget theme wins over the ambient theme', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      wrap: (app) => KeyboardActionsTheme(
        data: const KeyboardActionsThemeData(
          doneText: 'Ambient',
          doneTextStyle: TextStyle(color: Colors.green),
        ),
        child: app,
      ),
      child: KeyboardActions.done(
        doneText: 'Local',
        theme: const KeyboardActionsThemeData(
          doneTextStyle: TextStyle(color: Colors.orange),
        ),
        child: TextField(focusNode: focus),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Local'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Local')).style?.color,
      Colors.orange,
    );
  });

  testWidgets('inherited theme wins over the ThemeData extension',
      (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      theme: ThemeData(
        useMaterial3: true,
        extensions: const [
          KeyboardActionsThemeData(
            doneText: 'FromExtension',
            barHeight: 90,
          ),
        ],
      ),
      wrap: (app) => KeyboardActionsTheme(
        data: const KeyboardActionsThemeData(doneText: 'FromInherited'),
        child: app,
      ),
      child: KeyboardActions.done(child: TextField(focusNode: focus)),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    // The inherited label wins, but barHeight still comes from the extension
    // because the inherited data leaves it unset.
    expect(find.text('FromInherited'), findsOneWidget);
    expect(
      tester.getSize(find.byType(KeyboardBar).first).height,
      90,
    );
  });

  testWidgets('Submit needs onSubmit even when the theme sets a label',
      (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      wrap: (app) => KeyboardActionsTheme(
        data: const KeyboardActionsThemeData(submitText: 'Send'),
        child: app,
      ),
      child: KeyboardActions(child: TextField(focusNode: focus)),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Send'), findsNothing);
  });

  testWidgets('theme submitText labels the Submit button', (tester) async {
    final a = FocusNode();
    final b = FocusNode();
    addTearDown(() {
      a.dispose();
      b.dispose();
    });

    await pumpKeyboardApp(
      tester,
      wrap: (app) => KeyboardActionsTheme(
        data: const KeyboardActionsThemeData(submitText: 'Send'),
        child: app,
      ),
      child: KeyboardActions(
        dismissOnTapOutside: false,
        onSubmit: () {},
        child: Column(
          children: [
            TextField(focusNode: a),
            TextField(focusNode: b),
          ],
        ),
      ),
    );

    b.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Send'), findsOneWidget);
  });

  testWidgets('changing the theme repaints the visible bar', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    enableKeyboardActionsForTests();

    Widget app(KeyboardActionsThemeData data) => KeyboardActionsTheme(
          data: data,
          child: MaterialApp(
            home: Scaffold(
              body: KeyboardActions.done(child: TextField(focusNode: focus)),
            ),
          ),
        );

    await tester.pumpWidget(
      app(const KeyboardActionsThemeData(
        doneTextStyle: TextStyle(color: Colors.green),
        barHeight: 46,
      )),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(doneColor(tester), Colors.green);

    // The bar lives in an Overlay, so it must be refreshed explicitly.
    await tester.pumpWidget(
      app(const KeyboardActionsThemeData(
        doneTextStyle: TextStyle(color: Colors.orange),
        barHeight: 80,
      )),
    );
    await tester.pumpAndSettle();

    expect(doneColor(tester), Colors.orange);
    expect(tester.getSize(find.byType(KeyboardBar).first).height, 80);
  });

  group('KeyboardActionsThemeData', () {
    test('merge lets the other value win', () {
      const base = KeyboardActionsThemeData(
        barColor: Colors.red,
        barHeight: 40,
      );
      const other = KeyboardActionsThemeData(barColor: Colors.blue);

      final merged = base.merge(other);
      expect(merged.barColor, Colors.blue);
      expect(merged.barHeight, 40);
    });

    test('merge with null returns the same values', () {
      const base = KeyboardActionsThemeData(barColor: Colors.red);
      expect(base.merge(null), base);
    });

    test('equality is by value', () {
      expect(
        const KeyboardActionsThemeData(barColor: Colors.red),
        const KeyboardActionsThemeData(barColor: Colors.red),
      );
      expect(
        const KeyboardActionsThemeData(barColor: Colors.red),
        isNot(const KeyboardActionsThemeData(barColor: Colors.blue)),
      );
    });

    test('lerp interpolates colors and snaps labels', () {
      const a = KeyboardActionsThemeData(
        barColor: Colors.black,
        barHeight: 40,
        doneText: 'A',
      );
      const b = KeyboardActionsThemeData(
        barColor: Colors.white,
        barHeight: 60,
        doneText: 'B',
      );

      final mid = a.lerp(b, 0.5);
      expect(mid.barHeight, 50);
      expect(mid.doneText, 'B');
      expect(a.lerp(b, 0.2).doneText, 'A');
    });
  });
}
