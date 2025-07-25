/// 媒体缓存服务平台相关操作（存根实现）

/// 检查是否为Web平台
bool isWebPlatform() {
  throw UnsupportedError('Platform check is not supported on this platform');
}

/// 获取缓存目录路径
Future<String> getCacheDirectoryPath() async {
  throw UnsupportedError('Cache directory is not supported on this platform');
}