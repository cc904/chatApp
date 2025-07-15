import 'package:flutter/material.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/message_notification_service.dart';
import 'package:cc/core/services/notification_action_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知设置页面
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final LogService _logger = LogService.instance;
  
  // 通知设置状态
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showPreview = true;
  bool _groupMessages = true;
  
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _soundEnabled = prefs.getBool('notification_sound') ?? true;
        _vibrationEnabled = prefs.getBool('notification_vibration') ?? true;
        _showPreview = prefs.getBool('notification_preview') ?? true;
        _groupMessages = prefs.getBool('notification_group') ?? true;
        
      });
      
      _logger.i('通知设置已加载');
    } catch (error) {
      _logger.e('加载通知设置失败', error: error);
    }
  }

  /// 保存设置
  Future<void> _saveSettings({bool showMessage = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('notification_sound', _soundEnabled);
      await prefs.setBool('notification_vibration', _vibrationEnabled);
      await prefs.setBool('notification_preview', _showPreview);
      await prefs.setBool('notification_group', _groupMessages);
      
      
      _logger.i('通知设置已保存');
      
      if (showMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      _logger.e('保存通知设置失败', error: error);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存设置失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notificationSettings),
        actions: [
          TextButton(
            onPressed: () => _saveSettings(showMessage: true),
            child: Text(
              localizations.save,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // 通知总开关
          _buildSectionHeader('通知总设置'),
          _buildSwitchTile(
            title: '接收通知',
            subtitle: '开启后可以接收聊天消息通知',
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() {
                _notificationsEnabled = value;
              });
              
              // 自动保存设置
              await _saveSettings();
              
              if (value) {
                // 开启通知时检查权限
                await _checkNotificationPermission();
              }
            },
          ),
          
          // 通知权限状态
          _buildNotificationStatus(),
          
          if (_notificationsEnabled) ...[
            const Divider(),
            
            // 通知样式设置
            _buildSectionHeader('通知样式'),
            _buildSwitchTile(
              title: '声音',
              subtitle: '播放通知声音',
              value: _soundEnabled,
              onChanged: (value) async {
                setState(() {
                  _soundEnabled = value;
                });
                // 自动保存设置
                await _saveSettings();
              },
            ),
            _buildSwitchTile(
              title: '振动',
              subtitle: '通知时振动',
              value: _vibrationEnabled,
              onChanged: (value) async {
                setState(() {
                  _vibrationEnabled = value;
                });
                // 自动保存设置
                await _saveSettings();
              },
            ),
            _buildSwitchTile(
              title: '显示消息预览',
              subtitle: '在通知中显示消息内容',
              value: _showPreview,
              onChanged: (value) async {
                setState(() {
                  _showPreview = value;
                });
                // 自动保存设置
                await _saveSettings();
              },
            ),
            _buildSwitchTile(
              title: '分组消息',
              subtitle: '同一聊天的消息合并显示',
              value: _groupMessages,
              onChanged: (value) async {
                setState(() {
                  _groupMessages = value;
                });
                // 自动保存设置
                await _saveSettings();
              },
            ),
          ],
          
          const Divider(),
          
          // 高级设置
          _buildSectionHeader('高级设置'),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('重新请求权限'),
            subtitle: const Text('重新申请通知权限'),
            trailing: const Icon(Icons.security),
            onTap: _requestPermissionAgain,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool)? onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged != null ? (value) => onChanged(value) : null,
      activeColor: Colors.green,
    );
  }

  Widget _buildNotificationStatus() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getNotificationStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('检查通知状态...'),
          );
        }

        final status = snapshot.data!;
        final isInitialized = status['isInitialized'] as bool;
        final hasPermission = status['hasPermission'] as bool;

        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (isInitialized && hasPermission) {
          statusColor = Colors.green;
          statusText = '通知已启用';
          statusIcon = Icons.check_circle;
        } else if (isInitialized && !hasPermission) {
          statusColor = Colors.orange;
          statusText = '需要授予通知权限';
          statusIcon = Icons.warning;
        } else {
          statusColor = Colors.red;
          statusText = '通知服务未初始化';
          statusIcon = Icons.error;
        }

        return ListTile(
          leading: Icon(statusIcon, color: statusColor),
          title: const Text('通知状态'),
          subtitle: Text(statusText),
          trailing: !hasPermission 
            ? TextButton(
                onPressed: _requestPermissionAgain,
                child: const Text('授权'),
              )
            : null,
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getNotificationStatus() async {
    final serviceStatus = MessageNotificationService.instance.getServiceStatus();
    final actionServiceStatus = NotificationActionService.instance.getServiceStatus();
    
    return {
      ...serviceStatus,
      'actionServiceReady': actionServiceStatus['isInitialized'],
    };
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final hasPermission = await MessageNotificationService.instance.checkPermissionStatus();
      
      if (!hasPermission) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('需要通知权限'),
              content: const Text('要接收消息通知，请授予应用通知权限。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _requestPermissionAgain();
                  },
                  child: const Text('授权'),
                ),
              ],
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('检查通知权限失败', error: error);
    }
  }

  Future<void> _requestPermissionAgain() async {
    try {
      final granted = await MessageNotificationService.instance.requestPermissionAgain();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted ? '通知权限已授予' : '通知权限被拒绝'),
            backgroundColor: granted ? Colors.green : Colors.red,
          ),
        );
        
        // 刷新状态
        setState(() {});
      }
    } catch (error) {
      _logger.e('请求通知权限失败', error: error);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('请求权限失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


}