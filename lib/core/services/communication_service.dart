import 'dart:async';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/proto_events.dart';
import 'package:protobuf/protobuf.dart';

/// 通信服务
/// 基于ProtoSocketService提供更高级的类型安全API
class CommunicationService {
  final LogService _logger = LogService.instance;
  final ProtoSocketService _socketService = ProtoSocketService();

  // 连接状态
  bool get isConnected => _socketService.isConnected;
  bool get isInitialized => _socketService.isInitialized; // 为兼容旧版API添加
  Stream<bool> get connectionStateStream => _socketService.connectionStateStream;

  // 事件流控制器映射
  final Map<String, StreamController<GeneratedMessage>> _eventControllers = {};

  // 为兼容旧版API添加
  final Map<String, StreamController<Map<String, dynamic>>> _legacyEventControllers = {};

  // 单例模式
  static final CommunicationService _instance = CommunicationService._internal();
  factory CommunicationService() => _instance;
  CommunicationService._internal();

  /// 连接到服务器
  /// [serverUrl] - 服务器URL
  /// [userId] - 用户ID
  /// [token] - 认证令牌
  Future<bool> connect({
    required String serverUrl,
    required String userId,
    required String token,
  }) async {
    _logger.i('连接到服务器', extra: {'serverUrl': serverUrl, 'userId': userId});

    final result = await _socketService.connect(
      serverUrl: serverUrl,
      userId: userId,
      token: token,
    );

    if (result) {
      _logger.i('连接成功，注册事件监听');
      _registerEventListeners();
    }

    return result;
  }

  /// 断开连接
  Future<void> disconnect() async {
    _logger.i('断开服务器连接');
    await _socketService.disconnect();
  }

  /// 注册所有预定义事件的监听器
  void _registerEventListeners() {
    final events = ProtoEvents.allEvents;
    _logger.i('注册所有事件监听器', extra: {'events': events.toList()});

    for (final eventName in events) {
      _registerEventListener(eventName);
    }
  }

  /// 注册单个事件的监听器
  /// [eventName] - 事件名称
  void _registerEventListener(String eventName) {
    final creator = ProtoEvents.getEventCreator(eventName);
    if (creator == null) {
      _logger.w('未找到事件对应的Protobuf类型', extra: {'eventName': eventName});
      return;
    }

    // 创建事件流控制器
    if (!_eventControllers.containsKey(eventName)) {
      _eventControllers[eventName] = StreamController<GeneratedMessage>.broadcast();
    }

    // 创建旧版事件流控制器
    if (!_legacyEventControllers.containsKey(eventName)) {
      _legacyEventControllers[eventName] = StreamController<Map<String, dynamic>>.broadcast();
    }

    // 注册Protobuf事件监听
    _socketService.onProto(eventName, creator, (message) {
      _logger.d('收到事件: $eventName', extra: {'messageType': message.runtimeType});
      _eventControllers[eventName]?.add(message);

      // 同时转换为Map格式发送到旧版API中
      final map = _convertProtoToMap(message);
      _legacyEventControllers[eventName]?.add(map);
    });

    _logger.d('注册事件监听器: $eventName');
  }

  /// 将Protobuf消息转换为Map（用于兼容旧版API）
  Map<String, dynamic> _convertProtoToMap(GeneratedMessage message) {
    // 简单实现，实际项目中应该使用更完善的转换方法
    try {
      // 这里应该实现完整的转换逻辑
      return {'message': message.toString()};
    } catch (e) {
      _logger.e('转换Protobuf到Map失败', error: e);
      return {'error': 'Failed to convert protobuf message'};
    }
  }

  /// 发送Protobuf消息
  /// [eventName] - 事件名称
  /// [message] - Protobuf消息对象
  Future<void> emitProto<T extends GeneratedMessage>(String eventName, T message) async {
    _logger.i('发送事件: $eventName [${message.runtimeType}]');

    // 验证事件类型是否匹配
    final expectedCreator = ProtoEvents.getEventCreator(eventName);
    if (expectedCreator != null) {
      final expectedType = expectedCreator().runtimeType;
      if (message.runtimeType != expectedType) {
        _logger.w('事件类型不匹配', extra: {
          'eventName': eventName,
          'expectedType': expectedType,
          'actualType': message.runtimeType,
        });
      }
    }

    await _socketService.emitProto(eventName, message);
  }

  /// 监听特定类型的事件
  /// [eventName] - 事件名称
  /// 返回指定类型的事件流
  Stream<T> onProto<T extends GeneratedMessage>(String eventName) {
    if (!_eventControllers.containsKey(eventName)) {
      _registerEventListener(eventName);
    }

    return _eventControllers[eventName]!.stream.where((event) => event is T).cast<T>();
  }

  /// 注册自定义事件
  /// [eventName] - 事件名称
  /// [creator] - 创建对应Protobuf消息的函数
  void registerCustomEvent<T extends GeneratedMessage>(String eventName, T Function() creator) {
    _logger.i('注册自定义事件', extra: {'eventName': eventName, 'type': T.toString()});
    ProtoEvents.registerEvent(eventName, creator);
    _registerEventListener(eventName);
  }

  // 以下是为了兼容旧版API添加的方法

  /// 发送事件（兼容旧版API）
  /// [eventName] - 事件名称
  /// [data] - 事件数据
  void emitEvent(String eventName, Map<String, dynamic> data) {
    _logger.i('发送旧版事件: $eventName', extra: {'data': data});

    // 转换为Protobuf消息并发送
    try {
      final creator = ProtoEvents.getEventCreator(eventName);
      if (creator != null) {
        final message = creator();
        // 这里应该将data中的数据设置到message中
        emitProto(eventName, message);
      } else {
        _logger.w('未找到事件对应的Protobuf类型，使用原始方式发送', extra: {'eventName': eventName});
        // 这里可以调用原始的Socket.io发送方法
      }
    } catch (e) {
      _logger.e('发送旧版事件失败', error: e);
    }
  }

  /// 监听事件（兼容旧版API）
  /// [eventName] - 事件名称
  Stream<Map<String, dynamic>> onEvent(String eventName) {
    if (!_legacyEventControllers.containsKey(eventName)) {
      _legacyEventControllers[eventName] = StreamController<Map<String, dynamic>>.broadcast();
      _registerEventListener(eventName);
    }

    return _legacyEventControllers[eventName]!.stream;
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放通信服务资源');

    // 关闭所有事件流控制器
    for (final controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();

    // 关闭所有旧版事件流控制器
    for (final controller in _legacyEventControllers.values) {
      controller.close();
    }
    _legacyEventControllers.clear();

    // 断开连接
    _socketService.dispose();
  }
}
