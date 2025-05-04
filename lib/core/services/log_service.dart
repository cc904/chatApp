import 'dart:developer' as dev;

/// 日志服务
/// 提供统一的日志记录功能，自动添加文件名信息
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

  /// 格式化日志消息
  String _formatMessage(String message, {Map<String, dynamic>? extra, Object? error}) {
    var formattedMessage = '[$_shortFileName] $message';
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
