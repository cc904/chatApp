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

      // 💢💢💢 优化：并行初始化数据库和通信服务
      final results = await Future.wait([
        initDatabase(),
        initCommunication(),
      ]);

      final dbInitialized = results[0];
      final commInitialized = results[1];

      if (!dbInitialized) {
        _logger.e('数据库初始化失败');
        return false;
      }

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
    return await _initCommunicationWithRetry();
  }

  /// 💢💢💢 优化：带重试机制的通信初始化
  Future<bool> _initCommunicationWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _logger.i('初始化实时通信 (尝试 $attempt/$maxRetries)', 
            extra: {'userId': _currentUser.userId});

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

        // 动态超时：第一次6秒，之后递增
        final timeoutSeconds = 6 + (attempt - 1) * 2;
        final connected = await communicationService.connect(
          serverUrl: serverUrl,
          userId: _currentUser.userId,
          token: socketToken,
        ).timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            _logger.w('实时通信连接超时（${timeoutSeconds}秒），尝试 $attempt/$maxRetries');
            return false;
          },
        );

        if (connected) {
          _logger.i('实时通信连接成功 (尝试 $attempt/$maxRetries)');
          return true;
        } else {
          _logger.w('实时通信连接失败，尝试 $attempt/$maxRetries');
          
          // 最后一次尝试失败，不再重试
          if (attempt == maxRetries) {
            _logger.w('实时通信连接达到最大重试次数，进入离线模式');
            return false;
          }
          
          // 指数退避：等待时间递增
          final waitSeconds = attempt * 2;
          _logger.d('等待 ${waitSeconds}秒 后重试...');
          await Future.delayed(Duration(seconds: waitSeconds));
        }
      } catch (error) {
        _logger.e('初始化实时通信异常 (尝试 $attempt/$maxRetries)', 
            error: error, stackTrace: StackTrace.current);
        
        if (attempt == maxRetries) {
          return false;
        }
        
        // 异常后也等待一段时间再重试
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    
    return false;
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放资源');
  }
}
