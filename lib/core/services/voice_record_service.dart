import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:uuid/uuid.dart';

/// 语音录制服务
class VoiceRecordService {
  static final VoiceRecordService _instance = VoiceRecordService._internal();
  factory VoiceRecordService() => _instance;
  VoiceRecordService._internal();

  final Record _recorder = Record();
  final LogService _logger = LogService.instance;
  final Uuid _uuid = const Uuid();

  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  /// 检查录音权限（简化版本）
  Future<bool> checkPermission() async {
    try {
      // 使用record包自带的权限检查
      return await _recorder.hasPermission();
    } catch (e) {
      _logger.e('检查录音权限失败', error: e);
      return false;
    }
  }

  /// 开始录音
  Future<bool> startRecording() async {
    try {
      _logger.i('开始录音流程');

      // 检查权限
      _logger.i('检查录音权限...');
      final hasPermission = await checkPermission();
      _logger.i('权限检查结果', extra: {'hasPermission': hasPermission});

      if (!hasPermission) {
        _logger.w('录音权限未授予');
        return false;
      }

      // 检查是否已在录音
      final isCurrentlyRecording = await _recorder.isRecording();
      _logger.i('当前录音状态', extra: {'isRecording': isCurrentlyRecording});

      if (isCurrentlyRecording) {
        _logger.w('已在录音中，停止当前录音');
        await stopRecording();
      }

      // 生成录音文件路径
      _logger.i('生成录音文件路径...');
      final recordingPath = await _generateRecordingPath();
      _logger.i('录音文件路径生成完成', extra: {'path': recordingPath});

      // 开始录音
      _logger.i('开始录音到文件', extra: {'path': recordingPath});
      await _recorder.start(
        path: recordingPath,
        encoder: AudioEncoder.aacLc, // 使用AAC编码，兼容性好
      );

      _currentRecordingPath = recordingPath;
      _recordingStartTime = DateTime.now();

      _logger.i('录音开始成功', extra: {
        'path': recordingPath,
        'startTime': _recordingStartTime?.toIso8601String(),
      });

      return true;
    } catch (e, stackTrace) {
      _logger.e('开始录音失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 停止录音并返回录音结果
  Future<VoiceRecordResult?> stopRecording() async {
    try {
      if (!await _recorder.isRecording()) {
        _logger.w('当前未在录音');
        return null;
      }

      // 停止录音
      final path = await _recorder.stop();
      if (path == null || _currentRecordingPath == null) {
        _logger.w('录音路径为空');
        return null;
      }

      // 计算录音时长
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inSeconds
          : 0;

      // 检查录音文件是否存在
      final file = File(path);
      if (!await file.exists()) {
        _logger.w('录音文件不存在: $path');
        return null;
      }

      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize == 0) {
        _logger.w('录音文件为空: $path');
        await file.delete(); // 删除空文件
        return null;
      }

      _logger.i('录音完成', extra: {
        'path': path,
        'duration': duration,
        'fileSize': fileSize,
      });

      final result = VoiceRecordResult(
        filePath: path,
        duration: duration,
        fileSize: fileSize,
      );

      // 清理状态
      _currentRecordingPath = null;
      _recordingStartTime = null;

      return result;
    } catch (e) {
      _logger.e('停止录音失败', error: e);
      await _cleanup();
      return null;
    }
  }

  /// 取消录音
  Future<void> cancelRecording() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }

      // 删除录音文件
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          _logger.i('已删除取消的录音文件: $_currentRecordingPath');
        }
      }

      await _cleanup();
    } catch (e) {
      _logger.e('取消录音失败', error: e);
      await _cleanup();
    }
  }

  /// 获取当前录音时长
  int getCurrentRecordingDuration() {
    if (_recordingStartTime == null) return 0;
    return DateTime.now().difference(_recordingStartTime!).inSeconds;
  }

  /// 检查是否正在录音
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// 生成录音文件路径
  Future<String> _generateRecordingPath() async {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'voice_${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return '${tempDir.path}/$fileName';
  }

  /// 清理状态
  Future<void> _cleanup() async {
    _currentRecordingPath = null;
    _recordingStartTime = null;
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
      _recorder.dispose();
      await _cleanup();
    } catch (e) {
      _logger.e('释放录音服务资源失败', error: e);
    }
  }
}

/// 录音结果
class VoiceRecordResult {
  final String filePath;
  final int duration; // 秒
  final int fileSize; // 字节

  const VoiceRecordResult({
    required this.filePath,
    required this.duration,
    required this.fileSize,
  });

  @override
  String toString() {
    return 'VoiceRecordResult(path: $filePath, duration: ${duration}s, size: ${fileSize}bytes)';
  }
}
