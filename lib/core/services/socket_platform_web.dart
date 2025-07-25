import 'package:web/web.dart' as web;

/// Socket平台相关操作（Web平台实现）

/// 获取平台操作系统版本
String getPlatformOSVersion() {
  try {
    final userAgent = web.window.navigator.userAgent;
    
    // 简单解析UserAgent获取操作系统信息
    if (userAgent.contains('Windows NT')) {
      final regex = RegExp(r'Windows NT (\d+\.\d+)');
      final match = regex.firstMatch(userAgent);
      if (match != null) {
        return 'Windows ${match.group(1)}';
      }
      return 'Windows';
    } else if (userAgent.contains('Mac OS X')) {
      final regex = RegExp(r'Mac OS X (\d+_\d+_?\d*)');
      final match = regex.firstMatch(userAgent);
      if (match != null) {
        final version = match.group(1)!.replaceAll('_', '.');
        return 'macOS $version';
      }
      return 'macOS';
    } else if (userAgent.contains('Linux')) {
      return 'Linux';
    } else if (userAgent.contains('CrOS')) {
      return 'Chrome OS';
    }
    
    return 'Web Platform';
  } catch (e) {
    return 'Web Platform (Unknown Version)';
  }
}

/// 获取标准化的平台名称
String getStandardizedPlatformName() {
  return 'Web';
}