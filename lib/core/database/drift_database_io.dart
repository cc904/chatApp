import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// iOS/Android/Desktop平台的数据库连接实现
Future<DatabaseConnection> openDatabaseConnection(String userId) async {
  final dbFolder = await getApplicationDocumentsDirectory();
  // 为每个用户创建独立的数据库文件
  final sanitizedUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final file = File(p.join(dbFolder.path, 'app_database_$sanitizedUserId.db'));
  final executor = NativeDatabase.createInBackground(file);
  return DatabaseConnection(executor);
}