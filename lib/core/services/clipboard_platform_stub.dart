/// 剪贴板服务平台相关操作（存根实现）

/// 检查是否为移动平台（Android或iOS）
bool isMobilePlatform() {
  throw UnsupportedError('Platform check is not supported on this platform');
}

/// 检查是否为桌面平台（macOS、Windows或Linux）  
bool isDesktopPlatform() {
  throw UnsupportedError('Platform check is not supported on this platform');
}

/// Web 专用：读取剪贴板图片（存根，非 Web 返回 null）
Future<Map<String, dynamic>?> readClipboardImageWeb() async {
  return null;
}

/// 桌面平台：是否有剪贴板图片（存根）
Future<bool> platformHasClipboardImage() async {
  return false;
}

/// 桌面平台：获取剪贴板图片数据（存根）
Future<Map<String, dynamic>?> platformGetClipboardImageData() async {
  return null;
}