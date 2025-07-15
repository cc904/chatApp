import 'package:cc/core/services/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知设置服务
/// 
/// 管理用户的通知偏好设置，包括：
/// - 通知开关
/// - 声音、振动、LED设置  
/// - 勿扰模式
/// - 通知类型过滤
class NotificationSettingsService {
  static final NotificationSettingsService _instance = NotificationSettingsService._internal();
  static NotificationSettingsService get instance => _instance;
  NotificationSettingsService._internal();

  final LogService _logger = LogService.instance;
  SharedPreferences? _prefs;

  /// 初始化服务
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.i('通知设置服务初始化成功');
    } catch (error) {
      _logger.e('通知设置服务初始化失败', error: error);
    }
  }

  /// 检查是否应该显示通知
  /// 
  /// 根据用户设置决定是否应该显示通知
  bool shouldShowNotification() {
    if (_prefs == null) return true; // 默认显示

    try {
      // 检查通知总开关
      final notificationsEnabled = _prefs!.getBool('notifications_enabled') ?? true;
      return notificationsEnabled;
    } catch (error) {
      _logger.e('检查通知设置失败', error: error);
      return true; // 出错时默认显示通知
    }
  }

  /// 获取通知样式设置
  /// 
  /// 返回用户配置的通知样式（声音、振动等）
  NotificationStyle getNotificationStyle() {
    if (_prefs == null) return NotificationStyle.defaultStyle();

    try {
      return NotificationStyle(
        soundEnabled: _prefs!.getBool('notification_sound') ?? true,
        vibrationEnabled: _prefs!.getBool('notification_vibration') ?? true,
        showPreview: _prefs!.getBool('notification_preview') ?? true,
        groupMessages: _prefs!.getBool('notification_group') ?? true,
      );
    } catch (error) {
      _logger.e('获取通知样式设置失败', error: error);
      return NotificationStyle.defaultStyle();
    }
  }


  /// 获取通知设置状态
  Map<String, dynamic> getSettingsStatus() {
    if (_prefs == null) {
      return {
        'initialized': false,
        'notificationsEnabled': true,
      };
    }

    return {
      'initialized': true,
      'notificationsEnabled': _prefs!.getBool('notifications_enabled') ?? true,
      'soundEnabled': _prefs!.getBool('notification_sound') ?? true,
      'vibrationEnabled': _prefs!.getBool('notification_vibration') ?? true,
    };
  }

  /// 快速切换通知开关
  Future<bool> toggleNotifications() async {
    if (_prefs == null) return false;

    try {
      final current = _prefs!.getBool('notifications_enabled') ?? true;
      await _prefs!.setBool('notifications_enabled', !current);
      
      _logger.i('通知开关已切换', extra: {'enabled': !current});
      return !current;
    } catch (error) {
      _logger.e('切换通知开关失败', error: error);
      return false;
    }
  }

}

/// 通知样式配置
class NotificationStyle {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showPreview;
  final bool groupMessages;

  const NotificationStyle({
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.showPreview,
    required this.groupMessages,
  });

  static NotificationStyle defaultStyle() {
    return const NotificationStyle(
      soundEnabled: true,
      vibrationEnabled: true,
      showPreview: true,
      groupMessages: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showPreview': showPreview,
      'groupMessages': groupMessages,
    };
  }
}