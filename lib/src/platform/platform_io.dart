import 'dart:io';

import 'platform_check.dart';

PlatformCheckType get currentPlatform {
  if (Platform.isWindows) return PlatformCheckType.windows;
  if (Platform.isFuchsia) return PlatformCheckType.fuchsia;
  if (Platform.isMacOS) return PlatformCheckType.macOS;
  if (Platform.isLinux) return PlatformCheckType.linux;
  if (Platform.isIOS) return PlatformCheckType.iOS;
  return PlatformCheckType.android;
}

int? get iosMajorVersion {
  final match =
      RegExp(r'Version\s+(\d+)').firstMatch(Platform.operatingSystemVersion);
  return match == null ? null : int.tryParse(match.group(1)!);
}
