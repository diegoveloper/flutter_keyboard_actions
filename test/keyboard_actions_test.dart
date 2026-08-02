import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import 'helpers.dart';

void main() {
  testWidgets('done mode shows Done without arrows', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        child: Column(
          children: [
            TextField(key: const Key('a'), focusNode: focus),
            const TextField(key: Key('b')),
          ],
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.byTooltip('Previous'), findsNothing);
    expect(find.byTooltip('Next'), findsNothing);
  });

  testWidgets('auto navigation shows arrows with 2+ fields', (tester) async {
    final a = FocusNode();
    final b = FocusNode();
    addTearDown(() {
      a.dispose();
      b.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        child: Column(
          children: [
            TextField(key: const Key('a'), focusNode: a),
            TextField(key: const Key('b'), focusNode: b),
          ],
        ),
      ),
    );

    a.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.byTooltip('Next'), findsOneWidget);

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(b.hasFocus, isTrue);
  });

  testWidgets('Done unfocuses', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        child: TextField(focusNode: focus),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(focus.hasFocus, isFalse);
  });

  testWidgets('Submit replaces Done on the last field', (tester) async {
    final a = FocusNode();
    final b = FocusNode();
    addTearDown(() {
      a.dispose();
      b.dispose();
    });
    var submitted = false;
    var dismissals = 0;

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        dismissOnTapOutside: false,
        submitText: 'Submit',
        onSubmit: () => submitted = true,
        onDismissed: (_) => dismissals++,
        child: Column(
          children: [
            TextField(focusNode: a),
            TextField(focusNode: b),
          ],
        ),
      ),
    );

    a.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Done'), findsOneWidget);

    b.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(submitted, isTrue);
    // Submit is not a dismissal hook.
    expect(dismissals, 0);
  });

  testWidgets('Done keeps its place on the last field without onSubmit',
      (tester) async {
    final a = FocusNode();
    final b = FocusNode();
    addTearDown(() {
      a.dispose();
      b.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        dismissOnTapOutside: false,
        submitText: 'Submit',
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

    expect(find.text('Submit'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('onDismissed also fires when a tap outside closes the keyboard',
      (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var dismissals = 0;

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        onDismissed: (_) => dismissals++,
        child: Column(
          children: [
            TextField(focusNode: focus),
            const SizedBox(height: 200, child: Text('outside')),
          ],
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(dismissals, 0);

    await tester.tap(find.text('outside'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(dismissals, 1);
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('dragging outside the field does not dismiss', (tester) async {
    final focus = FocusNode();
    final controller = ScrollController();
    addTearDown(() {
      focus.dispose();
      controller.dispose();
    });
    var dismissals = 0;

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        onDismissed: (_) => dismissals++,
        child: ListView(
          controller: controller,
          children: [
            TextField(focusNode: focus),
            const SizedBox(height: 900, child: Text('filler')),
          ],
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    // A scroll starts outside the field but must not be read as a tap.
    await tester.drag(find.text('filler'), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    expect(dismissals, 0);
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('inflates MediaQuery.viewInsets while bar is showing',
      (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    double? insetWhileFocused;

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        child: Builder(
          builder: (context) {
            insetWhileFocused = MediaQuery.viewInsetsOf(context).bottom;
            return TextField(focusNode: focus);
          },
        ),
      ),
    );

    final before = insetWhileFocused;
    focus.requestFocus();
    await tester.pumpAndSettle();

    // Rebuild to read inflated insets from child context.
    await tester.pump();
    final state =
        tester.state<KeyboardActionsState>(find.byType(KeyboardActions));
    expect(state.debugIsShowing, isTrue);
    expect(before, 0);
  });

  testWidgets('disabled KeyboardActions never shows bar', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        enabled: false,
        child: TextField(focusNode: focus),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('Prev/Next keeps bar visible (no hide/show flicker)',
      (tester) async {
    final a = FocusNode();
    final b = FocusNode();
    addTearDown(() {
      a.dispose();
      b.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        dismissOnTapOutside: true,
        child: Column(
          children: [
            TextField(focusNode: a),
            TextField(focusNode: b),
          ],
        ),
      ),
    );

    a.requestFocus();
    await tester.pumpAndSettle();

    final state =
        tester.state<KeyboardActionsState>(find.byType(KeyboardActions));
    expect(state.debugIsShowing, isTrue);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.byTooltip('Next'));
    // Mid-frame: bar must remain; keyboard actions should not tear down.
    await tester.pump();
    expect(state.debugIsShowing, isTrue);
    expect(find.text('Done'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(b.hasFocus, isTrue);
    expect(state.debugIsShowing, isTrue);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('tapping another TextField keeps bar (no dismiss barrier steal)',
      (tester) async {
    final a = FocusNode();
    final b = FocusNode();
    addTearDown(() {
      a.dispose();
      b.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        child: Column(
          children: [
            TextField(key: const Key('a'), focusNode: a),
            TextField(key: const Key('b'), focusNode: b),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('a')));
    await tester.pumpAndSettle();
    expect(a.hasFocus, isTrue);
    expect(find.text('Done'), findsOneWidget);

    // Must reach field B on the first tap (opaque overlay used to eat it).
    await tester.tap(find.byKey(const Key('b')));
    await tester.pumpAndSettle();

    expect(b.hasFocus, isTrue);
    expect(a.hasFocus, isFalse);
    expect(find.text('Done'), findsOneWidget);
    expect(
      tester
          .state<KeyboardActionsState>(find.byType(KeyboardActions))
          .debugIsShowing,
      isTrue,
    );
  });

  testWidgets('field-to-field tap does not dismiss via onTapOutside',
      (tester) async {
    final a = FocusNode();
    final b = FocusNode();
    addTearDown(() {
      a.dispose();
      b.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        dismissOnTapOutside: true,
        child: Column(
          children: [
            TextField(
              key: const Key('a'),
              focusNode: a,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('b'),
              focusNode: b,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('a')));
    await tester.pumpAndSettle();
    final state =
        tester.state<KeyboardActionsState>(find.byType(KeyboardActions));
    expect(state.debugIsShowing, isTrue);

    // Jump directly to the other field (decoration hit used to call Done).
    await tester.tap(find.byKey(const Key('b')));
    await tester.pump(); // post-frame dismiss check
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(b.hasFocus, isTrue);
    expect(state.debugIsShowing, isTrue);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('skips readOnly fields in navigation', (tester) async {
    final a = FocusNode();
    final readOnly = FocusNode();
    final c = FocusNode();
    addTearDown(() {
      a.dispose();
      readOnly.dispose();
      c.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        dismissOnTapOutside: false,
        child: Column(
          children: [
            TextField(focusNode: a),
            TextField(focusNode: readOnly, readOnly: true),
            TextField(focusNode: c),
          ],
        ),
      ),
    );

    final state =
        tester.state<KeyboardActionsState>(find.byType(KeyboardActions));
    expect(state.debugNodes, [a, c]);

    a.requestFocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(c.hasFocus, isTrue);
  });

  testWidgets('scrolls the field up when the keyboard arrives after focus',
      (tester) async {
    final focus = FocusNode();
    final controller = ScrollController();
    addTearDown(() {
      focus.dispose();
      controller.dispose();
      tester.view.reset();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        child: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 500),
            TextField(focusNode: focus),
            const SizedBox(height: 400),
          ],
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    final offsetBeforeKeyboard = controller.offset;

    // The keyboard reports its height only after focus, so the first
    // visibility check sees no insets at all.
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * tester.view.devicePixelRatio,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(offsetBeforeKeyboard + 200));
  });

  testWidgets('bar leaves with its page during a route transition',
      (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    enableKeyboardActionsForTests();

    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: Scaffold(
          body: KeyboardActions.done(child: TextField(focusNode: focus)),
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);

    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final moving = tester.widget<FractionalTranslation>(
      find
          .ancestor(
            of: find.text('Done'),
            matching: find.byType(FractionalTranslation),
          )
          .first,
    );
    expect(moving.translation.dy, greaterThan(0));

    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNothing);
  });
}
