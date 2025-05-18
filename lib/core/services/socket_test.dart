import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/network_diagnostics.dart';

/// Socket.IO测试工具
/// 用于测试Socket.IO连接，不依赖于我们现有的实现
class SocketTest {
  final LogService _logger = LogService.instance;
  final NetworkDiagnostics _diagnostics = NetworkDiagnostics();

  /// 运行测试
  Future<Map<String, dynamic>> runTest(String serverUrl, String token) async {
    _logger.i('开始Socket.IO连接测试', extra: {'url': serverUrl});
    
    // 先运行诊断
    final diagnosticResults = await _diagnostics.runDiagnostics(serverUrl);
    _logger.i('网络诊断结果', extra: diagnosticResults);
    
    // 如果无法连接到服务器，直接返回
    if (!(diagnosticResults['tcp']['success'] ?? false)) {
      _logger.e('无法连接到服务器，测试终止');
      return {
        'success': false,
        'diagnostics': diagnosticResults,
        'error': '无法连接到服务器',
      };
    }
    
    // 测试Socket.IO连接
    final socketResults = await _testSocketIO(serverUrl, token);
    
    return {
      'success': socketResults['connected'] ?? false,
      'diagnostics': diagnosticResults,
      'socket': socketResults,
    };
  }
  
  /// 测试Socket.IO连接
  Future<Map<String, dynamic>> _testSocketIO(String serverUrl, String token) async {
    final results = <String, dynamic>{};
    final completer = Completer<Map<String, dynamic>>();
    
    try {
      _logger.i('创建Socket.IO连接', extra: {'url': serverUrl});
      
      // 设置超时
      final timeout = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          _logger.e('Socket.IO连接超时');
          completer.complete({
            'connected': false,
            'error': '连接超时',
          });
        }
      });
      
      // 创建Socket.IO实例
      final socket = io.io(serverUrl, {
        'transports': ['websocket', 'polling'], 
        'autoConnect': true,
        'auth': {'token': token},
        'reconnection': false,  // 测试时禁用自动重连
        'timeout': 10000,
        'forceNew': true,
      });
      
      // 设置事件监听器
      socket.onConnect((_) {
        _logger.i('Socket.IO连接成功', extra: {'id': socket.id});
        results['connected'] = true;
        results['id'] = socket.id;
        
        // 1秒后断开连接
        Timer(const Duration(seconds: 1), () {
          socket.disconnect();
          if (!completer.isCompleted) {
            timeout.cancel();
            completer.complete(results);
          }
        });
      });
      
      socket.onConnectError((error) {
        _logger.e('Socket.IO连接错误', error: error);
        results['connected'] = false;
        results['error'] = error.toString();
        
        if (!completer.isCompleted) {
          timeout.cancel();
          completer.complete(results);
        }
      });
      
      socket.onError((error) {
        _logger.e('Socket.IO错误', error: error);
        results['error'] = error.toString();
      });
      
      socket.onDisconnect((reason) {
        _logger.i('Socket.IO断开连接', extra: {'reason': reason});
        results['disconnectReason'] = reason;
        
        if (!completer.isCompleted) {
          timeout.cancel();
          completer.complete(results);
        }
      });
      
      // 等待结果
      final testResults = await completer.future;
      
      // 清理
      socket.disconnect();
      socket.dispose();
      
      return testResults;
    } catch (e) {
      _logger.e('Socket.IO测试异常', error: e);
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }
} 