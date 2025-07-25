import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// 版本信息平台相关操作（IO平台实现）

/// 获取平台特定的版本信息
Future<String> getPlatformSpecificInfo(DeviceInfoPlugin deviceInfo) async {
  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return 'Android ${androidInfo.version.release} '
          '(API ${androidInfo.version.sdkInt}) '
          '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.systemName} ${iosInfo.systemVersion} '
          '${iosInfo.model}';
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return 'macOS ${macInfo.osRelease} '
          '${macInfo.model}';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return 'Windows ${windowsInfo.displayVersion} '
          '${windowsInfo.computerName}';
    }
    return 'Unknown Platform';
  } catch (e) {
    return 'Platform Info Error: $e';
  }
}

/// 获取平台名称
String getPlatformName() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}