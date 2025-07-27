import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';

// 条件导入：根据平台导入不同的网络诊断实现
import 'network_diagnostic_stub.dart'
    if (dart.library.io) 'network_diagnostic_io.dart'
    if (dart.library.html) 'network_diagnostic_web.dart';

/// 网络诊断工具
class NetworkDiagnostic {
  static final _logger = LogService.instance;
  
  /// 执行完整的网络诊断
  static Future<NetworkDiagnosticResult> runFullDiagnostic() async {
    _logger.i('🔍 开始网络诊断...');
    
    final result = NetworkDiagnosticResult();
    
    try {
      // 1. 检查网络连接类型
      result.connectivityResult = await _checkConnectivity();
      
      // 2. 检查网络权限
      result.hasNetworkPermission = await _checkNetworkPermission();
      
      // 3. DNS解析测试
      result.dnsResult = await _testDNSResolution();
      
      // 4. 服务器连通性测试
      result.serverConnectivityResult = await _testServerConnectivity();
      
      // 5. HTTP请求测试
      result.httpTestResult = await _testHTTPRequest();
      
      // 6. 系统网络配置
      result.systemNetworkInfo = await getSystemNetworkInfo();
      
      _logger.i('🔍 网络诊断完成', extra: result.toMap());
      
    } catch (e, stack) {
      _logger.e('网络诊断异常', error: e, stackTrace: stack);
      result.hasError = true;
      result.errorMessage = e.toString();
    }
    
    return result;
  }
  
  /// 检查网络连接类型
  static Future<List<ConnectivityResult>> _checkConnectivity() async {
    try {
      final connectivity = Connectivity();
      return await connectivity.checkConnectivity();
    } catch (e) {
      _logger.e('检查网络连接类型失败', error: e);
      return [ConnectivityResult.none];
    }
  }
  
  /// 检查网络权限
  static Future<bool> _checkNetworkPermission() async {
    try {
      // 尝试创建一个简单的HTTP请求来测试网络权限
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      
      await dio.get('https://www.google.com');
      return true;
    } catch (e) {
      _logger.w('网络权限检查失败', extra: {'error': e.toString()});
      return false;
    }
  }
  
