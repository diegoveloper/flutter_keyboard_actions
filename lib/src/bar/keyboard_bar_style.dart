import 'package:flutter/material.dart';

import '../platform/platform_check.dart';
import '../theme/keyboard_actions_theme.dart';

/// Fully resolved style for the keyboard action bar.
///
/// This is computed on every frame from [KeyboardActionsThemeData] plus runtime
/// state (keyboard visibility, platform). Users configure the bar through
/// [KeyboardActionsThemeData]; they never build this directly.
class KeyboardBarStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledColor;
  final double height;
  final double elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle doneTextStyle;
  final TextStyle submitTextStyle;
  final Widget? previousIcon;
  final Widget? nextIcon;

  /// Gap between bar and system keyboard (iOS 26+).
  final double keyboardGap;

  const KeyboardBarStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledColor,
    this.height = 46,
    this.elevation = 0,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 2),
    this.doneTextStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.submitTextStyle = const TextStyle(fontWeight: FontWeight.w600),
    this.previousIcon,
    this.nextIcon,
    this.keyboardGap = 0,
  });

  /// Resolves the bar style from [theme] and the ambient Material theme.
  factory KeyboardBarStyle.resolve(
    BuildContext context, {
    KeyboardActionsThemeData? theme,
    bool keyboardShowing = false,
  }) {
    final data = theme ?? const KeyboardActionsThemeData();
    final materialTheme = Theme.of(context);
    final scheme = materialTheme.colorScheme;
    final integratedBar = data.integratedBar ?? false;
    final rounded =
        !integratedBar && PlatformCheck.isIOS26OrAbove && keyboardShowing;

    final foregroundColor = data.foregroundColor ?? scheme.primary;

    return KeyboardBarStyle(
      backgroundColor: data.barColor ??
          (materialTheme.useMaterial3
              ? scheme.surfaceContainerHigh
              : (materialTheme.brightness == Brightness.dark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFD1D5DB))),
      foregroundColor: foregroundColor,
      disabledColor: data.disabledColor ?? materialTheme.disabledColor,
      height: data.barHeight ?? 46,
      elevation: data.elevation ?? (materialTheme.useMaterial3 ? 0 : 12),
      borderRadius:
          data.borderRadius ?? (rounded ? BorderRadius.circular(20) : null),
      padding: data.padding ?? const EdgeInsets.symmetric(horizontal: 2),
      doneTextStyle: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.bold,
      ).merge(data.doneTextStyle),
      submitTextStyle: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ).merge(data.submitTextStyle),
      previousIcon: data.previousIcon,
      nextIcon: data.nextIcon,
      keyboardGap: data.keyboardGap ?? (rounded ? 8 : 0),
    );
  }
}
