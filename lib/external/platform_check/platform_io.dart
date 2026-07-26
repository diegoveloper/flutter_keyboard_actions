import 'dart:io';
import 'platform_check.dart';

PlatformCheckType get currentPlatform {
  if (Platform.isWindows) return PlatformCheckType.Windows;
  if (Platform.isFuchsia) return PlatformCheckType.Fuchsia;
  if (Platform.isMacOS) return PlatformCheckType.MacOS;
  if (Platform.isLinux) return PlatformCheckType.Linux;
  if (Platform.isIOS) return PlatformCheckType.IOS;
  return PlatformCheckType.Android;
}

/// The device's iOS major version (e.g. 26 for "Version 26.0 (Build ...)"),
/// or null if not on iOS or the version string can't be parsed.
int? get iosMajorVersion {
  if (!Platform.isIOS) return null;
  final match = RegExp(r'\d+').firstMatch(Platform.operatingSystemVersion);
  return match == null ? null : int.tryParse(match.group(0)!);
}
