import 'dart:io';

/// 通知平台相关操作（IO平台实现）

/// 检查是否为Android平台
bool isAndroidPlatform() {
  return Platform.isAndroid;
}

/// 检查是否为iOS平台
bool isIOSPlatform() {
  return Platform.isIOS;
}

/// 检查是否为macOS平台
bool isMacOSPlatform() {
  return Platform.isMacOS;
}

/// 检查是否为Windows平台
bool isWindowsPlatform() {
  return Platform.isWindows;
}

/// 检查是否为Linux平台
bool isLinuxPlatform() {
  return Platform.isLinux;
}

/// 检查是否为Apple平台（iOS或macOS）
bool isApplePlatform() {
  return Platform.isIOS || Platform.isMacOS;
}

/// 获取平台名称
String getPlatformName() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}