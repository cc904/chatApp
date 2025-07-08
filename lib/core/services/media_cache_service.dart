import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cc/core/services/log_service.dart';

/// 媒体缓存服务
/// 负责下载网络媒体文件并保存到本地，实现"保存到本地后再使用"的设计原则
/// 支持不同类型的媒体文件：头像、缩略图、图片、视频等
class MediaCacheService {
  final LogService _logger = LogService.instance;
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
      final mediaTypes = ['avatars', 'thumbnails', 'images', 'videos'];

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
  Future<String?> getMedia(String mediaUrl, String mediaType) async {
    try {
      // 1. 先检查本地缓存
      final cachedPath = await getCachedMediaPath(mediaUrl, mediaType);
      if (cachedPath != null) {
        return cachedPath;
      }

      // 2. 如果没有缓存，下载并缓存
      return await downloadAndCacheMedia(mediaUrl, mediaType);
    } catch (error) {
      _logger.e('❌ 获取$mediaType失败',
          error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取媒体文件本地路径（如果已缓存）
  Future<String?> getCachedMediaPath(String mediaUrl, String mediaType) async {
    if (!_initialized) await initialize();

    try {
      final cacheDir = _cacheDirs[mediaType];
      if (cacheDir == null) {
        throw Exception('不支持的媒体类型: $mediaType');
      }

      final fileName = _generateFileName(mediaUrl);
      final filePath = path.join(cacheDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      return null;
    } catch (error) {
      _logger.w('检查$mediaType缓存失败', stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 下载并缓存媒体文件
  Future<String?> downloadAndCacheMedia(
      String mediaUrl, String mediaType) async {
    if (!_initialized) await initialize();

    try {
      _logger.i('⬇️ 开始下载$mediaType', extra: {'url': mediaUrl});

      // 检查是否已经缓存
      final cachedPath = await getCachedMediaPath(mediaUrl, mediaType);
      if (cachedPath != null) {
        _logger.d('✅ $mediaType已缓存，直接返回: $cachedPath');
        return cachedPath;
      }

      // 下载媒体文件
      final response = await http.get(
        Uri.parse(mediaUrl),
        headers: {
          'User-Agent': 'CC-Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // 保存到本地
        final cacheDir = _cacheDirs[mediaType]!;
        final fileName = _generateFileName(mediaUrl);
        final filePath = path.join(cacheDir.path, fileName);
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
      _logger.e('❌ 下载$mediaType失败',
          error: error,
          stackTrace: StackTrace.current,
          extra: {
            'url': mediaUrl,
          });
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

  /// 根据URL生成唯一的文件名
  String _generateFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final urlPath = uri.path;

      if (urlPath.isNotEmpty) {
        // 尝试从URL路径中提取原始文件名（包含服务器的UUID）
        final fileName = path.basename(urlPath);

        // 验证文件名是否合法（不包含特殊字符）
        if (fileName.isNotEmpty &&
            !fileName.contains('..') &&
            !fileName.startsWith('.') &&
            fileName.length < 255) {
          return fileName;
        }
      }
    } catch (e) {
      // URL解析失败，使用备用方案
    }

    // 备用方案：使用URL的MD5哈希作为文件名，确保唯一性
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

  // 便捷方法，兼容现有代码
  Future<String?> getAvatar(String avatarUrl) => getMedia(avatarUrl, 'avatars');
  Future<String?> getThumbnail(String thumbnailUrl) =>
      getMedia(thumbnailUrl, 'thumbnails');
  Future<String?> getImage(String imageUrl) => getMedia(imageUrl, 'images');
  Future<String?> getVideo(String videoUrl) => getMedia(videoUrl, 'videos');
}
