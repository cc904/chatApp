import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';

/// 媒体服务类
/// 负责处理图片、视频、语音和文件选择和存储
class MediaService {
  final Logger _logger = Logger();
  final ImagePicker _imagePicker = ImagePicker();
  final Record _audioRecorder = Record();
  final Uuid _uuid = const Uuid();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  // 单例模式
  static final MediaService _instance = MediaService._internal();

  factory MediaService() {
    return _instance;
  }

  MediaService._internal();

  /// 选择图片（相册）
  Future<File?> pickImage({required bool fromCamera}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70, // 压缩质量
      );

      if (pickedFile == null) {
        return null; // 用户取消选择
      }

      // 将XFile转换为File并返回
      return File(pickedFile.path);
    } catch (e) {
      _logger.e('选择图片失败', error: e);
      return null;
    }
  }

  /// 播放本地音频文件
  Future<void> playAudio(
    String filePath, {
    Function(double)? onProgress,
    VoidCallback? onComplete,
  }) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // 播放前设置监听器
      _audioPlayer.onPositionChanged.listen((Duration position) async {
        if (onProgress != null) {
          final duration = await _audioPlayer.getDuration();
          if (duration != null && duration.inMilliseconds > 0) {
            final progress = position.inMilliseconds / duration.inMilliseconds;
            onProgress(progress.clamp(0.0, 1.0));
          }
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        if (onComplete != null) {
          onComplete();
        }
      });

      // 设置音频源并播放
      await _audioPlayer.play(DeviceFileSource(filePath));
      _isPlaying = true;
    } catch (e) {
      _logger.e('播放音频失败', error: e);
      rethrow;
    }
  }

  /// 从URL播放音频
  Future<void> playAudioFromUrl(
    String url, {
    Function(double)? onProgress,
    VoidCallback? onComplete,
  }) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // 播放前设置监听器
      _audioPlayer.onPositionChanged.listen((Duration position) async {
        if (onProgress != null) {
          final duration = await _audioPlayer.getDuration();
          if (duration != null && duration.inMilliseconds > 0) {
            final progress = position.inMilliseconds / duration.inMilliseconds;
            onProgress(progress.clamp(0.0, 1.0));
          }
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        if (onComplete != null) {
          onComplete();
        }
      });

      // 对于file://协议的URL，处理为本地文件
      if (url.startsWith('file://')) {
        await _audioPlayer.play(DeviceFileSource(url.substring(7)));
      } else {
        // 否则作为网络URL处理
        await _audioPlayer.play(UrlSource(url));
      }

      _isPlaying = true;
    } catch (e) {
      _logger.e('播放网络音频失败', error: e);
      rethrow;
    }
  }

  /// 暂停音频播放
  Future<void> pauseAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      }
    } catch (e) {
      _logger.e('暂停音频失败', error: e);
      rethrow;
    }
  }

  /// 恢复音频播放
  Future<void> resumeAudio() async {
    try {
      if (!_isPlaying) {
        await _audioPlayer.resume();
        _isPlaying = true;
      }
    } catch (e) {
      _logger.e('恢复音频播放失败', error: e);
      rethrow;
    }
  }

  /// 停止音频播放
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      _logger.e('停止音频播放失败', error: e);
      rethrow;
    }
  }

  /// 选择视频
  Future<File?> pickVideo({required bool fromCamera}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile == null) {
        return null; // 用户取消选择
      }

      // 将XFile转换为File并返回
      return File(pickedFile.path);
    } catch (e) {
      _logger.e('选择视频失败', error: e);
      return null;
    }
  }

  /// 选择文件
  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.isEmpty) {
        return null; // 用户取消选择
      }

      // 获取文件路径并返回File对象
      String? filePath = result.files.single.path;
      if (filePath == null) {
        return null;
      }

      return File(filePath);
    } catch (e) {
      _logger.e('选择文件失败', error: e);
      return null;
    }
  }

  /// 开始录音
  Future<bool> startRecording() async {
    if (_isRecording) {
      _logger.w('已经在录音中');
      return false;
    }

    try {
      // 检查录音权限
      if (await _audioRecorder.hasPermission()) {
        // 创建临时文件用于存储录音
        final tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/${_uuid.v4()}.aac';
        _currentRecordingPath = filePath;

        // 配置录音
        await _audioRecorder.start(
          path: filePath,
          encoder: AudioEncoder.aacLc, // 使用AAC编码器
          bitRate: 128000, // 比特率
          samplingRate: 44100, // 采样率
        );

        _isRecording = true;
        return true;
      } else {
        _logger.w('没有录音权限');
        return false;
      }
    } catch (e) {
      _logger.e('开始录音失败', error: e);
      return false;
    }
  }

  /// 停止录音
  Future<RecordingResult?> stopRecording() async {
    if (!_isRecording || _currentRecordingPath == null) {
      _logger.w('没有正在进行的录音');
      return null;
    }

    try {
      // 停止录音
      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path == null) {
        _logger.e('录音文件路径为空');
        return null;
      }

      // 获取录音时长
      final file = File(path);
      if (!await file.exists()) {
        _logger.e('录音文件不存在: $path');
        return null;
      }

      // 这里使用文件大小作为近似判断，实际应用中可能需要更准确的方法获取音频时长
      final fileSize = await file.length();
      if (fileSize <= 0) {
        _logger.e('录音文件大小为0');
        return null;
      }

      // 使用简单估算，假设128kbps的比特率
      // 文件大小(bytes) / (比特率(bps) / 8) = 时长(秒)
      // 这只是一个粗略估计，实际应用中需要使用专门的音频处理库
      final durationInMillis = (fileSize * 8 * 1000 / 128000).round();

      return RecordingResult(
        file: file,
        duration: durationInMillis,
      );
    } catch (e) {
      _logger.e('停止录音失败', error: e);
      return null;
    }
  }

  /// 将文件保存到应用文档目录
  Future<String?> saveFileToDocuments(File file, String subdirectory) async {
    try {
      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();

      // 创建子目录
      final targetDir = Directory('${appDocDir.path}/$subdirectory');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 生成唯一文件名
      final fileName = '${_uuid.v4()}${path.extension(file.path)}';
      final targetPath = '${targetDir.path}/$fileName';

      // 复制文件到目标路径
      await file.copy(targetPath);

      return targetPath;
    } catch (e) {
      _logger.e('保存文件失败', error: e);
      return null;
    }
  }

  /// 清理临时文件
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);

      if (await dir.exists()) {
        // 删除临时目录中的所有文件，但保留目录
        await for (final entity in dir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      _logger.e('清理临时文件失败', error: e);
    }
  }

  /// 检查录音是否正在进行
  bool get isRecording => _isRecording;
}

/// 录音结果类
class RecordingResult {
  final File file;
  final int duration; // 以毫秒为单位

  RecordingResult({
    required this.file,
    required this.duration,
  });
}
