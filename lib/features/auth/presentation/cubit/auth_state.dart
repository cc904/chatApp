part of 'auth_cubit.dart';

class AuthState extends Equatable {
  // 表单数据
  final String? phoneNumber;
  final String? verificationCode;
  final String? password;
  final String? nickname;

  // 验证码状态
  final bool isCodeSent;
  final int? countdown;

  // 加载状态
  final bool isLoading;

  // 错误信息
  final String? errorMessage;

  // 认证成功数据 - 使用本地User模型而非Proto对象
  final CurrentUser? currentUser;
  final String? authToken;

  const AuthState({
    this.phoneNumber,
    this.verificationCode,
    this.password,
    this.nickname,
    this.isCodeSent = false,
    this.countdown,
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
    this.authToken,
  });

  // 状态判断方法
  bool get isInitial => !isLoading && !isAuthenticated && errorMessage == null;
  bool get hasError => errorMessage != null;
  bool get isAuthenticated =>
      currentUser != null &&
      currentUser!.userId.isNotEmpty &&
      authToken != null &&
      authToken!.isNotEmpty;

  // 创建表单状态
  factory AuthState.initial() {
    return const AuthState();
  }

  // 创建加载中状态
  AuthState toLoadingState() {
    return copyWith(isLoading: true, errorMessage: null);
  }

  // 创建错误状态
  AuthState toErrorState(String message) {
    return copyWith(isLoading: false, errorMessage: message);
  }

  // 创建认证成功状态
  AuthState toAuthenticatedState({
    required CurrentUser currentUser,
    required String authToken,
  }) {
    return copyWith(
      isLoading: false,
      errorMessage: null,
      currentUser: currentUser,
      authToken: authToken,
    );
  }

  // 清除错误
  AuthState clearError() {
    return copyWith(errorMessage: null);
  }

  // 更新验证码状态
  AuthState updateCodeSentStatus({required bool isCodeSent, int? countdown}) {
    return copyWith(
      isCodeSent: isCodeSent,
      countdown: countdown,
      isLoading: false,
    );
  }

  // 复制方法,创建新的状态实例
  AuthState copyWith({
    String? phoneNumber,
    String? verificationCode,
    String? password,
    String? nickname,
    bool? isCodeSent,
    int? countdown,
    bool? isLoading,
    String? errorMessage,
    CurrentUser? currentUser,
    String? authToken,
  }) {
    return AuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationCode: verificationCode ?? this.verificationCode,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      countdown: countdown ?? this.countdown,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // 特意不使用??,允许设置为null
      currentUser: currentUser ?? this.currentUser,
      authToken: authToken ?? this.authToken,
    );
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        verificationCode,
        password,
        nickname,
        isCodeSent,
        countdown,
        isLoading,
        errorMessage,
        currentUser,
        authToken,
      ];
}
