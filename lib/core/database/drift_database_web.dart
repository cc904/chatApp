import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:cc/core/services/log_service.dart';

/// Web平台的数据库连接实现
DatabaseConnection openDatabaseConnection() {
  LogService.instance.i('开始初始化Web数据库连接...');
  LogService.instance.i('构建模式: ${kReleaseMode ? 'Release' : 'Debug'}');
  
  return DatabaseConnection.delayed(Future(() async {
    try {
      LogService.instance.i('WASM文件路径: ./sqlite3.wasm');
      LogService.instance.i('Worker文件路径: ./drift_worker.dart.js');
      
      final result = await WasmDatabase.open(
        databaseName: 'app_database.db',
        sqlite3Uri: Uri.parse('./sqlite3.wasm'),
        driftWorkerUri: Uri.parse('./drift_worker.dart.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        LogService.instance.w('部分功能不可用: ${result.missingFeatures}');
      }

      LogService.instance.i('数据库连接初始化成功');
      return result.resolvedExecutor;
    } catch (e, stackTrace) {
      LogService.instance.e('数据库连接初始化失败: $e', stackTrace: stackTrace);
      rethrow;
    }
  }));
}