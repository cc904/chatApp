import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';

/// 文件上传API服务
/// 对应客户端使用指南的Flutter实现
class UploadApiService {
  final _logger = LogService.instance;
  late final Dio _dio;
  final AppConfig _appConfig = AppConfig();

  // 单例模式
  static final UploadApiService _instance = UploadApiService._internal();
  factory UploadApiService() => _instance;
  UploadApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: '${_appConfig.serverUrl}/api/v1/upload',
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(minutes: 10),
    ));

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 记录请求详细信息，包括认证头
        final authHeader = options.headers['Authorization'];
        _logger.i('上传请求详情', extra: {
          'url': options.path,
          'method': options.method,
          'hasAuth': authHeader != null,
          'authPreview': authHeader != null
              ? '${authHeader.toString().substring(0, 20)}...'
              : '❌ 无认证头',
          'allHeaders': options.headers.keys.toList(),
        });

        // 特别提醒：如果没有认证头
        if (authHeader == null) {
          _logger.w('🚨 警告：上传请求缺少Authorization头！');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i('上传响应', extra: {
          'statusCode': response.statusCode,
          'data': response.data,
        });
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('上传错误', error: error, stackTrace: StackTrace.current);

        // 如果是401错误，给出明确的认证问题提示
        if (error.response?.statusCode == 401) {
          _logger.e('🚨 401认证失败 - 可能的原因:', extra: {
            'reason1': 'Authorization头未设置',
            'reason2': 'Token格式错误',
            'reason3': 'Token已过期',
            'reason4': '服务器端Token验证失败',
            'solution': '请检查fileUploadService.setAuthToken()是否被调用',
          });
        }

        handler.next(error);
      },
    ));
  }

  /// 设置认证token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// 清除认证token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// 图片上传
  Future<UploadApiResult> uploadImage(
    File imageFile, {
    String? conversationId,
    String? caption,
    int? width,
    int? height,
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: imageFile,
      type: 'images',
      conversationId: conversationId,
      metadata: {
        if (caption != null) 'caption': caption,
        if (width != null) 'width': width.toString(),
        if (height != null) 'height': height.toString(),
      },
      onProgress: onProgress,
    );
  }

  /// 语音上传
  Future<UploadApiResult> uploadVoice(
    File voiceFile, {
    String? conversationId,
    int? duration,
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: voiceFile,
      type: 'voice',
      conversationId: conversationId,
      metadata: {
        if (duration != null) 'duration': duration.toString(),
      },
      onProgress: onProgress,
    );
  }

  /// 视频上传
  Future<UploadApiResult> uploadVideo(
    File videoFile, {
    String? conversationId,
    int? duration,
    int? width,
    int? height,
    String? caption,
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: videoFile,
      type: 'videos',
      conversationId: conversationId,
      metadata: {
        if (duration != null) 'duration': duration.toString(),
        if (width != null) 'width': width.toString(),
        if (height != null) 'height': height.toString(),
        if (caption != null) 'caption': caption,
      },
      onProgress: onProgress,
    );
  }

  /// 文档上传
  Future<UploadApiResult> uploadDocument(
    File documentFile, {
    String? conversationId,
    String? caption,
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: documentFile,
      type: 'files',
      conversationId: conversationId,
      metadata: {
        if (caption != null) 'caption': caption,
      },
      onProgress: onProgress,
    );
  }

  /// 头像上传
  Future<UploadApiResult> uploadAvatar(
    File avatarFile, {
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: avatarFile,
      type: 'avatar',
      conversationId: null, // 头像上传不需要conversationId
      metadata: null,
      onProgress: onProgress,
    );
  }

  /// 通用文件上传方法
  Future<UploadApiResult> _uploadFile({
    required File file,
    required String type,
    String? conversationId,
    Map<String, String>? metadata,
    Function(int)? onProgress,
  }) async {
    try {
      // 验证文件
      _validateFile(file, type);

      // 准备表单数据
      final formData = FormData();

      // 添加文件
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: path.basename(file.path),
            contentType: MediaType.parse(mimeType),
          ),
        ),
      );

      // 添加会话ID
      if (conversationId != null) {
        formData.fields.add(MapEntry('conversationId', conversationId));
      }

      // 添加元数据
      if (metadata != null && metadata.isNotEmpty) {
        formData.fields.add(
          MapEntry('metadata', jsonEncode(metadata)),
        );
      }

      // 发送请求
      final response = await _dio.post(
        '/$type',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            final progress = (sent / total * 100).round();
            onProgress(progress);
          }
        },
      );

      // 处理响应
      return _parseResponse(response);
    } catch (error) {
      _logger.e('文件上传失败', error: error, stackTrace: StackTrace.current);
      throw _handleError(error);
    }
  }

  /// 验证文件
  void _validateFile(File file, String type) {
    if (!file.existsSync()) {
      throw const UploadException('文件不存在');
    }

    final fileSize = file.lengthSync();

    switch (type) {
      case 'images':
        if (fileSize > 10 * 1024 * 1024) {
          throw const UploadException('图片大小不能超过10MB');
        }
        break;

      case 'voice':
        if (fileSize > 50 * 1024 * 1024) {
          throw const UploadException('音频文件大小不能超过50MB');
        }
        break;

      case 'videos':
        if (fileSize > 500 * 1024 * 1024) {
          throw const UploadException('视频文件大小不能超过500MB');
        }
        break;

      case 'files':
        // 文件模式：彻底不验证文件类型，只限制大小为500MB
        // 任何文件都可以上传，完全交由服务端处理
        if (fileSize > 500 * 1024 * 1024) {
          throw const UploadException('文件大小不能超过500MB');
        }
        break;

      case 'avatar':
        if (fileSize > 10 * 1024 * 1024) {
          throw const UploadException('头像大小不能超过10MB');
        }
        break;
    }
  }

  /// 解析响应
  UploadApiResult _parseResponse(Response response) {
    final data = response.data;

    if (data['success'] == true) {
      final resultData = data['data'];
      return UploadApiResult(
        success: true,
        fileId: resultData['fileId'],
        url: resultData['url'],
        localPath: resultData['localPath'],
        thumbnailUrl: resultData['thumbnailUrl'],
        metadata: UploadMetadata.fromJson(resultData['metadata']),
      );
    } else {
      throw UploadException(data['error']?['message'] ?? '上传失败');
    }
  }

  /// 处理错误
  UploadException _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final errorData = error.response!.data;
        final errorCode = errorData['error']?['code'];
        final errorMessage = errorData['error']?['message'] ?? '上传失败';

        switch (errorCode) {
          case 'NO_FILE':
            return const UploadException('请选择要上传的文件');
          case 'INVALID_MIME_TYPE':
            return const UploadException('不支持的文件类型');
          case 'INVALID_FILE_EXTENSION':
            return const UploadException('不支持的文件扩展名');
          case 'FILE_TOO_LARGE':
            final maxSize = errorData['error']?['details']?['maxSize'];
            if (maxSize != null) {
              final maxSizeMB = (maxSize / 1024 / 1024).round();
              return UploadException('文件大小超过限制，最大允许 ${maxSizeMB}MB');
            }
            return const UploadException('文件过大');
          case 'FILENAME_TOO_LONG':
            return const UploadException('文件名长度超过限制');
          case 'INVALID_FILENAME':
            return const UploadException('文件名包含非法字符');
          case 'INVALID_FILE_HEADER':
            return const UploadException('文件格式验证失败');
          case 'UPLOAD_FAILED':
            return const UploadException('文件上传处理失败');
          case 'RATE_LIMIT_EXCEEDED':
            return const UploadException('上传过于频繁，请稍后再试');
          default:
            return UploadException(errorMessage);
        }
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return const UploadException('连接超时，请检查网络');
      } else if (error.type == DioExceptionType.sendTimeout) {
        return const UploadException('上传超时，请重试');
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return const UploadException('响应超时，请重试');
      } else {
        return UploadException('网络错误：${error.message}');
      }
    } else if (error is UploadException) {
      return error;
    } else {
      return UploadException('未知错误：${error.toString()}');
    }
  }

  /// 带重试的上传
  Future<UploadApiResult> uploadWithRetry(
    File file,
    String type, {
    String? conversationId,
    Map<String, String>? metadata,
    Function(int)? onProgress,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await _uploadFile(
          file: file,
          type: type,
          conversationId: conversationId,
          metadata: metadata,
          onProgress: onProgress,
        );
      } catch (error) {
        if (i == maxRetries - 1) {
          rethrow;
        }

        _logger.w('上传失败，${delay.inSeconds}秒后重试... (${i + 1}/$maxRetries)');
        await Future.delayed(delay);
        delay = Duration(seconds: delay.inSeconds * 2); // 指数退避
      }
    }

    throw const UploadException('重试次数已用完');
  }
}

