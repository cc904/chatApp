import 'package:dio/dio.dart';
import 'package:cc/core/services/log_service.dart';

/// API错误处理工具类
///
/// 统一处理所有API接口的错误响应格式：
/// {"success": false, "message": "错误信息"}
class ApiErrorHandler {
  static final LogService _logger = LogService.instance;

  /// 从API响应中提取错误信息
  ///
  /// 处理以下情况：
  /// 1. 标准API错误响应：{"success": false, "message": "错误信息"}
  /// 2. DioException网络错误
  /// 3. 其他异常
  static String extractErrorMessage(dynamic error) {
    try {
      // 1. 处理DioException
      if (error is DioException) {
        return _handleDioException(error);
      }

      // 2. 处理Exception类型，尝试从消息中提取
      if (error is Exception) {
        final errorString = error.toString();

        // 如果是我们抛出的Exception，直接返回消息
        if (errorString.startsWith('Exception: ')) {
          return errorString.substring(11); // 移除"Exception: "前缀
        }

        return errorString;
      }

      // 3. 处理其他类型的错误
      return error.toString();
    } catch (e) {
      _logger.e('提取错误信息失败', error: e);
      return '未知错误';
    }
  }

  /// 处理DioException
  static String _handleDioException(DioException dioError) {
    try {
      // 记录详细的错误信息用于调试
      _logger.e('DioException详情', extra: {
        'type': dioError.type.toString(),
        'statusCode': dioError.response?.statusCode,
        'requestPath': dioError.requestOptions.path,
        'method': dioError.requestOptions.method,
        'hasResponseData': dioError.response?.data != null,
      });

      // 1. 处理有响应数据的情况
      if (dioError.response?.data != null) {
        final responseData = dioError.response!.data;

        // 如果响应数据是Map，尝试提取message字段
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'];
          if (message != null && message.toString().isNotEmpty) {
            _logger.i('从API响应中提取错误信息', extra: {
              'message': message,
              'success': responseData['success'],
              'statusCode': dioError.response?.statusCode,
            });
            return message.toString();
          }
        }

        // 如果响应数据是字符串，直接返回
        if (responseData is String && responseData.isNotEmpty) {
          return responseData;
        }
      }

      // 2. 处理没有响应数据的情况，根据错误类型返回友好的错误信息
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络';
        case DioExceptionType.sendTimeout:
          return '请求超时，请重试';
        case DioExceptionType.receiveTimeout:
          return '响应超时，请重试';
        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          switch (statusCode) {
            case 400:
              return '请求参数错误';
            case 401:
              return '未授权，请重新登录';
            case 403:
              return '权限不足';
            case 404:
              return '请求的资源不存在';
            case 429:
              return '请求过于频繁，请稍后重试';
            case 500:
              return '服务器内部错误';
            case 502:
              return '网关错误';
            case 503:
              return '服务暂时不可用';
            default:
              return '请求失败(${statusCode ?? 'Unknown'})';
          }
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.connectionError:
          return '网络连接错误，请检查网络';
        case DioExceptionType.badCertificate:
          return '证书验证失败';
        case DioExceptionType.unknown:
          return '网络错误：${dioError.message ?? '未知错误'}';
      }
    } catch (e) {
      _logger.e('处理DioException失败', error: e);
      return '网络错误';
    }
  }

  /// 验证API响应格式
  ///
  /// 检查响应是否符合标准格式：{"success": boolean, "message": string}
  static bool isValidApiResponse(Map<String, dynamic> response) {
    return response.containsKey('success') &&
        response.containsKey('message') &&
        response['success'] is bool;
  }

  /// 创建标准的API错误异常
  ///
  /// 用于在Repository层抛出标准格式的错误
  static Exception createApiException(String message) {
    return Exception(message);
  }

  /// 从响应中提取成功状态
  static bool isSuccessResponse(Map<String, dynamic> response) {
    return response['success'] == true;
  }

  /// 从响应中提取消息
  static String? extractMessage(Map<String, dynamic> response) {
    return response['message']?.toString();
  }
}
