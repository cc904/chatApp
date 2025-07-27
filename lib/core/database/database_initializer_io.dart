import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/log_service.dart';

final _logger = LogService.instance;

/// iOS/Android/Desktop平台的数据库文件操作实现
Future<bool> checkUserDatabaseExists(String userId) async {
  final dir = await getApplicationDocumentsDirectory();
  final sanitizedUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final dbFile = File('${dir.path}/app_database_$sanitizedUserId.db');
  return await dbFile.exists();
}

Future<bool> deleteDatabaseFiles(String userId) async {
  final dir = await getApplicationDocumentsDirectory();
  final sanitizedUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final dbFile = File('${dir.path}/app_database_$sanitizedUserId.db');
  final walFile = File('${dir.path}/app_database_$sanitizedUserId.db-wal');
  final shmFile = File('${dir.path}/app_database_$sanitizedUserId.db-shm');

  if (await dbFile.exists()) {
    await dbFile.delete();
    _logger.i('删除用户数据库文件: ${dbFile.path}');
  }

  if (await walFile.exists()) {
    await walFile.delete();
    _logger.i('删除用户数据库WAL文件: ${walFile.path}');
  }
  
  if (await shmFile.exists()) {
    await shmFile.delete();
    _logger.i('删除用户数据库SHM文件: ${shmFile.path}');
  }

  return true;
}

/// 列出所有用户数据库
Future<List<String>> listAllUserDatabases() async {
  final dir = await getApplicationDocumentsDirectory();
  final userIds = <String>[];
  
  try {
    await for (final entity in dir.list()) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        // 匹配 app_database_[userId].db 格式
        final regex = RegExp(r'^app_database_(.+)\.db$');
        final match = regex.firstMatch(fileName);
        if (match != null) {
          final sanitizedUserId = match.group(1)!;
          // 反向还原用户ID（虽然不能完全还原特殊字符，但可以提供基本信息）
          userIds.add(sanitizedUserId);
        }
      }
    }
  } catch (error) {
    _logger.e('列出用户数据库文件失败', error: error);
  }
  
  return userIds;
}