import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:cc/core/utils/api_error_handler.dart';

void main() {
  group('ApiErrorHandler 测试', () {
    test('应该正确提取DioException中的API错误消息', () {
      // 模拟API错误响应
      final responseData = {'success': false, 'message': '该手机号已被注册'};

      final response = Response(
        data: responseData,
        statusCode: 400,
        requestOptions: RequestOptions(path: '/api/v1/auth/register'),
      );

      final dioError = DioException(
        response: response,
        requestOptions: RequestOptions(path: '/api/v1/auth/register'),
        type: DioExceptionType.badResponse,
      );

      final errorMessage = ApiErrorHandler.extractErrorMessage(dioError);

      expect(errorMessage, equals('该手机号已被注册'));
    });

    test('应该正确处理Exception类型的错误', () {
      final exception = Exception('请输入手机号码');

      final errorMessage = ApiErrorHandler.extractErrorMessage(exception);

      expect(errorMessage, equals('请输入手机号码'));
    });

    test('应该正确处理网络连接错误', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.connectionError,
        message: 'Connection failed',
      );

      final errorMessage = ApiErrorHandler.extractErrorMessage(dioError);

      expect(errorMessage, equals('网络连接错误，请检查网络'));
    });

    test('应该正确处理超时错误', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.connectionTimeout,
      );

      final errorMessage = ApiErrorHandler.extractErrorMessage(dioError);

      expect(errorMessage, equals('连接超时，请检查网络'));
    });

    test('应该正确处理429错误', () {
      final response = Response(
        data: {'success': false, 'message': '发送过于频繁，请稍后再试'},
        statusCode: 429,
        requestOptions: RequestOptions(path: '/api/v1/auth/sendCode'),
      );

      final dioError = DioException(
        response: response,
        requestOptions: RequestOptions(path: '/api/v1/auth/sendCode'),
        type: DioExceptionType.badResponse,
      );

      final errorMessage = ApiErrorHandler.extractErrorMessage(dioError);

      expect(errorMessage, equals('发送过于频繁，请稍后再试'));
    });

    test('应该验证API响应格式', () {
      final validResponse = {'success': false, 'message': '错误信息'};

      final invalidResponse = {'status': 'error', 'error': '错误信息'};

      expect(ApiErrorHandler.isValidApiResponse(validResponse), isTrue);
      expect(ApiErrorHandler.isValidApiResponse(invalidResponse), isFalse);
    });

    test('应该正确提取成功状态', () {
      final successResponse = {'success': true, 'message': '操作成功'};
      final failureResponse = {'success': false, 'message': '操作失败'};

      expect(ApiErrorHandler.isSuccessResponse(successResponse), isTrue);
      expect(ApiErrorHandler.isSuccessResponse(failureResponse), isFalse);
    });

    test('应该正确提取消息', () {
      final response = {'success': false, 'message': '该手机号已被注册'};

      final message = ApiErrorHandler.extractMessage(response);

      expect(message, equals('该手机号已被注册'));
    });
  });
}
