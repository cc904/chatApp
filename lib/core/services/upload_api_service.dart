import 'dart:io' show File;
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:http/http.dart' as http;
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/dynamic_file_server_config.dart';
import 'package:cc/core/services/file_server_config_service.dart';
import 'package:cc/core/database/database_initializer.dart';

/// 文件上传API服务
/// 对应客户端使用指南的Flutter实现
///
/// 注意：文件上传和下载都无需Token认证，文件服务器是独立的无认证服务
class UploadApiService {
  final _logger = LogService.instance;
  Dio? _dio;
  final FileServerConfigService _fileServerConfigService =
      FileServerConfigService.instance;
  bool _isInitialized = false;

  // 单例模式
  static final UploadApiService _instance = UploadApiService._internal();
  factory UploadApiService() => _instance;
  UploadApiService._internal();

  /// 重新初始化Dio配置（当文件服务器配置更新时调用）
  Future<void> reinitialize() async {
    _logger.i('🔄 重新初始化上传API服务');
    _isInitialized = false;
    await _initializeDio();
  }

  /// 通用文件上传方法 - 支持 XFile (Web 平台兼容)
  Future<UploadApiResult> _uploadFileFromXFile({
    required XFile file,
    required String type,
    required String conversationId,
    Map<String, String>? metadata,
    Function(int)? onProgress,
  }) async {
    try {
      // 验证文件
      await _validateXFile(file, type);

      // 准备表单数据
      final formData = FormData();

      // 添加文件
      // Web平台下，file.path是blob URL，无法直接识别MIME类型，需要用文件名
      final mimeType = lookupMimeType(file.name) ?? lookupMimeType(file.path) ?? 'application/octet-stream';
      final bytes = await file.readAsBytes();
      formData.files.add(
        MapEntry(
          'file',
          MultipartFile.fromBytes(
            bytes,
            filename: file.name,
            contentType: MediaType.parse(mimeType),
          ),
        ),
      );

      // 添加会话ID（必需参数）
      formData.fields.add(MapEntry('conversationId', conversationId));

      // 添加文件类型（必需参数）
      formData.fields.add(MapEntry('type', type));

      // 添加用户ID（必需参数）
      // 从当前用户获取用户ID
      final currentUser = DatabaseInitializer.currentUser;
      if (currentUser != null) {
        formData.fields.add(MapEntry('userId', currentUser.userId));
      } else {
        _logger.w('⚠️ 无法获取用户ID，可能影响文件上传');
      }

      // 添加元数据（可选参数）
      if (metadata != null && metadata.isNotEmpty) {
        formData.fields.add(
          MapEntry('metadata', jsonEncode(metadata)),
        );
      }

      // 日志记录要发送的参数和服务器信息
      _logger.i('📤 文件上传参数 (XFile)', extra: {
        'conversationId': conversationId,
        'type': type,
        'userId': currentUser?.userId,
        'hasMetadata': metadata != null && metadata.isNotEmpty,
        'metadataKeys': metadata?.keys.toList(),
        'fileName': file.name,
        'fileSize': bytes.length,
        'serverBaseUrl': _dio?.options.baseUrl,
        'uploadPath': '/api/upload',
        'fullUploadUrl': '${_dio?.options.baseUrl}/api/upload',
        'connectTimeout': _dio?.options.connectTimeout?.inSeconds,
        'receiveTimeout': _dio?.options.receiveTimeout?.inSeconds,
        'dioInitialized': _isInitialized,
        'platform': 'web',
      });

      // 确保Dio已初始化
      await _ensureDioInitialized();

      // 发送请求到新的API端点
      final response = await _dio!.post(
        '/api/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            final progress = (sent / total * 100).round();
            onProgress(progress);
          }
        },
      );

