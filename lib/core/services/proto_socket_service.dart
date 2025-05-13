import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

import 'package:cc/core/services/log_service.dart';
import 'package:protobuf/protobuf.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Socket连接状态枚举
enum SocketConnectionStatus { disconnected, connecting, connected, reconnecting, error }

/// Protobuf Socket通信服务
class ProtoSocketService {
  final LogService _logger = LogService.instance;

  // Socket.io实例
  io.Socket? _socket;

  // 连接信息
  String? _serverUrl;
  String? _token;

  // 重连相关配置
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectInterval = Duration(seconds: 3);
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;

  // 标记是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 标记是否已连接
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // 当前连接状态
  SocketConnectionStatus _status = SocketConnectionStatus.disconnected;
  SocketConnectionStatus get status => _status;

  // 重连状态流控制器
  final StreamController<bool> _reconnectingStateController = StreamController<bool>.broadcast();
  Stream<bool> get reconnectingStateStream => _reconnectingStateController.stream;

  // 连接状态流控制器
  final StreamController<SocketConnectionStatus> _connectionStateController = StreamController<SocketConnectionStatus>.broadcast();
  Stream<SocketConnectionStatus> get connectionStateStream => _connectionStateController.stream;

  // 单例模式
  static final ProtoSocketService _instance = ProtoSocketService._internal();
  factory ProtoSocketService() => _instance;
  ProtoSocketService._internal();

  // 更新状态
  void _updateStatus(SocketConnectionStatus status) {
    _status = status;
    _connectionStateController.add(status);

    // 更新连接标志
    _isConnected = status == SocketConnectionStatus.connected;

    // 直接输出到控制台，确保可见
    _logger.i('Socket状态变更: $status');
  }

  /// 初始化连接
  /// [serverUrl] - 服务器URL
  /// [token] - 认证令牌
  Future<bool> connect({
    required String serverUrl,
    required String token,
  }) async {
    _logger.i('🔌 开始连接Socket.io: $serverUrl');
    _logger.i('开始连接服务器', extra: {'serverUrl': serverUrl, 'token': token});

    // 更新状态为连接中
    _updateStatus(SocketConnectionStatus.connecting);

    // 记录更详细的连接信息
    _logger.d('连接详情', extra: {
      'url': serverUrl,
      'tokenPrefix': token.length > 10 ? '${token.substring(0, 10)}...' : token,
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion
    });

    // 保存连接信息用于重连
    _serverUrl = serverUrl;
    _token = token;

    try {
      _reconnectTimer?.cancel();

      // 创建一个Completer来等待连接结果
      final completer = Completer<bool>();

      _logger.i('⚡ 创建Socket.IO实例: $serverUrl');

      // macOS 上需要特别注意的配置选项
      _socket = io.io(serverUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'], // 支持两种传输方式
        'autoConnect': true,
        'auth': {'token': token},
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 3000,
        'forceNew': true, // 强制创建新连接
        'timeout': 20000, // 增加超时时间
        'extraHeaders': {
          // 添加调试头信息
          'x-client-type': 'flutter-macos',
          'x-client-version': '1.0.0'
        },
        'path': '/socket.io/', // 明确指定路径
        'secure': serverUrl.startsWith('https'), // 根据URL设置secure选项
      });

      _logger.i('⚡ Socket.IO选项已设置，等待连接事件...');

      // 在连接前监听所有可能的事件
      // 注意：socket.io-client-dart不支持onConnecting事件
      // 直接进入连接流程

      // 设置临时监听器来捕获连接结果
      _socket?.onConnect((_) {
        _logger.i('✅ Socket.IO连接成功! SocketId: ${_socket?.id}');
        if (!completer.isCompleted) {
          _logger.i('Socket.io连接成功', extra: {'socketId': _socket?.id, 'url': serverUrl});
          _updateStatus(SocketConnectionStatus.connected);
          _isInitialized = true;
          completer.complete(true);
        }
      });

      _socket?.onConnectError((error) {
        _logger.i('❌ Socket.IO连接错误: $error');
        if (!completer.isCompleted) {
          _logger.e('Socket.io连接失败', error: error, extra: {'详细错误': error.toString(), 'url': serverUrl, 'token': token});
          _updateStatus(SocketConnectionStatus.error);
          completer.complete(false);
        }
      });

      _socket?.onError((error) {
        _logger.i('⚠️ Socket.IO错误: $error');
        if (!completer.isCompleted) {
          _logger.e('Socket.io连接错误', error: error, extra: {'详细错误': error.toString(), 'url': serverUrl});
          _updateStatus(SocketConnectionStatus.error);
          completer.complete(false);
        }
      });

      // 打印连接状态
      Timer(Duration(milliseconds: 500), () {
        _logger.i('📊 连接状态检查: connected=${_socket?.connected}, id=${_socket?.id}');
      });

      _setupSocketListeners();

      // 等待连接结果
      final success = await completer.future;

      if (!success) {
        _logger.i('❌ 连接失败');
        _logger.e('连接失败，请检查：\n1. 服务器地址是否正确\n2. 认证信息是否有效\n3. 网络连接是否正常\n4. 服务器是否运行正常');
        return false;
      }

      return true;
    } catch (error) {
      _logger.i('💥 连接异常: $error');
      _logger.e('连接异常', error: error, stackTrace: StackTrace.current);
      _updateStatus(SocketConnectionStatus.error);
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _logger.i('🔌 断开Socket.IO连接');
    _logger.i('断开服务器连接');
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _reconnectAttempts = 0;
    _socket?.disconnect();
    _updateStatus(SocketConnectionStatus.disconnected);
  }

