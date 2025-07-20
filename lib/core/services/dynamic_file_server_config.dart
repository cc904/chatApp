import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/file_server_config_service.dart';

/// 动态文件服务器配置管理器
/// 负责管理从服务器获取的文件服务器配置信息
class DynamicFileServerConfig {
  static final DynamicFileServerConfig _instance = DynamicFileServerConfig._internal();
  factory DynamicFileServerConfig() => _instance;
  DynamicFileServerConfig._internal();

  final _logger = LogService.instance;
  
  // 存储键名
  static const String _configKey = 'file_server_config';
  
  // 当前配置信息
  FileServerInfo? _currentConfig;
  
  /// 获取当前文件服务器配置
  FileServerInfo? get currentConfig => _currentConfig;
  
  /// 初始化配置（从本地存储加载）
  Future<void> initialize() async {
    try {
      // 优先从新的FileServerConfigService获取配置
      final configService = FileServerConfigService.instance;
      final chatServers = await configService.getChatServers();
      final loginServers = await configService.getLoginServers();
      final defaultId = await configService.getDefaultFileServerId();
      final fileServers = await configService.getFileServers();
      
      if (chatServers != null && defaultId != null && fileServers != null) {
        final limits = await configService.getFileLimits();
        _currentConfig = FileServerInfo(
          ss: chatServers,
          ls: loginServers ?? chatServers, // 如果没有登录服务器配置，使用聊天服务器作为备选
          defs: defaultId,
          fsUrl: fileServers,
          limits: limits != null 
            ? FileSizeLimits(
                imageMaxSize: limits['imageMaxSize'] ?? 10 * 1024 * 1024,
                videoMaxSize: limits['videoMaxSize'] ?? 100 * 1024 * 1024,
                audioMaxSize: limits['audioMaxSize'] ?? 50 * 1024 * 1024,
                fileMaxSize: limits['fileMaxSize'] ?? 50 * 1024 * 1024,
              )
            : FileSizeLimits.defaultLimits(),
        );
        _logger.i('✅ 从FileServerConfigService加载文件服务器配置', extra: {
          'ss': _currentConfig?.ss,
          'ls': _currentConfig?.ls,
          'defs': _currentConfig?.defs,
          'fsUrl': _currentConfig?.fsUrl,
        });
        return;
      }
      
      // 如果新服务没有配置，回退到旧的SharedPreferences方式
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);
      
      if (configJson != null) {
        final configData = jsonDecode(configJson);
        _currentConfig = FileServerInfo.fromJson(configData);
        _logger.i('✅ 从SharedPreferences加载文件服务器配置', extra: {
          'ss': _currentConfig?.ss,
          'defs': _currentConfig?.defs,
          'fsUrl': _currentConfig?.fsUrl,
        });
      } else {
        _logger.i('⚠️ 本地存储中没有文件服务器配置，使用默认配置');
        _setDefaultConfig();
      }
    } catch (error) {
      _logger.e('❌ 初始化文件服务器配置失败', error: error);
      _setDefaultConfig();
    }
  }

  /// 设置默认配置（作为后备方案）
  void _setDefaultConfig() {
    _currentConfig = FileServerInfo(
      ss: {'1': 'http://13.158.26.10:7031'},
      ls: {'1': 'http://13.158.26.10:7031'},
      defs: '1',
      fsUrl: {'1': 'http://13.158.26.10:7031'},
      limits: FileSizeLimits.defaultLimits(),
    );
  }

  /// 更新文件服务器配置（从登录响应中获取）
  Future<void> updateConfig(FileServerInfo config) async {
    try {
      _currentConfig = config;
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, jsonEncode(config.toJson()));
      
      _logger.i('✅ 更新文件服务器配置成功', extra: {
        'ss': config.ss,
        'ls': config.ls,
        'defs': config.defs,
        'fsUrl': config.fsUrl,
        'limits': {
          'imageMaxSize': config.limits.imageMaxSize,
          'videoMaxSize': config.limits.videoMaxSize,
          'audioMaxSize': config.limits.audioMaxSize,
          'fileMaxSize': config.limits.fileMaxSize,
        },
      });
    } catch (error) {
      _logger.e('❌ 更新文件服务器配置失败', error: error);
    }
  }

  /// 从登录响应数据中解析配置
  FileServerInfo? parseConfigFromLoginResponse(Map<String, dynamic> loginResponse) {
    try {
      final serverConfig = loginResponse['serverConfig'] as Map<String, dynamic>?;
      
      if (serverConfig != null) {
        // 直接使用 serverConfig 数据，包含 ss、ls、defs、fsUrl、limits
        return FileServerInfo.fromJson(serverConfig);
      }
      
      _logger.w('⚠️ 登录响应中没有找到 serverConfig 字段');
      return null;
    } catch (error) {
      _logger.e('❌ 解析登录响应中的文件服务器配置失败', error: error);
      return null;
    }
  }

  /// 清除配置
  Future<void> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
      _currentConfig = null;
      _logger.i('✅ 清除文件服务器配置成功');
    } catch (error) {
      _logger.e('❌ 清除文件服务器配置失败', error: error);
    }
  }

  /// 验证配置是否有效
  bool isConfigValid() {
    return _currentConfig != null && 
           _currentConfig!.ss.isNotEmpty &&
           _currentConfig!.fsUrl.isNotEmpty &&
           _currentConfig!.defs.isNotEmpty;
  }

  /// 获取配置摘要信息
  Map<String, dynamic> getConfigSummary() {
    if (_currentConfig == null) {
      return {'status': 'no_config'};
    }
    
    return {
      'status': 'configured',
      'ss': _currentConfig!.ss,
      'ls': _currentConfig!.ls,
      'defs': _currentConfig!.defs,
      'fsUrl': _currentConfig!.fsUrl,
      'limits': {
        'imageMaxSize': _currentConfig!.limits.imageMaxSize,
        'videoMaxSize': _currentConfig!.limits.videoMaxSize,
        'audioMaxSize': _currentConfig!.limits.audioMaxSize,
        'fileMaxSize': _currentConfig!.limits.fileMaxSize,
      },
      'configuredAt': _currentConfig!.configuredAt?.toIso8601String(),
    };
  }
}