      // 处理响应
      return await _parseResponse(response);
    } catch (error, stackTrace) {
      _logger.e('文件上传失败 (XFile)', error: error, stackTrace: stackTrace);
      throw _handleError(error);
    }
  }

  /// 验证 XFile
  Future<void> _validateXFile(XFile file, String type) async {
    final fileSize = await file.length();

    // 优先使用FileServerConfigService获取文件大小限制
    final isAllowed =
        await _fileServerConfigService.isFileSizeAllowed(type, fileSize);
    if (isAllowed) {
      return;
    }

    // 如果FileServerConfigService不可用，使用动态配置的文件大小限制
    final dynamicConfig = DynamicFileServerConfig();
    final config = dynamicConfig.currentConfig;

    if (config != null && config.isFileSizeValidForType(fileSize, type)) {
      // 文件大小符合动态配置限制
      return;
    }

    // 获取具体的文件大小限制并生成错误消息
    final limit = await _fileServerConfigService.getFileSizeLimit(type);
    if (limit != null) {
      final maxSizeMB = (limit / 1024 / 1024).round();
      String errorMessage;

      switch (type.toLowerCase()) {
        case 'image':
        case 'images':
          errorMessage = '图片大小不能超过${maxSizeMB}MB';
          break;
        case 'voice':
          // 语音文件已通过时长限制，无需大小限制
          return;
        case 'video':
        case 'videos':
          errorMessage = '视频文件大小不能超过${maxSizeMB}MB';
          break;
        case 'file':
        case 'files':
          errorMessage = '文件大小不能超过${maxSizeMB}MB';
          break;
        case 'avatar':
          errorMessage = '头像大小不能超过${maxSizeMB}MB';
          break;
        default:
          errorMessage = '文件大小超过限制';
      }

      throw UploadException(errorMessage);
    }

    // 如果动态配置验证失败，抛出具体的错误信息
    if (config != null) {
      final limits = config.limits;
      String errorMessage;

      switch (type.toLowerCase()) {
        case 'image':
        case 'images':
          final maxSizeMB = (limits.imageMaxSize / 1024 / 1024).round();
          errorMessage = '图片大小不能超过${maxSizeMB}MB';
          break;
        case 'voice':
          // 语音文件已通过时长限制，无需大小限制
          return;
        case 'video':
        case 'videos':
          final maxSizeMB = (limits.videoMaxSize / 1024 / 1024).round();
          errorMessage = '视频文件大小不能超过${maxSizeMB}MB';
          break;
        case 'file':
        case 'files':
          final maxSizeMB = (limits.fileMaxSize / 1024 / 1024).round();
          errorMessage = '文件大小不能超过${maxSizeMB}MB';
          break;
        case 'avatar':
          final maxSizeMB = (limits.imageMaxSize / 1024 / 1024).round();
          errorMessage = '头像大小不能超过${maxSizeMB}MB';
          break;
        default:
          errorMessage = '文件大小超过限制';
      }

      throw UploadException(errorMessage);
    }

    // 如果没有配置，使用默认限制
    throw const UploadException('文件大小超过限制');
  }

  /// 当ServerConfig更新时调用此方法重新配置服务
  Future<void> onServerConfigChanged() async {
    _logger.i('🔄 ServerConfig已更改，重新初始化上传API服务');
    await reinitialize();
  }

  Future<void> _initializeDio() async {
    // 获取默认文件服务器URL
    final baseUrl = await _getFileServerBaseUrl();

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl, // 使用ServerConfig中的文件服务器地址
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(minutes: 10),
    ));

    // 添加拦截器
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 记录请求详细信息（无需认证）
        _logger.i('上传请求详情', extra: {
          'baseUrl': options.baseUrl,
          'fullUrl': '${options.baseUrl}${options.path}',
          'path': options.path,
          'method': options.method,
          'headers': options.headers.keys.toList(),
          'contentType': options.contentType,
          'connectTimeout': options.connectTimeout?.inSeconds,
          'receiveTimeout': options.receiveTimeout?.inSeconds,
        });

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
        _logger.e('上传错误', error: error, extra: {
          'errorType': error.type.name,
          'statusCode': error.response?.statusCode,
          'statusMessage': error.response?.statusMessage,
          'baseUrl': error.requestOptions.baseUrl,
          'fullUrl': '${error.requestOptions.baseUrl}${error.requestOptions.path}',
          'path': error.requestOptions.path,
          'method': error.requestOptions.method,
          'responseData': error.response?.data,
          'serverMessage': error.message,
        });
        handler.next(error);
      },
    ));

    _isInitialized = true;
  }

  /// 获取文件服务器基础URL
  Future<String> _getFileServerBaseUrl() async {
    try {
      // 优先使用FileServerConfigService获取配置
      final defaultFileServerUrl =
          await _fileServerConfigService.getDefaultFileServerUrl();
      if (defaultFileServerUrl != null && defaultFileServerUrl.isNotEmpty) {
        _logger.i('✅ 使用ServerConfig中的文件服务器地址',
            extra: {'url': defaultFileServerUrl});
        return defaultFileServerUrl;
      }

      // 如果新的配置不可用，使用DynamicFileServerConfig作为后备
      final dynamicConfig = DynamicFileServerConfig();
      final config = dynamicConfig.currentConfig;
      if (config != null && config.defaultFsUrl.isNotEmpty) {
        _logger.i('✅ 使用DynamicFileServerConfig中的文件服务器地址',
            extra: {'url': config.defaultFsUrl});
        return config.defaultFsUrl;
      }

      // 如果都不可用，使用默认地址
      const defaultUrl = 'http://13.158.26.10:7031';
      _logger.w('⚠️ 未找到文件服务器配置，使用默认地址', extra: {'url': defaultUrl});
      return defaultUrl;
    } catch (error) {
      _logger.e('获取文件服务器地址失败', error: error);
      // 返回默认地址作为后备
      const defaultUrl = 'http://13.158.26.10:7031';
      return defaultUrl;
    }
  }

  /// 确保Dio已初始化
  Future<void> _ensureDioInitialized() async {
    if (!_isInitialized || _dio == null) {
      await _initializeDio();
    }
  }

  /// 图片上传 - 支持 XFile (Web 平台兼容)
  Future<UploadApiResult> uploadImageFromXFile(
    XFile imageFile, {
    required String conversationId,
    String? caption,
    int? width,
    int? height,
    Function(int)? onProgress,
  }) async {
    return _uploadFileFromXFile(
      file: imageFile,
      type: 'image',
      conversationId: conversationId,
      metadata: {
        if (caption != null) 'caption': caption,
        if (width != null) 'width': width.toString(),
        if (height != null) 'height': height.toString(),
      },
      onProgress: onProgress,
    );
  }

  /// 图片上传 - 支持 File (IO 平台)
  Future<UploadApiResult> uploadImage(
    File imageFile, {
    required String conversationId,
    String? caption,
    int? width,
    int? height,
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: imageFile,
      type: 'image',
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
    required String conversationId,
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
    required String conversationId,
    int? duration,
    int? width,
    int? height,
    String? caption,
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: videoFile,
      type: 'video',
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
    required String conversationId,
    String? caption,
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: documentFile,
      type: 'file',
      conversationId: conversationId,
      metadata: {
        if (caption != null) 'caption': caption,
      },
      onProgress: onProgress,
    );
  }

  /// 头像上传
  Future<UploadApiResult> uploadAvatar(
    dynamic avatarFile, {  // 支持File和Uint8List
    Function(int)? onProgress,
  }) async {
    return _uploadFile(
      file: avatarFile,
      type: 'image', // 头像也使用image类型
      conversationId: 'avatar', // 使用固定值作为头像标识
      metadata: null,
      onProgress: onProgress,
    );
  }

  /// 通用文件上传方法
  Future<UploadApiResult> _uploadFile({
    required dynamic file, // 支持File和Uint8List
    required String type,
    required String conversationId,
    Map<String, String>? metadata,
    Function(int)? onProgress,
  }) async {
    try {
      // 验证文件
      await _validateFile(file, type);

      // 准备表单数据
      final formData = FormData();

      // 添加文件
      if (file is Uint8List) {
        // 直接使用字节数据（Web平台或预处理的文件）
        _logger.i('📎 使用字节数据上传', extra: {'bytesLength': file.length});
        
        // 根据类型确定文件名和MIME类型
        String fileName;
        String mimeType;
        
        if (type == 'image') {
          fileName = 'avatar.jpg';
          mimeType = 'image/jpeg';
        } else if (type == 'voice') {
          fileName = 'voice_recording.m4a';
          mimeType = 'audio/mp4';
        } else {
          fileName = 'file.bin';
          mimeType = 'application/octet-stream';
        }
        
        formData.files.add(
          MapEntry(
            'file',
            MultipartFile.fromBytes(
              file,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );
      } else if (kIsWeb && file.path.startsWith('blob:')) {
        // Web平台处理blob URL
        _logger.i('🌐 Web平台处理blob URL文件', extra: {'path': file.path});
        
        try {
          // 使用HTTP客户端获取blob URL数据
          final response = await http.get(Uri.parse(file.path));
          if (response.statusCode != 200) {
            throw Exception('无法获取blob数据: ${response.statusCode}');
          }
          
          final Uint8List bytes = response.bodyBytes;
          const fileName = 'voice_recording.m4a';
          const mimeType = 'audio/mp4'; // Web录音通常是AAC格式
          
          _logger.i('🌐 成功获取blob数据', extra: {
            'bytesLength': bytes.length,
            'fileName': fileName,
            'mimeType': mimeType,
          });
          
          formData.files.add(
            MapEntry(
              'file',
              MultipartFile.fromBytes(
                bytes,
                filename: fileName,
                contentType: MediaType.parse(mimeType),
              ),
            ),
          );
        } catch (e) {
          _logger.e('🌐 获取blob数据失败', error: e);
          rethrow;
        }
      } else {
        // 移动端/桌面端正常文件处理
        final mimeType = lookupMimeType(file.path) ??
                        lookupMimeType(path.basename(file.path)) ??
                        'application/octet-stream';
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
      }

      // 添加会话ID（必需参数）
      formData.fields.add(MapEntry('conversationId', conversationId));

      // 添加文件类型（必需参数）
      formData.fields.add(MapEntry('type', type));

      // 添加用户ID（必需参数）
      // 从当前用户获取用户ID
      final currentUser = DatabaseInitializer.currentUser;
      if (currentUser != null) {
        formData.fields.add(MapEntry('userId', currentUser.userId));
      } else {
        _logger.w('⚠️ 无法获取用户ID，可能影响文件上传');
      }

      // 暂时不发送timestamp参数，因为服务器在解析时出现错误
      // TODO: 需要与服务器端协调正确的timestamp格式
      // final utcTimestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      // formData.fields.add(MapEntry('timestamp', utcTimestamp.toString()));

      // 添加元数据（可选参数）
      if (metadata != null && metadata.isNotEmpty) {
        formData.fields.add(
          MapEntry('metadata', jsonEncode(metadata)),
        );
      }

      // 日志记录要发送的参数和服务器信息
      final logExtra = <String, dynamic>{
        'conversationId': conversationId,
        'type': type,
        'userId': currentUser?.userId,
        'hasMetadata': metadata != null && metadata.isNotEmpty,
        'metadataKeys': metadata?.keys.toList(),
        'serverBaseUrl': _dio?.options.baseUrl,
        'uploadPath': '/api/upload',
        'fullUploadUrl': '${_dio?.options.baseUrl}/api/upload',
        'connectTimeout': _dio?.options.connectTimeout?.inSeconds,
        'receiveTimeout': _dio?.options.receiveTimeout?.inSeconds,
        'dioInitialized': _isInitialized,
      };

      // Web平台和移动端使用不同的方式获取文件信息
      if (kIsWeb && file.path.startsWith('blob:')) {
        logExtra['fileName'] = 'voice_recording.m4a';
        logExtra['fileSize'] = 'blob_url';
        logExtra['filePath'] = file.path;
      } else {
        logExtra['fileName'] = path.basename(file.path);
        logExtra['fileSize'] = file.lengthSync();
        logExtra['filePath'] = file.path;
      }

      _logger.i('📤 文件上传参数', extra: logExtra);

      // 确保Dio已初始化
      await _ensureDioInitialized();

      // 发送请求到新的API端点
      final response = await _dio!.post(
        '/api/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            final progress = (sent / total * 100).round();
            onProgress(progress);
          }
        },
      );

      // 处理响应
      return await _parseResponse(response);
    } catch (error, stackTrace) {
      _logger.e('文件上传失败', error: error, stackTrace: stackTrace);
      throw _handleError(error);
    }
  }

  /// 验证文件
  Future<void> _validateFile(dynamic file, String type) async {
    // 处理Uint8List类型
    if (file is Uint8List) {
      final fileSize = file.length;
      
      // 使用FileServerConfigService检查文件大小限制
      final isAllowed = await _fileServerConfigService.isFileSizeAllowed(type, fileSize);
      if (!isAllowed) {
        // 如果服务检查失败，使用默认限制
        const maxSize = 50 * 1024 * 1024; // 50MB
        if (fileSize > maxSize) {
          throw UploadException('文件大小超过限制: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB > 50MB');
        }
      }
      return;
    }
    
    // Web平台跳过文件系统检查，因为使用blob URL
    if (kIsWeb) {
      // 对于Web平台，我们无法检查文件大小，直接通过验证
      return;
    }

    final ioFile = file as File;
    if (!ioFile.existsSync()) {
      throw const UploadException('文件不存在');
    }

    final fileSize = ioFile.lengthSync();

    // 优先使用FileServerConfigService获取文件大小限制
    final isAllowed =
        await _fileServerConfigService.isFileSizeAllowed(type, fileSize);
    if (isAllowed) {
      return;
    }

    // 如果FileServerConfigService不可用，使用动态配置的文件大小限制
    final dynamicConfig = DynamicFileServerConfig();
    final config = dynamicConfig.currentConfig;

    if (config != null && config.isFileSizeValidForType(fileSize, type)) {
      // 文件大小符合动态配置限制
      return;
    }

    // 获取具体的文件大小限制并生成错误消息
    final limit = await _fileServerConfigService.getFileSizeLimit(type);
    if (limit != null) {
      final maxSizeMB = (limit / 1024 / 1024).round();
      String errorMessage;

      switch (type.toLowerCase()) {
        case 'image':
        case 'images':
          errorMessage = '图片大小不能超过${maxSizeMB}MB';
          break;
        case 'voice':
          // 语音文件已通过时长限制，无需大小限制
          return;
        case 'video':
        case 'videos':
          errorMessage = '视频文件大小不能超过${maxSizeMB}MB';
          break;
        case 'file':
        case 'files':
          errorMessage = '文件大小不能超过${maxSizeMB}MB';
          break;
        case 'avatar':
          errorMessage = '头像大小不能超过${maxSizeMB}MB';
          break;
        default:
          errorMessage = '文件大小超过限制';
      }

      throw UploadException(errorMessage);
    }

    // 如果动态配置验证失败，抛出具体的错误信息
    if (config != null) {
      final limits = config.limits;
      String errorMessage;

      switch (type.toLowerCase()) {
        case 'image':
        case 'images':
          final maxSizeMB = (limits.imageMaxSize / 1024 / 1024).round();
          errorMessage = '图片大小不能超过${maxSizeMB}MB';
          break;
        case 'voice':
          // 语音文件已通过时长限制，无需大小限制
          return;
        case 'video':
        case 'videos':
          final maxSizeMB = (limits.videoMaxSize / 1024 / 1024).round();
          errorMessage = '视频文件大小不能超过${maxSizeMB}MB';
          break;
        case 'file':
        case 'files':
          final maxSizeMB = (limits.fileMaxSize / 1024 / 1024).round();
          errorMessage = '文件大小不能超过${maxSizeMB}MB';
          break;
        case 'avatar':
          final maxSizeMB = (limits.imageMaxSize / 1024 / 1024).round();
          errorMessage = '头像大小不能超过${maxSizeMB}MB';
          break;
        default:
          errorMessage = '文件大小超过限制';
      }

      throw UploadException(errorMessage);
    }

    // 如果没有动态配置，使用硬编码的默认限制作为后备
    switch (type) {
      case 'images':
        if (fileSize > 10 * 1024 * 1024) {
          throw const UploadException('图片大小不能超过10MB');
        }
        break;

      case 'voice':
        // 语音文件已通过时长限制，无需大小限制
        break;

      case 'videos':
        if (fileSize > 500 * 1024 * 1024) {
          throw const UploadException('视频文件大小不能超过500MB');
        }
        break;

      case 'files':
        // 文件模式：彻底不验证文件类型，只限制大小为100MB
        // 任何文件都可以上传，完全交由服务端处理
        if (fileSize > 100 * 1024 * 1024) {
          throw const UploadException('文件大小不能超过100MB');
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
  Future<UploadApiResult> _parseResponse(Response response) async {
    final data = response.data;

    _logger.i('解析上传响应', extra: {
      'responseData': data,
      'success': data['success'],
    });

    if (data['success'] == true) {
      final resultData = data['data'];
      
      _logger.i('上传成功，解析结果数据', extra: {
        'resultData': resultData,
        'serverFsID': resultData['fsID'],
        'fileName': resultData['fileName'],
        'metadata': resultData['metadata'],
      });

      // 获取文件服务器ID：优先使用服务器返回的fsID，否则使用默认文件服务器ID，最后使用后备ID
      String? fsId = resultData['fsID'];
      if (fsId == null) {
        fsId = await _fileServerConfigService.getDefaultFileServerId();
        _logger.d('使用默认文件服务器ID', extra: {'defaultFsId': fsId});
        
        // 如果默认文件服务器ID也为空，使用后备ID
        if (fsId == null) {
          fsId = '1'; // 使用默认的文件服务器ID作为后备
          _logger.w('默认文件服务器ID为空，使用后备ID', extra: {'fallbackFsId': fsId});
        }
      } else {
        _logger.d('使用服务器返回的文件服务器ID', extra: {'serverFsId': fsId});
      }

      final result = UploadApiResult(
        success: true,
        fileId: fsId, // 使用确定的文件服务器ID（与fsId保持一致）
        fileName: resultData['fileName'], // 服务器返回的文件名
        fsId: fsId, // 文件服务器ID
        url: null, // 新的文件服务器不直接返回URL，由客户端构建
        localPath: null, // 文件服务器不返回本地路径
        metadata: UploadMetadata.fromJson(resultData['metadata'] ?? {}),
      );

      _logger.i('构建上传结果', extra: {
        'success': result.success,
        'fileId': result.fileId,
        'fileName': result.fileName,
        'fsId': result.fsId,
        'metadata': result.metadata?.toJson(),
      });

      return result;
    } else {
      _logger.e('上传失败', extra: {
        'error': data['error'],
        'message': data['error']?['message'],
      });
      throw UploadException(data['error']?['message'] ?? '上传失败');
    }
  }

  /// 处理错误
  UploadException _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final errorData = error.response!.data;

        // 添加详细的错误日志
        _logger.e('服务器错误详情', extra: {
          'statusCode': error.response!.statusCode,
          'statusMessage': error.response!.statusMessage,
          'responseData': errorData,
        });

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
            return UploadException(errorMessage);
          case 'RATE_LIMIT_EXCEEDED':
            return const UploadException('上传过于频繁，请稍后再试');
          default:
            // 如果没有特定的错误代码，尝试从响应中获取更多信息
            if (errorData is Map && errorData.containsKey('message')) {
              return UploadException(errorData['message']);
            } else if (errorData is String) {
              return UploadException(errorData);
            } else {
              return UploadException(
                  '上传失败：${error.response!.statusMessage ?? '未知错误'}');
            }
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
    required String conversationId,
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
  final String? fileName; // 服务器返回的文件名
  final String? fsId; // 文件服务器ID
  final String? url;
  final String? localPath;
  final UploadMetadata? metadata;
  final String? error;

  const UploadApiResult({
    required this.success,
    this.fileId,
    this.fileName,
    this.fsId,
    this.url,
    this.localPath,
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
