import 'dart:io';

import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:dio/dio.dart';

class FileUploadResult {
  final String mediaUrl;
  final String? thumbUrl;
  final String mimeType;
  final String fileName;
  final double fileSizeKb;
  final String? fsId;
  final int? width;
  final int? height;
  final int? duration;

  FileUploadResult({
    required this.mediaUrl,
    required this.mimeType,
    required this.fileName,
    required this.fileSizeKb,
    this.thumbUrl,
    this.fsId,
    this.width,
    this.height,
    this.duration,
  });
}

/// 文件上传服务（快捷回复媒体专用）
class FileUploadService {
  FileUploadService._();
  static final FileUploadService instance = FileUploadService._();

  final LogService _logger = LogService.instance;
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 60),
  ));

  /// 上传媒体文件到文件服务器（category 固定为 quick-reply）
  /// [type] 必须是 image|video|voice|file
  Future<FileUploadResult> uploadForQuickReply({
    required String filePath,
    required String type,
  }) async {
    final fileServer = AppConfig().fileServerUrl;
    if (fileServer.isEmpty) {
      throw Exception('文件服务器地址未配置');
    }

    final url = Uri.parse(fileServer).resolve('/api/upload').toString();
    _logger.i('开始上传快捷回复媒体', extra: {
      'url': url,
      'type': type,
      'file': filePath,
    });

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : 'media'),
      'type': type,
      'category': 'quick-reply',
    });

    try {
      final resp = await _dio.post(url, data: formData);
      final data = resp.data;
      if (data is! Map || data['success'] != true) {
        final err = data is Map ? data['error'] : null;
        final code = err is Map ? (err['code'] ?? 'UPLOAD_FAILED') : 'UPLOAD_FAILED';
        final msg = err is Map ? (err['message'] ?? '上传失败') : '上传失败';
        throw Exception('$code: $msg');
      }

      final d = data['data'] as Map;
      final metadata = (d['metadata'] as Map?) ?? const {};
      return FileUploadResult(
        mediaUrl: d['mediaUrl'] as String,
        thumbUrl: d['thumbUrl'] as String?,
        mimeType: d['mimeType'] as String? ?? 'application/octet-stream',
        fileName: d['fileName'] as String? ?? 'media',
        fileSizeKb: (d['fileSizeKb'] as num?)?.toDouble() ??
            ((d['size'] as num?)?.toDouble() ?? 0) / 1024.0,
        fsId: (d['fsId'] ?? d['fsID']) as String?,
        width: (metadata['width'] as num?)?.toInt(),
        height: (metadata['height'] as num?)?.toInt(),
        duration: (metadata['duration'] as num?)?.toInt(),
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      _logger.e('文件上传失败', extra: {
        'status': code,
        'body': body,
      });
      if (body is Map && body['error'] is Map) {
        final err = body['error'] as Map;
        throw Exception('${err['code'] ?? 'UPLOAD_FAILED'}: ${err['message'] ?? '上传失败'}');
      }
      rethrow;
    }
  }
}
