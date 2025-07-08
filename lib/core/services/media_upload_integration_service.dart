import 'dart:io';
import 'dart:async';
import 'package:mime/mime.dart';
import 'package:cc/core/services/upload_api_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 媒体上传集成服务
/// 将Upload API与现有消息系统集成的高级服务
class MediaUploadIntegrationService {
  final _logger = LogService.instance;
  final _uploadService = UploadApiService();
  ChatRepositorySend? _chatRepository;
  bool _isInitialized = false;

  // 单例模式
  static final MediaUploadIntegrationService _instance =
      MediaUploadIntegrationService._internal();
  factory MediaUploadIntegrationService() => _instance;
  MediaUploadIntegrationService._internal();

  /// 初始化服务
  void initialize(ChatRepositorySend chatRepository, [String? authToken]) {
    if (_isInitialized && _chatRepository == chatRepository) {
      _logger.d('MediaUploadIntegrationService已经初始化，跳过重复初始化');
      return;
    }

    _chatRepository = chatRepository;
    _isInitialized = true;

    if (authToken != null && authToken.isNotEmpty) {
      _uploadService.setAuthToken(authToken);
    }
    // 如果authToken为空，假设UploadApiService已经通过AuthTokenSyncService配置了token

    _logger.i('MediaUploadIntegrationService初始化完成');
  }

  /// 获取ChatRepository实例
  ChatRepositorySend get _chatRepo {
    if (_chatRepository == null) {
      throw StateError('MediaUploadIntegrationService未初始化，请先调用initialize方法');
    }
    return _chatRepository!;
  }

  /// 发送图片消息的完整流程
  Future<Message> sendImageMessage({
    required File imageFile,
    required String conversationId,
    String? caption,
    Function(int)? onUploadProgress,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('准备上传图片...');

      // 1. 获取图片尺寸（如果需要）
      final dimensions = await _getImageDimensions(imageFile);

      // 2. 上传图片到服务器
      onStatusUpdate?.call('正在上传图片...');
      final uploadResult = await _uploadService.uploadImage(
        imageFile,
        conversationId: conversationId,
        caption: caption,
        width: dimensions?.width,
        height: dimensions?.height,
        onProgress: onUploadProgress,
      );

      // 3. 发送消息 - 💢💢💢 立即设置宽高信息，避免布局跳动
      onStatusUpdate?.call('正在发送消息...');
      final message = await _chatRepo.sendImageMessage(
        conversationId,
        imageFile.path,
        mediaUrl: uploadResult.url,
        caption: caption,
      );

      // 💢💢💢 立即设置图片尺寸信息，避免等待图片加载后布局变化
      if (dimensions != null) {
        message.width = dimensions.width;
        message.height = dimensions.height;
        _logger.d('设置图片尺寸到消息', extra: {
          'messageId': message.messageId,
          'width': dimensions.width,
          'height': dimensions.height,
        });
      }

      // 4. 更新消息的服务器信息
      if (uploadResult.metadata != null) {
        message.fileSize = uploadResult.metadata!.size.toDouble();
        message.mimeType = uploadResult.metadata!.mimeType;
        // 只有在本地没有获取到尺寸时，才使用服务器返回的尺寸
        if (dimensions == null) {
          if (uploadResult.metadata!.width != null) {
            message.width = uploadResult.metadata!.width!;
          }
          if (uploadResult.metadata!.height != null) {
            message.height = uploadResult.metadata!.height!;
          }
        }
        if (uploadResult.thumbnailUrl != null) {
          message.thumbnailUrl = uploadResult.thumbnailUrl!;
        }
      }

      onStatusUpdate?.call('图片消息发送成功');
      _logger.i('图片消息发送完成', extra: {
        'conversationId': conversationId,
        'messageId': message.messageId,
        'fileId': uploadResult.fileId,
        'url': uploadResult.url,
        'width': message.width,
        'height': message.height,
      });

      return message;
    } catch (error) {
      _logger.e('发送图片消息失败', error: error, stackTrace: StackTrace.current);
      onStatusUpdate?.call('发送失败: $error');
      rethrow;
    }
  }

