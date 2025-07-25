import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// 媒体服务平台相关操作（Web平台实现）

/// 检查是否为macOS平台
bool isMacOSPlatform() {
  return false; // Web平台不是macOS
}

/// 检查是否为Web平台
bool isWebPlatform() {
  return true;
}

/// Web平台处理XFile转换
/// 在Web平台上，我们不能使用File，需要使用Uint8List或其他方式
Future<dynamic> handleXFileForPlatform(XFile xFile) async {
  // Web平台返回XFile本身，因为不能转换为File
  return xFile;
}