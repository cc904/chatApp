/// 应用全局配置
///
/// 这个类负责管理应用的全局配置选项,如服务器URL等。
/// 使用单例模式确保全应用范围内配置一致。
class AppConfig {
  // 服务端配置
  // String serverUrl = 'http://127.0.0.1:3000';
  String serverUrl = 'http://d2.orb.local:3000';

  // 单例模式
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();
}
