import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:protobuf/protobuf.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

// 条件导入：根据平台导入不同的Socket平台操作实现
import 'socket_platform_stub.dart'
    if (dart.library.io) 'socket_platform_io.dart'
    if (dart.library.html) 'socket_platform_web.dart';

/// Socket连接状态枚举
enum SocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error
}

/// Protobuf Socket通信服务
class ProtoSocketService {
  final LogService _logger = LogService.instance;

  // Socket.io实例
  io.Socket? _socket;

  // 连接信息
  String? _serverUrl;
  String? _token;

  // 重连相关配置 - 使用Socket.io内置机制
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectInterval = Duration(seconds: 3);

  // 移除自定义重连相关变量
  // Timer? _reconnectTimer;
  // bool _isReconnecting = false;
  // int _consecutiveFailures = 0;
  // DateTime? _lastReconnectAttempt;

  // 标记是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 标记是否已连接
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // 当前连接状态
  SocketConnectionStatus _status = SocketConnectionStatus.disconnected;
  SocketConnectionStatus get status => _status;

  // 连接状态流控制器
  final StreamController<SocketConnectionStatus> _connectionStateController =
      StreamController<SocketConnectionStatus>.broadcast();
  Stream<SocketConnectionStatus> get connectionStateStream =>
      _connectionStateController.stream;

  // 💢💢💢 移除：不再需要单独的重连状态流
  // Stream<bool> get reconnectingStateStream => ...

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

  /// 检查网络连接状态
  Future<Map<String, dynamic>> _checkNetworkStatus() async {
    try {
      // 检查网络连接状态
      final connectivityResult = await Connectivity().checkConnectivity();
      
      return {
        'hasConnection': connectivityResult.contains(ConnectivityResult.mobile) || 
                        connectivityResult.contains(ConnectivityResult.wifi) ||
                        connectivityResult.contains(ConnectivityResult.ethernet),
        'connectionType': connectivityResult.toString(),
        'hasNetworkPermission': true, // Android INTERNET权限在manifest中声明后自动授予
      };
    } catch (e) {
      _logger.w('网络状态检查失败', extra: {'error': e.toString()});
      return {
        'hasConnection': true, // 假设有连接，避免误判
        'connectionType': 'unknown',
        'hasNetworkPermission': true,
        'error': e.toString(),
      };
    }
  }

