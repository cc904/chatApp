import 'dart:async';
import 'package:cc/core/services/log_service.dart';
import 'types.dart';
import '../proto/generated/auth.pb.dart';

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

  /// 初始化认证服务
  Future<bool> init({
    required String serverUrl,
    DataEncoding encoding = DataEncoding.json,
    bool simulationMode = false,
  }) async {
    _logger.i('初始化认证服务', extra: {'simulationMode': simulationMode});
    return true;
  }

  /// 使用验证码登录
  Future<bool> loginWithCode(String phone, String code) async {
    _logger.i('使用验证码登录', extra: {'phone': phone});

    // 模拟成功登录
    final response = AuthResponse()
      ..success = true
      ..userId = 'user_${DateTime.now().millisecondsSinceEpoch}'
      ..token = 'token_${DateTime.now().millisecondsSinceEpoch}'
      ..message = '登录成功';

    _authResponseController.add(response);
    return true;
  }

  /// 使用密码登录
  Future<bool> loginWithPassword(String phone, String password) async {
    _logger.i('使用密码登录', extra: {'phone': phone});

    // 模拟成功登录
    final response = AuthResponse()
      ..success = true
      ..userId = 'user_${DateTime.now().millisecondsSinceEpoch}'
      ..token = 'token_${DateTime.now().millisecondsSinceEpoch}'
      ..message = '登录成功';

    _authResponseController.add(response);
    return true;
  }

  /// 注册新用户
  Future<bool> register(String phone, String code, String password, String nickname) async {
    _logger.i('注册新用户', extra: {'phone': phone, 'nickname': nickname});

    // 模拟成功注册
    final response = AuthResponse()
      ..success = true
      ..userId = 'user_${DateTime.now().millisecondsSinceEpoch}'
      ..token = 'token_${DateTime.now().millisecondsSinceEpoch}'
      ..message = '注册成功';

    _authResponseController.add(response);
    return true;
  }

  /// 重置密码
  Future<bool> resetPassword(String phone, String code, String newPassword) async {
    _logger.i('重置密码', extra: {'phone': phone});

    // 模拟成功重置
    final response = AuthResponse()
      ..success = true
      ..message = '密码重置成功';

    _authResponseController.add(response);
    return true;
  }

  /// 发送验证码
  Future<bool> sendVerificationCode(String phone, String purpose) async {
    _logger.i('发送验证码', extra: {'phone': phone, 'purpose': purpose});
    return true;
  }

  /// 获取连接信息
  Map<String, dynamic> getConnectionInfo() {
    return {
      'serverUrl': 'http://localhost:3000',
      'dataEncoding': DataEncoding.json,
      'simulationMode': true,
    };
  }
}
