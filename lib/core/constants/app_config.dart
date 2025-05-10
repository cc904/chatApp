/// 应用全局配置
///
/// 这个类负责管理应用的全局配置选项,如模拟模式、服务器URL等。
/// 使用单例模式确保全应用范围内配置一致。
class AppConfig {
  // 服务端配置
  String serverUrl = 'http://[::1]:3000';

  // 模拟模式配置
  bool isSimulationMode = false;

  // 默认用户ID
  final String defaultUserId = 'user_123456';

  // 单例模式
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();
}
