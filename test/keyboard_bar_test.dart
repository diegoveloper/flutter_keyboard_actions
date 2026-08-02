import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
// KeyboardBar and KeyboardBarStyle are internal: reach for them directly.
import 'package:keyboard_actions/src/bar/keyboard_bar.dart';
import 'package:keyboard_actions/src/bar/keyboard_bar_style.dart';

void main() {
  KeyboardBarStyle style() => const KeyboardBarStyle(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.blue,
        disabledColor: Colors.black26,
      );

  /// Resolves a style inside a MaterialApp, optionally under a theme.
  Future<KeyboardBarStyle> resolve(
    WidgetTester tester, {
    KeyboardActionsThemeData? theme,
    bool keyboardShowing = true,
  }) async {
    late KeyboardBarStyle resolved;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            resolved = KeyboardBarStyle.resolve(
              context,
              theme: theme,
              keyboardShowing: keyboardShowing,
            );
            return const SizedBox();
          },
        ),
      ),
    );
    return resolved;
  }

  testWidgets('Done fires callback', (tester) async {
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyboardBar(
            style: style(),
            onDone: () => done = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Done'));
    expect(done, isTrue);
  });

  testWidgets('navigation buttons respect enabled flags', (tester) async {
    var next = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyboardBar(
            style: style(),
            showNavigation: true,
            canGoPrevious: false,
            canGoNext: true,
            onNext: () => next = true,
            onPrevious: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Previous'));
    await tester.tap(find.byTooltip('Next'));
    expect(next, isTrue);
  });

  testWidgets('integratedBar uses flush styling', (tester) async {
    final integrated = await resolve(
      tester,
      theme: const KeyboardActionsThemeData(integratedBar: true),
    );

    expect(integrated.keyboardGap, 0);
    expect(integrated.borderRadius, isNull);
  });

  testWidgets('an explicit borderRadius survives integratedBar',
      (tester) async {
    final resolved = await resolve(
      tester,
      theme: const KeyboardActionsThemeData(
        integratedBar: true,
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
    );

    expect(resolved.borderRadius, BorderRadius.circular(26));
  });

  testWidgets('theme overrides bar colors and height', (tester) async {
    final resolved = await resolve(
      tester,
      theme: const KeyboardActionsThemeData(
        barColor: Colors.amber,
        foregroundColor: Colors.purple,
        disabledColor: Colors.red,
        barHeight: 72,
        elevation: 9,
        keyboardGap: 14,
      ),
    );

    expect(resolved.backgroundColor, Colors.amber);
    expect(resolved.foregroundColor, Colors.purple);
    expect(resolved.disabledColor, Colors.red);
    expect(resolved.height, 72);
    expect(resolved.elevation, 9);
    expect(resolved.keyboardGap, 14);
  });

  testWidgets('label styles merge over the foreground color', (tester) async {
    final resolved = await resolve(
      tester,
      theme: const KeyboardActionsThemeData(
        foregroundColor: Colors.purple,
        doneTextStyle: TextStyle(fontSize: 22),
        submitTextStyle: TextStyle(color: Colors.green),
      ),
    );

    // fontSize set by the user, color inherited from foregroundColor.
    expect(resolved.doneTextStyle.fontSize, 22);
    expect(resolved.doneTextStyle.color, Colors.purple);
    expect(resolved.doneTextStyle.fontWeight, FontWeight.bold);

    // An explicit color wins over foregroundColor.
    expect(resolved.submitTextStyle.color, Colors.green);
  });

  testWidgets('custom label styles reach the rendered buttons', (tester) async {
    final resolved = await resolve(
      tester,
      theme: const KeyboardActionsThemeData(
        doneTextStyle: TextStyle(color: Colors.green, fontSize: 21),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: KeyboardBar(style: resolved)),
      ),
    );

    final done = tester.widget<Text>(find.text('Done'));
    expect(done.style?.color, Colors.green);
    expect(done.style?.fontSize, 21);
  });

  testWidgets('custom arrow icons replace the defaults', (tester) async {
    final resolved = await resolve(
      tester,
      theme: const KeyboardActionsThemeData(
        previousIcon: Icon(Icons.arrow_back),
        nextIcon: Icon(Icons.arrow_forward),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyboardBar(
            style: resolved,
            showNavigation: true,
            canGoPrevious: true,
            canGoNext: true,
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsNothing);
  });
}