/// 上传结果
class UploadApiResult {
  final bool success;
  final String? fileId;
  final String? url;
  final String? localPath;
  final String? thumbnailUrl;
  final UploadMetadata? metadata;
  final String? error;

  const UploadApiResult({
    required this.success,
    this.fileId,
    this.url,
    this.localPath,
    this.thumbnailUrl,
    this.metadata,
    this.error,
  });

  factory UploadApiResult.error(String error) {
    return UploadApiResult(
      success: false,
      error: error,
    );
  }
}

/// 上传元数据
class UploadMetadata {
  final String originalName;
  final int size;
  final String mimeType;
  final int? duration;
  final int? width;
  final int? height;

  const UploadMetadata({
    required this.originalName,
    required this.size,
    required this.mimeType,
    this.duration,
    this.width,
    this.height,
  });

  factory UploadMetadata.fromJson(Map<String, dynamic> json) {
    return UploadMetadata(
      originalName: json['originalName'] ?? '',
      size: _parseIntSafely(json['size']) ?? 0,
      mimeType: json['mimeType'] ?? '',
      duration: _parseIntSafely(json['duration']),
      width: _parseIntSafely(json['width']),
      height: _parseIntSafely(json['height']),
    );
  }

  /// 安全地解析整数，支持字符串转换
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.round();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'originalName': originalName,
      'size': size,
      'mimeType': mimeType,
      if (duration != null) 'duration': duration,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }
}

/// 上传异常
class UploadException implements Exception {
  final String message;
  const UploadException(this.message);

  @override
  String toString() => 'UploadException: $message';
}
