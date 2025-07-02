import 'dart:io';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/friend_request.dart';
// 💢💢💢 已移除：import 'database_migration.dart'; // 开发阶段不需要迁移
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
  static CurrentUser? _currentUser;

  /// 数据库是否已初始化
  static bool get isInitialized => _isar != null;

  /// 当前用户ID
  ///
  /// 可用于创建资源库实例和关联用户数据
  static CurrentUser? get currentUser => _currentUser;

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
  static Future<void> init({required CurrentUser currentUser}) async {
    try {
      // 如果数据库已经初始化,且用户ID相同,则直接返回
      if (_isar != null && _currentUser?.userId == currentUser.userId) {
        _logger.i('数据库已经初始化,当前用户ID: ${_currentUser?.userId}');
        return;
      }
      // 如果已有其他用户的数据库实例打开，先关闭它
      if (_isar != null) {
        _logger.i('关闭之前打开的数据库实例，用户ID: ${_currentUser?.userId}');
        await close();
      }

      _logger.i('初始化数据库,用户ID: ${currentUser.userId}');

      final dir = await getApplicationDocumentsDirectory();
      String dbName = currentUser.userId;

      _logger.i('使用数据库目录: ${dir.path}');

      // 检查是否已有相同名称的实例打开
      if (Isar.instanceNames.contains(dbName)) {
        _logger.w('检测到数据库实例 $dbName 已被打开，尝试关闭');
        await Isar.getInstance(dbName)?.close();
      }

      // 打开数据库
      final schemas = [
        UserSchema,
        ConversationSchema,
        MessageSchema,
        CurrentUserSchema,
        FriendRequestSchema,
      ];

      final isarInstance = await Isar.open(
        schemas,
        directory: dir.path,
        name: dbName,
        inspector: true,
      );

      // 实例创建成功后设置全局变量
      _isar = isarInstance;
      _currentUser = currentUser;

      _logger.i('数据库初始化完成');

      // 创建索引
      await _createIndexes();

      // 💢💢 重要：将当前用户信息保存到数据库中
      await _saveCurrentUserToDatabase(currentUser);

      // 💢💢💢 已移除：数据库迁移（开发阶段直接修改代码）
      // await _runMigrations(currentUser.userId);
    } catch (error) {
      // 确保在初始化失败时重置状态
      _isar = null;
      _currentUser = null;
      _logger.e('数据库初始化失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 保存当前用户信息到数据库
  ///
  /// 确保HomeLage传递的currentUser信息能够被ProfileRepository等其他组件读取到
  static Future<void> _saveCurrentUserToDatabase(
      CurrentUser currentUser) async {
    try {
      _logger.i('保存当前用户信息到数据库', extra: {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'phone': currentUser.phone,
        'email': currentUser.email,
        'avatar': currentUser.avatar,
        'status': currentUser.status,
        'hasAvatar':
            currentUser.avatar != null && currentUser.avatar!.isNotEmpty,
        'lastLoginTime': currentUser.lastLoginTime?.toIso8601String(),
      });

      // 验证必需字段是否存在
      if (currentUser.userId.isEmpty) {
        throw ArgumentError('用户ID不能为空');
      }

      // 检查并修复name字段
      try {
        final name = currentUser.name; // 尝试访问name字段
        if (name.isEmpty) {
          _logger.w('用户名为空，使用默认名称');
          currentUser.name = '用户${currentUser.userId.substring(0, 6)}';
        }
      } catch (e) {
        // name字段未初始化，设置默认值
        _logger.w('用户名未初始化，设置默认名称', extra: {'error': e.toString()});
        currentUser.name = '用户${currentUser.userId.substring(0, 6)}';
      }

      // 验证其他字段，确保non-null字段有值
      currentUser.phone ??= '';
      currentUser.email ??= '';
      currentUser.avatar ??= '';
      currentUser.status ??= 'offline';

      // 🔍 记录字段修复后的状态
      _logger.i('🔧 字段验证和修复完成', extra: {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'phone': currentUser.phone,
        'email': currentUser.email,
        'avatar': currentUser.avatar,
        'status': currentUser.status,
        'allFieldsValid': true,
      });

      await _isar!.writeTxn(() async {
        // 清除旧的用户数据
        await _isar!.currentUsers.clear();
        // 保存新的用户数据
        await _isar!.currentUsers.put(currentUser);
      });

      _logger.i('当前用户信息已保存到数据库', extra: {
        'finalUserId': currentUser.userId,
        'finalName': currentUser.name,
        'finalPhone': currentUser.phone,
        'finalEmail': currentUser.email,
        'finalStatus': currentUser.status,
      });
    } catch (error) {
      _logger.e('保存当前用户信息到数据库失败', error: error, stackTrace: StackTrace.current);

      // 如果是字段未初始化错误，提供更好的错误处理
      if (error.toString().contains('has not been initialized')) {
        _logger.e('检测到用户信息不完整，建议清除存储重新登录');

        // 可以选择清除不完整的用户数据
        try {
          final secureStorage = SecureStorageService();
          await secureStorage.clearUserCredentials();
          _logger.i('已清除不完整的用户凭证，请重新登录');
        } catch (clearError) {
          _logger.e('清除用户凭证失败', error: clearError);
        }
      }

      // 不抛出异常，因为这不影响数据库的正常使用
    }
  }

  /// 💢💢💢 已移除：数据库迁移方法（开发阶段直接修改代码）
  // static Future<void> _runMigrations(String userId) async {
  //   // 开发阶段不需要迁移
  // }

  /// 创建数据库索引
  ///
  /// 为各个集合创建必要的查询索引，提高查询性能
  static Future<void> _createIndexes() async {
    try {
      _logger.i('创建数据库索引');
      await isar.writeTxn(() async {
        // 联系人索引
        isar.users.where().filter().nameContains('').build();
        isar.users.where().filter().pinyinContains('').build();

        // 当前用户索引
        isar.currentUsers.where().build();

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
      _logger.e('创建数据库索引失败', error: error);
      // 不抛出异常，允许应用在没有索引的情况下继续运行
    }
  }

  /// 关闭数据库
  ///
  /// 安全地关闭当前打开的数据库连接
  /// 在用户退出登录或应用关闭时调用
  static Future<void> close() async {
    try {
      if (_isar != null) {
        _logger.i('关闭数据库');
        await _isar!.close();
        _isar = null;
        _currentUser = null;
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
      if (_currentUser?.userId == userId && _isar != null) {
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
