import 'dart:math';

import 'package:flutter/material.dart';

/// A field for inputting a color.
class ColorInput extends StatefulWidget {
  /// Key to look up this widget later. Helps you get the current color.
  final GlobalKey key;
  /// Focus node for this input.
  final FocusNode focusNode;
  /// The input decoration.
  final InputDecoration decoration;

  const ColorInput({this.key, this.focusNode, this.decoration}) : super(key: key);

  @override
  _ColorInputState createState() => _ColorInputState();
}

class _ColorInputState extends State<ColorInput> {

  Color _color;
  bool _hasFocus;

  @override
  void initState() {
    super.initState();
    _hasFocus = widget.focusNode.hasFocus;
  }

  void _onColorPicked(Color newColor) {
    setState(() {
      _color = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      child: Container(
        child: InputDecorator(
          decoration: widget.decoration ?? InputDecoration(),
          isFocused: _hasFocus,
          isEmpty: (_color == null),
          child: GestureDetector(
              onTap: () {
                if (!widget.focusNode.hasFocus) {
                  widget.focusNode.requestFocus();
                }
              },
              child: MergeSemantics(
                child: Semantics(
                  focused: _hasFocus,
                  child: Container(
                    width: double.maxFinite,
                    height: 30,
                    color: _color ?? Colors.transparent,
                  ),
                ),
              )
          ),
        ),
      ),
      onFocusChange: (newValue) =>
          setState(() {
            _hasFocus = newValue;
            if (_hasFocus) {
              ColorPickerKeyboard.listener = _onColorPicked;
            }
          }),
    );
  }
}

/// A quick example "keyboard" widget for picking a color.
///
/// **hacky!** :: Maintains a single global listener reference in a static variable, which [ColorInput]s
/// use to subscribe to changes.  This can't be good :) Don't have more than one [ColorPickerKeyboard].
///
/// For a real implementation, consider using something like a GlobalKey to reference this, and then link
/// [ColorInput]s to it via some equivalent of a [TextEditingController].
class ColorPickerKeyboard extends StatelessWidget implements PreferredSizeWidget {

  static const double _kKeyboardHeight = 200;

  /// Public singleton instance.
  static const ColorPickerKeyboard instance = ColorPickerKeyboard._();

  /// Single listener to this keyboard.
  static Function(Color pickedColor) listener;


  const ColorPickerKeyboard._() : super(); // private constructor


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
          for (final color in Colors.primaries) GestureDetector(
            onTap: () {
              if (listener != null) {
                listener(color);
              }
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
