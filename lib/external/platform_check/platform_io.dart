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
