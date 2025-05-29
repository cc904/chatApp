import 'package:equatable/equatable.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 网络状态枚举
enum NetworkStatus {
  /// 已连接
  connected,
  
  /// 连接中
  connecting,
  
  /// 断开连接
  disconnected,
  
  /// 连接错误
  error
}

/// HomePage的状态类
class HomeState extends Equatable {
  // 初始化状态
  final bool homePageIsInitializing;
  final bool homePageIsInitialized;
  final String? errorMessage;
  final CurrentUserProto? currentUser;

  // 联系人相关状态
  final List<User> contacts;
  final bool isLoadingContacts;
  final ContactsSyncStatus contactsSyncStatus; // 联系人同步状态
  final DateTime? lastContactsSyncTime; // 最后同步时间
  final String? contactsErrorMessage; // 联系人错误信息

  // 网络相关状态
  final bool isConnected; // 是否连接到网络
  final NetworkStatus networkStatus; // 网络状态
  final DateTime? lastConnectionTime; // 最后一次连接时间
  final String? connectionErrorMessage; // 连接错误信息

  // 搜索相关状态
  final List<dynamic> searchResults; // 可能是联系人、会话或消息
  final bool isSearching;

  const HomeState({
    // 初始化状态
    this.homePageIsInitializing = false,
    this.homePageIsInitialized = false,
    this.errorMessage,
    this.currentUser,

    // 联系人相关状态
    this.contacts = const [],
    this.isLoadingContacts = false,
    this.contactsSyncStatus = ContactsSyncStatus.idle,
    this.lastContactsSyncTime,
    this.contactsErrorMessage,

    // 网络相关状态
    this.isConnected = false,
    this.networkStatus = NetworkStatus.disconnected,
    this.lastConnectionTime,
    this.connectionErrorMessage,

    // 搜索相关状态
    this.searchResults = const [],
    this.isSearching = false,
  });

  /// 初始状态
  static HomeState initial() {
    return const HomeState(
      homePageIsInitializing: false,
      homePageIsInitialized: false,
    );
  }

  /// 初始化中状态
  HomeState toInitializingState() {
    return copyWith(
      homePageIsInitializing: true,
      errorMessage: null,
    );
  }

  /// 初始化成功状态
  HomeState toInitializedState({required CurrentUserProto currentUserProto}) {
    return copyWith(
      homePageIsInitializing: false,
      homePageIsInitialized: true,
      errorMessage: null,
      currentUser: currentUserProto,
    );
  }

  /// 初始化失败状态
  HomeState toErrorState(String message) {
    return copyWith(
      homePageIsInitializing: false,
      errorMessage: message,
    );
  }

  /// 复制实例方法
  HomeState copyWith({
    // 初始化状态
    bool? homePageIsInitializing,
    bool? homePageIsInitialized,
    String? errorMessage,
    CurrentUserProto? currentUser,

    // 联系人相关状态
    List<User>? contacts,
    bool? isLoadingContacts,
    ContactsSyncStatus? contactsSyncStatus,
    DateTime? lastContactsSyncTime,
    String? contactsErrorMessage,

    // 网络相关状态
    bool? isConnected,
    NetworkStatus? networkStatus,
    DateTime? lastConnectionTime,
    String? connectionErrorMessage,

    // 搜索相关状态
    List<dynamic>? searchResults,
    bool? isSearching,
  }) {
    return HomeState(
      // 初始化状态
      homePageIsInitializing: homePageIsInitializing ?? this.homePageIsInitializing,
      homePageIsInitialized: homePageIsInitialized ?? this.homePageIsInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,

      // 联系人相关状态
      contacts: contacts ?? this.contacts,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
      contactsSyncStatus: contactsSyncStatus ?? this.contactsSyncStatus,
      lastContactsSyncTime: lastContactsSyncTime ?? this.lastContactsSyncTime,
      contactsErrorMessage: contactsErrorMessage ?? this.contactsErrorMessage,

      // 网络相关状态
      isConnected: isConnected ?? this.isConnected,
      networkStatus: networkStatus ?? this.networkStatus,
      lastConnectionTime: lastConnectionTime ?? this.lastConnectionTime,
      connectionErrorMessage: connectionErrorMessage ?? this.connectionErrorMessage,

      // 搜索相关状态
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  /// 判断是否有错误
  bool get hasError => errorMessage != null;

  /// 判断联系人同步是否有错误
  bool get hasContactsError => contactsErrorMessage != null;

  @override
  List<Object?> get props => [
        // 初始化状态
        homePageIsInitializing,
        homePageIsInitialized,
        errorMessage,
        currentUser,

        // 联系人相关状态
        contacts,
        isLoadingContacts,
        contactsSyncStatus,
        lastContactsSyncTime,
        contactsErrorMessage,

        // 网络相关状态
        isConnected,
        networkStatus,
        lastConnectionTime,
        connectionErrorMessage,

        // 搜索相关状态
        searchResults,
        isSearching,
      ];
}
