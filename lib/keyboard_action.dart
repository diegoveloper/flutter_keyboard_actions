import 'package:flutter/material.dart';

///Class to define the `focusNode` that you pass to your `TextField` too and other params to customize
///the bar that will appear over your keyboard
class KeyboardAction {
  /// The Focus object coupled to TextField, listening for got/lost focus events
  final FocusNode focusNode;

  /// Optional callback if the button for TextField was tapped
  final VoidCallback onTapAction;

  /// Optional widget to display to the right of the bar
  final Widget closeWidget;

  /// true [default] to display a closeWidget
  final bool displayCloseWidget;

  /// true [default] if the TextField is enabled
  final bool enabled;

  /// Builder for an optional widget to show below the action bar.
  ///
  /// Consider using for field validation or as a replacement for a system keyboard.
  ///
  /// This widget must be a PreferredSizeWidget to report its exact height; use [Size.fromHeight]
  final PreferredSizeWidget Function(BuildContext context) footerBuilder;

  const KeyboardAction({
    @required this.focusNode,
    this.onTapAction,
    this.closeWidget,
    this.enabled = true,
    this.displayCloseWidget = true,
    this.footerBuilder,
  });
}
