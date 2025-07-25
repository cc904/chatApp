import 'package:package_info_plus/package_info_plus.dart';
import 'package:web/web.dart' as web;

/// 设备管理器平台相关操作（Web平台实现）

/// 获取标准化的平台名称
String getStandardizedPlatformName() {
  return 'Web';
}

/// 获取操作系统版本
String getOperatingSystemVersion() {
  // Web平台可以尝试从userAgent中获取信息，但这里简化处理
  return 'Web Browser';
}

/// 检查是否为移动平台
bool isMobilePlatform() {
  // Web平台可以通过userAgent检测是否为移动设备
  // 这里简化处理，假设不是移动平台
  return false;
}

/// 获取详细设备信息
Future<Map<String, String>> getDetailedDeviceInfo(String deviceId, PackageInfo packageInfo) async {
  try {
    // Web平台尝试从UserAgent获取基本信息
    final userAgent = web.window.navigator.userAgent;
    
    // 简单解析UserAgent获取浏览器和OS信息
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
    } else if (userAgent.contains('Android')) {
      osInfo = 'Android';
    } else if (userAgent.contains('iOS')) {
      osInfo = 'iOS';
    }
    
    return {
      'deviceType': 'Web',
      'deviceModel': browserInfo,
      'osVersion': '$osInfo (Web)',
      'appVersion': packageInfo.version,
    };
  } catch (e) {
    // 如果获取失败，返回基本信息
    return {
      'deviceType': 'Web',
      'deviceModel': 'Web Browser',
      'osVersion': 'Web Platform',
      'appVersion': packageInfo.version,
    };
  }
}