/// 服务器配置信息
class FileServerInfo {
  final Map<String, String> ss; // Socket.io 聊天服务器地址映射
  final Map<String, String> ls; // 登录服务器地址映射
  final String defs; // 默认文件服务器ID（仅用于文件上传，与登录/聊天服务器无关）
  final Map<String, String> fsUrl; // 文件服务器URL映射
  final FileSizeLimits limits;
  final DateTime? configuredAt;

  FileServerInfo({
    required this.ss,
    required this.ls,
    required this.defs,
    required this.fsUrl,
    required this.limits,
    this.configuredAt,
  });

  /// 获取默认文件服务器URL（用于文件上传）
  String get defaultFsUrl => fsUrl[defs] ?? '';

  /// 获取第一个可用的Socket.io聊天服务器URL
  String get defaultSsUrl => ss.values.isNotEmpty ? ss.values.first : '';

  /// 获取第一个可用的登录服务器URL
  String get defaultLsUrl => ls.values.isNotEmpty ? ls.values.first : '';

  /// 根据ID获取文件服务器URL
  String getFsUrl(String fsId) => fsUrl[fsId] ?? defaultFsUrl;

  /// 根据ID获取Socket.io聊天服务器URL
  String getSsUrl(String fsId) => ss[fsId] ?? defaultSsUrl;

  /// 根据ID获取登录服务器URL
  String getLsUrl(String lsId) => ls[lsId] ?? defaultLsUrl;

