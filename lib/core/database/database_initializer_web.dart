import 'package:cc/core/services/log_service.dart';

final _logger = LogService.instance;

/// Web平台的数据库操作实现
/// Web平台使用IndexedDB或OPFS，没有传统的文件系统操作
Future<bool> checkUserDatabaseExists(String userId) async {
  // Web平台上，数据库存在性由Drift内部管理
  // 这里返回true，让应用正常初始化
  _logger.i('Web平台：跳过数据库文件存在性检查');
  return true;
}

Future<bool> deleteDatabaseFiles(String userId) async {
  // Web平台上，数据库删除需要通过Drift API
  // 这里只是记录日志，实际删除操作需要在应用层处理
  _logger.i('Web平台：数据库删除需要通过应用层API处理');
  return true;
}