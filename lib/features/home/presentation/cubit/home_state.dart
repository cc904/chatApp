import 'package:equatable/equatable.dart';
import 'package:cc/core/database/models/current_user.dart';

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
  final CurrentUser? currentUser;

  // UI状态
  final int currentTabIndex; // 当前选中的Tab索引

  // 网络相关状态
  final bool isConnected; // 是否连接到网络
  final NetworkStatus networkStatus; // 网络状态
  final DateTime? lastConnectionTime; // 最后一次连接时间
  final String? connectionErrorMessage; // 连接错误信息

  const HomeState({
    // 初始化状态
    this.homePageIsInitializing = false,
    this.homePageIsInitialized = false,
    this.errorMessage,
    this.currentUser,

    // UI状态
    this.currentTabIndex = 0,

    // 网络相关状态
    this.isConnected = false,
    this.networkStatus = NetworkStatus.disconnected,
    this.lastConnectionTime,
    this.connectionErrorMessage,
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
  HomeState toInitializedState({required CurrentUser currentUser}) {
    return copyWith(
      homePageIsInitializing: false,
      homePageIsInitialized: true,
      errorMessage: null,
      currentUser: currentUser,
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
    CurrentUser? currentUser,

    // UI状态
    int? currentTabIndex,

    // 网络相关状态
    bool? isConnected,
    NetworkStatus? networkStatus,
    DateTime? lastConnectionTime,
    String? connectionErrorMessage,
  }) {
    return HomeState(
      // 初始化状态
      homePageIsInitializing: homePageIsInitializing ?? this.homePageIsInitializing,
      homePageIsInitialized: homePageIsInitialized ?? this.homePageIsInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,

      // UI状态
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,

      // 网络相关状态
      isConnected: isConnected ?? this.isConnected,
      networkStatus: networkStatus ?? this.networkStatus,
      lastConnectionTime: lastConnectionTime ?? this.lastConnectionTime,
      connectionErrorMessage: connectionErrorMessage ?? this.connectionErrorMessage,
    );
  }

  /// 判断是否有错误
  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => [
        // 初始化状态
        homePageIsInitializing,
        homePageIsInitialized,
        errorMessage,
        currentUser,

        // UI状态
        currentTabIndex,

        // 网络相关状态
        isConnected,
        networkStatus,
        lastConnectionTime,
        connectionErrorMessage,
      ];
}
