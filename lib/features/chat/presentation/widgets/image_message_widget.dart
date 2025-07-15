import 'package:flutter/material.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/media_cache_service.dart';
import 'package:cc/features/chat/presentation/widgets/media_viewer.dart';
import 'dart:io';

/// 图片消息Widget
/// 支持网络图片、本地图片、加载状态、错误处理和点击查看
///
/// 实现逻辑：
/// 1. 先检查原始图片是否已在本地缓存
/// 2. 如果没有缓存，先显示缩略图（如果有）
/// 3. 同时在后台下载原始图片到本地
/// 4. 下载完成后替换为原始图片
class ImageMessageWidget extends StatefulWidget {
  final Message message;
  final bool isCurrentUser;
  final double? maxWidth;
  final double? maxHeight;

  const ImageMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<ImageMessageWidget> createState() => _ImageMessageWidgetState();
}

class _ImageMessageWidgetState extends State<ImageMessageWidget> {
  final LogService _logger = LogService.instance;
  final MediaCacheService _mediaCache = MediaCacheService();

  // 加载状态
  bool _isLoading = true;
  bool _hasError = false;
  bool _isShowingThumbnail = false;
  bool _isDownloadingOriginal = false;

  // 图片信息
  ImageProvider? _imageProvider;

  // 实际的图片宽高比（从图片获取）
  double? _actualAspectRatio;

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  /// 初始化图片加载流程
  void _initializeImage() async {
    try {
      _logger.d('开始初始化图片', extra: {
        'mediaUrl': widget.message.mediaUrl,
        'localPath': widget.message.localPath,
        'thumbnailUrl': widget.message.thumbnailUrl,
        'isCurrentUser': widget.isCurrentUser,
      });

      // 1. 检查是否有网络图片URL
      if (widget.message.mediaUrl != null &&
          widget.message.mediaUrl!.isNotEmpty) {
        // 1.1 检查原始图片是否已缓存
        final cachedImagePath = await _mediaCache.getCachedMediaPath(
            widget.message.mediaUrl!, 'images', messageDate: widget.message.createdAt);
        if (cachedImagePath != null) {
          _logger.d('使用缓存的原始图片');
          await _loadImageFromPath(cachedImagePath);
          return;
        }

        // 1.2 原始图片未缓存，先尝试显示缩略图
        if (widget.message.thumbnailUrl != null &&
            widget.message.thumbnailUrl!.isNotEmpty) {
          _logger.d('原始图片未缓存，先显示缩略图');
          await _showThumbnailWhileDownloading();
        } else {
          // 没有缩略图，直接显示加载状态并下载原始图片
          _logger.d('没有缩略图，直接下载原始图片');
          await _downloadOriginalImage();
        }
        return;
      }

      // 2. 如果都没有，显示错误
      throw Exception('没有可用的图片路径');
    } catch (error) {
      _logger.e('图片初始化失败', error: error);
      _setError('图片初始化失败: $error');
    }
  }

  /// 显示缩略图的同时下载原始图片
  Future<void> _showThumbnailWhileDownloading() async {
    try {
      // 先加载缩略图
      final thumbnailPath =
          await _mediaCache.getThumbnail(widget.message.thumbnailUrl!);
      if (thumbnailPath != null) {
        _logger.d('显示缩略图');
        setState(() {
          _isShowingThumbnail = true;
        });
        await _loadImageFromPath(thumbnailPath);
      }

      // 同时在后台下载原始图片
      _downloadOriginalImageInBackground();
    } catch (error) {
      _logger.e('显示缩略图失败', error: error);
      // 缩略图失败，直接下载原始图片
      await _downloadOriginalImage();
    }
  }

