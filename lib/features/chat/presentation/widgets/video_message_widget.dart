import 'package:flutter/material.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/thumbnail_cache_service.dart';
import 'package:cc/core/utils/media_url_builder.dart';
import 'package:cc/features/chat/presentation/widgets/media_viewer.dart';
import 'dart:io';

/// 视频消息Widget
/// 支持网络视频、本地视频、缩略图显示、播放按钮和点击查看
class VideoMessageWidget extends StatefulWidget {
  final Message message;
  final bool isCurrentUser;
  final double? maxWidth;
  final double? maxHeight;

  const VideoMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  final LogService _logger = LogService.instance;
  final ThumbnailCacheService _thumbnailCache = ThumbnailCacheService();
  final MediaUrlBuilder _mediaUrlBuilder = MediaUrlBuilder();

  // 加载状态
  bool _isLoading = true;
  bool _hasError = false;

  // 缩略图信息
  ImageProvider? _thumbnailProvider;
  String? _effectiveThumbnailPath;

  // 实际的缩略图宽高比（从图片获取）
  double? _actualAspectRatio;

  /// Helper methods to extract video properties from message content JSON
  String? _getLocalPath() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['local_path'] as String?;
  }

  String? _getMediaUrl() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['media_url'] as String? ?? 
           mediaInfo?['url'] as String? ?? 
           mediaInfo?['fileUrl'] as String?;
  }

  String? _getThumbnailUrl() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['thumbnailUrl'] as String? ?? 
           mediaInfo?['thumbnail'] as String?;
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

  int? _getDuration() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['duration'] as int?;
  }

  String? _getCaption() {
    final mediaInfo = MessageAdapter.extractMediaInfo(widget.message.content);
    return mediaInfo?['caption'] as String?;
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }


  /// 初始化视频
  void _initializeVideo() {
    try {
      // 检查是否有有效的视频路径
      if ((_getLocalPath() == null || _getLocalPath()!.isEmpty) &&
          (_getMediaUrl() == null || _getMediaUrl()!.isEmpty)) {
        throw Exception('视频路径为空');
      }

      // 尝试获取缩略图URL
      _loadThumbnailUrl();

    } catch (error) {
      _logger.e('视频初始化失败', error: error);
      _setError('视频初始化失败: $error');
    }
  }

  /// 获取缩略图URL并加载
  void _loadThumbnailUrl() async {
    // 尝试从新的URL构建器获取缩略图URL
    String? thumbnailUrl;
    if (_hasNewFileServerFields) {
      thumbnailUrl = await _mediaUrlBuilder.buildThumbnailUrl(widget.message);
    }
    
    // 如果没有新字段，尝试使用旧的thumbnailUrl字段
    thumbnailUrl ??= _getThumbnailUrl();
    
    _effectiveThumbnailPath = thumbnailUrl;
    _loadThumbnail();
  }
  
  /// 加载缩略图
  void _loadThumbnail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    if (_effectiveThumbnailPath == null || _effectiveThumbnailPath!.isEmpty) {
      // 没有缩略图，直接显示默认视频图标
      setState(() {
        _isLoading = false;
        _thumbnailProvider = null;
      });
      return;
    }

    try {
      String? localThumbnailPath;

      // 根据路径类型处理缩略图
      if (_effectiveThumbnailPath!.startsWith('http://') ||
          _effectiveThumbnailPath!.startsWith('https://')) {
        // 网络缩略图 - 使用缓存服务下载到本地
        localThumbnailPath =
            await _thumbnailCache.getThumbnail(_effectiveThumbnailPath!);

        if (localThumbnailPath == null) {
          throw Exception('缩略图下载失败');
        }
      } else if (_effectiveThumbnailPath!.startsWith('file://')) {
        // file:// 协议的本地文件
        final filePath = _effectiveThumbnailPath!.substring(7);
        final file = File(filePath);
        if (file.existsSync()) {
          localThumbnailPath = filePath;
        } else {
          throw Exception('缩略图文件不存在: $filePath');
        }
      } else {
        // 直接的文件路径
        final file = File(_effectiveThumbnailPath!);
        if (file.existsSync()) {
          localThumbnailPath = _effectiveThumbnailPath!;
        } else {
          throw Exception('缩略图文件不存在: $_effectiveThumbnailPath');
        }
      }

      // 使用本地文件创建ImageProvider
      _thumbnailProvider = FileImage(File(localThumbnailPath));

      // 预加载缩略图
      _preloadThumbnail();
    } catch (error) {
      _logger.e('加载缩略图失败', error: error);
      // 缩略图加载失败不算致命错误，继续显示默认图标
      if (mounted) {
        setState(() {
          _isLoading = false;
          _thumbnailProvider = null;
        });
      }
    }
  }

  /// 预加载缩略图
  void _preloadThumbnail() {
    if (_thumbnailProvider == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final ImageStream stream =
        _thumbnailProvider!.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (mounted) {
          // 计算实际的宽高比
          final actualRatio = info.image.width / info.image.height;

          setState(() {
            _isLoading = false;
            _hasError = false;
            _actualAspectRatio = actualRatio;
          });
        }
        stream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        if (mounted) {
          // 缩略图失败不影响整体功能
          setState(() {
            _isLoading = false;
            _thumbnailProvider = null;
          });
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

  /// 计算视频宽高比
  double _calculateAspectRatio() {
    // 1. 优先使用实际缩略图的宽高比
    if (_actualAspectRatio != null && _actualAspectRatio! > 0) {
      return _actualAspectRatio!;
    }

    // 2. 如果消息中有宽高信息，使用它
    if (_getWidth() != null &&
        _getHeight() != null &&
        _getWidth()! > 0 &&
        _getHeight()! > 0) {
      final ratio = _getWidth()! / _getHeight()!;
      return ratio;
    }

    // 3. 默认使用16:9的横屏比例（作为最后的备选）
    return 16.0 / 9.0;
  }

  /// 格式化视频时长
  String _formatDuration() {
    if (_getDuration() == null || _getDuration() == 0) {
      return '';
    }

    final seconds = _getDuration()! ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  /// 处理视频点击
  void _onVideoTap() {
    try {
      MediaViewer.openMedia(context, widget.message);
    } catch (error) {
      _logger.e('打开视频播放器失败', error: error);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法播放视频: $error'),
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
      _thumbnailProvider = null;
      _actualAspectRatio = null;
    });
    _initializeVideo();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = widget.maxWidth ?? screenSize.width * 0.6;
    final maxHeight = widget.maxHeight ?? screenSize.height * 0.4;

    // 检查是否有caption文字
    final hasCaption = _getCaption() != null &&
        _getCaption()!.trim().isNotEmpty;

    if (hasCaption) {
      // 视频 + 文字组合形式
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频部分
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
                  onTap: _hasError ? _retryLoad : _onVideoTap,
                  borderRadius: BorderRadius.circular(8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 背景/缩略图
                        _buildVideoBackground(),

                        // 播放按钮覆盖层
                        if (!_hasError) _buildPlayOverlay(),

                        // 时长标签
                        if (!_hasError && _formatDuration().isNotEmpty)
                          _buildDurationLabel(),
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
      // 纯视频形式
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
              onTap: _hasError ? _retryLoad : _onVideoTap,
              borderRadius: BorderRadius.circular(8.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景/缩略图
                    _buildVideoBackground(),

                    // 播放按钮覆盖层
                    if (!_hasError) _buildPlayOverlay(),

                    // 时长标签
                    if (!_hasError && _formatDuration().isNotEmpty)
                      _buildDurationLabel(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  /// 构建视频背景（缩略图或默认背景）
  Widget _buildVideoBackground() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_thumbnailProvider != null) {
      return Image(
        image: _thumbnailProvider!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultVideoBackground();
        },
      );
    }

    return _buildDefaultVideoBackground();
  }

  /// 构建默认视频背景
  Widget _buildDefaultVideoBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[400],
      child: Icon(
        Icons.video_library,
        color: Colors.grey[600],
        size: 48.0,
      ),
    );
  }

  /// 构建播放按钮覆盖层
  Widget _buildPlayOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(12.0),
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 32.0,
      ),
    );
  }

  /// 构建时长标签
  Widget _buildDurationLabel() {
    return Positioned(
      bottom: 8.0,
      right: 8.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(153),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          _formatDuration(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
            SizedBox(height: 8.0),
            Text(
              '加载中...',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.refresh,
          color: Colors.grey[400],
          size: 32.0,
        ),
      ),
    );
  }
}
