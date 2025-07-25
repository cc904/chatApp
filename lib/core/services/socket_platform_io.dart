import 'dart:io';

/// Socket平台相关操作（IO平台实现）

/// 获取平台操作系统版本
String getPlatformOSVersion() {
  return Platform.operatingSystemVersion;
}

/// 获取标准化的平台名称
String getStandardizedPlatformName() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}