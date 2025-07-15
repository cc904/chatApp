import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/message_notification_service.dart';
import 'package:cc/features/chat/data/repositories/chats_repository_impl.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/services/secure_storage_service.dart';

/// 通知动作处理服务
/// 
/// 负责处理通知按钮的各种动作，如标记已读、快速回复、打开会话等
class NotificationActionService {
  static final NotificationActionService _instance = NotificationActionService._internal();
  static NotificationActionService get instance => _instance;
  NotificationActionService._internal();

  final LogService _logger = LogService.instance;
  ChatsRepositoryImpl? _chatsRepository;

  /// 初始化服务
  Future<void> initialize() async {
    try {
      // 获取当前用户信息
      final secureStorage = SecureStorageService();
      final userId = await secureStorage.read('user_id');
      final userDisplayName = await secureStorage.read('user_display_name');
      final userAvatar = await secureStorage.read('user_avatar');

      if (userId != null && userDisplayName != null) {
        final currentUser = CurrentUser()
          ..userId = userId
          ..name = userDisplayName
          ..avatar = userAvatar;

        _chatsRepository = ChatsRepositoryImpl(currentUser: currentUser);
        _logger.i('通知动作服务初始化成功', extra: {'userId': userId});
      } else {
        _logger.w('无法初始化通知动作服务：用户信息不完整');
      }
    } catch (error, stackTrace) {
      _logger.e('通知动作服务初始化失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理标记为已读动作
  Future<void> handleMarkAsRead(String conversationId) async {
    try {
      _logger.i('执行标记已读操作', extra: {'conversationId': conversationId});

      if (_chatsRepository == null) {
        _logger.w('ChatsRepository未初始化，无法执行标记已读操作');
        return;
      }

      // 更新会话的最后阅读时间
      await _chatsRepository!.updateConversationLastReadTime(conversationId);

      // 清除该会话的通知
      await MessageNotificationService.instance.clearConversationNotifications(conversationId);

      _logger.i('标记已读操作完成', extra: {'conversationId': conversationId});

    } catch (error, stackTrace) {
      _logger.e('标记已读操作失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理快速回复动作
  Future<void> handleQuickReply(String conversationId, String? replyText) async {
    try {
      _logger.i('执行快速回复操作', extra: {
        'conversationId': conversationId,
        'replyText': replyText,
      });

      // 快速回复功能需要发送消息的功能支持
      // 暂时先打开对应会话
      await handleOpenConversation(conversationId);

    } catch (error, stackTrace) {
      _logger.e('快速回复操作失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理打开会话动作
  Future<void> handleOpenConversation(String conversationId) async {
    try {
      _logger.i('执行打开会话操作', extra: {'conversationId': conversationId});

      // 清除该会话的通知
      await MessageNotificationService.instance.clearConversationNotifications(conversationId);

      // 这里需要导航逻辑，但由于是后台处理，需要特殊处理
      // 可以发送一个应用内事件来触发导航
      _logger.d('会话通知已清除，需要应用层处理导航', extra: {'conversationId': conversationId});

    } catch (error, stackTrace) {
      _logger.e('打开会话操作失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 检查服务是否可用
  bool get isReady => _chatsRepository != null;

  /// 获取服务状态
  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _chatsRepository != null,
      'chatsRepositoryReady': _chatsRepository != null,
    };
  }
}