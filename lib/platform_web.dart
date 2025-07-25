import 'package:cc/core/services/log_service.dart';

/// 平台初始化（Web平台）
Future<void> initializePlatform() async {
  // Web平台不需要窗口管理器初始化
  // 这里可以添加Web特有的初始化逻辑
}

/// 初始化目录（Web平台）
Future<void> initializeDirectories(LogService logger) async {
  // Web平台不需要创建文件目录
  // 使用IndexedDB或其他Web存储机制
  logger.i('Web平台：跳过媒体目录创建');
}

/// 退出应用（Web平台）
void exitApp() {
  // Web平台不能直接退出，只能关闭tab
  // 使用LogService记录日志而不是print
  LogService.instance.i('Web平台：请手动关闭浏览器标签页');
}