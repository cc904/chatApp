import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/network/index.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/core/proto/generated/auth.pb.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/my_user_service.dart';

part 'auth_state.dart';

final _logger = LogService('auth_cubit.dart');

class AuthCubit extends Cubit<AuthState> {
  Timer? _countdownTimer;
  static const int countdownDuration = 60;

  // 添加ChatRepository依赖，用于初始化Socket连接
  final ChatRepository? _chatRepository;

  // 添加ChatCubit依赖，用于在登录成功后初始化
  final ChatCubit? _chatCubit;

  // 认证服务
  final AuthService _authService = AuthService.getInstance();
  // 服务器URL，在构造函数中赋值
  final String _serverUrl;
  // 模拟模式
  final bool _simulationMode;

  AuthCubit({
    required String serverUrl,
    ChatRepository? chatRepository,
    ChatCubit? chatCubit,
    bool simulationMode = false,
  })  : _chatRepository = chatRepository,
        _chatCubit = chatCubit,
        _serverUrl = serverUrl,
        _simulationMode = simulationMode,
        super(AuthState.initial()) {
    // 初始化认证服务
    _initAuthService();
    // 订阅认证响应事件
    _authService.onAuthResponse.listen(_handleAuthResponse);
  }

  // 初始化认证服务
  Future<void> _initAuthService() async {
    try {
      final success = await _authService.init(
        serverUrl: _serverUrl,
        simulationMode: _simulationMode,
      );

      if (!success) {
        _logger.e('初始化认证服务失败');
        emit(state.toErrorState('初始化认证服务失败，请重试'));
      }
    } catch (e) {
      _logger.e('初始化认证服务出错', error: e);
      emit(state.toErrorState(e.toString()));
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
      emit(state.toAuthenticatedState(userId: response.userId, token: response.token));

      // 认证成功后，准备实时通信
      _initRealTimeCommunication(response.userId, response.token);
    }
  }

  // 初始化实时通信
  Future<void> _initRealTimeCommunication(String userId, String token) async {
    if (_chatRepository == null) {
      _logger.w('聊天仓库未初始化，无法开启实时通信');
      return;
    }

    try {
      _logger.i('初始化实时通信连接', extra: {'userId': userId});

      // 获取来自认证服务的连接信息
      final connectionInfo = _authService.getConnectionInfo();

      // 使用认证后的用户ID和令牌初始化实时通信
      final success = await _chatRepository.initRealTimeConnection(
        userId,
        token,
        connectionInfo['serverUrl'] as String,
        connectionInfo['simulationMode'] as bool,
      );

      if (!success) {
        _logger.e('初始化实时通信连接失败');
      } else {
        _logger.i('实时通信连接成功');

        // 初始化聊天相关订阅
        if (_chatCubit != null) {
          await _chatCubit.initializeSubscriptions();

          // 同步联系人列表
          await _chatCubit.syncContacts();
        }
      }
    } catch (e) {
      _logger.e('初始化实时通信错误', error: e);
    }
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

  Future<void> sendVerificationCode() async {
    _logger.i('发送验证码');

    if (state.phoneNumber?.length != 11) {
      _logger.e('手机号错误: ${state.phoneNumber}');
      emit(state.toErrorState('请输入正确的手机号码'));
      return;
    }

    try {
      _logger.i('发送验证码中...');
      emit(state.toLoadingState());

      // 使用认证服务发送验证码
      final success = await _authService.sendVerificationCode(
        state.phoneNumber!,
        'login', // 用途：login/register/reset
      );

      if (!success) {
        throw '发送验证码失败，请稍后再试';
      }

      emit(state.updateCodeSentStatus(
        isCodeSent: true,
        countdown: countdownDuration,
      ));
      _logger.i('验证码已发送，倒计时: $countdownDuration');

      _startCountdown();
    } catch (e) {
      _logger.e('发送验证码错误: $e');
      emit(state.toErrorState(e.toString()));
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
        _logger.e('手机号错误: ${state.phoneNumber}');
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
        success = await _authService.loginWithCode(
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
        success = await _authService.loginWithPassword(
          state.phoneNumber!,
          state.password!,
        );
      }

      if (!success) {
        throw '登录失败，请检查网络连接';
      }

      // 注意：登录结果将通过AuthService的onAuthResponse回调处理
    } catch (e) {
      _logger.e('登录错误: $e');
      emit(state.toErrorState(e.toString()));
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
        _logger.e('手机号错误: $phoneNumber');
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

      final success = await _authService.register(phoneNumber, verificationCode, password, nickname);

      if (!success) {
        throw '注册失败，请检查网络连接';
      }

      // 注意：注册结果将通过AuthService的onAuthResponse回调处理
    } catch (e) {
      _logger.e('注册错误: $e');
      emit(state.toErrorState(e.toString()));
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
        _logger.e('手机号错误: $phoneNumber');
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

      final success = await _authService.resetPassword(phoneNumber, verificationCode, newPassword);

      if (!success) {
        throw '重置密码失败，请检查网络连接';
      }

      // 注意：重置密码结果将通过AuthService的onAuthResponse回调处理
    } catch (e) {
      _logger.e('重置密码错误: $e');
      emit(state.toErrorState(e.toString()));
      // 重新抛出异常，以便上层代码捕获
      rethrow;
    }
  }

  // 使用测试账户登录（仅用于测试）
  Future<void> loginWithTestAccount({
    required String userId,
    required String token,
    required String username,
  }) async {
    _logger.i('使用测试账户登录', extra: {'userId': userId, 'username': username});

    try {
      emit(state.toLoadingState());

      // 初始化数据库（如果尚未初始化）
      if (!DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.init(userId: userId);
      }

      // 保存测试用户信息
      final myUser = await MyUserService.saveCurrentUser(
        userId: userId,
        token: token,
        name: username,
        avatar: null,
        phone: '13800138000', // 测试手机号
        tokenExpireTime: DateTime.now().add(const Duration(days: 7)), // 测试令牌7天有效期
      );

      if (myUser == null) {
        throw '创建测试用户失败';
      }

      // 更新认证状态
      emit(state.toAuthenticatedState(userId: userId, token: token));

      // 初始化实时通信
      await _initRealTimeCommunication(userId, token);

      _logger.i('测试账户登录成功');
    } catch (e) {
      _logger.e('测试账户登录失败', error: e);
      emit(state.toErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
