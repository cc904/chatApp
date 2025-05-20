import 'package:equatable/equatable.dart';
import 'package:cc/core/proto/generated/user.pb.dart';

/// HomePage的状态类
class HomeState extends Equatable {
  final bool isInitializing;
  final bool isInitialized;
  final String? errorMessage;
  final MyUserProto? user;

  const HomeState({
    required this.isInitializing,
    required this.isInitialized,
    this.errorMessage,
    this.user,
  });

  /// 初始状态
  factory HomeState.initial() {
    return const HomeState(
      isInitializing: false,
      isInitialized: false,
    );
  }

  /// 初始化中状态
  HomeState toInitializingState() {
    return copyWith(
      isInitializing: true,
      errorMessage: null,
    );
  }

  /// 初始化成功状态
  HomeState toInitializedState({required MyUserProto user}) {
    return copyWith(
      isInitializing: false,
      isInitialized: true,
      errorMessage: null,
      user: user,
    );
  }

  /// 初始化失败状态
  HomeState toErrorState(String message) {
    return copyWith(
      isInitializing: false,
      errorMessage: message,
    );
  }

  /// 复制实例方法
  HomeState copyWith({
    bool? isInitializing,
    bool? isInitialized,
    String? errorMessage,
    MyUserProto? user,
  }) {
    return HomeState(
      isInitializing: isInitializing ?? this.isInitializing,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }

  /// 判断是否有错误
  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props =>
      [isInitializing, isInitialized, errorMessage, user];
}
