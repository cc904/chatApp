import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/socket_service.dart';
import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/core/constants/app_config.dart';

/// HomeRepository的实现类
/// 负责用户会话初始化相关的业务逻辑
class HomeRepositoryImpl implements HomeRepository {
  final SecureStorageService _secureStorage;
  final SocketService _socketService;
  final LogService _logger = LogService.instance;
  final String _serverUrl;

  /// 构造函数
  HomeRepositoryImpl({
    required SecureStorageService secureStorage,
    required SocketService socketService,
  })  : _secureStorage = secureStorage,
        _socketService = socketService,
        _serverUrl = AppConfig().serverUrl;

  /// 初始化用户会话
  ///
  /// 完成数据库和通信服务初始化
  ///
  /// 参数:
  /// - user: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  @override
  Future<bool> initUserSession(MyUserProto user) async {
    try {
      _logger.i('初始化用户会话', extra: {'userId': user.userId});

      // 初始化数据库
      final dbInitialized = await initDatabase(user.userId);
      if (!dbInitialized) {
        _logger.e('数据库初始化失败');
        return false;
      }

      // 初始化通信服务
      final commInitialized = await initCommunication(user.userId, user.token);
      if (!commInitialized) {
        _logger.e('通信服务初始化失败');
        return false;
      }

      _logger.i('用户会话初始化成功');
      return true;
    } catch (error) {
      _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 初始化数据库
  ///
  /// 参数:
  /// - userId: 用户ID
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  @override
  Future<bool> initDatabase(String userId) async {
    try {
      _logger.i('初始化数据库', extra: {'userId': userId});

      await DatabaseInitializer.init(userId: userId);

      if (DatabaseInitializer.isInitialized) {
        _logger.i('数据库初始化成功');
        return true;
      } else {
        _logger.e('数据库初始化失败');
        return false;
      }
    } catch (error) {
      _logger.e('初始化数据库出错', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 初始化实时通信
  ///
  /// 参数:
  /// - userId: 用户ID
  /// - token: 认证令牌
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  @override
  Future<bool> initCommunication(String userId, String token) async {
    try {
      _logger.i('初始化通信服务', extra: {'userId': userId});

      int attempts = 0;
      const maxAttempts = 3;
      bool success = false;

      while (attempts < maxAttempts && !success) {
        attempts++;
        _logger.i('尝试连接到服务器', extra: {'attempt': attempts});

        success = await _socketService.initializeSocket(
          userId: userId,
          token: token,
          serverUrl: _serverUrl,
        );

        if (!success && attempts < maxAttempts) {
          _logger.i('连接失败，等待重试');
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (success) {
        _logger.i('通信服务初始化成功');
      } else {
        _logger.e('通信服务初始化失败，达到最大重试次数');
      }

      return success;
    } catch (error) {
      _logger.e('初始化通信服务出错', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 从安全存储获取用户信息
  ///
  /// 返回:
  /// - 用户信息对象，失败返回null
  @override
  Future<MyUserProto?> getUserFromSecureStorage() async {
    try {
      _logger.i('从安全存储获取用户信息');
      final user = await _secureStorage.getFullUserInfo();
      if (user != null) {
        _logger.i('成功获取用户信息', extra: {'userId': user.userId});
      } else {
        _logger.w('未找到用户信息');
      }
      return user;
    } catch (error) {
      _logger.e('获取用户信息出错', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }
}
