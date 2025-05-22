import 'dart:async';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/constants/app_config.dart';

import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/core/database/database_initializer.dart';

/// HomeRepository的实现类
/// 负责用户会话初始化相关的业务逻辑
class HomeRepositoryImpl implements HomeRepository {
  final LogService _logger = LogService.instance;
  final CurrentUserProto _currentUser;

  /// 构造函数
  HomeRepositoryImpl({required CurrentUserProto currentUserProto})
      : _currentUser = currentUserProto {
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

      // 初始化通信服务
      final commInitialized = await initCommunication();
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

      // 初始化通信服务
      final communicationService = CommunicationService();

      // 连接到服务器
      final connected = await communicationService.connect(
        serverUrl: serverUrl,
        userId: _currentUser.userId,
        token: _currentUser.token,
      );

      if (connected) {
        _logger.i('实时通信连接成功');

        // 这里可以注册各种事件监听
        // 例如：在线状态变化、消息接收等

        return true;
      } else {
        _logger.e('实时通信连接失败');
        return false;
      }
    } catch (error) {
      _logger.e('初始化实时通信失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放资源');
  }
}
