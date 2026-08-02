import 'package:example/main.dart';
import 'package:example/widgets/custom_keyboards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Tells [tool/capture_readme_gifs.sh] to start screen recording.
const _readySignal = 'README_GIF_READY';

/// Tells [tool/capture_readme_gifs.sh] to stop before "Test finished" appears.
const _doneSignal = 'README_GIF_DONE';

void _signalReady() => debugPrint(_readySignal);

void _signalDone() => debugPrint(_doneSignal);

Future<void> _hold([Duration duration = const Duration(seconds: 2)]) =>
    Future<void>.delayed(duration);

Future<void> _openDemo(WidgetTester tester, String title) async {
  await tester.pumpWidget(const KeyboardActionsGalleryApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _focusFirstTextField(WidgetTester tester) async {
  await tester.tap(find.byType(TextField).first);
  await tester.pumpAndSettle();
  await _hold(const Duration(milliseconds: 500));
}

Future<void> _arrowHop(WidgetTester tester, {int nextTaps = 3}) async {
  final next = find.byTooltip('Next');
  final previous = find.byTooltip('Previous');
  if (next.evaluate().isEmpty) return;

  for (var i = 0; i < nextTaps; i++) {
    await tester.tap(next);
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 400));
  }

  if (previous.evaluate().isNotEmpty) {
    await tester.tap(previous);
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 400));
  }
}

Future<void> _finishClip() async {
  await _hold(const Duration(seconds: 2));
  _signalDone();
}

Future<void> _keyboardWithArrows(WidgetTester tester,
    {int nextTaps = 3}) async {
  await _focusFirstTextField(tester);
  _signalReady();
  await _arrowHop(tester, nextTaps: nextTaps);
  await _finishClip();
}

Finder _colorSwatches() => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.color != null &&
          (w.constraints?.maxHeight ?? 0) > 50,
    );

Future<void> _tapNumericKey(WidgetTester tester, String key) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NumericKeyboard),
      matching: find.text(key),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('readme: done only', (tester) async {
    await _openDemo(tester, 'Done only');
    await _focusFirstTextField(tester);
    _signalReady();
    await _finishClip();
  });

  testWidgets('readme: navigation', (tester) async {
    await _openDemo(tester, 'Form + navigation');
    // Email keyboard first, then Next lands on Phone (numeric) with bar still up.
    await tester.tap(find.byType(TextFormField).at(1));
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 500));
    _signalReady();
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 700));
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Previous'));
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 400));
    await _finishClip();
  });

  testWidgets('readme: integrated bar', (tester) async {
    await _openDemo(tester, 'Integrated bar');
    await _keyboardWithArrows(tester, nextTaps: 3);
  });

  testWidgets('readme: custom keyboard', (tester) async {
    await _openDemo(tester, 'Custom keyboards');

    final stringInputs = find.byType(KeyboardCustomInput<String>);

    // Counter panel
    await tester.tap(stringInputs.first);
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 500));
    _signalReady();
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('−'));
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 350));

    // Color picker — tap the field, then two swatches
    await tester.tap(find.byType(KeyboardCustomInput<Color>));
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 400));
    final swatches = _colorSwatches();
    await tester.tap(swatches.at(1));
    await tester.pumpAndSettle();
    await tester.tap(swatches.at(5));
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 350));

    // Numeric pad
    await tester.tap(stringInputs.last);
    await tester.pumpAndSettle();
    await _hold(const Duration(milliseconds: 400));
    await _tapNumericKey(tester, '1');
    await _tapNumericKey(tester, '2');
    await _tapNumericKey(tester, '5');
    await _tapNumericKey(tester, '0');

    await _finishClip();
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
    await _hold(const Duration(milliseconds: 500));
    _signalReady();
    await _arrowHop(tester, nextTaps: 2);
    await _finishClip();
  });

  testWidgets('readme: dialog', (tester) async {
    await _openDemo(tester, 'Dialog');
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    await _focusFirstTextField(tester);
    _signalReady();
    await _arrowHop(tester, nextTaps: 1);
    await _finishClip();
  });
}
