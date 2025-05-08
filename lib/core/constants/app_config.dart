/// 应用全局配置
///
/// 这个类负责管理应用的全局配置选项，如模拟模式、服务器URL等。
/// 使用单例模式确保全应用范围内配置一致。
class AppConfig {
  // 单例实例
  static final AppConfig _instance = AppConfig._internal();

  // 工厂构造函数
  factory AppConfig() {
    return _instance;
  }

  // 私有构造函数
  AppConfig._internal();

  // 全局配置项
  /// 模拟模式 - 当开启时，应用将使用本地模拟数据而不是真实网络连接
  ///
  /// 模拟模式下：
  /// 1. 所有网络请求使用本地模拟数据，不会发送实际网络请求
  /// 2. 联系人、会话和消息等数据从模拟数据库获取
  /// 3. socket.io连接将被模拟，不会真正连接到服务器
  bool isSimulationMode = true; // 默认使用模拟模式

  /// 服务器URL - 实时通信和API请求的基础URL
  String serverUrl = 'http://localhost:3000'; // 默认服务器URL

  /// 重置为默认配置
  void resetToDefaults() {
    isSimulationMode = true;
    serverUrl = 'http://localhost:3000';
  }
}
