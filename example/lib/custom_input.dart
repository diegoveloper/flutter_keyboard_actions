import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// A quick example "keyboard" widget for picking a color.
class ColorPickerKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<Color>
    implements PreferredSizeWidget {
  final ValueNotifier<Color> notifier;
  static const double _kKeyboardHeight = 200;

  ColorPickerKeyboard({Key key, this.notifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double rows = 3;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int colorsCount = Colors.primaries.length;
    final int colorsPerRow = (colorsCount / rows).ceil();
    final double itemWidth = screenWidth / colorsPerRow;
    final double itemHeight = _kKeyboardHeight / rows;

    return Container(
      height: _kKeyboardHeight,
      child: Wrap(
        children: <Widget>[
          for (final color in Colors.primaries)
            GestureDetector(
              onTap: () {
                updateValue(color);
              },
              child: Container(
                color: color,
                width: itemWidth,
                height: itemHeight,
              ),
            )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_kKeyboardHeight);
}

class CounterKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  final ValueNotifier<String> notifier;

  CounterKeyboard({Key key, this.notifier}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(200);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                int value = int.tryParse(notifier.value) ?? 0;
                value--;
                updateValue(value.toString());
              },
              child: FittedBox(
                child: Text(
                  "-",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                int value = int.tryParse(notifier.value) ?? 0;
                value++;
                updateValue(value.toString());
              },
              child: FittedBox(
                child: Text(
                  "+",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
