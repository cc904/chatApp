import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/dynamic_file_server_config.dart';

/// 文件服务器配置
/// 管理独立文件服务器的配置信息
/// 优先使用动态配置，如果没有则使用静态配置作为后备
class FileServerConfig {
  static final FileServerConfig _instance = FileServerConfig._internal();
  factory FileServerConfig() => _instance;
  FileServerConfig._internal();

  final AppConfig _appConfig = AppConfig();
  final DynamicFileServerConfig _dynamicConfig = DynamicFileServerConfig();

  /// 获取默认文件服务器URL
  String get defaultFsUrl {
    // 优先使用动态配置
    if (_dynamicConfig.currentConfig != null) {
      return _dynamicConfig.currentConfig!.defaultFsUrl;
    }
    // 后备使用静态配置
    return _appConfig.fileServerUrl;
  }

  /// 获取上传API的基础URL（使用默认服务器端点）
  String get uploadApiBaseUrl {
    // 优先使用动态配置
    if (_dynamicConfig.currentConfig != null) {
      return '${_dynamicConfig.currentConfig!.defaultSsUrl}/api/v1/upload';
    }
    // 后备使用静态配置
    return '${_appConfig.fileServerUrl}/api/v1/upload';
  }

  /// 根据fsId获取文件服务器URL
  String getFsUrl(String fsId) {
    if (_dynamicConfig.currentConfig != null) {
      return _dynamicConfig.currentConfig!.getFsUrl(fsId);
    }
    // 后备使用静态配置
    return _appConfig.fileServerUrl;
  }

  /// 构建完整的文件URL
  /// [type] 文件类型：image, voice, video, file (对应新的文件服务器类型)
  /// [conversationId] 会话ID
  /// [timestamp] UTC时间戳字符串或消息创建时间戳
  /// [userId] 用户ID
  /// [fileName] 服务器生成的文件名
  String buildFileUrl({
    required String type,
    required String conversationId,
    required String timestamp,
    required String userId,
    required String fileName,
  }) {
    // 优先使用动态配置的构建方法（使用默认文件服务器）
    if (_dynamicConfig.currentConfig != null) {
      final date = _extractDateFromTimestamp(timestamp);
      return _dynamicConfig.currentConfig!.buildDefaultFileUrl(
        type: type,
        conversationId: conversationId,
        date: date,
        userId: userId,
        fileName: fileName,
      );
    }
    // 后备使用静态配置
    final date = _extractDateFromTimestamp(timestamp);
    return '$defaultFsUrl/$type/$conversationId/$date/$userId/$fileName';
  }

  /// 构建缩略图URL
  /// [conversationId] 会话ID
  /// [timestamp] UTC时间戳字符串或消息创建时间戳
  /// [userId] 用户ID
  /// [thumbnailFileName] 服务器生成的缩略图文件名
  String buildThumbnailUrl({
    required String conversationId,
    required String timestamp,
    required String userId,
    required String thumbnailFileName,
  }) {
    // 优先使用动态配置的构建方法（使用默认文件服务器）
    if (_dynamicConfig.currentConfig != null) {
      final date = _extractDateFromTimestamp(timestamp);
      return _dynamicConfig.currentConfig!.buildDefaultFileUrl(
        type: 'thumbnail',
        conversationId: conversationId,
        date: date,
        userId: userId,
        fileName: thumbnailFileName,
      );
    }
    // 后备使用静态配置
    final date = _extractDateFromTimestamp(timestamp);
    return '$defaultFsUrl/thumbnail/$conversationId/$date/$userId/$thumbnailFileName';
  }

  /// 从时间戳提取日期
  /// 支持字符串和整数时间戳
  String _extractDateFromTimestamp(dynamic timestamp) {
    DateTime date;
    if (timestamp is String) {
      // 尝试解析字符串时间戳
      final parsed = int.tryParse(timestamp);
      if (parsed != null) {
        date = DateTime.fromMillisecondsSinceEpoch(parsed);
      } else {
        // 如果不能解析为整数，使用当前UTC时间
        date = DateTime.now().toUtc();
      }
    } else if (timestamp is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      date = DateTime.now().toUtc();
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }


  /// 文件服务器配置信息
  Map<String, dynamic> get configInfo => {
    'defaultFsUrl': defaultFsUrl,
    'uploadApiBaseUrl': uploadApiBaseUrl,
    'dynamicConfig': _dynamicConfig.currentConfig?.toJson(),
    'features': [
      '支持无认证上传下载',
      '统一的文件路径结构',
      '多服务器故障转移',
      '基于fsID的文件服务器选择',
      '基于日期的文件组织',
    ],
    'supportedTypes': ['images', 'voice', 'videos', 'files', 'avatar'],
    'pathStructure': '{fsUrl}/{type}/{conversationId}/{utcDate}/{userId}/{fileName}',
    'thumbnailPath': '{fsUrl}/thumbnail/{conversationId}/{utcDate}/{userId}/{thumbnailFileName}',
  };

  /// 验证文件URL是否为有效的文件服务器URL
  bool isValidFileServerUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // 检查是否匹配任何配置的文件服务器URL
      if (_dynamicConfig.currentConfig != null) {
        final fsUrls = _dynamicConfig.currentConfig!.fsUrl.values;
        return fsUrls.any((fsUrl) => uri.host == Uri.parse(fsUrl).host);
      }
      return uri.host == Uri.parse(defaultFsUrl).host;
    } catch (e) {
      return false;
    }
  }

  /// 从URL中提取文件信息
  Map<String, String>? extractFileInfoFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // 新的文件URL格式：type/conversationId/date/userId/fileName
      if (pathSegments.length >= 5) {
        return {
          'type': pathSegments[0],
          'conversationId': pathSegments[1],
          'date': pathSegments[2],
          'userId': pathSegments[3],
          'fileName': pathSegments[4],
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}