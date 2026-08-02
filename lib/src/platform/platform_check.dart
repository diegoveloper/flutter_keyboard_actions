import 'platform_web.dart' if (dart.library.io) 'platform_io.dart';

abstract final class PlatformCheck {
  static bool get isWeb => currentPlatform == PlatformCheckType.web;
  static bool get isAndroid => currentPlatform == PlatformCheckType.android;
  static bool get isIOS => currentPlatform == PlatformCheckType.iOS;

  /// iOS 26+ rounded system keyboard.
  static bool get isIOS26OrAbove => isIOS && (iosMajorVersion ?? 0) >= 26;
}

enum PlatformCheckType {
  web,
  windows,
  linux,
  macOS,
  android,
  fuchsia,
  iOS,
}
