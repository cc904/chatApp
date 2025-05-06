import 'dart:async';
import 'dart:math' as math;
// 使用但当前未用到
// import 'dart:convert';
import 'package:cc/core/services/log_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'proto_converter.dart';
import '../proto/generated/message.pb.dart';
import '../proto/generated/user.pb.dart';
// 暂时未使用到此导入
// import '../proto/generated/conversation.pb.dart';

/// Socket.IO事件枚举
enum SocketEvent {
  // 连接相关
  connect,
  disconnect,
  connecting,
  connectError,
  reconnect,
  reconnectAttempt,

  // 自定义事件
  userOnline,
  userOffline,
  newMessage,
  messageDelivered,
  messageRead,
  typing,
  stopTyping,
}

/// 数据编码方式
enum DataEncoding {
  json, // 传统JSON编码
  protobuf, // Protobuf二进制编码
  base64, // Base64编码的Protobuf (兼容性更好)
}

/// Socket服务
/// 负责管理与服务器的Socket.IO实时通信
class SocketService {
  // 单例模式
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  final LogService _logger = LogService('socket_service.dart');
  final ProtoConverter _protoConverter = ProtoConverter();

  // Socket实例
  io.Socket? _socket;

  // 连接状态
  bool _isConnected = false;
  bool _isConnecting = false;

  // 数据编码方式
  DataEncoding _dataEncoding = DataEncoding.json;

  // 事件流控制器
  final Map<SocketEvent, StreamController<dynamic>> _eventControllers = {};

  // 重连设置
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  // 模拟模式设置
  bool _simulationMode = false;
  final Map<String, StreamController<dynamic>> _simulationEvents = {};
  final Map<String, int> _simulationDelays = {
    'new_message': 300,
    'message_delivered': 500,
    'message_read': 1000,
    'user_online': 200,
    'user_offline': 200,
    'typing': 100,
    'stop_typing': 100,
  };

  // 随机数生成器，用于模拟延迟
  final math.Random _random = math.Random();

  // 获取连接状态
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  DataEncoding get dataEncoding => _dataEncoding;
  bool get isSimulationMode => _simulationMode;

  /// 设置模拟模式
  /// [enabled] - 是否启用模拟模式
  void setSimulationMode(bool enabled) {
    if (_simulationMode != enabled) {
      _logger.i('${enabled ? "启用" : "禁用"}模拟模式');
      _simulationMode = enabled;

      // 如果启用模拟模式，确保事件控制器已设置
      if (_simulationMode) {
        _setupSimulationEventControllers();
        // 模拟连接成功事件
        if (!_isConnected) {
          _isConnected = true;
          _isConnecting = false;
          _emitEvent(SocketEvent.connect, null);
        }
      }
    }
  }

  /// 设置模拟事件延迟
  /// [event] - 事件名称
  /// [delayMs] - 延迟毫秒数
  void setSimulationDelay(String event, int delayMs) {
    if (delayMs >= 0) {
      _simulationDelays[event] = delayMs;
      _logger.i('设置模拟事件 $event 的延迟为 $delayMs ms');
    }
  }

