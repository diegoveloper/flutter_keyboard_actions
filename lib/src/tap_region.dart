/// Shared [TapRegion.groupId] so taps on the floating bar / custom keyboard
/// do not unfocus [KeyboardCustomInput] or text fields.
class KeyboardActionsTapRegion {
  const KeyboardActionsTapRegion._();

  static const Object groupId = Object();
}
