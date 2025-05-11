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

  // 连接信息
  String? _serverUrl;
  String? _userId;
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

  // 重连状态流控制器
  final StreamController<bool> _reconnectingStateController = StreamController<bool>.broadcast();
  Stream<bool> get reconnectingStateStream => _reconnectingStateController.stream;

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
    _logger.i('开始连接服务器', extra: {'serverUrl': serverUrl, 'userId': userId});

    try {
      _reconnectTimer?.cancel();

      _socket = io.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'auth': {
          'userId': userId,
          'token': token,
        },
      });

      _logger.d('Socket实例已创建', extra: {'socket': _socket?.id});

      _setupSocketListeners();
      _isInitialized = true;
      _isConnected = true;
      _connectionStateController.add(true);
      _logger.i('连接成功', extra: {'socketId': _socket?.id});
      return true;
    } catch (error) {
      _logger.e('连接失败', error: error);
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _logger.i('断开服务器连接');
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _reconnectAttempts = 0;
    _socket?.disconnect();
    _isConnected = false;
    _connectionStateController.add(false);
  }

  /// 尝试重新连接
  Future<void> _attemptReconnect() async {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('已达到最大重连次数或正在重连中', extra: {'attempts': _reconnectAttempts, 'maxAttempts': _maxReconnectAttempts, 'isReconnecting': _isReconnecting});
      return;
    }

    _isReconnecting = true;
    _reconnectingStateController.add(true);
    _reconnectAttempts++;

    _logger.i('尝试重新连接', extra: {'attempt': _reconnectAttempts, 'maxAttempts': _maxReconnectAttempts});

    try {
      final result = await connect(
        serverUrl: _serverUrl!,
        userId: _userId!,
        token: _token!,
      );

      if (result) {
        _logger.i('重连成功');
        _isReconnecting = false;
        _reconnectingStateController.add(false);
        _reconnectAttempts = 0;
      } else {
        _scheduleReconnect();
      }
    } catch (error) {
      _logger.e('重连失败', error: error);
      _scheduleReconnect();
    }
  }

  /// 安排下一次重连
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('已达到最大重连次数，停止重连');
      _isReconnecting = false;
      _reconnectingStateController.add(false);
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, _attemptReconnect);
  }

  /// 设置Socket监听器
  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      _logger.i('Socket.io已连接', extra: {'socketId': _socket?.id});
      _isConnected = true;
      _connectionStateController.add(true);
      _isReconnecting = false;
      _reconnectingStateController.add(false);
      _reconnectAttempts = 0;
    });

    _socket?.onDisconnect((reason) {
      _logger.w('Socket.io断开连接', extra: {'reason': reason, 'socketId': _socket?.id});
      _isConnected = false;
      _connectionStateController.add(false);
      _attemptReconnect();
    });

    _socket?.onError((error) {
      _logger.e('Socket.io连接错误', error: error, extra: {'socketId': _socket?.id});
      _isConnected = false;
      _connectionStateController.add(false);
      _attemptReconnect();
    });

    _socket?.onConnectError((error) {
      _logger.e('Socket.io连接错误', error: error, extra: {'socketId': _socket?.id});
    });
  }

  /// 释放资源
  void dispose() {
    _reconnectTimer?.cancel();
    _reconnectingStateController.close();
    _connectionStateController.close();
    _socket?.disconnect();
    _socket?.dispose();
  }

  /// 监听Protobuf事件
  void onProto<T extends GeneratedMessage>(
    String eventName,
    T Function() creator,
    void Function(T) handler,
  ) {
    _socket?.on(eventName, (data) {
      try {
        final message = creator()..mergeFromBuffer(data);
        handler(message);
      } catch (e) {
        _logger.e('解析Protobuf消息失败', error: e);
      }
    });
  }

  /// 发送Protobuf消息
  Future<void> emitProto(String eventName, GeneratedMessage message) async {
    if (!_isConnected) {
      _logger.e('Socket未连接，无法发送消息', extra: {'eventName': eventName});
      return;
    }
    _logger.d('发送Socket消息', extra: {'eventName': eventName, 'isConnected': _isConnected});
    _socket?.emit(eventName, message.writeToBuffer());
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