  /// 尝试重新连接
  Future<void> _attemptReconnect() async {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('已达到最大重连次数或正在重连中', extra: {'attempts': _reconnectAttempts, 'maxAttempts': _maxReconnectAttempts, 'isReconnecting': _isReconnecting});
      return;
    }

    _isReconnecting = true;
    _reconnectingStateController.add(true);
    _updateStatus(SocketConnectionStatus.reconnecting);
    _reconnectAttempts++;

    _logger.i('🔄 尝试重新连接 #$_reconnectAttempts');
    _logger.i('尝试重新连接', extra: {'attempt': _reconnectAttempts, 'maxAttempts': _maxReconnectAttempts, 'url': _serverUrl});

    try {
      final result = await connect(
        serverUrl: _serverUrl!,
        token: _token!,
      );

      if (result) {
        _logger.i('✅ 重连成功');
        _logger.i('重连成功');
        _isReconnecting = false;
        _reconnectingStateController.add(false);
        _reconnectAttempts = 0;
      } else {
        _scheduleReconnect();
      }
    } catch (error) {
      _logger.i('❌ 重连失败: $error');
      _logger.e('重连失败', error: error);
      _scheduleReconnect();
    }
  }

  /// 安排下一次重连
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.i('⚠️ 已达到最大重连次数，停止重连');
      _logger.w('已达到最大重连次数，停止重连');
      _isReconnecting = false;
      _reconnectingStateController.add(false);
      _updateStatus(SocketConnectionStatus.error);
      return;
    }

    _reconnectTimer?.cancel();
    _logger.i('⏱️ 安排下一次重连');
    _reconnectTimer = Timer(_reconnectInterval, _attemptReconnect);
  }

  /// 设置Socket监听器
  void _setupSocketListeners() {
    _socket?.onDisconnect((reason) {
      _logger.i('🔌 Socket.io断开连接: $reason');
      _logger.w('Socket.io断开连接', extra: {'reason': reason, 'socketId': _socket?.id});
      _updateStatus(SocketConnectionStatus.disconnected);
      _attemptReconnect();
    });

    _socket?.onError((error) {
      _logger.i('⚠️ Socket.io连接错误: $error');
      _logger.e('Socket.io连接错误', error: error, extra: {'socketId': _socket?.id, '详细信息': error.toString()});
      _updateStatus(SocketConnectionStatus.error);
      _attemptReconnect();
    });

    _socket?.onReconnect((_) {
      _logger.i('🔄 Socket.io重连成功');
      _logger.i('Socket.io重连成功', extra: {'socketId': _socket?.id});
      _updateStatus(SocketConnectionStatus.connected);
      _isReconnecting = false;
      _reconnectingStateController.add(false);
      _reconnectAttempts = 0;
    });

    _socket?.onReconnectAttempt((attempt) {
      _logger.i('🔄 Socket.io重连尝试 #$attempt');
      _logger.i('Socket.io重连尝试', extra: {'attempt': attempt});
      _updateStatus(SocketConnectionStatus.reconnecting);

      // 更新认证令牌
      if (_socket != null && _token != null) {
        _socket!.auth = {'token': _token};
      }
    });

    // 添加ping/pong事件监听，用于调试
    _socket?.on('ping', (_) {
      _logger.i('📡 Socket.io ping');
      _logger.d('Socket.io ping');
    });

    _socket?.on('pong', (_) {
      _logger.i('📡 Socket.io pong');
      _logger.d('Socket.io pong');
    });

    // 监听所有事件
    _socket?.onAny((event, data) {
      _logger.i('📨 Socket.io事件: $event, 数据类型: ${data?.runtimeType}');
    });
  }

  /// 更新认证令牌
  void updateToken(String token) {
    _token = token;
    if (_socket != null) {
      _socket!.auth = {'token': token};
      _logger.i('🔑 更新Socket.io认证令牌');
      _logger.i('更新Socket.io认证令牌');
    }
  }

  /// 释放资源
  void dispose() {
    _reconnectTimer?.cancel();
    _reconnectingStateController.close();
    _connectionStateController.close();
    _socket?.disconnect();
    _socket?.dispose();
    _logger.i('🧹 Socket.io服务已释放资源');
    _logger.i('Socket.io服务已释放资源');
  }

  /// 手动检查连接状态
  String checkConnectionStatus() {
    final status = {
      'connected': _socket?.connected,
      'id': _socket?.id,
      'status': _status,
      'url': _serverUrl,
    };
    _logger.i('📊 连接状态: $status');
    return status.toString();
  }

  /// 监听Protobuf事件
  void onProto<T extends GeneratedMessage>(
    String eventName,
    T Function() creator,
    void Function(T) handler,
  ) {
    _logger.i('👂 注册Protobuf事件监听: $eventName');
    _socket?.on(eventName, (data) {
      try {
        final message = creator()..mergeFromBuffer(data);
        _logger.i('📩 接收到Protobuf事件: $eventName');
        handler(message);
      } catch (e) {
        _logger.i('❌ 解析Protobuf消息失败: $e');
        _logger.e('解析Protobuf消息失败', error: e, extra: {'eventName': eventName});
      }
    });
  }

  /// 简化版监听Protobuf事件 (直接传入处理函数)
  Stream<T> listenProto<T extends GeneratedMessage>(String eventName, T Function() creator) {
    _logger.i('👂 创建Protobuf事件流: $eventName');
    final controller = StreamController<T>.broadcast();

    _socket?.on(eventName, (data) {
      try {
        final message = creator()..mergeFromBuffer(data);
        _logger.i('📩 接收到Protobuf事件流: $eventName');
        controller.add(message);
      } catch (e) {
        _logger.i('❌ 解析Protobuf消息失败 (流): $e');
        _logger.e('解析Protobuf消息失败', error: e, extra: {'eventName': eventName});
      }
    });

    return controller.stream;
  }

  /// 发送Protobuf消息
  Future<bool> emitProto(String eventName, GeneratedMessage message) async {
    if (!_isConnected) {
      _logger.i('❌ Socket未连接，无法发送消息: $eventName');
      _logger.e('Socket未连接，无法发送消息', extra: {'eventName': eventName});
      return false;
    }

    try {
      _logger.i('📤 发送Socket消息: $eventName, 类型: ${message.runtimeType}');
      _logger.d('发送Socket消息', extra: {'eventName': eventName, 'isConnected': _isConnected});
      _socket?.emit(eventName, message.writeToBuffer());
      return true;
    } catch (e) {
      _logger.i('❌ 发送Socket消息失败: $e');
      _logger.e('发送Socket消息失败', error: e, extra: {'eventName': eventName});
      return false;
    }
  }

  /// 获取连接状态信息
  Map<String, dynamic> getConnectionInfo() {
    final info = {
      'connected': _isConnected,
      'status': _status.toString(),
      'initialized': _isInitialized,
      'serverUrl': _serverUrl,
      'socketId': _socket?.id,
      'reconnectAttempts': _reconnectAttempts,
      'isReconnecting': _isReconnecting,
    };
    _logger.i('📊 连接信息: $info');
    return info;
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
    } catch (error) {
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
