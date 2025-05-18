import 'dart:async';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:protobuf/protobuf.dart';

/// Socket服务
/// 提供Socket.IO通信功能
class SocketService {
  final ProtoSocketService _protoSocketService = ProtoSocketService();

  // 连接状态
  bool get isConnected => _protoSocketService.isConnected;
  bool get isInitialized => _protoSocketService.isInitialized;
  Stream<SocketConnectionStatus> get connectionStateStream => _protoSocketService.connectionStateStream;

  // 消息流控制器
  final StreamController<dynamic> _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get onMessage => _messageController.stream;

  // 单例模式
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal() {
    _setupMessageListener();
  }

  void _setupMessageListener() {
    _protoSocketService.on('message', (data) {
      _messageController.add(data);
    });
  }

  /// 连接到服务器
  Future<bool> connect({
    required String serverUrl,
    required String token,
  }) async {
    return _protoSocketService.connect(
      serverUrl: serverUrl,
      token: token,
    );
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _protoSocketService.disconnect();
  }

  /// 发送消息
  Future<bool> emit(String eventName, dynamic data) async {
    if (data is GeneratedMessage) {
      return _protoSocketService.emitProto(eventName, data);
    } else {
      _protoSocketService.emit(eventName, data);
      return true;
    }
  }

  /// 释放资源
  void dispose() {
    _messageController.close();
    _protoSocketService.dispose();
  }
}
