import 'dart:io';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/log_service.dart';

/// 文件上传服务迁移指南
/// 从模拟实现迁移到真实API实现的指南和示例
class FileUploadMigrationGuide {
  final _logger = LogService.instance;
  final _fileUploadService = FileUploadService();

  /// 迁移示例1: 图片上传
  /// 从: 简单的本地保存
  /// 到: 真实API上传 + 本地缓存
  Future<void> migrateImageUpload() async {
    final imageFile = File('/path/to/image.jpg');

    // === 旧的模拟实现 ===
    // final result = await _fileUploadService.uploadImage(imageFile);

    // === 新的真实API实现 ===
    try {
      // 1. 设置认证token（通常在登录后设置一次）
      _fileUploadService.setAuthToken('your-jwt-token-here');

      // 2. 使用新的API参数上传图片
      final result = await _fileUploadService.uploadImage(
        imageFile,
        conversationId: 'conv_123', // 可选：关联到特定会话
        caption: '这是一张图片', // 可选：图片说明
        onProgress: (progress) {
          _logger.d('上传进度: $progress%'); // 实时进度回调
        },
      );

      if (result != null) {
        _logger.i('图片上传成功', extra: {
          'fileId': result.fileId, // 新增：服务器文件ID
          'localPath': result.localPath, // 本地缓存路径
          'remoteUrl': result.remoteUrl, // 服务器URL
          'thumbnailUrl': result.thumbnailUrl, // 新增：缩略图URL
          'metadata': result.metadata, // 新增：完整元数据
        });

        // 新功能：可以获取图片的详细信息
        final metadata = result.metadata;
        if (metadata != null) {
          _logger.d('原始文件名: ${metadata['originalName']}');
          _logger.d('文件大小: ${metadata['size']} 字节');
          _logger.d('图片尺寸: ${metadata['width']}x${metadata['height']}');
          _logger.d('MIME类型: ${metadata['mimeType']}');
        }
      }
    } catch (error) {
      _logger.e('图片上传失败: $error');
    }
  }

  /// 迁移示例2: 语音上传
  /// 从: 简单添加duration参数
  /// 到: 完整的元数据和API集成
  Future<void> migrateVoiceUpload() async {
    final voiceFile = File('/path/to/voice.aac');
    const duration = 45000; // 45秒，单位：毫秒

    // === 新的真实API实现 ===
    try {
      final result = await _fileUploadService.uploadVoice(
        voiceFile,
        duration,
        conversationId: 'conv_123',
        onProgress: (progress) {
          _logger.d('语音上传进度: $progress%');
        },
      );

      if (result != null) {
        _logger.i('语音上传成功', extra: {
          'fileId': result.fileId,
          'duration': result.duration, // 保留duration信息
          'remoteUrl': result.remoteUrl,
          'metadata': result.metadata,
        });

        // 语音文件的特定信息
        _logger.d('语音时长: ${result.duration! / 1000}秒');
        if (result.metadata != null) {
          _logger.d('音频格式: ${result.metadata!['mimeType']}');
          _logger.d('文件大小: ${result.metadata!['size']} 字节');
        }
      }
    } catch (error) {
      _logger.e('语音上传失败: $error');
    }
  }

  /// 迁移示例3: 视频上传
  /// 从: 客户端生成缩略图
  /// 到: 服务器端处理 + 高质量缩略图
  Future<void> migrateVideoUpload() async {
    final videoFile = File('/path/to/video.mp4');

    // === 新的真实API实现的优势 ===
    try {
      final result = await _fileUploadService.uploadVideo(
        videoFile,
        conversationId: 'conv_123',
        caption: '精彩视频分享',
        onProgress: (progress) {
          _logger.d('视频上传进度: $progress%');
        },
      );

      if (result != null) {
        _logger.i('视频上传成功', extra: {
          'fileId': result.fileId,
          'remoteUrl': result.remoteUrl,
          'thumbnailUrl': result.thumbnailUrl, // 服务器生成的高质量缩略图
          'serverProcessed': result.serverProcessed, // true表示服务器处理
          'metadata': result.metadata,
        });

        // 视频特定信息
        if (result.metadata != null) {
          final metadata = result.metadata!;
          _logger.d('视频尺寸: ${metadata['width']}x${metadata['height']}');
          _logger.d('视频时长: ${metadata['duration']! / 1000}秒');
          _logger.d('文件大小: ${metadata['size']} 字节');
        }

        // 服务器生成的缩略图（比客户端生成的质量更高）
        if (result.thumbnailUrl != null) {
          _logger.d('缩略图URL: ${result.thumbnailUrl}');
          _logger.d('缩略图由服务器生成: ${result.serverProcessed}');
        }

        // 备用方案：如果服务器缩略图生成失败，可以使用本地生成
        if (result.thumbnailUrl == null) {
          _logger.d('服务器未生成缩略图，使用本地备用方案');
          final localThumbnail =
              await _fileUploadService.generateVideoThumbnail(videoFile.path);
          if (localThumbnail != null) {
            _logger.d('本地缩略图路径: ${localThumbnail.path}');
          }
        }
      }
    } catch (error) {
      _logger.e('视频上传失败: $error');
    }
  }

