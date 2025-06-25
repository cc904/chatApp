/// 应用全局配置
///
/// 这个类负责管理应用的全局配置选项,如服务器URL等。
/// 使用单例模式确保全应用范围内配置一致。
///
/// 🔄 支持多域名后备机制:
/// - 主域名失效时自动切换到备用域名
/// - 简单的故障转移逻辑
class AppConfig {
  // 服务器地址列表 (按优先级排序)
  static const List<String> serverUrls = [
    'http://d2.orb.local:3000', // 主域名
    'http://127.0.0.1:3000', // 本地回退
    'http://192.168.1.100:3000', // 内网IP回退
    'https://backup.example.com:3000', // 云端备用
  ];

  // 当前使用的服务器索引
  int _currentServerIndex = 0;

  // 单例模式
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// 获取当前服务器URL
  String get serverUrl => serverUrls[_currentServerIndex];

  /// 获取当前服务器索引
  int get currentServerIndex => _currentServerIndex;

  /// 获取所有服务器地址
  List<String> get allServerUrls => List.unmodifiable(serverUrls);

  /// 设置服务器URL (通过URL查找对应索引)
  void setServerUrl(String url) {
    final index = serverUrls.indexOf(url);
    if (index != -1) {
      _currentServerIndex = index;
    } else {
      // 如果URL不在预定义列表中，保持当前索引不变
      // 在实际应用中可能需要支持自定义URL
    }
  }

  /// 切换到下一个可用服务器
  /// 返回: 是否成功切换到新服务器
  bool switchToNextServer() {
    if (_currentServerIndex < serverUrls.length - 1) {
      _currentServerIndex++;
      return true;
    }
    // 如果已经是最后一个服务器，重置到第一个
    _currentServerIndex = 0;
    return false;
  }

  /// 重置到第一个服务器
  void resetToFirstServer() {
    _currentServerIndex = 0;
  }

  /// 检查是否还有备用服务器可以尝试
  bool hasNextServer() {
    return _currentServerIndex < serverUrls.length - 1;
  }

  /// 获取当前服务器的显示名称
  String get currentServerName {
    switch (_currentServerIndex) {
      case 0:
        return '内网主服务器';
      case 1:
        return '本地开发服务器';
      case 2:
        return '内网IP服务器';
      case 3:
        return '云端备用服务器';
      default:
        return '未知服务器';
    }
  }

  /// 获取所有服务器的显示信息
  List<Map<String, String>> get serverDisplayInfo {
    return [
      {'name': '内网主服务器', 'url': serverUrls[0]},
      {'name': '本地开发服务器', 'url': serverUrls[1]},
      {'name': '内网IP服务器', 'url': serverUrls[2]},
      {'name': '云端备用服务器', 'url': serverUrls[3]},
    ];
  }
}
