import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:cc/core/services/log_service.dart';
import 'package:protobuf/protobuf.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;


/// Protobuf Socket通信服务
class ProtoSocketService {
  final LogService _logger = LogService.instance;

  // Socket.io实例
  io.Socket? _socket;

  // 标记是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 标记是否已连接
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // 连接状态流控制器
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // 单例模式
  static final ProtoSocketService _instance = ProtoSocketService._internal();
  factory ProtoSocketService() => _instance;
  ProtoSocketService._internal();

  /// 初始化连接
  /// [serverUrl] - 服务器URL
  /// [userId] - 用户ID
  /// [token] - 认证令牌
  Future<bool> connect({
    required String serverUrl,
    required String userId,
    required String token,
  }) async {
    try {
      // 如果已经初始化并且连接有效,检查用户ID是否匹配
      if (_isInitialized && _socket != null) {
        String? currentUserId;
        try {
          currentUserId = _socket?.auth?['userId'];
        } catch (e) {
          _logger.e('获取当前用户ID失败', error: e);
        }

        // 如果是同一用户且已连接,直接返回成功
        if (currentUserId == userId && _isConnected) {
          _logger.i('已连接到服务器,无需重连', extra: {'userId': userId});
          return true;
        }

        // 如果是不同用户或连接已断开,先断开现有连接
        _logger.i('断开旧连接并准备重连', extra: {'oldUserId': currentUserId, 'newUserId': userId});
        await disconnect();
      }

      _logger.i('初始化通信连接', extra: {
        'serverUrl': serverUrl,
        'userId': userId,
      });

      // 创建Socket.io配置
      final Map<String, dynamic> options = <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 10000,
        'timeout': 30000,
        'auth': {
          'userId': userId,
          'token': token,
        }
      };

      _logger.i('添加认证信息', extra: {'userId': userId});

      // 创建和配置Socket.io客户端
      _socket = io.io(serverUrl, options);

      _setupSocketListeners();

      // 等待连接建立
      final connected = await _waitForConnection();
      if (!connected) {
        throw Exception('Socket.io连接超时');
      }

      _isInitialized = true;
      _isConnected = true;
      _connectionStateController.add(true);

      // 发送上线状态通知
      final userStatus = UserStatus()
        ..userId = userId
        ..status = 'online'
        ..timestamp = DateTime.now().millisecondsSinceEpoch;

      // 直接使用protobuf对象发送
      emitProto('user_online', userStatus);

      _logger.i('通信服务初始化成功');
      return true;
    } catch (e) {
      _logger.e('初始化通信服务失败', error: e);
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
      // 这里需要特殊处理系统消息
    });
  }

  /// 等待Socket.io连接建立
  Future<bool> _waitForConnection() async {
    final socket = _socket;
    if (socket == null) return false;

    // 如果已连接,直接返回成功
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

  /// 断开连接
  Future<void> disconnect() async {
    if (!_isInitialized || _socket == null) return;

    _logger.i('断开通信连接');

    // 发送用户下线状态
    if (_isConnected) {
      // 获取当前用户ID
      String? userId;
      try {
        userId = _socket?.auth?['userId'];
      } catch (e) {
        _logger.e('获取当前用户ID失败', error: e);
      }

      if (userId != null) {
        final userStatus = UserStatus()
          ..userId = userId
          ..status = 'offline'
          ..timestamp = DateTime.now().millisecondsSinceEpoch;

        // 直接使用protobuf对象发送
        emitProto('user_offline', userStatus);
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
      serverUrl: serverUrl,
      userId: userId,
      token: token,
    );
  }

  /// 使用Protobuf对象发送事件
  /// [eventName] - 事件名称
  /// [message] - Protobuf生成的消息对象
  Future<void> emitProto<T extends GeneratedMessage>(String eventName, T message) async {
    if (!_isInitialized || !_isConnected || _socket == null) {
      _logger.w('通信服务未初始化或未连接,无法发送事件');
      return;
    }

    try {
      _logger.i('发送Protobuf事件: $eventName [${message.runtimeType}]');

      // 直接序列化Protobuf对象为二进制数据
      final Uint8List data = message.writeToBuffer();

      // 发送到服务器
      _socket!.emit(eventName, data);
    } catch (e) {
      _logger.e('发送Protobuf事件失败', error: e);
    }
  }

  /// 注册Protobuf事件监听
  /// [eventName] - 事件名称
  /// [createDefault] - 创建默认Protobuf消息实例的方法
  /// [handler] - 处理收到消息的回调函数
  void onProto<T extends GeneratedMessage>(String eventName, T Function() createDefault, void Function(T) handler) {
    if (_socket == null) {
      _logger.w('Socket未初始化,无法注册事件: $eventName');
      return;
    }

    _logger.d('注册Protobuf事件监听: $eventName -> ${T.toString()}');

    _socket!.on(eventName, (data) {
      try {
        // 确保数据是二进制格式
        if (data is! List<int>) {
          _logger.w('收到非二进制数据,尝试兼容处理', extra: {'dataType': data.runtimeType});

          // 如果服务器发送的是JSON,尝试处理兼容
          if (data is Map) {
            _logger.w('收到Map数据而非二进制,无法处理为Protobuf');
            return;
          }

          _logger.e('不支持的数据格式', extra: {'dataType': data.runtimeType});
          return;
        }

        // 创建默认实例并从二进制数据反序列化
        final message = createDefault()..mergeFromBuffer(data);

        _logger.d('成功反序列化Protobuf消息: $eventName [${T.toString()}]');

        // 调用处理函数
        handler(message);
      } catch (e) {
        _logger.e('处理Protobuf消息失败', error: e, extra: {'eventName': eventName});
      }
    });
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放通信服务资源');

    // 关闭连接状态流控制器
    _connectionStateController.close();

    // 断开连接
    disconnect();
  }
}

/// 用于用户在线状态的临时类
/// 这个应该在proto文件中定义并生成
class UserStatus implements GeneratedMessage {
  String userId = '';
  String status = ''; // online, offline
  int timestamp = 0;

  @override
  BuilderInfo get info_ => throw UnimplementedError('这是临时类,应该由protoc生成');

  @override
  GeneratedMessage createEmptyInstance() => UserStatus();

  @override
  GeneratedMessage clone() => UserStatus()
    ..userId = userId
    ..status = status
    ..timestamp = timestamp;

  @override
  Uint8List writeToBuffer() {
    // 由于这是临时实现，我们使用JSON并转换为二进制
    final Map<String, dynamic> json = {
      'userId': userId,
      'status': status,
      'timestamp': timestamp,
    };
    return Uint8List.fromList(json.toString().codeUnits);
  }

  @override
  void mergeFromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) {
    // 临时实现，实际上应该使用protoc生成的代码
    try {
      final jsonStr = String.fromCharCodes(i);
      final Map<String, dynamic> data = Map<String, dynamic>.from(jsonStr.startsWith('{') ? jsonDecode(jsonStr) : {'userId': '', 'status': '', 'timestamp': 0});
      userId = data['userId'] ?? '';
      status = data['status'] ?? '';
      timestamp = data['timestamp'] ?? 0;
    } catch (e) {
      // 忽略解析错误
    }
  }

  @override
  void clear() {
    userId = '';
    status = '';
    timestamp = 0;
  }

  @override
  // 补充必要的未实现方法
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} 未实现');
  }
}
