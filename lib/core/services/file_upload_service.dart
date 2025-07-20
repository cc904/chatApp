import 'dart:io';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/upload_api_service.dart';
import 'package:cc/core/services/dynamic_file_server_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
// import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:cc/core/constants/app_colors.dart';

/// 文件上传服务
/// 负责处理文件的真实上传到服务器
class FileUploadService {
  final _logger = LogService.instance;
  final Uuid _uuid = const Uuid();
  final UploadApiService _uploadApiService = UploadApiService();

  // 单例模式
  static final FileUploadService _instance = FileUploadService._internal();

  factory FileUploadService() {
    return _instance;
  }

  FileUploadService._internal() {
    _ensureDirectories();
  }

  /// 初始化上传API服务（在登录后调用）
  /// 注意：由于UploadApiService是单例，此方法现在是可选的
  void initialize() {
    _logger.i('🔄 FileUploadService已使用UploadApiService单例');
  }

  /// 确保上传API服务已初始化
  /// 注意：由于直接使用单例，无需检查初始化状态
  void _ensureInitialized() {
    // UploadApiService是单例，总是可用的
  }


  /// 确保所需目录存在
  Future<void> _ensureDirectories() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final directories = ['images', 'videos', 'voice', 'files', 'thumbnails'];

      for (final dir in directories) {
        final mediaDir = Directory('${appDocDir.path}/media/$dir');
        if (!await mediaDir.exists()) {
          await mediaDir.create(recursive: true);
          _logger.i('创建目录: ${mediaDir.path}');
        }
      }
    } catch (error) {
      _logger.e('创建媒体目录失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 上传图片
  /// 真实API实现
  Future<UploadResult?> uploadImage(
    File imageFile,
    String conversationId, {
    String? caption,
    Function(int)? onProgress,
  }) async {
    try {
      _logger.i('开始上传图片到服务器', extra: {
        'filePath': imageFile.path,
        'conversationId': conversationId,
      });

      // 验证文件大小
      _validateFileSize(imageFile, 'image');

      // 获取图片尺寸
      final dimensions = await _getImageDimensions(imageFile);

      // 确保服务已初始化
      _ensureInitialized();
      
      // 调用真实API上传
      final apiResult = await _uploadApiService.uploadImage(
        imageFile,
        conversationId: conversationId,
        caption: caption,
        width: dimensions?.width,
        height: dimensions?.height,
        onProgress: onProgress,
      );

      if (apiResult.success) {
        // 同时保存到本地用于缓存
        final localResult = await _saveFileLocally(imageFile, 'images');

        return UploadResult(
          localPath: localResult?.localPath ?? imageFile.path,
          remoteUrl: apiResult.url ?? '', // 新文件服务器可能不返回URL
          fileId: apiResult.fileId,
          fileName: apiResult.fileName, // 新增：服务器生成的文件名
          thumbnailUrl: null, // 缩略图由客户端构建
          thumbnailFileName: apiResult.fileName, // 缩略图使用相同文件名
          metadata: apiResult.metadata != null
              ? {
                  'originalName': apiResult.metadata!.originalName,
                  'size': apiResult.metadata!.size,
                  'mimeType': apiResult.metadata!.mimeType,
                  'width': apiResult.metadata!.width,
                  'height': apiResult.metadata!.height,
                }
              : null,
        );
      } else {
        _logger.e('图片上传API失败', extra: {'error': apiResult.error});
        return null;
      }
    } catch (error) {
      _logger.e('图片上传失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 上传语音
  /// 真实API实现
  Future<UploadResult?> uploadVoice(
    File voiceFile,
    int duration, {
    String? conversationId,
    Function(int)? onProgress,
  }) async {
    try {
      _logger.i('开始上传语音到服务器', extra: {
        'filePath': voiceFile.path,
        'duration': duration,
        'conversationId': conversationId,
      });

      // 验证文件大小
      _validateFileSize(voiceFile, 'voice');

      // 确保服务已初始化
      _ensureInitialized();
      
      // 调用真实API上传
      final apiResult = await _uploadApiService.uploadVoice(
        voiceFile,
        conversationId: conversationId ?? '',
        duration: duration,
        onProgress: onProgress,
      );

      if (apiResult.success) {
        // 同时保存到本地用于缓存
        final localResult = await _saveFileLocally(voiceFile, 'voice');

        return UploadResult(
          localPath: localResult?.localPath ?? voiceFile.path,
          remoteUrl: apiResult.url ?? '', // 新的文件服务器不直接返回URL，使用空字符串
          fileId: apiResult.fileId,
          fileName: apiResult.fileName, // 新增：服务器生成的文件名
          duration: duration,
          metadata: apiResult.metadata != null
              ? {
                  'originalName': apiResult.metadata!.originalName,
                  'size': apiResult.metadata!.size,
                  'mimeType': apiResult.metadata!.mimeType,
                  'duration': apiResult.metadata!.duration,
                }
              : null,
        );
      } else {
        _logger.e('语音上传API失败', extra: {'error': apiResult.error});
        return null;
      }
    } catch (error) {
      _logger.e('语音上传失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 上传文件
  /// 真实API实现
  Future<UploadResult?> uploadFile(
    File file,
    String conversationId, {
    String? caption,
    Function(int)? onProgress,
  }) async {
    try {
      _logger.i('开始上传文档到服务器', extra: {
        'filePath': file.path,
        'conversationId': conversationId,
      });

      // 验证文件大小
      _validateFileSize(file, 'file');

      // 确保服务已初始化
      _ensureInitialized();
      
      // 调用真实API上传
      final apiResult = await _uploadApiService.uploadDocument(
        file,
        conversationId: conversationId,
        caption: caption,
        onProgress: onProgress,
      );

      if (apiResult.success) {
        // 同时保存到本地用于缓存
        final localResult = await _saveFileLocally(file, 'files');

        return UploadResult(
          localPath: localResult?.localPath ?? file.path,
          remoteUrl: apiResult.url ?? '', // 新文件服务器可能不返回URL
          fileId: apiResult.fileId,
          fileName: apiResult.fileName, // 新增：服务器生成的文件名
          thumbnailUrl: null, // 缩略图由客户端构建
          thumbnailFileName: apiResult.fileName, // 缩略图使用相同文件名
          metadata: apiResult.metadata != null
              ? {
                  'originalName': apiResult.metadata!.originalName,
                  'size': apiResult.metadata!.size,
                  'mimeType': apiResult.metadata!.mimeType,
                }
              : null,
        );
      } else {
        _logger.e('文档上传API失败', extra: {'error': apiResult.error});
        return null;
      }
    } catch (error) {
      _logger.e('文档上传失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 上传视频
  /// 真实API实现，服务器端处理缩略图生成
  Future<UploadResult?> uploadVideo(
    File videoFile,
    String conversationId, {
    String? caption,
    Function(int)? onProgress,
  }) async {
    try {
      _logger.i('开始上传视频到服务器', extra: {
        'filePath': videoFile.path,
        'conversationId': conversationId,
      });

      // 验证文件大小
      _validateFileSize(videoFile, 'video');

      // 获取视频信息
      final videoInfo = await _getVideoInfo(videoFile);

      // 确保服务已初始化
      _ensureInitialized();
      
      // 调用真实API上传视频
      final apiResult = await _uploadApiService.uploadVideo(
        videoFile,
        conversationId: conversationId,
        duration: videoInfo['duration'] as int?,
        width: videoInfo['width'] as int?,
        height: videoInfo['height'] as int?,
        caption: caption,
        onProgress: onProgress,
      );

      if (apiResult.success) {
        // 同时保存到本地用于缓存
        final localResult = await _saveFileLocally(videoFile, 'videos');

        return UploadResult(
          localPath: localResult?.localPath ?? videoFile.path,
          remoteUrl: apiResult.url ?? '', // 新文件服务器可能不返回URL
          fileId: apiResult.fileId,
          fileName: apiResult.fileName, // 新增：服务器生成的文件名
          thumbnailPath: null, // 服务器生成的缩略图不保存到本地
          thumbnailUrl: null, // 缩略图由客户端构建
          thumbnailFileName: apiResult.fileName, // 缩略图使用相同文件名
          serverProcessed: true, // 标记为服务器处理
          metadata: apiResult.metadata != null
              ? {
                  'originalName': apiResult.metadata!.originalName,
                  'size': apiResult.metadata!.size,
                  'mimeType': apiResult.metadata!.mimeType,
                  'duration': apiResult.metadata!.duration,
                  'width': apiResult.metadata!.width,
                  'height': apiResult.metadata!.height,
                }
              : null,
        );
      } else {
        _logger.e('视频上传API失败', extra: {'error': apiResult.error});
        return null;
      }
    } catch (error) {
      _logger.e('视频上传失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 本地生成视频缩略图（作为备用方案）
  /// 当服务器无法生成缩略图时使用
  Future<File?> generateVideoThumbnail(String videoPath) async {
    try {
      _logger.i('本地生成视频缩略图作为备用方案');
      return await _generateFallbackThumbnail(videoPath);
    } catch (error) {
      _logger.e('生成视频缩略图失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取图片尺寸
  Future<ImageDimensions?> _getImageDimensions(File imageFile) async {
    try {
      // 使用Flutter的方法获取图片尺寸
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      return ImageDimensions(
        width: image.width,
        height: image.height,
      );
    } catch (error) {
      _logger.w('获取图片尺寸失败: $error');
      return null;
    }
  }

  /// 获取视频信息
  Future<Map<String, dynamic>> _getVideoInfo(File videoFile) async {
    try {
      final videoController = VideoPlayerController.file(videoFile);
      await videoController.initialize();

      final duration = videoController.value.duration.inMilliseconds;
      final aspectRatio = videoController.value.aspectRatio;

      // 根据宽高比估算尺寸
      int? width, height;
      if (aspectRatio > 0 && !aspectRatio.isNaN && !aspectRatio.isInfinite) {
        // 假设高度为720p，计算宽度
        height = 720;
        width = (height * aspectRatio).round();
      }

      await videoController.dispose();

      return {
        'duration': duration,
        'width': width,
        'height': height,
        'aspectRatio': aspectRatio,
      };
    } catch (error) {
      _logger.w('获取视频信息失败: $error');
      return {};
    }
  }

  /// 将文件保存到本地缓存
  Future<UploadResult?> _saveFileLocally(File file, String subdirectory) async {
    try {
      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();

      // 创建子目录
      final mediaDir = Directory('${appDocDir.path}/media/$subdirectory');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      // 生成唯一文件名
      final fileName = '${_uuid.v4()}${path.extension(file.path)}';
      final localPath = '${mediaDir.path}/$fileName';

      // 复制文件到目标路径
      await file.copy(localPath);

      return UploadResult(
        localPath: localPath,
        remoteUrl: '', // 本地缓存不需要远程URL
      );
    } catch (error) {
      _logger.e('保存文件到本地失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 备用的缩略图生成方法
  Future<File?> _generateFallbackThumbnail(String videoPath) async {
    try {
      _logger.i('开始生成备用缩略图，视频路径: $videoPath');

      // 创建临时目录用于存储缩略图
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = '${tempDir.path}/${_uuid.v4()}_fallback.jpg';

      final String fileName = path.basename(videoPath);

      // 根据文件名生成一个独特的颜色
      final int hashCode = fileName.hashCode;
      final List<Color> gradientColors = [
        AppColors.primary,
        Colors.red[700] ?? Colors.red,
        Colors.green[700] ?? Colors.green,
        Colors.purple[700] ?? Colors.purple,
        Colors.orange[700] ?? Colors.orange,
        Colors.teal[700] ?? Colors.teal,
        Colors.indigo[700] ?? Colors.indigo,
        Colors.pink[700] ?? Colors.pink,
        Colors.amber[700] ?? Colors.amber
      ];

      final Color primaryColor =
          gradientColors[hashCode.abs() % gradientColors.length];
      final Color secondaryColor =
          gradientColors[(hashCode.abs() + 3) % gradientColors.length];
      final Color tertiaryColor =
          gradientColors[(hashCode.abs() + 6) % gradientColors.length];

      // 生成彩色渐变
      final Gradient gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withAlpha(204), // 0.8 * 255 = 204
            secondaryColor,
            tertiaryColor,
          ],
          stops: const [
            0.0,
            0.5,
            1.0
          ]);

      // 获取视频时长
      int videoDurationInSeconds = 0;
      double aspectRatio = 16 / 9; // 默认宽高比

      try {
        final videoController = VideoPlayerController.file(File(videoPath));
        await videoController.initialize();
        videoDurationInSeconds = videoController.value.duration.inSeconds;
        aspectRatio = videoController.value.aspectRatio;
        if (aspectRatio <= 0 || aspectRatio.isNaN || aspectRatio.isInfinite) {
          aspectRatio = 16 / 9;
        }
        await videoController.dispose();
      } catch (error) {
        _logger.w('无法获取视频信息: $error，使用默认值');
      }

      // 创建一个生动的缩略图
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      const double width = 300.0;
      final double height = width / aspectRatio;

      // 创建渐变背景
      final Rect rect = Rect.fromLTWH(0, 0, width, height);

      // 绘制背景
      final Paint backgroundPaint = Paint()
        ..shader = gradient.createShader(rect);
      canvas.drawRect(rect, backgroundPaint);

      // 添加网格图案增加视觉效果
      final Paint gridPaint = Paint()
        ..color = Colors.white.withAlpha(26) // 0.1 * 255 = 25.5 ≈ 26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (double i = 0; i < width; i += 20) {
        canvas.drawLine(Offset(i, 0), Offset(i, height), gridPaint);
      }

      for (double i = 0; i < height; i += 20) {
        canvas.drawLine(Offset(0, i), Offset(width, i), gridPaint);
      }

      // 添加视频图标
      const double iconSize = 80.0;
      final Paint iconCirclePaint = Paint()
        ..color = Colors.white.withAlpha(51) // 0.2 * 255 = 51
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          Offset(width / 2, height / 2), iconSize / 1.5, iconCirclePaint);

      // 绘制播放三角形
      final Path trianglePath = Path();
      const double triangleOffset = width * 0.03;
      trianglePath.moveTo(
          width / 2 - iconSize / 4 + triangleOffset, height / 2 - iconSize / 4);
      trianglePath.lineTo(
          width / 2 + iconSize / 4 + triangleOffset, height / 2);
      trianglePath.lineTo(
          width / 2 - iconSize / 4 + triangleOffset, height / 2 + iconSize / 4);
      trianglePath.close();

      final Paint trianglePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawPath(trianglePath, trianglePaint);

      // 添加文件名
      final TextStyle fileNameStyle = TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(1.0, 1.0),
            blurRadius: 3.0,
            color: Colors.black.withAlpha(128), // 0.5 * 255 = 127.5 ≈ 128
          ),
        ],
      );

      final String displayName =
          fileName.length > 25 ? '${fileName.substring(0, 22)}...' : fileName;

      final TextPainter fileNamePainter = TextPainter(
        text: TextSpan(text: displayName, style: fileNameStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      );

      fileNamePainter.layout(maxWidth: width - 40);

      // 添加半透明背景提高可读性
      final Rect textBgRect = Rect.fromLTWH(
          20,
          height - fileNamePainter.height - 40,
          fileNamePainter.width + 20,
          fileNamePainter.height + 10);

      final Paint textBgPaint = Paint()
        ..color = Colors.black.withAlpha(128) // 0.5 * 255 = 127.5 ≈ 128
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
          RRect.fromRectAndRadius(textBgRect, const Radius.circular(5)),
          textBgPaint);

      fileNamePainter.paint(
          canvas, Offset(30, height - fileNamePainter.height - 35));

      // 添加视频时长信息
      if (videoDurationInSeconds > 0) {
        final String durationText =
            _formatDuration(Duration(seconds: videoDurationInSeconds));
        final TextStyle durationStyle = TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(1.0, 1.0),
              blurRadius: 2.0,
              color: Colors.black.withAlpha(128), // 0.5 * 255 = 127.5 ≈ 128
            ),
          ],
        );

        final TextPainter durationPainter = TextPainter(
          text: TextSpan(text: durationText, style: durationStyle),
          textDirection: TextDirection.ltr,
        );

        durationPainter.layout();

        // 右下角时长显示
        final Rect durationBgRect = Rect.fromLTWH(
            width - durationPainter.width - 30,
            height - durationPainter.height - 20,
            durationPainter.width + 10,
            durationPainter.height + 6);

        canvas.drawRRect(
            RRect.fromRectAndRadius(durationBgRect, const Radius.circular(3)),
            textBgPaint);

        durationPainter.paint(
            canvas,
            Offset(width - durationPainter.width - 25,
                height - durationPainter.height - 17));
      }

      // 将绘制内容转换为图像
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image =
          await picture.toImage(width.toInt(), height.toInt());
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('无法从渲染器获取图像数据');
      }

      // 将图像字节写入文件
      final File thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(byteData.buffer.asUint8List());

      _logger.i('备用视频缩略图生成成功: $thumbnailPath');
      return thumbnailFile;
    } catch (error) {
      _logger.e('备用缩略图生成失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 格式化视频时长
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  /// 验证文件大小
  void _validateFileSize(File file, String fileType) {
    if (!file.existsSync()) {
      throw Exception('文件不存在');
    }

    final fileSize = file.lengthSync();
    final dynamicConfig = DynamicFileServerConfig();
    final config = dynamicConfig.currentConfig;

    if (config != null) {
      if (!config.isFileSizeValidForType(fileSize, fileType)) {
        final limits = config.limits;
        String errorMessage;

        switch (fileType.toLowerCase()) {
          case 'image':
          case 'images':
            final maxSizeMB = (limits.imageMaxSize / 1024 / 1024).round();
            errorMessage = '图片大小不能超过${maxSizeMB}MB';
            break;
          case 'voice':
          case 'audio':
            // 语音文件已通过时长限制，无需大小限制
            return;
          case 'video':
          case 'videos':
            final maxSizeMB = (limits.videoMaxSize / 1024 / 1024).round();
            errorMessage = '视频文件大小不能超过${maxSizeMB}MB';
            break;
          case 'file':
          case 'files':
            final maxSizeMB = (limits.fileMaxSize / 1024 / 1024).round();
            errorMessage = '文件大小不能超过${maxSizeMB}MB';
            break;
          default:
            errorMessage = '文件大小超过限制';
        }

        throw Exception(errorMessage);
      }
    } else {
      // 如果没有动态配置，使用默认限制
      _logger.w('没有找到动态文件服务器配置，使用默认文件大小限制');

      switch (fileType.toLowerCase()) {
        case 'image':
        case 'images':
          if (fileSize > 10 * 1024 * 1024) {
            throw Exception('图片大小不能超过10MB');
          }
          break;
        case 'voice':
        case 'audio':
          // 语音文件已通过时长限制，无需大小限制
          break;
        case 'video':
        case 'videos':
          if (fileSize > 500 * 1024 * 1024) {
            throw Exception('视频文件大小不能超过500MB');
          }
          break;
        case 'file':
        case 'files':
          if (fileSize > 100 * 1024 * 1024) {
            throw Exception('文件大小不能超过100MB');
          }
          break;
      }
    }
  }

  /// 获取本地文件完整路径
  String getLocalFilePath(String mediaUrl) {
    if (mediaUrl.startsWith('file://')) {
      // 去除file://前缀
      return mediaUrl.substring(7);
    }
    return mediaUrl;
  }
}

/// 图片尺寸类
class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({
    required this.width,
    required this.height,
  });
}

/// 文件上传结果
class UploadResult {
  final String localPath;
  final String remoteUrl;
  final String? fileId; // 服务器返回的文件ID
  final String? fileName; // 新增：服务器生成的文件名（nanoID或UUID）
  final int? duration; // 语音/视频文件使用
  final String? thumbnailPath; // 视频缩略图本地路径
  final String? thumbnailUrl; // 视频缩略图URL
  final String? thumbnailFileName; // 新增：缩略图文件名
  final bool serverProcessed; // 是否由服务器处理生成的缩略图
  final Map<String, dynamic>? metadata; // 文件元数据

  UploadResult({
    required this.localPath,
    required this.remoteUrl,
    this.fileId,
    this.fileName,
    this.duration,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.thumbnailFileName,
    this.serverProcessed = false, // 默认为客户端处理
    this.metadata,
  });

  /// 根据新的文件服务器逻辑构建完整的文件URL
  /// 路径格式：文件服务器/类型type/会话ID/UTC日期/用户ID/文件名
  String buildFileUrl(String fileServerBaseUrl, String type,
      String conversationId, String timestamp, String userId) {
    if (fileName == null) return remoteUrl;
    // 从时间戳提取UTC日期
    final utcDate = _extractDateFromTimestamp(timestamp);
    return '$fileServerBaseUrl/$type/$conversationId/$utcDate/$userId/$fileName';
  }

  /// 构建缩略图URL
  String? buildThumbnailUrl(String fileServerBaseUrl, String conversationId,
      String timestamp, String userId) {
    if (thumbnailFileName == null) return thumbnailUrl;
    // 从时间戳提取UTC日期
    final utcDate = _extractDateFromTimestamp(timestamp);
    return '$fileServerBaseUrl/thumbnail/$conversationId/$utcDate/$userId/$thumbnailFileName';
  }

  /// 从时间戳提取UTC日期
  static String _extractDateFromTimestamp(String timestamp) {
    DateTime date;
    final parsed = int.tryParse(timestamp);
    if (parsed != null) {
      date = DateTime.fromMillisecondsSinceEpoch(parsed).toUtc();
    } else {
      date = DateTime.now().toUtc();
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
