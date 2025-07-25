import 'package:device_info_plus/device_info_plus.dart';

/// 版本信息平台相关操作（存根实现）

/// 获取平台特定的版本信息
Future<String> getPlatformSpecificInfo(DeviceInfoPlugin deviceInfo) async {
  return 'Unknown Platform';
}

/// 获取平台名称
String getPlatformName() {
  return 'Unknown';
}