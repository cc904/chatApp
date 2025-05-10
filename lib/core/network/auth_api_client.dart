import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';

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

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userId: json['data']?['userId'],
      token: json['data']?['token'],
      nickname: json['data']?['nickname'],
    );
  }

  bool hasUserId() => userId != null && userId!.isNotEmpty;
  bool hasToken() => token != null && token!.isNotEmpty;
}

/// 认证异常
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// 认证API客户端
/// 负责处理用户认证和注册的API请求
class AuthApiClient {
  // 单例模式
  static final AuthApiClient _instance = AuthApiClient._internal();
  static AuthApiClient getInstance() => _instance;

  late final Dio _dio;
  final LogService _logger = LogService('auth_api_client.dart');

  // 从AppConfig获取模拟模式
  bool get _isSimulationMode => AppConfig().isSimulationMode;

  // 认证响应流控制器
  final StreamController<AuthResponse> _authResponseController = StreamController<AuthResponse>.broadcast();

  /// 获取认证响应流
  Stream<AuthResponse> get onAuthResponse => _authResponseController.stream;

  AuthApiClient._internal();

  /// 初始化认证API客户端
  Future<bool> init({
    required String serverUrl,
    bool isSimulationMode = false,
  }) async {
    try {
      _logger.i('初始化认证API客户端', extra: {'serverUrl': serverUrl, 'isSimulationMode': _isSimulationMode});

      // 创建和配置Dio客户端
      _dio = Dio(BaseOptions(
        baseUrl: serverUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        // 添加状态码验证
        validateStatus: (status) {
          return status != null && status < 500; // 接受所有非500错误的状态码
        },
      ));

      // 添加拦截器进行日志记录
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (object) {
          if (object is String && object.contains('-->')) {
            // 只打印请求URI和参数
            final lines = object.split('\n');
            for (final line in lines) {
              if (line.contains('-->') || line.contains('data:')) {
                _logger.d(line.trim());
              }
            }
          }
        },
      ));

      // 添加错误处理
      _dio.interceptors.add(InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          _logger.e('请求错误', error: e, extra: {
            'url': e.requestOptions.uri.toString(),
            'method': e.requestOptions.method,
            'data': e.requestOptions.data,
            'headers': e.requestOptions.headers,
            'response': e.response?.data,
            'statusCode': e.response?.statusCode,
          });
          return handler.next(e);
        },
      ));

      return true;
    } catch (e) {
      _logger.e('初始化认证API客户端失败', error: e);
      return false;
    }
  }

  /// 发送验证码
  /// [phoneNumber] - 手机号码
  /// [purpose] - 用途（login/register/reset）
  Future<bool> sendVerificationCode(String phoneNumber, String purpose) async {
    try {
      _logger.i('发送验证码', extra: {'phoneNumber': phoneNumber, 'purpose': purpose});

      if (_isSimulationMode) {
        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 500));
        // 模拟成功响应
        return true;
      }

      final response = await _dio.post('/api/auth/send-code', data: {
        'phoneNumber': phoneNumber,
        'purpose': purpose,
      });

      final data = response.data;
      // 直接使用服务器返回的响应
      _authResponseController.add(AuthResponse(
        success: data['success'] ?? false,
        message: data['message'] ?? '发送验证码失败',
      ));

      return data['success'] ?? false;
    } catch (e) {
      _logger.e('发送验证码失败', error: e);
      _authResponseController.add(AuthResponse(
        success: false,
        message: e.toString(),
      ));
      return false;
    }
  }

  /// 使用验证码登录
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  Future<bool> loginWithCode(String phoneNumber, String verificationCode) async {
    try {
      _logger.i('使用验证码登录', extra: {'phoneNumber': phoneNumber});

      if (_isSimulationMode) {
        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 800));

        // 判断是否是模拟账号
        bool isMockAccount = phoneNumber == '13800138000' && verificationCode == '123456';

        if (isMockAccount) {
          // 模拟标准的成功登录响应
          _authResponseController.add(AuthResponse(
            success: true,
            message: '登录成功',
            userId: 'user_${DateTime.now().millisecondsSinceEpoch % 1000}',
            token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
            nickname: '模拟用户',
          ));
          return true;
        } else {
          // 模拟失败响应
          _authResponseController.add(AuthResponse(
            success: false,
            message: '验证码错误',
          ));
          return false;
        }
      }

      final response = await _dio.post('/api/auth/login', data: {
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'loginType': 'code',
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse.success;
    } catch (e) {
      _logger.e('验证码登录失败', error: e);

      // 向流中添加错误响应
      _authResponseController.add(AuthResponse(
        success: false,
        message: '登录失败: ${e.toString()}',
      ));

      return false;
    }
  }

  /// 使用密码登录
  /// [phoneNumber] - 手机号码
  /// [password] - 密码
  Future<bool> loginWithPassword(String phoneNumber, String password) async {
    try {
      _logger.i('使用密码登录', extra: {'phoneNumber': phoneNumber});

      if (_isSimulationMode) {
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

      final response = await _dio.post('/api/auth/login', data: {
        'phoneNumber': phoneNumber,
        'password': password,
        'loginType': 'password',
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse.success;
    } catch (e) {
      _logger.e('密码登录失败', error: e);

      // 向流中添加错误响应
      _authResponseController.add(AuthResponse(
        success: false,
        message: '登录失败: ${e.toString()}',
      ));

      return false;
    }
  }

  /// 注册账号
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  /// [password] - 密码
  /// [nickname] - 昵称
  Future<bool> register(String phoneNumber, String verificationCode, String password, String nickname) async {
    try {
      _logger.i('注册账号', extra: {'phoneNumber': phoneNumber, 'nickname': nickname});

      if (_isSimulationMode) {
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

      final response = await _dio.post('/api/auth/register', data: {
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'password': password,
        'nickname': nickname,
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse.success;
    } catch (e) {
      _logger.e('注册失败', error: e);

      // 向流中添加错误响应
      _authResponseController.add(AuthResponse(
        success: false,
        message: '注册失败: ${e.toString()}',
      ));

      return false;
    }
  }

  /// 重置密码
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  /// [newPassword] - 新密码
  Future<bool> resetPassword(String phoneNumber, String verificationCode, String newPassword) async {
    try {
      _logger.i('重置密码', extra: {'phoneNumber': phoneNumber});

      if (_isSimulationMode) {
        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 800));
        // 模拟成功重置
        _authResponseController.add(AuthResponse(
          success: true,
          message: '密码重置成功',
        ));
        return true;
      }

      final response = await _dio.post('/api/auth/reset-password', data: {
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse.success;
    } catch (e) {
      _logger.e('重置密码失败', error: e);

      // 向流中添加错误响应
      _authResponseController.add(AuthResponse(
        success: false,
        message: '重置密码失败: ${e.toString()}',
      ));

      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _authResponseController.close();
  }
}
