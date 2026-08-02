/// Keyboard Actions: the easiest professional keyboard experience for Flutter.
///
/// ```dart
/// KeyboardActions(
///   child: ListView(
///     children: [
///       TextField(...),
///       KeyboardField(
///         footer: MyCustomPad(),
///         child: TextField(...),
///       ),
///     ],
///   ),
/// )
/// ```
library;

// Only the widgets you compose with are exported. The bar, its resolved style,
// the field registry, the tap-region group, and the platform helpers are
// implementation details: style the bar through KeyboardActionsThemeData.
export 'src/bar/keyboard_bar.dart' show KeyboardBarButtonBuilder;
export 'src/custom/keyboard_custom.dart';
export 'src/keyboard_actions.dart'
    show KeyboardActions, KeyboardActionsState, KeyboardNavigation;
export 'src/keyboard_field.dart' show KeyboardField;
export 'src/theme/keyboard_actions_theme.dart';
