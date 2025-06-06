import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/domain/entities/conversation_event.dart';
import 'package:cc/features/chat/domain/entities/chat_state_snapshot.dart';

/// 聊天会话列表仓库接口
/// 定义了会话列表管理所需的各种操作方法
abstract class ChatsRepository {
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

  /// 💢💢💢 新增：监听单个会话变化
  /// 用于 ChatCubit 监听特定会话的状态变化
  /// [conversationId] - 会话ID
  /// 返回该会话的变化流
  Stream<Conversation?> watchConversation(String conversationId);

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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   会话阅读状态管理   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 更新会话最后阅读时间
  /// [conversationId] - 会话ID
  /// [timestamp] - 阅读时间戳
  /// [syncToServer] - 是否同步到服务器，默认false
  Future<void> updateLastReadAt(String conversationId, DateTime timestamp,
      {bool syncToServer = false});

  /// 更新会话最后阅读消息ID
  /// [conversationId] - 会话ID
  /// [messageId] - 最后阅读的消息ID
  Future<void> updateLastReadMessageId(String conversationId, String messageId);

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   状态快照管理   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 保存会话状态快照
  Future<void> saveStateSnapshot(ChatStateSnapshot snapshot);

  /// 获取会话状态快照
  Future<ChatStateSnapshot?> getStateSnapshot(String conversationId);

  /// 清除指定会话的状态快照
  Future<void> clearStateSnapshot(String conversationId);

  /// 清除所有过期的状态快照
  Future<void> cleanupExpiredSnapshots();

  /// 获取当前状态快照数量（用于监控和调试）
  int get stateSnapshotCount;
}
