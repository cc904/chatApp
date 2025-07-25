import 'dart:io';

/// 剪贴板服务平台相关操作（IO平台实现）

/// 检查是否为移动平台（Android或iOS）
bool isMobilePlatform() {
  return Platform.isAndroid || Platform.isIOS;
}

/// 检查是否为桌面平台（macOS、Windows或Linux）
bool isDesktopPlatform() {
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}