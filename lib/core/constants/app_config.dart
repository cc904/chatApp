/// 应用全局配置
///
/// 这个类负责管理应用的全局配置选项,如服务器URL等。
/// 使用单例模式确保全应用范围内配置一致。
///
/// 🔄 支持多域名后备机制:
/// - 主域名失效时自动切换到备用域名
/// - 简单的故障转移逻辑
/// - 支持服务器切换的持久化存储
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cc/core/services/log_service.dart';

class AppConfig {
  // 服务器地址列表 (按优先级排序)
  static const List<String> serverUrls = [
    'http://13.158.26.10:7030', // 云端服务器
    'http://d2.orb.local:3000', // 本地服务器
  ];

  // 当前使用的服务器索引
  int _currentServerIndex = 0;

  // 日志器
  final _logger = LogService.instance;

  // 存储键名
  static const String _serverIndexKey = 'cc_server_index';

  // 单例模式
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal() {
    _loadServerIndex();
  }

  /// 从持久化存储加载服务器索引
  Future<void> _loadServerIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_serverIndexKey);
      if (savedIndex != null &&
          savedIndex >= 0 &&
          savedIndex < serverUrls.length) {
        _currentServerIndex = savedIndex;
        _logger.i('🔗 从存储加载服务器索引', extra: {
          'index': _currentServerIndex,
          'serverUrl': serverUrl,
          'serverName': currentServerName,
        });
      } else {
        _logger.i('🔗 使用默认服务器索引', extra: {
          'index': _currentServerIndex,
          'serverUrl': serverUrl,
          'serverName': currentServerName,
        });
      }
    } catch (e) {
      _logger.e('加载服务器索引失败', error: e);
    }
  }

  /// 保存服务器索引到持久化存储
  Future<void> _saveServerIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_serverIndexKey, _currentServerIndex);
      _logger.i('💾 保存服务器索引到存储', extra: {
        'index': _currentServerIndex,
        'serverUrl': serverUrl,
        'serverName': currentServerName,
      });
    } catch (e) {
      _logger.e('保存服务器索引失败', error: e);
    }
  }

  /// 获取当前服务器URL
  String get serverUrl => serverUrls[_currentServerIndex];

  /// 获取当前服务器索引
  int get currentServerIndex => _currentServerIndex;

  /// 获取所有服务器地址
  List<String> get allServerUrls => List.unmodifiable(serverUrls);

  /// 设置服务器URL (通过URL查找对应索引)
  Future<void> setServerUrl(String url) async {
    final index = serverUrls.indexOf(url);
    if (index != -1) {
      _currentServerIndex = index;
      await _saveServerIndex();
    } else {
      // 如果URL不在预定义列表中，保持当前索引不变
      // 在实际应用中可能需要支持自定义URL
    }
  }

  /// 设置服务器索引
  Future<void> setServerIndex(int index) async {
    if (index >= 0 && index < serverUrls.length) {
      _currentServerIndex = index;
      await _saveServerIndex();
    }
  }

  /// 切换到下一个可用服务器
  /// 返回: 是否成功切换到新服务器
  Future<bool> switchToNextServer() async {
    if (_currentServerIndex < serverUrls.length - 1) {
      _currentServerIndex++;
      await _saveServerIndex();
      return true;
    }
    // 如果已经是最后一个服务器，重置到第一个
    _currentServerIndex = 0;
    await _saveServerIndex();
    return false;
  }

  /// 重置到第一个服务器
  Future<void> resetToFirstServer() async {
    _currentServerIndex = 0;
    await _saveServerIndex();
  }

  /// 检查是否还有备用服务器可以尝试
  bool hasNextServer() {
    return _currentServerIndex < serverUrls.length - 1;
  }

  /// 获取当前服务器的显示名称
  String get currentServerName {
    switch (_currentServerIndex) {
      case 0:
        return '云端服务器';
      case 1:
        return '本地服务器';
      default:
        return '未知服务器';
    }
  }

  /// 获取所有服务器的显示信息
  List<Map<String, String>> get serverDisplayInfo {
    return [
      {'name': '云端服务器', 'url': serverUrls[0]},
      {'name': '本地服务器', 'url': serverUrls[1]},
    ];
  }

  /// 初始化配置（确保配置已加载）
  Future<void> init() async {
    await _loadServerIndex();
  }
}
