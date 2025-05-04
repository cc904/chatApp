import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/test_data_generator.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// 数据库初始化器
/// 负责初始化 Isar 数据库并创建必要的索引
class DatabaseInitializer {
  static final _logger = LogService('database_initializer.dart');
  static Isar? _isar;

  /// 数据库是否已初始化
  static bool get isInitialized => _isar != null;

  /// 获取数据库实例
  static Isar get isar {
    if (_isar == null) {
      throw Exception('数据库未初始化，请先调用 init() 方法');
    }
    return _isar!;
  }

  /// 初始化数据库
  static Future<void> init() async {
    try {
      if (_isar != null) {
        _logger.i('数据库已经初始化');
        return;
      }

      _logger.i('开始初始化数据库');
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [
          UserSchema,
          ConversationSchema,
          MessageSchema,
        ],
        directory: dir.path,
      );

      // 创建索引
      await _createIndexes();
      _logger.i('数据库初始化完成');

      // 在调试模式下生成测试数据
      if (kDebugMode) {
        _logger.i('开始生成测试数据');
        await TestDataGenerator.generateMoreTestData();
      }
    } catch (e) {
      _logger.e('数据库初始化失败', error: e);
      rethrow;
    }
  }

  /// 创建数据库索引
  static Future<void> _createIndexes() async {
    try {
      _logger.i('开始创建数据库索引');
      await isar.writeTxn(() async {
        // 用户索引
        await isar.users.where().filter().isFriendEqualTo(true).build();
        await isar.users.where().filter().isFriendEqualTo(false).build();

        // 会话索引
        await isar.conversations.where().filter().typeEqualTo(ConversationType.private).build();
        await isar.conversations.where().filter().typeEqualTo(ConversationType.group).build();

        // 消息索引
        await isar.messages.where().filter().conversationIdEqualTo('').build();
        await isar.messages.where().filter().senderIdEqualTo('').build();
      });
      _logger.i('数据库索引创建完成');
    } catch (e) {
      _logger.e('创建数据库索引失败', error: e);
      rethrow;
    }
  }

  /// 同步ID字段
  /// 用于确保实体的ID和字符串ID保持一致
  static void syncIds(dynamic entity) {
    if (entity == null) return;

    if (entity is User) {
      entity.userId = entity.id.toString();
    } else if (entity is Conversation) {
      entity.conversationId = entity.id.toString();
    } else if (entity is Message) {
      entity.messageId = entity.id.toString();
    }
  }

  /// 关闭数据库
  static Future<void> close() async {
    try {
      if (_isar != null) {
        _logger.i('开始关闭数据库');
        await _isar!.close();
        _isar = null;
        _logger.i('数据库关闭完成');
      }
    } catch (e) {
      _logger.e('关闭数据库失败', error: e);
      rethrow;
    }
  }
}
