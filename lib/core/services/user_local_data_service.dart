import 'dart:io';

import 'package:cc/core/database/drift_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 本地用户数据清理服务
class UserLocalDataService {
  UserLocalDataService._internal();
  static final UserLocalDataService instance = UserLocalDataService._internal();

  /// 根据 userId 删除本地 Drift 数据库文件
  /// 注意：会先尝试关闭当前数据库实例
  Future<void> wipeLocalDbForUser(String userId) async {
    if (userId.isEmpty) return;

    try {
      // 关闭当前数据库
      await AppDatabase.closeDatabase();

      final dir = await getApplicationDocumentsDirectory();
      final sanitized = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final dbFilePath = p.join(dir.path, 'app_database_${sanitized}.db');
      final dbFile = File(dbFilePath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (_) {
      // 静默失败，避免影响主流程
    }
  }
}


