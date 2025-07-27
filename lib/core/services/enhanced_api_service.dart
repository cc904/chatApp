import 'package:dio/dio.dart';
import 'package:cc/core/services/device_manager.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/constants/app_config.dart';

/// 增强的API服务
///
/// 自动添加设备相关的请求头，支持多设备登录功能
/// 在所有API请求中自动包含设备标识符和用户代理信息
class EnhancedApiService {
  static final EnhancedApiService _instance = EnhancedApiService._internal();
  static EnhancedApiService get instance => _instance;

  final _logger = LogService.instance;
  final _tokenManager = EnhancedTokenManager.instance;
  late final Dio _dio;

  /// 私有构造函数
  EnhancedApiService._internal() {
    // 获取默认服务器URL
    final appConfig = AppConfig();

    _dio = Dio(BaseOptions(
      baseUrl: appConfig.serverUrl, // 添加默认baseUrl
      connectTimeout: const Duration(seconds: 60), // 增加连接超时
      receiveTimeout: const Duration(seconds: 60), // 增加接收超时  
      sendTimeout: const Duration(seconds: 60),    // 增加发送超时
    ));
    _setupInterceptors();
  }

  /// 设置请求拦截器
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 判断是否需要附加Token
          final attachToken = options.extra['attachToken'] != false;

          // 基础请求头（不包含Authorization）
          final baseHeaders = await getStandardHeaders(attachToken: false);
          options.headers.addAll(baseHeaders);

          // 可选地附加Authorization
          if (attachToken) {
            final token = await _tokenManager.getApiToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          _logger.d('🌐 API请求', extra: {
            'method': options.method,
            'url': options.uri.toString(),
            'deviceId': baseHeaders['x-device-id']?.toString().substring(0, 16),
          });

          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('✅ API响应', extra: {
            'statusCode': response.statusCode,
            'url': response.requestOptions.uri.toString(),
          });
          handler.next(response);
        },
        onError: (error, handler) {
          // 对于认证相关的401错误，使用信息级别日志
          if (error.response?.statusCode == 401 && 
              (error.requestOptions.path.contains('/auth/') ||
               error.requestOptions.path.contains('/verifyToken'))) {
            _logger.i('🔐 认证失败（正常情况）', extra: {
              'statusCode': 401,
              'url': error.requestOptions.uri.toString(),
              'path': error.requestOptions.path,
            });
          } else if (error.type == DioExceptionType.connectionTimeout ||
                     error.type == DioExceptionType.receiveTimeout ||
                     error.type == DioExceptionType.sendTimeout) {
            // 网络超时错误
            _logger.w('🌐 网络超时', extra: {
              'type': error.type.toString(),
              'url': error.requestOptions.uri.toString(),
              'message': '服务器响应时间过长，请检查网络连接',
              'timeout': '${error.requestOptions.connectTimeout?.inSeconds}s',
            });
          } else if (error.type == DioExceptionType.connectionError) {
            // 连接错误
            _logger.w('🌐 网络连接失败', extra: {
              'url': error.requestOptions.uri.toString(),
              'message': '无法连接到服务器，请检查网络连接或服务器状态',
              'error': error.message,
            });
          } else {
            // 其他错误使用错误级别
            _logger.e('❌ API错误', extra: {
              'statusCode': error.response?.statusCode,
              'url': error.requestOptions.uri.toString(),
              'message': error.message,
              'type': error.type.toString(),
            });
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 获取标准请求头
  ///
  /// 返回包含设备ID、User-Agent、Content-Type等标准请求头
  Future<Map<String, String>> getStandardHeaders(
      {bool attachToken = true}) async {
    try {
      final deviceId = await DeviceManager.getDeviceId();
      final userAgent = await DeviceManager.getUserAgent();

      final headers = {
        'Content-Type': 'application/json',
        'x-device-id': deviceId,
        'User-Agent': userAgent,
      };

      // 如果用户已登录，添加Authorization头
      if (attachToken) {
        final token = await _tokenManager.getApiToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      return headers;
    } catch (error) {
      _logger.w('生成标准请求头失败', extra: {'error': error.toString()});
      return {
        'Content-Type': 'application/json',
        'x-device-id': 'unknown',
        'User-Agent': 'CC/1.0.0 (Flutter; Unknown)',
      };
    }
  }

  /// 获取带认证的请求头
  ///
  /// 强制包含Authorization头，如果token不存在会抛出异常
  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final headers = await getStandardHeaders();

    final token = await _tokenManager.getApiToken();
    if (token == null || token.isEmpty) {
      throw Exception('用户未登录或token已过期');
    }

    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// 发送GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = false,
    bool attachToken = true,
  }) async {
    final headers = requireAuth
        ? await getAuthenticatedHeaders()
        : await getStandardHeaders(attachToken: attachToken);

    final requestOptions =
        Options(headers: headers, extra: {'attachToken': attachToken});

    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  /// 发送POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = false,
    bool attachToken = true,
  }) async {
    final headers = requireAuth
        ? await getAuthenticatedHeaders()
        : await getStandardHeaders(attachToken: attachToken);

    final requestOptions =
        Options(headers: headers, extra: {'attachToken': attachToken});

    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  /// 发送PUT请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = false,
    bool attachToken = true,
  }) async {
    final headers = requireAuth
        ? await getAuthenticatedHeaders()
        : await getStandardHeaders(attachToken: attachToken);

    final requestOptions =
        Options(headers: headers, extra: {'attachToken': attachToken});

    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  /// 发送DELETE请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = false,
    bool attachToken = true,
  }) async {
    final headers = requireAuth
        ? await getAuthenticatedHeaders()
        : await getStandardHeaders(attachToken: attachToken);

    final requestOptions =
        Options(headers: headers, extra: {'attachToken': attachToken});

    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  /// 设置基础URL
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    _logger.i('🔗 设置API基础URL', extra: {'baseUrl': baseUrl});
  }

  /// 设置请求超时
  void setTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
    if (sendTimeout != null) {
      _dio.options.sendTimeout = sendTimeout;
    }

    _logger.i('⏱️ API超时设置已更新');
  }

  /// 添加自定义拦截器
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
    _logger.d('🔧 添加自定义拦截器');
  }

  /// 获取原始Dio实例
  ///
  /// 在需要更精细控制时使用
  Dio get dio => _dio;
}
