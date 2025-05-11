import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/network/auth_api_client.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/my_user_service.dart';
import 'package:cc/core/services/communication_service.dart';

part 'auth_state.dart';

final _logger = LogService.instance;

class AuthCubit extends Cubit<AuthState> {
  Timer? _countdownTimer;
  static const int countdownDuration = 60;

  // 通信服务
  final CommunicationService _communicationService = CommunicationService();

  // 认证API客户端
  final AuthApiClient _authApiClient = AuthApiClient.getInstance();

  // 服务器URL
  final String _serverUrl;

  AuthCubit({
    required String serverUrl,
  })  : _serverUrl = serverUrl,
        super(AuthState.initial()) {
    _initAuthApiClient();
    // 订阅认证响应事件
    _authApiClient.onAuthResponse.listen(_handleAuthResponse);
  }

  /// 初始化认证API客户端
  Future<void> _initAuthApiClient() async {
    try {
      final success = await _authApiClient.init(
        serverUrl: _serverUrl,
      );

      if (!success) {
        _logger.e('初始化认证API客户端失败', stackTrace: StackTrace.current);
        emit(state.toErrorState('初始化认证服务失败,请重试'));
      }
    } catch (error) {
      _logger.e('初始化认证API客户端出错', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  // 处理认证响应
  void _handleAuthResponse(AuthResponse response) {
    _logger.i('收到认证响应', extra: {'success': response.success, 'message': response.message});

    if (!response.success) {
      emit(state.toErrorState(response.message));
      return;
    }

    if (response.hasUserId() && response.hasToken()) {
      // 先不要发出认证成功的状态，等数据库初始化完成后再发出
      final userId = response.userId ?? '';
      final token = response.token ?? '';

      // 初始化数据库，然后再发出认证成功的状态
      _initDatabases(userId, token).then((_) {
        // 数据库初始化成功后，再发出认证成功的状态
        _logger.i('数据库和服务初始化完成，发出认证成功状态');
        emit(state.toAuthenticatedState(
          userId: userId,
          token: token,
        ));
      }).catchError((error) {
        _logger.e('初始化失败，无法完成认证', error: error, stackTrace: StackTrace.current);
        emit(state.toErrorState('初始化失败: ${error.toString()}'));
      });
    }
  }

  // 初始化数据库
  Future<void> _initDatabases(String userId, String token) async {
    try {
      _logger.i('开始初始化数据库', extra: {'userId': userId});

      // 初始化Isar数据库
      await DatabaseInitializer.init(userId: userId);

      // 验证数据库是否成功初始化
      if (!DatabaseInitializer.isInitialized) {
        throw Exception('数据库初始化失败，但未抛出异常');
      }

      _logger.i('数据库初始化成功，开始保存用户信息');

      // 保存当前用户信息
      await MyUserService.saveCurrentUser(
        userId: userId,
        token: token,
        name: '我',
      );

      // 初始化实时通信
      await _initRealTimeCommunication(userId, token);
    } catch (error) {
      _logger.e('初始化数据库出错', error: error, stackTrace: StackTrace.current);
      // 不再在这里修改状态，而是向上抛出异常
      throw Exception('初始化数据库出错: ${error.toString()}');
    }
  }

  // 初始化实时通信
  Future<void> _initRealTimeCommunication(String userId, String token) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        _logger.i('初始化实时通信，尝试次数: ${retryCount + 1}');

        // 直接尝试连接
        final success = await _communicationService.connect(
          serverUrl: _serverUrl,
          userId: userId,
          token: token,
        );

        if (success) {
          _logger.i('实时通信初始化成功');
          return;
        } else {
          _logger.e('初始化实时通信失败', stackTrace: StackTrace.current);
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2)); // 递增延迟
            continue;
          }
        }
      } catch (error) {
        _logger.e('初始化实时通信错误', error: error, stackTrace: StackTrace.current);
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
      }
    }

    // 所有重试都失败后，记录错误但不中断认证流程
    _logger.e('实时通信初始化失败，已达到最大重试次数', stackTrace: StackTrace.current);
  }

  void updatePhoneNumber(String phoneNumber) {
    _logger.i('更新手机号: $phoneNumber');
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  void updateVerificationCode(String code) {
    _logger.i('更新验证码: $code');
    emit(state.copyWith(verificationCode: code));
  }

  void updatePassword(String password) {
    _logger.i('更新密码: $password');
    emit(state.copyWith(password: password));
  }

  void updateNickname(String nickname) {
    _logger.i('更新昵称: $nickname');
    emit(state.copyWith(nickname: nickname));
  }

  Future<void> sendVerificationCode({required String purpose}) async {
    _logger.i('发送验证码', extra: {'purpose': purpose});

    if (state.phoneNumber?.length != 11) {
      _logger.e('手机号错误: ${state.phoneNumber}', stackTrace: StackTrace.current);
      emit(state.toErrorState('请输入正确的手机号码'));
      return;
    }

    try {
      _logger.i('发送验证码中...');
      emit(state.toLoadingState());

      // 使用认证API客户端发送验证码
      final success = await _authApiClient.sendVerificationCode(
        state.phoneNumber!,
        purpose,
      );

      if (!success) {
        throw '发送验证码失败,请稍后再试';
      }

      emit(state.updateCodeSentStatus(
        isCodeSent: true,
        countdown: countdownDuration,
      ));
      _logger.i('验证码已发送,倒计时: $countdownDuration');

      _startCountdown();
    } catch (error) {
      _logger.e('发送验证码错误: $error', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newCountdown = (state.countdown ?? 0) - 1;
      if (newCountdown <= 0) {
        timer.cancel();
        emit(state.updateCodeSentStatus(isCodeSent: false, countdown: null));
      } else {
        emit(state.copyWith(countdown: newCountdown));
      }
    });
  }

  Future<void> login(bool isQuickLogin) async {
    _logger.i('登录请求 - 快捷登录: $isQuickLogin');

    try {
      // 验证手机号
      if (state.phoneNumber?.isEmpty ?? true) {
        _logger.i('手机号为空');
        throw '请输入手机号码';
      }
      if (state.phoneNumber!.length != 11) {
        _logger.e('手机号错误: ${state.phoneNumber}', stackTrace: StackTrace.current);
        throw '请输入正确的手机号码';
      }

      emit(state.toLoadingState());
      _logger.i('登录中...');

      bool success = false;

      if (isQuickLogin) {
        // 验证码登录
        if (state.verificationCode?.isEmpty ?? true) {
          _logger.i('验证码为空');
          throw '请输入验证码';
        }

        _logger.i('使用验证码登录: ${state.verificationCode}');
        success = await _authApiClient.loginWithCode(
          state.phoneNumber!,
          state.verificationCode!,
        );
      } else {
        // 密码登录
        if (state.password?.isEmpty ?? true) {
          _logger.i('密码为空');
          throw '请输入密码';
        }

        _logger.i('使用密码登录: ${state.password}');
        success = await _authApiClient.loginWithPassword(
          state.phoneNumber!,
          state.password!,
        );
      }

      if (!success) {
        throw '登录失败,请检查网络连接';
      }

      // 注意：登录结果将通过AuthApiClient的onAuthResponse回调处理
    } catch (error) {
      _logger.e('登录错误: $error', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  Future<void> register(String phoneNumber, String password, String verificationCode, String nickname) async {
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

      final success = await _authApiClient.register(phoneNumber, verificationCode, password, nickname);

      if (!success) {
        throw '注册失败,请检查网络连接';
      }

      // 注意：注册结果将通过AuthApiClient的onAuthResponse回调处理
    } catch (error) {
      _logger.e('注册错误: $error', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  Future<void> resetPassword(String phoneNumber, String newPassword, String verificationCode) async {
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

      final success = await _authApiClient.resetPassword(phoneNumber, verificationCode, newPassword);

      if (!success) {
        throw '重置密码失败,请检查网络连接';
      }

      // 注意：重置密码结果将通过AuthApiClient的onAuthResponse回调处理
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
    _communicationService.disconnect();
    return super.close();
  }
}
