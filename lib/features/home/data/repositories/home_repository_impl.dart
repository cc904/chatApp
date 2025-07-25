import 'dart:async';

import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/constants/app_config.dart';

import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/core/database/database_initializer.dart';

/// HomeRepository的实现类
/// 负责用户会话初始化相关的业务逻辑
class HomeRepositoryImpl implements HomeRepository {
  final LogService _logger = LogService.instance;
  final CurrentUser _currentUser;

  /// 构造函数
  HomeRepositoryImpl({required CurrentUser currentUser})
      : _currentUser = currentUser {
    _logger.x('HomeRepositoryImpl 初始化');
  }

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
  Future<bool> initUserSession() async {
    try {
      _logger.i('初始化用户会话', extra: {'userId': _currentUser.userId});

      // 初始化数据库
      final dbInitialized = await initDatabase();
      if (!dbInitialized) {
        _logger.e('数据库初始化失败');
        return false;
      }

      // 初始化通信服务（允许失败，不阻塞主界面显示）
      final commInitialized = await initCommunication();
      if (!commInitialized) {
        _logger.w('通信服务初始化失败，但允许继续使用应用（离线模式）');
        // 不返回false，允许应用在离线模式下运行
      }

      _logger.i('用户会话初始化完成', extra: {
        'dbInitialized': dbInitialized,
        'commInitialized': commInitialized,
      });
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
  Future<bool> initDatabase() async {
    try {
      _logger.i('初始化数据库', extra: {'userId': _currentUser.userId});

      await DatabaseInitializer.init(currentUser: _currentUser);

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
  Future<bool> initCommunication() async {
    try {
      _logger.i('初始化实时通信', extra: {'userId': _currentUser.userId});

      // 获取服务器URL
      final serverUrl = AppConfig().serverUrl;
      _logger.d('使用服务器URL: $serverUrl');

      // 初始化通信服务
      final communicationService = CommunicationService();

      // 获取Socket连接用的正确Token
      final tokenManager = EnhancedTokenManager.instance;
      final socketToken = await tokenManager.getSocketToken();

      if (socketToken == null) {
        _logger.w('没有可用的Socket Token，跳过实时通信连接');
        return false;
      }

      _logger.d('Socket Token获取成功，准备连接');

      // 🔧 关键修复：添加超时控制，避免无限等待
      final connected = await communicationService.connect(
        serverUrl: serverUrl,
        userId: _currentUser.userId,
        token: socketToken, // 使用正确的Socket Token
      ).timeout(
        const Duration(seconds: 8), // 8秒超时，用户体验更好
        onTimeout: () {
          _logger.w('实时通信连接超时（8秒），进入离线模式');
          return false;
        },
      );

      if (connected) {
        _logger.i('实时通信连接成功');

        // 这里可以注册各种事件监听
        // 例如：在线状态变化、消息接收等

        return true;
      } else {
        _logger.w('实时通信连接失败，可能是网络问题或Token无效');
        return false;
      }
    } catch (error) {
      _logger.e('初始化实时通信异常', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放资源');
  }
}
