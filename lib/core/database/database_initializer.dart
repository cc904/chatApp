import 'dart:io';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:path_provider/path_provider.dart';

/// 数据库初始化器
///
/// 负责初始化和管理Isar数据库实例，提供统一的数据库访问点
/// 主要功能：
/// 1. 初始化用户特定的数据库
/// 2. 提供数据库实例访问
/// 3. 管理数据库生命周期(打开/关闭)
/// 4. 提供数据库相关工具方法
class DatabaseInitializer {
  static final _logger = LogService.instance;
  static Isar? _isar;
  static String? _currentUserId;

  /// 数据库是否已初始化
  static bool get isInitialized => _isar != null;

  /// 当前用户ID
  ///
  /// 可用于创建资源库实例和关联用户数据
  static String? get currentUserId => _currentUserId;

  /// 获取数据库实例
  ///
  /// 如果数据库未初始化，会抛出异常
  /// 使用前应先检查 isInitialized 属性
  static Isar get isar {
    if (_isar == null) {
      throw Exception('数据库未初始化,请先调用 init() 方法');
    }
    return _isar!;
  }

  /// 初始化数据库
  ///
  /// 为特定用户创建或打开Isar数据库
  /// 必须指定userId，不支持默认数据库
  ///
  /// 参数:
  /// - userId: 用户唯一标识符，用于创建用户专属数据库
  ///
  /// 异常:
  /// - 如果初始化失败，会抛出异常并记录错误信息
  static Future<void> init({required String userId}) async {
    try {
      // 如果数据库已经初始化,且用户ID相同,则直接返回
      if (_isar != null && _currentUserId == userId) {
        _logger.i('数据库已经初始化,当前用户ID: $_currentUserId');
        return;
      }

      _logger.d('开始初始化数据库,用户ID: $userId', stackTrace: StackTrace.current);

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
  ///
  /// 为各个集合创建必要的查询索引，提高查询性能
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
        isar.conversations
            .where()
            .filter()
            .typeEqualTo(ConversationType.private)
            .build();
        isar.conversations
            .where()
            .filter()
            .typeEqualTo(ConversationType.group)
            .build();

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

  /// 关闭数据库
  ///
  /// 安全地关闭当前打开的数据库连接
  /// 在用户退出登录或应用关闭时调用
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
  ///
  /// 检查特定用户的数据库文件是否已经创建
  ///
  /// 参数:
  /// - userId: 要检查的用户ID
  ///
  /// 返回值:
  /// - 如果数据库文件存在返回true，否则返回false
  static Future<bool> userDatabaseExists(String userId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/$userId.isar');
      return await dbFile.exists();
    } catch (error) {
      _logger.e('检查用户数据库失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 删除用户数据库
  ///
  /// 删除特定用户的所有数据库文件
  /// 在用户注销账号或清除数据时使用
  ///
  /// 参数:
  /// - userId: 要删除数据库的用户ID
  ///
  /// 返回值:
  /// - 操作成功返回true，失败返回false
  static Future<bool> deleteUserDatabase(String userId) async {
    try {
      // 如果当前打开的是要删除的数据库,先关闭它
      if (_currentUserId == userId && _isar != null) {
        await close();
      }

      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/$userId.isar');
      final lockFile = File('${dir.path}/$userId.isar.lock');

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

  /// 清理数据库
  ///
  /// 清空数据库中的所有数据，但保留数据库结构
  /// 谨慎使用，此操作不可撤销
  static Future<void> clearAllData() async {
    try {
      if (_isar != null) {
        _logger.w('清空数据库中的所有数据');
        await _isar!.writeTxn(() async {
          await _isar!.clear();
        });
        _logger.i('数据库清空完成');
      }
    } catch (error) {
      _logger.e('清空数据库失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }
}
