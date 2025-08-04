import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/services/file_server_config_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'dart:convert';

/// 统一的媒体URL构建工具
/// 根据消息的content中的MediaMessage信息构建完整的文件URL
class MediaUrlBuilder {
  static final MediaUrlBuilder _instance = MediaUrlBuilder._internal();
  factory MediaUrlBuilder() => _instance;
  MediaUrlBuilder._internal();

  final LogService _logger = LogService.instance;
  final FileServerConfigService _configService = FileServerConfigService.instance;

  /// 为消息构建主要文件URL
  /// 返回null表示无法构建（缺少必要字段）
  Future<String?> buildMainFileUrl(Message message) async {
    final mediaInfo = _extractMediaInfo(message);
    if (mediaInfo == null) {
      _logger.w('消息不包含媒体信息', extra: {'messageId': message.messageId});
      return null;
    }

    if (!_hasRequiredFields(mediaInfo)) {
      _logger.w('媒体信息缺少必要字段', extra: {'messageId': message.messageId});
      return null;
    }

    final fsId = mediaInfo['fs_id'] as String;

    return await _buildFileUrl(
      fsId: fsId,
      type: _getFileTypeFromMimeType(mediaInfo['mime_type'] as String?),
      conversationId: message.conversationId,
      messageCreatedAt: message.createdAt,
      userId: message.senderId,
      fileName: mediaInfo['file_name'] as String,
    );
  }

  /// 为消息构建缩略图URL
  /// 使用相同的fileName，但类型为thumbnail，文件后缀改为.jpg
  Future<String?> buildThumbnailUrl(Message message) async {
    final mediaInfo = _extractMediaInfo(message);
    if (mediaInfo == null || !_hasRequiredFields(mediaInfo)) {
      return null;
    }

    final fsId = mediaInfo['fs_id'] as String;

    // 将原文件名的后缀改为.jpg（所有缩略图都是JPG格式）
    final thumbnailFileName = _convertToJpgFileName(mediaInfo['file_name'] as String);

    return await _buildFileUrl(
      fsId: fsId,
      type: 'thumbnail',
      conversationId: message.conversationId,
      messageCreatedAt: message.createdAt,
      userId: message.senderId,
      fileName: thumbnailFileName,
    );
  }

  /// 从消息内容中提取媒体信息
  Map<String, dynamic>? _extractMediaInfo(Message message) {
    try {
      _logger.i('🔍 开始提取媒体信息', extra: {
        'messageId': message.messageId,
        'messageType': message.messageType,
        'hasContent': message.content != null,
        'contentLength': message.content?.length ?? 0,
      });

      if (message.content == null || message.content!.isEmpty) {
        _logger.w('🔍 消息内容为空', extra: {'messageId': message.messageId});
        return null;
      }

      final contentJson = jsonDecode(message.content!);
      _logger.i('🔍 消息内容JSON解析成功', extra: {
        'messageId': message.messageId,
        'contentJson': contentJson,
        'hasMediaMessage': contentJson['media_message'] != null,
      });
      
      // 检查是否是媒体消息
      if (contentJson['media_message'] != null) {
        final mediaInfo = contentJson['media_message'] as Map<String, dynamic>;
        _logger.i('🔍 媒体信息提取成功', extra: {
          'messageId': message.messageId,
          'mediaInfo': mediaInfo,
          'fsId': mediaInfo['fs_id'],
          'fileName': mediaInfo['file_name'],
          'mediaUrl': mediaInfo['media_url'],
          'type': mediaInfo['type'],
        });
        return mediaInfo;
      }
      
      _logger.w('🔍 消息不包含media_message字段', extra: {
        'messageId': message.messageId,
        'availableKeys': contentJson.keys.toList(),
      });
      return null;
    } catch (e) {
      _logger.e('🔍 解析消息内容失败', error: e, extra: {
        'messageId': message.messageId,
        'content': message.content,
      });
      return null;
    }
  }

