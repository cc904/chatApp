/// 剪贴板服务平台相关操作（Web平台实现）

/// 检查是否为移动平台（Android或iOS）
bool isMobilePlatform() {
  return false; // Web平台不是移动平台
}

/// 检查是否为桌面平台（macOS、Windows或Linux）
bool isDesktopPlatform() {
  return true; // Web平台视为桌面平台，支持剪贴板功能
}