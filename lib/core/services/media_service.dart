import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';

/// 媒体服务类
/// 负责处理图片、视频、语音和文件选择和存储
class MediaService {
  final _logger = LogService.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final Record _audioRecorder = Record();
  final Uuid _uuid = const Uuid();

  // 音频播放器实例,使用懒加载模式
  AudioPlayer? _audioPlayer;
  bool _isPlayerInitialized = false;

  // 状态变量
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  // 回调函数
  VoidCallback? _onCompleteCallback;
  void Function(double)? _onProgressCallback;

  // 状态订阅
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;

  // 单例模式
  static final MediaService _instance = MediaService._internal();

  factory MediaService() {
    return _instance;
  }

  MediaService._internal();

  // 获取AudioPlayer实例
  Future<AudioPlayer> _getAudioPlayer() async {
    if (_audioPlayer == null) {
      _logger.i('创建新的AudioPlayer实例');
      try {
        _audioPlayer = AudioPlayer();
        _isPlayerInitialized = true;

        // 设置处理状态监听
        _processingStateSubscription = _audioPlayer!.processingStateStream.listen((state) {
          _logger.i('音频处理状态: $state');
          if (state == ProcessingState.completed) {
            _isPlaying = false;
            if (_onCompleteCallback != null) {
              _onCompleteCallback!();
            }
          }
        }, onError: (error) {
          _logger.e('音频状态监听错误', error: error);
        });
      } catch (e) {
        _logger.e('创建AudioPlayer实例失败', error: e);
        throw Exception('无法初始化音频播放器: $e');
      }
    }
    return _audioPlayer!;
  }

  // 清理监听器
  Future<void> _clearPositionListener() async {
    if (_positionSubscription != null) {
      try {
        await _positionSubscription!.cancel();
      } catch (e) {
        _logger.e('取消位置监听器失败', error: e);
      } finally {
        _positionSubscription = null;
      }
    }
  }

  /// 播放本地音频文件
  Future<void> playAudio(
    String filePath, {
    VoidCallback? onComplete,
    void Function(double)? onProgress,
  }) async {
    try {
      _logger.i('准备播放音频文件: $filePath');

      // 先停止当前播放
      await stopAudio();

      // 保存回调函数
      _onCompleteCallback = onComplete;
      _onProgressCallback = onProgress;

      // 获取播放器
      AudioPlayer player;
      try {
        player = await _getAudioPlayer();
      } catch (e) {
        _logger.e('获取AudioPlayer实例失败', error: e);
        // 尝试重新初始化播放器
        _audioPlayer = null;
        _isPlayerInitialized = false;

        // 第二次尝试
        player = await _getAudioPlayer();
      }

      // 处理文件路径
      String effectiveFilePath = filePath;
      if (filePath.startsWith('file://')) {
        effectiveFilePath = filePath.substring(7);
        _logger.i('移除file://前缀,实际路径: $effectiveFilePath');
      }

      // 验证文件是否存在
      final file = File(effectiveFilePath);
      if (!await file.exists()) {
        _logger.e('音频文件不存在: $effectiveFilePath');
        throw Exception('音频文件不存在');
      }

      final fileSize = await file.length();
      if (fileSize <= 0) {
        _logger.e('音频文件大小为0');
        throw Exception('音频文件无效（大小为0）');
      }
      _logger.i('音频文件大小: $fileSize字节');

      // 清理之前的位置监听器
      await _clearPositionListener();

      // 设置音频源
      _logger.i('加载音频文件...');
      try {
        await player.setFilePath(effectiveFilePath);
      } catch (e) {
        _logger.e('设置音频文件路径失败', error: e);
        // 对于macOS,尝试使用完整的file://路径
        if (Platform.isMacOS) {
          _logger.i('在macOS上尝试使用file://URL格式');
          final macOSPath = 'file://$effectiveFilePath';
          await player.setUrl(macOSPath);
        } else {
          rethrow;
        }
      }

      final duration = player.duration;
      _logger.i('音频时长: ${duration?.inMilliseconds ?? "未知"}毫秒');

      // 设置进度监听器
      _positionSubscription = player.positionStream.listen((position) {
        if (duration != null && duration.inMilliseconds > 0) {
          final progress = position.inMilliseconds / duration.inMilliseconds;

          // 调用进度回调
          if (_onProgressCallback != null) {
            _onProgressCallback!(progress);
          }

          if (progress >= 1.0 && _onCompleteCallback != null) {
            _onCompleteCallback!();
          }
        }
      }, onError: (e) {
        _logger.e('播放进度监听错误', error: e);
      });

      // 开始播放
      _logger.i('开始播放音频');
      await player.play();
      _isPlaying = true;
    } catch (e) {
      _logger.e('播放音频失败', error: e);
      // 清理状态
      _isPlaying = false;
      _onCompleteCallback = null;
      _onProgressCallback = null;
      await _clearPositionListener();
      rethrow;
    }
  }

