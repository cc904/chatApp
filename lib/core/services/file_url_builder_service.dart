import 'package:cc/core/constants/file_server_config.dart';
import 'package:cc/core/services/log_service.dart';

/// 文件URL构建服务
/// 根据新的文件服务器逻辑构建文件URL
/// 路径格式：文件服务器/类型type/会话ID/时间UTC/用户ID/文件名[nanoID或UUID]
class FileUrlBuilderService {
  static final FileUrlBuilderService _instance = FileUrlBuilderService._internal();
  factory FileUrlBuilderService() => _instance;
  FileUrlBuilderService._internal();

  final _logger = LogService.instance;
  final _fileServerConfig = FileServerConfig();

  // 移除未使用的_fileServerBaseUrl方法，直接使用_fileServerConfig

  /// 构建文件URL
  /// [type] 文件类型：images, voice, videos, files, avatar
  /// [conversationId] 会话ID
  /// [timestamp] UTC时间戳
  /// [userId] 用户ID
  /// [fileName] 服务器生成的文件名（nanoID或UUID）
  String buildFileUrl({
    required String type,
    required String conversationId,
    required String timestamp,
    required String userId,
    required String fileName,
  }) {
    final url = _fileServerConfig.buildFileUrl(
      type: type,
      conversationId: conversationId,
      timestamp: timestamp,
      userId: userId,
      fileName: fileName,
    );
    _logger.d('构建文件URL', extra: {
      'type': type,
      'conversationId': conversationId,
      'timestamp': timestamp,
      'userId': userId,
      'fileName': fileName,
      'url': url,
    });
    return url;
  }

  /// 构建缩略图URL
  /// [conversationId] 会话ID
  /// [timestamp] UTC时间戳
  /// [userId] 用户ID
  /// [thumbnailFileName] 缩略图文件名
  String buildThumbnailUrl({
    required String conversationId,
    required String timestamp,
    required String userId,
    required String thumbnailFileName,
  }) {
    final url = _fileServerConfig.buildThumbnailUrl(
      conversationId: conversationId,
      timestamp: timestamp,
      userId: userId,
      thumbnailFileName: thumbnailFileName,
    );
    _logger.d('构建缩略图URL', extra: {
      'conversationId': conversationId,
      'timestamp': timestamp,
      'userId': userId,
      'thumbnailFileName': thumbnailFileName,
      'url': url,
    });
    return url;
  }

  /// 从消息数据构建文件URL
  /// [messageData] 消息数据，包含文件相关信息
  String? buildFileUrlFromMessageData(Map<String, dynamic> messageData) {
    try {
      final fileName = messageData['fileName'] as String?;
      final conversationId = messageData['conversationId'] as String?;
      final timestamp = messageData['timestamp'] as String?;
      final userId = messageData['userId'] as String?;
      final messageType = messageData['type'] as String?;

      if (fileName == null || conversationId == null || timestamp == null || userId == null) {
        _logger.w('构建文件URL失败：缺少必要参数', extra: messageData);
        return null;
      }

      // 根据消息类型确定文件类型
      String fileType;
      switch (messageType?.toLowerCase()) {
        case 'image':
          fileType = 'images';
          break;
        case 'voice':
          fileType = 'voice';
          break;
        case 'video':
          fileType = 'videos';
          break;
        case 'file':
          fileType = 'files';
          break;
        default:
          fileType = 'files';
      }

      return buildFileUrl(
        type: fileType,
        conversationId: conversationId,
        timestamp: timestamp,
        userId: userId,
        fileName: fileName,
      );
    } catch (error) {
      _logger.e('从消息数据构建文件URL失败', error: error, extra: messageData);
      return null;
    }
  }

  /// 从消息数据构建缩略图URL
  String? buildThumbnailUrlFromMessageData(Map<String, dynamic> messageData) {
    try {
      final thumbnailFileName = messageData['thumbnailFileName'] as String?;
      final conversationId = messageData['conversationId'] as String?;
      final timestamp = messageData['timestamp'] as String?;
      final userId = messageData['userId'] as String?;

      if (thumbnailFileName == null || conversationId == null || timestamp == null || userId == null) {
        return null;
      }

      return buildThumbnailUrl(
        conversationId: conversationId,
        timestamp: timestamp,
        userId: userId,
        thumbnailFileName: thumbnailFileName,
      );
    } catch (error) {
      _logger.e('从消息数据构建缩略图URL失败', error: error, extra: messageData);
      return null;
    }
  }

  /// 解析文件URL获取文件信息
  /// 从URL中提取文件路径组件
  Map<String, String>? parseFileUrl(String url) {
    try {
      final result = _fileServerConfig.extractFileInfoFromUrl(url);
      if (result != null) {
        _logger.d('成功解析文件URL', extra: {'url': url, 'result': result});
        return result;
      }
      
      _logger.w('无法解析文件URL：不匹配预期格式', extra: {'url': url});
      return null;
    } catch (error) {
      _logger.e('解析文件URL失败', error: error, extra: {'url': url});
      return null;
    }
  }

  /// 检查URL是否为新格式的文件URL
  bool isNewFormatFileUrl(String url) {
    return _fileServerConfig.isValidFileServerUrl(url);
  }

  /// 获取文件下载URL（用于无认证下载）
  /// 根据文件服务器规范，下载不需要认证
  String getDownloadUrl(String fileUrl) {
    // 新格式的文件URL可以直接用于下载
    return fileUrl;
  }
}