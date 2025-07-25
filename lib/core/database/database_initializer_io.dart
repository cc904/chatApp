import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/log_service.dart';

final _logger = LogService.instance;

/// iOS/Android/Desktop平台的数据库文件操作实现
Future<bool> checkUserDatabaseExists(String userId) async {
  final dir = await getApplicationDocumentsDirectory();
  final dbFile = File('${dir.path}/app_database.db');
  return await dbFile.exists();
}

Future<bool> deleteDatabaseFiles(String userId) async {
  final dir = await getApplicationDocumentsDirectory();
  final dbFile = File('${dir.path}/app_database.db');
  final walFile = File('${dir.path}/app_database.db-wal');
  final shmFile = File('${dir.path}/app_database.db-shm');

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