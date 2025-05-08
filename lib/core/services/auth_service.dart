import 'dart:async';
import 'package:cc/core/services/log_service.dart';
import '../constants/app_config.dart';

/// 认证响应模型
class AuthResponse {
  final bool success;
  final String message;
  final String? userId;
  final String? token;
  final String? nickname;

  AuthResponse({
    required this.success,
    required this.message,
    this.userId,
    this.token,
    this.nickname,
  });

  bool hasUserId() => userId != null && userId!.isNotEmpty;
  bool hasToken() => token != null && token!.isNotEmpty;
}

/// 认证服务
/// 负责处理用户认证和注册
class AuthService {
  // 单例模式
  static final AuthService _instance = AuthService._internal();
  static AuthService getInstance() => _instance;

  AuthService._internal();

  final LogService _logger = LogService('auth_service.dart');

  // 认证响应流控制器
  final StreamController<AuthResponse> _authResponseController = StreamController<AuthResponse>.broadcast();

  /// 获取认证响应流
  Stream<AuthResponse> get onAuthResponse => _authResponseController.stream;

  // 从AppConfig获取模拟模式
  bool get _isSimulationMode => AppConfig().isSimulationMode;

  // 连接信息
  Map<String, dynamic> _connectionInfo = {};

  /// 初始化认证服务
  Future<bool> init({
    required String serverUrl,
    bool isSimulationMode = false,
  }) async {
    try {
      _logger.i('初始化认证服务', extra: {'serverUrl': serverUrl, 'isSimulationMode': _isSimulationMode});

      // 更新连接信息
      _connectionInfo = {
        'serverUrl': serverUrl,
        'isSimulationMode': _isSimulationMode,
      };

      return true;
    } catch (e) {
      _logger.e('初始化认证服务失败', error: e);
      return false;
    }
  }

  /// 发送验证码
  /// [phoneNumber] - 手机号码
  /// [purpose] - 用途（登录/注册/重置密码）
  Future<bool> sendVerificationCode(String phoneNumber, String purpose) async {
    _logger.i('发送验证码', extra: {'phoneNumber': phoneNumber, 'purpose': purpose});

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟成功响应
    return true;
  }

  /// 使用验证码登录
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  Future<bool> loginWithCode(String phoneNumber, String verificationCode) async {
    _logger.i('使用验证码登录', extra: {'phoneNumber': phoneNumber});

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟成功登录
    _authResponseController.add(AuthResponse(
      success: true,
      message: '登录成功',
      userId: '1',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      nickname: '用户',
    ));

    return true;
  }

  /// 使用密码登录
  /// [phoneNumber] - 手机号码
  /// [password] - 密码
  Future<bool> loginWithPassword(String phoneNumber, String password) async {
    _logger.i('使用密码登录', extra: {'phoneNumber': phoneNumber});

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟成功登录
    _authResponseController.add(AuthResponse(
      success: true,
      message: '登录成功',
      userId: '1',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      nickname: '用户',
    ));

    return true;
  }

  /// 注册账号
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  /// [password] - 密码
  /// [nickname] - 昵称
  Future<bool> register(String phoneNumber, String verificationCode, String password, String nickname) async {
    _logger.i('注册账号', extra: {'phoneNumber': phoneNumber, 'nickname': nickname});

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 1000));

    // 模拟成功注册
    _authResponseController.add(AuthResponse(
      success: true,
      message: '注册成功',
      userId: '${DateTime.now().millisecondsSinceEpoch % 1000}',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      nickname: nickname,
    ));

    return true;
  }

  /// 重置密码
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  /// [newPassword] - 新密码
  Future<bool> resetPassword(String phoneNumber, String verificationCode, String newPassword) async {
    _logger.i('重置密码', extra: {'phoneNumber': phoneNumber});

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟成功重置
    _authResponseController.add(AuthResponse(
      success: true,
      message: '密码重置成功',
    ));

    return true;
  }

  /// 获取连接信息
  Map<String, dynamic> getConnectionInfo() {
    return _connectionInfo;
  }

  /// 释放资源
  void dispose() {
    _authResponseController.close();
  }
}
