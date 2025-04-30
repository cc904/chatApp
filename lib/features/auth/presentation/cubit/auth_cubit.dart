import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      emit(const AuthLoading());
      // TODO: 实现发送验证码逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      emit(const AuthVerificationCodeSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyCode(String phoneNumber, String code) async {
    try {
      emit(const AuthLoading());
      // TODO: 实现验证码验证逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginWithPassword(String phoneNumber, String password) async {
    try {
      emit(const AuthLoading());
      // TODO: 实现密码登录逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String phoneNumber, String password) async {
    try {
      emit(const AuthLoading());
      // TODO: 实现注册逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String phoneNumber, String newPassword) async {
    try {
      emit(const AuthLoading());
      // TODO: 实现重置密码逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