  /// 发送语音消息的完整流程
  Future<Message> sendVoiceMessage({
    required File voiceFile,
    required String conversationId,
    required int duration,
    Function(int)? onUploadProgress,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('准备上传语音...');

      // 1. 上传语音文件
      onStatusUpdate?.call('正在上传语音...');
      final uploadResult = await _uploadService.uploadVoice(
        voiceFile,
        conversationId: conversationId,
        duration: duration,
        onProgress: onUploadProgress,
      );

      // 2. 发送消息
      onStatusUpdate?.call('正在发送消息...');
      final message = await _chatRepo.sendVoiceMessage(
        conversationId,
        voiceFile.path,
        duration, // 🔧 duration参数已经是毫秒，直接传递
        mediaUrl: uploadResult.url,
      );

      // 3. 更新消息的服务器信息
      if (uploadResult.metadata != null) {
        message.fileSize = uploadResult.metadata!.size.toDouble();
        message.mimeType = uploadResult.metadata!.mimeType;
        message.duration = uploadResult.metadata!.duration ?? duration;
      }

      onStatusUpdate?.call('语音消息发送成功');
      _logger.i('语音消息发送完成', extra: {
        'conversationId': conversationId,
        'messageId': message.messageId,
        'fileId': uploadResult.fileId,
        'duration': duration,
      });

      return message;
    } catch (error) {
      _logger.e('发送语音消息失败', error: error, stackTrace: StackTrace.current);
      onStatusUpdate?.call('发送失败: $error');
      rethrow;
    }
  }

  /// 发送视频消息的完整流程
  Future<Message> sendVideoMessage({
    required File videoFile,
    required String conversationId,
    int? duration,
    String? caption,
    Function(int)? onUploadProgress,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('准备上传视频...');

      // 1. 获取视频信息（如果需要）
      final videoInfo = await _getVideoInfo(videoFile);
      final actualDuration = duration ?? videoInfo['duration'] as int?;

      // 2. 上传视频文件
      onStatusUpdate?.call('正在上传视频...');
      final uploadResult = await _uploadService.uploadVideo(
        videoFile,
        conversationId: conversationId,
        duration: actualDuration,
        width: videoInfo['width'] as int?,
        height: videoInfo['height'] as int?,
        caption: caption,
        onProgress: onUploadProgress,
      );

      // 3. 发送消息
      onStatusUpdate?.call('正在发送消息...');
      final message = await _chatRepo.sendVideoMessage(
        conversationId,
        videoFile.path,
        actualDuration != null ? actualDuration ~/ 1000 : 0,
        thumbnailUrl: uploadResult.thumbnailUrl,
        mediaUrl: uploadResult.url,
        isServerProcessed: true,
      );

      // 4. 更新消息的服务器信息
      if (uploadResult.metadata != null) {
        message.fileSize = uploadResult.metadata!.size.toDouble();
        message.mimeType = uploadResult.metadata!.mimeType;
        message.duration =
            uploadResult.metadata!.duration ?? actualDuration ?? 0;
        if (uploadResult.metadata!.width != null) {
          message.width = uploadResult.metadata!.width!;
        }
        if (uploadResult.metadata!.height != null) {
          message.height = uploadResult.metadata!.height!;
        }
      }

      onStatusUpdate?.call('视频消息发送成功');
      _logger.i('视频消息发送完成', extra: {
        'conversationId': conversationId,
        'messageId': message.messageId,
        'fileId': uploadResult.fileId,
        'hasThumbnail': uploadResult.thumbnailUrl != null,
      });

      return message;
    } catch (error) {
      _logger.e('发送视频消息失败', error: error, stackTrace: StackTrace.current);
      onStatusUpdate?.call('发送失败: $error');
      rethrow;
    }
  }

