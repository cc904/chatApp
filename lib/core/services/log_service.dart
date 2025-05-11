import 'package:logger/logger.dart';
import 'package:stack_trace/stack_trace.dart';

class VSCodeLogPrinter extends LogPrinter {
  static final Map<Level, String> _levelEmojis = {
    Level.trace: '🔍',
    Level.debug: '🐛',
    Level.info: '💡',
    Level.warning: '⚠️',
    Level.error: '❌',
    Level.fatal: '👾',
  };

  // 添加灰黑色文本
  static String _lightX(String text) => '\x1B[38;2;30;30;30m$text\x1B[0m';

  // 项目根目录
  static const String projectRoot = '/Users/ad/Dev/Flutter/cc';

  // 将 package: URI 转换为 file:// URI
  static String _convertToFileUri(String uri) {
    if (uri.startsWith('package:')) {
      final parts = uri.substring(8).split('/');
      final relativePath = parts.sublist(1).join('/');
      return 'file://$projectRoot/lib/$relativePath';
    }
    return uri;
  }

  @override
  List<String> log(LogEvent event) {
    final emoji = _levelEmojis[event.level]!;
    final message = event.message;
    final stackTrace = event.stackTrace;

    final buffer = StringBuffer();

    // 添加日志级别
    final levelColor = _getLevelColor(event.level);
    final levelName = event.level.name.toUpperCase();

    // 获取调用堆栈信息
    String? atText;
    String? className;
    final trace = Trace.current();
    final frames = trace.frames;
    for (var i = 1; i < frames.length; i++) {
      final frame = frames[i];
      final member = frame.member ?? '';
      final uri = frame.uri.toString();
      if (!uri.contains('logger') && !member.contains('LogService')) {
        final fileUri = _convertToFileUri(uri);
        final location = '$fileUri:${frame.line}:${frame.column}';
        atText = 'at $member ($location)';
        // 从成员名中提取类名
        final memberParts = member.split('.');
        if (memberParts.length > 1) {
          className = memberParts[0];
        }
        break;
      }
    }

    // 构建框框样式
    if (className != null) {
      buffer.write('$levelColor[${levelName.padRight(5)}] $emoji [ $className ] -> $message\x1B[0m');
    } else {
      buffer.write('$levelColor[${levelName.padRight(5)}] $emoji $message\x1B[0m');
    }

    // 如果有错误堆栈，显示它
    if (stackTrace != null) {
      // 直接使用传入的 stackTrace 字符串
      final lines = stackTrace.toString().split('\n');
      // 过滤出 package:cc 开头的行，并替换路径，同时过滤掉 at 开头的行
      final filteredLines = lines
          .where((line) => line.contains('package:cc') && !line.trim().startsWith('at'))
          .map((line) => line.replaceAll('package:cc', 'file:///Users/ad/Dev/Flutter/cc/lib'))
          .toList();
      // 显示堆栈帧，最多显示6行
      final maxLines = filteredLines.length > 6 ? 6 : filteredLines.length;

      for (var i = 0; i < maxLines; i++) {
        final line = filteredLines[i].trim();
        if (line.isNotEmpty) {
          // 使用不同的缩进符号来区分堆栈层级
          final indent = i == 0 ? '├─' : '│  ';
          buffer.write('\n$levelColor  $indent\x1B[30;2;50;50;50m $line');
        }
      }

      // 如果还有更多堆栈帧，显示省略号
      if (filteredLines.length > 6) {
        buffer.write('\n$levelColor  └─ ... 还有 ${filteredLines.length - 6} 个堆栈帧 ...\x1B[31;2;30;30;30m');
      }
    } else {
      // 如果没有堆栈信息，但有 at 信息，在新的一行显示
      if (atText != null) {
        buffer.write('\n                 ${_lightX(atText)}');
      }
    }

    return [buffer.toString()];
  }

  String _getLevelColor(Level level) {
    switch (level) {
      case Level.trace:
        return '\x1B[36m'; // 青色
      case Level.debug:
        return '\x1B[36m'; // 青色
      case Level.info:
        return '\x1B[32m'; // 绿色
      case Level.warning:
        return '\x1B[38;2;180;180;0m'; // 暗黄色
      case Level.error:
        return '\x1B[31m'; // 红色
      case Level.fatal:
        return '\x1B[35m'; // 紫色
      default:
        return '\x1B[0m'; // 默认颜色
    }
  }
}

/// 日志服务
/// 提供统一的日志记录功能
class LogService {
  static final LogService instance = LogService._();
  static final _logger = Logger(
    printer: VSCodeLogPrinter(),
  );

  LogService._();

  /// 格式化日志消息
  String _formatMessage(String message, {Map<String, dynamic>? extra, Object? error}) {
    var formattedMessage = message;
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
    _logger.d(_formatMessage(message, extra: extra));
  }

  /// 记录信息
  void i(String message, {Map<String, dynamic>? extra}) {
    _logger.i(_formatMessage(message, extra: extra));
  }

  /// 记录警告
  void w(String message, {Map<String, dynamic>? extra, StackTrace? stackTrace}) {
    _logger.w(_formatMessage(message, extra: extra), stackTrace: stackTrace);
  }

  /// 记录错误
  void e(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _logger.e(_formatMessage(message, extra: extra, error: error), error: error, stackTrace: stackTrace);
  }

  /// 记录致命错误
  void wtf(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _logger.f(_formatMessage(message, extra: extra, error: error), error: error, stackTrace: stackTrace);
  }
}
