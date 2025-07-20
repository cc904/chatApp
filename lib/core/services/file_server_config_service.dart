import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'dart:convert';

/// 文件服务器配置管理服务
/// 
/// 处理登录成功后服务器返回的serverConfig信息，包括：
/// - ss: 聊天服务器映射
/// - defs: 默认文件服务器ID
/// - fsUrl: 文件服务器映射
/// - limits: 文件大小限制
class FileServerConfigService {
  static final FileServerConfigService _instance = FileServerConfigService._internal();
  static FileServerConfigService get instance => _instance;
  
  final LogService _logger = LogService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();
  
  // 配置缓存
  Map<String, String>? _chatServers;
  Map<String, String>? _loginServers;
  String? _defaultFileServerId;
  Map<String, String>? _fileServers;
  Map<String, int>? _fileLimits;
  
  FileServerConfigService._internal();
  
  /// 保存服务器配置
  Future<void> saveServerConfig(Map<String, dynamic> serverConfig) async {
    try {
      _logger.i('💾 保存服务器配置', extra: {
        'hasChatServers': serverConfig.containsKey('ss'),
        'hasLoginServers': serverConfig.containsKey('ls'),
        'hasDefaultFileServer': serverConfig.containsKey('defs'),
        'hasFileServers': serverConfig.containsKey('fsUrl'),
        'hasLimits': serverConfig.containsKey('limits'),
      });

      // 解析聊天服务器映射 (Socket.io)
      if (serverConfig['ss'] != null) {
        _chatServers = Map<String, String>.from(serverConfig['ss']);
        await _secureStorage.write('chat_servers', jsonEncode(_chatServers));
        _logger.d('保存聊天服务器配置', extra: {'count': _chatServers?.length});
      }

      // 解析登录服务器映射
      if (serverConfig['ls'] != null) {
        _loginServers = Map<String, String>.from(serverConfig['ls']);
        await _secureStorage.write('login_servers', jsonEncode(_loginServers));
        _logger.d('保存登录服务器配置', extra: {'count': _loginServers?.length});
      }

      // 解析默认文件服务器ID（用于文件上传）
      if (serverConfig['defs'] != null) {
        _defaultFileServerId = serverConfig['defs'].toString();
        await _secureStorage.write('default_file_server_id', _defaultFileServerId!);
        _logger.d('保存默认文件服务器ID（上传用）', extra: {'defaultId': _defaultFileServerId});
      }

      // 解析文件服务器映射
      if (serverConfig['fsUrl'] != null) {
        _fileServers = Map<String, String>.from(serverConfig['fsUrl']);
        await _secureStorage.write('file_servers', jsonEncode(_fileServers));
        _logger.d('保存文件服务器配置', extra: {'count': _fileServers?.length});
      }

      // 解析文件大小限制
      if (serverConfig['limits'] != null) {
        final limits = serverConfig['limits'];
        _fileLimits = {
          'imageMaxSize': limits['imageMaxSize']?.toInt() ?? 10 * 1024 * 1024, // 默认10MB
          'videoMaxSize': limits['videoMaxSize']?.toInt() ?? 100 * 1024 * 1024, // 默认100MB
          'audioMaxSize': limits['audioMaxSize']?.toInt() ?? 50 * 1024 * 1024, // 默认50MB
          'fileMaxSize': limits['fileMaxSize']?.toInt() ?? 50 * 1024 * 1024, // 默认50MB
        };
        await _secureStorage.write('file_limits', jsonEncode(_fileLimits));
        _logger.d('保存文件大小限制', extra: _fileLimits);
      }

      _logger.i('✅ 服务器配置保存完成');
    } catch (error) {
      _logger.e('保存服务器配置失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取聊天服务器映射 (Socket.io)
  Future<Map<String, String>?> getChatServers() async {
    if (_chatServers != null) return _chatServers;
    
    try {
      final stored = await _secureStorage.read('chat_servers');
      if (stored != null) {
        _chatServers = Map<String, String>.from(jsonDecode(stored));
        return _chatServers;
      }
    } catch (error) {
      _logger.e('获取聊天服务器配置失败', error: error);
    }
    return null;
  }

  /// 获取登录服务器映射
  Future<Map<String, String>?> getLoginServers() async {
    if (_loginServers != null) return _loginServers;
    
    try {
      final stored = await _secureStorage.read('login_servers');
      if (stored != null) {
        _loginServers = Map<String, String>.from(jsonDecode(stored));
        return _loginServers;
      }
    } catch (error) {
      _logger.e('获取登录服务器配置失败', error: error);
    }
    return null;
  }

  /// 获取默认文件服务器ID（用于文件上传）
  Future<String?> getDefaultFileServerId() async {
    if (_defaultFileServerId != null) return _defaultFileServerId;
    
    try {
      _defaultFileServerId = await _secureStorage.read('default_file_server_id');
      return _defaultFileServerId;
    } catch (error) {
      _logger.e('获取默认文件服务器ID失败', error: error);
    }
    return null;
  }

  /// 获取文件服务器映射
  Future<Map<String, String>?> getFileServers() async {
    if (_fileServers != null) return _fileServers;
    
    try {
      final stored = await _secureStorage.read('file_servers');
      if (stored != null) {
        _fileServers = Map<String, String>.from(jsonDecode(stored));
        return _fileServers;
      }
    } catch (error) {
      _logger.e('获取文件服务器配置失败', error: error);
    }
    return null;
  }

  /// 获取文件大小限制
  Future<Map<String, int>?> getFileLimits() async {
    if (_fileLimits != null) return _fileLimits;
    
    try {
      final stored = await _secureStorage.read('file_limits');
      if (stored != null) {
        _fileLimits = Map<String, int>.from(jsonDecode(stored));
        return _fileLimits;
      }
    } catch (error) {
      _logger.e('获取文件大小限制失败', error: error);
    }
    return null;
  }

  /// 根据服务器ID获取文件服务器URL
  Future<String?> getFileServerUrl(String serverId) async {
    final fileServers = await getFileServers();
    return fileServers?[serverId];
  }

  /// 获取默认文件服务器URL
  Future<String?> getDefaultFileServerUrl() async {
    final defaultId = await getDefaultFileServerId();
    if (defaultId != null) {
      return await getFileServerUrl(defaultId);
    }
    return null;
  }

  /// 构建文件URL
  Future<String?> buildFileUrl(String serverId, String filePath) async {
    final baseUrl = await getFileServerUrl(serverId);
    if (baseUrl != null) {
      return '$baseUrl/$filePath';
    }
    return null;
  }

  /// 构建默认文件URL
  Future<String?> buildDefaultFileUrl(String filePath) async {
    final defaultUrl = await getDefaultFileServerUrl();
    if (defaultUrl != null) {
      return '$defaultUrl/$filePath';
    }
    return null;
  }

  /// 获取文件类型的大小限制
  Future<int?> getFileSizeLimit(String fileType) async {
    final limits = await getFileLimits();
    if (limits != null) {
      switch (fileType.toLowerCase()) {
        case 'image':
          return limits['imageMaxSize'];
        case 'video':
          return limits['videoMaxSize'];
        case 'audio':
        case 'voice':
          return limits['audioMaxSize'];
        case 'file':
        default:
          return limits['fileMaxSize'];
      }
    }
    return null;
  }

  /// 检查文件大小是否超过限制
  Future<bool> isFileSizeAllowed(String fileType, int fileSize) async {
    final limit = await getFileSizeLimit(fileType);
    if (limit != null) {
      return fileSize <= limit;
    }
    return true; // 如果没有配置限制，默认允许
  }

  /// 清除所有配置
  Future<void> clearConfig() async {
    try {
      _chatServers = null;
      _loginServers = null;
      _defaultFileServerId = null;
      _fileServers = null;
      _fileLimits = null;
      
      await _secureStorage.delete('chat_servers');
      await _secureStorage.delete('login_servers');
      await _secureStorage.delete('default_file_server_id');
      await _secureStorage.delete('file_servers');
      await _secureStorage.delete('file_limits');
      
      _logger.i('✅ 服务器配置已清除');
    } catch (error) {
      _logger.e('清除服务器配置失败', error: error);
    }
  }

  /// 获取配置摘要（用于调试）
  Future<Map<String, dynamic>> getConfigSummary() async {
    return {
      'chatServers': await getChatServers(),
      'loginServers': await getLoginServers(),
      'defaultFileServerId': await getDefaultFileServerId(),
      'fileServers': await getFileServers(),
      'fileLimits': await getFileLimits(),
    };
  }
}