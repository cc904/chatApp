import 'package:cc/core/database/models/user.dart';

/// 联系人仓库接口
/// 定义了与联系人相关的数据操作方法
abstract class ContactsRepository {
  /// 获取所有联系人
  Future<List<User>> getAllContacts();

  /// 搜索联系人
  Future<List<User>> searchContacts(String keyword);

  /// 根据ID获取联系人
  Future<User?> getContactById(String userId);

  /// 添加联系人
  Future<void> addContact(User user);

  /// 删除联系人
  Future<void> deleteContact(String userId);

  /// 更新联系人信息
  Future<void> updateContact(User user);

  /// 监听联系人列表变化
  Stream<void> watchContacts();
}