  /// 初始化连接
  /// [serverUrl] - 服务器URL
  /// [token] - 认证令牌
  Future<bool> connect({
    required String serverUrl,
    required String token,
  }) async {
    _logger.i('🔌 开始连接Socket.io: $serverUrl');

    // 更新状态为连接中
    _updateStatus(SocketConnectionStatus.connecting);
    
    // 🔧 新增：检查网络状态
    final networkStatus = await _checkNetworkStatus();
    _logger.i('🌐 网络状态检查', extra: networkStatus);
    
    if (!networkStatus['hasConnection']) {
      _logger.e('❌ 无网络连接', extra: {
        'connectionType': networkStatus['connectionType'],
        'hasPermission': networkStatus['hasNetworkPermission'],
      });
      _updateStatus(SocketConnectionStatus.error);
      return false;
    }
    
    if (!networkStatus['hasNetworkPermission']) {
      _logger.e('❌ 缺少网络权限', extra: networkStatus);
      _updateStatus(SocketConnectionStatus.error);
      return false;
    }
    
    // 🔧 新增：简单网络连通性测试
    try {
      _logger.d('🔍 测试服务器连通性...');
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await dio.head(
        serverUrl,
        options: Options(
          validateStatus: (status) => true, // 接受所有状态码
        ),
      );
      _logger.i('🔍 服务器连通性测试', extra: {
        'statusCode': response.statusCode,
        'reachable': response.statusCode != null,
        'responseTime': '${DateTime.now().millisecondsSinceEpoch}ms',
      });
    } catch (e) {
      _logger.w('⚠️ 服务器连通性测试失败', extra: {
        'error': e.toString(),
        'serverUrl': serverUrl,
        'suggestion': '网络可能较慢或服务器暂时不可达',
      });
      // 不直接返回false，继续尝试Socket连接
    }

    // 记录更详细的连接信息
    _logger.d('连接详情', extra: {
      'url': serverUrl,
      'tokenPrefix': token.length > 10 ? '${token.substring(0, 10)}...' : token,
      'platform': getStandardizedPlatformName(),
      'platformVersion': getPlatformOSVersion(),
      'networkType': networkStatus['connectionType'],
    });

    // 保存连接信息用于重连
    _serverUrl = serverUrl;
    _token = token;

    try {
      // 💢💢💢 清理旧的Socket实例和监听器
      if (_socket != null) {
        _logger.i('🧹 清理旧的Socket实例');
        _socket?.disconnect();
        _socket?.dispose();
        _socket = null;
      }

      // 创建一个Completer来等待连接结果
      final completer = Completer<bool>();

      _logger.i('⚡ 创建Socket.IO实例: $serverUrl');

      // macOS 上需要特别注意的配置选项
      _socket = io.io(serverUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'], // 支持两种传输方式
        'autoConnect': true,
        'auth': {'token': token},
        'reconnection': true, // 启用Socket.io内置重连
        'reconnectionAttempts': _maxReconnectAttempts, // 最大重连次数
        'reconnectionDelay': _reconnectInterval.inMilliseconds, // 重连间隔
        'reconnectionDelayMax': 10000, // 最大重连间隔
        'maxReconnectionAttempts': _maxReconnectAttempts, // 最大重连次数
        'forceNew': true, // 强制创建新连接
        'timeout': 15000, // 🔧 增加超时时间到15秒，适应移动网络
        'extraHeaders': {
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
          _updateStatus(SocketConnectionStatus.connected);
          _isInitialized = true;
          completer.complete(true);
        }
      });

      _socket?.onConnectError((error) {
        _logger.e('❌ Socket.IO连接错误', extra: {
          'error': error.toString(),
          'serverUrl': serverUrl,
          'hasToken': token.isNotEmpty,
          'tokenPrefix': token.length > 10 ? '${token.substring(0, 10)}...' : token,
        });
        if (!completer.isCompleted) {
          _updateStatus(SocketConnectionStatus.error);
          completer.complete(false);
        }
      });

      _socket?.onError((error) {
        _logger.e('⚠️ Socket.IO通用错误', extra: {
          'error': error.toString(),
          'serverUrl': serverUrl,
          'socketId': _socket?.id,
          'connected': _socket?.connected,
        });
        if (!completer.isCompleted) {
          _updateStatus(SocketConnectionStatus.error);
          completer.complete(false);
        }
      });

      // 打印连接状态
      Timer(const Duration(milliseconds: 500), () {
        _logger
            .i('📊 连接状态检查: connected=${_socket?.connected}, id=${_socket?.id}');
      });

      _setupSocketListeners();

      // 🔧 关键修复：添加明确的超时控制，防止无限等待
      final success = await completer.future.timeout(
        const Duration(seconds: 20), // 20秒超时，适应移动网络环境
        onTimeout: () {
          _logger.e('💥 Socket连接超时（20秒）', extra: {
            'serverUrl': serverUrl,
            'socketConnected': _socket?.connected,
            'socketId': _socket?.id,
            'reason': '网络连接过慢或服务器无响应',
          });
          _updateStatus(SocketConnectionStatus.error);
          
          // 清理Socket实例
          _socket?.disconnect();
          _socket?.dispose();
          _socket = null;
          
          return false;
        },
      );

      if (!success) {
        _logger.i('❌ 连接失败');

        // 如果连接失败且当前URL是配置中的服务器，尝试故障转移
        final appConfig = AppConfig();
        if (serverUrl == appConfig.serverUrl && appConfig.hasNextServer()) {
          _logger.i('🔄 尝试故障转移到备用服务器');
          appConfig.switchToNextServer();
          final newServerUrl = appConfig.serverUrl;
          _logger
              .i('🔄 切换到备用服务器: $newServerUrl (${appConfig.currentServerName})');

          // 递归尝试连接新服务器
          return await connect(serverUrl: newServerUrl, token: token);
        }

        return false;
      }

      return true;
    } catch (error) {
      _logger.i('💥 连接异常: $error');
      _updateStatus(SocketConnectionStatus.error);
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _logger.i('🔌 断开Socket.IO连接');
    _socket?.disconnect();
    _updateStatus(SocketConnectionStatus.disconnected);
  }

  /// 💢💢💢 简化：移除自定义重连逻辑，Socket.io会自动处理
  // 移除 _attemptReconnect 和 _scheduleReconnect 方法

