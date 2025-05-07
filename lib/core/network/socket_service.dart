import 'dart:async';
// 使用但当前未用到
// import 'dart:convert';
import 'package:cc/core/services/log_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'types.dart';
// 暂时未使用到此导入
// import '../proto/generated/conversation.pb.dart';

/// Socket服务
/// 负责管理与服务器的Socket.IO实时通信
class SocketService {
  // 单例模式
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  /// 获取单例实例
  static SocketService getInstance() {
    return _instance;
  }

  SocketService._internal();

  final LogService _logger = LogService('socket_service.dart');

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
  static const int maxReconnectAttempts = 5;

  // 模拟模式设置
  bool _simulationMode = false;
  final Map<String, StreamController<dynamic>> _simulationEvents = {};

  // 随机数生成器，用于模拟延迟

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

  /// 初始化Socket连接用于认证过程
  /// [serverUrl] - Socket.IO服务器URL
  /// [encoding] - 数据编码方式
  /// [simulationMode] - 是否启用模拟模式
  Future<bool> initForAuth({
    required String serverUrl,
    DataEncoding encoding = DataEncoding.json,
    bool simulationMode = false,
  }) async {
    _logger.i('初始化Socket连接(认证)${simulationMode ? "(模拟模式)" : ""}');
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

      // 创建Socket连接（认证阶段无需令牌）
      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({
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

  /// 设置模拟事件控制器
  void _setupSimulationEventControllers() {
    final events = ['user_online', 'user_offline', 'new_message', 'message_delivered', 'message_read', 'typing', 'stop_typing'];

    for (final event in events) {
      if (!_simulationEvents.containsKey(event)) {
        _simulationEvents[event] = StreamController<dynamic>.broadcast();
      }
    }
  }

  /// 设置Socket事件监听
  void _setupSocketEventListeners() {
    if (_socket == null) return;

    // 连接成功
    _socket!.onConnect((_) {
      _logger.i('Socket连接成功');
      _isConnected = true;
      _isConnecting = false;
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
  }

  /// 发送事件到服务器
  /// [event] - 事件名称
  /// [data] - 事件数据
  bool emit(String event, dynamic data) {
    // 如果是模拟模式，进行模拟响应
    if (_simulationMode) {
      _logger.i('模拟发送事件', extra: {'event': event, 'data': data});
      return true;
    }

    if (_socket == null || !_isConnected) {
      _logger.w('Socket未连接，无法发送事件', extra: {'event': event});
      return false;
    }

    try {
      _logger.i('发送事件', extra: {'event': event, 'data': data});
      _socket!.emit(event, data);
      return true;
    } catch (e) {
      _logger.e('发送事件失败', error: e, extra: {'event': event});
      return false;
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
}