  /// 发送文档消息的完整流程
  /// 智能识别文件类型，图片文件自动使用图片上传端点
  Future<Message> sendDocumentMessage({
    required File documentFile,
    required String conversationId,
    String? caption,
    Function(int)? onUploadProgress,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('准备上传文件...');

      // 智能检测文件类型
      final mediaType = _getMediaTypeFromFile(documentFile);

      // 根据文件类型选择合适的上传方法
      UploadApiResult uploadResult;
      Message message;

      switch (mediaType) {
        case MediaType.image:
          // 图片文件使用图片上传端点，确保生成缩略图
          _logger.i('检测到图片文件，使用图片上传端点');
          onStatusUpdate?.call('正在上传图片...');

          final dimensions = await _getImageDimensions(documentFile);
          uploadResult = await _uploadService.uploadImage(
            documentFile,
            conversationId: conversationId,
            caption: caption,
            width: dimensions?.width,
            height: dimensions?.height,
            onProgress: onUploadProgress,
          );

          // 发送图片消息
          onStatusUpdate?.call('正在发送消息...');
          message = await _chatRepo.sendImageMessage(
            conversationId,
            documentFile.path,
            mediaUrl: uploadResult.url,
            caption: caption,
          );

          // 设置图片尺寸信息
          if (dimensions != null) {
            message.width = dimensions.width;
            message.height = dimensions.height;
          }
          break;

        case MediaType.video:
          // 视频文件使用视频上传端点，确保生成缩略图
          _logger.i('检测到视频文件，使用视频上传端点');
          onStatusUpdate?.call('正在上传视频...');

          final videoInfo = await _getVideoInfo(documentFile);
          uploadResult = await _uploadService.uploadVideo(
            documentFile,
            conversationId: conversationId,
            duration: videoInfo['duration'] as int?,
            width: videoInfo['width'] as int?,
            height: videoInfo['height'] as int?,
            caption: caption,
            onProgress: onUploadProgress,
          );

          // 发送视频消息
          onStatusUpdate?.call('正在发送消息...');
          message = await _chatRepo.sendVideoMessage(
            conversationId,
            documentFile.path,
            (videoInfo['duration'] as int? ?? 0) ~/ 1000,
            thumbnailUrl: uploadResult.thumbnailUrl,
            mediaUrl: uploadResult.url,
            isServerProcessed: true,
          );
          break;

        default:
          // 其他文件类型使用文档上传端点
          _logger.i('检测到文档文件，使用文档上传端点');
          onStatusUpdate?.call('正在上传文档...');

          uploadResult = await _uploadService.uploadDocument(
            documentFile,
            conversationId: conversationId,
            caption: caption,
            onProgress: onUploadProgress,
          );

          // 发送文档消息
          onStatusUpdate?.call('正在发送消息...');
          final fileName = documentFile.path.split('/').last;
          final fileSize = documentFile.lengthSync().toDouble();

          message = await _chatRepo.sendFileMessage(
            conversationId,
            documentFile.path,
            fileName,
            fileSize,
            mediaUrl: uploadResult.url,
          );
          break;
      }

      // 更新消息的服务器信息
      if (uploadResult.metadata != null) {
        message.fileSize = uploadResult.metadata!.size.toDouble();
        message.mimeType = uploadResult.metadata!.mimeType;

        // 对于图片和视频，更新尺寸信息
        if (mediaType == MediaType.image || mediaType == MediaType.video) {
          if (uploadResult.metadata!.width != null) {
            message.width = uploadResult.metadata!.width!;
          }
          if (uploadResult.metadata!.height != null) {
            message.height = uploadResult.metadata!.height!;
          }
          if (uploadResult.thumbnailUrl != null) {
            message.thumbnailUrl = uploadResult.thumbnailUrl!;
          }
        }

        // 对于视频，更新时长信息
        if (mediaType == MediaType.video &&
            uploadResult.metadata!.duration != null) {
          message.duration = uploadResult.metadata!.duration!;
        }
      }

      onStatusUpdate?.call('文件消息发送成功');
      _logger.i('文件消息发送完成', extra: {
        'conversationId': conversationId,
        'messageId': message.messageId,
        'fileId': uploadResult.fileId,
        'mediaType': mediaType.toString(),
        'hasThumbnail': uploadResult.thumbnailUrl != null,
      });

      return message;
    } catch (error) {
      _logger.e('发送文件消息失败', error: error, stackTrace: StackTrace.current);
      onStatusUpdate?.call('发送失败: $error');
      rethrow;
    }
  }

  /// 带重试的上传
  Future<Message> sendMediaMessageWithRetry({
    required File file,
    required String conversationId,
    required MediaType mediaType,
    String? caption,
    int? duration,
    Function(int)? onUploadProgress,
    Function(String)? onStatusUpdate,
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        switch (mediaType) {
          case MediaType.image:
            return await sendImageMessage(
              imageFile: file,
              conversationId: conversationId,
              caption: caption,
              onUploadProgress: onUploadProgress,
              onStatusUpdate: onStatusUpdate,
            );
          case MediaType.voice:
            if (duration == null) {
              throw ArgumentError('语音消息需要提供时长');
            }
            return await sendVoiceMessage(
              voiceFile: file,
              conversationId: conversationId,
              duration: duration,
              onUploadProgress: onUploadProgress,
              onStatusUpdate: onStatusUpdate,
            );
          case MediaType.video:
            return await sendVideoMessage(
              videoFile: file,
              conversationId: conversationId,
              duration: duration,
              caption: caption,
              onUploadProgress: onUploadProgress,
              onStatusUpdate: onStatusUpdate,
            );
          case MediaType.document:
            return await sendDocumentMessage(
              documentFile: file,
              conversationId: conversationId,
              caption: caption,
              onUploadProgress: onUploadProgress,
              onStatusUpdate: onStatusUpdate,
            );
        }
      } catch (error) {
        if (i == maxRetries - 1) {
          rethrow;
        }

        _logger.w('发送媒体消息失败，准备重试... (${i + 1}/$maxRetries)');
        onStatusUpdate?.call('发送失败，正在重试... (${i + 1}/$maxRetries)');

        await Future.delayed(Duration(seconds: (i + 1) * 2)); // 递增延迟
      }
    }

