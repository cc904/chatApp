import 'dart:async';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 登录前使用的模拟联系人仓库
/// 不依赖数据库,只提供基本实现以满足UI需求
class MockContactsRepository implements ContactsRepository {
  final _logger = LogService('mock_contacts_repository.dart');

  @override
  Future<List<User>> getAllContacts() async {
    _logger.i('获取模拟联系人列表');
    return [];
  }

  @override
  Future<User?> getContactById(String userId) async {
    return null;
  }

  @override
  Future<List<User>> searchContacts(String keyword) async {
    return [];
  }

  @override
  Future<bool> addContact(User contact) async {
    throw UnimplementedError('登录后才能添加联系人');
  }

  @override
  Future<bool> updateContact(User contact) async {
    return false;
  }

  @override
  Future<bool> deleteContact(String userId) async {
    return false;
  }

  @override
  Future<List<User>> syncContacts() async {
    return [];
  }

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    return [];
  }

  @override
  Future<bool> sendFriendRequest(String userId, String message) async {
    return false;
  }

  @override
  Future<List<FriendRequest>> getPendingFriendRequests() async {
    return [];
  }

  @override
  Future<bool> acceptFriendRequest(String requestId) async {
    return false;
  }

  @override
  Future<bool> rejectFriendRequest(String requestId) async {
    return false;
  }

  @override
  Stream<void> watchContacts() {
    return Stream.empty();
  }

  Stream<void> watchFriendRequests() {
    return Stream.empty();
  }
}
