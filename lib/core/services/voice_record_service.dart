import 'dart:io' show File;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:nanoid/nanoid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 语音录制结果
class VoiceRecordResult {
  final String filePath;
  final int duration; // 秒
  final int fileSize; // 字节

  const VoiceRecordResult({
    required this.filePath,
    required this.duration,
    required this.fileSize,
  });

  /// 格式化文件大小
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 格式化时长
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds}s';
    }
  }

  @override
  String toString() {
    return 'VoiceRecordResult(path: $filePath, duration: $formattedDuration, size: $formattedFileSize)';
  }
}

/// 语音录制服务
/// 使用record插件6.0.0的AudioRecorder实现语音录制功能
/// 基于官方示例进行优化和简化
class VoiceRecordService {
  static final VoiceRecordService _instance = VoiceRecordService._internal();
  factory VoiceRecordService() => _instance;
  VoiceRecordService._internal();

  /// 最大录音时长（秒）
  static const int maxRecordingDuration = 60;

  AudioRecorder? _recorder;
  final LogService _logger = LogService.instance;

  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  bool _isRecording = false;

  /// 初始化录制器
  Future<bool> _initializeRecorder() async {
    try {
      _recorder ??= AudioRecorder();
      _logger.i('语音录制器初始化成功');
      return true;
    } catch (e, stackTrace) {
      _logger.e('语音录制器初始化失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 检查录音权限
  Future<bool> hasPermission() async {
    try {
      if (!await _initializeRecorder() || _recorder == null) {
        return false;
      }
      return await _recorder!.hasPermission();
    } catch (e, stackTrace) {
      _logger.e('检查录音权限失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 同步检查是否正在录制（基于内部状态）
  bool get isRecording => _isRecording;

  /// 开始录音
  Future<bool> startRecording() async {
    try {
      _logger.i('开始录音流程');

      if (!await _initializeRecorder() || _recorder == null) {
        return false;
      }

      // 检查权限
      _logger.i('检查录音权限...');
      final hasPermission = await _recorder!.hasPermission();
      _logger.i('权限检查结果: $hasPermission');

      if (!hasPermission) {
        _logger.w('录音权限未授予');
        return false;
      }

      // 检查是否已在录音
      final isCurrentlyRecording = await _recorder!.isRecording();
      _logger.i('当前录音状态: $isCurrentlyRecording');

      if (isCurrentlyRecording) {
        _logger.w('已在录音中，停止当前录音');
        await stopRecording();
      }

      // 生成录音文件路径
      _logger.i('生成录音文件路径...');
      final recordingPath = await _generateFilePath();
      _logger.i('录音文件路径生成完成: $recordingPath');

      // 开始录音 - 使用优化配置
      _logger.i('开始录音到文件: $recordingPath');
      await _recorder!.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), // AAC-LC编码，兼容性最好
        path: recordingPath,
      );

      _currentRecordingPath = recordingPath;
      _recordingStartTime = DateTime.now();
      _isRecording = true;

      _logger.i('录音开始成功: path=$recordingPath, startTime=${_recordingStartTime?.toIso8601String()}');

      return true;
    } catch (e, stackTrace) {
      _logger.e('开始录音失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 停止录音并返回录音结果
  Future<VoiceRecordResult?> stopRecording() async {
    try {
      if (!_isRecording) {
        _logger.w('当前未在录音');
        return null;
      }

      // 停止录音
      final path = await _recorder?.stop();
      if (path == null || _currentRecordingPath == null) {
        _logger.w('录音路径为空');
        return null;
      }

      // 计算录音时长
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inSeconds
          : 0;

      // Web平台跳过文件系统检查，直接返回结果
      if (kIsWeb) {
        _logger.i('Web平台录音完成', extra: {
          'path': path,
          'duration': duration,
        });

        await _cleanup();

        return VoiceRecordResult(
          filePath: path,
          duration: duration,
          fileSize: 0, // Web平台无法获取文件大小
        );
      }

      // 移动端/桌面端进行文件检查
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
      _isRecording = false;

      return result;
    } catch (e, stackTrace) {
      _logger.e('停止录音失败', error: e, stackTrace: stackTrace);
      await _cleanup();
      return null;
    }
  }

  /// 取消录音
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder?.cancel();

        // Web平台跳过文件操作
        if (!kIsWeb) {
          // 删除录音文件（cancel方法应该已经删除了文件，但为了确保）
          if (_currentRecordingPath != null) {
            final file = File(_currentRecordingPath!);
            if (await file.exists()) {
              await file.delete();
              _logger.i('已删除取消的录音文件: $_currentRecordingPath');
            }
          }
        }

        await _cleanup();
      }
    } catch (e, stackTrace) {
      _logger.e('取消录音失败', error: e, stackTrace: stackTrace);
      await _cleanup();
    }
  }

  /// 获取当前录音时长
  int getCurrentRecordingDuration() {
    if (_recordingStartTime == null) return 0;
    return DateTime.now().difference(_recordingStartTime!).inSeconds;
  }

  /// 异步检查是否正在录音（向后兼容）
  Future<bool> isRecordingAsync() async {
    try {
      if (_recorder == null) {
        return _isRecording;
      }
      return await _recorder!.isRecording();
    } catch (e) {
      return _isRecording;
    }
  }

  /// 生成文件路径
  Future<String> _generateFilePath() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uuid = nanoid(21);
      
      // Web平台返回一个简单路径，record库会处理实际存储
      if (kIsWeb) {
        return 'voice_${uuid}_$timestamp.m4a';
      }

      final tempDir = await getTemporaryDirectory();
      // 使用.m4a扩展名，对应AAC-LC编码
      return '${tempDir.path}/voice_${uuid}_$timestamp.m4a';
    } catch (e) {
      // 在测试环境中，path_provider可能不可用，使用固定路径
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uuid = nanoid(21);
      return '/tmp/voice_${uuid}_$timestamp.m4a';
    }
  }

  /// 清理状态
  Future<void> _cleanup() async {
    _currentRecordingPath = null;
    _recordingStartTime = null;
    _isRecording = false;
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      await cancelRecording();

      if (_recorder != null) {
        _recorder!.dispose();
        _recorder = null;
      }

      _logger.i('语音录制服务资源已释放');
    } catch (e, stackTrace) {
      _logger.e('释放语音录制服务资源失败', error: e, stackTrace: stackTrace);
    }
  }
}
