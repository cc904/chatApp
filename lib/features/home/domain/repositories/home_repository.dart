import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';

/// 定义与主页面相关的数据操作方法
abstract class HomeRepository {
  /// 初始化用户会话
  ///
  /// 初始化数据库和通信服务
  ///
  /// 参数:
  /// - currentUser: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initUserSession();

  /// 初始化数据库
  ///
  /// 参数:
  /// - currentUser: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initDatabase();

  /// 初始化实时通信
  ///
  /// 参数:
  /// - currentUser: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initCommunication();

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   聊天相关   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取所有会话
  Future<List<Conversation>> getAllConversations();

  /// 监听会话变化
  Stream<List<Conversation>> watchConversations();

  /// 获取会话消息
  Future<List<Message>> getMessagesForConversation(String conversationId);

  /// 监听会话消息变化
  Stream<List<Message>> watchMessagesForConversation(String conversationId);

  /// 发送消息
  Future<bool> sendMessage(Message message);

  /// 标记消息为已读
  Future<bool> markAsRead(String conversationId);

  /// 获取打字状态流
  Stream<Map<String, dynamic>> getTypingStatusStream();

  /// 获取在线状态流
  Stream<Map<String, dynamic>> getOnlineStatusStream();

  /// 获取或创建私聊会话
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId);

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 联系人相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取所有联系人
  Future<List<User>> getAllContacts();

  /// 监听联系人变化
  Stream<List<User>> watchContacts();

  /// 获取联系人详情
  Future<User?> getContact(String userId);

  /// 添加联系人
  Future<bool> addContact(User contact);

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   通话相关   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取通话记录
  Future<List<dynamic>> getCallHistory();

  /// 发起通话
  Future<bool> initiateCall(String contactId, bool isVideo);

  /// 结束通话
  Future<bool> endCall(String callId);

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 个人资料相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取当前用户资料
  Future<User?> getCurrentUserProfile();

  /// 更新用户资料
  Future<bool> updateUserProfile(User user);

  /// 获取用户状态
  Future<String> getUserStatus();

  /// 更新用户状态
  Future<bool> updateUserStatus(String status);
}
