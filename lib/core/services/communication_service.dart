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

  // 💢💢💢 移除：不再需要单独的重连状态流
  // Stream<bool> get reconnectingStateStream => ...

  // 实例变量
  final Map<String, StreamController<GeneratedMessage>> _eventControllers = {};
  final Map<String, dynamic Function(dynamic)> _rawEventHandlers = {};

  // 💢💢💢 新增：重连成功事件流
  final StreamController<void> _reconnectSuccessController =
      StreamController<void>.broadcast();
  Stream<void> get reconnectSuccessStream => _reconnectSuccessController.stream;

  // 💢💢💢 新增：标记是否已初始化事件通道
  bool _isEventChannelsInitialized = false;

  // 单例模式
  static final CommunicationService _instance =
      CommunicationService._internal();
  factory CommunicationService() => _instance;
  CommunicationService._internal() {
    _initConnectionListener();
    // 移除自动启动延迟监控，改为按需启动
  }

  /// 💢💢💢 新增：初始化连接状态监听
  void _initConnectionListener() {
    connectionStateStream.listen((status) {
      if (status == SocketConnectionStatus.connected) {
        _onReconnectSuccess();
      }
    });
  }


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

    if (result && !_isEventChannelsInitialized) {
      _logger.i('初次连接成功，初始化Proto事件通道');
      _setupProtoEventChannels();
      _isEventChannelsInitialized = true;
    }

    return result;
  }

  /// 断开连接
  Future<void> disconnect() async {
    _logger.i('断开服务器连接');
    await _socketService.disconnect();
  }

  /// 💢💢💢 新增：手动重连
  /// 提供统一的重连接口，供上层调用
  Future<bool> reconnect() async {
    _logger.i('🔄 开始手动重连');

    try {
      // 检查当前连接状态
      if (_socketService.isConnected) {
        _logger.i('当前已连接，无需重连');
        return true;
      }

      // 调用底层重连逻辑
      final success = await _socketService.reconnect();

      if (success) {
        _logger.i('✅ 手动重连成功');
      } else {
        _logger.w('❌ 手动重连失败');
      }

      return success;
    } catch (error) {
      _logger.e('手动重连异常', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 💢💢💢 新增：重连成功后的统一处理
  /// 当连接成功时（包括初次连接和重连），执行统一的后续处理
  void _onReconnectSuccess() {
    _logger.i('🎉 连接成功，执行重连后处理');

    try {
      // 💢💢💢 重要：只有在事件通道已初始化的情况下才重新设置（表示这是重连而非初次连接）
      if (_isEventChannelsInitialized) {
        _logger.i('重连成功，重新初始化Proto事件通道');
        _setupProtoEventChannels();
      } else {
        _logger.i('初次连接，跳过事件通道重新初始化');
      }

      // 通知所有监听者重连成功
      _reconnectSuccessController.add(null);

      _logger.i('重连成功事件已通知所有监听者');
    } catch (error) {
      _logger.e('重连成功处理异常', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 💢💢💢 新增：获取连接状态信息
  /// 提供详细的连接状态信息，用于调试和状态显示
  Map<String, dynamic> getConnectionInfo() {
    return _socketService.getConnectionInfo();
  }

  /// 初始化所有预定义Proto事件的数据通道
  /// 为每个事件创建Stream通道并设置事件转换处理
  void _setupProtoEventChannels() {
    final events = ProtoEvents.allEvents;
    _logger.i('初始化Proto事件通道', extra: {'events': events.toList()});

    // 💢💢💢 新增：重新初始化前，先清理旧的监听器以防止重复
    _cleanupEventChannels();

    for (final eventName in events) {
      _setupProtoEventChannel(eventName);
    }
  }

  /// 💢💢💢 新增：清理事件通道
  /// 清理所有现有的事件监听器，防止重复监听
  void _cleanupEventChannels() {
    _logger.d('清理旧的事件通道');

    // 清理Socket层的事件监听器
    for (final eventName in _eventControllers.keys) {
      _socketService.off(eventName);
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
  /// [retryOnFailure] - 发送失败时是否自动重试
  Future<bool> emitProto<T extends GeneratedMessage>(
      String eventName, T message,
      {bool retryOnFailure = true}) async {
    _logger.d('📤 发送Proto消息: $eventName [${message.runtimeType}]');

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

    // 尝试发送消息
    final success = await _socketService.emitProto(eventName, message);

    // 💢💢💢 新增：如果发送失败且允许重试，尝试重连后再发送
    if (!success && retryOnFailure && !_socketService.isConnected) {
      _logger.i('📤 消息发送失败，尝试重连后重发: $eventName');

      try {
        // 尝试重连
        final reconnectSuccess = await reconnect();

        if (reconnectSuccess) {
          _logger.i('📤 重连成功，重新发送消息: $eventName');
          // 重连成功后重新发送
          return await _socketService.emitProto(eventName, message);
        } else {
          _logger.w('📤 重连失败，消息发送失败: $eventName');
          return false;
        }
      } catch (error) {
        _logger.e('📤 重连重发过程异常', error: error, extra: {'eventName': eventName});
        return false;
      }
    }

    return success;
  }

  /// 监听特定类型的Proto事件
  /// 返回类型安全的数据流
  /// [eventName] - 事件名称
  Stream<T> onProto<T extends GeneratedMessage>(String eventName) {
    // _logger.i('订阅Proto事件流: $eventName [${T.toString()}]',
    //     stackTrace: StackTrace.current);

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

    // 💢💢💢 关闭重连成功事件流控制器
    _reconnectSuccessController.close();

    // 断开连接
    _socketService.dispose();
  }
}
