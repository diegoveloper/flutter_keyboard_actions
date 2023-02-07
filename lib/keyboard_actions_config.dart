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

  /// Thickness of the line separator between keyboard and content, defaults to 1.0
  final double keyboardSeparatorThickness;

  /// Color of the line separator between keyboard and content
  final Color keyboardSeparatorColor;

  /// The height to be optionally used instead of the Default bar height, defaults to 45
  final double? defaultBarHeight;

  /// A [Widget] to be optionally used instead of the "Done" button
  /// which dismisses the keyboard.
  final Widget? Function(void Function()? closeAction)? defaultDoneWidget;

  /// A [Widget] to be optionally used instead of the "Previous" button.
  final Widget?  Function(void Function()? previousAction)? defaultPreviousWidget;

  /// A [Widget] to be optionally used instead of the "Next" button.
  final Widget?  Function(void Function()? nextAction)? defaultNextWidget;

  const KeyboardActionsConfig({
    this.keyboardActionsPlatform = KeyboardActionsPlatform.ALL,
    this.nextFocus = true,
    this.actions,
    this.keyboardBarColor,
    this.keyboardBarElevation,
    this.keyboardSeparatorThickness = 1.0,
    this.keyboardSeparatorColor = Colors.transparent,
    this.defaultBarHeight,
    this.defaultDoneWidget,
    this.defaultPreviousWidget,
    this.defaultNextWidget,
  });
}
