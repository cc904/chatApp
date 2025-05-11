import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/message_types.dart';

/// 全屏媒体浮窗查看器组件
/// 直接覆盖在当前页面上,无需导航到新页面
class MediaOverlayViewer extends StatefulWidget {
  final String? localPath; // 本地路径
  final String? mediaUrl; // 媒体URL
  final String mediaType; // 媒体类型
  final VoidCallback onClose; // 关闭回调
  final VoidCallback? onDelete; // 可选的删除回调

  const MediaOverlayViewer({
    super.key,
    this.localPath,
    this.mediaUrl,
    required this.mediaType,
    required this.onClose,
    this.onDelete,
  });

  /// 显示图片查看器
  static void show(
    BuildContext context, {
    String? imagePath,
    String? mediaUrl,
    String? videoPath,
    VoidCallback? onDelete,
  }) {
    // 保存BuildContext用于后续显示对话框
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = navigator.context;

    // 确定媒体类型
    final String mediaType;
    final String? localPath;

    if (videoPath != null) {
      mediaType = MessageType.video;
      localPath = videoPath;
    } else {
      mediaType = MessageType.image;
      localPath = imagePath;
    }

    // 创建一个overlay entry
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    // 定义何时显示确认对话框
    void showConfirmationDialog() {
      // 关闭预览
      entry.remove();

      // 使用根导航器的上下文显示对话框
      showDialog(
        context: rootContext,
        builder: (dialogContext) => AlertDialog(
          title: Text('删除${mediaType == MessageType.image ? '图片' : '视频'}'),
          content: Text('确定要删除这${mediaType == MessageType.image ? '张图片' : '个视频'}吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (onDelete != null) {
                  onDelete();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      );
    }

    entry = OverlayEntry(
      builder: (overlayContext) => MediaOverlayViewer(
        localPath: localPath,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        onClose: () {
          entry.remove();
        },
        onDelete: onDelete != null ? showConfirmationDialog : null,
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<MediaOverlayViewer> createState() => _MediaOverlayViewerState();
}

class _MediaOverlayViewerState extends State<MediaOverlayViewer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // 视频播放器控制器
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  final _logger = LogService.instance;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();

    // 初始化媒体
    _initMedia();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  Future<void> _initMedia() async {
    try {
      if (widget.mediaType == MessageType.video) {
        await _initVideoPlayer();
      } else {
        // 图片不需要特殊初始化,只需验证路径
        _validateImagePath();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '媒体加载失败: $e';
        _isLoading = false;
      });
      _logger.e('媒体加载失败', error: e);
    }
  }

  void _validateImagePath() {
    setState(() => _isLoading = false);

    try {
      if (widget.localPath != null) {
        final file = File(widget.localPath!);
        if (!file.existsSync()) {
          if (widget.mediaUrl == null || widget.mediaUrl!.isEmpty) {
            setState(() {
              _hasError = true;
              _errorMessage = '图片文件不存在';
            });
          }
        }
      } else if (widget.mediaUrl == null || widget.mediaUrl!.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = '没有可用的图片源';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '验证图片路径失败: $e';
      });
    }
  }

  // 初始化视频播放器
  Future<void> _initVideoPlayer() async {
    try {
      String? effectivePath;

      // 确定有效路径
      if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        effectivePath = widget.localPath;
      } else if (widget.mediaUrl != null && widget.mediaUrl!.startsWith('file://')) {
        effectivePath = widget.mediaUrl!.substring(7);
      }

      // 创建视频控制器
      if (effectivePath != null) {
        final file = File(effectivePath);
        if (file.existsSync()) {
          _videoController = VideoPlayerController.file(file);
          _logger.i('浮窗使用本地文件初始化视频', extra: {'path': file.path});
        } else {
          _logger.i('浮窗视频文件不存在', extra: {'path': effectivePath});
          if (widget.mediaUrl != null && !widget.mediaUrl!.startsWith('file://')) {
            _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!));
            _logger.i('浮窗回退使用网络URL初始化视频', extra: {'url': widget.mediaUrl});
          } else {
            throw Exception('未找到有效的视频文件');
          }
        }
      } else if (widget.mediaUrl != null && !widget.mediaUrl!.startsWith('file://')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!));
        _logger.i('浮窗使用网络URL初始化视频', extra: {'url': widget.mediaUrl});
      } else {
        throw Exception('未找到有效的视频文件');
      }

      // 初始化视频控制器
      await _videoController!.initialize();
      _logger.i('浮窗视频播放器初始化成功');

      if (!mounted) return;

      // 创建Chewie控制器
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControlsOnInitialize: false,
        allowFullScreen: false,
        aspectRatio: _videoController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.white, size: 42),
              const SizedBox(height: 16),
              Text(
                '视频加载失败: $errorMessage',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = '视频初始化失败: $e';
          _isLoading = false;
        });
      }
      _logger.e('浮窗视频初始化失败', error: e);
    }
  }

  // 分享媒体
  Future<void> _shareMedia() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      String? filePath;
      if (widget.localPath != null && File(widget.localPath!).existsSync()) {
        filePath = widget.localPath;
      } else if (widget.mediaUrl != null && widget.mediaUrl!.startsWith('file://')) {
        final file = File(widget.mediaUrl!.substring(7));
        if (file.existsSync()) {
          filePath = file.path;
        }
      }

      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '分享${widget.mediaType == MessageType.image ? '图片' : '视频'}',
        );
      } else {
        UINotificationService().showError('无法分享：找不到有效的文件');
      }
    } catch (e) {
      UINotificationService().showError('分享失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 关闭查看器
  void _closeViewer() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  // 处理删除操作
  void _handleDelete() {
    _animationController.reverse().then((_) {
      if (widget.onDelete != null) {
        widget.onDelete!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _closeViewer();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black.withAlpha(230),
            body: SafeArea(
              child: Stack(
                children: [
                  // 媒体内容
                  Center(
                    child: _buildMediaContent(),
                  ),

                  // 顶部操作栏
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withAlpha(128),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _closeViewer,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.white),
                                onPressed: _shareMedia,
                              ),
                              if (widget.onDelete != null)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: _handleDelete,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 加载指示器
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (widget.mediaType == MessageType.video) {
      if (_chewieController != null) {
        return Chewie(controller: _chewieController!);
      } else {
        return const Text('无法加载视频播放器', style: TextStyle(color: Colors.white));
      }
    } else {
      // 图片查看器
      return _buildImageViewer();
    }
  }

  Widget _buildImageViewer() {
    ImageProvider? imageProvider;

    try {
      if (widget.localPath != null) {
        final file = File(widget.localPath!);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
          _logger.i('浮窗使用本地文件显示图片', extra: {'path': file.path});
        }
      }

      if (imageProvider == null && widget.mediaUrl != null) {
        if (widget.mediaUrl!.startsWith('http')) {
          imageProvider = NetworkImage(widget.mediaUrl!);
          _logger.i('浮窗使用网络URL显示图片', extra: {'url': widget.mediaUrl});
        } else if (widget.mediaUrl!.startsWith('file://')) {
          final file = File(widget.mediaUrl!.substring(7));
          if (file.existsSync()) {
            imageProvider = FileImage(file);
            _logger.i('浮窗使用file://路径显示图片', extra: {'path': file.path});
          }
        }
      }

      if (imageProvider == null) {
        _logger.e('浮窗无法加载图片', extra: {'localPath': widget.localPath, 'mediaUrl': widget.mediaUrl});
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text('无法加载图片', style: TextStyle(color: Colors.white)),
          ],
        );
      }

      return PhotoView(
        imageProvider: imageProvider,
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 3.0,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 64, color: Colors.white),
              SizedBox(height: 16),
              Text('图片加载失败', style: TextStyle(color: Colors.white)),
            ],
          );
        },
      );
    } catch (e) {
      _logger.e('构建图片查看器失败', error: e);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text('图片加载失败: $e', style: const TextStyle(color: Colors.white)),
        ],
      );
    }
  }
}
