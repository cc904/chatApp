import 'dart:async';
import 'dart:typed_data';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/proto_converter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// 通信服务
/// 负责与服务器的实时通信，提供统一的接口用于发送和接收事件
/// 使用Protocol Buffers作为唯一的数据序列化格式
class CommunicationService {
  final LogService _logger = LogService('communication_service.dart');
  final ProtoConverter _protoConverter = ProtoConverter();

  // Socket.io实例
  io.Socket? _socket;

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
  Future<bool> connect({
    required String userId,
    required String token,
    required String serverUrl,
  }) async {
    if (_isInitialized && _socket != null) {
      _logger.w('通信服务已初始化，无需重复初始化');
      return true;
    }

    try {
      _logger.i('初始化通信连接', extra: {
        'userId': userId,
        'serverUrl': serverUrl,
      });

      // 创建和配置Socket.io客户端
      _socket = io.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'auth': {
          'userId': userId,
          'token': token,
        },
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'timeout': 20000,
      });

      _setupSocketListeners();

      // 等待连接建立
      final connected = await _waitForConnection();
      if (!connected) {
        throw Exception('Socket.io连接超时');
      }

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

  /// 初始化匿名连接
  /// 用于登录阶段，不需要用户ID和token
  /// [serverUrl] - 服务器URL
  Future<bool> connectAnonymous({
    required String serverUrl,
  }) async {
    if (_isInitialized && _socket != null) {
      _logger.w('通信服务已初始化，无需重复初始化');
      return true;
    }

    try {
      _logger.i('初始化匿名通信连接', extra: {
        'serverUrl': serverUrl,
      });

      // 创建和配置Socket.io客户端（匿名模式）
      _socket = io.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'timeout': 20000,
      });

      _setupSocketListeners();

      // 等待连接建立
      final connected = await _waitForConnection();
      if (!connected) {
        throw Exception('Socket.io匿名连接超时');
      }

      _isInitialized = true;
      _isConnected = true;
      _connectionStateController.add(true);

