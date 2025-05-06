import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/user_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/core/services/socket_service.dart';

part 'auth_state.dart';

final _logger = LogService('auth_cubit.dart');

class AuthCubit extends Cubit<AuthState> {
  Timer? _countdownTimer;
  static const int countdownDuration = 60;

  // 添加ChatRepository依赖，用于初始化Socket连接
  final ChatRepository? _chatRepository;

  // 添加ChatCubit依赖，用于在登录成功后初始化
  final ChatCubit? _chatCubit;

  AuthCubit({ChatRepository? chatRepository, ChatCubit? chatCubit})
      : _chatRepository = chatRepository,
        _chatCubit = chatCubit,
        super(const AuthFormState());

  void updatePhoneNumber(String phoneNumber) {
    final currentState = state;
    _logger.i('更新手机号: $phoneNumber');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(phoneNumber: phoneNumber));
    }
  }

  void updateVerificationCode(String code) {
    final currentState = state;
    _logger.i('更新验证码: $code');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(verificationCode: code));
    }
  }

  void updatePassword(String password) {
    final currentState = state;
    _logger.i('更新密码: $password');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(password: password));
    }
  }

  void updateNickname(String nickname) {
    final currentState = state;
    _logger.i('更新昵称: $nickname');
    if (currentState is AuthFormState) {
      emit(currentState.copyWith(nickname: nickname));
    }
  }

  Future<void> sendVerificationCode() async {
    final currentState = state;
    _logger.i('发送验证码');
    if (currentState is AuthFormState) {
      if (currentState.phoneNumber?.length != 11) {
        _logger.e('手机号错误: ${currentState.phoneNumber}');
        emit(const AuthError('请输入正确的手机号码'));
        emit(currentState);
        return;
      }

      try {
        _logger.i('发送验证码中...');
        emit(AuthLoading());
        // TODO: 实现发送验证码的API调用
        await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求

        emit(currentState.copyWith(
          isCodeSent: true,
          countdown: countdownDuration,
        ));
        _logger.i('验证码已发送，倒计时: $countdownDuration');

        _startCountdown();
      } catch (e) {
        _logger.e('发送验证码错误: $e');
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
    _logger.i('登录请求 - 快捷登录: $isQuickLogin');
    if (currentState is AuthFormState) {
      try {
        // 验证手机号
        if (currentState.phoneNumber?.isEmpty ?? true) {
          _logger.i('手机号为空');
          throw '请输入手机号码';
        }
        if (currentState.phoneNumber!.length != 11) {
          _logger.e('手机号错误: ${currentState.phoneNumber}');
          throw '请输入正确的手机号码';
        }

        emit(AuthLoading());
        _logger.i('登录中...');

        if (isQuickLogin) {
          // 验证码登录
          if (currentState.verificationCode?.isEmpty ?? true) {
            _logger.i('验证码为空');
            throw '请输入验证码';
          }
          _logger.i('使用验证码登录: ${currentState.verificationCode}');
          // TODO: 实现验证码登录API调用
        } else {
          // 密码登录
          if (currentState.password?.isEmpty ?? true) {
            _logger.i('密码为空');
            throw '请输入密码';
          }
          _logger.i('使用密码登录: ${currentState.password}');
          // TODO: 实现密码登录API调用
        }

        await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

        // 模拟从服务器获取的用户ID
        final String serverUserId = _generateMockUserId(currentState.phoneNumber!);
        // 模拟从服务器获取的token
        final String serverToken = _generateMockToken(serverUserId);

        // 初始化或切换到该用户的数据库
        await _initUserDatabase(serverUserId);

        // 保存或更新用户信息
        await _saveUserInfoToDatabase(currentState.phoneNumber!, serverUserId, nickname: currentState.nickname);

        // 初始化Socket.IO实时通信
        await _initRealTimeConnection(serverUserId, serverToken);

        // 初始化ChatCubit(在数据库和Socket初始化后)
        await _initChatCubit();

        _logger.i('登录成功');
        emit(AuthSuccess(userId: serverUserId, token: serverToken));
      } catch (e) {
        _logger.e('登录错误: $e');
        emit(AuthError(e.toString()));
        emit(currentState);
      }
    }
  }

  /// 初始化Socket.IO实时通信连接
  Future<void> _initRealTimeConnection(String userId, String token) async {
    try {
      if (_chatRepository != null) {
        _logger.i('初始化Socket.IO实时通信');

        // 获取SocketService单例
        final socketService = SocketService();

        // 使用Protobuf二进制格式初始化连接
        // 注意：在Web平台使用base64编码更合适
        final isWeb = identical(0, 0.0);
        final encoding = isWeb ? DataEncoding.base64 : DataEncoding.protobuf;

        _logger.i('使用 ${encoding.toString()} 编码格式初始化Socket连接');

        final success = await _chatRepository!.initRealTimeConnection(
          userId,
          token,
          encoding: encoding,
        );

        if (success) {
          _logger.i('Socket.IO实时通信初始化成功');
        } else {
          _logger.w('Socket.IO实时通信初始化失败，将在后台继续尝试');
          // 可以在这里添加重试逻辑，或者让用户手动重试
        }
      } else {
        _logger.w('未提供ChatRepository，无法初始化Socket.IO实时通信');
      }
    } catch (e) {
      _logger.e('初始化Socket.IO实时通信出错', error: e);
      // 不抛出异常，确保登录流程正常进行
    }
  }

  /// 初始化用户数据库
  Future<void> _initUserDatabase(String userId) async {
    try {
      _logger.i('初始化用户数据库: $userId');

      // 检查用户数据库是否存在
      final dbExists = await DatabaseInitializer.userDatabaseExists(userId);

      // 检查数据库是否已初始化
      final isInitialized = DatabaseInitializer.isInitialized;

      if (!isInitialized) {
        _logger.i('数据库尚未初始化，首次创建数据库');
      }

      if (dbExists) {
        _logger.i('用户数据库已存在，切换到该数据库');
        await DatabaseInitializer.switchUserDatabase(userId);
      } else {
        _logger.i('用户数据库不存在，创建新数据库');
        await DatabaseInitializer.init(userId: userId);
      }
    } catch (e) {
      _logger.e('初始化用户数据库失败', error: e);
      // 如果用户数据库初始化失败，回退到默认数据库
      if (!DatabaseInitializer.isInitialized) {
        _logger.i('尝试回退到默认数据库');
        await DatabaseInitializer.init();
      }
    }
  }

  /// 生成模拟用户ID (实际环境应该由服务器返回)
  String _generateMockUserId(String phoneNumber) {
    // 移除模拟ID生成中的随机性，确保同一个手机号总是得到相同的ID
    return 'u${phoneNumber.substring(phoneNumber.length - 6)}';
  }

  /// 生成模拟token (实际环境应该由服务器返回)
  String _generateMockToken(String userId) {
    return 'token_${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 将用户信息保存到数据库
  Future<void> _saveUserInfoToDatabase(String phone, String userId, {String? nickname}) async {
    try {
      _logger.i('保存用户信息到数据库');

      // 检查是否已有当前用户
      final existingUser = await UserService.getCurrentUser();

      if (existingUser != null) {
        // 更新已有用户信息
        _logger.i('更新已有用户信息');
        await UserService.updateUser(
          existingUser.userId,
          phone: phone,
          name: nickname ?? existingUser.name,
          status: 'online',
        );
      } else {
        // 创建新用户
        _logger.i('创建新用户');
        // 先创建一个基本用户
        final newUser = await UserService.createCurrentUser();

        if (newUser != null) {
          // 然后更新用户信息
          await UserService.updateUser(
            newUser.userId,
            phone: phone,
            name: nickname ?? '用户${phone.substring(phone.length - 4)}', // 如果没有昵称，使用手机号后4位作为默认昵称
            status: 'online',
          );
        }
      }

      _logger.i('用户信息保存成功');
    } catch (e) {
      _logger.e('保存用户信息到数据库失败', error: e);
      // 不抛出异常，确保登录流程正常进行
    }
  }

  /// 初始化ChatCubit
  Future<void> _initChatCubit() async {
    try {
      if (_chatCubit != null) {
        _logger.i('初始化ChatCubit');
        await _chatCubit!.initializeSubscriptions();
        _logger.i('ChatCubit初始化成功');
      } else {
        _logger.w('未提供ChatCubit，无法初始化');
      }
    } catch (e) {
      _logger.e('初始化ChatCubit出错', error: e);
      // 不抛出异常，确保登录流程正常进行
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

      emit(AuthLoading());
      _logger.i('注册中...');

      // TODO: 实现注册API调用
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

      // 检查手机号是否已注册（模拟）
      if (phoneNumber == '13800000000') {
        throw '该手机号已注册';
      }

      // 模拟从服务器获取的用户ID
      final String serverUserId = _generateMockUserId(phoneNumber);
      // 模拟从服务器获取的token
      final String serverToken = _generateMockToken(serverUserId);

      // 初始化用户数据库
      await _initUserDatabase(serverUserId);

      // 保存用户信息
      await _saveUserInfoToDatabase(phoneNumber, serverUserId, nickname: nickname);

      // 初始化Socket.IO实时通信
      await _initRealTimeConnection(serverUserId, serverToken);

      // 初始化ChatCubit
      await _initChatCubit();

      _logger.i('注册成功');
      emit(AuthSuccess(userId: serverUserId, token: serverToken));
    } catch (e) {
      _logger.e('注册错误: $e');
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

      emit(AuthLoading());
      _logger.i('重置密码中...');

      // TODO: 实现重置密码API调用
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

      // 模拟一些可能的错误情况（测试用）
      if (phoneNumber == '13800000000') {
        throw '该手机号未注册';
      }
      if (verificationCode == '000000') {
        throw '验证码错误';
      }

      // 模拟从服务器获取的用户ID
      final String serverUserId = _generateMockUserId(phoneNumber);
      // 模拟从服务器获取的token
      final String serverToken = _generateMockToken(serverUserId);

      // 初始化用户数据库
      await _initUserDatabase(serverUserId);

      // 更新用户信息
      final existingUser = await UserService.getCurrentUser();
      if (existingUser != null) {
        await UserService.updateUser(
          existingUser.userId,
          phone: phoneNumber,
        );
      }

      // 初始化Socket.IO实时通信
      await _initRealTimeConnection(serverUserId, serverToken);

      // 初始化ChatCubit
      await _initChatCubit();

      _logger.i('重置密码成功');
      emit(AuthSuccess(userId: serverUserId, token: serverToken));
    } catch (e) {
      _logger.e('重置密码错误: $e');
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
