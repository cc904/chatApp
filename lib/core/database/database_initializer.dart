import 'dart:io';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// 数据库初始化器
/// 负责初始化 Isar 数据库并创建必要的索引
class DatabaseInitializer {
  static final _logger = LogService.instance;
  static Isar? _isar;
  static String? _currentUserId;

  /// 数据库是否已初始化
  static bool get isInitialized => _isar != null;

  /// 当前用户ID
  static String? get currentUserId => _currentUserId;

  /// 获取数据库实例
  static Isar get isar {
    if (_isar == null) {
      throw Exception('数据库未初始化,请先调用 init() 方法');
    }
    return _isar!;
  }

  /// 初始化数据库
  ///
  /// 必须指定userId,不再支持默认数据库
  static Future<void> init({required String userId}) async {
    try {
      // 如果数据库已经初始化,且用户ID相同,则直接返回
      if (_isar != null && _currentUserId == userId) {
        _logger.i('数据库已经初始化,当前用户ID: $_currentUserId');
        return;
      }

      _logger.i('开始初始化数据库,用户ID: $userId');

      final dir = await getApplicationDocumentsDirectory();
      String dbName = '$userId.isar';

      _logger.i('使用数据库文件目录: $dir');
      _logger.i('使用数据库文件: $dbName');

      // 保存临时实例，避免初始化失败时影响全局变量
      final isarInstance = await Isar.open(
        [
          UserSchema,
          MyUserSchema,
          ConversationSchema,
          MessageSchema,
          FriendRequestSchema,
        ],
        directory: dir.path,
        name: dbName,
      );

      // 实例创建成功后才设置全局变量
      _isar = isarInstance;
      _currentUserId = userId;

      // 创建索引
      await _createIndexes();
      _logger.i('数据库初始化完成，isInitialized: $isInitialized');
    } catch (error) {
      // 确保在初始化失败时重置状态
      _isar = null;
      _currentUserId = null;
      _logger.e('数据库初始化失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 创建数据库索引
  static Future<void> _createIndexes() async {
    try {
      _logger.i('开始创建数据库索引');
      await isar.writeTxn(() async {
        // 联系人索引
        isar.users.where().filter().nameContains('').build();
        isar.users.where().filter().pinyinContains('').build();

        // 当前用户索引
        isar.myUsers.where().build();

        // 会话索引
        isar.conversations.where().filter().typeEqualTo(ConversationType.private).build();
        isar.conversations.where().filter().typeEqualTo(ConversationType.group).build();

        // 消息索引
        isar.messages.where().filter().conversationIdEqualTo('').build();
        isar.messages.where().filter().senderIdEqualTo('').build();
      });
      _logger.i('数据库索引创建完成');
    } catch (error) {
      _logger.e('创建数据库索引失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 同步ID字段
  /// 用于确保实体的ID和字符串ID保持一致
  static void syncIds(dynamic entity) {
    if (entity == null) return;

    if (entity is User) {
      entity.userId = entity.id.toString();
    } else if (entity is MyUser) {
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
        _currentUserId = null;
        _logger.i('数据库关闭完成');
      }
    } catch (error) {
      _logger.e('关闭数据库失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 检查用户数据库是否存在
  static Future<bool> userDatabaseExists(String userId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/user_$userId.isar');
      return await dbFile.exists();
    } catch (error) {
      _logger.e('检查用户数据库失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 删除用户数据库
  static Future<bool> deleteUserDatabase(String userId) async {
    try {
      // 如果当前打开的是要删除的数据库,先关闭它
      if (_currentUserId == userId && _isar != null) {
        await close();
      }

      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/user_$userId.isar');
      final lockFile = File('${dir.path}/user_$userId.isar.lock');

      if (await dbFile.exists()) {
        await dbFile.delete();
        _logger.i('删除用户数据库文件: ${dbFile.path}');
      }

      if (await lockFile.exists()) {
        await lockFile.delete();
        _logger.i('删除用户数据库锁文件: ${lockFile.path}');
      }

      return true;
    } catch (error) {
      _logger.e('删除用户数据库失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }
}
