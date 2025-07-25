import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 设备管理器平台相关操作（IO平台实现）

/// 获取标准化的平台名称
/// 与 VersionInfoService.platformName 保持一致
String getStandardizedPlatformName() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}

/// 获取操作系统版本
String getOperatingSystemVersion() {
  return Platform.operatingSystemVersion;
}

/// 检查是否为移动平台
bool isMobilePlatform() {
  return Platform.isAndroid || Platform.isIOS;
}

/// 检查字符串是否包含非ASCII字符
bool _containsNonAscii(String input) {
  return RegExp(r'[^\x20-\x7E]').hasMatch(input);
}

/// 清理字符串用于HTTP头部，移除非ASCII字符
String _sanitizeForHeader(String input) {
  if (input.isEmpty) return input;
  
  // 如果包含非ASCII字符，移除它们
  if (_containsNonAscii(input)) {
    String sanitized = input.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
    // 移除多余的空格
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return sanitized;
  }
  
  return input;
}

/// 获取详细设备信息
Future<Map<String, String>> getDetailedDeviceInfo(String deviceId, PackageInfo packageInfo) async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  
  // 使用标准化的设备类型名称
  String deviceType = getStandardizedPlatformName();
  String deviceModel = 'Unknown';
  String osVersion = Platform.operatingSystemVersion;

  // 获取具体设备信息
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
    deviceModel = '${info.manufacturer} ${info.model}';
    osVersion = 'Android ${info.version.release} (API ${info.version.sdkInt})';
  } else if (Platform.isIOS) {
    IosDeviceInfo info = await deviceInfoPlugin.iosInfo;
    deviceModel = info.model;
    osVersion = '${info.systemName} ${info.systemVersion}';
  } else if (Platform.isMacOS) {
    MacOsDeviceInfo info = await deviceInfoPlugin.macOsInfo;
    deviceModel = info.model;
    // 清理macOS版本信息，移除中文字符
    final cleanOsRelease = _sanitizeForHeader(info.osRelease);
    osVersion = 'macOS $cleanOsRelease';
  } else if (Platform.isWindows) {
    WindowsDeviceInfo info = await deviceInfoPlugin.windowsInfo;
    deviceModel = info.computerName;
    osVersion = 'Windows ${info.displayVersion}';
  } else if (Platform.isLinux) {
    LinuxDeviceInfo info = await deviceInfoPlugin.linuxInfo;
    deviceModel = info.name;
    osVersion = '${info.prettyName} (${info.version})';
  }

  // 清理设备型号信息，防止HTTP头部问题
  deviceModel = _sanitizeForHeader(deviceModel);
  osVersion = _sanitizeForHeader(osVersion);

  return {
    'deviceType': deviceType,
    'deviceModel': deviceModel,
    'osVersion': osVersion,
    'appVersion': packageInfo.version,
  };
}