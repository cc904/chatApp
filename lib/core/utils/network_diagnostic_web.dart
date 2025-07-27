/// 网络诊断工具 - Web平台实现

/// 获取系统网络信息
Future<Map<String, dynamic>> getSystemNetworkInfo() async {
  try {
    return {
      'platform': 'Web',
      'platformVersion': 'Web Browser',
      'hostname': 'localhost',
      'numberOfProcessors': 1,
      'environment': [], // Web平台无环境变量访问
    };
  } catch (e) {
    return {'error': e.toString()};
  }
}