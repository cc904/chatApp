part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthFormState extends AuthState {
  final String? phoneNumber;
  final String? verificationCode;
  final String? password;
  final String? nickname;
  final bool isCodeSent;
  final int? countdown;

  const AuthFormState({
    this.phoneNumber,
    this.verificationCode,
    this.password,
    this.nickname,
    this.isCodeSent = false,
    this.countdown,
  });

  AuthFormState copyWith({
    String? phoneNumber,
    String? verificationCode,
    String? password,
    String? nickname,
    bool? isCodeSent,
    int? countdown,
  }) {
    return AuthFormState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationCode: verificationCode ?? this.verificationCode,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      countdown: countdown ?? this.countdown,
    );
  }

  @override
  List<Object> get props => [phoneNumber ?? '', verificationCode ?? '', password ?? '', nickname ?? '', isCodeSent, countdown ?? 0];
}

class AuthVerificationCodeSent extends AuthState {
  const AuthVerificationCodeSent();
}

class AuthSuccess extends AuthState {
  final String userId;
  final String token;

  const AuthSuccess({
    required this.userId,
    required this.token,
  });

  @override
  List<Object> get props => [userId, token];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

