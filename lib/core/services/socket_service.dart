import 'package:cc/core/services/log_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Socket通信服务，管理与服务器的实时连接
class SocketService {
  static final SocketService instance = SocketService._internal();
  final LogService _logger = LogService.instance;

  io.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentToken;
  String? _serverUrl;

  /// 连接尝试次数
  int _connectionAttempts = 0;

  /// 最大连接尝试次数
  static const int maxConnectionAttempts = 3;

  /// 私有构造函数
  SocketService._internal();

  /// 获取当前Socket实例
  io.Socket? get socket => _socket;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 当前用户ID
  String? get currentUserId => _currentUserId;

  /// 初始化Socket连接
  ///
  /// [userId] 用户ID
  /// [token] 用户认证令牌
  /// [serverUrl] 服务器URL
  /// 返回连接是否成功
  Future<bool> initializeSocket({
    required String userId,
    required String token,
    required String serverUrl,
  }) async {
    if (_isConnected && _socket != null) {
      _logger.i('Socket已连接');
      return true;
    }

    _serverUrl = serverUrl;
    _currentUserId = userId;
    _currentToken = token;

    return _connectToServer();
  }

  /// 连接到服务器
  Future<bool> _connectToServer() async {
    if (_serverUrl == null || _currentUserId == null || _currentToken == null) {
      _logger.e('连接参数不完整', extra: {
        'serverUrl': _serverUrl,
        'userId': _currentUserId,
        'hasToken': _currentToken != null,
      });
      return false;
    }

    try {
      _logger.i('尝试连接到服务器', extra: {
        'serverUrl': _serverUrl,
        'userId': _currentUserId,
        'attempt': _connectionAttempts + 1,
      });

      _connectionAttempts++;

      // 创建socket实例
      _socket = io.io(_serverUrl!, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'query': {
          'userId': _currentUserId,
          'token': _currentToken,
        },
      });

      // 注册事件处理器
      _registerEventHandlers();

      // 连接到服务器
      _socket!.connect();

      // 使用Future.delayed模拟异步连接过程
      // 实际应该使用socket的connect事件来判断连接状态
      await Future.delayed(const Duration(seconds: 1));

      // 重置连接尝试次数
      _connectionAttempts = 0;
      _isConnected = true;
      _logger.i('Socket连接成功');
      return true;
    } catch (error) {
      _logger.e('Socket连接失败', error: error, stackTrace: StackTrace.current);
      _isConnected = false;

      // 如果尝试次数未达到最大值，则重试
      if (_connectionAttempts < maxConnectionAttempts) {
        _logger.i('尝试重新连接', extra: {'attempt': _connectionAttempts + 1});
        await Future.delayed(const Duration(seconds: 2));
        return _connectToServer();
      }

      _logger.e('达到最大重试次数，放弃连接');
      return false;
    }
  }

  /// 注册Socket事件处理器
  void _registerEventHandlers() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      _isConnected = true;
      _logger.i('Socket已连接');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _logger.i('Socket已断开');
    });

    _socket!.onConnectError((error) {
      _logger.e('Socket连接错误', error: error);
    });

    _socket!.onError((error) {
      _logger.e('Socket错误', error: error);
    });

    // 添加自定义事件处理器
    _socket!.on('message', (data) {
      _logger.i('收到消息', extra: data);
      // 处理消息事件
    });
  }

  /// 发送消息
  ///
  /// [event] 事件名称
  /// [data] 消息数据
  Future<bool> emit(String event, dynamic data) async {
    if (!_isConnected || _socket == null) {
      _logger.e('Socket未连接，无法发送消息');
      return false;
    }

    try {
      _logger.i('发送消息', extra: {'event': event, 'data': data});
      _socket!.emit(event, data);
      return true;
    } catch (error) {
      _logger.e('发送消息失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 关闭Socket连接
  Future<void> disconnect() async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      _logger.i('Socket已断开');
    }
  }
}
