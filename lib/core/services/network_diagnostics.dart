import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cc/core/services/log_service.dart';

/// 网络诊断工具类
/// 用于诊断Socket.IO连接问题
class NetworkDiagnostics {
  final LogService _logger = LogService.instance;

  /// 测试服务器是否可达
  Future<bool> isServerReachable(String serverUrl) async {
    _logger.i('开始测试服务器可达性', extra: {'url': serverUrl});

    try {
      // 提取主机和端口
      final uri = Uri.parse(serverUrl);
      final host = uri.host;
      final port = uri.port > 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80);

      _logger.i('尝试TCP连接', extra: {'host': host, 'port': port});

      // 尝试TCP连接
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      socket.destroy();

      _logger.i('TCP连接成功', extra: {'host': host, 'port': port});
      return true;
    } catch (e) {
      _logger.e('TCP连接失败', error: e);
      return false;
    }
  }

  /// 测试Socket.IO握手
  Future<Map<String, dynamic>> testSocketIOHandshake(String serverUrl) async {
    _logger.i('开始测试Socket.IO握手', extra: {'url': serverUrl});

    try {
      // 确保URL不以/结尾
      final baseUrl = serverUrl.endsWith('/') ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;

      // 构建Socket.IO握手URL
      final handshakeUrl = '$baseUrl/socket.io/?EIO=4&transport=polling';

      _logger.i('发送Socket.IO握手请求', extra: {'url': handshakeUrl});

      // 发送HTTP请求测试握手
      final response = await http.get(Uri.parse(handshakeUrl)).timeout(const Duration(seconds: 10));

      _logger.i('收到Socket.IO握手响应', extra: {
        'statusCode': response.statusCode,
        'body': response.body,
        'headers': response.headers,
      });

      if (response.statusCode == 200) {
        // 解析sid
        String? sid;
        if (response.body.startsWith('0{')) {
          final jsonStart = response.body.indexOf('{');
          final jsonBody = response.body.substring(jsonStart);
          sid = RegExp(r'"sid":"([^"]+)"').firstMatch(jsonBody)?.group(1);
        }

        return {
          'success': true,
          'statusCode': response.statusCode,
          'body': response.body,
          'sid': sid,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'body': response.body,
          'error': '握手失败: HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      _logger.e('Socket.IO握手请求失败', error: e);
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 运行完整诊断
  Future<Map<String, dynamic>> runDiagnostics(String serverUrl) async {
    final results = <String, dynamic>{};

    // 1. 测试DNS解析
    try {
      final uri = Uri.parse(serverUrl);
      final host = uri.host;
      _logger.i('测试DNS解析', extra: {'host': host});

      final addresses = await InternetAddress.lookup(host);
      results['dns'] = {
        'success': addresses.isNotEmpty,
        'addresses': addresses.map((a) => a.address).toList(),
      };
      _logger.i('DNS解析成功', extra: results['dns']);
    } catch (e) {
      results['dns'] = {
        'success': false,
        'error': e.toString(),
      };
      _logger.e('DNS解析失败', error: e);
    }

    // 2. 测试TCP连接
    results['tcp'] = {
      'success': await isServerReachable(serverUrl),
    };

    // 3. 测试HTTP请求
    try {
      final uri = Uri.parse(serverUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      results['http'] = {
        'success': response.statusCode < 400,
        'statusCode': response.statusCode,
        'contentLength': response.contentLength,
      };
      _logger.i('HTTP请求成功', extra: results['http']);
    } catch (e) {
      results['http'] = {
        'success': false,
        'error': e.toString(),
      };
      _logger.e('HTTP请求失败', error: e);
    }

    // 4. 测试Socket.IO握手
    results['socketio'] = await testSocketIOHandshake(serverUrl);

    // 5. 测试操作系统和应用权限
    results['system'] = {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'localHostname': Platform.localHostname,
    };

    _logger.i('诊断完成', extra: {'serverUrl': serverUrl, 'results': results});
    return results;
  }
}
