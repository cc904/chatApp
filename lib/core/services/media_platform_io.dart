import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// 媒体服务平台相关操作（IO平台实现）

/// 检查是否为macOS平台
bool isMacOSPlatform() {
  return Platform.isMacOS;
}

/// 检查是否为Web平台
bool isWebPlatform() {
  return false;
}

/// IO平台处理XFile转换
/// 在IO平台上，可以将XFile转换为File
Future<dynamic> handleXFileForPlatform(XFile xFile) async {
  // IO平台可以转换为File
  return File(xFile.path);
}