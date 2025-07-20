import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/file_server_config_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/backup_domain_service.dart';

/// 服务器选择和测速服务
/// 负责选择最优的登录服务器和聊天服务器
class ServerSelectionService {
  static final ServerSelectionService _instance = ServerSelectionService._internal();
  static ServerSelectionService get instance => _instance;
  
  final LogService _logger = LogService.instance;
  final FileServerConfigService _configService = FileServerConfigService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();
  final BackupDomainService _backupDomainService = BackupDomainService.instance;
  
  // 缓存最优服务器
  String? _preferredLoginServer;
  String? _preferredChatServer;
  
  ServerSelectionService._internal();
  
  /// 获取最优登录服务器
  /// 应用启动时调用，会进行测速选择
  /// 优先使用安全存储中的服务器，如果失效则使用后备域名
  Future<String?> getBestLoginServer() async {
    try {
      // 1. 首先从缓存获取
      if (_preferredLoginServer != null) {
        _logger.d('使用缓存的最优登录服务器: $_preferredLoginServer');
        return _preferredLoginServer;
      }
      
      // 2. 获取综合的登录服务器列表（安全存储 + 后备域名）
      final allLoginServers = await _getCombinedLoginServers();
      if (allLoginServers.isEmpty) {
        _logger.e('没有任何可用的登录服务器');
        return null;
      }
      
      _logger.i('开始选择最优登录服务器', extra: {
        'availableServers': allLoginServers,
        'serverCount': allLoginServers.length,
      });
      
      // 3. 将列表转换为Map格式用于测速
      final serverMap = <String, String>{};
      for (int i = 0; i < allLoginServers.length; i++) {
        serverMap['server_$i'] = allLoginServers[i];
      }
      
      // 4. 进行测速选择
      final bestServer = await _selectFastestServer(serverMap);
      
      if (bestServer != null) {
        _preferredLoginServer = bestServer;
        // 保存到安全存储供下次快速启动
        await _secureStorage.write('preferred_login_server', bestServer);
        _logger.i('选择最优登录服务器完成', extra: {
          'selectedServer': bestServer,
        });
      }
      
      return bestServer;
    } catch (error) {
      _logger.e('选择最优登录服务器失败', error: error);
      return null;
    }
  }
  
  /// 获取最优聊天服务器
  /// 登录成功后优先使用返回的聊天服务器配置
  Future<String?> getBestChatServer() async {
    try {
      // 1. 首先从缓存获取
      if (_preferredChatServer != null) {
        _logger.d('使用缓存的最优聊天服务器: $_preferredChatServer');
        return _preferredChatServer;
      }
      
      // 2. 从安全存储获取聊天服务器列表
      final chatServers = await _configService.getChatServers();
      if (chatServers == null || chatServers.isEmpty) {
        _logger.w('没有可用的聊天服务器配置');
        return null;
      }
      
      _logger.i('开始选择最优聊天服务器', extra: {
        'availableServers': chatServers.keys.toList(),
        'serverCount': chatServers.length,
      });
      
      // 3. 进行测速选择
      final bestServer = await _selectFastestServer(chatServers);
      
      if (bestServer != null) {
        _preferredChatServer = bestServer;
        // 保存到安全存储
        await _secureStorage.write('preferred_chat_server', bestServer);
        _logger.i('选择最优聊天服务器完成', extra: {
          'selectedServer': bestServer,
        });
      }
      
      return bestServer;
    } catch (error) {
      _logger.e('选择最优聊天服务器失败', error: error);
      return null;
    }
  }
  
  /// 更新首选聊天服务器（登录成功后调用）
  /// 优先使用服务器返回的聊天服务器配置
  Future<void> updatePreferredChatServerFromLogin(Map<String, String> newChatServers) async {
    try {
      _logger.i('登录成功，更新聊天服务器配置', extra: {
        'newServers': newChatServers.keys.toList(),
        'serverCount': newChatServers.length,
      });
      
      // 更新配置服务中的聊天服务器列表
      final serverConfig = {
        'ss': newChatServers,
      };
      await _configService.saveServerConfig(serverConfig);
      
      // 重新选择最优聊天服务器
      _preferredChatServer = null; // 清除缓存
      await getBestChatServer();
      
    } catch (error) {
      _logger.e('更新首选聊天服务器失败', error: error);
    }
  }
  
