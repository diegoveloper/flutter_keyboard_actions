import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:intl/intl.dart';

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

/// A quick example "keyboard" widget for Counter.
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

/// A quick example "keyboard" widget for Numeric.
class NumericKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  final ValueNotifier<String> notifier;
  final FocusNode focusNode;

  NumericKeyboard({
    Key key,
    this.notifier,
    this.focusNode,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(280);

  final format = NumberFormat("0000");

  String _formatValue(String value) {
    final updatedValue = format.format(double.parse(value));
    final finalValue = updatedValue.substring(0, updatedValue.length - 2) +
        "." +
        updatedValue.substring(updatedValue.length - 2, updatedValue.length);
    return finalValue;
  }

  void _onTapNumber(String value) {
    if (value == "Done") {
      focusNode.unfocus();
      return;
    }
    final currentValue = notifier.value.replaceAll(".", "");
    final temp = currentValue + value;
    updateValue(_formatValue(temp));
  }

  void _onTapBackspace() {
    final currentValue = notifier.value.replaceAll(".", "");
    final temp = currentValue.substring(0, currentValue.length - 1);
    updateValue(_formatValue(temp));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: Color(0xFF313131),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: [
            _buildButton(text: "7"),
            _buildButton(text: "8"),
            _buildButton(text: "9"),
            _buildButton(text: "4"),
            _buildButton(text: "5"),
            _buildButton(text: "6"),
            _buildButton(text: "1"),
            _buildButton(text: "2"),
            _buildButton(text: "3"),
            _buildButton(icon: Icons.backspace, color: Colors.black),
            _buildButton(text: "0"),
            _buildButton(text: "Done", color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    String text,
    IconData icon,
    Color color,
  }) =>
      NumericButton(
        text: text,
        icon: icon,
        color: color,
        onTap: () => icon != null ? _onTapBackspace() : _onTapNumber(text),
      );
}

class NumericButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const NumericButton({
    Key key,
    this.text,
    this.onTap,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      color: color ?? Color(0xFF4A4A4A),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: icon != null
                ? Icon(
                    icon,
                    color: Colors.white,
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
