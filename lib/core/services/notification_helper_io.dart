import 'dart:io';

/// 通知帮助工具（IO平台实现）

/// 获取平台特定的权限引导消息
String getPlatformPermissionMessage() {
  if (Platform.isMacOS) {
    return '请在"系统偏好设置 > 通知"中允许此应用发送通知';
  } else if (Platform.isIOS) {
    return '请在"设置 > 通知"中开启通知权限';
  } else {
    return '请在设置中开启通知权限以接收消息提醒';
  }
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

/// 检查是否为macOS平台
bool isMacOSPlatform() {
  return Platform.isMacOS;
}