import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:equatable/equatable.dart';

/// 联系人Cubit的状态
/// 负责管理联系人列表的状态
class ContactsCubitState extends Equatable {
  final List<User> contacts;
  final List<FriendRequest> friendRequests;
  final bool isLoading;
  final String? errorMessage;
  final bool isSyncing;

  const ContactsCubitState({
    this.contacts = const [],
    this.friendRequests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSyncing = false,
  });

  ContactsCubitState copyWith({
    List<User>? contacts,
    List<FriendRequest>? friendRequests,
    bool? isLoading,
    String? errorMessage,
    bool? isSyncing,
  }) {
    return ContactsCubitState(
      contacts: contacts ?? this.contacts,
      friendRequests: friendRequests ?? this.friendRequests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [contacts, friendRequests, isLoading, errorMessage, isSyncing];
}

class ContactsCubit extends Cubit<ContactsCubitState> {
  final ContactsRepository _repository;
  final LogService _logger = LogService.instance;

  ContactsCubit(this._repository) : super(const ContactsCubitState()) {
    // 设置联系人同步回调
    _repository.onContactsSynced = _handleContactsSyncedEvent;
    // 初始化事件监听
    _initializeEventListeners();
  }

  /// 加载所有联系人
  Future<void> loadContacts() async {
    _logger.i('加载联系人');
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final contacts = await _repository.getAllContacts();
      emit(state.copyWith(contacts: contacts, isLoading: false));
    } catch (error) {
      _logger.e('加载联系人失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isLoading: false, errorMessage: '加载联系人失败: $error'));
    }
  }

  /// 同步联系人（从服务器获取最新数据）
  Future<void> syncContacts() async {
    _logger.i('同步联系人');
    try {
      emit(state.copyWith(isSyncing: true, errorMessage: null));

      // 只发送同步请求，不等待返回数据
      // await _repository.syncContacts();

      _logger.i('-----> await _repository.syncContacts();');

      // 注意：这里不立即更新状态，等待事件通知后再更新
      // 状态更新将在_handleContactsSyncedEvent中处理
    } catch (error) {
      _logger.e('同步联系人失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isSyncing: false, errorMessage: '同步联系人失败: $error'));
    }
  }

  /// 处理联系人同步完成事件
  void _handleContactsSyncedEvent(List<User> contacts) {
    _logger.i('收到联系人同步事件', extra: {'count': contacts.length});
    try {
      emit(state.copyWith(contacts: contacts, isSyncing: false, errorMessage: null));

      // 加载好友请求
      loadFriendRequests();
    } catch (error) {
      _logger.e('处理联系人同步事件失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isSyncing: false, errorMessage: '处理联系人同步事件失败: $error'));
    }
  }

  /// 初始化数据库事件监听
  void _initializeEventListeners() {
    // 订阅联系人同步事件
    _repository.watchContacts().listen((_) {
      // 当本地数据库发生变化时，重新加载联系人列表
      loadContacts();
    });
  }

  /// 加载好友请求
  Future<void> loadFriendRequests() async {
    _logger.i('加载好友请求');
    try {
      final requests = await _repository.getFriendRequests();
      emit(state.copyWith(friendRequests: requests));
    } catch (error) {
      _logger.e('加载好友请求失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 发送好友请求
  Future<bool> sendFriendRequest(String userId, String message) async {
    _logger.i('发送好友请求', extra: {'userId': userId, 'message': message});
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final result = await _repository.sendFriendRequest(userId, message);
      emit(state.copyWith(isLoading: false));
      return result;
    } catch (error) {
      _logger.e('发送好友请求失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isLoading: false, errorMessage: '发送好友请求失败: $error'));
      return false;
    }
  }

  /// 接受好友请求
  Future<bool> acceptFriendRequest(String requestId) async {
    _logger.i('接受好友请求', extra: {'requestId': requestId});
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final result = await _repository.acceptFriendRequest(requestId);

      if (result) {
        await loadFriendRequests(); // 更新好友请求列表
        await loadContacts(); // 重新加载联系人列表
      }

      emit(state.copyWith(isLoading: false));
      return result;
    } catch (error) {
      _logger.e('接受好友请求失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isLoading: false, errorMessage: '接受好友请求失败: $error'));
      return false;
    }
  }

  /// 拒绝好友请求
  Future<bool> rejectFriendRequest(String requestId) async {
    _logger.i('拒绝好友请求', extra: {'requestId': requestId});
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final result = await _repository.rejectFriendRequest(requestId);

      if (result) {
        // 更新好友请求列表
        await loadFriendRequests();
      }

      emit(state.copyWith(isLoading: false));
      return result;
    } catch (error) {
      _logger.e('拒绝好友请求失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isLoading: false, errorMessage: '拒绝好友请求失败: $error'));
      return false;
    }
  }

  /// 搜索联系人
  Future<List<User>> searchContacts(String query) async {
    _logger.i('搜索联系人', extra: {'query': query});
    try {
      if (query.isEmpty) {
        return state.contacts;
      }
      return await _repository.searchContacts(query);
    } catch (error) {
      _logger.e('搜索联系人失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 添加联系人
  Future<void> addContact(User contact) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await _repository.addContact(contact);
      await loadContacts(); // 重新加载联系人列表
    } catch (error) {
      _logger.e('添加联系人失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(
        errorMessage: '添加联系人失败: $error',
        isLoading: false,
      ));
    }
  }

  /// 删除联系人
  Future<void> deleteContact(String userId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await _repository.deleteContact(userId);
      await loadContacts(); // 重新加载联系人列表
    } catch (error) {
      _logger.e('删除联系人失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(
        errorMessage: '删除联系人失败: $error',
        isLoading: false,
      ));
    }
  }

  /// 更新联系人
  Future<void> updateContact(User contact) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await _repository.updateContact(contact);
      await loadContacts(); // 重新加载联系人列表
    } catch (error) {
      _logger.e('更新联系人失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(
        errorMessage: '更新联系人失败: $error',
        isLoading: false,
      ));
    }
  }
}
