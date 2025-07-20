import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/file_server_config_service.dart';
import 'package:cc/core/constants/file_server_config.dart';

/// 媒体缓存服务
/// 负责下载网络媒体文件并保存到本地，实现"保存到本地后再使用"的设计原则
/// 支持不同类型的媒体文件：头像、缩略图、图片、视频等
class MediaCacheService {
  final LogService _logger = LogService.instance;
  final FileServerConfigService _fileServerConfig = FileServerConfigService.instance;
  final FileServerConfig _staticConfig = FileServerConfig();
  static final MediaCacheService _instance = MediaCacheService._internal();

  factory MediaCacheService() => _instance;
  MediaCacheService._internal();

  /// 缓存目录映射
  final Map<String, Directory> _cacheDirs = {};
  bool _initialized = false;

  /// 初始化缓存服务
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();

      // 创建不同类型的缓存目录
      final mediaTypes = ['avatars', 'thumbnails', 'images', 'videos', 'voice'];

      for (final type in mediaTypes) {
        final dir = Directory('${appDocDir.path}/media/$type');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
          _logger.i('📁 创建$type缓存目录: ${dir.path}');
        }
        _cacheDirs[type] = dir;
      }

      _initialized = true;
      _logger.i('✅ 媒体缓存服务初始化完成');
    } catch (error) {
      _logger.e('❌ 媒体缓存服务初始化失败', error: error, stackTrace: StackTrace.current);
      throw Exception('媒体缓存服务初始化失败: $error');
    }
  }

  /// 获取媒体文件（优先本地，如果没有则下载）
  /// [mediaUrl] 媒体文件URL
  /// [mediaType] 媒体类型：'avatars', 'thumbnails', 'images', 'videos'
  /// [messageDate] 消息发送日期，用于图片和视频的分层存储
  Future<String?> getMedia(String mediaUrl, String mediaType, {DateTime? messageDate}) async {
    try {
      // 1. 先检查本地缓存
      final cachedPath = await getCachedMediaPath(mediaUrl, mediaType, messageDate: messageDate);
      if (cachedPath != null) {
        return cachedPath;
      }

      // 2. 如果没有缓存，下载并缓存
      return await downloadAndCacheMedia(mediaUrl, mediaType, messageDate: messageDate);
    } catch (error) {
      _logger.e('❌ 获取$mediaType失败',
          error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取媒体文件本地路径（如果已缓存）
  /// [messageDate] 消息发送日期，用于图片和视频的分层存储
  Future<String?> getCachedMediaPath(String mediaUrl, String mediaType, {DateTime? messageDate}) async {
    if (!_initialized) await initialize();

    try {
      final cacheDir = _cacheDirs[mediaType];
      if (cacheDir == null) {
        throw Exception('不支持的媒体类型: $mediaType');
      }

      final fileName = _generateFileName(mediaUrl);
      
      // 对于图片和视频，使用日期分层存储
      if ((mediaType == 'images' || mediaType == 'videos') && messageDate != null) {
        final dateFolder = '${messageDate.year}-${messageDate.month.toString().padLeft(2, '0')}';
        final dateCacheDir = Directory(path.join(cacheDir.path, dateFolder));
        final filePath = path.join(dateCacheDir.path, fileName);
        final file = File(filePath);

        if (await file.exists()) {
          return filePath;
        }
      } else {
        // 头像和缩略图仍使用原格式
        final filePath = path.join(cacheDir.path, fileName);
        final file = File(filePath);

        if (await file.exists()) {
          return filePath;
        }
      }

      return null;
    } catch (error) {
      _logger.w('检查$mediaType缓存失败', stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 下载并缓存媒体文件
  /// [messageDate] 消息发送日期，用于图片和视频的分层存储
  Future<String?> downloadAndCacheMedia(
      String mediaUrl, String mediaType, {DateTime? messageDate}) async {
    if (!_initialized) await initialize();

    try {
      _logger.i('⬇️ 开始下载$mediaType', extra: {'url': mediaUrl});

      // 检查是否已经缓存
      final cachedPath = await getCachedMediaPath(mediaUrl, mediaType, messageDate: messageDate);
      if (cachedPath != null) {
        _logger.d('✅ $mediaType已缓存，直接返回: $cachedPath');
        return cachedPath;
      }

      // 检查并使用正确的文件服务器URL
      final downloadUrl = await _getValidDownloadUrl(mediaUrl);
      
      // 下载媒体文件
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: await _buildRequestHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // 保存到本地
        final cacheDir = _cacheDirs[mediaType]!;
        final fileName = _generateFileName(mediaUrl);
        
        Directory targetDir = cacheDir;
        String filePath;
        
        // 对于图片和视频，使用日期分层存储
        if ((mediaType == 'images' || mediaType == 'videos') && messageDate != null) {
          final dateFolder = '${messageDate.year}-${messageDate.month.toString().padLeft(2, '0')}';
          targetDir = Directory(path.join(cacheDir.path, dateFolder));
          if (!await targetDir.exists()) {
            await targetDir.create(recursive: true);
            _logger.d('📁 创建$mediaType日期缓存目录: ${targetDir.path}');
          }
        }
        
        filePath = path.join(targetDir.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        _logger.i('✅ $mediaType下载并缓存成功', extra: {
          'url': mediaUrl,
          'localPath': filePath,
          'size': '${response.bodyBytes.length} bytes',
        });

        return filePath;
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (error) {
      _logger.w('❌ 下载$mediaType失败', stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 清理过期的缓存文件
  Future<void> cleanupCache(String mediaType, {int maxDays = 30}) async {
    if (!_initialized) await initialize();

    try {
      final cacheDir = _cacheDirs[mediaType];
      if (cacheDir == null) return;

      final now = DateTime.now();
      final files = await cacheDir.list().toList();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified).inDays;

          if (age > maxDays) {
            await entity.delete();
            deletedCount++;
            _logger.d('🗑️ 删除过期$mediaType缓存: ${entity.path} ($age天前)');
          }
        }
      }

      if (deletedCount > 0) {
        _logger.i('🧹 $mediaType缓存清理完成，删除了 $deletedCount 个过期文件');
      }
    } catch (error) {
      _logger.e('❌ $mediaType缓存清理失败',
          error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize(String mediaType) async {
    if (!_initialized) await initialize();

    try {
      final cacheDir = _cacheDirs[mediaType];
      if (cacheDir == null) return 0;

      final files = await cacheDir.list().toList();
      int totalSize = 0;

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (error) {
      _logger.w('获取$mediaType缓存大小失败', stackTrace: StackTrace.current);
      return 0;
    }
  }

  /// 清空所有缓存
  Future<void> clearAllCache(String mediaType) async {
    if (!_initialized) await initialize();

    try {
      final cacheDir = _cacheDirs[mediaType];
      if (cacheDir == null) return;

      final files = await cacheDir.list().toList();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          await entity.delete();
          deletedCount++;
        }
      }

      _logger.i('🗑️ 清空$mediaType缓存完成，删除了 $deletedCount 个文件');
    } catch (error) {
      _logger.e('❌ 清空$mediaType缓存失败',
          error: error, stackTrace: StackTrace.current);
    }
  }

  /// 根据URL生成唯一的文件名（优先服务器nanoid，备用MD5哈希）
  String _generateFileName(String url) {
    // 1. 优先尝试提取服务器nanoid文件名
    final serverFileName = _extractServerFileName(url);
    if (serverFileName != null) {
      return serverFileName;
    }

    // 2. 备用方案：使用URL的MD5哈希作为文件名
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);

    // 尝试从URL中提取文件扩展名
    String extension = '.jpg'; // 默认扩展名
    try {
      final uri = Uri.parse(url);
      final urlPath = uri.path;
      if (urlPath.isNotEmpty) {
        final urlExtension = path.extension(urlPath);
        if (urlExtension.isNotEmpty) {
          extension = urlExtension;
        }
      }
    } catch (e) {
      // 如果解析URL失败，使用默认扩展名
    }

    return '${digest.toString()}$extension';
  }

  /// 基于消息ID获取语音文件（优化版 - 使用日期分层和服务器nanoid）
  /// [messageId] 消息ID 
  /// [mediaUrl] 媒体文件URL
  /// [messageDate] 消息发送日期，用于分层存储
  Future<String?> getVoiceByMessageId(String messageId, String? mediaUrl, {DateTime? messageDate}) async {
    if (!_initialized) await initialize();
    
    try {
      final cacheDir = _cacheDirs['voice'];
      if (cacheDir == null) {
        throw Exception('语音缓存目录未初始化');
      }

      // 使用消息日期创建子目录（格式：2025-01）
      final date = messageDate ?? DateTime.now();
      final dateFolder = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final dateCacheDir = Directory(path.join(cacheDir.path, dateFolder));
      if (!await dateCacheDir.exists()) {
        await dateCacheDir.create(recursive: true);
        _logger.d('📁 创建语音日期缓存目录: ${dateCacheDir.path}');
      }

      // 1. 首先检查基于消息ID的本地文件
      final messageBasedPath = path.join(dateCacheDir.path, '$messageId.m4a');
      final messageBasedFile = File(messageBasedPath);
      if (await messageBasedFile.exists()) {
        _logger.d('✅ 找到基于消息ID的语音缓存: $messageBasedPath');
        return messageBasedPath;
      }

      // 2. 如果没有网络URL，无法下载
      if (mediaUrl == null || mediaUrl.isEmpty) {
        _logger.w('❌ 语音文件无网络URL且无本地缓存: $messageId');
        return null;
      }

      // 3. 从URL中提取服务器nanoid文件名
      final serverFileName = _extractServerFileName(mediaUrl);
      if (serverFileName != null) {
        // 检查是否已经有基于服务器nanoid的缓存文件
        final serverBasedPath = path.join(dateCacheDir.path, serverFileName);
        final serverBasedFile = File(serverBasedPath);
        if (await serverBasedFile.exists()) {
          _logger.d('✅ 找到基于服务器nanoid的语音缓存，创建消息ID软链接');
          
          // 创建消息ID的软链接指向服务器nanoid文件（节省空间）
          try {
            final link = Link(messageBasedPath);
            await link.create(serverBasedPath);
            _logger.i('🔗 创建语音缓存软链接: $messageBasedPath -> $serverBasedPath');
            return messageBasedPath;
          } catch (e) {
            // 如果软链接创建失败，直接复制文件
            await serverBasedFile.copy(messageBasedPath);
            _logger.i('📋 复制语音缓存文件: $messageBasedPath');
            return messageBasedPath;
          }
        }
      }

      // 4. 检查其他月份的旧缓存（使用URL哈希）
      final oldCachedPath = await _findExistingVoiceCache(mediaUrl);
      if (oldCachedPath != null) {
        _logger.d('✅ 找到旧的语音缓存，将移动到新位置');
        
        final oldFile = File(oldCachedPath);
        await oldFile.copy(messageBasedPath);
        _logger.i('📋 语音缓存已迁移到新格式: $messageBasedPath');
        
        return messageBasedPath;
      }

      // 5. 下载并缓存
      _logger.i('⬇️ 开始下载语音文件', extra: {'messageId': messageId, 'url': mediaUrl});
      
      // 检查并使用正确的文件服务器URL
      final downloadUrl = await _getValidDownloadUrl(mediaUrl);
      
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: await _buildRequestHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // 如果能提取到服务器nanoid，优先保存为nanoid文件名
        final finalPath = serverFileName != null 
            ? path.join(dateCacheDir.path, serverFileName)
            : messageBasedPath;
            
        final finalFile = File(finalPath);
        await finalFile.writeAsBytes(response.bodyBytes);
        
        // 如果保存的是nanoid文件名，创建消息ID的链接
        if (serverFileName != null && finalPath != messageBasedPath) {
          try {
            final link = Link(messageBasedPath);
            await link.create(finalPath);
            _logger.i('🔗 创建新下载语音的软链接');
          } catch (e) {
            await finalFile.copy(messageBasedPath);
            _logger.i('📋 复制新下载的语音文件');
          }
        }
        
        _logger.i('✅ 语音文件下载并缓存成功', extra: {
          'messageId': messageId,
          'url': mediaUrl,
          'localPath': messageBasedPath,
          'serverPath': finalPath,
          'size': '${response.bodyBytes.length} bytes',
        });
        return messageBasedPath;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (error) {
      _logger.e('❌ 获取语音文件失败', error: error, extra: {'messageId': messageId, 'url': mediaUrl});
      return null;
    }
  }

  /// 验证并获取有效的下载URL
  /// 使用登录响应中的文件服务器配置来修正URL
  Future<String> _getValidDownloadUrl(String originalUrl) async {
    try {
      // 检查URL是否已经是正确的文件服务器格式
      if (_staticConfig.isValidFileServerUrl(originalUrl)) {
        return originalUrl;
      }
      
      // 尝试从配置服务获取正确的文件服务器URL
      final defaultServerUrl = await _fileServerConfig.getDefaultFileServerUrl();
      if (defaultServerUrl != null) {
        // 解析原始URL的路径部分
        final originalUri = Uri.parse(originalUrl);
        final pathSegments = originalUri.pathSegments;
        
        // 只修正符合文件服务器格式的URL（type/conversationId/date/userId/fileName）
        if (pathSegments.length >= 5) {
          final correctedUrl = '$defaultServerUrl/${pathSegments.join('/')}';
          _logger.i('🔄 修正文件服务器URL', extra: {
            'original': originalUrl,
            'corrected': correctedUrl,
          });
          return correctedUrl;
        }
      }
      
      // 如果无法修正，直接使用原始URL（可能是旧格式或其他有效URL）
      _logger.d('使用原始URL', extra: {'url': originalUrl});
      return originalUrl;
    } catch (error) {
      _logger.e('❌ 验证下载URL失败，使用原始URL', error: error, extra: {'url': originalUrl});
      return originalUrl;
    }
  }

  /// 构建请求头
  Future<Map<String, String>> _buildRequestHeaders() async {
    final headers = {
      'User-Agent': 'CC-Flutter-App/1.0',
    };
    
    // 文件服务器使用无认证下载，不需要添加额外的认证头
    // 但可以在这里添加其他必要的头信息
    
    return headers;
  }

  /// 从URL中提取服务器生成的文件名
  String? _extractServerFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final fileName = path.basename(uri.path);
      
      // 只需要检查是否是有效的文件名（包含扩展名且不包含危险字符）
      if (fileName.isNotEmpty && 
          fileName.contains('.') &&
          !fileName.contains('..') &&
          !fileName.startsWith('.') &&
          fileName.length < 255) {
        _logger.d('🔍 提取到服务器文件名: $fileName');
        return fileName;
      }
    } catch (e) {
      _logger.w('URL解析失败: $url');
    }
    return null;
  }

  /// 查找现有的语音缓存文件（跨月份搜索）
  Future<String?> _findExistingVoiceCache(String mediaUrl) async {
    try {
      final cacheDir = _cacheDirs['voice'];
      if (cacheDir == null) return null;

      // 搜索所有日期子目录
      final entries = await cacheDir.list().toList();
      for (final entry in entries) {
        if (entry is Directory) {
          // 检查基于URL哈希的旧文件
          final urlFileName = _generateFileName(mediaUrl);
          final oldFilePath = path.join(entry.path, urlFileName);
          final oldFile = File(oldFilePath);
          if (await oldFile.exists()) {
            return oldFilePath;
          }
        }
      }
    } catch (e) {
      _logger.w('搜索旧缓存失败: $e');
    }
    return null;
  }

  // 便捷方法，兼容现有代码
  Future<String?> getAvatar(String avatarUrl) => getMedia(avatarUrl, 'avatars');
  Future<String?> getThumbnail(String thumbnailUrl) =>
      getMedia(thumbnailUrl, 'thumbnails');
  Future<String?> getImage(String imageUrl, {DateTime? messageDate}) => 
      getMedia(imageUrl, 'images', messageDate: messageDate);
  Future<String?> getVideo(String videoUrl, {DateTime? messageDate}) => 
      getMedia(videoUrl, 'videos', messageDate: messageDate);
  Future<String?> getVoice(String voiceUrl) => getMedia(voiceUrl, 'voice');
}
