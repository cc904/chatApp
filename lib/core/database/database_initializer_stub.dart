/// 数据库文件操作的存根实现
Future<bool> checkUserDatabaseExists(String userId) async {
  throw UnsupportedError('此平台不支持数据库文件检查');
}

Future<bool> deleteDatabaseFiles(String userId) async {
  throw UnsupportedError('此平台不支持数据库文件删除');
}