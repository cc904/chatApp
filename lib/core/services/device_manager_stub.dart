import 'package:package_info_plus/package_info_plus.dart';

/// 设备管理器平台相关操作（存根实现）

/// 获取标准化的平台名称
String getStandardizedPlatformName() {
  throw UnsupportedError('此平台不支持平台名称获取');
}

/// 获取操作系统版本
String getOperatingSystemVersion() {
  throw UnsupportedError('此平台不支持操作系统版本获取');
}

/// 检查是否为移动平台
bool isMobilePlatform() {
  throw UnsupportedError('此平台不支持平台类型检查');
}

/// 获取详细设备信息
Future<Map<String, String>> getDetailedDeviceInfo(String deviceId, PackageInfo packageInfo) async {
  throw UnsupportedError('此平台不支持详细设备信息获取');
}