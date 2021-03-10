## [3.4.0]
* Null safety migration. Thanks TheManuz

## [3.3.1 - 3.3.1+1]

* Fixed issue #115 when running Flutter 1.22.
* Fixed issue #106
* Fixed issue #121

## [3.3.0+1]

* Some bugs fixed: #99, #100, #101.
* `disableScroll` was added in `KeyboardActions`.


## [3.3.0]

* `KeyboardAction` was renamed to `KeyboardActionsItem` to avoid mess with the main widget `KeyboardActions`.
* Support Web compilation.

## [3.2.1+1]

* Bug fixed when Custom Keyboard has an area above footer builder. Thanks @lzhuor

## [3.2.1]

* Exposed `overscroll` property in `KeyboardActions` in case you want an extra scroll below your focused input. (default: 12).

## [3.2.0] BREAKING CHANGE

* `displayArrows` property was added in `KeyboardAction`.
* `closeWidget` and `displayCloseWidget` were removed. Now you can add multiple toolbar buttons using `toolbarButtons` property from `KeyboardAction` (check the sample updated).
* Set `displayDoneButton` to false if you don't want the DONE button by default.

## [3.1.3]

* Now you can change the size of the arrow buttons using the Theme. (Check the sample.dart file from the example folder to get more info)
* `keyboardSeparatorColor` was added in `KeyboardActionsConfig` to change the color of the line separator between keyboard and content.

## [3.1.2]

* fixed issue with `keyboardActionsPlatform`.

## [3.1.1]

* added `tapOutsideToDismiss` property inside `KeyboardActions` in case you want to press outside the keyboard to dismiss it.

## [3.1.0] BREAKING CHANGE

* API improved
* `FormKeyboardActions` was renamed to `KeyboardActions`.
* `KeyboardCustomInput` was added to help you to create custom keyboards in an easy way.
* added `enabled` property inside `KeyboardActions` in case you don't want to use `KeyboardActions` widget (tablets for example).
* added `displayActionBar` property inside `KeyboardAction` in case you want to display/hide the keyboard bar (E.g: if you use footerBuilder and add your own done button inside that)
* added `isDialog` property inside `KeyboardActions`.
* Material color is transparent to avoid issues with the parent container.



## [3.0.0] BREAKING CHANGE

* Restore the old API with some bug fixing

## [2.1.2+2]

* Keyboard dismissed when press back on Android.

## [2.1.2+1]

* Fixed issue when using `CupertinoPageScaffold`.

## [2.1.2]

* Now you can use the `IconTheme.of(context).color` and `Theme.of(context).disabledColor` to set the colors of the arrow icons (up/down).

## [2.1.0 - 2.1.1+1]

* Custom footer widget below keyboard bar
* Now you can add your custom keyboard!! 
* Thanks @jayjwarrick again for the contribution 

## [2.0.1]

* Disable next & previous buttons when there is none

## [2.0.0] ** Breaking change **

* Now `KeyboardActions` works on Dialogs
* Add KeyboardActionsConfig to make parameters easily swappable
* Add `FormKeyboardActions.setKeyboardActions` and `FormKeyboardActions` to allow changing the  config from anywhere in the child widget tree. (Check the sample)
* Thanks @jayjwarrick for the contribution

## [1.0.4]

* Added `enabled` attribute for KeyboardAction to skip the prev/next when the TextField is disabled

## [1.0.3]

* Fixed android issue when return from background

## [1.0.0 - 1.0.2]

* First release.