  /// 在后台下载原始图片
  void _downloadOriginalImageInBackground() async {
    if (_isDownloadingOriginal) return;

    if (mounted) {
      setState(() {
        _isDownloadingOriginal = true;
      });
    }

    try {
      _logger.d('开始后台下载原始图片');
      final originalImagePath =
          await _mediaCache.getImage(widget.message.mediaUrl!, messageDate: widget.message.createdAt);

      if (originalImagePath != null && mounted) {
        _logger.d('原始图片下载完成，替换缩略图');
        setState(() {
          _isShowingThumbnail = false;
        });
        await _loadImageFromPath(originalImagePath);
      }
    } catch (error) {
      _logger.e('后台下载原始图片失败', error: error);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingOriginal = false;
        });
      }
    }
  }

  /// 直接下载原始图片
  Future<void> _downloadOriginalImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      _logger.d('直接下载原始图片');
      final originalImagePath =
          await _mediaCache.getImage(widget.message.mediaUrl!, messageDate: widget.message.createdAt);

      if (originalImagePath != null) {
        await _loadImageFromPath(originalImagePath);
      } else {
        throw Exception('图片下载失败');
      }
    } catch (error) {
      _logger.e('下载原始图片失败', error: error);
      _setError('图片下载失败: $error');
    }
  }

  /// 从指定路径加载图片
  Future<void> _loadImageFromPath(String imagePath) async {
    try {
      _logger.d('从路径加载图片', extra: {'path': imagePath});

      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('图片文件不存在: $imagePath');
      }

      setState(() {
        _imageProvider = FileImage(file);
        _isLoading = false;
        _hasError = false;
      });

      // 预加载图片以获取尺寸信息
      _preloadImage();
    } catch (error) {
      _logger.e('从路径加载图片失败', error: error);
      _setError('图片加载失败: $error');
    }
  }

  /// 预加载图片
  void _preloadImage() {
    if (_imageProvider == null) return;

    final ImageStream stream =
        _imageProvider!.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (mounted) {
          // 计算实际的宽高比
          final actualRatio = info.image.width / info.image.height;

          // 如果消息中已有宽高信息，则不更新实际宽高比，避免布局跳动
          final hasMessageDimensions = widget.message.width != null &&
              widget.message.height != null &&
              widget.message.width! > 0 &&
              widget.message.height! > 0;

          setState(() {
            // 只有在消息中没有宽高信息时才使用实际宽高比
            if (!hasMessageDimensions) {
              _actualAspectRatio = actualRatio;
            }
          });

          _logger.d('图片预加载完成', extra: {
            'actualRatio': actualRatio,
            'hasMessageDimensions': hasMessageDimensions,
            'isShowingThumbnail': _isShowingThumbnail,
          });
        }
        stream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        if (mounted) {
          _logger.e('图片预加载失败', error: exception);
          _setError('图片预加载失败: $exception');
        }
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
  }

  /// 设置错误状态
  void _setError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  /// 计算图片宽高比
  double _calculateAspectRatio() {
    // 1. 优先使用消息中保存的宽高信息（避免布局跳动）
    if (widget.message.width != null &&
        widget.message.height != null &&
        widget.message.width! > 0 &&
        widget.message.height! > 0) {
      final ratio = widget.message.width! / widget.message.height!;
      return ratio;
    }

    // 2. 如果图片已加载且消息中没有宽高信息，使用实际宽高比
    if (_actualAspectRatio != null && _actualAspectRatio! > 0) {
      return _actualAspectRatio!;
    }

    // 3. 默认比例
    return 1.33; // 4:3 比例
  }

  /// 处理图片点击
  void _onImageTap() {
    try {
      MediaViewer.openMedia(context, widget.message);
    } catch (error) {
      _logger.e('打开图片查看器失败', error: error);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法打开图片: $error'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 重试加载
  void _retryLoad() {
    _logger.i('用户点击重试按钮');
    setState(() {
      _hasError = false;
      _isLoading = true;
      _imageProvider = null;
      _isShowingThumbnail = false;
      _isDownloadingOriginal = false;
    });
    _initializeImage();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = widget.maxWidth ?? screenSize.width * 0.6;
    final maxHeight = widget.maxHeight ?? screenSize.height * 0.4;

    // 检查是否有caption文字
    final hasCaption = widget.message.caption != null &&
        widget.message.caption!.trim().isNotEmpty;

    if (hasCaption) {
      // 图片 + 文字组合形式
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片部分
          Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              minWidth: 120.0,
              minHeight: 80.0,
            ),
            child: AspectRatio(
              aspectRatio: _calculateAspectRatio(),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
                child: InkWell(
                  onTap: _hasError ? _retryLoad : _onImageTap,
                  borderRadius: BorderRadius.circular(8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                    ),
                    child: Stack(
                      children: [
                        _buildImageContent(),
                        // 显示下载进度指示器
                        if (_isDownloadingOriginal && _isShowingThumbnail)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(128),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 文字说明部分
          const SizedBox(height: 6),
          Container(
            width: maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              widget.message.caption!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      );
    } else {
      // 纯图片形式
      return Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minWidth: 120.0,
          minHeight: 80.0,
        ),
        child: AspectRatio(
          aspectRatio: _calculateAspectRatio(),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              onTap: _hasError ? _retryLoad : _onImageTap,
              borderRadius: BorderRadius.circular(8.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
                child: Stack(
                  children: [
                    _buildImageContent(),
                    // 显示下载进度指示器
                    if (_isDownloadingOriginal && _isShowingThumbnail)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(128),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  /// 构建图片内容
  Widget _buildImageContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_imageProvider == null) {
      return _buildErrorWidget();
    }

    return Image(
      image: _imageProvider!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        _logger.e('图片显示失败', error: error);
        return _buildErrorWidget();
      },
    );
  }

  /// 构建加载状态Widget
  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 构建错误状态Widget
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.refresh,
          color: Colors.grey[600],
          size: 32,
        ),
      ),
    );
  }
}
