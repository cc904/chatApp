import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/network/auth_api_client.dart';

part 'auth_state.dart';

final _logger = LogService.instance;

class AuthCubit extends Cubit<AuthState> {
  Timer? _countdownTimer;
  static const int countdownDuration = 60;

  // 认证仓库
  final AuthRepository _authRepository;

  // 服务器URL

  AuthCubit({
    required String serverUrl,
  })  : _authRepository = AuthRepositoryImpl.getInstance(serverUrl: serverUrl),
        super(AuthState.initial()) {
    _init();
  }

  /// 初始化
  Future<void> _init() async {
    _logger.i('初始化AuthCubit');
    try {
      // 初始authRepository
      await _authRepository.init();
      await loginWithToken();

      // // 尝试使用令牌自动登录
      // final response = await _authRepository.loginWithToken();
      // if (response.success && response.myUser != null) {
      //   _logger.i('loginWithToken成功，用户ID: ${response.myUser!.userId}');
      //   emit(state.toAuthenticatedState(
      //     myUser: response.myUser!,
      //   ));
      // }
    } catch (error) {
      _logger.e('初始化认证服务失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  void updatePhoneNumber(String phoneNumber) {
    // _logger.i('更新手机号: $phoneNumber');
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  void updateVerificationCode(String code) {
    // _logger.i('更新验证码: $code');
    emit(state.copyWith(verificationCode: code));
  }

  void updatePassword(String password) {
    // _logger.i('更新密码: $password');
    emit(state.copyWith(password: password));
  }

  void updateNickname(String nickname) {
    // _logger.i('更新昵称: $nickname');
    emit(state.copyWith(nickname: nickname));
  }

  /// 发送验证码
  ///
  /// 根据指定目的向当前手机号发送验证码
  ///
  /// 参数:
  /// - purpose: 验证码用途 (login/register/reset)
  Future<void> sendVerificationCode({required String purpose}) async {
    _logger.i('发送验证码', extra: {'purpose': purpose});

    // 检查手机号是否有效
    if (state.phoneNumber?.isEmpty ?? true) {
      _logger.i('手机号为空');
      emit(state.toErrorState('请输入手机号码'));
      return;
    }
    if (state.phoneNumber!.length != 11) {
      _logger.e('手机号错误: ${state.phoneNumber}', stackTrace: StackTrace.current);
      emit(state.toErrorState('请输入正确的手机号码'));
      return;
    }

    try {
      _logger.i('发送验证码中...');
      if (isClosed) return;
      emit(state.toLoadingState());

      // 使用认证仓库发送验证码
      final success = await _authRepository.sendVerificationCode(
        state.phoneNumber!,
        purpose,
      );

      if (!success) {
        throw '发送验证码失败,请稍后再试';
      }

      if (isClosed) return;
      emit(state.updateCodeSentStatus(
        isCodeSent: true,
        countdown: countdownDuration,
      ));
      _logger.i('验证码已发送,倒计时: $countdownDuration');

      _startCountdown();
    } catch (error) {
      _logger.e('发送验证码错误: $error',
          error: error, stackTrace: StackTrace.current);
      if (isClosed) return;
      emit(state.toErrorState(error.toString()));
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final newCountdown = (state.countdown ?? 0) - 1;
      if (newCountdown <= 0) {
        timer.cancel();
        if (!isClosed) {
          emit(state.updateCodeSentStatus(isCodeSent: false, countdown: null));
        }
      } else {
        if (!isClosed) emit(state.copyWith(countdown: newCountdown));
      }
    });
  }

  /// 使用令牌登录
  ///
  /// 尝试使用存储的令牌自动登录
  ///
  /// 返回是否登录成功
  Future<bool> loginWithToken() async {
    try {
      emit(state.toLoadingState());
      _logger.i('尝试使用令牌登录');

      final response = await _authRepository.loginWithToken();

      if (response.success && response.myUser != null) {
        _logger.i('令牌登录成功', extra: {'userId': response.myUser!.userId});

        emit(state.toAuthenticatedState(
          myUser: response.myUser!,
        ));
        return true;
      } else {
        _logger.i('令牌登录失败：${response.message}');
        emit(state.copyWith(
          isLoading: false,
        ));
        return false;
      }
    } catch (error) {
      _logger.e('令牌登录过程中发生错误', error: error);
      emit(state.toErrorState(error.toString()));
      return false;
    }
  }

  /// 用户登录
  ///
  /// 使用手机号和密码或验证码登录
  ///
  /// 参数:
  /// - isQuickLogin: 是否使用快捷登录(验证码)
  Future<void> login(bool isQuickLogin) async {
    _logger.i('登录请求 - 快捷登录: $isQuickLogin');

    try {
      // 验证手机号
      if (state.phoneNumber?.isEmpty ?? true) {
        _logger.i('手机号为空');
        throw '请输入手机号码';
      }
      if (state.phoneNumber!.length != 11) {
        _logger.e('手机号错误: ${state.phoneNumber}',
            stackTrace: StackTrace.current);
        throw '请输入正确的手机号码';
      }

      emit(state.toLoadingState());
      // _logger.i('登录中...');

      AuthResponse response;

      if (isQuickLogin) {
        // 验证码登录
        if (state.verificationCode?.isEmpty ?? true) {
          _logger.i('验证码为空');
          throw '请输入验证码';
        }

        _logger.i('使用验证码登录: ${state.verificationCode}');
        response = await _authRepository.loginWithCode(
            state.phoneNumber!, state.verificationCode!);
      } else {
        // 密码登录
        if (state.password?.isEmpty ?? true) {
          _logger.i('密码为空');
          throw '请输入密码';
        }

        _logger.i('使用密码登录: ${state.password}');
        response = await _authRepository.loginWithPassword(
            state.phoneNumber!, state.password!);
      }

      // 检查登录结果
      if (!response.success) {
        throw response.message;
      }

      // 检查返回的用户信息
      if (!response.hasUserId()) {
        throw '登录成功但未返回用户信息';
      }

      // 登录成功
      _logger.i('登录成功，用户信息: ${response.myUser!.userId}');

      emit(state.toAuthenticatedState(
        myUser: response.myUser!,
      ));
    } catch (error) {
      _logger.e('登录错误: $error', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  Future<void> register(String phoneNumber, String password,
      String verificationCode, String nickname) async {
    _logger.i('注册请求: $phoneNumber, 昵称: $nickname');
    try {
      // 验证手机号
      if (phoneNumber.isEmpty) {
        _logger.i('手机号为空');
        throw '请输入手机号码';
      }
      if (phoneNumber.length != 11) {
        _logger.e('手机号错误: $phoneNumber', stackTrace: StackTrace.current);
        throw '请输入正确的手机号码';
      }

      // 验证验证码
      if (verificationCode.isEmpty) {
        _logger.i('验证码为空');
        throw '请输入验证码';
      }

      // 验证密码
      if (password.isEmpty) {
        _logger.i('密码为空');
        throw '请输入密码';
      }
      if (password.length < 6) {
        _logger.i('密码不符合要求');
        throw '密码长度至少6位';
      }

      // 验证昵称
      if (nickname.isEmpty) {
        _logger.i('昵称为空');
        throw '请输入昵称';
      }

      // 更新表单数据
      emit(state.copyWith(
        phoneNumber: phoneNumber,
        password: password,
        verificationCode: verificationCode,
        nickname: nickname,
      ));

      emit(state.toLoadingState());
      _logger.i('注册中...');

      // 使用认证仓库注册
      final response = await _authRepository.register(
        phoneNumber,
        password,
        verificationCode,
        nickname,
      );

      // 检查注册是否成功
      if (!response.success) {
        throw response.message;
      }

      // 注册成功
      _logger.i('注册成功，用户ID: ${response.myUser!.userId}');

      emit(state.toAuthenticatedState(
        myUser: response.myUser!,
      ));
    } catch (error) {
      _logger.e('注册错误: $error', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  Future<void> resetPassword(
      String phoneNumber, String newPassword, String verificationCode) async {
    _logger.i('重置密码请求: $phoneNumber');
    try {
      // 验证手机号
      if (phoneNumber.isEmpty) {
        _logger.i('手机号为空');
        throw '请输入手机号码';
      }
      if (phoneNumber.length != 11) {
        _logger.e('手机号错误: $phoneNumber', stackTrace: StackTrace.current);
        throw '请输入正确的手机号码';
      }

      // 验证验证码
      if (verificationCode.isEmpty) {
        _logger.i('验证码为空');
        throw '请输入验证码';
      }

      // 验证密码
      if (newPassword.isEmpty) {
        _logger.i('密码为空');
        throw '请输入新密码';
      }
      if (newPassword.length < 6) {
        _logger.i('密码不符合要求');
        throw '密码长度至少6位';
      }

      // 更新表单数据
      emit(state.copyWith(
        phoneNumber: phoneNumber,
        password: newPassword,
        verificationCode: verificationCode,
      ));

      emit(state.toLoadingState());
      _logger.i('重置密码中...');

      // 使用认证仓库重置密码
      final success = await _authRepository.resetPassword(
        phoneNumber,
        verificationCode,
        newPassword,
      );

      if (!success) {
        throw '重置密码失败';
      }

      // 重置成功
      _logger.i('重置密码成功');
      emit(state.copyWith(isLoading: false));
    } catch (error) {
      _logger.e('重置密码错误: $error', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
      // 重新抛出异常,以便上层代码捕获
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }

  /// 退出登录
  Future<void> logout() async {
    _logger.i('退出登录');
    try {
      // 使用认证仓库登出
      final success = await _authRepository.logout();
      if (!success) {
        throw '退出登录失败';
      }

      // 重置状态
      emit(AuthState.initial());
      _logger.i('退出登录成功');
    } catch (error) {
      _logger.e('退出登录失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState('退出登录失败: ${error.toString()}'));
    }
  }
}
