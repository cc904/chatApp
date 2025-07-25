import 'dart:io' show File;
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// 条件导入：根据平台导入不同的剪贴板平台操作实现
import 'clipboard_platform_stub.dart'
    if (dart.library.io) 'clipboard_platform_io.dart'
    if (dart.library.html) 'clipboard_platform_web.dart';

/// 剪贴板服务
/// 提供图片粘贴和文本处理功能
class ClipboardService {
  final LogService _logger = LogService.instance;
  
  // 单例模式
  static final ClipboardService _instance = ClipboardService._internal();
  factory ClipboardService() => _instance;
  ClipboardService._internal();

  /// 检查剪贴板是否包含图片
  Future<bool> hasImage() async {
    try {
      if (isMobilePlatform()) {
        // 移动端不支持图片粘贴
        return false;
      } else {
        // 桌面端使用pasteboard检查图片
        return await _hasImageDesktop();
      }
    } catch (error) {
      _logger.e('检查剪贴板图片失败', error: error);
    }
    return false;
  }

  /// 桌面端检查剪贴板图片
  Future<bool> _hasImageDesktop() async {
    // 1. 检查文件路径
    final files = await Pasteboard.files();
    if (files.isNotEmpty) {
      for (final file in files) {
        final extension = path.extension(file).toLowerCase();
        if (_isImageExtension(extension)) {
          return true;
        }
      }
    }

    // 2. 检查图片数据
    final imageData = await Pasteboard.image;
    return imageData != null;
  }

  /// 从剪贴板获取图片数据
  /// 返回 Map<String, dynamic> 包含:
  /// - 'data': Uint8List 图片数据
  /// - 'name': String 文件名
  /// - 'mimeType': String MIME类型
  Future<Map<String, dynamic>?> getImageData() async {
    try {
      if (isMobilePlatform()) {
        // 移动端不支持图片粘贴
        return null;
      } else {
        // 桌面端：从剪贴板直接获取
        return await _getImageDataDesktop();
      }
    } catch (error) {
      _logger.e('从剪贴板获取图片失败', error: error);
    }
    return null;
  }


  /// 桌面端从剪贴板获取图片数据
  Future<Map<String, dynamic>?> _getImageDataDesktop() async {
    // 1. 首先尝试获取文件路径
    final files = await Pasteboard.files();
    if (files.isNotEmpty) {
      for (final filePath in files) {
        final extension = path.extension(filePath).toLowerCase();
        if (_isImageExtension(extension)) {
          final file = File(filePath);
          if (await file.exists()) {
            final data = await file.readAsBytes();
            final fileName = path.basename(filePath);
            final mimeType = _getMimeTypeFromExtension(extension);
            
            _logger.i('从剪贴板获取图片文件', extra: {
              'fileName': fileName,
              'size': data.length,
              'mimeType': mimeType,
            });
            
            return {
              'data': data,
              'name': fileName,
              'mimeType': mimeType,
              'isUrl': false,
            };
          }
        }
      }
    }

    // 2. 尝试获取图片数据
    final imageData = await Pasteboard.image;
    if (imageData != null) {
      final fileName = 'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.png';
      
      _logger.i('从剪贴板获取图片数据', extra: {
        'fileName': fileName,
        'size': imageData.length,
      });
      
      return {
        'data': imageData,
        'name': fileName,
        'mimeType': 'image/png',
        'isUrl': false,
      };
    }
    
    return null;
  }

  /// 获取剪贴板文本内容
  Future<String?> getText() async {
    try {
      final ClipboardData? data = await Clipboard.getData('text/plain');
      return data?.text;
    } catch (error) {
      _logger.e('获取剪贴板文本失败', error: error);
      return null;
    }
  }

  /// 设置剪贴板文本内容
  Future<void> setText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _logger.d('设置剪贴板文本成功');
    } catch (error) {
      _logger.e('设置剪贴板文本失败', error: error);
    }
  }

  /// 将图片数据保存到临时文件
  Future<File?> saveImageToTempFile(Map<String, dynamic> imageData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = imageData['name'] as String;
      final data = imageData['data'] as List<int>;
      
      final tempFile = File(path.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(data);
      
      _logger.i('图片保存到临时文件', extra: {
        'path': tempFile.path,
        'size': data.length,
      });
      
      return tempFile;
    } catch (error) {
      _logger.e('保存图片到临时文件失败', error: error);
      return null;
    }
  }


  /// 检查文件扩展名是否为支持的图片格式
  bool _isImageExtension(String extension) {
    const supportedExtensions = [
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', 
      '.webp', '.tiff', '.tif', '.ico', '.svg'
    ];
    return supportedExtensions.contains(extension.toLowerCase());
  }

  /// 根据文件扩展名获取MIME类型
  String _getMimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      case '.webp':
        return 'image/webp';
      case '.tiff':
      case '.tif':
        return 'image/tiff';
      case '.ico':
        return 'image/x-icon';
      case '.svg':
        return 'image/svg+xml';
      default:
        return 'image/png';
    }
  }


  /// 清空剪贴板
  Future<void> clear() async {
    try {
      await Clipboard.setData(const ClipboardData(text: ''));
      _logger.d('清空剪贴板成功');
    } catch (error) {
      _logger.e('清空剪贴板失败', error: error);
    }
  }

  /// 检查平台是否支持图片剪贴板功能
  bool get supportsImageClipboard {
    return isDesktopPlatform();
  }

  /// 获取支持详情描述
  String get supportDetails {
    if (isMobilePlatform()) {
      return '移动端不支持图片粘贴';
    } else {
      return '桌面端支持粘贴图片文件和数据';
    }
  }
}