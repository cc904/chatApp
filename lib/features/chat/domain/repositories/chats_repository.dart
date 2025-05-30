import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/domain/entities/conversation_event.dart';

/// 聊天会话列表仓库接口
/// 定义了会话列表管理所需的各种操作方法
abstract class ChatsRepository {
  /// 注册事件处理器
  /// 设置与通信服务的事件监听，用于接收和处理服务器发送的Proto消息
  Future<void> registerEventHandlers();

  /// 获取单个联系人信息
  /// 注：此方法仅用于支持聊天功能,不应用于联系人管理
  Future<User?> getContactById(String userId);

  /// 获取所有会话
  /// 从本地数据库获取所有会话
  /// 返回会话列表
  Future<List<Conversation>> getAllConversations();

  /// 获取单个会话信息
  Future<Conversation?> getConversationById(String conversationId);

  /// 获取或创建私聊会话
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId);

  /// 创建群聊会话
  Future<Conversation> createGroupConversation(
      String name, List<String> memberIds,
      {String? avatar});

  /// 删除会话和会话中的所有消息
  Future<void> deleteConversation(String conversationId);

  /// 监听会话列表变化
  Stream<void> watchConversations();

  /// 监听会话更新事件
  Stream<ConversationUpdateEvent> get conversationUpdateStream;

  /// 监听会话同步事件
  Stream<ConversationSyncEvent> get conversationSyncStream;

  /// 监听联系人列表变化
  Stream<void> watchContacts();

  /// 创建或获取与用户的对话
  Future<String?> createOrGetConversation(String userId);

  /// 同步会话列表
  /// 从服务器同步最新的会话数据
  /// 该方法只发送同步请求，不返回会话列表
  /// 会话数据将通过事件通知并由状态管理系统更新UI
  Future<void> requestSyncConversations();

  /// 更新会话的静音状态
  Future<void> updateConversationMuteStatus(
      String conversationId, bool isMuted);

  /// 更新会话的置顶状态
  Future<void> updateConversationPinStatus(
      String conversationId, bool isPinned);

  /// 更新会话的最后阅读时间
  Future<void> updateLastReadAt(String conversationId, DateTime timestamp);

  /// 更新会话的最后阅读消息ID
  Future<void> updateLastReadMessageId(String conversationId, String messageId);

  /// 根据标签过滤会话
  ///
  /// 根据标签类型过滤会话列表
  /// [tabIndex] - 标签索引
  /// 返回过滤后的会话列表
  Future<List<Conversation>> filterConversationsByTab(int tabIndex);

  /// 更新会话设置
  ///
  /// 更新会话的静音或置顶状态
  /// [conversationId] - 会话ID
  /// [muted] - 是否静音
  /// [pinned] - 是否置顶
  /// 返回是否更新成功
  Future<bool> updateConversationSettings(String conversationId,
      {bool? muted, bool? pinned});

  /// 获取联系人在线状态流
  Stream<List<String>> getOnlineStatusStream();

  /// 向服务器请求获取会话详情
  ///
  /// 当本地数据库中找不到会话时，向服务器请求完整的会话信息
  /// 会话详情将通过事件回调方式处理
  /// [conversationId] - 会话ID
  Future<void> requestConversationDetail(String conversationId);
}
