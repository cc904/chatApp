import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/media_cache_service.dart';
import 'package:cc/core/utils/media_url_builder.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/features/chat/presentation/widgets/media_viewer.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 图片消息Widget
/// 支持网络图片、本地图片、加载状态、错误处理和点击查看
///
/// 实现逻辑：
/// 1. 先检查原始图片是否已在本地缓存
/// 2. 如果没有缓存，先显示缩略图（如果有）
/// 3. 同时在后台下载原始图片到本地
/// 4. 下载完成后替换为原始图片
///
/// 日志优化：
/// - 使用条件调试日志，仅在debug模式下输出
/// - 批量日志减少I/O操作
/// - 生产环境零调试日志开销
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
  final MediaUrlBuilder _mediaUrlBuilder = MediaUrlBuilder();

  // 加载状态
  bool _isLoading = true;
  bool _hasError = false;
  bool _isShowingThumbnail = false;
  bool _isDownloadingOriginal = false;

  // 图片信息
  ImageProvider? _imageProvider;

  // 实际的图片宽高比（从图片获取）
  double? _actualAspectRatio;

  /// 是否启用详细调试日志（仅在debug模式下）
  static bool get _isDebugLoggingEnabled => kDebugMode;

  /// Helper methods to extract image properties from message content JSON
  String? _getFsId() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['fs_id'] as String?;
  }

  String? _getMediaUrl() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['media_url'] as String?;
  }

  bool get _hasNewFileServerFields {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['hasNewFileServerFields'] as bool? ?? false;
  }

  int? _getWidth() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['width'] as int?;
  }

  int? _getHeight() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['height'] as int?;
  }

  String? _getCaption() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['caption'] as String?;
  }

  /// 详细调试日志（仅在debug模式下输出）
  void _debugLog(String message, {Map<String, dynamic>? extra}) {
    if (_isDebugLoggingEnabled) {
      _logger.d(message, extra: extra);
    }
  }

  /// 批量调试日志（避免频繁调用）
  void _batchDebugLog(List<String> messages, {Map<String, dynamic>? extra}) {
    if (_isDebugLoggingEnabled && messages.isNotEmpty) {
      _logger.d(messages.join(' | '), extra: extra);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  // URL构建现在通过异步方法处理，移除getter

  /// 初始化图片加载流程
  void _initializeImage() async {
    try {
      _debugLog('🖼️ 开始初始化图片加载流程', extra: {
        'messageId': widget.message.messageId,
        'messageType': widget.message.messageType,
        'messageContent': widget.message.content,
        'fsId': _getFsId(),
        'hasNewFields': _hasNewFileServerFields,
        'isCurrentUser': widget.isCurrentUser,
      });

      // 🆕 检查是否有直接的media_url
      final directMediaUrl = _getMediaUrl();
      if (directMediaUrl != null && directMediaUrl.isNotEmpty) {
        _debugLog('🖼️ 发现直接media_url，跳过缩略图加载', extra: {
          'directMediaUrl': directMediaUrl,
        });
        await _loadImageFromUrl(directMediaUrl);
        return;
      }

      // 使用新的MediaUrlBuilder构建URL
      final constructedFileUrl = await _mediaUrlBuilder.buildMainFileUrl(widget.message);
      final constructedThumbnailUrl = await _mediaUrlBuilder.buildThumbnailUrl(widget.message);

      _debugLog('🖼️ URL构建完成', extra: {
        'constructedFileUrl': constructedFileUrl,
        'constructedThumbnailUrl': constructedThumbnailUrl,
        'fsId': _getFsId(),
        'hasNewFields': _hasNewFileServerFields,
        'isCurrentUser': widget.isCurrentUser,
      });

      // 确保有构建的文件URL
      if (constructedFileUrl == null || constructedFileUrl.isEmpty) {
        _debugLog('🖼️ URL构建失败 - 缺少必要字段', extra: {
          'messageContent': widget.message.content,
          'fsId': _getFsId(),
        });
        throw Exception('无法构建图片URL - 缺少必要的文件服务器字段');
      }

      // 1. 检查原始图片是否已缓存
      final cachedImagePath = await _mediaCache.getCachedMediaPath(constructedFileUrl, 'images', messageDate: widget.message.createdAt);
      if (cachedImagePath != null) {
        _debugLog('🖼️ 使用缓存的原始图片');
        await _loadImageFromPath(cachedImagePath);
        return;
      }

      // 2. 原始图片未缓存，先尝试显示缩略图
      if (constructedThumbnailUrl != null && constructedThumbnailUrl.isNotEmpty) {
        _debugLog('🖼️ 原始图片未缓存，先显示缩略图');
        await _showThumbnailWhileDownloading(constructedThumbnailUrl, constructedFileUrl);
      } else {
        // 没有缩略图，直接显示加载状态并下载原始图片
        _debugLog('🖼️ 没有缩略图，直接下载原始图片');
        await _downloadOriginalImage(constructedFileUrl);
      }
    } catch (error) {
      _logger.e('🖼️ 图片初始化失败', error: error, extra: {
        'messageId': widget.message.messageId,
        'messageContent': widget.message.content,
      });
      _setError('图片初始化失败: $error');
    }
  }

  /// 显示缩略图的同时下载原始图片
  Future<void> _showThumbnailWhileDownloading(String thumbnailUrl, String originalUrl) async {
    try {
      // 先加载缩略图
      final thumbnailPath = await _mediaCache.getThumbnail(thumbnailUrl);
      if (thumbnailPath != null) {
        _debugLog('显示缩略图');
        setState(() {
          _isShowingThumbnail = true;
        });
        await _loadImageFromPath(thumbnailPath);
      }

      // 同时在后台下载原始图片
      _downloadOriginalImageInBackground(originalUrl);
    } catch (error) {
      _logger.e('显示缩略图失败', error: error);
      // 缩略图失败，直接下载原始图片
      await _downloadOriginalImage(originalUrl);
    }
  }

  /// 在后台下载原始图片
  void _downloadOriginalImageInBackground(String originalUrl) async {
    if (_isDownloadingOriginal) return;

    if (mounted) {
      setState(() {
        _isDownloadingOriginal = true;
      });
    }

    try {
      _debugLog('开始后台下载原始图片');
      final originalImagePath = await _mediaCache.getImage(originalUrl, messageDate: widget.message.createdAt);

      if (originalImagePath != null && mounted) {
        _debugLog('原始图片下载完成，替换缩略图');
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
  Future<void> _downloadOriginalImage(String originalUrl) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      _debugLog('直接下载原始图片');
      final originalImagePath = await _mediaCache.getImage(originalUrl, messageDate: widget.message.createdAt);

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
      _debugLog('从路径加载图片', extra: {'path': imagePath});

      if (kIsWeb) {
        // Web 平台：直接使用 NetworkImage
        setState(() {
          _imageProvider = NetworkImage(imagePath);
          _isLoading = false;
          _hasError = false;
        });
      } else {
        // 原生平台：使用 FileImage
        final file = File(imagePath);
        if (!file.existsSync()) {
          throw Exception('图片文件不存在: $imagePath');
        }

        setState(() {
          _imageProvider = FileImage(file);
          _isLoading = false;
          _hasError = false;
        });
      }

      // 预加载图片以获取尺寸信息
      _preloadImage();
    } catch (error) {
      _logger.e('从路径加载图片失败', error: error);
      _setError('图片加载失败: $error');
    }
  }

  /// 🆕 从URL直接加载图片（用于有media_url的情况）
  Future<void> _loadImageFromUrl(String imageUrl) async {
    try {
      _debugLog('从URL直接加载图片', extra: {'url': imageUrl});

      setState(() {
        _imageProvider = NetworkImage(imageUrl);
        _isLoading = false;
        _hasError = false;
      });

      // 预加载图片以获取尺寸信息
      _preloadImage();
    } catch (error) {
      _logger.e('从URL加载图片失败', error: error);
      _setError('图片加载失败: $error');
    }
  }

  /// 预加载图片
  void _preloadImage() {
    if (_imageProvider == null) return;

    final ImageStream stream = _imageProvider!.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (mounted) {
          // 计算实际的宽高比
          final actualRatio = info.image.width / info.image.height;

          // 如果消息中已有宽高信息，则不更新实际宽高比，避免布局跳动
          final hasMessageDimensions = _getWidth() != null && _getHeight() != null && _getWidth()! > 0 && _getHeight()! > 0;

          setState(() {
            // 只有在消息中没有宽高信息时才使用实际宽高比
            if (!hasMessageDimensions) {
              _actualAspectRatio = actualRatio;
            }
          });

          _batchDebugLog(['图片预加载完成', '实际比例: $actualRatio', '使用消息尺寸: $hasMessageDimensions', '显示缩略图: $_isShowingThumbnail']);
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
    if (_getWidth() != null && _getHeight() != null && _getWidth()! > 0 && _getHeight()! > 0) {
      final ratio = _getWidth()! / _getHeight()!;
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
    final hasCaption = _getCaption() != null && _getCaption()!.trim().isNotEmpty;

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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              _getCaption()!,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
