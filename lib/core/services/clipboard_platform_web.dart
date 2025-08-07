/// Web 平台平台判断 + 剪贴板图片读取（基于 package:web）

import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

bool isMobilePlatform() => false; // Web不是移动平台
bool isDesktopPlatform() => true; // Web 视作“支持粘贴”的平台

/// 从浏览器剪贴板读取图片（若存在）。
/// 返回 { 'data': Uint8List, 'name': String, 'mimeType': String, 'isUrl': false }
Future<Map<String, dynamic>?> readClipboardImageWeb() async {
  try {
    // 现代浏览器：navigator.clipboard.read()
    final items = await web.window.navigator.clipboard.read().toDart;
    for (final item in items.toDart) {
      for (final type in item.types.toDart) {
        final String t = type as String;
        if (t.startsWith('image/')) {
          final blob = await item.getType(t).toDart;
          final ab = await blob.arrayBuffer().toDart;
          final bytes = Uint8List.view(ab as ByteBuffer);
          final name = 'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.${_extFromMime(t)}';
          return {
            'data': bytes,
            'name': name,
            'mimeType': t,
            'isUrl': false,
          };
        }
      }
    }

    // 回退：使用旧的 clipboardData（在某些浏览器中可用）
    final evt = web.ClipboardEvent('paste');
    final data = evt.clipboardData;
    if (data != null) {
      final files = data.files;
      for (int i = 0; i < files.length; i++) {
        final file = files.item(i);
        if (file != null && file.type.startsWith('image/')) {
          final ab = await file.arrayBuffer().toDart;
          final bytes = Uint8List.view(ab as ByteBuffer);
          return {
            'data': bytes,
            'name': file.name.isNotEmpty ? file.name : 'clipboard_image.${_extFromMime(file.type)}',
            'mimeType': file.type,
            'isUrl': false,
          };
        }
      }
    }
  } catch (_) {
    // 忽略错误，返回null
  }
  return null;
}

String _extFromMime(String mime) {
  switch (mime) {
    case 'image/jpeg':
      return 'jpg';
    case 'image/png':
      return 'png';
    case 'image/gif':
      return 'gif';
    case 'image/webp':
      return 'webp';
    default:
      return 'png';
  }
}