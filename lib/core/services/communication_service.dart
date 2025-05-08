import 'dart:async';

import 'package:cc/core/services/log_service.dart';

/// 数据编码类型
enum DataEncoding {
  json, // JSON编码
  protobuf, // Protocol Buffers编码
}

/// 通信服务
/// 负责与服务器的实时通信，提供统一的接口用于发送和接收事件
class CommunicationService {
  final LogService _logger = LogService('communication_service.dart');

  // 标记是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 标记是否已连接
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // 事件流控制器集合
  final Map<String, StreamController<Map<String, dynamic>>> _eventControllers = {};

  // 连接状态流控制器
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // 单例模式
  static final CommunicationService _instance = CommunicationService._internal();
  factory CommunicationService() => _instance;
  CommunicationService._internal();

  /// 初始化连接
  /// 连接到指定服务器并进行身份验证
  /// [userId] - 用户ID
  /// [token] - 认证令牌
  /// [serverUrl] - 服务器URL
  /// [encoding] - 数据编码类型
  Future<bool> connect({
    required String userId,
    required String token,
    required String serverUrl,
    DataEncoding encoding = DataEncoding.json,
  }) async {
    if (_isInitialized) {
      _logger.w('通信服务已初始化，无需重复初始化');
      return true;
    }

    try {
      _logger.i('初始化通信连接', extra: {
        'userId': userId,
        'serverUrl': serverUrl,
      });

      // 实际连接逻辑（在实际项目中实现真实的Socket.io连接）
      // 这里简化为模拟实现
      await Future.delayed(const Duration(milliseconds: 500));
      _isInitialized = true;
      _isConnected = true;
      _connectionStateController.add(true);

      // 发送用户上线状态
      _emitServerEvent('user_online', {'userId': userId});

      _logger.i('通信服务初始化成功');
      return true;
    } catch (e) {
      _logger.e('初始化通信服务失败', error: e);
      _connectionStateController.add(false);
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (!_isInitialized) return;

    _logger.i('断开通信连接');

    // 发送用户下线状态
    if (_isConnected) {
      // 获取当前用户ID（在实际项目中应从会话中获取）
      String? userId;
      try {
        userId = null; // 应当从某处获取当前用户ID
      } catch (e) {
        _logger.e('获取当前用户ID失败', error: e);
      }

      if (userId != null) {
        _emitServerEvent('user_offline', {'userId': userId});
      }
    }

    // 断开连接
    _isConnected = false;
    _connectionStateController.add(false);
    _isInitialized = false;
  }

  /// 重新连接
  Future<bool> reconnect({
    required String userId,
    required String token,
    required String serverUrl,
  }) async {
    _logger.i('尝试重新连接');

    // 断开现有连接
    await disconnect();

    // 重新连接
    return connect(
      userId: userId,
      token: token,
      serverUrl: serverUrl,
    );
  }

  /// 发送事件
  /// 向服务器发送自定义事件和数据
  /// [eventName] - 事件名称
  /// [data] - 事件数据
  void emitEvent(String eventName, Map<String, dynamic> data) {
    if (!_isInitialized || !_isConnected) {
      _logger.w('通信服务未初始化或未连接，无法发送事件');
      return;
    }

    try {
      _logger.i('发送事件: $eventName', extra: {'data': data});

      // 实际的发送逻辑（在实际项目中通过Socket.io发送）
      _emitServerEvent(eventName, data);
    } catch (e) {
      _logger.e('发送事件失败', error: e);
    }
  }

  /// 向服务器发送事件
  /// 这是实际发送到服务器的方法，应在具体实现中覆盖
  /// [eventName] - 事件名称
  /// [data] - 事件数据
  void _emitServerEvent(String eventName, Map<String, dynamic> data) {
    // 实际项目中，这里应该实现真正的Socket.io事件发送
    _logger.d('向服务器发送事件: $eventName', extra: {'data': data});

    // 开发阶段模拟实现，实际项目中应删除
    // 模拟服务器响应以方便开发测试
    Future.delayed(Duration.zero, () {
      // 这里不应该有任何模拟响应的逻辑
      // 真实项目中，服务器会通过socket.io的事件机制返回响应
    });
  }

  /// 监听事件
  /// 订阅指定类型的事件
  /// [eventName] - 事件名称
  Stream<Map<String, dynamic>> onEvent(String eventName) {
    if (!_eventControllers.containsKey(eventName)) {
      _eventControllers[eventName] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _eventControllers[eventName]!.stream;
  }

  /// 获取所有事件名称
  Set<String> get registeredEvents => _eventControllers.keys.toSet();

  /// 触发事件（开发阶段使用）
  /// 在特定事件的流上发送数据
  /// 注意：此方法仅用于开发阶段模拟服务器发送的事件
  /// 实际项目中应通过socket收到事件后调用
  void triggerEvent(String eventName, Map<String, dynamic> data) {
    if (!_eventControllers.containsKey(eventName)) {
      _eventControllers[eventName] = StreamController<Map<String, dynamic>>.broadcast();
    }

    _logger.d('触发事件: $eventName', extra: {'data': data});
    _eventControllers[eventName]!.add(data);
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放通信服务资源');

    // 关闭所有事件流控制器
    for (final controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();

    // 关闭连接状态流控制器
    _connectionStateController.close();

    // 断开连接
    disconnect();
  }
}
