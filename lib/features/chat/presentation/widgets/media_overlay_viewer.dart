import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cc/core/database/models/message.dart';
import 'dart:developer' as dev;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';

/// 全屏媒体浮窗查看器组件
/// 直接覆盖在当前页面上，无需导航到新页面
class MediaOverlayViewer extends StatefulWidget {
  final String? localPath; // 本地路径
  final String? mediaUrl; // 媒体URL
  final MessageType mediaType; // 媒体类型
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
    final MessageType mediaType;
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
        // 图片不需要特殊初始化，只需验证路径
        _validateImagePath();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '媒体加载失败: $e';
        _isLoading = false;
      });
      dev.log('媒体加载失败: $e');
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

  Future<void> _initVideoPlayer() async {
    try {
      if (widget.localPath != null) {
        final file = File(widget.localPath!);
        if (file.existsSync()) {
          _videoController = VideoPlayerController.file(file);
        } else if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
          if (widget.mediaUrl!.startsWith('http')) {
            _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!));
          } else if (widget.mediaUrl!.startsWith('file://')) {
            final videoFile = File(widget.mediaUrl!.substring(7));
            _videoController = VideoPlayerController.file(videoFile);
          }
        }
      } else if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) {
        if (widget.mediaUrl!.startsWith('http')) {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!));
        } else if (widget.mediaUrl!.startsWith('file://')) {
          final videoFile = File(widget.mediaUrl!.substring(7));
          _videoController = VideoPlayerController.file(videoFile);
        }
      }

      if (_videoController == null) {
        throw Exception('无法创建视频控制器：没有有效的视频源');
      }

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: true,
        allowFullScreen: false,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
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
            ),
          );
        },
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '视频初始化失败: $e';
        _isLoading = false;
      });
      dev.log('视频初始化失败: $e');
    }
  }

  // 分享媒体
  Future<void> _shareMedia() async {
    try {
      setState(() => _isLoading = true);

      String? filePath;
      if (widget.localPath != null && File(widget.localPath!).existsSync()) {
        filePath = widget.localPath;
      } else if (widget.mediaUrl != null && widget.mediaUrl!.startsWith('file://')) {
        filePath = widget.mediaUrl!.substring(7);
      }

      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '分享${widget.mediaType == MessageType.image ? '图片' : '视频'}',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法分享：找不到有效的文件')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败: $e')),
      );
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
        child: WillPopScope(
          onWillPop: () async {
            _closeViewer();
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.9),
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
                      color: Colors.black.withOpacity(0.5),
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
        }
      }

      if (imageProvider == null && widget.mediaUrl != null) {
        if (widget.mediaUrl!.startsWith('http')) {
          imageProvider = NetworkImage(widget.mediaUrl!);
        } else if (widget.mediaUrl!.startsWith('file://')) {
          final file = File(widget.mediaUrl!.substring(7));
          if (file.existsSync()) {
            imageProvider = FileImage(file);
          }
        }
      }

      if (imageProvider == null) {
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
      dev.log('构建图片查看器失败: $e');
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
