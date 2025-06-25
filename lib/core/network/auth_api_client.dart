import 'dart:async';
import 'package:dio/dio.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:fixnum/fixnum.dart';

/// 认证响应模型
class AuthResponse {
  final bool success;
  final String message;
  final CurrentUserProto? currentUser;

  AuthResponse({
    required this.success,
    required this.message,
    this.currentUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['currentUser'];
    CurrentUserProto? currentUser;

    if (userData != null) {
      currentUser = CurrentUserProto(
        userId: userData['userId'] ?? '',
        token: userData['token'] ?? '',
        name: userData['nickname'] ?? userData['name'] ?? '',
        phone: userData['phone'] ?? '',
        email: userData['email'] ?? '',
        avatar: userData['avatar'] ?? '',
        status: userData['status'] ?? '',
        lastLoginTime: userData['lastLoginTime'] != null
            ? Int64(userData['lastLoginTime'])
            : null,
        tokenExpireTime: userData['tokenExpireTime'] != null
            ? Int64(userData['tokenExpireTime'])
            : json['tokenExpiresAt'] != null
                ? Int64(json['tokenExpiresAt'])
                : null,
      );
    }

    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      currentUser: currentUser,
    );
  }

  bool hasUserId() => currentUser != null && currentUser!.hasUserId();
  bool hasToken() => currentUser != null && currentUser!.hasToken();
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
  final LogService _logger = LogService.instance;

  // 认证响应流控制器
  final StreamController<AuthResponse> _authResponseController =
      StreamController<AuthResponse>.broadcast();

  /// 获取认证响应流
  Stream<AuthResponse> get onAuthResponse => _authResponseController.stream;

  // 判断是否已初始化的标志
  bool _isInitialized = false;

  AuthApiClient._internal();