  /// 检查媒体信息是否包含必要字段
  bool _hasRequiredFields(Map<String, dynamic> mediaInfo) {
    final fsId = mediaInfo['fs_id'];
    final fileName = mediaInfo['file_name'];
    
    final hasValidFsId = fsId != null && fsId is String && fsId.isNotEmpty;
    final hasValidFileName = fileName != null && fileName is String && fileName.isNotEmpty;
    
    _logger.i('🔍 检查必要字段', extra: {
      'fsId': fsId,
      'fsId_type': fsId?.runtimeType.toString(),
      'fsId_isEmpty': fsId is String ? fsId.isEmpty : 'not_string',
      'hasValidFsId': hasValidFsId,
      'fileName': fileName,
      'fileName_type': fileName?.runtimeType.toString(),
      'fileName_isEmpty': fileName is String ? fileName.isEmpty : 'not_string',
      'hasValidFileName': hasValidFileName,
      'allFieldsValid': hasValidFsId && hasValidFileName,
    });
    
    return hasValidFsId && hasValidFileName;
  }

  /// 根据MIME类型推断文件类型
  String _getFileTypeFromMimeType(String? mimeType) {
    if (mimeType == null) return 'file';
    
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'voice';
    
    return 'file';
  }

  /// 核心的文件URL构建方法
  Future<String?> _buildFileUrl({
    required String fsId,
    required String type,
    required String conversationId,
    required DateTime messageCreatedAt,
    required String userId,
    required String fileName,
  }) async {
    try {
      // 根据fsID获取对应的文件服务器URL
      final fileServerUrl = await _configService.getFileServerUrl(fsId);
      if (fileServerUrl == null || fileServerUrl.isEmpty) {
        _logger.w('无法获取文件服务器URL', extra: {'fsId': fsId});
        return null;
      }

      // 从消息创建时间提取日期
      final date = _extractDateFromDateTime(messageCreatedAt);

      // 构建完整URL：{fileServerUrl}/{type}/{conversationId}/{date}/{userId}/{fileName}
      final url = '$fileServerUrl/$type/$conversationId/$date/$userId/$fileName';
      
      _logger.d('构建媒体URL成功', extra: {
        'fsId': fsId,
        'type': type,
        'url': url,
        'messageCreatedAt': messageCreatedAt.toIso8601String(),
        'extractedDate': date,
      });

      return url;
    } catch (error) {
      _logger.e('构建媒体URL失败', error: error, extra: {
        'fsId': fsId,
        'type': type,
        'conversationId': conversationId,
        'fileName': fileName,
        'messageCreatedAt': messageCreatedAt.toIso8601String(),
      });
      return null;
    }
  }

  /// 从DateTime对象提取日期字符串（推荐使用）
  /// 使用消息的创建时间，确保URL中的日期与消息实际创建时间一致
  String _extractDateFromDateTime(DateTime dateTime) {
    // 使用消息的创建时间，转换为UTC确保一致性
    final utcDate = dateTime.toUtc();
    return '${utcDate.year}-${utcDate.month.toString().padLeft(2, '0')}-${utcDate.day.toString().padLeft(2, '0')}';
  }



  /// 检查消息是否有构建URL所需的完整字段
  static bool canBuildUrl(Message message) {
    try {
      if (message.content == null || message.content!.isEmpty) {
        return false;
      }

      final contentJson = jsonDecode(message.content!);
      final mediaInfo = contentJson['media_message'] as Map<String, dynamic>?;
      
      return mediaInfo != null &&
             mediaInfo['fs_id'] != null &&
             mediaInfo['fs_id'] is String &&
             (mediaInfo['fs_id'] as String).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 将文件名的后缀改为.jpg（所有缩略图都是JPG格式）
  String _convertToJpgFileName(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) {
      // 如果没有扩展名，直接添加.jpg
      return '$fileName.jpg';
    }
    
    // 将扩展名替换为.jpg
    final nameWithoutExtension = fileName.substring(0, lastDotIndex);
    return '$nameWithoutExtension.jpg';
  }

  /// 批量预构建消息的URL（用于列表优化）
  Future<Map<String, String?>> batchBuildUrls(List<Message> messages) async {
    final Map<String, String?> urlCache = {};
    
    for (final message in messages) {
      if (canBuildUrl(message)) {
        final mainUrl = await buildMainFileUrl(message);
        if (mainUrl != null) {
          urlCache['${message.messageId}_main'] = mainUrl;
        }
        
        final thumbnailUrl = await buildThumbnailUrl(message);
        if (thumbnailUrl != null) {
          urlCache['${message.messageId}_thumbnail'] = thumbnailUrl;
        }
      }
    }
    
    return urlCache;
  }
}