      _logger.i('匿名通信服务初始化成功');
      return true;
    } catch (e) {
      _logger.e('初始化匿名通信服务失败', error: e);
      _connectionStateController.add(false);
      return false;
    }
  }

  /// 设置Socket.io事件监听器
  void _setupSocketListeners() {
    final socket = _socket;
    if (socket == null) return;

    // 连接成功
    socket.on('connect', (_) {
      _logger.i('Socket.io连接成功：${socket.id}');
      _isConnected = true;
      _connectionStateController.add(true);
    });

    // 连接错误
    socket.on('connect_error', (error) {
      _logger.e('Socket.io连接错误', error: error);
      _isConnected = false;
      _connectionStateController.add(false);
    });

    // 断开连接
    socket.on('disconnect', (reason) {
      _logger.w('Socket.io断开连接', extra: {'reason': reason});
      _isConnected = false;
      _connectionStateController.add(false);
    });

    // 重连尝试
    socket.on('reconnect_attempt', (attemptNumber) {
      _logger.i('Socket.io重连尝试', extra: {'attempt': attemptNumber});
    });

    // 重连失败
    socket.on('reconnect_failed', (_) {
      _logger.e('Socket.io重连失败');
      _isConnected = false;
      _connectionStateController.add(false);
    });

    // 重连成功
    socket.on('reconnect', (attemptNumber) {
      _logger.i('Socket.io重连成功', extra: {'attempt': attemptNumber});
      _isConnected = true;
      _connectionStateController.add(true);
    });

    // 错误事件
    socket.on('error', (error) {
      _logger.e('Socket.io错误', error: error);
    });

    // 自定义系统事件
    socket.on('system_message', (data) {
      _logger.i('收到系统消息', extra: {'data': data});
      triggerEvent('system_message', data);
    });
  }

  /// 等待Socket.io连接建立
  Future<bool> _waitForConnection() async {
    final socket = _socket;
    if (socket == null) return false;

    // 如果已连接，直接返回成功
    if (socket.connected) {
      _logger.i('Socket.io已连接');
      return true;
    }

    // 等待连接建立或超时
    final completer = Completer<bool>();

    // 监听连接事件
    void onConnect(_) {
      if (!completer.isCompleted) {
        _logger.i('Socket.io连接已建立');
        completer.complete(true);
      }
    }

    // 监听错误事件
    void onError(error) {
      if (!completer.isCompleted) {
        _logger.e('Socket.io连接错误', error: error);
        completer.complete(false);
      }
    }

    socket.on('connect', onConnect);
    socket.on('connect_error', onError);

    // 设置连接超时
    Timer timer = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        _logger.e('Socket.io连接超时');
        completer.complete(false);
      }
    });

    // 等待连接结果
    bool result = await completer.future;

    // 清理监听器和计时器
    socket.off('connect', onConnect);
    socket.off('connect_error', onError);
    timer.cancel();

    return result;
  }

  /// 升级连接
  /// 将匿名连接升级为认证连接，用于登录成功后
  /// [userId] - 用户ID
  /// [token] - 认证令牌
  Future<bool> upgradeConnection({
    required String userId,
    required String token,
  }) async {
    if (!_isInitialized || !_isConnected || _socket == null) {
      _logger.e('通信服务未初始化或连接已断开，无法升级连接');
      return false;
    }

    try {
      _logger.i('升级通信连接', extra: {
        'userId': userId,
      });

      // 发送认证事件，包含用户ID和令牌
      _socket!.emit('authenticate', {
        'userId': userId,
        'token': token,
      });

      // 监听认证结果
      final completer = Completer<bool>();

      void onAuthSuccess(data) {
        if (!completer.isCompleted) {
          _logger.i('Socket.io认证成功', extra: {'data': data});
          completer.complete(true);
        }
      }

      void onAuthError(error) {
        if (!completer.isCompleted) {
          _logger.e('Socket.io认证失败', error: error);
          completer.complete(false);
        }
      }

      _socket!.once('auth_success', onAuthSuccess);
      _socket!.once('auth_error', onAuthError);

      // 设置认证超时
      Timer timer = Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          _logger.e('Socket.io认证超时');
          completer.complete(false);
        }
      });

      // 等待认证结果
      bool result = await completer.future;

      // 清理计时器
      timer.cancel();

      if (result) {
        // 认证成功后，发送用户上线状态
        _emitServerEvent('user_online', {'userId': userId});
        _logger.i('通信连接升级成功');
      }

      return result;
    } catch (e) {
      _logger.e('升级通信连接失败', error: e);
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (!_isInitialized || _socket == null) return;

    _logger.i('断开通信连接');

    // 发送用户下线状态
    if (_isConnected) {
      // 获取当前用户ID（在实际项目中应从会话中获取）
      String? userId;
      try {
        userId = _socket?.auth?['userId'];
      } catch (e) {
        _logger.e('获取当前用户ID失败', error: e);
      }

      if (userId != null) {
        _emitServerEvent('user_offline', {'userId': userId});
      }
    }

    // 断开Socket.io连接
    try {
      _socket?.disconnect();
      _socket?.close();
      _socket = null;
    } catch (e) {
      _logger.e('断开Socket.io连接失败', error: e);
    }

    // 更新状态
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
  /// 向服务器发送自定义事件和数据，使用Protobuf序列化
  /// [eventName] - 事件名称
  /// [data] - 事件数据
  void emitEvent(String eventName, Map<String, dynamic> data) {
    if (!_isInitialized || !_isConnected || _socket == null) {
      _logger.w('通信服务未初始化或未连接，无法发送事件');
      return;
    }

    try {
      _logger.i('发送事件: $eventName', extra: {'data': data});

      // 使用Protobuf编码数据
      final encodedData = _protoConverter.encodeData(data, eventName);

      // 发送事件到服务器
      _emitServerEvent(eventName, data, encodedData);
    } catch (e) {
      _logger.e('发送事件失败', error: e);
    }
  }

  /// 向服务器发送事件
  /// 这是实际发送到服务器的方法
  /// [eventName] - 事件名称
  /// [data] - 原始事件数据 (用于日志)
  /// [encodedData] - 编码后的二进制数据 (用于发送)
  void _emitServerEvent(String eventName, Map<String, dynamic> data, [Uint8List? encodedData]) {
    if (_socket == null) return;

    _logger.d('向服务器发送事件: $eventName', extra: {
      'data': data,
      'encoding': 'protobuf',
    });

    if (encodedData != null) {
      // 发送Protobuf编码的二进制数据
      _socket!.emit(eventName, encodedData);
    } else {
      // 直接发送JSON数据（用于特殊事件）
      _socket!.emit(eventName, data);
    }
  }

  /// 处理收到的事件数据
  /// 用于将接收到的原始二进制数据转换为`Map<String, dynamic>`
  Map<String, dynamic> _processReceivedData(String eventName, dynamic rawData) {
    try {
      if (rawData is Uint8List) {
        // 处理Protobuf二进制数据
        return _protoConverter.decodeData(rawData, eventName);
      } else if (rawData is Map) {
        // 已经是Map类型，直接返回（用于特殊事件）
        return Map<String, dynamic>.from(rawData);
      } else {
        throw FormatException('不支持的数据格式: ${rawData.runtimeType}，应为Protobuf二进制数据');
      }
    } catch (e) {
      _logger.e('处理接收数据失败', error: e);
      // 返回带错误信息的数据
      return {'error': '数据解析错误', 'details': e.toString()};
    }
  }

  /// 监听事件
  /// 订阅指定类型的事件
  /// [eventName] - 事件名称
  Stream<Map<String, dynamic>> onEvent(String eventName) {
    if (!_eventControllers.containsKey(eventName)) {
      _eventControllers[eventName] = StreamController<Map<String, dynamic>>.broadcast();

      // 如果Socket已连接，设置Socket.io事件监听
      if (_socket != null) {
        _socket!.on(eventName, (data) {
          final processedData = _processReceivedData(eventName, data);
          _logger.d('收到服务器事件: $eventName', extra: {'data': processedData});
          _eventControllers[eventName]?.add(processedData);
        });
      }
    }
    return _eventControllers[eventName]!.stream;
  }

  /// 获取所有事件名称
  Set<String> get registeredEvents => _eventControllers.keys.toSet();

  /// 触发事件（用于接收服务器事件或开发阶段测试）
  /// 在特定事件的流上发送数据
  /// [eventName] - 事件名称
  /// [rawData] - 原始数据(Protobuf二进制数据)
  void triggerEvent(String eventName, dynamic rawData) {
    if (!_eventControllers.containsKey(eventName)) {
      _eventControllers[eventName] = StreamController<Map<String, dynamic>>.broadcast();
    }

    // 处理接收到的数据
    final data = _processReceivedData(eventName, rawData);

    _logger.d('触发事件: $eventName', extra: {'data': data});
    _eventControllers[eventName]!.add(data);
  }

  /// 注册所有需要监听的服务器事件
  void registerServerEvents(List<String> eventNames) {
    if (_socket == null) return;

    for (final eventName in eventNames) {
      // 创建事件流控制器
      if (!_eventControllers.containsKey(eventName)) {
        _eventControllers[eventName] = StreamController<Map<String, dynamic>>.broadcast();
      }

      // 设置Socket.io事件监听
      _socket!.on(eventName, (data) {
        final processedData = _processReceivedData(eventName, data);
        _logger.d('收到服务器事件: $eventName', extra: {'data': processedData});
        _eventControllers[eventName]?.add(processedData);
      });

      _logger.d('注册服务器事件监听: $eventName');
    }
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