  /// 初始化认证API客户端
  Future<bool> init({
    required String serverUrl,
  }) async {
    try {
      // 如果已经初始化，直接返回true
      if (_isInitialized) {
        _logger.i('认证API客户端已经初始化过，跳过重复初始化');
        return true;
      }

      _logger.i('初始化认证API客户端', extra: {'serverUrl': serverUrl});

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

      // 添加漂亮的日志拦截器
      // _dio.interceptors.add(PrettyDioLogger(
      //   requestHeader: false,
      //   requestBody: false,
      //   responseHeader: false,
      //   responseBody: true,
      //   error: true,
      //   compact: false,
      //   maxWidth: 120,
      // ));

      _isInitialized = true;
      return true;
    } catch (error) {
      _logger.e('初始化认证API客户端失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 根据异常类型生成友好的错误消息
  String _getFriendlyErrorMessage(Object error, String defaultMessage) {
    if (error is DioException) {
      if (error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return '连接超时，请检查网络后重试';
      } else if (error.type == DioExceptionType.connectionError) {
        return '网络连接错误，请检查网络设置';
      } else if (error.response != null) {
        if (error.response?.data is Map &&
            error.response?.data['message'] != null) {
          // 如果服务器返回了错误消息，优先使用服务器的错误消息
          return error.response?.data['message'];
        }
        // 否则返回状态码
        return '服务器错误 (${error.response?.statusCode})';
      }
    }
    return defaultMessage;
  }

  /// 发送验证码
  /// [phoneNumber] - 手机号码
  /// [purpose] - 验证码用途(login/register/reset)
  Future<bool> sendVerificationCode(String phoneNumber, String purpose) async {
    try {
      _logger
          .i('发送验证码', extra: {'phoneNumber': phoneNumber, 'purpose': purpose});

      final response = await _dio.post('/api/v1/auth/sendCode', data: {
        'phoneNumber': phoneNumber,
        'purpose': purpose,
      });

      final data = response.data;
      // 创建响应对象
      final authResponse = AuthResponse(
        success: data['success'] ?? false,
        message: data['message'] ?? '发送验证码失败',
      );

      // 发送到流
      _authResponseController.add(authResponse);

      return authResponse.success;
    } catch (error) {
      _logger.e('发送验证码失败', error: error, stackTrace: StackTrace.current);

      // 使用通用错误处理方法
      final errorMsg = _getFriendlyErrorMessage(error, '发送验证码失败');

      // 创建错误响应
      final errorResponse = AuthResponse(
        success: false,
        message: errorMsg,
      );

      // 向流中添加错误响应
      _authResponseController.add(errorResponse);

      return false;
    }
  }

  /// 使用验证码登录
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  Future<AuthResponse> loginWithCode(
      String phoneNumber, String verificationCode) async {
    try {
      _logger.i('使用验证码登录', extra: {'phoneNumber': phoneNumber});

      final response = await _dio.post('/api/v1/auth/login', data: {
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'loginType': 'code',
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse;
    } catch (error) {
      _logger.e('验证码登录失败', error: error, stackTrace: StackTrace.current);

      // 使用通用错误处理方法
      final errorMsg = _getFriendlyErrorMessage(error, '登录失败');

      // 创建错误响应
      final errorResponse = AuthResponse(
        success: false,
        message: errorMsg,
      );

      // 向流中添加错误响应
      _authResponseController.add(errorResponse);

      return errorResponse;
    }
  }

  /// 使用密码登录
  /// [phoneNumber] - 手机号码
  /// [password] - 密码
  Future<AuthResponse> loginWithPassword(
      String phoneNumber, String password) async {
    try {
      _logger.i('使用密码登录', extra: {'phoneNumber': phoneNumber});

      final response = await _dio.post('/api/v1/auth/login', data: {
        'phoneNumber': phoneNumber,
        'password': password,
        'loginType': 'password',
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse;
    } catch (error) {
      _logger.e('密码登录失败', error: error, stackTrace: StackTrace.current);

      // 使用通用错误处理方法
      final errorMsg = _getFriendlyErrorMessage(error, '登录失败');

      // 创建错误响应
      final errorResponse = AuthResponse(
        success: false,
        message: errorMsg,
      );

      // 向流中添加错误响应
      _authResponseController.add(errorResponse);

      return errorResponse;
    }
  }

  /// 注册账号
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  /// [password] - 密码
  /// [nickname] - 昵称
  Future<AuthResponse> register(String phoneNumber, String verificationCode,
      String password, String nickname) async {
    try {
      _logger
          .i('注册账号', extra: {'phoneNumber': phoneNumber, 'nickname': nickname});

      final response = await _dio.post('/api/v1/auth/register', data: {
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'password': password,
        'nickname': nickname,
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse;
    } catch (error) {
      _logger.e('注册失败', error: error, stackTrace: StackTrace.current);

      // 使用通用错误处理方法
      final errorMsg = _getFriendlyErrorMessage(error, '注册失败');

      // 创建错误响应
      final errorResponse = AuthResponse(
        success: false,
        message: errorMsg,
      );

      // 向流中添加错误响应
      _authResponseController.add(errorResponse);

      return errorResponse;
    }
  }

  /// 重置密码
  /// [phoneNumber] - 手机号码
  /// [verificationCode] - 验证码
  /// [newPassword] - 新密码
  Future<AuthResponse> resetPassword(
      String phoneNumber, String verificationCode, String newPassword) async {
    try {
      _logger.i('重置密码', extra: {'phoneNumber': phoneNumber});

      final response = await _dio.post('/api/v1/auth/resetPassword', data: {
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      });

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse;
    } catch (error) {
      _logger.e('重置密码失败', error: error, stackTrace: StackTrace.current);

      // 使用通用错误处理方法
      final errorMsg = _getFriendlyErrorMessage(error, '重置密码失败');

      // 创建错误响应
      final errorResponse = AuthResponse(
        success: false,
        message: errorMsg,
      );

      // 向流中添加错误响应
      _authResponseController.add(errorResponse);

      return errorResponse;
    }
  }

  /// 验证令牌有效性
  /// [userId] - 用户ID
  /// [token] - 认证令牌
  Future<AuthResponse> verifyToken(String token) async {
    try {
      _logger.i('验证令牌有效性', extra: {'token': token.substring(0, 20)});

      final response =
          await _dio.post('/api/v1/auth/verifyToken', data: {'token': token});

      final authResponse = AuthResponse.fromJson(response.data);
      _authResponseController.add(authResponse);

      return authResponse;
    } catch (error) {
      _logger.d('令牌验证失败', extra: {'error': error.toString()});

      // 使用通用错误处理方法
      final errorMsg = _getFriendlyErrorMessage(error, '令牌验证失败');

      // 创建错误响应
      final errorResponse = AuthResponse(
        success: false,
        message: errorMsg,
      );

      // 向流中添加错误响应
      _authResponseController.add(errorResponse);

      return errorResponse;
    }
  }

  /// 释放资源
  void dispose() {
    _authResponseController.close();
  }
}
