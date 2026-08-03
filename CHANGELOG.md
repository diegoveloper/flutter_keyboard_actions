## [5.0.1]

* automate publishing to pub.dev (`c5bcc43`)
* #266 add mounted check (@kollinmurphy)

## [5.0.0]

* **Breaking rewrite** focused on being the most reliable keyboard UX package for Flutter.
* **No scroll hijacking**: removed `BottomAreaAvoider` as the default path. The toolbar floats in an `Overlay`, and the toolbar height is reserved at the bottom of the child so Scaffold / ListView / Dialog / BottomSheet / slivers react naturally.
* Uses `Scrollable.ensureVisible` to keep the focused field visible.
* Keep `Scaffold.resizeToAvoidBottomInset: true` (Flutter default). No more `false` requirement.
* New primary API, three names for almost every use:
  * `KeyboardActions`: Prev/Next/Done (auto) with zero FocusNode setup
  * `KeyboardActions.done`: Done only. Wrap a body, a scrollable, or one field
  * `KeyboardField`: local per-field config & custom keyboard footers (no global action lists)
* **Wrap it anywhere.** `KeyboardActions` reserves the toolbar height at the bottom of its child, which inside a scrollable becomes extra scroll extent and around one shrinks the viewport by exactly the covered pixels. Both positions now behave identically, so the previous "where do I wrap?" rules are gone.
  * This also fixes a real bug: a field at the bottom of a `ListView` stayed partly behind the bar even when wrapping the list, because `ListView`'s automatic padding comes from `MediaQuery.padding` and never saw the inflated `viewInsets`.
* **Public API trimmed from 18 exported names to 10.** `KeyboardActionsController`, `KeyboardActionsScope`, `KeyboardActionsTapRegion`, `KeyboardBar`, `KeyboardFieldState`, `PlatformCheck` and `PlatformCheckType` are now internal. Use `kIsWeb` / `defaultTargetPlatform` for platform checks.
* Custom keyboards via `KeyboardField.footer` / `footerBuilder` + `KeyboardCustomInput` + `KeyboardCustomPanelMixin`.
* Material 3-aware bar styling; iOS 26 rounded bar + gap by default.
* All bar appearance in `KeyboardActionsThemeData`: colors, height, elevation, radius, padding, `doneTextStyle` / `submitTextStyle`, custom arrow icons, `doneText` / `submitText`, `integratedBar`.
  * Apply app-wide with `KeyboardActionsTheme`, or via `ThemeData.extensions` (it is a `ThemeExtension`).
  * Override one instance with `KeyboardActions.theme`.
  * Replaces the `barColor`, `barHeight` and `integratedBar` parameters.
* `Submit` now requires `onSubmit`, and it replaces Done on the last field instead of sitting next to it: submitting is the primary action there.
* Fixed `dismissOnTapOutside`, which never dismissed on iOS/Android touch. Two causes: the guard meant to protect field-to-field taps also blocked taps on inert space, and the deferred check ran in a post-frame callback without requesting a frame.
* Dismissal now happens on pointer up and ignores drags, so starting a scroll no longer closes the keyboard.
* Callbacks no longer overlap: `KeyboardActions.onDone` is now `onDismissed`, since it also fires when `dismissOnTapOutside` closes the keyboard. `KeyboardField.onDone` keeps meaning "this field's Done button" and still runs first. `onSubmit` is unchanged.
* `enabled` + `platformEnabled` collapsed into one `bool? enabled`: `null` = auto (iOS + Android), `true` = always, `false` = never.
* Custom keyboard panels (and their Done bar) slide down on dismiss and up on show, matching a soft-keyboard motion instead of popping away.
* Removed `KeyboardField.done`, `StandaloneKeyboardField` and `KeyboardActionsInsetScope`. `KeyboardActions.done(child: TextField(...))` already covered the single-field case, and reserving space made the inset scope unnecessary.
* README preview GIFs under `doc/gifs/` (record with `./tool/record_readme_gifs.sh`).

## [4.2.2]
* A lot of fixes

## [4.2.1]
* Fix Dart 3.10 nullability error. Thanks `paul-charlton`.

## [4.2.0]
* removed unfocusing for android on keyboard change (bug). Thanks `raphire08`.
* minor lints for flutter 3.7.3.

## [4.1.0]
* Dismiss the bar when the android back button is pressed (bug). Thanks `monster555`.

## [4.0.1]
* Adds `keyboardBarElevation` to `KeyboardActionsConfig`. Thanks `Rooa94`.

## [4.0.0]
* Update to Flutter 3.0. Thanks `ashim-kr-saha` and `Roaa94`.

## [3.4.0]
* Null safety migration. Thanks TheManuz

## [1.0.0 - 1.0.2]
* First release.
