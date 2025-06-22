import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/services/voice_record_service.dart';

void main() {
  // 初始化Flutter绑定
  TestWidgetsFlutterBinding.ensureInitialized();
  group('VoiceRecordService', () {
    late VoiceRecordService service;

    setUp(() {
      service = VoiceRecordService();
    });

    test('should be a singleton', () {
      final service1 = VoiceRecordService();
      final service2 = VoiceRecordService();
      expect(service1, equals(service2));
    });

    test('should not be recording initially', () {
      expect(service.isRecording, false);
    });

    test('should start recording successfully', () async {
      final result = await service.startRecording();
      expect(result, true);
      expect(service.isRecording, true);
    });

    test('VoiceRecordResult should format correctly', () {
      const result = VoiceRecordResult(
        filePath: '/test/path.m4a',
        duration: 30,
        fileSize: 1024,
      );

      expect(result.toString(), contains('path: /test/path.m4a'));
      expect(result.toString(), contains('duration: 30s'));
      expect(result.toString(), contains('size: 1024bytes'));
    });

    test('should stop recording and return result', () async {
      // 首先开始录制
      await service.startRecording();
      expect(service.isRecording, true);

      // 停止录制
      final result = await service.stopRecording();
      expect(result, isNotNull);
      expect(service.isRecording, false);
      expect(result!.filePath, isNotEmpty);
    });
  });
}
 