import 'package:flutter/material.dart';

import 'keyboard_bar_style.dart';

typedef KeyboardBarButtonBuilder = Widget Function(FocusNode focusNode);

/// Floating bar above the keyboard: optional Prev/Next + Done/Submit/custom.
class KeyboardBar extends StatelessWidget {
  final KeyboardBarStyle style;
  final bool showNavigation;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool showDone;
  final bool showSubmit;
  final String doneText;
  final String? submitText;
  final Widget? doneWidget;
  final List<KeyboardBarButtonBuilder>? trailingButtons;
  final FocusNode? focusNode;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onDone;
  final VoidCallback? onSubmit;

  const KeyboardBar({
    super.key,
    required this.style,
    this.showNavigation = false,
    this.canGoPrevious = false,
    this.canGoNext = false,
    this.showDone = true,
    this.showSubmit = false,
    this.doneText = 'Done',
    this.submitText,
    this.doneWidget,
    this.trailingButtons,
    this.focusNode,
    this.onPrevious,
    this.onNext,
    this.onDone,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: style.backgroundColor,
      elevation: style.elevation,
      borderRadius: style.borderRadius,
      child: SizedBox(
        height: style.height,
        child: Padding(
          padding: style.padding,
          child: Row(
            children: [
              if (showNavigation) ...[
                _navButton(
                  tooltip: 'Previous',
                  enabled: canGoPrevious,
                  onPressed: onPrevious,
                  icon: style.previousIcon ??
                      const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                _navButton(
                  tooltip: 'Next',
                  enabled: canGoNext,
                  onPressed: onNext,
                  icon: style.nextIcon ??
                      const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ],
              const Spacer(),
              ..._trailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required String tooltip,
    required bool enabled,
    required VoidCallback? onPressed,
    required Widget icon,
  }) {
    // IconTheme so custom icons pick up the enabled/disabled color without
    // having to hardcode it.
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onPressed : null,
      icon: IconTheme.merge(
        data: IconThemeData(
          color: enabled ? style.foregroundColor : style.disabledColor,
        ),
        child: icon,
      ),
    );
  }

  List<Widget> _trailing() {
    if (trailingButtons != null &&
        trailingButtons!.isNotEmpty &&
        focusNode != null) {
      return [for (final b in trailingButtons!) b(focusNode!)];
    }

    return [
      if (showSubmit && submitText != null)
        TextButton(
          onPressed: onSubmit,
          child: Text(submitText!, style: style.submitTextStyle),
        ),
      if (showDone)
        doneWidget ??
            TextButton(
              onPressed: onDone,
              child: Text(doneText, style: style.doneTextStyle),
            ),
    ];
  }
}
