import 'dart:developer' as dev;
import 'package:stack_trace/stack_trace.dart';

/// 日志服务
/// 提供统一的日志记录功能，自动添加文件名和函数名信息
class LogService {
  static final Map<String, LogService> _instances = {};

  final String _fileName;

  factory LogService(String fileName) {
    if (!_instances.containsKey(fileName)) {
      _instances[fileName] = LogService._internal(fileName);
    }
    return _instances[fileName]!;
  }

  LogService._internal(this._fileName);

  /// 获取当前文件名（不包含路径）
  String get _shortFileName {
    final parts = _fileName.split('/');
    final fileName = parts.last;
    return fileName.endsWith('.dart') ? fileName.substring(0, fileName.length - 5) : fileName;
  }

  /// 获取调用函数名
  String _getFunctionName() {
    try {
      final frames = Trace.current().frames;
      // 需要找到第一个不在LogService类中的帧
      for (var i = 0; i < frames.length; i++) {
        final frame = frames[i];
        final member = frame.member ?? '';
        // 跳过LogService类中的方法
        if (!member.contains('LogService')) {
          // 提取函数名
          final parts = member.split('.');
          // 添加行号信息
          return ':${frame.line} -> ${parts.length > 1 ? parts.last : member}';
        }
      }
    } catch (e) {
      // 无法获取函数名时，返回unknown
    }
    return 'unknown';
  }

  /// 格式化日志消息
  String _formatMessage(String message, {Map<String, dynamic>? extra, Object? error}) {
    final funcName = _getFunctionName();
    var formattedMessage = '[ $_shortFileName$funcName ] $message';
    if (extra != null && extra.isNotEmpty) {
      formattedMessage += ' : $extra';
    }
    if (error != null) {
      formattedMessage += ' 错误: $error';
    }
    return formattedMessage;
  }

  /// 记录调试信息
  void d(String message, {Map<String, dynamic>? extra}) {
    dev.log(_formatMessage(message, extra: extra), name: 'DEBUG', level: 0);
  }

  /// 记录信息
  void i(String message, {Map<String, dynamic>? extra}) {
    dev.log(_formatMessage(message, extra: extra), name: 'INFO>', level: 0);
  }

  /// 记录警告
  void w(String message, {Map<String, dynamic>? extra}) {
    dev.log(_formatMessage(message, extra: extra), name: 'WARNING', level: 0);
  }

  /// 记录错误
  void e(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    dev.log(_formatMessage(message, extra: extra, error: error), name: 'ERROR', level: 0, error: error, stackTrace: stackTrace);
  }

  /// 记录致命错误
  void wtf(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    dev.log(_formatMessage(message, extra: extra, error: error), name: 'FATAL', level: 0, error: error, stackTrace: stackTrace);
  }
}
