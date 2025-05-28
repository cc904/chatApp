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
  bool get isInitialized => _socketService.isInitialized;
  Stream<SocketConnectionStatus> get connectionStateStream =>
      _socketService.connectionStateStream;

  // 获取简化的布尔状态（是否已连接）
  Stream<bool> get isConnectedStream => _socketService.connectionStateStream
      .map((status) => status == SocketConnectionStatus.connected);

  // 获取重连状态流
  Stream<bool> get reconnectingStateStream =>
      _socketService.reconnectingStateStream;

  // 事件流控制器映射
  final Map<String, StreamController<GeneratedMessage>> _eventControllers = {};

  // 原始事件处理器映射
  final Map<String, dynamic Function(dynamic)> _rawEventHandlers = {};

  // 单例模式
  static final CommunicationService _instance =
      CommunicationService._internal();
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
      token: token,
    );

    if (result) {
      _logger.i('连接成功，初始化Proto事件通道');
      _setupProtoEventChannels();
    }

    return result;
  }

  /// 断开连接
  Future<void> disconnect() async {
    _logger.i('断开服务器连接');
    await _socketService.disconnect();
  }

  /// 初始化所有预定义Proto事件的数据通道
  /// 为每个事件创建Stream通道并设置事件转换处理
  void _setupProtoEventChannels() {
    final events = ProtoEvents.allEvents;
    _logger.i('初始化Proto事件通道', extra: {'events': events.toList()});

    for (final eventName in events) {
      _setupProtoEventChannel(eventName);
    }
  }

  /// 为单个Proto事件设置数据通道
  /// 创建事件流控制器并配置Proto消息转换处理
  /// [eventName] - 事件名称
  void _setupProtoEventChannel(String eventName) {
    // _logger.x('设置Proto事件通道: $eventName');

    final creator = ProtoEvents.getEventCreator(eventName);
    if (creator == null) {
      _logger.w('无法找到Proto类型定义', extra: {'eventName': eventName});
      return;
    }

    // 创建事件流控制器
    if (!_eventControllers.containsKey(eventName)) {
      _eventControllers[eventName] =
          StreamController<GeneratedMessage>.broadcast();
    }

    // 配置Proto消息转换和处理
    _socketService.onProto(eventName, creator, (message) {
      _logger.d('收到Proto消息: $eventName',
          extra: {'messageType': message.runtimeType});

      // 添加try-catch以捕获可能的错误
      try {
        _eventControllers[eventName]?.add(message);
      } catch (e, stack) {
        _logger.e('推送消息到数据流失败',
            error: e, stackTrace: stack, extra: {'eventName': eventName});
      }
    });
  }

  /// 发送Protobuf消息
  /// [eventName] - 事件名称
  /// [message] - Protobuf消息对象
  Future<void> emitProto<T extends GeneratedMessage>(
      String eventName, T message) async {
    // _logger.d('发送Proto消息: $eventName [${message.runtimeType}]',
    //     stackTrace: StackTrace.current);

    // 验证事件类型是否匹配
    final expectedCreator = ProtoEvents.getEventCreator(eventName);
    if (expectedCreator != null) {
      final expectedType = expectedCreator().runtimeType;
      if (message.runtimeType != expectedType) {
        _logger.w('Proto类型不匹配', extra: {
          'eventName': eventName,
          'expectedType': expectedType,
          'actualType': message.runtimeType,
        });
      }
    }

    await _socketService.emitProto(eventName, message);
  }

  /// 监听特定类型的Proto事件
  /// 返回类型安全的数据流
  /// [eventName] - 事件名称
  Stream<T> onProto<T extends GeneratedMessage>(String eventName) {
    _logger.d('订阅Proto事件流: $eventName [${T.toString()}]');

    if (!_eventControllers.containsKey(eventName)) {
      _setupProtoEventChannel(eventName);
    }

    return _eventControllers[eventName]!.stream.where((event) {
      return event is T;
    }).cast<T>();
  }

  /// 注册自定义Proto事件
  /// [eventName] - 事件名称
  /// [creator] - 创建对应Protobuf消息的函数
  void registerCustomEvent<T extends GeneratedMessage>(
      String eventName, T Function() creator) {
    _logger.i('注册自定义Proto事件',
        extra: {'eventName': eventName, 'type': T.toString()});
    ProtoEvents.registerEvent(eventName, creator);
    _setupProtoEventChannel(eventName);
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放通信服务资源');

    // 移除所有原始事件处理器
    for (final entry in _rawEventHandlers.entries) {
      _socketService.off(entry.key, entry.value);
    }
    _rawEventHandlers.clear();

    // 关闭所有事件流控制器
    for (final controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();

    // 断开连接
    _socketService.dispose();
  }
}
