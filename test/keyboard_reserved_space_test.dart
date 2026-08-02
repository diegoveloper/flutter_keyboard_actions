import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

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
}
