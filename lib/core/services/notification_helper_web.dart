/// 通知帮助工具（Web平台实现）

/// 获取平台特定的权限引导消息
String getPlatformPermissionMessage() {
  return '请在浏览器设置中允许此网站发送通知';
}

/// 获取标准化的平台名称
String getStandardizedPlatformName() {
  return 'Web';
}

/// 检查是否为macOS平台
bool isMacOSPlatform() {
  return false; // Web平台不是macOS
}