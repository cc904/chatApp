import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/utils/media_url_builder.dart';

/// Web平台图片查看器组件
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
      print('Web图片查看器初始化:');
      print('  widget.imagePath: ${widget.imagePath}');
      print('  widget.mediaUrl: ${widget.mediaUrl}');
      
      // Web平台优先使用mediaUrl，支持所有URL格式
      if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
        _effectivePath = widget.mediaUrl!;
        print('  使用mediaUrl: $_effectivePath');
      } else {
        _effectivePath = widget.imagePath;
        print('  使用imagePath: $_effectivePath');
      }
      
      _logger.d('Web图片查看器路径', extra: {'path': _effectivePath});
    } catch (error) {
      _logger.e('初始化图片路径失败', error: error, stackTrace: StackTrace.current);
      _effectivePath = widget.imagePath;
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
              _logger.e('图片查看器加载失败', error: error, stackTrace: StackTrace.current);
              if (!_hasError) {
                setState(() {
                  _hasError = true;
                });
              }
              return Center(
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

  /// 获取图片Provider - Web平台版本
  ImageProvider _getImageProvider() {
    try {
      print('Web ImageProvider Debug:');
      print('  _effectivePath: $_effectivePath');
      print('  widget.mediaUrl: ${widget.mediaUrl}');
      
      // Web平台支持多种URL格式
      if (_effectivePath.startsWith('http') || _effectivePath.startsWith('https')) {
        print('  使用HTTP/HTTPS URL');
        return NetworkImage(_effectivePath);
      } else if (_effectivePath.startsWith('blob:')) {
        print('  使用Blob URL');
        return NetworkImage(_effectivePath);
      } else if (_effectivePath.startsWith('file://')) {
        print('  处理file:// URL');
        return NetworkImage(_effectivePath);
      } else if (_effectivePath.startsWith('data:')) {
        print('  使用Data URL');
        return NetworkImage(_effectivePath);
      } else if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
        print('  回退到widget.mediaUrl: ${widget.mediaUrl}');
        return NetworkImage(widget.mediaUrl!);
      } else {
        print('  尝试将路径作为URL: $_effectivePath');
        // 尝试将路径直接作为URL使用
        return NetworkImage(_effectivePath);
      }
    } catch (error) {
      _logger.e('获取图片失败', error: error, stackTrace: StackTrace.current);
      setState(() {
        _hasError = true;
      });
      throw Exception('图片加载失败: $error');
    }
  }

  /// 分享图片 - Web版本
  Future<void> _shareImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
        await Share.share(widget.mediaUrl!, subject: '分享图片');
      } else {
        UINotificationService().showError('Web平台不支持分享本地文件');
      }
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

  /// 保存图片 - Web版本
  Future<void> _saveImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Web平台提示用户手动保存
      UINotificationService().showInfo('Web平台请右键图片选择"图片另存为"');
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

/// Web平台视频查看器组件
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
      // Web平台优先使用网络URL
      if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
        if (widget.mediaUrl!.startsWith('file://')) {
          _effectivePath = widget.mediaUrl!; // Web平台保持file://前缀
        } else {
          _effectivePath = widget.mediaUrl!;
        }
      } else {
        _effectivePath = widget.videoPath;
      }
      _logger.d('Web视频查看器路径', extra: {'path': _effectivePath});
    } catch (error) {
      _logger.e('初始化视频路径失败', error: error, stackTrace: StackTrace.current);
      _effectivePath = widget.videoPath;
      _hasError = true;
    }
  }

  // 初始化视频播放器 - Web版本
  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Web平台只使用网络URL
      if (_effectivePath.startsWith('http') || _effectivePath.startsWith('https')) {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_effectivePath));
        _logger.d('Web使用网络URL初始化视频', extra: {'url': _effectivePath});
      } else if (_effectivePath.startsWith('file://')) {
        // Web平台的file://URL可能是blob URL
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_effectivePath));
        _logger.d('Web使用file URL初始化视频', extra: {'url': _effectivePath});
      } else if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!));
        _logger.d('Web使用mediaUrl初始化视频', extra: {'url': widget.mediaUrl});
      } else {
        _logger.e('Web平台无法找到有效的视频URL', extra: {'path': _effectivePath});
        throw Exception('Web平台无法访问本地视频文件');
      }

      // 初始化视频播放器
      await _videoPlayerController!.initialize();
      _logger.d('Web视频播放器初始化成功');

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
                Text('视频播放错误: $errorMessage', style: const TextStyle(color: Colors.white)),
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
      _logger.e('Web视频播放器初始化失败', error: error, stackTrace: StackTrace.current);
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
                  const Icon(Icons.video_library_outlined, size: 64, color: Colors.red),
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

  /// 分享视频 - Web版本
  Future<void> _shareVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
        await Share.share(widget.mediaUrl!, subject: '分享视频');
      } else {
        UINotificationService().showError('Web平台不支持分享本地文件');
      }
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

  /// 保存视频 - Web版本
  Future<void> _saveVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Web平台提示用户手动保存
      UINotificationService().showInfo('Web平台请右键视频选择"视频另存为"');
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

