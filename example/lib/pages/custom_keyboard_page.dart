import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../widgets/custom_keyboards.dart';

class CustomKeyboardPage extends StatefulWidget {
  const CustomKeyboardPage({super.key});

  @override
  State<CustomKeyboardPage> createState() => _CustomKeyboardPageState();
}

class _CustomKeyboardPageState extends State<CustomKeyboardPage> {
  final _counterFocus = FocusNode();
  final _colorFocus = FocusNode();
  final _amountFocus = FocusNode();

  final _counter = ValueNotifier<String>('0');
  final _color = ValueNotifier<Color>(Colors.teal);
  final _amount = ValueNotifier<String>('');

  @override
  void dispose() {
    _counterFocus.dispose();
    _colorFocus.dispose();
    _amountFocus.dispose();
    _counter.dispose();
    _color.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom keyboards')),
      body: KeyboardActions(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Use KeyboardField to attach a custom panel. No global '
              'FocusNode config list required.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const Text('Counter'),
            const SizedBox(height: 8),
            KeyboardField(
              focusNode: _counterFocus,
              footer: CounterKeyboard(notifier: _counter),
              child: KeyboardCustomInput<String>(
                focusNode: _counterFocus,
                notifier: _counter,
                height: 64,
                builder: (context, value, hasFocus) => InputDecorator(
                  isFocused: hasFocus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Text(value, style: const TextStyle(fontSize: 20)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Color'),
            const SizedBox(height: 8),
            KeyboardField(
              focusNode: _colorFocus,
              showBar: false,
              footer: ColorPickerKeyboard(notifier: _color),
              child: KeyboardCustomInput<Color>(
                focusNode: _colorFocus,
                notifier: _color,
                height: 52,
                builder: (context, value, hasFocus) => InputDecorator(
                  isFocused: hasFocus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: value,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Amount'),
            const SizedBox(height: 8),
            KeyboardField(
              focusNode: _amountFocus,
              showBar: false,
              footer: NumericKeyboard(
                notifier: _amount,
                onDone: () => _amountFocus.unfocus(),
              ),
              child: KeyboardCustomInput<String>(
                focusNode: _amountFocus,
                notifier: _amount,
                height: 64,
                builder: (context, value, hasFocus) => InputDecorator(
                  isFocused: hasFocus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  child: Text(
                    value.isEmpty ? '0' : value,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
