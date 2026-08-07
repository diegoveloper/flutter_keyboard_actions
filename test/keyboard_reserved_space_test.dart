import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
// KeyboardBar is internal: used only to assert overlay geometry.
import 'package:keyboard_actions/src/bar/keyboard_bar.dart';

import 'helpers.dart';

/// Focuses the bottom-most field of a tall list and returns how far the field
/// pokes below the top of the bar. Negative means the field clears the bar.
Future<double> overlapOfLastField(
  WidgetTester tester, {
  required Widget Function(Widget field) buildBody,
}) async {
  final focus = FocusNode();
  final fieldKey = GlobalKey();
  addTearDown(focus.dispose);

  await pumpKeyboardApp(
    tester,
    child: buildBody(TextField(key: fieldKey, focusNode: focus)),
  );

  focus.requestFocus();
  await tester.pumpAndSettle();
  tester.view.viewInsets = FakeViewPadding(
    bottom: 300 * tester.view.devicePixelRatio,
  );
  addTearDown(tester.view.resetViewInsets);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();

  expect(find.text('Done'), findsOneWidget);
  return tester.getRect(find.byKey(fieldKey)).bottom -
      tester.getRect(find.text('Done')).top;
}

void main() {
  // The whole point of reserving space instead of only inflating viewInsets:
  // both wrapping positions must behave identically, so there is no "where do
  // I wrap?" decision for the developer.
  testWidgets('field clears the bar with KeyboardActions inside the list',
      (tester) async {
    final overlap = await overlapOfLastField(
      tester,
      buildBody: (field) => ListView(
        children: [
          const SizedBox(height: 400),
          KeyboardActions.done(child: field),
        ],
      ),
    );

    expect(overlap, lessThan(0));
  });

  testWidgets('field clears the bar with KeyboardActions around the list',
      (tester) async {
    final overlap = await overlapOfLastField(
      tester,
      buildBody: (field) => KeyboardActions.done(
        child: ListView(
          children: [const SizedBox(height: 400), field],
        ),
      ),
    );

    expect(overlap, lessThan(0));
  });

  testWidgets('reserved space is released when the keyboard closes',
      (tester) async {
    final focus = FocusNode();
    final fieldKey = GlobalKey();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions.done(
        child: Column(
          children: [
            Expanded(child: Container(key: fieldKey)),
            TextField(focusNode: focus),
          ],
        ),
      ),
    );

    final fullHeight = tester.getRect(find.byKey(fieldKey)).height;

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(fieldKey)).height, lessThan(fullHeight));

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(fieldKey)).height, fullHeight);
  });

  testWidgets('showing the bar does not remount a field with internal focus',
      (tester) async {
    await pumpKeyboardApp(
      tester,
      child: const KeyboardActions.done(
        child: TextField(),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    final editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editable.focusNode.hasFocus, isTrue);
    expect(find.text('Done'), findsOneWidget);
  });

  // Regression for #267: wrapping Scaffold used to apply bar height twice
  // (inflated viewInsets for Scaffold resize + Padding), leaving a gap
  // above the Done bar. FAB must also clear the bar in that setup.
  testWidgets(
      'wrapping Scaffold does not leave a gap above the Done bar',
      (tester) async {
    final focus = FocusNode();
    final bodyKey = GlobalKey();
    addTearDown(focus.dispose);
    enableKeyboardActionsForTests();

    await tester.pumpWidget(
      MaterialApp(
        home: KeyboardActions.done(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            // Expand so bodyBottom is the Scaffold content floor (above
            // viewInsets), not the intrinsic height of the TextField.
            body: SizedBox.expand(
              key: bodyKey,
              child: Align(
                alignment: Alignment.topCenter,
                child: TextField(focusNode: focus),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    focus.requestFocus();
    await tester.pumpAndSettle();
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);

    final bodyBottom = tester.getRect(find.byKey(bodyKey)).bottom;
    final barTop = tester.getRect(find.byType(KeyboardBar)).top;
    // Body (after Scaffold resize) should meet the bar — not sit a full bar
    // height above it from a second Padding (~46px).
    expect(barTop - bodyBottom, closeTo(0, 1));

    final fabBottom = tester.getRect(find.byType(FloatingActionButton)).bottom;
    expect(fabBottom, lessThanOrEqualTo(barTop + 0.5));
  });
}
