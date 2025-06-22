import 'package:flutter/material.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/presentation/widgets/media_viewer.dart';
import 'dart:io';

/// 图片消息Widget
/// 支持网络图片、本地图片、加载状态、错误处理和点击查看
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

  // 加载状态
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // 图片信息
  ImageProvider? _imageProvider;
  String? _effectiveImagePath;

  // 实际的图片宽高比（从图片获取）
  double? _actualAspectRatio;

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  /// 初始化图片
  void _initializeImage() {
    _logger.i('🖼️ 初始化图片消息', extra: {
      'messageId': widget.message.messageId,
      'mediaUrl': widget.message.mediaUrl,
      'localPath': widget.message.localPath,
      'width': widget.message.width,
      'height': widget.message.height,
    });

    try {
      // 确定图片路径优先级：localPath > mediaUrl（优先使用本地文件）
      if (widget.message.localPath != null &&
          widget.message.localPath!.isNotEmpty) {
        _effectiveImagePath = widget.message.localPath!;
        _logger.i('📁 使用本地图片: $_effectiveImagePath');
      } else if (widget.message.mediaUrl != null &&
          widget.message.mediaUrl!.isNotEmpty) {
        _effectiveImagePath = widget.message.mediaUrl!;
        _logger.i('📡 使用网络图片: $_effectiveImagePath');
      } else {
        throw Exception('图片路径为空');
      }

      _loadImage();
    } catch (error) {
      _logger.e('❌ 图片初始化失败', error: error, stackTrace: StackTrace.current);
      _setError('图片初始化失败: $error');
    }
  }

  /// 加载图片
  void _loadImage() {
    if (_effectiveImagePath == null) {
      _setError('图片路径为空');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // 根据路径类型选择ImageProvider
      if (_effectiveImagePath!.startsWith('http://') ||
          _effectiveImagePath!.startsWith('https://')) {
        // 网络图片
        _imageProvider = NetworkImage(_effectiveImagePath!);
        _logger.i('🌐 加载网络图片: $_effectiveImagePath');
      } else if (_effectiveImagePath!.startsWith('file://')) {
        // file:// 协议的本地文件
        final filePath = _effectiveImagePath!.substring(7);
        final file = File(filePath);
        if (file.existsSync()) {
          _imageProvider = FileImage(file);
          _logger.i('📄 加载本地文件: $filePath');
        } else {
          throw Exception('本地文件不存在: $filePath');
        }
      } else {
        // 直接的文件路径
        final file = File(_effectiveImagePath!);
        if (file.existsSync()) {
          _imageProvider = FileImage(file);
          _logger.i('📁 加载本地文件: $_effectiveImagePath');
        } else {
          throw Exception('本地文件不存在: $_effectiveImagePath');
        }
      }

      // 预加载图片
      _preloadImage();
    } catch (error) {
      _logger.e('❌ 创建ImageProvider失败',
          error: error, stackTrace: StackTrace.current);
      _setError('加载图片失败: $error');
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

          _logger.i('✅ 图片加载成功', extra: {
            'width': info.image.width,
            'height': info.image.height,
            'aspectRatio': actualRatio,
            'synchronousCall': synchronousCall,
          });

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
          _logger.e('❌ 图片加载失败', error: exception, stackTrace: stackTrace);
          _setError('图片加载失败: $exception');
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
        _errorMessage = message;
      });
    }
  }

  /// 计算图片宽高比
  double _calculateAspectRatio() {
    // 1. 优先使用实际图片的宽高比
    if (_actualAspectRatio != null && _actualAspectRatio! > 0) {
      _logger.d('使用实际图片宽高比', extra: {
        'aspectRatio': _actualAspectRatio,
      });
      return _actualAspectRatio!;
    }

    // 2. 如果消息中有宽高信息，使用它
    if (widget.message.width != null &&
        widget.message.height != null &&
        widget.message.width! > 0 &&
        widget.message.height! > 0) {
      final ratio = widget.message.width! / widget.message.height!;
      _logger.d('使用消息中的宽高比', extra: {
        'width': widget.message.width,
        'height': widget.message.height,
        'ratio': ratio,
      });
      return ratio;
    }

    // 3. 根据图片路径推测可能的宽高比
    if (_effectiveImagePath != null) {
      final path = _effectiveImagePath!.toLowerCase();

      if (path.contains('portrait') || path.contains('vertical')) {
        _logger.d('根据路径推测为竖图比例');
        return 0.75; // 3:4 竖图比例
      } else if (path.contains('landscape') || path.contains('horizontal')) {
        _logger.d('根据路径推测为横图比例');
        return 1.5; // 3:2 横图比例
      } else if (path.contains('square')) {
        _logger.d('根据路径推测为正方形');
        return 1.0; // 1:1 正方形
      }

      // 根据文件扩展名推测
      if (path.contains('.jpg') || path.contains('.jpeg')) {
        _logger.d('根据JPEG扩展名推测为4:3比例');
        return 1.33; // 4:3 比例，常见于相机拍摄
      } else if (path.contains('.png')) {
        _logger.d('根据PNG扩展名推测为正方形');
        return 1.0; // PNG 通常接近正方形
      }
    }

    // 4. 默认比例
    _logger.d('使用默认4:3宽高比');
    return 1.33; // 4:3 比例
  }

  /// 处理图片点击
  void _onImageTap() {
    _logger.i('👆 用户点击图片', extra: {
      'messageId': widget.message.messageId,
      'effectivePath': _effectiveImagePath,
    });

    try {
      MediaViewer.openMedia(context, widget.message);
    } catch (error) {
      _logger.e('❌ 打开图片查看器失败', error: error, stackTrace: StackTrace.current);

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
    _logger.i('🔄 用户点击重试加载图片');
    _initializeImage();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = widget.maxWidth ?? screenSize.width * 0.6;
    final maxHeight = widget.maxHeight ?? screenSize.height * 0.4;

    return GestureDetector(
      onTap: _hasError ? _retryLoad : _onImageTap,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minWidth: 120.0,
          minHeight: 80.0,
        ),
        child: AspectRatio(
          aspectRatio: _calculateAspectRatio(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _buildImageContent(),
            ),
          ),
        ),
      ),
    );
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
        _logger.e('❌ Image组件加载失败', error: error, stackTrace: stackTrace);
        return _buildErrorWidget();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.grey[400],
              size: 40.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              '图片加载失败',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              '点击重试',
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.grey[500],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 4.0),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 9.0,
                  color: Colors.red[400],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