  /// DNS解析测试
  static Future<DNSTestResult> _testDNSResolution() async {
    try {
      final serverUrl = AppConfig().serverUrl;
      final uri = Uri.parse(serverUrl);
      final host = uri.host;
      
      _logger.d('测试DNS解析: $host');
      
      final stopwatch = Stopwatch()..start();
      final addresses = await InternetAddress.lookup(host);
      stopwatch.stop();
      
      return DNSTestResult(
        success: true,
        host: host,
        addresses: addresses.map((addr) => addr.address).toList(),
        resolveTime: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      _logger.e('DNS解析失败', error: e);
      return DNSTestResult(
        success: false,
        host: 'unknown',
        addresses: [],
        resolveTime: 0,
        error: e.toString(),
      );
    }
  }
  
  /// 服务器连通性测试
  static Future<ServerConnectivityResult> _testServerConnectivity() async {
    try {
      final serverUrl = AppConfig().serverUrl;
      final uri = Uri.parse(serverUrl);
      
      _logger.d('测试服务器连通性: $serverUrl');
      
      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(
        uri.host, 
        uri.port,
        timeout: const Duration(seconds: 5),
      );
      stopwatch.stop();
      
      await socket.close();
      
      return ServerConnectivityResult(
        success: true,
        host: uri.host,
        port: uri.port,
        connectTime: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      _logger.e('服务器连通性测试失败', error: e);
      final uri = Uri.parse(AppConfig().serverUrl);
      return ServerConnectivityResult(
        success: false,
        host: uri.host,
        port: uri.port,
        connectTime: 0,
        error: e.toString(),
      );
    }
  }
  
  /// HTTP请求测试
  static Future<HTTPTestResult> _testHTTPRequest() async {
    try {
      final serverUrl = AppConfig().serverUrl;
      
      _logger.d('测试HTTP请求: $serverUrl');
      
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      final stopwatch = Stopwatch()..start();
      final response = await dio.head(serverUrl);
      stopwatch.stop();
      
      return HTTPTestResult(
        success: true,
        url: serverUrl,
        statusCode: response.statusCode ?? 0,
        responseTime: stopwatch.elapsedMilliseconds,
        headers: response.headers.map,
      );
    } catch (e) {
      _logger.e('HTTP请求测试失败', error: e);
      return HTTPTestResult(
        success: false,
        url: AppConfig().serverUrl,
        statusCode: 0,
        responseTime: 0,
        error: e.toString(),
      );
    }
  }
  
}

/// 网络诊断结果
class NetworkDiagnosticResult {
  List<ConnectivityResult> connectivityResult = [];
  bool hasNetworkPermission = false;
  DNSTestResult? dnsResult;
  ServerConnectivityResult? serverConnectivityResult;
  HTTPTestResult? httpTestResult;
  Map<String, dynamic> systemNetworkInfo = {};
  
  bool hasError = false;
  String? errorMessage;
  
  /// 转换为Map格式
  Map<String, dynamic> toMap() {
    return {
      'connectivity': connectivityResult.map((r) => r.name).toList(),
      'hasNetworkPermission': hasNetworkPermission,
      'dns': dnsResult?.toMap(),
      'serverConnectivity': serverConnectivityResult?.toMap(),
      'httpTest': httpTestResult?.toMap(),
      'systemInfo': systemNetworkInfo,
      'hasError': hasError,
      'errorMessage': errorMessage,
    };
  }
  
  /// 生成诊断报告
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== 网络诊断报告 ===');
    
    // 网络连接类型
    buffer.writeln('网络连接: ${connectivityResult.map((r) => r.name).join(', ')}');
    
    // 网络权限
    buffer.writeln('网络权限: ${hasNetworkPermission ? '正常' : '异常'}');
    
    // DNS解析
    if (dnsResult != null) {
      buffer.writeln('DNS解析: ${dnsResult!.success ? '成功' : '失败'}');
      if (dnsResult!.success) {
        buffer.writeln('  - 解析时间: ${dnsResult!.resolveTime}ms');
        buffer.writeln('  - IP地址: ${dnsResult!.addresses.join(', ')}');
      } else {
        buffer.writeln('  - 错误: ${dnsResult!.error}');
      }
    }
    
    // 服务器连通性
    if (serverConnectivityResult != null) {
      buffer.writeln('服务器连通性: ${serverConnectivityResult!.success ? '成功' : '失败'}');
      if (serverConnectivityResult!.success) {
        buffer.writeln('  - 连接时间: ${serverConnectivityResult!.connectTime}ms');
      } else {
        buffer.writeln('  - 错误: ${serverConnectivityResult!.error}');
      }
    }
    
    // HTTP测试
    if (httpTestResult != null) {
      buffer.writeln('HTTP测试: ${httpTestResult!.success ? '成功' : '失败'}');
      if (httpTestResult!.success) {
        buffer.writeln('  - 响应时间: ${httpTestResult!.responseTime}ms');
        buffer.writeln('  - 状态码: ${httpTestResult!.statusCode}');
      } else {
        buffer.writeln('  - 错误: ${httpTestResult!.error}');
      }
    }
    
    if (hasError) {
      buffer.writeln('诊断过程中出现错误: $errorMessage');
    }
    
    return buffer.toString();
  }
}

/// DNS测试结果
class DNSTestResult {
  final bool success;
  final String host;
  final List<String> addresses;
  final int resolveTime;
  final String? error;
  
  DNSTestResult({
    required this.success,
    required this.host,
    required this.addresses,
    required this.resolveTime,
    this.error,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'host': host,
      'addresses': addresses,
      'resolveTime': resolveTime,
      'error': error,
    };
  }
}

/// 服务器连通性测试结果
class ServerConnectivityResult {
  final bool success;
  final String host;
  final int port;
  final int connectTime;
  final String? error;
  
  ServerConnectivityResult({
    required this.success,
    required this.host,
    required this.port,
    required this.connectTime,
    this.error,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'host': host,
      'port': port,
      'connectTime': connectTime,
      'error': error,
    };
  }
}

/// HTTP测试结果
class HTTPTestResult {
  final bool success;
  final String url;
  final int statusCode;
  final int responseTime;
  final Map<String, List<String>>? headers;
  final String? error;
  
  HTTPTestResult({
    required this.success,
    required this.url,
    required this.statusCode,
    required this.responseTime,
    this.headers,
    this.error,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'url': url,
      'statusCode': statusCode,
      'responseTime': responseTime,
      'headers': headers,
      'error': error,
    };
  }
}