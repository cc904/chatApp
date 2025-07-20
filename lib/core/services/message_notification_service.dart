import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/message.dart' as models;
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/notification_action_service.dart';
import 'package:cc/core/services/notification_settings_service.dart';

/// 消息通知服务
/// 
/// 负责处理聊天应用的本地通知功能，包括：
/// - 新消息通知
/// - 通知分组（按会话）
/// - 通知动作（回复、标记已读）
/// - 通知权限管理
/// - 通知点击处理
class MessageNotificationService {
  static final MessageNotificationService _instance = MessageNotificationService._internal();
  static MessageNotificationService get instance => _instance;
  MessageNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final LogService _logger = LogService.instance;
  final NotificationSettingsService _settingsService = NotificationSettingsService.instance;
  
  bool _isInitialized = false;
  bool _hasPermission = false;

  /// 通知渠道配置
  static const String _channelId = 'chat_messages';
  static const String _channelName = '聊天消息';
  static const String _channelDescription = '接收新的聊天消息通知';

  /// 通知动作ID
  static const String _actionReply = 'reply';
  static const String _actionMarkRead = 'mark_read';

  /// 初始化通知服务
  Future<bool> initialize() async {
    if (_isInitialized) return _hasPermission;

    try {
      _logger.i('初始化消息通知服务');

      // Android配置
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS配置
      const iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: null, // 旧版本iOS兼容，现在不需要
      );

      // macOS配置
      const macosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // 初始化设置
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
      );

