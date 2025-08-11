import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cc/core/services/log_service.dart';

/// iOS/Android/Desktop平台的数据库连接实现
Future<DatabaseConnection> openDatabaseConnection(String userId) async {
  final logger = LogService.instance;
  // 优先使用应用支持目录，避免 macOS/iOS 上对“Documents”的权限限制
  Directory dbFolder;
  try {
    dbFolder = await getApplicationSupportDirectory();
  } catch (_) {
    // 回退到 Documents 目录
    dbFolder = await getApplicationDocumentsDirectory();
  }
  // 为每个用户创建独立的数据库文件
  final sanitizedUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final dbPath = p.join(dbFolder.path, 'app_database_$sanitizedUserId.db');

  try {
    // 确保父目录存在
    await Directory(p.dirname(dbPath)).create(recursive: true);

    final file = File(dbPath);
    logger.i('准备打开数据库', extra: {
      'path': dbPath,
      'exists': await file.exists(),
      'parentExists': await Directory(p.dirname(dbPath)).exists(),
      'baseDir': dbFolder.path,
    });

    // 优先使用后台隔离打开，性能更好
    final executor = NativeDatabase.createInBackground(file);
    return DatabaseConnection(executor);
  } catch (e) {
    // 回退方案：在同一隔离中打开，避免某些平台/权限导致的 code 14 错误
    logger.w('后台隔离打开数据库失败，使用同步方式回退', extra: {
      'path': dbPath,
      'error': e.toString(),
    });
    final file = File(dbPath);
    final executor = NativeDatabase(file);
    return DatabaseConnection(executor);
  }
}