  /// 从URL播放音频
  Future<void> playAudioFromUrl(
    String url, {
    VoidCallback? onComplete,
    void Function(double)? onProgress,
  }) async {
    try {
      _logger.i('准备播放URL音频: $url');

      // 先停止当前播放
      await stopAudio();

      // 保存回调函数
      _onCompleteCallback = onComplete;
      _onProgressCallback = onProgress;

      // 获取播放器
      AudioPlayer player;
      try {
        player = await _getAudioPlayer();
      } catch (e) {
        _logger.e('获取AudioPlayer实例失败', error: e);
        // 尝试重新初始化播放器
        _audioPlayer = null;
        _isPlayerInitialized = false;

        // 第二次尝试
        player = await _getAudioPlayer();
      }

      // 清理之前的位置监听器
      await _clearPositionListener();

      // 根据URL类型设置音频源
      if (url.startsWith('file://')) {
        final localPath = url.substring(7);
        _logger.i('检测到本地URL,转换为本地路径: $localPath');

        // 验证文件是否存在
        final file = File(localPath);
        if (!await file.exists()) {
          _logger.e('本地音频文件不存在: $localPath');
          throw Exception('本地音频文件不存在');
        }

        try {
          // 设置本地文件
          await player.setFilePath(localPath);
        } catch (e) {
          _logger.e('设置本地文件路径失败', error: e);
          // 对于macOS,直接使用URL格式
          if (Platform.isMacOS) {
            _logger.i('在macOS上尝试使用原始file://URL');
            await player.setUrl(url);
          } else {
            rethrow;
          }
        }
      } else {
        // 设置网络URL
        await player.setUrl(url);
      }

      final duration = player.duration;
      _logger.i('音频时长: ${duration?.inMilliseconds ?? "未知"}毫秒');

      // 设置进度监听器
      _positionSubscription = player.positionStream.listen((position) {
        if (duration != null && duration.inMilliseconds > 0) {
          final progress = position.inMilliseconds / duration.inMilliseconds;

          // 调用进度回调
          if (_onProgressCallback != null) {
            _onProgressCallback!(progress);
          }

          if (progress >= 1.0 && _onCompleteCallback != null) {
            _onCompleteCallback!();
          }
        }
      }, onError: (e) {
        _logger.e('播放进度监听错误', error: e);
      });

      // 开始播放
      _logger.i('开始播放音频URL');
      await player.play();
      _isPlaying = true;
    } catch (e) {
      _logger.e('播放URL音频失败', error: e);
      // 清理状态
      _isPlaying = false;
      _onCompleteCallback = null;
      _onProgressCallback = null;
      await _clearPositionListener();
      rethrow;
    }
  }

  /// 暂停音频播放
  Future<void> pauseAudio() async {
    if (!_isPlaying || _audioPlayer == null || !_isPlayerInitialized) return;

    try {
      _logger.i('暂停音频播放');
      await _audioPlayer!.pause();
      _isPlaying = false;
      _logger.i('音频播放已暂停');
    } catch (e) {
      _logger.e('暂停音频播放失败', error: e);
    }
  }

  /// 恢复音频播放
  Future<void> resumeAudio() async {
    if (_isPlaying || _audioPlayer == null || !_isPlayerInitialized) return;

    try {
      _logger.i('恢复音频播放');
      await _audioPlayer!.play();
      _isPlaying = true;
      _logger.i('音频播放已恢复');
    } catch (e) {
      _logger.e('恢复音频播放失败', error: e);
    }
  }

