import 'package:drift/drift.dart';

/// 通用数据库接口（存根实现）
/// 实际的数据库连接由平台特定的实现提供
Future<DatabaseConnection> openDatabaseConnection() {
  throw UnsupportedError('此平台不支持数据库操作');
}