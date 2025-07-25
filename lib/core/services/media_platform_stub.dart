import 'package:image_picker/image_picker.dart';

/// 媒体服务平台相关操作（存根实现）

/// 检查是否为macOS平台
bool isMacOSPlatform() {
  throw UnsupportedError('Platform check is not supported on this platform');
}

/// 检查是否为Web平台
bool isWebPlatform() {
  throw UnsupportedError('Platform check is not supported on this platform');
}

/// 平台处理XFile转换
Future<dynamic> handleXFileForPlatform(XFile xFile) async {
  throw UnsupportedError('XFile handling is not supported on this platform');
}