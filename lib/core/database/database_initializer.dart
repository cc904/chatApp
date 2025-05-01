import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import 'models/user.dart';
import 'models/conversation.dart';
import 'models/message.dart';

/// 数据库初始化器
/// 负责初始化Isar数据库并提供数据库实例
class DatabaseInitializer {
  static late Isar _isar;
  static final Logger _logger = Logger();
  static bool _isInitialized = false;

  /// 获取数据库实例
  static Isar get isar {
    if (!_isInitialized) {
      throw Exception('数据库尚未初始化，请先调用init()方法');
    }
    return _isar;
  }

  /// 初始化数据库
  static Future<void> init() async {
    if (_isInitialized) {
      _logger.w('数据库已经初始化，不需要重复初始化');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      _logger.i('数据库初始化路径: ${dir.path}');

      // 打开数据库
      _isar = await Isar.open(
        [UserSchema, ConversationSchema, MessageSchema],
        directory: dir.path,
        inspector: kDebugMode, // 调试模式启用检查器
      );

      _isInitialized = true;
      _logger.i('数据库初始化成功');
    } catch (e, stack) {
      _logger.e('数据库初始化失败', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 检查数据库是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 关闭数据库（通常在应用退出时调用）
  static Future<void> close() async {
    if (_isInitialized) {
      await _isar.close();
      _isInitialized = false;
      _logger.i('数据库已关闭');
    }
  }
  
  /// 同步模型对象的ID字段
  /// 在保存对象前调用此方法，确保兼容性ID字段与Isar ID保持一致
  static void syncIds(dynamic obj) {
    if (obj is User && obj.id > 0) {
      obj.userId = obj.id.toString();
    } else if (obj is Conversation && obj.id > 0) {
      obj.conversationId = obj.id.toString();
      obj.safeUnreadCount = obj.unreadCount < 0 ? 0 : obj.unreadCount;
    } else if (obj is Message && obj.id > 0) {
      obj.messageId = obj.id.toString();
    }
  }
}