  /// 设置Socket监听器
  void _setupSocketListeners() {
    _socket?.onDisconnect((reason) {
      _logger.i('🔌 Socket.io断开连接: $reason');
      _updateStatus(SocketConnectionStatus.disconnected);
      // 移除手动重连触发，让Socket.io自动处理
    });

    _socket?.onError((error) {
      _logger.i('⚠️ Socket.io连接错误: $error');
      
      // 检查是否是Token过期错误
      if (_isTokenExpiredError(error)) {
        _logger.w('🔑 检测到Token过期，尝试自动刷新');
        _handleTokenExpired();
      } else {
        _updateStatus(SocketConnectionStatus.error);
      }
    });

    _socket?.onReconnect((_) {
      _logger.i('🔄 Socket.io重连成功');
      _updateStatus(SocketConnectionStatus.connected);
      // Socket.io自动重连成功，无需额外处理
    });

    _socket?.onReconnectAttempt((attempt) {
      _logger.i('🔄 Socket.io重连尝试 #$attempt');
      _updateStatus(SocketConnectionStatus.reconnecting);

      // 更新认证令牌
      if (_socket != null && _token != null) {
        _socket!.auth = {'token': _token};
      }
    });

    _socket?.onReconnectError((error) {
      _logger.i('❌ Socket.io重连错误: $error');
      
      // 检查是否是Token过期错误
      if (_isTokenExpiredError(error)) {
        _logger.w('🔑 重连时检测到Token过期，尝试自动刷新');
        _handleTokenExpired();
      } else {
        _updateStatus(SocketConnectionStatus.error);
      }
    });

    _socket?.onReconnectFailed((_) {
      _logger.i('💥 Socket.io重连失败，已达到最大重连次数');
      _updateStatus(SocketConnectionStatus.error);
    });

    // 添加ping/pong事件监听
    _socket?.on('ping', (_) {
      _logger.d('📡 Socket.io ping');
    });

    _socket?.on('pong', (_) {
      _logger.d('📡 Socket.io pong');
    });
  }

  /// 更新认证令牌
  void updateToken(String token) {
    _token = token;
    if (_socket != null) {
      _socket!.auth = {'token': token};
      _logger.i('🔑 更新Socket.io认证令牌');
    }
  }

