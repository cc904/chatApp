import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/message_notification_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/notification_settings_service.dart';
import 'package:cc/core/widgets/top_notification.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as conversation_proto;
import 'package:cc/core/database/drift_database.dart';

// 条件导入：根据平台导入不同的通知帮助工具实现
import 'notification_helper_stub.dart'
    if (dart.library.io) 'notification_helper_io.dart'
    if (dart.library.html) 'notification_helper_web.dart';

/// 会话预览更新通知服务
/// 
/// 处理 conversation:preview:updated 事件后的用户通知
/// 提供多种通知方式，根据应用状态和用户偏好选择合适的通知方式
class ConversationPreviewNotificationService {
  static final ConversationPreviewNotificationService _instance = 
      ConversationPreviewNotificationService._internal();
  static ConversationPreviewNotificationService get instance => _instance;
  ConversationPreviewNotificationService._internal();

  final LogService _logger = LogService.instance;
  final MessageNotificationService _notificationService = MessageNotificationService.instance;
  final UINotificationService _uiNotificationService = UINotificationService.instance;
  final NotificationSettingsService _settingsService = NotificationSettingsService.instance;
  
  CurrentUser? _currentUser;

  /// 设置当前用户
  void setCurrentUser(CurrentUser currentUser) {
    _currentUser = currentUser;
  }

