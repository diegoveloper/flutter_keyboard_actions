import 'package:flutter/material.dart';

import '../tap_region.dart';

typedef WidgetKeyboardBuilder<T> = Widget Function(
  BuildContext context,
  T value,
  bool hasFocus,
);

/// Focusable value display for custom keyboards (no system keyboard).
class KeyboardCustomInput<T> extends StatefulWidget {
  final WidgetKeyboardBuilder<T> builder;
  final FocusNode focusNode;
  final ValueNotifier<T> notifier;
  final double? height;

  const KeyboardCustomInput({
    super.key,
    required this.focusNode,
    required this.builder,
    required this.notifier,
    this.height,
  });

  @override
  State<KeyboardCustomInput<T>> createState() => _KeyboardCustomInputState<T>();
}

class _KeyboardCustomInputState<T> extends State<KeyboardCustomInput<T>>
    with AutomaticKeepAliveClientMixin {
  late bool _hasFocus = widget.focusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TextFieldTapRegion → same group as EditableText / the floating bar, so
    // dismiss-on-outside and focus handoff work like normal TextFields.
    // KeyboardActionsTapRegion → taps on the custom panel stay "inside".
    return TextFieldTapRegion(
      child: TapRegion(
        groupId: KeyboardActionsTapRegion.groupId,
        child: Focus(
          focusNode: widget.focusNode,
          onFocusChange: (v) => setState(() => _hasFocus = v),
          child: GestureDetector(
            onTap: () {
              if (!widget.focusNode.hasFocus) {
                widget.focusNode.requestFocus();
              }
            },
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: widget.notifier,
                builder: (context, _) => widget.builder(
                  context,
                  widget.notifier.value,
                  _hasFocus,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Mixin for custom keyboard panels that push values into a [notifier].
mixin KeyboardCustomPanelMixin<T> {
  ValueNotifier<T> get notifier;

  void updateValue(T value) => notifier.value = value;
}