  /// 检查错误是否为Token过期
  bool _isTokenExpiredError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('token_expired') || 
           errorString.contains('token expired') ||
           errorString.contains('unauthorized') ||
           errorString.contains('invalid token');
  }

  /// 处理Token过期 - 自动刷新Token并重连
  Future<void> _handleTokenExpired() async {
    try {
      _logger.i('🔄 开始Token过期处理流程');
      
      // 1. 使用EnhancedTokenManager刷新Token
      final tokenManager = EnhancedTokenManager.instance;
      final success = await tokenManager.manualRefreshToken();
      
      if (success) {
        // 2. 获取新的Token
        final newToken = await tokenManager.getSocketToken();
        
        if (newToken != null) {
          _logger.i('✅ Token刷新成功，更新Socket认证');
          
          // 3. 更新Token
          updateToken(newToken);
          
          // 4. 重新连接
          if (_serverUrl != null) {
            _logger.i('🔄 使用新Token重新连接');
            await connect(serverUrl: _serverUrl!, token: newToken);
          }
        } else {
          _logger.e('❌ 刷新后无法获取新Token');
          _updateStatus(SocketConnectionStatus.error);
        }
      } else {
        _logger.e('❌ Token刷新失败');
        _updateStatus(SocketConnectionStatus.error);
        // 这里可以触发需要重新登录的事件
        _notifyAuthenticationFailure();
      }
    } catch (error) {
      _logger.e('❌ Token过期处理异常', error: error);
      _updateStatus(SocketConnectionStatus.error);
      _notifyAuthenticationFailure();
    }
  }

  /// 通知认证失败 - 需要重新登录
  void _notifyAuthenticationFailure() {
    _logger.w('🚨 认证失败，可能需要重新登录');
    // 这里可以发送事件给上层处理重新登录逻辑
    // 例如：EventBus.instance.fire(AuthenticationFailedEvent());
  }

  /// 💢💢💢 新增：手动重连接口
  /// 提供给上层调用的公共重连方法
  Future<bool> reconnect() async {
    _logger.i('🔄 收到手动重连请求');

    try {
      // 如果已经连接，直接返回成功
      if (_isConnected) {
        _logger.i('当前已连接，无需重连');
        return true;
      }

      // 检查是否有连接信息
      if (_serverUrl == null || _token == null) {
        _logger.w('❌ 缺少连接信息，无法重连');
        return false;
      }

      _logger.i('🔄 开始执行手动重连', extra: {
        'serverUrl': _serverUrl,
        'currentStatus': _status.toString(),
        'socketConnected': _socket?.connected,
      });

      // 💢💢💢 实际执行重连：重新调用connect方法
      final success = await connect(
        serverUrl: _serverUrl!,
        token: _token!,
      );

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

  /// 释放资源
  void dispose() {
    _connectionStateController.close();
    _socket?.disconnect();
    _socket?.dispose();
    _logger.i('🧹 Socket.io服务已释放资源');
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
    // _logger.x('注册Protobuf事件监听: $eventName [${T.toString()}]');

    _socket?.on(eventName, (data) {
      try {
        // 创建并解析Protobuf消息
        final message = creator()..mergeFromBuffer(data);

        // _logger.d('接收到Protobuf事件: $eventName', extra: {
        //   'messageType': message.runtimeType,
        //   'dataType': data.runtimeType
        // });

        // 调用处理函数
        handler(message);
      } catch (e, stack) {
        _logger.e('解析Protobuf消息失败',
            error: e,
            stackTrace: stack,
            extra: {'eventName': eventName, 'dataType': data?.runtimeType});

        // 尝试输出原始数据的一部分以帮助诊断
        if (data != null) {
          try {
            String dataPreview = '';
            if (data is List) {
              dataPreview =
                  'List length: ${data.length}, first few bytes: ${data.take(20)}';
            } else if (data is String) {
              dataPreview =
                  'String length: ${data.length}, preview: ${data.substring(0, min(50, data.length))}';
            } else {
              dataPreview =
                  'ToString: ${data.toString().substring(0, min(100, data.toString().length))}';
            }
            _logger.e('原始数据预览', extra: {'dataPreview': dataPreview});
          } catch (previewError) {
            _logger.e('无法预览原始数据', error: previewError);
          }
        }
      }
    });
  }

  /// 发送Protobuf消息
  Future<bool> emitProto(String eventName, GeneratedMessage message) async {
    if (!_isConnected) {
      _logger.i('❌ Socket未连接，无法发送消息: $eventName');
      // Socket.io会自动重连，无需手动触发
      return false;
    }

    try {
      // _logger.i('📤 发送Socket消息: $eventName, 类型: ${message.runtimeType}');
      _socket?.emit(eventName, message.writeToBuffer());
      return true;
    } catch (e) {
      _logger.i('❌ 发送Socket消息失败: $e');
      // Socket.io会自动重连，无需手动触发
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
      'isReconnecting': _socket?.connected == false,
    };
    _logger.i('📊 连接信息: $info');
    return info;
  }

  /// 监听原始事件
  void on(String eventName, Function(dynamic) handler) {
    _logger.i('👂 注册原始事件监听: $eventName');

    // 先移除已存在的监听器
    _socket?.off(eventName);

    _socket?.on(eventName, (data) {
      try {
        _logger.i('📩 接收到原始事件: $eventName,dataType: ${data.runtimeType}');
        handler(data);
      } catch (e) {
        _logger.e('❌ 处理原始事件失败: $e',
            extra: {'eventName': eventName}, stackTrace: StackTrace.current);
      }
    });
  }

  /// 移除原始事件监听
  void off(String eventName, [Function(dynamic)? handler]) {
    // _logger.i('🔕 移除原始事件监听: $eventName');
    if (handler != null) {
      _socket?.off(eventName, handler);
    } else {
      _socket?.off(eventName);
    }
  }

  /// 发送原始事件
  void emit(String eventName, dynamic data) {
    if (!_isConnected) {
      _logger.i('❌ Socket未连接，无法发送原始事件: $eventName');
      return;
    }

    try {
      _logger.i('📤 发送原始事件: $eventName');
      _socket?.emit(eventName, data);
    } catch (e) {
      _logger.e('❌ 发送原始事件失败: $e',
          extra: {'eventName': eventName}, stackTrace: StackTrace.current);
    }
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
  void mergeFromBuffer(List<int> i,
      [ExtensionRegistry r = ExtensionRegistry.EMPTY]) {
    // 临时实现，实际上应该使用protoc生成的代码
    try {
      final jsonStr = String.fromCharCodes(i);
      final Map<String, dynamic> data = Map<String, dynamic>.from(
          jsonStr.startsWith('{')
              ? jsonDecode(jsonStr)
              : {'userId': '', 'status': '', 'timestamp': 0});
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
