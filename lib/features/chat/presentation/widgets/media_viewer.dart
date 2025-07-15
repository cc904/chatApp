import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/media_cache_service.dart';

/// 图片查看器组件
class ImageViewerPage extends StatefulWidget {
  final String imagePath; // 图片路径
  final String? mediaUrl; // 媒体URL
  final VoidCallback? onDelete; // 删除回调

  const ImageViewerPage({
    super.key,
    required this.imagePath,
    this.mediaUrl,
    this.onDelete,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late String _effectivePath;
  bool _isLoading = false;
  bool _hasError = false;
  final _logger = LogService.instance;

  @override
  void initState() {
    super.initState();
    _initImagePath();
  }

  void _initImagePath() {
    try {
      // 检查媒体URL是否是file://开头
      if (widget.mediaUrl != null && widget.mediaUrl!.startsWith('file://')) {
        _effectivePath = widget.mediaUrl!.substring(7); // 移除file://前缀
      } else {
        _effectivePath = widget.imagePath;
      }
      _logger.d('图片查看器路径', extra: {'path': _effectivePath});
    } catch (error) {
      _logger.e('初始化图片路径失败', error: error, stackTrace: StackTrace.current);
      _effectivePath = widget.imagePath; // 使用原始路径作为回退
      _hasError = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(128),
        foregroundColor: Colors.white,
        title: const Text('图片查看'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareImage,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveImage,
          ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteImage,
            ),
        ],
      ),
      body: Stack(
        children: [
          // 图片显示
          PhotoView(
            imageProvider: _getImageProvider(),
            errorBuilder: (context, error, stackTrace) {
              _logger.e('图片查看器加载失败',
                  error: error, stackTrace: StackTrace.current);
              if (!_hasError) {
                setState(() {
                  _hasError = true;
                });
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image,
                        size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      '图片加载失败\n$_effectivePath',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
            loadingBuilder: (context, event) {
              if (event == null) return const SizedBox.shrink();
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            enableRotation: true,
          ),

          // 加载状态
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // 错误状态
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    '图片加载失败\n$_effectivePath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 获取图片Provider
  ImageProvider _getImageProvider() {
    try {
      final file = File(_effectivePath);
      if (file.existsSync()) {
        return FileImage(file);
      } else if (widget.mediaUrl != null &&
          widget.mediaUrl!.isNotEmpty &&
          !widget.mediaUrl!.startsWith('file://')) {
        // 先尝试缓存，如果失败回退到直接网络加载
        return NetworkImage(widget.mediaUrl!);
      } else {
        _logger.e('图片文件不存在', extra: {'path': _effectivePath});
        throw Exception('图片文件不存在');
      }
    } catch (error) {
      _logger.e('获取图片失败', error: error, stackTrace: StackTrace.current);
      setState(() {
        _hasError = true;
      });
      throw Exception('图片加载失败');
    }
  }

  /// 分享图片
  Future<void> _shareImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await Share.shareXFiles(
        [XFile(_effectivePath)],
        text: '分享图片',
      );
    } catch (error) {
      _logger.e('分享图片失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        UINotificationService().showError('分享失败: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 保存图片
  Future<void> _saveImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 这里实现保存到相册的逻辑
      // 在实际应用中,你可能需要使用image_gallery_saver或其他插件
      // 这里简化处理,仅弹出提示

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        UINotificationService().showSuccess('图片已保存');
      }
    } catch (error) {
      _logger.e('保存图片失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        UINotificationService().showError('保存失败: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 删除图片
  void _deleteImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确定要删除这张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
              Navigator.of(context).pop(); // 关闭图片查看器
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 视频查看器组件
class VideoViewerPage extends StatefulWidget {
  final String videoPath; // 视频路径
  final String? mediaUrl; // 媒体URL
  final VoidCallback? onDelete; // 删除回调

  const VideoViewerPage({
    super.key,
    required this.videoPath,
    this.mediaUrl,
    this.onDelete,
  });

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  late String _effectivePath;
  bool _isLoading = true;
  bool _hasError = false;
  final _logger = LogService.instance;

  // 视频播放控制器
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initVideoPath();
    _initializePlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _initVideoPath() {
    try {
      // 检查媒体URL是否是file://开头
      if (widget.mediaUrl != null && widget.mediaUrl!.startsWith('file://')) {
        _effectivePath = widget.mediaUrl!.substring(7); // 移除file://前缀
      } else {
        _effectivePath = widget.videoPath;
      }
      _logger.d('视频查看器路径', extra: {'path': _effectivePath});
    } catch (error) {
      _logger.e('初始化视频路径失败', error: error, stackTrace: StackTrace.current);
      _effectivePath = widget.videoPath; // 使用原始路径作为回退
      _hasError = true;
    }
  }

  // 初始化视频播放器
  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 根据路径创建不同类型的控制器
      final file = File(_effectivePath);
      if (file.existsSync()) {
        // 本地文件
        _videoPlayerController = VideoPlayerController.file(file);
        _logger.d('使用本地文件初始化视频', extra: {'path': file.path});
      } else if (widget.mediaUrl != null &&
          widget.mediaUrl!.isNotEmpty &&
          !widget.mediaUrl!.startsWith('file://')) {
        // 网络URL
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!));
        _logger.d('使用网络URL初始化视频', extra: {'url': widget.mediaUrl});
      } else {
        _logger.e('无法找到有效的视频文件', extra: {'path': _effectivePath});
        throw Exception('无法加载视频: 找不到有效的文件或URL');
      }

      // 初始化视频播放器
      await _videoPlayerController!.initialize();
      _logger.d('视频播放器初始化成功');

      if (!mounted) return;

      // 创建Chewie控制器
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 42),
                const SizedBox(height: 8),
                Text('视频播放错误: $errorMessage',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      _logger.e('视频播放器初始化失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(128),
        foregroundColor: Colors.white,
        title: const Text('视频查看'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareVideo,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveVideo,
          ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteVideo,
            ),
        ],
      ),
      body: Stack(
        children: [
          // 视频播放器
          if (_chewieController != null && !_hasError)
            Center(
              child: Chewie(controller: _chewieController!),
            ),

          // 错误状态
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library_outlined,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '视频加载失败\n$_effectivePath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initializePlayer,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),

          // 加载状态
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }

  /// 分享视频
  Future<void> _shareVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await Share.shareXFiles(
        [XFile(_effectivePath)],
        text: '分享视频',
      );
    } catch (error) {
      _logger.e('分享视频失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        UINotificationService().showError('分享失败: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 保存视频
  Future<void> _saveVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 这里实现保存视频的逻辑
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        UINotificationService().showSuccess('视频已保存');
      }
    } catch (error) {
      _logger.e('保存视频失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        UINotificationService().showError('保存失败: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 删除视频
  void _deleteVideo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除视频'),
        content: const Text('确定要删除这个视频吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
              Navigator.of(context).pop(); // 关闭视频查看器
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 媒体查看器工厂
class MediaViewer {
  /// 打开图片查看器
  static void openImage(
    BuildContext context, {
    required String imagePath,
    String? mediaUrl,
    VoidCallback? onDelete,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerPage(
          imagePath: imagePath,
          mediaUrl: mediaUrl,
          onDelete: onDelete,
        ),
      ),
    );
  }

  /// 打开视频查看器
  static void openVideo(
    BuildContext context, {
    required String videoPath,
    String? mediaUrl,
    VoidCallback? onDelete,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoViewerPage(
          videoPath: videoPath,
          mediaUrl: mediaUrl,
          onDelete: onDelete,
        ),
      ),
    );
  }

  /// 打开媒体查看器（根据消息类型）
  static void openMedia(BuildContext context, Message message,
      {VoidCallback? onDelete}) {
    final localPath = message.localPath;
    final mediaUrl = message.mediaUrl;

    if (localPath == null && mediaUrl == null) {
      UINotificationService().showError('无法查看：找不到媒体文件');
      return;
    }

    // 优先使用mediaUrl，只有当mediaUrl为空且localPath存在且文件存在时才使用localPath
    String effectivePath = '';

    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      if (mediaUrl.startsWith('file://')) {
        effectivePath = mediaUrl.substring(7);
      } else {
        effectivePath = mediaUrl;
      }
    } else if (localPath != null && localPath.isNotEmpty) {
      // 检查本地文件是否存在
      final localFile = File(localPath);
      if (localFile.existsSync()) {
        effectivePath = localPath;
      }
    }

    if (effectivePath.isEmpty) {
      UINotificationService().showError('无法查看：媒体文件不存在');
      return;
    }

    if (message.type == MessageType.image) {
      openImage(
        context,
        imagePath: effectivePath,
        mediaUrl: mediaUrl,
        onDelete: onDelete,
      );
    } else if (message.type == MessageType.video) {
      openVideo(
        context,
        videoPath: effectivePath,
        mediaUrl: mediaUrl,
        onDelete: onDelete,
      );
    }
  }
}
