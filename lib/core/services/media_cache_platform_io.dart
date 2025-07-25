import 'package:path_provider/path_provider.dart';

/// 媒体缓存服务平台相关操作（IO平台实现）

/// 检查是否为Web平台
bool isWebPlatform() {
  return false;
}

/// 获取缓存目录路径
Future<String> getCacheDirectoryPath() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  return appDocDir.path;
}