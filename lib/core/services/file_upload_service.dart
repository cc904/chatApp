import 'dart:io';
import 'package:cc/core/services/log_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
// import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// 文件上传服务
/// 负责处理文件的上传和本地存储
class FileUploadService {
  final _logger = LogService('file_upload_service.dart');
  final Uuid _uuid = const Uuid();

  // 单例模式
  static final FileUploadService _instance = FileUploadService._internal();

  factory FileUploadService() {
    return _instance;
  }

  FileUploadService._internal() {
    _ensureDirectories();
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
    } catch (e) {
      _logger.e('创建媒体目录失败', error: e);
    }
  }

  /// 上传图片
  /// 在实际应用中,这里应该连接到真实的API进行上传
  /// 目前我们先模拟上传,只保存到本地目录
  Future<UploadResult?> uploadImage(File imageFile) async {
    return _uploadFile(imageFile, 'images');
  }

  /// 上传语音
  Future<UploadResult?> uploadVoice(File voiceFile, int duration) async {
    final result = await _uploadFile(voiceFile, 'voice');
    if (result == null) return null;

    return UploadResult(
      localPath: result.localPath,
      remoteUrl: result.remoteUrl,
      duration: duration,
    );
  }

  /// 上传文件
  Future<UploadResult?> uploadFile(File file) async {
    return _uploadFile(file, 'files');
  }

  /// 上传视频
  /// 模拟将视频发送到服务器并由服务器生成缩略图的过程
  Future<UploadResult?> uploadVideo(File videoFile) async {
    try {
      _logServerProcess('接收到视频上传请求: ${videoFile.path}');

      // 首先上传视频文件（在真实实现中,这将是发送到服务器的过程）
      _logClientProcess('开始上传视频文件');
      final videoResult = await _uploadFile(videoFile, 'videos');
      if (videoResult == null) {
        _logClientProcess('视频文件上传失败');
        return null;
      }

      _logClientProcess('视频文件上传成功');
      _logServerProcess('服务器收到视频文件,准备处理');

      // 模拟服务器处理延迟
      await Future.delayed(const Duration(milliseconds: 800));

      // 模拟服务器生成缩略图
      File? thumbnailFile;
      try {
        _logServerProcess('开始生成视频缩略图');
        thumbnailFile = await _simulateServerThumbnailGeneration(videoFile.path);
        _logServerProcess('缩略图生成成功');
      } catch (e) {
        _logServerProcess('生成缩略图失败: $e');
        _logger.w('服务器生成缩略图失败,将返回没有缩略图的视频', extra: {'error': e});
      }

      if (thumbnailFile != null) {
        // 模拟服务器存储缩略图并返回URL
        _logServerProcess('正在存储缩略图');
        final thumbnailResult = await _uploadFile(thumbnailFile, 'thumbnails');

        if (thumbnailResult != null) {
          _logServerProcess('缩略图存储成功,准备返回结果');
          // 模拟服务器返回包含视频和缩略图URL的响应
          return UploadResult(
            localPath: videoResult.localPath,
            remoteUrl: videoResult.remoteUrl,
            thumbnailPath: thumbnailResult.localPath,
            thumbnailUrl: thumbnailResult.remoteUrl,
            serverProcessed: true, // 标记为服务器处理
          );
        } else {
          _logServerProcess('缩略图存储失败');
        }
      } else {
        _logServerProcess('无法生成缩略图,将返回不含缩略图的视频结果');
      }

      // 如果服务器缩略图处理失败,仍然返回视频上传结果
      return UploadResult(
        localPath: videoResult.localPath,
        remoteUrl: videoResult.remoteUrl,
        serverProcessed: true,
      );
    } catch (e) {
      _logger.e('视频上传或处理失败', error: e);
      _logClientProcess('视频上传过程中出现错误: $e');
      return null;
    }
  }

  /// 模拟服务器生成视频缩略图
  /// 在真正的服务器实现中,这个过程将在服务器上执行
  Future<File?> _simulateServerThumbnailGeneration(String videoPath) async {
    try {
      _logServerProcess('分析视频文件');

      // 添加随机延迟模拟服务器处理时间
      final random = math.Random();
      await Future.delayed(Duration(milliseconds: 500 + random.nextInt(1000)));

      // 模拟服务器成功率 (90%)
      if (random.nextDouble() > 0.1) {
        // 在这里,我们仍然使用本地方法生成缩略图
        // 但在概念上,我们将其视为服务器端处理
        _logServerProcess('使用服务器算法生成缩略图');
        return await _generateFallbackThumbnail(videoPath);
      } else {
        // 模拟服务器偶尔失败的情况
        throw Exception('服务器缩略图处理失败');
      }
    } catch (e) {
      _logServerProcess('生成缩略图失败: $e');
      rethrow; // 重新抛出异常,让调用者处理
    }
  }

  /// 生成视频缩略图
  /// 返回缩略图文件
  Future<File?> generateVideoThumbnail(String videoPath) async {
    try {
      // 直接使用备用方法生成缩略图,因为video_thumbnail插件在当前平台有问题
      _logClientProcess('使用备用方法生成视频缩略图');
      return await _generateFallbackThumbnail(videoPath);
    } catch (e) {
      _logger.e('生成视频缩略图失败', error: e);
      return null;
    }
  }

  /// 备用的缩略图生成方法,当video_thumbnail包失败时使用
  Future<File?> _generateFallbackThumbnail(String videoPath) async {
    try {
      _logClientProcess('开始生成备用缩略图,视频路径: $videoPath');

      // 创建临时目录用于存储缩略图
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = '${tempDir.path}/${_uuid.v4()}_fallback.jpg';
      _logClientProcess('缩略图将保存至: $thumbnailPath');

      final String fileName = path.basename(videoPath);

      // 根据文件名生成一个独特的颜色
      final int hashCode = fileName.hashCode;
      final List<Color> gradientColors = [
        Colors.blue[700] ?? Colors.blue,
        Colors.red[700] ?? Colors.red,
        Colors.green[700] ?? Colors.green,
        Colors.purple[700] ?? Colors.purple,
        Colors.orange[700] ?? Colors.orange,
        Colors.teal[700] ?? Colors.teal,
        Colors.indigo[700] ?? Colors.indigo,
        Colors.pink[700] ?? Colors.pink,
        Colors.amber[700] ?? Colors.amber
      ];

      final Color primaryColor = gradientColors[hashCode.abs() % gradientColors.length];
      final Color secondaryColor = gradientColors[(hashCode.abs() + 3) % gradientColors.length];
      final Color tertiaryColor = gradientColors[(hashCode.abs() + 6) % gradientColors.length];

      // 生成彩色渐变
      final Gradient gradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
        primaryColor.withAlpha(204), // 0.8 * 255 = 204
        secondaryColor,
        tertiaryColor,
      ], stops: const [
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
      } catch (e) {
        _logClientProcess('无法获取视频信息: $e,使用默认值');
        // 出错时使用默认值即可,不需要抛出异常
      }

      // 创建一个生动的缩略图
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      const double width = 300.0;
      final double height = width / aspectRatio;

      // 创建渐变背景
      final Rect rect = Rect.fromLTWH(0, 0, width, height);

      // 绘制背景
      final Paint backgroundPaint = Paint()..shader = gradient.createShader(rect);
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

      canvas.drawCircle(Offset(width / 2, height / 2), iconSize / 1.5, iconCirclePaint);

      // 绘制播放三角形
      final Path trianglePath = Path();
      final double triangleOffset = width * 0.03;
      trianglePath.moveTo(width / 2 - iconSize / 4 + triangleOffset, height / 2 - iconSize / 4);
      trianglePath.lineTo(width / 2 + iconSize / 4 + triangleOffset, height / 2);
      trianglePath.lineTo(width / 2 - iconSize / 4 + triangleOffset, height / 2 + iconSize / 4);
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

      final String displayName = fileName.length > 25 ? '${fileName.substring(0, 22)}...' : fileName;

      final TextPainter fileNamePainter = TextPainter(
        text: TextSpan(text: displayName, style: fileNameStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      );

      fileNamePainter.layout(maxWidth: width - 40);

      // 添加半透明背景提高可读性
      final Rect textBgRect = Rect.fromLTWH(20, height - fileNamePainter.height - 40, fileNamePainter.width + 20, fileNamePainter.height + 10);

      final Paint textBgPaint = Paint()
        ..color = Colors.black.withAlpha(128) // 0.5 * 255 = 127.5 ≈ 128
        ..style = PaintingStyle.fill;

      canvas.drawRRect(RRect.fromRectAndRadius(textBgRect, const Radius.circular(5)), textBgPaint);

      fileNamePainter.paint(canvas, Offset(30, height - fileNamePainter.height - 35));

      // 添加视频时长信息
      if (videoDurationInSeconds > 0) {
        final String durationText = _formatDuration(Duration(seconds: videoDurationInSeconds));
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
        final Rect durationBgRect = Rect.fromLTWH(width - durationPainter.width - 30, height - durationPainter.height - 20, durationPainter.width + 10, durationPainter.height + 6);

        canvas.drawRRect(RRect.fromRectAndRadius(durationBgRect, const Radius.circular(3)), textBgPaint);

        durationPainter.paint(canvas, Offset(width - durationPainter.width - 25, height - durationPainter.height - 17));
      }

      // 将绘制内容转换为图像
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('无法从渲染器获取图像数据');
      }

      // 将图像字节写入文件
      final File thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(byteData.buffer.asUint8List());

      _logClientProcess('备用视频缩略图生成成功: $thumbnailPath');
      return thumbnailFile;
    } catch (e) {
      _logger.e('备用缩略图生成失败', error: e);
      _logClientProcess('备用缩略图生成过程中发生错误: $e');
      return await _createDefaultThumbnail('${(await getTemporaryDirectory()).path}/${_uuid.v4()}_default.jpg', videoPath);
    }
  }

  /// 创建默认缩略图,当所有其他方法都失败时使用
  Future<File?> _createDefaultThumbnail(String thumbnailPath, String videoPath) async {
    try {
      _logClientProcess('创建默认视频缩略图');
      final String fileName = path.basename(videoPath);

      // 创建一个简单但美观的缩略图
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      const double width = 300.0;
      const double height = 200.0;

      // 使用渐变背景
      final Rect rect = Rect.fromLTWH(0, 0, width, height);
      final LinearGradient gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.deepPurple.shade900,
          Colors.deepPurple.shade700,
          Colors.deepPurple.shade500,
        ],
      );

      // 绘制背景
      final Paint backgroundPaint = Paint()..shader = gradient.createShader(rect);
      canvas.drawRect(rect, backgroundPaint);

      // 添加一些几何图案作为装饰
      for (int i = 0; i < 5; i++) {
        final Paint decorPaint = Paint()
          ..color = Colors.white.withAlpha(26) // 0.1 * 255 = 25.5 ≈ 26
          ..style = PaintingStyle.fill;

        final double size = 80 + i * 40.0;
        canvas.drawCircle(Offset(width * 0.2, height * 0.8), size, decorPaint);
      }

      // 添加视频图标
      final Paint iconCirclePaint = Paint()
        ..color = Colors.white.withAlpha(230) // 0.9 * 255 = 229.5 ≈ 230
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(width / 2, height / 2), 40, iconCirclePaint);

      final Paint iconTrianglePaint = Paint()
        ..color = Colors.deepPurple.shade700
        ..style = PaintingStyle.fill;

      final Path trianglePath = Path();
      trianglePath.moveTo(width / 2 - 10 + 5, height / 2 - 20);
      trianglePath.lineTo(width / 2 + 25, height / 2);
      trianglePath.lineTo(width / 2 - 10 + 5, height / 2 + 20);
      trianglePath.close();
      canvas.drawPath(trianglePath, iconTrianglePaint);

      // 添加"视频"文字标签
      final TextSpan videoLabel = TextSpan(
        text: '视频',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 3,
              color: Colors.black.withAlpha(128), // 0.5 * 255 = 127.5 ≈ 128
            ),
          ],
        ),
      );

      final TextPainter labelPainter = TextPainter(
        text: videoLabel,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      labelPainter.layout();
      labelPainter.paint(canvas, Offset((width - labelPainter.width) / 2, height - 60));

      // 添加文件名
      final String displayName = fileName.length > 25 ? '${fileName.substring(0, 22)}...' : fileName;

      final TextSpan nameSpan = TextSpan(
        text: displayName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: Colors.black.withAlpha(179), // 0.7 * 255 = 178.5 ≈ 179
            ),
          ],
        ),
      );

      final TextPainter namePainter = TextPainter(
        text: nameSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: '...',
      );

      namePainter.layout(maxWidth: width - 40);

      // 绘制文件名背景
      final Rect nameBgRect = Rect.fromLTWH((width - namePainter.width) / 2 - 10, height - 40, namePainter.width + 20, namePainter.height + 8);

      final Paint nameBgPaint = Paint()
        ..color = Colors.black.withAlpha(128) // 0.5 * 255 = 127.5 ≈ 128
        ..style = PaintingStyle.fill;

      canvas.drawRRect(RRect.fromRectAndRadius(nameBgRect, const Radius.circular(4)), nameBgPaint);

      namePainter.paint(canvas, Offset((width - namePainter.width) / 2, height - 36));

      // 生成图像
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('无法创建默认缩略图');
      }

      // 将图像字节写入文件
      final File thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(byteData.buffer.asUint8List());

      _logClientProcess('默认视频缩略图创建成功: $thumbnailPath');
      return thumbnailFile;
    } catch (e) {
      _logClientProcess('创建默认缩略图失败: $e');
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

  /// 内部上传文件方法
  Future<UploadResult?> _uploadFile(File file, String subdirectory) async {
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

      // 模拟远程URL（实际应用中应该是服务器返回的URL）
      // 使用file://开头表示本地文件
      final remoteUrl = 'file://$localPath';

      return UploadResult(
        localPath: localPath,
        remoteUrl: remoteUrl,
      );
    } catch (e) {
      _logger.e('上传文件失败', error: e);
      return null;
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

  /// 记录服务器端日志
  void _logServerProcess(String message) {
    _logger.i('[服务器模拟] $message');
  }

  /// 记录客户端日志
  void _logClientProcess(String message) {
    _logger.i('[客户端] $message');
  }
}

/// 文件上传结果
class UploadResult {
  final String localPath;
  final String remoteUrl;
  final int? duration; // 语音文件使用
  final String? thumbnailPath; // 视频缩略图本地路径
  final String? thumbnailUrl; // 视频缩略图URL
  final bool serverProcessed; // 是否由服务器处理生成的缩略图

  UploadResult({
    required this.localPath,
    required this.remoteUrl,
    this.duration,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.serverProcessed = false, // 默认为客户端处理
  });
}