      // 初始化插件
      final initialized = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
      );

      if (initialized == true) {
        await _createNotificationChannels();
        _hasPermission = await _requestPermissions();
        _isInitialized = true;
        
        _logger.i('消息通知服务初始化成功', extra: {
          'hasPermission': _hasPermission,
        });
      } else {
        _logger.e('消息通知服务初始化失败');
        _isInitialized = false;
        _hasPermission = false;
      }

      return _hasPermission;
    } catch (error, stackTrace) {
      _logger.e('初始化消息通知服务异常', error: error, stackTrace: stackTrace);
      _isInitialized = false;
      _hasPermission = false;
      return false;
    }
  }

  /// 创建Android通知渠道
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      _logger.e('Android通知插件未找到，无法创建通知渠道');
      return;
    }

    try {
      // 首先创建通知渠道组
      const channelGroup = AndroidNotificationChannelGroup(
        'chat_group',
        '聊天通知',
        description: '所有聊天相关的通知',
      );

      await androidPlugin.createNotificationChannelGroup(channelGroup);
      _logger.d('Android通知渠道组创建完成');

      // 然后创建通知渠道
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color.fromARGB(255, 7, 193, 96), // 绿色LED
        groupId: 'chat_group',
      );

      await androidPlugin.createNotificationChannel(channel);
      _logger.d('Android通知渠道创建完成');
    } catch (error, stackTrace) {
      _logger.e('创建Android通知渠道失败', error: error, stackTrace: stackTrace);
      rethrow; // 重新抛出异常以便上层处理
    }
  }

  /// 请求通知权限
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin == null) {
          _logger.e('Android通知插件未找到');
          return false;
        }

        _logger.i('请求Android通知权限');
        
        // Android 13+ 需要请求通知权限
        final granted = await androidPlugin.requestNotificationsPermission();
        
        _logger.i('Android通知权限请求结果', extra: {
          'granted': granted,
          'platform': _getStandardizedPlatformName(),
        });
        
        return granted ?? true; // 旧版本默认有权限
        
      } else if (Platform.isIOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        
        if (iosPlugin == null) {
          _logger.e('iOS通知插件未找到');
          return false;
        }

        _logger.i('请求iOS通知权限');
        
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
        _logger.i('iOS通知权限请求结果', extra: {
          'granted': granted,
          'platform': _getStandardizedPlatformName(),
        });
        
        return granted ?? false;
        
      } else if (Platform.isMacOS) {
        final macosPlugin = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
        
        if (macosPlugin == null) {
          _logger.e('macOS通知插件未找到');
          return false;
        }

        _logger.i('请求macOS通知权限');
        
        final granted = await macosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
        _logger.i('macOS通知权限请求结果', extra: {
          'granted': granted,
          'platform': _getStandardizedPlatformName(),
        });
        
        return granted ?? false;
      }

      _logger.i('其他平台，默认授予通知权限');
      return true;
      
    } catch (error, stackTrace) {
      _logger.e('请求通知权限时发生异常', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// 显示新消息通知
  Future<void> showMessageNotification({
    required models.Message message,
    required Conversation conversation,
    required User sender,
    int? unreadCount,
  }) async {
    if (!_isInitialized || !_hasPermission) {
      const errorMsg = '通知服务未初始化或无权限，无法显示通知';
      _logger.w(errorMsg, extra: {
        'isInitialized': _isInitialized,
        'hasPermission': _hasPermission,
      });
      throw Exception(errorMsg);
    }

    // 检查通知总开关
    if (!_settingsService.shouldShowNotification()) {
      _logger.d('通知总开关已关闭，跳过显示通知');
      return;
    }

    // 获取通知样式设置
    final notificationStyle = _settingsService.getNotificationStyle();

    try {
      final notificationId = _generateNotificationId(conversation.conversationId);
      
      // 构建通知内容
      final title = _buildNotificationTitle(conversation, sender);
      final body = _buildNotificationBody(message, notificationStyle.showPreview);
      final groupKey = 'chat_${conversation.conversationId}';

      // Android特定配置
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        when: message.createdAt.millisecondsSinceEpoch,
        groupKey: notificationStyle.groupMessages ? groupKey : null,
        setAsGroupSummary: false,
        autoCancel: true,
        ongoing: false,
        silent: !notificationStyle.soundEnabled,
        // 设置通知样式
        styleInformation: _buildAndroidStyle(message, conversation, unreadCount, notificationStyle.showPreview),
        // 添加动作按钮
        actions: _buildNotificationActions(),
        // 设置通知图标和颜色
        icon: '@mipmap/ic_launcher',
        color: const Color.fromARGB(255, 7, 193, 96),
        // 设置LED和振动（兼容旧版本Android）
        enableLights: true,
        ledColor: const Color.fromARGB(255, 7, 193, 96),
        ledOnMs: 1000, // LED开启时间（毫秒）- Android O之前版本必需
        ledOffMs: 500, // LED关闭时间（毫秒）- Android O之前版本必需
        enableVibration: notificationStyle.vibrationEnabled,
        vibrationPattern: notificationStyle.vibrationEnabled ? Int64List.fromList([0, 250, 250, 250]) : null,
      );

      // iOS/macOS特定配置
      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: notificationStyle.soundEnabled,
        sound: notificationStyle.soundEnabled ? 'default' : null,
        badgeNumber: null, // 将在外部设置
        threadIdentifier: notificationStyle.groupMessages ? conversation.conversationId : null,
        attachments: null, // 可以添加媒体附件
        categoryIdentifier: 'chat_category',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // 显示通知
      await _plugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: _buildNotificationPayload(message, conversation),
      );

      // 显示分组摘要通知（Android）
      if (Platform.isAndroid && notificationStyle.groupMessages && unreadCount != null && unreadCount > 1) {
        await _showGroupSummaryNotification(conversation, unreadCount);
      }

      _logger.i('显示消息通知成功', extra: {
        'conversationId': conversation.conversationId,
        'messageId': message.messageId,
        'notificationId': notificationId,
      });

    } catch (error, stackTrace) {
      _logger.e('显示消息通知失败', error: error, stackTrace: stackTrace);
      
      // 如果是LED相关错误，尝试使用简化配置重试
      if (error.toString().contains('led') || error.toString().contains('LED')) {
        _logger.w('LED配置错误，尝试使用简化通知配置');
        try {
          await _showSimplifiedNotification(message, conversation, sender);
        } catch (retryError) {
          _logger.e('简化通知也失败', error: retryError);
        }
      }
    }
  }

  /// 显示简化版通知（去除LED配置）
  Future<void> _showSimplifiedNotification(
    models.Message message,
    Conversation conversation,
    User sender,
  ) async {
    final notificationStyle = _settingsService.getNotificationStyle();
    final notificationId = _generateNotificationId(conversation.conversationId);
    final title = _buildNotificationTitle(conversation, sender);
    final body = _buildNotificationBody(message, notificationStyle.showPreview);

    // 简化的Android配置，不包含LED设置
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      ongoing: false,
      silent: !notificationStyle.soundEnabled,
      icon: '@mipmap/ic_launcher',
      color: const Color.fromARGB(255, 7, 193, 96),
      enableVibration: notificationStyle.vibrationEnabled,
      vibrationPattern: notificationStyle.vibrationEnabled ? Int64List.fromList([0, 250, 250, 250]) : null,
    );

    final darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: notificationStyle.soundEnabled,
      sound: notificationStyle.soundEnabled ? 'default' : null,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: _buildNotificationPayload(message, conversation),
    );

    _logger.i('简化通知显示成功', extra: {
      'conversationId': conversation.conversationId,
      'messageId': message.messageId,
    });
  }

  /// 构建通知标题
  String _buildNotificationTitle(Conversation conversation, User sender) {
    if (conversation.type == ConversationType.private) {
      return sender.name;
    } else {
      return '${conversation.name ?? '群聊'} (${sender.name})';
    }
  }

  /// 构建通知内容
  String _buildNotificationBody(models.Message message, bool showPreview) {
    if (!showPreview) {
      return '新消息';
    }
    
    switch (message.type) {
      case models.MessageType.text:
        return message.text ?? '';
      case models.MessageType.image:
        return '[图片]';
      case models.MessageType.voice:
        return '[语音消息]';
      case models.MessageType.video:
        return '[视频]';
      case models.MessageType.file:
        return '[文件] ${message.fileName ?? ''}';
      default:
        return '[消息]';
    }
  }

  /// 构建Android通知样式
  StyleInformation _buildAndroidStyle(
    models.Message message, 
    Conversation conversation, 
    int? unreadCount,
    bool showPreview,
  ) {
    // 如果有多条未读消息，使用InboxStyle
    if (unreadCount != null && unreadCount > 1) {
      return BigTextStyleInformation(
        '$unreadCount条新消息',
        contentTitle: conversation.name ?? '聊天',
        summaryText: '聊天消息',
      );
    }

    // 单条消息使用BigTextStyle
    return BigTextStyleInformation(
      _buildNotificationBody(message, showPreview),
      contentTitle: conversation.name ?? '聊天',
    );
  }

  /// 构建通知动作按钮
  List<AndroidNotificationAction> _buildNotificationActions() {
    // 暂时移除动作按钮，简化通知功能
    return [];
    
    // 如果需要恢复动作按钮，取消注释以下代码：
    // return [
    //   const AndroidNotificationAction(
    //     _actionMarkRead,
    //     '标记已读',
    //     icon: DrawableResourceAndroidBitmap('@drawable/ic_mark_read'),
    //     cancelNotification: true,
    //   ),
    //   const AndroidNotificationAction(
    //     _actionReply,
    //     '回复',
    //     icon: DrawableResourceAndroidBitmap('@drawable/ic_reply'),
    //     inputs: [
    //       AndroidNotificationActionInput(
    //         label: '输入回复内容...',
    //         allowFreeFormInput: true,
    //       ),
    //     ],
    //   ),
    // ];
  }

  /// 显示分组摘要通知
  Future<void> _showGroupSummaryNotification(
    Conversation conversation, 
    int unreadCount,
  ) async {
    const summaryId = 0; // 摘要通知使用固定ID
    
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      groupKey: 'chat_${conversation.conversationId}',
      setAsGroupSummary: true,
      groupAlertBehavior: GroupAlertBehavior.children,
      styleInformation: BigTextStyleInformation(
        '有$unreadCount条新消息',
        contentTitle: '新消息',
        summaryText: '点击查看详情',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      summaryId,
      '新消息',
      '有$unreadCount条新消息',
      notificationDetails,
      payload: _buildNotificationPayload(null, conversation),
    );
  }

  /// 构建通知载荷数据
  String _buildNotificationPayload(models.Message? message, Conversation conversation) {
    return '${conversation.conversationId}|${message?.messageId ?? ''}';
  }

  /// 生成通知ID
  int _generateNotificationId(String conversationId) {
    return conversationId.hashCode.abs() % (1 << 31);
  }

  /// 通知点击处理
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationAction(payload, response.actionId);
    }
  }

  /// 后台通知点击处理
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    _onNotificationTapped(response);
  }

  /// 处理通知动作
  static void _handleNotificationAction(String payload, String? actionId) {
    final parts = payload.split('|');
    if (parts.length < 2) return;

    final conversationId = parts[0];
    final messageId = parts[1].isNotEmpty ? parts[1] : null;

    final logger = LogService.instance;
    
    logger.i('处理通知动作', extra: {
      'actionId': actionId,
      'conversationId': conversationId,
      'messageId': messageId,
    });

    switch (actionId) {
      case _actionMarkRead:
        _handleMarkAsRead(conversationId);
        break;
      case _actionReply:
        _handleQuickReply(conversationId);
        break;
      default:
        _handleOpenConversation(conversationId);
        break;
    }
  }

  /// 处理标记为已读动作
  static void _handleMarkAsRead(String conversationId) {
    NotificationActionService.instance.handleMarkAsRead(conversationId);
  }

  /// 处理快速回复动作
  static void _handleQuickReply(String conversationId) {
    NotificationActionService.instance.handleQuickReply(conversationId, null);
  }

  /// 处理打开会话动作
  static void _handleOpenConversation(String conversationId) {
    NotificationActionService.instance.handleOpenConversation(conversationId);
  }

  /// 清除会话通知
  Future<void> clearConversationNotifications(String conversationId) async {
    final notificationId = _generateNotificationId(conversationId);
    await _plugin.cancel(notificationId);
    
    _logger.d('清除会话通知', extra: {'conversationId': conversationId});
  }

  /// 清除所有通知
  Future<void> clearAllNotifications() async {
    await _plugin.cancelAll();
    _logger.d('清除所有通知');
  }

  /// 检查通知权限状态
  Future<bool> checkPermissionStatus() async {
    if (!_isInitialized) {
      _logger.w('通知服务未初始化，无法检查权限状态');
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin == null) {
          _logger.w('Android通知插件未找到，无法检查权限');
          return false;
        }

        final enabled = await androidPlugin.areNotificationsEnabled();
        
        _logger.d('Android通知权限检查', extra: {
          'enabled': enabled,
          'storedPermission': _hasPermission,
          'platform': _getStandardizedPlatformName(),
        });
        
        return enabled ?? false;
        
      } else if (Platform.isIOS) {
        _logger.d('iOS平台权限检查', extra: {
          'platform': _getStandardizedPlatformName(),
          'storedPermission': _hasPermission,
        });
        
        // iOS 权限状态通常在初始化后不会改变，使用存储的值
        return _hasPermission;
        
      } else if (Platform.isMacOS) {
        _logger.d('macOS平台权限检查', extra: {
          'platform': _getStandardizedPlatformName(),
          'storedPermission': _hasPermission,
        });
        
        // macOS 可以检查实时权限状态
        final macosPlugin = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
        
        if (macosPlugin == null) {
          _logger.w('macOS通知插件未找到，返回存储的权限状态');
          return _hasPermission;
        }

        try {
          // 对于 macOS，我们可以尝试检查权限状态
          // 但这个 API 可能不可用，所以我们先返回存储的状态
          return _hasPermission;
        } catch (e) {
          _logger.d('macOS权限状态检查失败，返回存储状态', extra: {'error': e.toString()});
          return _hasPermission;
        }
      }
      
      _logger.d('其他平台权限检查', extra: {
        'platform': _getStandardizedPlatformName(),
        'storedPermission': _hasPermission,
      });
      
      return _hasPermission;
      
    } catch (error, stackTrace) {
      _logger.e('检查通知权限状态时发生异常', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// 获取通知服务状态（用于调试）
  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'hasPermission': _hasPermission,
    };
  }

  /// 重新请求通知权限
  /// 用户可以调用此方法来重新授予权限
  Future<bool> requestPermissionAgain() async {
    if (!_isInitialized) {
      _logger.w('通知服务未初始化，无法重新请求权限');
      return false;
    }

    _logger.i('用户主动重新请求通知权限');
    
    final granted = await _requestPermissions();
    _hasPermission = granted;
    
    _logger.i('重新请求通知权限结果', extra: {
      'granted': granted,
    });
    
    return granted;
  }

  /// 获取当前角标数量
  Future<int?> getBadgeCount() async {
    if (Platform.isIOS || Platform.isMacOS) {
      // iOS 不再支持直接获取角标数量，需要在应用层维护
      return null;
    }
    return null;
  }

  /// 设置应用角标数量
  Future<void> setBadgeCount(int count) async {
    if (Platform.isIOS || Platform.isMacOS) {
      // iOS 角标需要在应用层手动维护
      _logger.d('设置应用角标（iOS）', extra: {'count': count});
    }
    _logger.d('设置应用角标', extra: {'count': count});
  }

  /// 获取标准化的平台名称
  String _getStandardizedPlatformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// 销毁服务
  void dispose() {
    _isInitialized = false;
    _hasPermission = false;
    _logger.d('消息通知服务已销毁');
  }
}