  /// 停止音频播放
  Future<void> stopAudio() async {
    if (_audioPlayer == null || !_isPlayerInitialized) {
      _logger.i('没有活动的音频播放器,无需停止');
      return;
    }

    try {
      _logger.i('停止音频播放');

      // 清理回调
      _onCompleteCallback = null;
      _onProgressCallback = null;

      // 清理位置监听器
      await _clearPositionListener();

      // 停止播放
      await _audioPlayer!.stop();
      _isPlaying = false;

      _logger.i('音频播放已停止');
    } catch (e) {
      _logger.e('停止音频播放失败', error: e);
      _isPlaying = false;
    }
  }

  /// 清理音频资源
  Future<void> disposeAudio() async {
    try {
      _logger.i('清理所有音频资源');

      // 清理位置监听器
      await _clearPositionListener();

      // 清理处理状态监听器
      if (_processingStateSubscription != null) {
        try {
          await _processingStateSubscription!.cancel();
        } catch (e) {
          _logger.e('取消处理状态监听器失败', error: e);
        } finally {
          _processingStateSubscription = null;
        }
      }

      // 清理回调
      _onCompleteCallback = null;
      _onProgressCallback = null;

      // 如果有活动播放器,释放资源
      if (_audioPlayer != null && _isPlayerInitialized) {
        try {
          await _audioPlayer!.stop();
          await _audioPlayer!.dispose();
        } catch (e) {
          _logger.e('释放音频播放器资源失败', error: e);
        } finally {
          _audioPlayer = null;
          _isPlayerInitialized = false;
        }
      }

      _isPlaying = false;
      _logger.i('所有音频资源已清理');
    } catch (e) {
      _logger.e('清理音频资源失败', error: e);
      // 确保实例被重置
      _audioPlayer = null;
      _isPlayerInitialized = false;
      _isPlaying = false;
    }
  }

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
        final String fileName = '${_uuid.v4()}.aac';
        final String filePath = '${tempDir.path}/$fileName';

        // 保存原始路径,用于后续的文件操作
        _currentRecordingPath = filePath;
        _logger.i('录音文件路径: $filePath');

        // 确保录音服务未处于活动状态
        if (await _audioRecorder.isRecording()) {
          await _audioRecorder.stop();
          _isRecording = false;
        }

        // 在macOS上,我们需要使用file://前缀
        String recordPath;
        if (Platform.isMacOS) {
          // 使用file://前缀的完整URL
          recordPath = 'file://$filePath';
          _logger.i('macOS录音URL: $recordPath');
        } else {
          // 其他平台使用普通文件路径
          recordPath = filePath;
        }

        // 配置录音
        await _audioRecorder.start(
          path: recordPath,
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
      _isRecording = false; // 确保状态重置
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
      // 停止录音前,确保设置了正确的状态标志
      _isRecording = false;

      // 停止录音
      final path = await _audioRecorder.stop();

      if (path == null) {
        _logger.e('录音文件路径为空');
        return null;
      }

      // 记录返回的路径和我们保存的原始路径
      _logger.i('录音结果 - 原始路径: $_currentRecordingPath, 返回路径: $path');

      // 使用我们保存的原始路径创建File对象
      final file = File(_currentRecordingPath!);

      // 确认文件存在
      if (!await file.exists()) {
        _logger.e('录音文件不存在,尝试使用返回的路径');

        // 如果返回的路径是file://开头,尝试转换并检查
        String altPath = path;
        if (path.startsWith('file://')) {
          altPath = path.substring(7);
        }

        final altFile = File(altPath);
        if (await altFile.exists()) {
          _logger.i('使用替代路径找到文件: $altPath');

          // 如果文件大小为0,可能录音失败
          final fileSize = await altFile.length();
          if (fileSize <= 0) {
            _logger.e('录音文件大小为0');
            return null;
          }

          // 使用替代文件和路径
          final durationInMillis = (fileSize * 8 * 1000 / 128000).round();
          return RecordingResult(
            file: altFile,
            duration: durationInMillis,
          );
        }

        return null;
      }

      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize <= 0) {
        _logger.e('录音文件大小为0');
        return null;
      }

      // 计算持续时间
      final durationInMillis = (fileSize * 8 * 1000 / 128000).round();

      return RecordingResult(
        file: file,
        duration: durationInMillis,
      );
    } catch (e) {
      _logger.e('停止录音失败', error: e);
      return null;
    } finally {
      // 无论成功与否,确保状态被重置
      _isRecording = false;
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
        // 删除临时目录中的所有文件,但保留目录
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