  factory FileServerInfo.fromJson(Map<String, dynamic> json) {
    final ssMap = <String, String>{};
    final lsMap = <String, String>{};
    final fsUrlMap = <String, String>{};
    
    // 解析ss字段（Socket.io 聊天服务器）
    if (json['ss'] != null) {
      final ssData = json['ss'] as Map<String, dynamic>;
      ssData.forEach((key, value) {
        ssMap[key] = value.toString();
      });
    }
    
    // 解析ls字段（登录服务器）
    if (json['ls'] != null) {
      final lsData = json['ls'] as Map<String, dynamic>;
      lsData.forEach((key, value) {
        lsMap[key] = value.toString();
      });
    }
    
    // 解析fsUrl字段（文件服务器）
    if (json['fsUrl'] != null) {
      final fsUrlData = json['fsUrl'] as Map<String, dynamic>;
      fsUrlData.forEach((key, value) {
        fsUrlMap[key] = value.toString();
      });
    }
    
    return FileServerInfo(
      ss: ssMap,
      ls: lsMap,
      defs: json['defs']?.toString() ?? '1',
      fsUrl: fsUrlMap,
      limits: json['limits'] != null 
        ? FileSizeLimits.fromJson(json['limits'])
        : FileSizeLimits.defaultLimits(),
      configuredAt: json['configuredAt'] != null 
        ? DateTime.parse(json['configuredAt'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ss': ss,
      'ls': ls,
      'defs': defs,
      'fsUrl': fsUrl,
      'limits': limits.toJson(),
      'configuredAt': (configuredAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// 构建文件URL（指定文件服务器ID）
  /// 格式：fsUrl + 消息类型 + 会话ID + 日期 + 用户ID + 文件名
  String buildFileUrl({
    required String fsId,
    required String type,
    required String conversationId,
    required String date, // 日期格式，从created_at提取
    required String userId,
    required String fileName,
  }) {
    final fsBaseUrl = getFsUrl(fsId);
    return '$fsBaseUrl/$type/$conversationId/$date/$userId/$fileName';
  }

  /// 使用默认文件服务器构建文件URL（用于文件上传）
  /// 格式：defaultFsUrl + 消息类型 + 会话ID + 日期 + 用户ID + 文件名
  String buildDefaultFileUrl({
    required String type,
    required String conversationId,
    required String date, // 日期格式，从created_at提取
    required String userId,
    required String fileName,
  }) {
    return buildFileUrl(
      fsId: defs, // 使用默认文件服务器ID
      type: type,
      conversationId: conversationId,
      date: date,
      userId: userId,
      fileName: fileName,
    );
  }

  /// 从created_at时间戳提取日期字符串
  /// 格式：YYYY-MM-DD
  String extractDateFromTimestamp(int createdAt) {
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 检查特定类型文件大小是否符合限制
  bool isFileSizeValidForType(int fileSize, String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
      case 'images':
        return fileSize <= limits.imageMaxSize;
      case 'video':
      case 'videos':
        return fileSize <= limits.videoMaxSize;
      case 'audio':
      case 'voice':
        // 语音文件已通过时长限制，无需大小限制
        return true;
      case 'file':
      case 'files':
        return fileSize <= limits.fileMaxSize;
      default:
        return false; // 未知类型不允许
    }
  }
}

/// 文件大小限制配置
class FileSizeLimits {
  final int imageMaxSize;
  final int videoMaxSize;
  final int audioMaxSize;
  final int fileMaxSize;

  FileSizeLimits({
    required this.imageMaxSize,
    required this.videoMaxSize,
    required this.audioMaxSize,
    required this.fileMaxSize,
  });

  factory FileSizeLimits.fromJson(Map<String, dynamic> json) {
    return FileSizeLimits(
      imageMaxSize: json['imageMaxSize'] ?? 10 * 1024 * 1024, // 10MB
      videoMaxSize: json['videoMaxSize'] ?? 500 * 1024 * 1024, // 500MB
      audioMaxSize: json['audioMaxSize'] ?? 50 * 1024 * 1024, // 50MB
      fileMaxSize: json['fileMaxSize'] ?? 100 * 1024 * 1024, // 100MB
    );
  }

  /// 创建默认限制配置
  factory FileSizeLimits.defaultLimits() {
    return FileSizeLimits(
      imageMaxSize: 10 * 1024 * 1024, // 10MB
      videoMaxSize: 500 * 1024 * 1024, // 500MB
      audioMaxSize: 50 * 1024 * 1024, // 50MB
      fileMaxSize: 100 * 1024 * 1024, // 100MB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageMaxSize': imageMaxSize,
      'videoMaxSize': videoMaxSize,
      'audioMaxSize': audioMaxSize,
      'fileMaxSize': fileMaxSize,
    };
  }
}