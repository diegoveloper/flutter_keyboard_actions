import 'platform_web.dart' if (dart.library.io) 'platform_io.dart';

/// Class to check which is the current platform allow the compilation from web/mobile/desktop
abstract class PlatformCheck {
  static bool get isWeb => currentPlatform == PlatformCheckType.Web;
  static bool get isMacOS => currentPlatform == PlatformCheckType.MacOS;
  static bool get isWindows => currentPlatform == PlatformCheckType.Windows;
  static bool get isLinux => currentPlatform == PlatformCheckType.Linux;
  static bool get isAndroid => currentPlatform == PlatformCheckType.Android;
  static bool get isIOS => currentPlatform == PlatformCheckType.IOS;

  /// True on iOS 26 ("Liquid Glass") and above, where the system keyboard
  /// has rounded top corners. False on other platforms, or on iOS if the
  /// version string can't be parsed (so unknown versions fall back to the
  /// pre-iOS-26 flat-keyboard look rather than guessing).
  static bool get isIOS26OrAbove => isIOS && (iosMajorVersion ?? 0) >= 26;
}

enum PlatformCheckType { Web, Windows, Linux, MacOS, Android, Fuchsia, IOS }
