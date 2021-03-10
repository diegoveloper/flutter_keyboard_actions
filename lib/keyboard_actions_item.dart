import 'package:flutter/material.dart';

typedef ButtonBuilder = Widget Function(FocusNode focusNode);

///Class to define the `focusNode` that you pass to your `TextField` too and other params to customize
///the bar that will appear over your keyboard
class KeyboardActionsItem {
  /// The Focus object coupled to TextField, listening for got/lost focus events
  final FocusNode focusNode;

  /// Optional widgets to display to the right of the bar/
  /// NOTE: `toolbarButtons` override the Done button by default
  final List<ButtonBuilder>? toolbarButtons;

  /// true [default] to display the Done button
  final bool displayDoneButton;

  /// Optional callback if the Done button for TextField was tapped
  /// It will only work if `displayDoneButton` is [true] and `toolbarButtons` is null or empty
  final VoidCallback? onTapAction;

  /// true [default] to display the arrows to move between the fields
  final bool displayArrows;

  /// true [default] if the TextField is enabled
  final bool enabled;

  /// true [default] to display the action bar
  final bool displayActionBar;

  /// Builder for an optional widget to show below the action bar.
  ///
  /// Consider using for field validation or as a replacement for a system keyboard.
  ///
  /// This widget must be a PreferredSizeWidget to report its exact height; use [Size.fromHeight]
  final PreferredSizeWidget Function(BuildContext context)? footerBuilder;

  const KeyboardActionsItem({
    required this.focusNode,
    this.onTapAction,
    this.toolbarButtons,
    this.enabled = true,
    this.displayActionBar = true,
    this.displayArrows = true,
    this.displayDoneButton = true,
    this.footerBuilder,
  });
}
