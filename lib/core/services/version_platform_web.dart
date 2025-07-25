import 'package:device_info_plus/device_info_plus.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// 版本信息平台相关操作（Web平台实现）

/// 获取平台特定的版本信息
Future<String> getPlatformSpecificInfo(DeviceInfoPlugin deviceInfo) async {
  try {
    // 在Web平台获取浏览器信息
    final userAgent = html.window.navigator.userAgent;
    
    // 简单解析UserAgent
    String browserInfo = 'Unknown Browser';
    String osInfo = 'Unknown OS';
    
    if (userAgent.contains('Chrome')) {
      browserInfo = 'Chrome';
    } else if (userAgent.contains('Firefox')) {
      browserInfo = 'Firefox';
    } else if (userAgent.contains('Safari')) {
      browserInfo = 'Safari';
    } else if (userAgent.contains('Edge')) {
      browserInfo = 'Edge';
    }
    
    if (userAgent.contains('Windows')) {
      osInfo = 'Windows';
    } else if (userAgent.contains('Mac')) {
      osInfo = 'macOS';
    } else if (userAgent.contains('Linux')) {
      osInfo = 'Linux';
    }
    
    return 'Web $browserInfo on $osInfo';
  } catch (e) {
    return 'Web Platform Info Error: $e';
  }
}

/// 获取平台名称
String getPlatformName() {
  return 'Web';
}