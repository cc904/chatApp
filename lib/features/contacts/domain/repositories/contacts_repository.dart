import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/friend_request.dart';

/// 联系人仓库接口
/// 定义了与联系人相关的数据操作方法
abstract class ContactsRepository {
  /// 获取所有联系人
  Future<List<User>> getAllContacts();

  /// 根据ID获取联系人
  Future<User?> getContactById(String userId);

  /// 搜索联系人
  Future<List<User>> searchContacts(String query);

  /// 添加联系人
  Future<bool> addContact(User contact);

  /// 更新联系人
  Future<bool> updateContact(User contact);

  /// 删除联系人
  Future<bool> deleteContact(String userId);

  /// 同步联系人列表（从服务器获取最新联系人列表）
  Future<List<User>> syncContacts();

  /// 获取好友请求列表
  Future<List<FriendRequest>> getFriendRequests();

  /// 发送好友请求
  Future<bool> sendFriendRequest(String userId, String message);

  /// 接受好友请求
  Future<bool> acceptFriendRequest(String requestId);

  /// 拒绝好友请求
  Future<bool> rejectFriendRequest(String requestId);

  /// 监听联系人列表变化
  Stream<void> watchContacts();
}
