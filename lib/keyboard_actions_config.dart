import 'package:flutter/material.dart';
import 'keyboard_actions.dart';

/// Wrapper for a single configuration of the keyboard actions bar.
class KeyboardActionsConfig {
  /// Keyboard Action for specific platform
  /// KeyboardActionsPlatform : ANDROID , IOS , ALL
  final KeyboardActionsPlatform keyboardActionsPlatform;

  /// true to display arrows prev/next to move focus between inputs
  final bool nextFocus;

  /// KeyboardAction for each input
  final List<KeyboardAction> actions;

  /// Color of the background to the Custom keyboard buttons
  final Color keyboardBarColor;

  const KeyboardActionsConfig({
    this.keyboardActionsPlatform = KeyboardActionsPlatform.ALL,
    this.nextFocus = true,
    this.actions,
    this.keyboardBarColor,
  });
}
