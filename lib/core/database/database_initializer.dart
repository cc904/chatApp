import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/drift_database.dart';

// 条件导入：仅在非Web平台导入IO相关依赖
import 'database_initializer_stub.dart'
    if (dart.library.io) 'database_initializer_io.dart'
    if (dart.library.html) 'database_initializer_web.dart';

/// 数据库初始化器
///
/// 负责初始化和管理Drift数据库实例，提供统一的数据库访问点
/// 主要功能：
/// 1. 初始化用户特定的数据库
/// 2. 提供数据库实例访问
/// 3. 管理数据库生命周期(打开/关闭)
/// 4. 提供数据库相关工具方法
class DatabaseInitializer {
  static final _logger = LogService.instance;
  static AppDatabase? _database;
  static CurrentUser? _currentUser;

  /// 数据库是否已初始化
  static bool get isInitialized => _database != null;

  /// 当前用户ID
  ///
  /// 可用于创建资源库实例和关联用户数据
  static CurrentUser? get currentUser => _currentUser;

  /// 获取数据库实例
  ///
  /// 如果数据库未初始化，会抛出异常
  /// 使用前应先检查 isInitialized 属性
  static AppDatabase get database {
    if (_database == null) {
      throw Exception('数据库未初始化,请先调用 init() 方法');
    }
    return _database!;
  }

  /// 保持兼容性的 isar 访问器
  static AppDatabase get isar {
    return database;
  }

  /// 初始化数据库
  ///
  /// 为特定用户创建或打开Drift数据库
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
      if (_database != null && _currentUser?.userId == currentUser.userId) {
        _logger.i('数据库已经初始化,当前用户ID: ${_currentUser?.userId}');
        return;
      }
      
      // 如果已有其他用户的数据库实例打开，先关闭它
      if (_database != null) {
        _logger.i('关闭之前打开的数据库实例，用户ID: ${_currentUser?.userId}');
        await close();
      }

      _logger.i('初始化Drift数据库,用户ID: ${currentUser.userId}');

      // 初始化Drift数据库
      await AppDatabase.init(currentUser: currentUser);
      _database = AppDatabase.instance;
      _currentUser = currentUser;

      _logger.i('Drift数据库初始化完成');
    } catch (error) {
      // 确保在初始化失败时重置状态
      _database = null;
      _currentUser = null;
      _logger.e('数据库初始化失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 关闭数据库
  ///
  /// 安全地关闭当前打开的数据库连接
  /// 在用户退出登录或应用关闭时调用
  static Future<void> close() async {
    try {
      if (_database != null) {
        _logger.i('关闭数据库');
        await AppDatabase.closeDatabase();
        _database = null;
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
      return await checkUserDatabaseExists(userId);
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
      if (_currentUser?.userId == userId && _database != null) {
        await close();
      }

      return await deleteDatabaseFiles(userId);
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
      if (_database != null) {
        _logger.w('清空数据库中的所有数据');
        
        // Drift数据库清空所有表数据
        final db = _database!;
        await db.transaction(() async {
          await db.delete(db.users).go();
          await db.delete(db.currentUsers).go();
          await db.delete(db.conversations).go();
          await db.delete(db.messages).go();
          await db.delete(db.friendRequests).go();
          await db.delete(db.quickReplies).go();
        });
        
        _logger.i('数据库清空完成');
      }
    } catch (error) {
      _logger.e('清空数据库失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }
}