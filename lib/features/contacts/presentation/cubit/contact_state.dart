import 'package:equatable/equatable.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 联系人页面的状态类
class ContactState extends Equatable {
  // 联系人相关状态
  final List<User> contacts;
  final bool isLoading;
  final ContactsSyncStatus syncStatus; // 联系人同步状态
  final DateTime? lastSyncTime; // 最后同步时间
  final String? errorMessage; // 错误信息

  // 好友请求相关状态
  final List<FriendRequest> friendRequests;
  final bool isLoadingFriendRequests;

  // 搜索相关状态
  final List<User> searchResults; // 搜索结果
  final bool isSearching;
  final String? searchQuery;

  const ContactState({
    this.contacts = const [],
    this.isLoading = false,
    this.syncStatus = ContactsSyncStatus.idle,
    this.lastSyncTime,
    this.errorMessage,
    this.friendRequests = const [],
    this.isLoadingFriendRequests = false,
    this.searchResults = const [],
    this.isSearching = false,
    this.searchQuery,
  });

  /// 初始状态
  factory ContactState.initial() => const ContactState();

  /// 加载中状态
  ContactState toLoadingState() => copyWith(
        isLoading: true,
        errorMessage: null,
      );

  /// 同步中状态
  ContactState toSyncingState() => copyWith(
        syncStatus: ContactsSyncStatus.syncing,
        errorMessage: null,
      );

  /// 加载成功状态
  ContactState toLoadedState({
    required List<User> contacts,
    DateTime? lastSyncTime,
  }) =>
      copyWith(
        contacts: contacts,
        isLoading: false,
        syncStatus: ContactsSyncStatus.success,
        lastSyncTime: lastSyncTime ?? this.lastSyncTime,
        errorMessage: null,
      );

  /// 加载好友请求中状态
  ContactState toLoadingFriendRequestsState() => copyWith(
        isLoadingFriendRequests: true,
        errorMessage: null,
      );

  /// 好友请求加载成功状态
  ContactState toLoadedFriendRequestsState({
    required List<FriendRequest> friendRequests,
  }) =>
      copyWith(
        friendRequests: friendRequests,
        isLoadingFriendRequests: false,
        errorMessage: null,
      );

  /// 搜索中状态
  ContactState toSearchingState(String query) => copyWith(
        isSearching: true,
        searchQuery: query,
        errorMessage: null,
      );

  /// 搜索完成状态
  ContactState toSearchCompletedState(List<User> results) => copyWith(
        searchResults: results,
        isSearching: false,
        errorMessage: null,
      );

  /// 清除搜索状态
  ContactState toClearSearchState() => copyWith(
        isSearching: false,
        searchQuery: null,
        searchResults: const [],
        errorMessage: null,
      );

  /// 错误状态
  ContactState toErrorState(String message) => copyWith(
        isLoading: false,
        isLoadingFriendRequests: false,
        errorMessage: message,
      );

  /// 复制状态对象并更新指定字段
  ContactState copyWith({
    List<User>? contacts,
    bool? isLoading,
    ContactsSyncStatus? syncStatus,
    DateTime? lastSyncTime,
    String? errorMessage,
    List<FriendRequest>? friendRequests,
    bool? isLoadingFriendRequests,
    List<User>? searchResults,
    bool? isSearching,
    String? searchQuery,
  }) {
    return ContactState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
      friendRequests: friendRequests ?? this.friendRequests,
      isLoadingFriendRequests:
          isLoadingFriendRequests ?? this.isLoadingFriendRequests,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        contacts,
        isLoading,
        syncStatus,
        lastSyncTime,
        errorMessage,
        friendRequests,
        isLoadingFriendRequests,
        searchResults,
        isSearching,
        searchQuery,
      ];
}
