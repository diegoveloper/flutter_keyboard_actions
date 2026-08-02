import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CounterKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<String> notifier;

  const CounterKeyboard({super.key, required this.notifier});

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(
        height: preferredSize.height,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                canRequestFocus: false,
                onTap: () => updateValue(
                  '${(int.tryParse(notifier.value) ?? 0) - 1}',
                ),
                child: const Center(
                  child: Text('−', style: TextStyle(fontSize: 42)),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                canRequestFocus: false,
                onTap: () => updateValue(
                  '${(int.tryParse(notifier.value) ?? 0) + 1}',
                ),
                child: const Center(
                  child: Text('+', style: TextStyle(fontSize: 42)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<Color>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<Color> notifier;

  const ColorPickerKeyboard({super.key, required this.notifier});

  static const _h = 160.0;

  @override
  Size get preferredSize => const Size.fromHeight(_h);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width / 5;
    return SizedBox(
      height: _h,
      child: Wrap(
        children: [
          for (final c in Colors.primaries.take(15))
            GestureDetector(
              onTap: () => updateValue(c),
              child: Container(width: w, height: _h / 3, color: c),
            ),
        ],
      ),
    );
  }
}

class NumericKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<String> notifier;
  final VoidCallback? onDone;

  const NumericKeyboard({super.key, required this.notifier, this.onDone});

  @override
  Size get preferredSize => const Size.fromHeight(260);

  void _key(String k) {
    if (k == 'DEL') {
      final v = notifier.value;
      if (v.isNotEmpty) updateValue(v.substring(0, v.length - 1));
      return;
    }
    updateValue('${notifier.value}$k');
  }

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['DEL', '0', 'OK'],
    ];
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        height: preferredSize.height,
        child: Column(
          children: [
            for (final row in keys)
              Expanded(
                child: Row(
                  children: [
                    for (final k in row)
                      Expanded(
                        child: InkWell(
                          canRequestFocus: false,
                          onTap: () => k == 'OK' ? onDone?.call() : _key(k),
                          child: Center(
                            child: Text(
                              k,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
