import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// iOS/Android/Desktop平台的数据库连接实现
Future<DatabaseConnection> openDatabaseConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'app_database.db'));
  final executor = NativeDatabase.createInBackground(file);
  return DatabaseConnection(executor);
}