  /// 测速选择最快的服务器
  Future<String?> _selectFastestServer(Map<String, String> servers) async {
    if (servers.isEmpty) return null;
    if (servers.length == 1) return servers.values.first;
    
    final results = <String, int>{}; // 服务器URL -> 响应时间(ms)
    
    // 并发测试所有服务器
    final futures = servers.entries.map((entry) async {
      final serverId = entry.key;
      final serverUrl = entry.value;
      
      try {
        final responseTime = await _pingServer(serverUrl);
        if (responseTime != null) {
          results[serverUrl] = responseTime;
          _logger.d('服务器测速结果', extra: {
            'serverId': serverId,
            'serverUrl': serverUrl,
            'responseTime': '${responseTime}ms',
          });
        }
      } catch (error) {
        _logger.w('服务器测速失败', extra: {
          'serverId': serverId,
          'serverUrl': serverUrl,
          'error': error.toString(),
        });
      }
    });
    
    // 等待所有测速完成，最多等待8秒（因为每个请求最多3秒）
    await Future.wait(futures).timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _logger.w('服务器测速超时，使用已有结果');
        return [];
      },
    );
    
    // 选择响应最快的服务器
    if (results.isNotEmpty) {
      final sortedResults = results.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      final fastestServer = sortedResults.first.key;
      final fastestTime = sortedResults.first.value;
      
      _logger.i('选择最快服务器', extra: {
        'fastestServer': fastestServer,
        'responseTime': '${fastestTime}ms',
        'allResults': results,
      });
      
      return fastestServer;
    }
    
    // 如果测速都失败了，返回第一个服务器作为备选
    final fallbackServer = servers.values.first;
    _logger.w('所有服务器测速失败，使用备选服务器: $fallbackServer');
    return fallbackServer;
  }
  
  /// 通过 /health 端点测试服务器响应时间
  Future<int?> _pingServer(String serverUrl) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // 创建专用的Dio实例，避免干扰其他请求
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        sendTimeout: const Duration(seconds: 3),
        validateStatus: (status) => status != null && status < 500, // 接受所有非5xx状态码
      ));
      
      // 发送健康检查请求
      final response = await dio.get('$serverUrl/health');
      
      stopwatch.stop();
      
      // 检查响应状态
      if (response.statusCode != null && response.statusCode! < 400) {
        final responseTime = stopwatch.elapsedMilliseconds;
        _logger.d('服务器健康检查成功', extra: {
          'serverUrl': serverUrl,
          'statusCode': response.statusCode,
          'responseTime': '${responseTime}ms',
          'responseData': response.data?.toString(),
        });
        return responseTime;
      } else {
        _logger.w('服务器健康检查失败', extra: {
          'serverUrl': serverUrl,
          'statusCode': response.statusCode,
        });
        return null;
      }
    } catch (error) {
      _logger.d('服务器健康检查异常', extra: {
        'serverUrl': serverUrl,
        'error': error.toString(),
      });
      return null;
    }
  }
  
  /// 获取综合的登录服务器列表
  /// 优先使用安全存储中的服务器，当安全存储无效时使用后备域名
  Future<List<String>> _getCombinedLoginServers() async {
    try {
      // 1. 首先尝试从安全存储获取登录服务器
      final loginServers = await _configService.getLoginServers();
      final storedServers = <String>[];
      
      if (loginServers != null && loginServers.isNotEmpty) {
        storedServers.addAll(loginServers.values);
        _logger.i('从安全存储获取到登录服务器', extra: {
          'count': storedServers.length,
          'servers': storedServers,
        });
      }
      
      // 2. 获取后备域名服务器列表
      final backupServers = await _backupDomainService.getCombinedLoginServers();
      
      // 3. 如果安全存储为空或失效，使用后备域名
      if (storedServers.isEmpty) {
        _logger.w('安全存储中无登录服务器，使用后备域名列表');
        return backupServers;
      }
      
      // 4. 如果安全存储有服务器，将后备域名作为补充
      final allServers = <String>[];
      allServers.addAll(storedServers);
      
      // 添加不重复的后备服务器
      for (final backupServer in backupServers) {
        if (!allServers.contains(backupServer)) {
          allServers.add(backupServer);
        }
      }
      
      _logger.i('获取综合登录服务器列表完成', extra: {
        'storedCount': storedServers.length,
        'backupCount': backupServers.length,
        'totalCount': allServers.length,
        'finalList': allServers,
      });
      
      return allServers;
      
    } catch (error) {
      _logger.e('获取综合登录服务器列表失败', error: error);
      
      // 发生错误时，尝试获取紧急后备域名
      try {
        final emergencyServers = await _backupDomainService.getBackupDomains();
        _logger.w('使用紧急后备域名', extra: {
          'count': emergencyServers.length,
        });
        return emergencyServers;
      } catch (backupError) {
        _logger.e('获取紧急后备域名也失败', error: backupError);
        return [];
      }
    }
  }

  /// 清除缓存的服务器选择
  Future<void> clearCache() async {
    _preferredLoginServer = null;
    _preferredChatServer = null;
    await _secureStorage.delete('preferred_login_server');
    await _secureStorage.delete('preferred_chat_server');
    _logger.i('已清除服务器选择缓存');
  }
  
  /// 获取当前首选服务器状态
  Map<String, String?> getPreferredServers() {
    return {
      'loginServer': _preferredLoginServer,
      'chatServer': _preferredChatServer,
    };
  }
}