import 'dart:async';
import 'package:cc/core/database/models/current_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:cc/core/services/auth_token_sync_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';

part 'auth_state.dart';

final _logger = LogService.instance;

class AuthCubit extends Cubit<AuthState> {
  Timer? _countdownTimer;
  static const int countdownDuration = 60;

  // 认证仓库
  final AuthRepository _authRepository;
  final EnhancedTokenManager _tokenManager = EnhancedTokenManager.instance;

  // 服务器URL

  AuthCubit({
    required String serverUrl,
  })  : _authRepository = AuthRepositoryImpl.getInstance(serverUrl: serverUrl),
        super(AuthState.initial()) {
    _init();
  }

  /// 初始化
  Future<void> _init() async {
    _logger.x('初始化AuthCubit (新认证模式)');
    try {
      // 初始化认证仓库
      await _authRepository.init();
      await loginWithToken();
    } catch (error) {
      _logger.e('初始化认证服务失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  void updatePhoneNumber(String phoneNumber) {
    // _logger.x('更新手机号', extra: {'phoneNumber': phoneNumber});
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  void updateVerificationCode(String code) {
    // _logger.x('更新验证码', extra: {'code': code});
    emit(state.copyWith(verificationCode: code));
  }

  void updatePassword(String password) {
    // _logger.x('更新密码');
    emit(state.copyWith(password: password));
  }

  void updateNickname(String nickname) {
    // _logger.x('更新昵称', extra: {'nickname': nickname});
    emit(state.copyWith(nickname: nickname));
  }

  /// 发送验证码
  ///
  /// 根据指定目的向当前手机号发送验证码
  ///
  /// 参数:
  /// - purpose: 验证码用途 (login/register/reset)
  Future<void> sendVerificationCode(String purpose) async {
    try {
      if (state.phoneNumber?.isEmpty ?? true) {
        _logger.i('手机号为空');
        emit(state.toErrorState('请输入手机号码'));
        return;
      }

      _logger.x('发送验证码', extra: {
        'phoneNumber': state.phoneNumber,
        'purpose': purpose,
      });

      emit(state.toLoadingState());

      final success = await _authRepository.sendVerificationCode(
        state.phoneNumber!,
        purpose,
      );

      if (success) {
        emit(state.updateCodeSentStatus(
          isCodeSent: true,
          countdown: countdownDuration,
        ));
        _startCountdown();
        _logger.i('验证码发送成功');
      } else {
        emit(state.toErrorState('验证码发送失败，请重试'));
      }
    } catch (error) {
      _logger.e('发送验证码失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState('发送验证码失败：${error.toString()}'));
    }
  }

  void _startCountdown() {
    _logger.x('开始倒计时', extra: {'duration': countdownDuration});
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
      _logger.x('尝试使用令牌登录');

      final response = await _authRepository.loginWithToken();

      // 提取用户信息
      final userData = response['currentUser'] ?? response['user'];
      if (userData != null) {
        _logger.i('令牌登录成功', extra: {'userId': userData['userId']});

        // 创建CurrentUser对象
        final currentUser = CurrentUser()
          ..userId = userData['userId'] ?? ''
          ..name = userData['nickname'] ?? userData['name'] ?? ''
          ..phone = userData['phone'] ?? ''
          ..email = userData['email'] ?? ''
          ..avatar = userData['avatar'] ?? ''
          ..status = userData['status'] ?? ''
          ..lastLoginTime = userData['lastLoginTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(userData['lastLoginTime'])
              : DateTime.now();

        // 🔑 自动同步Token到所有需要认证的服务
        await AuthTokenSyncService.instance.syncTokenToAllServices();

        emit(state.toAuthenticatedState(
          currentUser: currentUser,
        ));
        return true;
      } else {
        _logger.i('令牌登录失败：未返回用户信息');
        emit(state.copyWith(isLoading: false));
        return false;
      }
    } catch (error) {
      _logger.i('令牌登录失败：${error.toString()}');
      emit(state.copyWith(isLoading: false));
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
    _logger.x('登录请求', extra: {
      'isQuickLogin': isQuickLogin,
      'phoneNumber': state.phoneNumber
    });

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

      Map<String, dynamic> response;

      if (isQuickLogin) {
        // 验证码登录
        if (state.verificationCode?.isEmpty ?? true) {
          _logger.i('验证码为空');
          throw '请输入验证码';
        }

        _logger.x('使用验证码登录', extra: {'phoneNumber': state.phoneNumber});
        response = await _authRepository.loginWithCode(
            state.phoneNumber!, state.verificationCode!);
      } else {
        // 密码登录
        if (state.password?.isEmpty ?? true) {
          _logger.i('密码为空');
          throw '请输入密码';
        }

        _logger.x('使用密码登录', extra: {'phoneNumber': state.phoneNumber});
        response = await _authRepository.loginWithPassword(
            state.phoneNumber!, state.password!);
      }

      // 提取用户信息
      final userData = response['currentUser'] ?? response['user'];
      if (userData == null) {
        throw '登录成功但未返回用户信息';
      }

      // 登录成功
      _logger.i('登录成功，用户信息: ${userData['userId']}');

      // 创建CurrentUser对象
      final currentUser = CurrentUser()
        ..userId = userData['userId'] ?? ''
        ..name = userData['nickname'] ?? userData['name'] ?? ''
        ..phone = userData['phone'] ?? ''
        ..email = userData['email'] ?? ''
        ..avatar = userData['avatar'] ?? ''
        ..status = userData['status'] ?? ''
        ..lastLoginTime = userData['lastLoginTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(userData['lastLoginTime'])
            : DateTime.now();

      // 🔑 自动同步Token到所有需要认证的服务
      await AuthTokenSyncService.instance.syncTokenToAllServices();

      emit(state.toAuthenticatedState(
        currentUser: currentUser,
      ));
    } catch (error) {
      _logger.e('登录失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState('登录失败: ${error.toString()}'));
    }
  }

  /// 用户注册
  ///
  /// 使用手机号、密码、验证码和昵称注册
  Future<void> register() async {
    _logger.x('注册请求', extra: {'phoneNumber': state.phoneNumber});

    try {
      // 验证输入
      if (state.phoneNumber?.isEmpty ?? true) {
        throw '请输入手机号码';
      }
      if (state.phoneNumber!.length != 11) {
        throw '请输入正确的手机号码';
      }
      if (state.password?.isEmpty ?? true) {
        throw '请输入密码';
      }
      if (state.verificationCode?.isEmpty ?? true) {
        throw '请输入验证码';
      }
      if (state.nickname?.isEmpty ?? true) {
        throw '请输入昵称';
      }

      emit(state.toLoadingState());

      _logger.x('开始注册', extra: {
        'phoneNumber': state.phoneNumber,
        'nickname': state.nickname,
      });

      final response = await _authRepository.register(
        state.phoneNumber!,
        state.password!,
        state.verificationCode!,
        state.nickname!,
      );

      // 提取用户信息
      final userData = response['currentUser'] ?? response['user'];
      if (userData == null) {
        throw '注册成功但未返回用户信息';
      }

      // 注册成功
      _logger.i('注册成功，用户信息: ${userData['userId']}');

      // 创建CurrentUser对象
      final currentUser = CurrentUser()
        ..userId = userData['userId'] ?? ''
        ..name = userData['nickname'] ?? userData['name'] ?? ''
        ..phone = userData['phone'] ?? ''
        ..email = userData['email'] ?? ''
        ..avatar = userData['avatar'] ?? ''
        ..status = userData['status'] ?? ''
        ..lastLoginTime = userData['lastLoginTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(userData['lastLoginTime'])
            : DateTime.now();

      // 🔑 自动同步Token到所有需要认证的服务
      await AuthTokenSyncService.instance.syncTokenToAllServices();

      emit(state.toAuthenticatedState(
        currentUser: currentUser,
      ));
    } catch (error) {
      _logger.e('注册失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState('注册失败: ${error.toString()}'));
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      _logger.i('开始登出操作');

      // 停止Token管理
      _tokenManager.stopTokenManagement();

      // 调用仓库登出
      await _authRepository.logout();

      // 清除所有服务的Token
      AuthTokenSyncService.instance.clearTokenFromAllServices();

      emit(AuthState.initial());
      _logger.i('用户已登出');
    } catch (error) {
      _logger.e('登出失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState('登出失败: ${error.toString()}'));
    }
  }

  /// 重置密码
  Future<void> resetPassword() async {
    try {
      if (state.phoneNumber?.isEmpty ?? true) {
        throw '请输入手机号码';
      }
      if (state.verificationCode?.isEmpty ?? true) {
        throw '请输入验证码';
      }
      if (state.password?.isEmpty ?? true) {
        throw '请输入新密码';
      }

      emit(state.toLoadingState());

      final success = await _authRepository.resetPassword(
        state.phoneNumber!,
        state.verificationCode!,
        state.password!,
      );

      if (success) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: null,
        ));
        _logger.i('密码重置成功');
      } else {
        throw '密码重置失败';
      }
    } catch (error) {
      _logger.e('重置密码失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState('重置密码失败: ${error.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _logger.x('关闭AuthCubit');
    _countdownTimer?.cancel();
    return super.close();
  }
}
