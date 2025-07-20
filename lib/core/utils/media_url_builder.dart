import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/file_server_config_service.dart';
import 'package:cc/core/services/log_service.dart';

/// 统一的媒体URL构建工具
/// 根据消息的fsID和文件信息构建完整的文件URL
class MediaUrlBuilder {
  static final MediaUrlBuilder _instance = MediaUrlBuilder._internal();
  factory MediaUrlBuilder() => _instance;
  MediaUrlBuilder._internal();

  final LogService _logger = LogService.instance;
  final FileServerConfigService _configService = FileServerConfigService.instance;

  /// 为消息构建主要文件URL
  /// 返回null表示无法构建（缺少必要字段）
  Future<String?> buildMainFileUrl(Message message) async {
    if (!message.hasNewFileServerFields) {
      _logger.w('消息缺少新文件服务器字段', extra: {'messageId': message.messageId});
      return null;
    }

    return await _buildFileUrl(
      fsId: message.fsId!,
      type: message.fileType,
      conversationId: message.conversationId,
      timestamp: message.createdAt.millisecondsSinceEpoch.toString(),
      userId: message.senderId,
      fileName: message.fileName!,
    );
  }

  /// 为消息构建缩略图URL
  /// 使用相同的fileName，但类型为thumbnail，文件后缀改为.jpg
  Future<String?> buildThumbnailUrl(Message message) async {
    if (!message.hasNewFileServerFields) {
      return null;
    }

    // 将原文件名的后缀改为.jpg（所有缩略图都是JPG格式）
    final thumbnailFileName = _convertToJpgFileName(message.fileName!);

    return await _buildFileUrl(
      fsId: message.fsId!,
      type: 'thumbnail',
      conversationId: message.conversationId,
      timestamp: message.createdAt.millisecondsSinceEpoch.toString(),
      userId: message.senderId,
      fileName: thumbnailFileName,
    );
  }

  /// 核心的文件URL构建方法
  Future<String?> _buildFileUrl({
    required String fsId,
    required String type,
    required String conversationId,
    required String timestamp,
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

      // 从时间戳提取日期
      final date = _extractDateFromTimestamp(timestamp);

      // 构建完整URL：{fileServerUrl}/{type}/{conversationId}/{date}/{userId}/{fileName}
      final url = '$fileServerUrl/$type/$conversationId/$date/$userId/$fileName';
      
      _logger.d('构建媒体URL成功', extra: {
        'fsId': fsId,
        'type': type,
        'url': url,
      });

      return url;
    } catch (error) {
      _logger.e('构建媒体URL失败', error: error, extra: {
        'fsId': fsId,
        'type': type,
        'conversationId': conversationId,
        'fileName': fileName,
      });
      return null;
    }
  }

  /// 从时间戳提取日期字符串
  String _extractDateFromTimestamp(String timestamp) {
    try {
      final parsed = int.tryParse(timestamp);
      if (parsed != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(parsed).toUtc();
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      _logger.w('时间戳解析失败，使用当前日期', extra: {'timestamp': timestamp});
    }
    
    // 备用：使用当前UTC日期
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 检查消息是否有构建URL所需的完整字段
  static bool canBuildUrl(Message message) {
    return message.hasNewFileServerFields &&
           message.fsId != null &&
           message.fsId!.isNotEmpty;
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