  /// 迁移示例4: 文档上传
  /// 从: 基础文件上传
  /// 到: 完整的文档处理和元数据
  Future<void> migrateDocumentUpload() async {
    final documentFile = File('/path/to/document.pdf');

    try {
      final result = await _fileUploadService.uploadFile(
        documentFile,
        conversationId: 'conv_123',
        caption: '重要文档',
        onProgress: (progress) {
          _logger.d('文档上传进度: $progress%');
        },
      );

      if (result != null) {
        _logger.i('文档上传成功', extra: {
          'fileId': result.fileId,
          'remoteUrl': result.remoteUrl,
          'thumbnailUrl': result.thumbnailUrl, // 某些文档可能有预览图
          'metadata': result.metadata,
        });

        // 文档特定信息
        if (result.metadata != null) {
          final metadata = result.metadata!;
          _logger.d('原始文件名: ${metadata['originalName']}');
          _logger.d('文件类型: ${metadata['mimeType']}');
          _logger.d(
              '文件大小: ${(metadata['size'] / 1024 / 1024).toStringAsFixed(2)} MB');
        }
      }
    } catch (error) {
      _logger.e('文档上传失败: $error');
    }
  }

  /// 认证管理示例
  void demonstrateAuthManagement() {
    // 在用户登录时设置token
    void onUserLogin(String jwtToken) {
      _fileUploadService.setAuthToken(jwtToken);
      _logger.i('文件上传服务已设置认证token');
    }

    // 在用户登出时清除token
    void onUserLogout() {
      _fileUploadService.clearAuthToken();
      _logger.i('文件上传服务已清除认证token');
    }

    // 示例调用
    onUserLogin('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
    // ... 用户会话期间可以正常上传文件
    onUserLogout();
  }

  /// 错误处理最佳实践
  Future<void> demonstrateErrorHandling() async {
    final file = File('/path/to/file.jpg');

    try {
      final result = await _fileUploadService.uploadImage(file);

      if (result == null) {
        // 上传失败，但没有抛出异常
        _logger.w('上传失败，返回null结果');
        _showUserFriendlyError('上传失败，请稍后重试');
        return;
      }

      // 上传成功
      _handleUploadSuccess(result);
    } catch (error) {
      // 捕获具体的上传异常
      _logger.e('上传过程中发生异常: $error');

      // 根据错误类型提供不同的用户提示
      if (error.toString().contains('network')) {
        _showUserFriendlyError('网络连接有问题，请检查网络设置');
      } else if (error.toString().contains('unauthorized')) {
        _showUserFriendlyError('登录已过期，请重新登录');
        // 可能需要引导用户重新登录
      } else if (error.toString().contains('file too large')) {
        _showUserFriendlyError('文件过大，请选择较小的文件');
      } else {
        _showUserFriendlyError('上传失败，请稍后重试');
      }
    }
  }

  void _handleUploadSuccess(UploadResult result) {
    // 处理上传成功的逻辑
    _logger.i('文件上传成功处理', extra: {
      'fileId': result.fileId,
      'remoteUrl': result.remoteUrl,
    });
  }

  void _showUserFriendlyError(String message) {
    // 显示用户友好的错误信息
    _logger.w('用户提示: $message');
  }

  /// 性能优化建议
  void performanceOptimizationTips() {
    _logger.i('''
    === 性能优化建议 ===
    
    1. 本地缓存利用：
       - 新实现会自动将文件保存到本地缓存
       - 可以使用 result.localPath 快速访问本地副本
       - 减少重复下载，提升用户体验
    
    2. 进度反馈：
       - 使用 onProgress 回调提供实时上传进度
       - 大文件上传时特别重要
       - 可以显示进度条或百分比
    
    3. 错误重试：
       - 网络不稳定时自动重试
       - 使用指数退避策略
       - 最大重试次数限制
    
    4. 文件压缩：
       - 图片可以在上传前进行适当压缩
       - 视频可以选择较低的比特率
       - 文档通常不需要压缩
    
    5. 并发控制：
       - 同时上传多个文件时控制并发数量
       - 避免过多并发请求导致网络拥塞
       - 优先级队列处理重要文件
    ''');
  }

  /// 兼容性说明
  void compatibilityNotes() {
    _logger.i('''
    === API兼容性说明 ===
    
    旧API (模拟实现):
    ✗ uploadImage(File file)
    ✗ uploadVoice(File file, int duration)
    ✗ uploadVideo(File file)
    ✗ uploadFile(File file)
    
    新API (真实实现):
    ✓ uploadImage(File file, {String? conversationId, String? caption, Function(int)? onProgress})
    ✓ uploadVoice(File file, int duration, {String? conversationId, Function(int)? onProgress})
    ✓ uploadVideo(File file, {String? conversationId, String? caption, Function(int)? onProgress})
    ✓ uploadFile(File file, {String? conversationId, String? caption, Function(int)? onProgress})
    
    主要变化:
    1. 所有方法都增加了可选的 conversationId 参数
    2. 增加了可选的 caption 参数（除语音外）
    3. 增加了可选的 onProgress 进度回调
    4. UploadResult 增加了 fileId 和 metadata 字段
    5. 需要设置认证token: setAuthToken(token)
    
    迁移策略:
    1. 现有代码基本无需修改（保持向后兼容）
    2. 逐步添加新参数以获得更好的功能
    3. 在登录时设置认证token
    4. 使用新的元数据字段优化用户体验
    ''');
  }
}
