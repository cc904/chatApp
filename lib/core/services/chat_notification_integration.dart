import 'package:cc/core/services/message_notification_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/message.dart' as models;
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';

/// 聊天通知集成服务
/// 
/// 负责将聊天消息与通知系统集成，处理：
/// - 新消息通知触发
/// - 通知去重逻辑
/// - 应用状态检测
/// - 通知权限管理
class ChatNotificationIntegration {
  static final ChatNotificationIntegration _instance = ChatNotificationIntegration._internal();
  static ChatNotificationIntegration get instance => _instance;
  ChatNotificationIntegration._internal();

  final MessageNotificationService _notificationService = MessageNotificationService.instance;
  final LogService _logger = LogService.instance;
  
  // 记录最后一次通知的消息ID，避免重复通知
  final Set<String> _notifiedMessageIds = {};
  
  // 当前用户ID，用于过滤自己发送的消息
  String? _currentUserId;

  /// 设置当前用户ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _logger.d('设置当前用户ID', extra: {'userId': userId});
  }

  /// 处理新消息通知
  /// 
  /// 该方法应该在以下情况下调用：
  /// 1. Socket.io接收到新消息事件
  /// 2. 本地数据库有新消息插入
  /// 3. 聊天页面不在前台时
  Future<void> handleNewMessage({
    required models.Message message,
    required Conversation conversation,
    required User sender,
    required bool isAppInForeground,
    required bool isChatPageVisible,
    int? unreadCount,
  }) async {
    try {
      // 检查是否应该显示通知
      if (!_shouldShowNotification(
        message: message,
        isAppInForeground: isAppInForeground,
        isChatPageVisible: isChatPageVisible,
      )) {
        return;
      }

      // 显示通知
      await _notificationService.showMessageNotification(
        message: message,
        conversation: conversation,
        sender: sender,
        unreadCount: unreadCount,
      );

      // 记录已通知的消息
      _notifiedMessageIds.add(message.messageId);

      _logger.i('已显示消息通知', extra: {
        'messageId': message.messageId,
        'conversationId': conversation.conversationId,
        'senderName': sender.name,
      });

    } catch (error, stackTrace) {
      _logger.e('处理新消息通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 判断是否应该显示通知
  bool _shouldShowNotification({
    required models.Message message,
    required bool isAppInForeground,
    required bool isChatPageVisible,
  }) {
    // 1. 检查是否是自己发送的消息
    if (message.senderId == _currentUserId) {
      _logger.d('跳过自己发送的消息通知');
      return false;
    }

    // 2. 检查消息是否已经通知过
    if (_notifiedMessageIds.contains(message.messageId)) {
      _logger.d('消息已通知过，跳过', extra: {'messageId': message.messageId});
      return false;
    }

    // 3. 如果应用在前台且聊天页面可见，不显示通知
    if (isAppInForeground && isChatPageVisible) {
      _logger.d('应用在前台且聊天页面可见，跳过通知');
      return false;
    }

    // 4. 检查消息时间，避免通知过旧的消息
    final now = DateTime.now();
    final messageTime = message.createdAt;
    final timeDiff = now.difference(messageTime).inMinutes;
    
    if (timeDiff > 5) { // 超过5分钟的消息不通知
      _logger.d('消息过旧，跳过通知', extra: {
        'messageTime': messageTime.toIso8601String(),
        'timeDiffMinutes': timeDiff,
      });
      return false;
    }

    return true;
  }

  /// 清除会话通知
  Future<void> clearConversationNotifications(String conversationId) async {
    await _notificationService.clearConversationNotifications(conversationId);
    
    // 清除该会话的通知记录
    _notifiedMessageIds.removeWhere((messageId) => 
        messageId.startsWith('${conversationId}_'));
    
    _logger.d('清除会话通知', extra: {'conversationId': conversationId});
  }

  /// 清除所有通知
  Future<void> clearAllNotifications() async {
    await _notificationService.clearAllNotifications();
    _notifiedMessageIds.clear();
    
    _logger.d('清除所有通知');
  }

  /// 用户进入聊天页面时调用
  Future<void> onChatPageEntered(String conversationId) async {
    // 清除该会话的通知
    await clearConversationNotifications(conversationId);
  }

  /// 用户离开应用时调用
  Future<void> onAppBackground() async {
    _logger.d('应用进入后台，准备接收通知');
  }

  /// 用户回到应用时调用
  Future<void> onAppForeground() async {
    _logger.d('应用回到前台');
    // 可以在这里更新未读消息数量的角标
  }

  /// 更新应用角标数量
  Future<void> updateBadgeCount(int count) async {
    await _notificationService.setBadgeCount(count);
  }

  /// 检查通知权限状态
  Future<bool> checkNotificationPermission() async {
    return await _notificationService.checkPermissionStatus();
  }

  /// 清理服务状态
  void dispose() {
    _notifiedMessageIds.clear();
    _currentUserId = null;
    _logger.d('聊天通知集成服务已清理');
  }
}

/// 使用示例：
/// 
/// ```dart
/// // 1. 在应用启动时设置当前用户
/// ChatNotificationIntegration.instance.setCurrentUserId(currentUser.userId);
/// 
/// // 2. 在接收到新消息时调用
/// await ChatNotificationIntegration.instance.handleNewMessage(
///   message: newMessage,
///   conversation: conversation,
///   sender: senderUser,
///   isAppInForeground: WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
///   isChatPageVisible: currentChatPageConversationId == conversation.conversationId,
///   unreadCount: conversation.unreadCount,
/// );
/// 
/// // 3. 用户进入聊天页面时清除通知
/// await ChatNotificationIntegration.instance.onChatPageEntered(conversationId);
/// 
/// // 4. 更新应用角标
/// await ChatNotificationIntegration.instance.updateBadgeCount(totalUnreadCount);
/// ```