/// Web平台媒体查看器工厂
class MediaViewer {
  /// Helper methods to extract media properties from message content JSON
  static String? _getLocalPath(Message message) {
    final mediaInfo = MessageAdapter.extractMediaInfo(message.content);
    return mediaInfo?['local_path'] as String?;
  }

  static String? _getMediaUrl(Message message) {
    final mediaInfo = MessageAdapter.extractMediaInfo(message.content);
    return mediaInfo?['media_url'] as String? ?? mediaInfo?['url'] as String? ?? mediaInfo?['fileUrl'] as String?;
  }

  /// 获取图片的有效URL - 与ImageMessageWidget保持一致的逻辑
  static Future<String?> _getEffectiveImageUrl(Message message) async {
    try {
      // 1. 首先检查是否有直接的media_url
      final directMediaUrl = _getMediaUrl(message);
      if (directMediaUrl != null && directMediaUrl.isNotEmpty) {
        print('  找到直接media_url: $directMediaUrl');
        return directMediaUrl;
      }

      // 2. 使用MediaUrlBuilder构建URL（与ImageMessageWidget相同的逻辑）
      final mediaUrlBuilder = MediaUrlBuilder();
      final constructedFileUrl = await mediaUrlBuilder.buildMainFileUrl(message);
      
      if (constructedFileUrl != null && constructedFileUrl.isNotEmpty) {
        print('  构建的文件URL: $constructedFileUrl');
        return constructedFileUrl;
      }

      // 3. 最后尝试local_path
      final localPath = _getLocalPath(message);
      if (localPath != null && localPath.isNotEmpty) {
        print('  使用local_path: $localPath');
        return localPath;
      }

      return null;
    } catch (error) {
      print('  获取有效URL失败: $error');
      return null;
    }
  }

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

  /// 打开媒体查看器（根据消息类型）- Web版本
  static void openMedia(BuildContext context, Message message, {VoidCallback? onDelete}) async {
    if (!context.mounted) return;
    
    try {
      final localPath = _getLocalPath(message);
      final mediaUrl = _getMediaUrl(message);

      // 使用与ImageMessageWidget相同的逻辑获取有效URL
      final effectivePath = await _getEffectiveImageUrl(message);

      if (effectivePath == null || effectivePath.isEmpty) {
        if (context.mounted) {
          UINotificationService().showError('无法查看：找不到媒体文件');
        }
        return;
      }

      if (message.messageType == 'IMAGE') {
        if (context.mounted) {
          openImage(
            context,
            imagePath: effectivePath,
            mediaUrl: mediaUrl,
            onDelete: onDelete,
          );
        }
      } else if (message.messageType == 'VIDEO') {
        if (context.mounted) {
          openVideo(
            context,
            videoPath: effectivePath,
            mediaUrl: mediaUrl,
            onDelete: onDelete,
          );
        }
      } else {
        if (context.mounted) {
          UINotificationService().showError('不支持的媒体类型: ${message.messageType}');
        }
      }
    } catch (error) {
      if (context.mounted) {
        UINotificationService().showError('打开媒体查看器失败: $error');
      }
    }
  }
}
