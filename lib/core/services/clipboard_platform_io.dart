import 'dart:io';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as path;

/// 剪贴板服务平台相关操作（IO平台实现）

/// 检查是否为移动平台（Android或iOS）
bool isMobilePlatform() {
  return Platform.isAndroid || Platform.isIOS;
}

/// 检查是否为桌面平台（macOS、Windows或Linux）
bool isDesktopPlatform() {
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

/// 非Web平台占位：返回null表示无Web剪贴板读取
Future<Map<String, dynamic>?> readClipboardImageWeb() async {
  return null;
}

Future<bool> platformHasClipboardImage() async {
  // 1) 文件路径
  final files = await Pasteboard.files();
  if (files.isNotEmpty) {
    for (final file in files) {
      final ext = path.extension(file).toLowerCase();
      if (_isImageExtension(ext)) return true;
    }
  }
  // 2) 原始图片数据
  final imageData = await Pasteboard.image;
  return imageData != null;
}

Future<Map<String, dynamic>?> platformGetClipboardImageData() async {
  // 1) 文件路径
  final files = await Pasteboard.files();
  if (files.isNotEmpty) {
    for (final filePath in files) {
      final ext = path.extension(filePath).toLowerCase();
      if (_isImageExtension(ext)) {
        final file = File(filePath);
        if (await file.exists()) {
          final data = await file.readAsBytes();
          return {
            'data': data,
            'name': path.basename(filePath),
            'mimeType': _mimeFromExt(ext),
            'isUrl': false,
          };
        }
      }
    }
  }
  // 2) 原始图片数据
  final imageData = await Pasteboard.image;
  if (imageData != null) {
    return {
      'data': imageData,
      'name': 'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.png',
      'mimeType': 'image/png',
      'isUrl': false,
    };
  }
  return null;
}

bool _isImageExtension(String ext) {
  const exts = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff', '.tif', '.ico', '.svg'];
  return exts.contains(ext);
}

String _mimeFromExt(String ext) {
  switch (ext) {
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