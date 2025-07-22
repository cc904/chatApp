import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/services/clipboard_service.dart';
import 'dart:io';

void main() {
  group('ClipboardService', () {
    late ClipboardService clipboardService;

    setUp(() {
      clipboardService = ClipboardService();
    });

    test('should be a singleton', () {
      final instance1 = ClipboardService();
      final instance2 = ClipboardService();
      expect(instance1, same(instance2));
    });

    // 私有方法测试已移除，因为无法从外部访问
    // 测试将通过集成测试来验证功能

    test('should check platform support correctly', () {
      // 移动端不支持图片剪贴板
      if (Platform.isAndroid || Platform.isIOS) {
        expect(clipboardService.supportsImageClipboard, isFalse);
      } else {
        // 桌面端支持
        expect(clipboardService.supportsImageClipboard, isTrue);
      }
    });
  });
}