import 'package:flutter/material.dart';
import 'keyboard_actions.dart';

/// Wrapper for a single configuration of the keyboard actions bar.
class KeyboardActionsConfig {
  /// Keyboard Action for specific platform
  /// KeyboardActionsPlatform : ANDROID , IOS , ALL
  final KeyboardActionsPlatform keyboardActionsPlatform;

  /// true to display arrows prev/next to move focus between inputs
  final bool nextFocus;

  /// [KeyboardActionsItem] for each input
  final List<KeyboardActionsItem>? actions;

  /// Color of the background to the Custom keyboard buttons
  final Color? keyboardBarColor;

  /// Elevation of the Custom keyboard buttons
  final double? keyboardBarElevation;

  /// Color of the line separator between keyboard and content
  final Color keyboardSeparatorColor;

  /// A [Widget] to be optionally used instead of the "Done" button
  /// which dismisses the keyboard.
  final Widget? defaultDoneWidget;

  ///Icon to display for next icon
  final IconData? keyboardNextIcon;

  ///Icon to display previous icon
  final IconData? keyboardPreviousIcon;

  const KeyboardActionsConfig({
    this.keyboardActionsPlatform = KeyboardActionsPlatform.ALL,
    this.nextFocus = true,
    this.actions,
    this.keyboardBarColor,
    this.keyboardBarElevation,
    this.keyboardSeparatorColor = Colors.transparent,
    this.defaultDoneWidget,
    this.keyboardNextIcon,
    this.keyboardPreviousIcon
  });
}
