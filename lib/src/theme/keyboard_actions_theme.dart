import 'package:flutter/material.dart';

/// Visual configuration for the keyboard action bar.
///
/// Every field is nullable. Unset values fall back to the next source in the
/// resolution chain, and finally to defaults derived from [Theme]:
///
/// 1. `KeyboardActions.theme` (single instance)
/// 2. [KeyboardActionsTheme] (subtree)
/// 3. `ThemeData.extensions` (whole app)
/// 4. Material / platform defaults
///
/// ```dart
/// KeyboardActionsTheme(
///   data: KeyboardActionsThemeData(
///     barColor: Colors.grey.shade200,
///     doneTextStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
///   ),
///   child: MaterialApp(...),
/// )
/// ```
@immutable
class KeyboardActionsThemeData
    extends ThemeExtension<KeyboardActionsThemeData> {
  /// Bar background. Defaults to a Material surface color.
  final Color? barColor;

  /// Color for arrows and, unless overridden by a text style, button labels.
  final Color? foregroundColor;

  /// Color for arrows that cannot be used (first / last field).
  final Color? disabledColor;

  /// Bar height. Defaults to 46.
  final double? barHeight;

  /// Material elevation of the bar.
  final double? elevation;

  /// Corner radius. Defaults to a pill shape on iOS 26+ unless
  /// [integratedBar] is true.
  final BorderRadius? borderRadius;

  /// Space between the bar and the system keyboard.
  final double? keyboardGap;

  /// Horizontal padding around the bar content.
  final EdgeInsetsGeometry? padding;

  /// Text style for the Done label. Merged over the default style.
  final TextStyle? doneTextStyle;

  /// Text style for the Submit label. Merged over the default style.
  final TextStyle? submitTextStyle;

  /// Icon for the "previous field" button.
  final Widget? previousIcon;

  /// Icon for the "next field" button.
  final Widget? nextIcon;

  /// When true, the bar sits flush against the system keyboard, with no gap
  /// and no rounded corners on iOS 26+. Classic accessory view look.
  final bool? integratedBar;

  /// Done label. Defaults to `'Done'`. Set here to localize app-wide.
  final String? doneText;

  /// Submit label, shown on the last field when `onSubmit` is set.
  final String? submitText;

  const KeyboardActionsThemeData({
    this.barColor,
    this.foregroundColor,
    this.disabledColor,
    this.barHeight,
    this.elevation,
    this.borderRadius,
    this.keyboardGap,
    this.padding,
    this.doneTextStyle,
    this.submitTextStyle,
    this.previousIcon,
    this.nextIcon,
    this.integratedBar,
    this.doneText,
    this.submitText,
  });

  @override
  KeyboardActionsThemeData copyWith({
    Color? barColor,
    Color? foregroundColor,
    Color? disabledColor,
    double? barHeight,
    double? elevation,
    BorderRadius? borderRadius,
    double? keyboardGap,
    EdgeInsetsGeometry? padding,
    TextStyle? doneTextStyle,
    TextStyle? submitTextStyle,
    Widget? previousIcon,
    Widget? nextIcon,
    bool? integratedBar,
    String? doneText,
    String? submitText,
  }) {
    return KeyboardActionsThemeData(
      barColor: barColor ?? this.barColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
      barHeight: barHeight ?? this.barHeight,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      keyboardGap: keyboardGap ?? this.keyboardGap,
      padding: padding ?? this.padding,
      doneTextStyle: doneTextStyle ?? this.doneTextStyle,
      submitTextStyle: submitTextStyle ?? this.submitTextStyle,
      previousIcon: previousIcon ?? this.previousIcon,
      nextIcon: nextIcon ?? this.nextIcon,
      integratedBar: integratedBar ?? this.integratedBar,
      doneText: doneText ?? this.doneText,
      submitText: submitText ?? this.submitText,
    );
  }

  /// Returns a copy where every value set in [other] wins over this one.
  KeyboardActionsThemeData merge(KeyboardActionsThemeData? other) {
    if (other == null) return this;
    return copyWith(
      barColor: other.barColor,
      foregroundColor: other.foregroundColor,
      disabledColor: other.disabledColor,
      barHeight: other.barHeight,
      elevation: other.elevation,
      borderRadius: other.borderRadius,
      keyboardGap: other.keyboardGap,
      padding: other.padding,
      doneTextStyle: other.doneTextStyle,
      submitTextStyle: other.submitTextStyle,
      previousIcon: other.previousIcon,
      nextIcon: other.nextIcon,
      integratedBar: other.integratedBar,
      doneText: other.doneText,
      submitText: other.submitText,
    );
  }

  @override
  KeyboardActionsThemeData lerp(
    covariant ThemeExtension<KeyboardActionsThemeData>? other,
    double t,
  ) {
    if (other is! KeyboardActionsThemeData) return this;
    // Widgets, flags and labels cannot be interpolated, so they snap at the
    // halfway point.
    final snapToOther = t >= 0.5;
    return KeyboardActionsThemeData(
      barColor: Color.lerp(barColor, other.barColor, t),
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t),
      barHeight: _lerpDouble(barHeight, other.barHeight, t),
      elevation: _lerpDouble(elevation, other.elevation, t),
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t),
      keyboardGap: _lerpDouble(keyboardGap, other.keyboardGap, t),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      doneTextStyle: TextStyle.lerp(doneTextStyle, other.doneTextStyle, t),
      submitTextStyle:
          TextStyle.lerp(submitTextStyle, other.submitTextStyle, t),
      previousIcon: snapToOther ? other.previousIcon : previousIcon,
      nextIcon: snapToOther ? other.nextIcon : nextIcon,
      integratedBar: snapToOther ? other.integratedBar : integratedBar,
      doneText: snapToOther ? other.doneText : doneText,
      submitText: snapToOther ? other.submitText : submitText,
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? b!) + ((b ?? a!) - (a ?? b!)) * t;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyboardActionsThemeData &&
        other.barColor == barColor &&
        other.foregroundColor == foregroundColor &&
        other.disabledColor == disabledColor &&
        other.barHeight == barHeight &&
        other.elevation == elevation &&
        other.borderRadius == borderRadius &&
        other.keyboardGap == keyboardGap &&
        other.padding == padding &&
        other.doneTextStyle == doneTextStyle &&
        other.submitTextStyle == submitTextStyle &&
        other.previousIcon == previousIcon &&
        other.nextIcon == nextIcon &&
        other.integratedBar == integratedBar &&
        other.doneText == doneText &&
        other.submitText == submitText;
  }

  @override
  int get hashCode => Object.hash(
        barColor,
        foregroundColor,
        disabledColor,
        barHeight,
        elevation,
        borderRadius,
        keyboardGap,
        padding,
        doneTextStyle,
        submitTextStyle,
        previousIcon,
        nextIcon,
        integratedBar,
        doneText,
        submitText,
      );
}

/// Applies a [KeyboardActionsThemeData] to every `KeyboardActions` below it.
///
/// Wrap `MaterialApp` to style the whole app from one place, or use
/// `ThemeData.extensions` if you prefer keeping it inside your `ThemeData`.
class KeyboardActionsTheme extends InheritedWidget {
  final KeyboardActionsThemeData data;

  const KeyboardActionsTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Nearest theme data, merged with any [ThemeData] extension, or `null`.
  static KeyboardActionsThemeData? maybeOf(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<KeyboardActionsTheme>();
    final extension = Theme.of(context).extension<KeyboardActionsThemeData>();
    if (inherited == null) return extension;
    return (extension ?? const KeyboardActionsThemeData())
        .merge(inherited.data);
  }

  /// Nearest theme data, or an empty one when nothing was provided.
  static KeyboardActionsThemeData of(BuildContext context) =>
      maybeOf(context) ?? const KeyboardActionsThemeData();

  @override
  bool updateShouldNotify(KeyboardActionsTheme oldWidget) =>
      data != oldWidget.data;
}
