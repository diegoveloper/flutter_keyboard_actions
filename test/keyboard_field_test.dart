import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import 'helpers.dart';

void main() {
  testWidgets('KeyboardActions.done wraps a single field directly',
      (tester) async {
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

    expect(find.text('Done'), findsOneWidget);
    expect(find.byTooltip('Next'), findsNothing);
  });

  testWidgets('KeyboardField toolbarButtons replace Done', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var custom = false;

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        child: KeyboardField(
          focusNode: focus,
          toolbarButtons: [
            (node) => TextButton(
                  onPressed: () {
                    custom = true;
                    node.unfocus();
                  },
                  child: const Text('Hide'),
                ),
          ],
          child: TextField(focusNode: focus),
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();
    expect(custom, isTrue);
  });

  testWidgets('KeyboardField footer is shown', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        child: KeyboardField(
          focusNode: focus,
          showBar: false,
          footer: const _Footer(),
          child: TextField(focusNode: focus),
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('custom-footer'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('custom panel slides away on Done instead of popping',
      (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        child: KeyboardField(
          focusNode: focus,
          footer: const _Footer(),
          child: TextField(focusNode: focus),
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('custom-footer'), findsOneWidget);

    await tester.tap(find.text('Done'));
    // Mid-slide: the panel is still in the tree, translating out.
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('custom-footer'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('custom-footer'), findsNothing);
    expect(find.text('Done'), findsNothing);
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('KeyboardField onDone is called', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var called = false;

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        child: KeyboardField(
          focusNode: focus,
          onDone: () => called = true,
          child: TextField(focusNode: focus),
        ),
      ),
    );

    focus.requestFocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('custom keyboard panel updates notifier', (tester) async {
    final focus = FocusNode();
    final notifier = ValueNotifier<String>('0');
    addTearDown(() {
      focus.dispose();
      notifier.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        child: KeyboardField(
          focusNode: focus,
          footer: _CounterFooter(notifier: notifier),
          child: KeyboardCustomInput<String>(
            focusNode: focus,
            notifier: notifier,
            builder: (_, value, __) => Text('v=$value'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('v=0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();

    expect(notifier.value, '1');
    expect(find.text('v=1'), findsOneWidget);
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('custom keyboard InkWell does not steal focus', (tester) async {
    final focus = FocusNode();
    final notifier = ValueNotifier<String>('0');
    addTearDown(() {
      focus.dispose();
      notifier.dispose();
    });

    await pumpKeyboardApp(
      tester,
      child: KeyboardActions(
        child: KeyboardField(
          focusNode: focus,
          showBar: false,
          footer: _InkWellFooter(notifier: notifier),
          child: KeyboardCustomInput<String>(
            focusNode: focus,
            notifier: notifier,
            builder: (_, value, __) => Text('v=$value'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('v=0'));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);

    await tester.tap(find.text('+'));
    await tester.pump();
    // Focus must stay, otherwise overlay rebuilds and drops the tap.
    expect(focus.hasFocus, isTrue);
    await tester.pumpAndSettle();

    expect(notifier.value, '1');
    expect(find.text('v=1'), findsOneWidget);
  });
}

class _Footer extends StatelessWidget implements PreferredSizeWidget {
  const _Footer();

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 50, child: Center(child: Text('custom-footer')));
}

class _CounterFooter extends StatelessWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<String> notifier;

  const _CounterFooter({required this.notifier});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextButton(
        onPressed: () =>
            updateValue('${(int.tryParse(notifier.value) ?? 0) + 1}'),
        child: const Text('+'),
      ),
    );
  }
}

class _InkWellFooter extends StatelessWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<String> notifier;

  const _InkWellFooter({required this.notifier});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: 60,
        child: InkWell(
          // Default canRequestFocus:true is what broke custom keypads.
          onTap: () =>
              updateValue('${(int.tryParse(notifier.value) ?? 0) + 1}'),
          child: const Center(child: Text('+')),
        ),
      ),
    );
  }
}
