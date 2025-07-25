import 'package:cc/core/services/log_service.dart';

/// 平台初始化（存根实现）
Future<void> initializePlatform() async {
  throw UnsupportedError('此平台不支持特定的平台初始化');
}

/// 初始化目录（存根实现）
Future<void> initializeDirectories(LogService logger) async {
  throw UnsupportedError('此平台不支持目录初始化');
}

/// 退出应用（存根实现）
void exitApp() {
  throw UnsupportedError('此平台不支持退出应用');
}