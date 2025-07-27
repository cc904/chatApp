/// 应用全局配置
///
/// 这个类负责管理应用的全局配置选项。
/// 使用单例模式确保全应用范围内配置一致。
///
/// 📍 重要变更：
/// - 移除了硬编码的服务器地址
/// - 完全依赖 ServerSelectionService 和加密域名配置
/// - 保持向后兼容的接口
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/backup_domain_service.dart';

class AppConfig {
  // 缓存的服务器列表（从ServerSelectionService获取）
  List<String> _availableServers = [];
  
  // 当前选择的服务器URL
  String? _currentServerUrl;

  // 日志器
  final _logger = LogService.instance;

  // 存储键名
  static const String _selectedServerKey = 'cc_selected_server_url';

  // 单例模式
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// 从持久化存储加载选择的服务器URL
  Future<void> _loadSelectedServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_selectedServerKey);
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _currentServerUrl = savedUrl;
        _logger.i('🔗 从存储加载选择的服务器', extra: {
          'serverUrl': _currentServerUrl,
        });
      }
    } catch (e) {
      _logger.e('加载选择的服务器失败', error: e);
    }
  }

  /// 保存选择的服务器URL到持久化存储
  Future<void> _saveSelectedServer(String serverUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedServerKey, serverUrl);
      _currentServerUrl = serverUrl;
      _logger.i('💾 保存选择的服务器到存储', extra: {
        'serverUrl': serverUrl,
      });
    } catch (e) {
      _logger.e('保存选择的服务器失败', error: e);
    }
  }

  /// 获取当前服务器URL
  String get serverUrl {
    return _currentServerUrl ?? _availableServers.firstOrNull ?? '';
  }

  /// 获取当前文件服务器URL（根据主服务器URL推导）
  String get fileServerUrl {
    final mainUrl = serverUrl;
    if (mainUrl.isEmpty) {
      return '';
    }
    try {
      // 简单的端口映射逻辑：主服务器端口+1
      final uri = Uri.parse(mainUrl);
      final newPort = (uri.port == 3000) ? 3001 : (uri.port + 1);
      return '${uri.scheme}://${uri.host}:$newPort';
    } catch (e) {
      _logger.e('解析服务器URL失败', error: e, extra: {'mainUrl': mainUrl});
      return '';
    }
  }

  /// 获取当前服务器索引（为了向后兼容）
  int get currentServerIndex {
    if (_currentServerUrl == null || _availableServers.isEmpty) return 0;
    final index = _availableServers.indexOf(_currentServerUrl!);
    return index >= 0 ? index : 0;
  }

  /// 获取所有服务器地址
  List<String> get allServerUrls => List.unmodifiable(_availableServers);

  /// 获取所有文件服务器地址（根据主服务器推导）
  List<String> get allFileServerUrls {
    return _availableServers.map((serverUrl) {
      final uri = Uri.parse(serverUrl);
      final newPort = (uri.port == 3000) ? 3001 : (uri.port + 1);
      return '${uri.scheme}://${uri.host}:$newPort';
    }).toList();
  }

  /// 设置服务器URL
  Future<void> setServerUrl(String url) async {
    if (_availableServers.contains(url)) {
      await _saveSelectedServer(url);
      _logger.i('🔄 切换到指定服务器', extra: {'serverUrl': url});
    } else {
      _logger.w('指定的服务器URL不在可用列表中', extra: {
        'requestedUrl': url,
        'availableServers': _availableServers,
      });
    }
  }

  /// 设置服务器索引（为了向后兼容）
  Future<void> setServerIndex(int index) async {
    if (index >= 0 && index < _availableServers.length) {
      final serverUrl = _availableServers[index];
      await _saveSelectedServer(serverUrl);
      _logger.i('🔄 通过索引切换服务器', extra: {
        'index': index,
        'serverUrl': serverUrl,
      });
    } else {
      _logger.w('服务器索引超出范围', extra: {
        'requestedIndex': index,
        'availableCount': _availableServers.length,
      });
    }
  }

  /// 切换到下一个可用服务器
  /// 返回: 是否成功切换到新服务器
  Future<bool> switchToNextServer() async {
    if (_availableServers.isEmpty) return false;
    
    final currentIndex = currentServerIndex;
    final nextIndex = (currentIndex + 1) % _availableServers.length;
    
    await setServerIndex(nextIndex);
    return nextIndex != currentIndex;
  }

  /// 重置到第一个服务器
  Future<void> resetToFirstServer() async {
    if (_availableServers.isNotEmpty) {
      await setServerIndex(0);
    }
  }

  /// 检查是否还有备用服务器可以尝试
  bool hasNextServer() {
    return _availableServers.length > 1;
  }

  /// 获取当前服务器的显示名称
  String get currentServerName {
    final url = serverUrl;
    if (url.isEmpty) return '未知服务器';
    
    final serverInfo = _getServerEnvironmentInfo(url);
    return serverInfo['displayName'] ?? '未知服务器';
  }

  /// 获取所有服务器的显示信息
  List<Map<String, String>> get serverDisplayInfo {
    return _availableServers.asMap().entries.map((entry) {
      final index = entry.key;
      final url = entry.value;
      final serverInfo = _getServerEnvironmentInfo(url);
      
      return {
        'name': serverInfo['displayName'] ?? '服务器 ${index + 1}',
        'url': url,
        'fileServerUrl': allFileServerUrls[index],
        'environment': serverInfo['environment'] ?? 'unknown',
        'environmentColor': serverInfo['environmentColor'] ?? 'grey',
      };
    }).toList();
  }

  /// 根据服务器URL获取环境信息
  Map<String, String> _getServerEnvironmentInfo(String url) {
    if (url.isEmpty) {
      return {
        'displayName': '未知服务器',
        'environment': 'unknown',
        'environmentColor': 'grey',
      };
    }

    try {
      final uri = Uri.parse(url);
      
      // 判断是否为开发环境服务器
      final isDevelopment = _isDevelopmentServer(uri);
      
      if (isDevelopment) {
        // 开发环境服务器
        if (uri.host.contains('localhost') || uri.host.contains('127.0.0.1')) {
          return {
            'displayName': '本地开发服务器',
            'environment': 'development',
            'environmentColor': 'blue',
          };
        } else if (uri.host.startsWith('192.168.') || uri.host.startsWith('10.') || uri.host.startsWith('172.')) {
          return {
            'displayName': '局域网开发服务器',
            'environment': 'development', 
            'environmentColor': 'blue',
          };
        } else {
          return {
            'displayName': '开发服务器',
            'environment': 'development',
            'environmentColor': 'blue',
          };
        }
      } else {
        // 生产环境服务器
        final isHttps = uri.scheme == 'https';
        return {
          'displayName': isHttps ? '生产服务器 (安全)' : '生产服务器',
          'environment': 'production',
          'environmentColor': isHttps ? 'green' : 'orange',
        };
      }
    } catch (e) {
      _logger.e('解析服务器URL失败', error: e, extra: {'url': url});
      return {
        'displayName': '服务器配置错误',
        'environment': 'error',
        'environmentColor': 'red',
      };
    }
  }

  /// 判断是否为开发环境服务器
  bool _isDevelopmentServer(Uri uri) {
    // 根据常见的开发环境特征判断
    return uri.host.contains('localhost') ||
           uri.host.contains('127.0.0.1') ||
           uri.host.startsWith('192.168.') ||
           uri.host.startsWith('10.') ||
           uri.host.startsWith('172.') ||
           uri.port == 3000 ||
           uri.port == 7003 ||
           uri.scheme == 'http'; // HTTP通常用于开发环境
  }

  /// 初始化配置（确保配置已加载）
  Future<void> init() async {
    try {
      // 1. 加载用户选择的服务器
      await _loadSelectedServer();
      
      // 2. 从ServerSelectionService获取可用服务器列表
      await _refreshAvailableServers();
      
      _logger.i('📋 AppConfig初始化完成', extra: {
        'availableServers': _availableServers.length,
        'currentServer': _currentServerUrl,
        'finalServerUrl': serverUrl,
      });
    } catch (error) {
      _logger.e('AppConfig初始化失败', error: error);
      // 如果没有可用服务器，保持空列表
      if (_availableServers.isEmpty) {
        _logger.w('没有可用的服务器配置');
      }
    }
  }

  /// 刷新可用服务器列表
  Future<void> _refreshAvailableServers() async {
    try {
      // 直接从BackupDomainService获取所有登录服务器
      final backupService = BackupDomainService.instance;
      final allServers = await backupService.getCombinedLoginServers();
      
      if (allServers.isNotEmpty) {
        _availableServers = allServers;
        _logger.i('成功加载服务器列表', extra: {
          'serverCount': allServers.length,
          'servers': allServers,
        });
      } else {
        _logger.w('BackupDomainService未返回可用服务器');
        _availableServers = [];
      }
    } catch (error) {
      _logger.e('刷新可用服务器列表失败', error: error);
      // 保持空列表，不使用硬编码服务器
      if (_availableServers.isEmpty) {
        _logger.w('服务器列表刷新失败，无可用服务器');
      }
    }
  }
}