  /// 初始化Socket连接
  /// [serverUrl] - Socket.IO服务器URL
  /// [authToken] - 认证令牌
  /// [encoding] - 数据编码方式
  /// [simulationMode] - 是否启用模拟模式
  Future<bool> init({
    required String serverUrl,
    required String authToken,
    DataEncoding encoding = DataEncoding.json,
    bool simulationMode = false,
  }) async {
    _logger.i('初始化Socket连接${simulationMode ? "(模拟模式)" : ""}');
    _simulationMode = simulationMode;

    if (_simulationMode) {
      _setupSimulationEventControllers();
      // 模拟连接
      _isConnected = true;
      _isConnecting = false;
      _dataEncoding = encoding;

      // 延迟一会儿后发送连接成功事件，模拟真实网络延迟
      Future.delayed(Duration(milliseconds: 100), () {
        _emitEvent(SocketEvent.connect, null);
      });

      return true;
    }

    if (_socket != null) {
      _logger.w('Socket已初始化，关闭旧连接');
      disconnect();
    }

    try {
      _isConnecting = true;
      _dataEncoding = encoding;

      // 创建Socket连接
      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({
              'Authorization': 'Bearer $authToken',
              'Content-Type': encoding == DataEncoding.json ? 'application/json' : 'application/octet-stream',
              'X-Encoding': encoding.toString().split('.').last,
            })
            .setReconnectionAttempts(maxReconnectAttempts)
            .setReconnectionDelay(1000) // 1秒后尝试重连
            .setReconnectionDelayMax(5000) // 最大5秒的重连延迟
            .enableReconnection()
            .build(),
      );

      // 设置内置事件监听
      _setupSocketEventListeners();

      // 尝试连接
      _socket!.connect();

      return true;
    } catch (e) {
      _logger.e('初始化Socket失败', error: e);
      _isConnecting = false;
      return false;
    }
  }

  /// 断开Socket连接
  void disconnect() {
    if (_simulationMode) {
      _logger.i('断开模拟Socket连接');
      _isConnected = false;
      _isConnecting = false;
      _emitEvent(SocketEvent.disconnect, 'client disconnect');
      return;
    }

    if (_socket != null) {
      _logger.i('断开Socket连接');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _isConnecting = false;
      _reconnectAttempts = 0;
    }
  }

  /// 设置模拟事件控制器
  void _setupSimulationEventControllers() {
    final events = ['user_online', 'user_offline', 'new_message', 'message_delivered', 'message_read', 'typing', 'stop_typing'];

    for (final event in events) {
      if (!_simulationEvents.containsKey(event)) {
        _simulationEvents[event] = StreamController<dynamic>.broadcast();
      }
    }
  }

  /// 模拟接收事件
  void _simulateReceiveEvent(String event, dynamic data) {
    if (!_simulationMode || !_isConnected) return;

    // 获取模拟延迟，增加一些随机性
    final baseDelay = _simulationDelays[event] ?? 300;
    final delay = baseDelay + _random.nextInt(baseDelay ~/ 2);

    _logger.i('模拟接收事件: $event，延迟: $delay ms', extra: {'data': data});

    // 延迟后模拟接收事件
    Future.delayed(Duration(milliseconds: delay), () {
      switch (event) {
        case 'new_message':
          _emitEvent(SocketEvent.newMessage, data);
          break;
        case 'message_delivered':
          _emitEvent(SocketEvent.messageDelivered, data);
          break;
        case 'message_read':
          _emitEvent(SocketEvent.messageRead, data);
          break;
        case 'user_online':
          _emitEvent(SocketEvent.userOnline, data);
          break;
        case 'user_offline':
          _emitEvent(SocketEvent.userOffline, data);
          break;
        case 'typing':
          _emitEvent(SocketEvent.typing, data);
          break;
        case 'stop_typing':
          _emitEvent(SocketEvent.stopTyping, data);
          break;
      }
    });
  }

  /// 模拟消息响应
  void _simulateMessageResponse(Map<String, dynamic> messageData) {
    // 1. 先模拟消息已送达
    final deliveredData = {
      'messageId': messageData['messageId'],
      'conversationId': messageData['conversationId'],
      'status': 'delivered',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // 2. 然后模拟消息已读（在已送达后再等一段时间）
    final readData = {
      'messageId': messageData['messageId'],
      'conversationId': messageData['conversationId'],
      'status': 'read',
      'timestamp': DateTime.now().millisecondsSinceEpoch + 1000,
    };

    // 发送已送达事件，延迟较短
    final deliveredDelay = _simulationDelays['message_delivered'] ?? 500;
    Future.delayed(Duration(milliseconds: deliveredDelay), () {
      _simulateReceiveEvent('message_delivered', deliveredData);

      // 发送已读事件，延迟较长
      final readDelay = _simulationDelays['message_read'] ?? 1500;
      Future.delayed(Duration(milliseconds: readDelay), () {
        _simulateReceiveEvent('message_read', readData);
      });
    });
  }

  /// 设置Socket事件监听
  void _setupSocketEventListeners() {
    if (_socket == null) return;

    // 连接成功
    _socket!.onConnect((_) {
      _logger.i('Socket连接成功');
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _emitEvent(SocketEvent.connect, null);
    });

    // 连接错误
    _socket!.onConnectError((error) {
      _logger.e('Socket连接错误', error: error);
      _isConnected = false;
      _emitEvent(SocketEvent.connectError, error);
    });

    // 断开连接
    _socket!.onDisconnect((reason) {
      _logger.w('Socket断开连接', extra: {'reason': reason});
      _isConnected = false;
      _emitEvent(SocketEvent.disconnect, reason);
    });

    // 尝试重连 - 使用on方法监听reconnecting事件
    _socket!.on('reconnecting', (_) {
      _logger.i('Socket尝试重连');
      _isConnecting = true;
      _reconnectAttempts++;
      _emitEvent(SocketEvent.reconnectAttempt, _reconnectAttempts);
    });

    // 重连成功
    _socket!.onReconnect((_) {
      _logger.i('Socket重连成功');
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _emitEvent(SocketEvent.reconnect, null);
    });

    // 监听自定义事件
    _setupCustomEventListeners();
  }

  /// 设置自定义事件监听
  void _setupCustomEventListeners() {
    if (_socket == null) return;

    // 用户上线
    _socket!.on('user_online', (data) {
      _logger.i('用户上线', extra: {'data': data});
      dynamic processedData = data;

      try {
        if (data is String && _dataEncoding == DataEncoding.base64) {
          final user = _protoConverter.base64ToUser(data);
          processedData = _protoConverter.userToMap(user);
        } else if (data is List<int> && _dataEncoding == DataEncoding.protobuf) {
          final user = UserProto.fromBuffer(data);
          processedData = _protoConverter.userToMap(user);
        }
      } catch (e) {
        _logger.e('解析用户上线数据失败', error: e);
      }

      _emitEvent(SocketEvent.userOnline, processedData);
    });

    // 用户下线
    _socket!.on('user_offline', (data) {
      _logger.i('用户下线', extra: {'data': data});
      dynamic processedData = data;

      try {
        if (data is String && _dataEncoding == DataEncoding.base64) {
          final user = _protoConverter.base64ToUser(data);
          processedData = _protoConverter.userToMap(user);
        } else if (data is List<int> && _dataEncoding == DataEncoding.protobuf) {
          final user = UserProto.fromBuffer(data);
          processedData = _protoConverter.userToMap(user);
        }
      } catch (e) {
        _logger.e('解析用户下线数据失败', error: e);
      }

      _emitEvent(SocketEvent.userOffline, processedData);
    });

    // 新消息
    _socket!.on('new_message', (data) {
      _logger.i('收到新消息', extra: {'data': data});
      dynamic processedData = data;

      try {
        if (data is String && _dataEncoding == DataEncoding.base64) {
          final message = _protoConverter.base64ToMessage(data);
          processedData = _protoConverter.messageToMap(message);
        } else if (data is List<int> && _dataEncoding == DataEncoding.protobuf) {
          final message = MessageProto.fromBuffer(data);
          processedData = _protoConverter.messageToMap(message);
        }
      } catch (e) {
        _logger.e('解析新消息数据失败', error: e);
      }

      _emitEvent(SocketEvent.newMessage, processedData);
    });

    // 消息已送达
    _socket!.on('message_delivered', (data) {
      _logger.i('消息已送达', extra: {'data': data});
      _emitEvent(SocketEvent.messageDelivered, data);
    });

    // 消息已读
    _socket!.on('message_read', (data) {
      _logger.i('消息已读', extra: {'data': data});
      _emitEvent(SocketEvent.messageRead, data);
    });

    // 对方正在输入
    _socket!.on('typing', (data) {
      _logger.i('对方正在输入', extra: {'data': data});
      _emitEvent(SocketEvent.typing, data);
    });

    // 对方停止输入
    _socket!.on('stop_typing', (data) {
      _logger.i('对方停止输入', extra: {'data': data});
      _emitEvent(SocketEvent.stopTyping, data);
    });
  }

  /// 发送事件到服务器
  /// [event] - 事件名称
  /// [data] - 事件数据
  bool emit(String event, dynamic data) {
    // 如果是模拟模式，进行模拟响应
    if (_simulationMode) {
      _logger.i('模拟发送事件', extra: {'event': event, 'data': data});

      // 根据事件类型模拟不同的响应
      switch (event) {
        case 'new_message':
          // 模拟服务器返回相同的消息，表示消息已接收
          _simulateReceiveEvent('new_message', data);
          // 然后模拟消息状态更新（已送达、已读）
          if (data is Map<String, dynamic>) {
            _simulateMessageResponse(data);
          }
          break;
        case 'typing':
          // 不需要模拟响应
          break;
        case 'stop_typing':
          // 不需要模拟响应
          break;
        case 'message_read':
          // 不需要模拟响应
          break;
        case 'user_online':
          // 模拟其他用户上线
          Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)), () {
            final userId = "sim_${_random.nextInt(1000)}";
            _simulateReceiveEvent('user_online', {
              'userId': userId,
              'name': '模拟用户$userId',
              'status': 'online',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          });
          break;
        default:
          // 其他事件默认不模拟响应
          break;
      }

      return true;
    }

    if (_socket == null || !_isConnected) {
      _logger.w('Socket未连接，无法发送事件', extra: {'event': event});
      return false;
    }

    try {
      _logger.i('发送事件', extra: {'event': event, 'data': data});

      // 根据编码方式转换数据
      dynamic encodedData = data;
      if (_dataEncoding != DataEncoding.json && data is Map<String, dynamic>) {
        if (event == 'new_message') {
          final message = _protoConverter.mapToMessage(data);
          encodedData = _dataEncoding == DataEncoding.protobuf ? _protoConverter.messageToBytes(message) : _protoConverter.messageToBase64(message);
        } else if (event == 'user_online' || event == 'user_offline') {
          final user = _protoConverter.mapToUser(data);
          encodedData = _dataEncoding == DataEncoding.protobuf ? user.writeToBuffer() : _protoConverter.userToBase64(user);
        }
      }

      _socket!.emit(event, encodedData);
      return true;
    } catch (e) {
      _logger.e('发送事件失败', error: e, extra: {'event': event});
      return false;
    }
  }

  /// 监听Socket事件
  /// [event] - 要监听的事件
  /// 返回事件流
  Stream<dynamic> on(SocketEvent event) {
    if (!_eventControllers.containsKey(event)) {
      _eventControllers[event] = StreamController<dynamic>.broadcast();
    }

    return _eventControllers[event]!.stream;
  }

  /// 向事件流发送数据
  void _emitEvent(SocketEvent event, dynamic data) {
    if (_eventControllers.containsKey(event) && !_eventControllers[event]!.isClosed) {
      _eventControllers[event]!.add(data);
    }
  }

  /// 发送用户上线状态
  bool sendUserOnline() {
    return emit('user_online', {});
  }

  /// 发送用户下线状态
  bool sendUserOffline() {
    return emit('user_offline', {});
  }

  /// 发送新消息
  bool sendMessage(Map<String, dynamic> messageData) {
    return emit('new_message', messageData);
  }

  /// 发送消息已读状态
  bool sendMessageRead(String messageId, String conversationId) {
    return emit('message_read', {
      'messageId': messageId,
      'conversationId': conversationId,
    });
  }

  /// 发送正在输入状态
  bool sendTyping(String conversationId) {
    return emit('typing', {'conversationId': conversationId});
  }

  /// 发送停止输入状态
  bool sendStopTyping(String conversationId) {
    return emit('stop_typing', {'conversationId': conversationId});
  }

  /// 释放资源
  void dispose() {
    disconnect();

    // 关闭所有事件流
    for (final controller in _eventControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _eventControllers.clear();

    // 关闭模拟事件流
    for (final controller in _simulationEvents.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _simulationEvents.clear();
  }
}