  /// 处理会话预览更新事件
  /// 根据应用状态选择合适的通知方式
  Future<void> handleConversationPreviewUpdated({
    required conversation_proto.ConversationPreviewUpdated previewUpdate,
    required Conversation conversation,
    User? sender,
    required bool isAppInForeground,
    required bool isChatsPageVisible,
    required bool isChatPageVisible,
    String? currentChatConversationId,
  }) async {
    try {
      _logger.i('处理会话预览更新通知', extra: {
        'conversationId': previewUpdate.conversationId,
        'isAppInForeground': isAppInForeground,
        'isChatsPageVisible': isChatsPageVisible,
        'isChatPageVisible': isChatPageVisible,
        'notificationServiceStatus': _notificationService.getServiceStatus(),
      });

      // 1. 检查是否需要通知
      if (!_shouldNotifyPreviewUpdate(
        previewUpdate: previewUpdate,
        isAppInForeground: isAppInForeground,
        isChatsPageVisible: isChatsPageVisible,
        isChatPageVisible: isChatPageVisible,
        currentChatConversationId: currentChatConversationId,
      )) {
        return;
      }

      // 2. 根据应用状态选择通知方式
      await _selectNotificationMethod(
        previewUpdate: previewUpdate,
        conversation: conversation,
        sender: sender,
        isAppInForeground: isAppInForeground,
        isChatsPageVisible: isChatsPageVisible,
        isChatPageVisible: isChatPageVisible,
      );

    } catch (error, stackTrace) {
      _logger.e('处理会话预览更新通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 判断是否需要通知用户
  bool _shouldNotifyPreviewUpdate({
    required conversation_proto.ConversationPreviewUpdated previewUpdate,
    required bool isAppInForeground,
    required bool isChatsPageVisible,
    required bool isChatPageVisible,
    String? currentChatConversationId,
  }) {
    // 1. 检查用户通知设置
    if (!_settingsService.shouldShowNotification()) {
      _logger.d('用户通知设置禁止显示通知');
      return false;
    }

    // 2. 如果用户正在查看这个会话，不需要额外通知
    if (isChatPageVisible && currentChatConversationId == previewUpdate.conversationId) {
      _logger.d('用户正在查看当前会话，跳过通知');
      return false;
    }

    // 2. 检查是否是自己发送的消息（通过消息发送者判断）
    // 注意：这里无法直接判断，需要在上层调用时传入sender信息

    // 3. 检查消息时间，避免通知过旧的消息
    if (previewUpdate.hasLastMessageTime()) {
      final messageTime = DateTime.fromMillisecondsSinceEpoch(
        previewUpdate.lastMessageTime.toInt()
      );
      final now = DateTime.now();
      final timeDiff = now.difference(messageTime).inMinutes;
      
      if (timeDiff > 5) { // 超过5分钟的消息不通知
        _logger.d('消息过旧，跳过通知', extra: {
          'messageTime': messageTime.toIso8601String(),
          'timeDiffMinutes': timeDiff,
        });
        return false;
      }
    }

    return true;
  }

  /// 选择合适的通知方式
  Future<void> _selectNotificationMethod({
    required conversation_proto.ConversationPreviewUpdated previewUpdate,
    required Conversation conversation,
    User? sender,
    required bool isAppInForeground,
    required bool isChatsPageVisible,
    required bool isChatPageVisible,
  }) async {
    if (!isAppInForeground) {
      // 应用在后台 - 显示系统通知
      await _showSystemNotification(previewUpdate, conversation, sender);
      
    } else if (isChatsPageVisible) {
      // 应用在前台且在会话列表页 - 显示轻量级UI通知
      await _showInAppNotification(previewUpdate, conversation, sender);
      
    } else {
      // 应用在前台但不在会话列表页 - 显示角标或简单提示
      await _showBadgeOrToast(previewUpdate, conversation, sender);
    }
  }

  /// 方式1: 系统通知（应用在后台时）
  Future<void> _showSystemNotification(
    conversation_proto.ConversationPreviewUpdated previewUpdate,
    Conversation conversation,
    User? sender,
  ) async {
    try {
      // 获取通知服务状态
      final serviceStatus = _notificationService.getServiceStatus();
      _logger.d('通知服务状态检查', extra: {
        'conversationId': previewUpdate.conversationId,
        'serviceStatus': serviceStatus,
      });

      // 检查通知服务状态
      final hasPermission = await _notificationService.checkPermissionStatus();
      if (!hasPermission) {
        _logger.w('通知权限未授予，尝试处理权限问题', extra: {
          'conversationId': previewUpdate.conversationId,
          'serviceStatus': serviceStatus,
        });
        
        // 尝试处理权限问题
        await _handlePermissionDenied(previewUpdate.conversationId);
        return;
      }

      // 创建模拟的消息对象用于通知
      final mockMessage = _createMockMessageFromPreview(previewUpdate);
      
      // 如果没有发送者信息，跳过通知
      if (sender == null) {
        _logger.w('发送者信息为空，跳过系统通知', extra: {
          'conversationId': previewUpdate.conversationId,
        });
        return;
      }

      // 使用现有的消息通知服务
      await _notificationService.showMessageNotification(
        message: mockMessage,
        conversation: conversation,
        sender: sender,
        unreadCount: 0, // 需要从数据库获取未读计数
      );
      
      _logger.i('系统通知显示成功', extra: {
        'conversationId': previewUpdate.conversationId,
      });
      
    } catch (error) {
      _logger.e('显示系统通知失败', error: error, extra: {
        'conversationId': previewUpdate.conversationId,
        'errorType': error.runtimeType.toString(),
      });
      
      // 如果系统通知失败，尝试降级到应用内通知（如果应用在前台）
      try {
        _logger.i('尝试降级到应用内通知');
        await _showInAppNotification(previewUpdate, conversation, sender);
      } catch (fallbackError) {
        _logger.e('降级通知也失败了', error: fallbackError);
      }
    }
  }

  /// 方式2: 应用内通知（应用在前台且在会话列表时）
  Future<void> _showInAppNotification(
    conversation_proto.ConversationPreviewUpdated previewUpdate,
    Conversation conversation,
    User? sender,
  ) async {
    try {
      // 获取通知设置
      final notificationStyle = _settingsService.getNotificationStyle();
      
      // 使用新的顶部消息通知
      final senderName = sender?.nickName ?? previewUpdate.lastMessageName;
      final messageText = notificationStyle.showPreview ? previewUpdate.lastMessagePreview : '新消息';
      final conversationName = conversation.type == 'PRIVATE' ? null : conversation.name;
      
      _uiNotificationService.showMessageNotification(
        senderName: senderName,
        messageText: messageText,
        conversationName: conversationName,
        onTap: () {
          // 点击通知跳转到对应会话
          _navigateToConversation(previewUpdate.conversationId);
        },
      );
      
      _logger.i('已显示应用内通知', extra: {
        'conversationId': previewUpdate.conversationId,
        'showPreview': notificationStyle.showPreview,
      });
      
    } catch (error) {
      _logger.e('显示应用内通知失败', error: error);
    }
  }

  /// 方式3: 角标或Toast（应用在前台但不在会话列表时）
  Future<void> _showBadgeOrToast(
    conversation_proto.ConversationPreviewUpdated previewUpdate,
    Conversation conversation,
    User? sender,
  ) async {
    try {
      // 获取通知设置
      final notificationStyle = _settingsService.getNotificationStyle();
      
      // 方式3A: 显示轻量Toast
      final messageText = notificationStyle.showPreview ? previewUpdate.lastMessagePreview : '新消息';
      _uiNotificationService.showToast(
        message: '${_buildNotificationTitle(conversation, sender)}: $messageText',
        duration: const Duration(seconds: 2),
        type: ToastType.info,
      );
      
      // 方式3B: 更新应用角标（如果支持）
      final totalUnreadCount = await _calculateTotalUnreadCount();
      await _notificationService.setBadgeCount(totalUnreadCount);
      
      _logger.i('已显示轻量通知', extra: {
        'conversationId': previewUpdate.conversationId,
        'totalUnreadCount': totalUnreadCount,
        'showPreview': notificationStyle.showPreview,
      });
      
    } catch (error) {
      _logger.e('显示轻量通知失败', error: error);
    }
  }


  /// 创建用于通知的模拟消息对象
  Message _createMockMessageFromPreview(
    conversation_proto.ConversationPreviewUpdated previewUpdate
  ) {
    // 创建一个Message对象用于通知
    return Message(
      messageId: 'preview_${previewUpdate.conversationId}_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: previewUpdate.conversationId,
      senderId: 'unknown', // 无法从preview获取具体senderId
      senderName: previewUpdate.lastMessageName.isNotEmpty ? previewUpdate.lastMessageName : null,
      createdAt: previewUpdate.hasLastMessageTime() 
          ? DateTime.fromMillisecondsSinceEpoch(previewUpdate.lastMessageTime.toInt())
          : DateTime.now(),
      messageIndex: previewUpdate.lastMessageIndex.toInt(),
      messageType: 'TEXT', // 假设为文本消息
      messageStatus: 'SENT',
      content: previewUpdate.lastMessagePreview.isNotEmpty 
          ? '{"text_message":{"text":"${previewUpdate.lastMessagePreview}"}}'
          : null,
      quotedMessageId: null,
      repliedToMessageId: null,
      forwardedFromConversationId: null,
      forwardedFromMessageId: null,
      isEdited: false,
      editedAt: null,
      isPinned: false,
      reactions: null,
      tags: null,
      updatedAt: null,
    );
  }

  /// 构建通知标题
  String _buildNotificationTitle(Conversation conversation, User? sender) {
    if (conversation.type == 'PRIVATE') {
      return sender?.nickName ?? conversation.name ?? '私聊';
    } else {
      final senderName = sender?.nickName ?? '某人';
      return '${conversation.name ?? '群聊'} ($senderName)';
    }
  }

  /// 跳转到指定会话
  void _navigateToConversation(String conversationId) {
    // 这里需要实现导航逻辑
    // 可以通过路由或状态管理来实现
    _logger.i('导航到会话', extra: {'conversationId': conversationId});
    
    // 示例实现（需要根据你的导航架构调整）
    // Navigator.pushNamed(context, '/chat', arguments: conversationId);
    // 或者通过状态管理
    // Get.toNamed('/chat', arguments: conversationId);
  }

  /// 计算总未读消息数
  Future<int> _calculateTotalUnreadCount() async {
    try {
      // 这里需要实现计算所有会话未读消息总数的逻辑
      // 可以通过数据库查询或状态管理获取
      return 0; // 临时返回0
    } catch (error) {
      _logger.e('计算未读消息数失败', error: error);
      return 0;
    }
  }

  /// 处理权限被拒绝的情况
  Future<void> _handlePermissionDenied(String conversationId) async {
    try {
      _logger.i('通知权限被拒绝，尝试重新请求', extra: {
        'conversationId': conversationId,
        'platform': getStandardizedPlatformName(),
      });

      // 尝试重新请求权限
      final granted = await _notificationService.requestPermissionAgain();
      
      if (granted) {
        _logger.i('权限重新授予成功，权限问题已解决');
        return;
      }

      // 如果重新请求失败，显示用户引导（根据平台定制消息）
      _logger.w('权限重新请求失败，显示用户引导');
      
      const title = '需要通知权限';
      final message = getPlatformPermissionMessage();
      
      _uiNotificationService.showTopNotification(
        title: title,
        message: message,
        type: TopNotificationType.warning,
        duration: const Duration(seconds: 6), // macOS 用户可能需要更多时间阅读
        onTap: () {
          _logger.i('用户点击了权限引导', extra: {
            'platform': getStandardizedPlatformName(),
          });
          
          if (isMacOSPlatform()) {
            _logger.i('macOS平台 - 建议用户手动打开系统偏好设置');
            // macOS 上可以尝试打开系统偏好设置的通知面板
            // 需要使用 url_launcher 或 process.run
          }
        },
      );
      
    } catch (error) {
      _logger.e('处理权限拒绝时发生错误', error: error);
    }
  }

  /// 清理资源
  void dispose() {
    _currentUser = null;
    _logger.d('会话预览通知服务已清理');
  }

}

/// 使用指南和集成示例：
/// 
/// ```dart
/// // 1. 在ChatsRepositoryImpl的_handleConversationPreviewUpdated中添加：
/// 
/// void _handleConversationPreviewUpdated(
///     conversation_proto.ConversationPreviewUpdated previewInfo) async {
///   try {
///     // ... 现有的数据库更新逻辑 ...
/// 
///     // 新增：处理用户通知
///     final conversation = await _getUpdatedConversation(previewInfo.conversationId);
///     final sender = await _getSenderByName(previewInfo.lastMessageName);
///     
///     await ConversationPreviewNotificationService.instance.handleConversationPreviewUpdated(
///       previewUpdate: previewInfo,
///       conversation: conversation,
///       sender: sender,
///       isAppInForeground: WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
///       isChatsPageVisible: _isChatsPageCurrentlyVisible(),
///       isChatPageVisible: _isChatPageCurrentlyVisible(),
///       currentChatConversationId: _getCurrentChatConversationId(),
///     );
///   } catch (error) {
///     _logger.e('处理会话预览更新失败', error: error);
///   }
/// }
/// 
/// // 2. 在应用启动时初始化：
/// ConversationPreviewNotificationService.instance.setCurrentUser(currentUser);
/// ```