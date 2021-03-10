import 'package:flutter/material.dart';

/// Signature for a function that creates a widget for a given value
typedef WidgetKeyboardBuilder<T> = Widget Function(
    BuildContext context, T value, bool? hasFocus);

/// A widget that allow us to create a custom keyboard instead of the platform keyboard.
class KeyboardCustomInput<T> extends StatefulWidget {
  ///Create your own widget and receive the [T] value
  final WidgetKeyboardBuilder<T> builder;

  ///Set the same `focusNode` you add to the [KeyboardAction]
  final FocusNode focusNode;

  ///The height of your widget
  final double? height;

  ///Set the same `notifier` you add to the [KeyboardAction]
  final ValueNotifier<T> notifier;

  const KeyboardCustomInput({
    Key? key,
    required this.focusNode,
    required this.builder,
    required this.notifier,
    this.height,
  }) : super(key: key);

  @override
  _KeyboardCustomInputState<T> createState() => _KeyboardCustomInputState<T>();
}

class _KeyboardCustomInputState<T> extends State<KeyboardCustomInput<T>>
    with AutomaticKeepAliveClientMixin {
  bool? _hasFocus;

  @override
  void initState() {
    super.initState();
    _hasFocus = widget.focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Focus(
      focusNode: widget.focusNode,
      child: GestureDetector(
        onTap: () {
          if (!widget.focusNode.hasFocus) {
            widget.focusNode.requestFocus();
          }
        },
        child: Container(
          height: widget.height,
          width: double.maxFinite,
          child: InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: false,
              disabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              enabled: false,
            ),
            isFocused: _hasFocus!,
            child: MergeSemantics(
              child: Semantics(
                focused: _hasFocus,
                child: Container(
                  child: AnimatedBuilder(
                    animation: widget.notifier,
                    builder: (context, child) => widget.builder(
                        context, widget.notifier.value, _hasFocus),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      onFocusChange: (newValue) => setState(() {
        _hasFocus = newValue;
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// A mixin which help to update the notifier, you must mix this class in case you want to create your own keyboard
mixin KeyboardCustomPanelMixin<T> {
  ///We'll use this notifier to send the data and refresh the widget inside [KeyboardCustomInput]
  ValueNotifier<T> get notifier;

  ///This method will update the notifier
  void updateValue(T value) {
    notifier.value = value;
  }
}
