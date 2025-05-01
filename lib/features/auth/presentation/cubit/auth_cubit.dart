import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev;

part 'auth_state.dart';

final _logger = dev.log;

class AuthCubit extends Cubit<AuthState> {
  Timer? _countdownTimer;
  static const int countdownDuration = 60;

  AuthCubit() : super(const AuthFormState());

  void updatePhoneNumber(String phoneNumber) {
    final currentState = state;
    _logger('更新手机号: $phoneNumber');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(phoneNumber: phoneNumber));
    }
  }

  void updateVerificationCode(String code) {
    final currentState = state;
    _logger('更新验证码: $code');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(verificationCode: code));
    }
  }

  void updatePassword(String password) {
    final currentState = state;
    _logger('更新密码: $password');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(password: password));
    }
  }

  void updateNickname(String nickname) {
    final currentState = state;
    _logger('更新昵称: $nickname');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(nickname: nickname));
    }
  }

  Future<void> sendVerificationCode() async {
    final currentState = state;
    _logger('发送验证码');
    if (currentState is AuthFormState) {
      if (currentState.phoneNumber?.length != 11) {
        _logger('手机号错误: ${currentState.phoneNumber}');
        emit(const AuthError('请输入正确的手机号码'));
        emit(currentState);
        return;
      }

      try {
        _logger('发送验证码中...');
        emit(AuthLoading());
        // TODO: 实现发送验证码的API调用
        await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求

        emit(currentState.copyWith(
          isCodeSent: true,
          countdown: countdownDuration,
        ));
        _logger('验证码已发送，倒计时: $countdownDuration');

        _startCountdown();
      } catch (e) {
        _logger('发送验证码错误: $e');
        emit(AuthError(e.toString()));
        emit(currentState);
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is AuthFormState) {
        final newCountdown = (currentState.countdown ?? 0) - 1;
        if (newCountdown <= 0) {
          timer.cancel();
          emit(currentState.copyWith(isCodeSent: false, countdown: null));
        } else {
          emit(currentState.copyWith(countdown: newCountdown));
        }
      }
    });
  }

  Future<void> login(bool isQuickLogin) async {
    final currentState = state;
    _logger('登录请求 - 快捷登录: $isQuickLogin');
    if (currentState is AuthFormState) {
      try {
        // 验证手机号
        if (currentState.phoneNumber?.isEmpty ?? true) {
          _logger('手机号为空');
          throw '请输入手机号码';
        }
        if (currentState.phoneNumber!.length != 11) {
          _logger('手机号错误: ${currentState.phoneNumber}');
          throw '请输入正确的手机号码';
        }

        emit(AuthLoading());
        _logger('登录中...');

        if (isQuickLogin) {
          // 验证码登录
          if (currentState.verificationCode?.isEmpty ?? true) {
            _logger('验证码为空');
            throw '请输入验证码';
          }
          _logger('使用验证码登录: ${currentState.verificationCode}');
          // TODO: 实现验证码登录API调用
        } else {
          // 密码登录
          if (currentState.password?.isEmpty ?? true) {
            _logger('密码为空');
            throw '请输入密码';
          }
          _logger('使用密码登录: ${currentState.password}');
          // TODO: 实现密码登录API调用
        }

        await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
        _logger('登录成功');
        emit(const AuthSuccess('mock_token'));
      } catch (e) {
        _logger('登录错误: $e');
        emit(AuthError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> register(String phoneNumber, String password, String verificationCode, String nickname) async {
    _logger('注册请求: $phoneNumber, 昵称: $nickname');
    try {
      // 验证手机号
      if (phoneNumber.isEmpty) {
        _logger('手机号为空');
        throw '请输入手机号码';
      }
      if (phoneNumber.length != 11) {
        _logger('手机号错误: $phoneNumber');
        throw '请输入正确的手机号码';
      }

      // 验证验证码
      if (verificationCode.isEmpty) {
        _logger('验证码为空');
        throw '请输入验证码';
      }

      // 验证密码
      if (password.isEmpty) {
        _logger('密码为空');
        throw '请输入密码';
      }
      if (password.length < 6) {
        _logger('密码不符合要求');
        throw '密码长度至少6位';
      }

      // 验证昵称
      if (nickname.isEmpty) {
        _logger('昵称为空');
        throw '请输入昵称';
      }

      emit(AuthLoading());
      _logger('注册中...');

      // TODO: 实现注册API调用
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

      // 检查手机号是否已注册（模拟）
      if (phoneNumber == '13800000000') {
        throw '该手机号已注册';
      }

      _logger('注册成功');
      emit(const AuthSuccess('mock_token'));
    } catch (e) {
      _logger('注册错误: $e');
      emit(AuthError(e.toString()));
      // 重置为表单状态
      emit(AuthFormState(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
        password: password,
        nickname: nickname,
      ));
    }
  }

  Future<void> resetPassword(String phoneNumber, String newPassword, String verificationCode) async {
    dev.log('重置密码请求: $phoneNumber');
    try {
      // 验证手机号
      if (phoneNumber.isEmpty) {
        dev.log('手机号为空');
        throw '请输入手机号码';
      }
      if (phoneNumber.length != 11) {
        dev.log('手机号错误: $phoneNumber');
        throw '请输入正确的手机号码';
      }

      // 验证验证码
      if (verificationCode.isEmpty) {
        dev.log('验证码为空');
        throw '请输入验证码';
      }

      // 验证密码
      if (newPassword.isEmpty) {
        dev.log('密码为空');
        throw '请输入新密码';
      }
      if (newPassword.length < 6) {
        dev.log('密码不符合要求');
        throw '密码长度至少6位';
      }

      emit(AuthLoading());
      dev.log('重置密码中...');

      // TODO: 实现重置密码API调用
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

      // 模拟一些可能的错误情况（测试用）
      if (phoneNumber == '13800000000') {
        throw '该手机号未注册';
      }
      if (verificationCode == '000000') {
        throw '验证码错误';
      }

      dev.log('重置密码成功');
      emit(const AuthSuccess('mock_token'));
    } catch (e) {
      dev.log('重置密码错误: $e');
      emit(AuthError(e.toString()));
      // 重置为表单状态
      emit(AuthFormState(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
        password: newPassword,
      ));
      // 重新抛出异常，以便上层代码捕获
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
