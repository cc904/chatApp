import 'dart:io';

/// 网络诊断工具 - IO平台实现

/// 获取系统网络信息
Future<Map<String, dynamic>> getSystemNetworkInfo() async {
  try {
    return {
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'hostname': Platform.localHostname,
      'numberOfProcessors': Platform.numberOfProcessors,
      'environment': Platform.environment.keys.where((key) => 
        key.toLowerCase().contains('proxy') || 
        key.toLowerCase().contains('network')).toList(),
    };
  } catch (e) {
    return {'error': e.toString()};
  }
}