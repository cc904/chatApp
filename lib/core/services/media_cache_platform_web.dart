/// 媒体缓存服务平台相关操作（Web平台实现）

/// 检查是否为Web平台
bool isWebPlatform() {
  return true;
}

/// 获取缓存目录路径
/// Web平台不支持文件系统，返回空字符串
Future<String> getCacheDirectoryPath() async {
  return ''; // Web平台不使用本地文件缓存
}