    throw Exception('重试次数已用完');
  }

  /// 批量上传文件
  Future<List<Message>> sendMultipleFiles({
    required List<File> files,
    required String conversationId,
    Function(int, int)? onProgress, // (currentIndex, totalCount)
    Function(String)? onStatusUpdate,
  }) async {
    final messages = <Message>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      onProgress?.call(i + 1, files.length);
      onStatusUpdate?.call('正在处理文件 ${i + 1}/${files.length}...');

      try {
        final mediaType = _getMediaTypeFromFile(file);
        final message = await sendMediaMessageWithRetry(
          file: file,
          conversationId: conversationId,
          mediaType: mediaType,
          onStatusUpdate: (status) =>
              onStatusUpdate?.call('文件 ${i + 1}: $status'),
        );
        messages.add(message);
      } catch (error) {
        _logger.e('批量上传中的文件失败', error: error, extra: {
          'fileName': file.path.split('/').last,
          'index': i,
        });
        // 继续处理其他文件，不中断整个流程
      }
    }

    onStatusUpdate?.call('批量上传完成，成功 ${messages.length}/${files.length} 个文件');
    return messages;
  }

  /// 从文件确定媒体类型
  MediaType _getMediaTypeFromFile(File file) {
    final mimeType = lookupMimeType(file.path);
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) return MediaType.image;
      if (mimeType.startsWith('audio/')) return MediaType.voice;
      if (mimeType.startsWith('video/')) return MediaType.video;
    }
    return MediaType.document;
  }

  /// 获取图片尺寸
  Future<ImageDimensions?> _getImageDimensions(File imageFile) async {
    try {
      _logger.d('开始获取图片尺寸', extra: {'filePath': imageFile.path});

      // 使用Flutter的Image类获取图片尺寸
      final imageProvider = FileImage(imageFile);
      final ImageStream stream =
          imageProvider.resolve(ImageConfiguration.empty);

      // 创建一个Completer来等待图片加载完成
      final completer = Completer<ImageDimensions?>();
      late ImageStreamListener listener;

      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          final width = info.image.width;
          final height = info.image.height;

          _logger.d('成功获取图片尺寸', extra: {
            'width': width,
            'height': height,
            'filePath': imageFile.path,
          });

          stream.removeListener(listener);
          completer.complete(ImageDimensions(width: width, height: height));
        },
        onError: (exception, stackTrace) {
          _logger.w('获取图片尺寸失败: $exception');
          stream.removeListener(listener);
          completer.complete(null);
        },
      );

      stream.addListener(listener);

      // 等待图片加载完成，最多等待5秒
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _logger.w('获取图片尺寸超时');
          stream.removeListener(listener);
          return null;
        },
      );
    } catch (error) {
      _logger.w('获取图片尺寸失败: $error');
      return null;
    }
  }

  /// 获取视频信息
  Future<Map<String, dynamic>> _getVideoInfo(File videoFile) async {
    try {
      // 这里应该使用适当的视频处理库来获取信息
      // 暂时返回空Map，实际实现需要添加video_player或ffmpeg库依赖
      return {};
    } catch (error) {
      _logger.w('获取视频信息失败: $error');
      return {};
    }
  }

  /// 清除认证token
  void clearAuth() {
    _uploadService.clearAuthToken();
  }
}

/// 媒体类型枚举
enum MediaType {
  image,
  voice,
  video,
  document,
}

/// 图片尺寸
class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({
    required this.width,
    required this.height,
  });
}

/// 上传进度回调类型定义
typedef UploadProgressCallback = void Function(int progress);
typedef StatusUpdateCallback = void Function(String status);
typedef BatchProgressCallback = void Function(int current, int total);
