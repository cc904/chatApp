import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

/// 媒体服务类
/// 负责处理图片、视频、语音录制、文件选择和下载
class MediaService {
  final _logger = LogService.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Uuid _uuid = const Uuid();
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
    sendTimeout: const Duration(seconds: 30),
  ));

  // 录音状态变量
  String? _currentRecordingPath;
  bool _isRecording = false;

  // 单例模式
  static final MediaService _instance = MediaService._internal();

  factory MediaService() {
    return _instance;
  }

  MediaService._internal();

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
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: recordPath,
        );

        _isRecording = true;
        return true;
      } else {
        _logger.w('没有录音权限');
        return false;
      }
    } catch (error) {
      _logger.e('开始录音失败', error: error, stackTrace: StackTrace.current);
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
    } catch (error) {
      _logger.e('停止录音失败', error: error, stackTrace: StackTrace.current);
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
    } catch (error) {
      _logger.e('保存文件失败', error: error, stackTrace: StackTrace.current);
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
    } catch (error) {
      _logger.e('清理临时文件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 检查录音是否正在进行
  bool get isRecording => _isRecording;

  /// 选择图片（相册或相机）
  Future<File?> pickImage({required bool fromCamera}) async {
    try {
      // 在macOS上，相机功能存在限制，强制使用相册
      ImageSource source;
      if (fromCamera && Platform.isMacOS) {
        _logger.w('macOS平台不支持相机功能，自动切换到相册选择');
        source = ImageSource.gallery;
      } else {
        source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // 压缩质量
      );

      if (pickedFile == null) {
        return null; // 用户取消选择
      }

      // 将XFile转换为File并返回
      return File(pickedFile.path);
    } catch (error) {
      _logger.e('选择图片失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 选择视频
  Future<File?> pickVideo({required bool fromCamera}) async {
    try {
      // 在macOS上，相机功能存在限制，强制使用相册
      ImageSource source;
      if (fromCamera && Platform.isMacOS) {
        _logger.w('macOS平台不支持相机录制视频，自动切换到相册选择');
        source = ImageSource.gallery;
      } else {
        source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      }

      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
      );

      if (pickedFile == null) {
        return null; // 用户取消选择
      }

      // 将XFile转换为File并返回
      return File(pickedFile.path);
    } catch (error) {
      _logger.e('选择视频失败', error: error, stackTrace: StackTrace.current);
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

      return File(filePath!);
    } catch (error) {
      _logger.e('选择文件失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 下载文件到本地
  Future<String?> downloadFile(String url, String fileName) async {
    try {
      _logger.i('开始下载文件: $url');

      // 获取Downloads目录
      final Directory? downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('无法获取Downloads目录');
      }

      final String savePath = path.join(downloadsDir.path, fileName);
      _logger.i('保存路径: $savePath');

      // 使用Dio下载文件
      await _dio.download(
        url,
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 300,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            _logger.i('下载进度: $progress%');
          }
        },
      );

      // 验证文件是否下载成功
      final file = File(savePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        _logger.i('文件下载成功: $savePath, 大小: $fileSize字节');
        return savePath;
      } else {
        throw Exception('下载完成但文件不存在');
      }
    } catch (error) {
      _logger.e('下载文件失败', error: error);
      rethrow;
    }
  }
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
