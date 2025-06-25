import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cc/core/services/log_service.dart';

/// 缩略图缓存服务
/// 负责下载网络缩略图并保存到本地，实现"保存到本地后再使用"的设计原则
class ThumbnailCacheService {
  final LogService _logger = LogService.instance;
  static final ThumbnailCacheService _instance =
      ThumbnailCacheService._internal();

  factory ThumbnailCacheService() => _instance;
  ThumbnailCacheService._internal();

  /// 缓存目录路径
  late final Directory _cacheDir;
  bool _initialized = false;

  /// 初始化缓存服务
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDocDir.path}/media/thumbnails');

      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
        _logger.i('📁 创建缩略图缓存目录: ${_cacheDir.path}');
      }

      _initialized = true;
      _logger.i('✅ 缩略图缓存服务初始化完成');
    } catch (error) {
      _logger.e('❌ 缩略图缓存服务初始化失败', error: error, stackTrace: StackTrace.current);
      throw Exception('缩略图缓存服务初始化失败: $error');
    }
  }

  /// 获取缩略图本地路径（如果已缓存）
  /// 如果没有缓存，返回null
  Future<String?> getCachedThumbnailPath(String thumbnailUrl) async {
    if (!_initialized) await initialize();

    try {
      final fileName = _generateFileName(thumbnailUrl);
      final filePath = path.join(_cacheDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        // _logger.d('🎯 找到缓存的缩略图: $filePath');
        return filePath;
      }

      return null;
    } catch (error) {
      _logger.w('检查缓存失败', stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 下载并缓存缩略图
  /// 返回本地文件路径
  Future<String?> downloadAndCacheThumbnail(String thumbnailUrl) async {
    if (!_initialized) await initialize();

    try {
      _logger.i('⬇️ 开始下载缩略图', extra: {'url': thumbnailUrl});

      // 检查是否已经缓存
      final cachedPath = await getCachedThumbnailPath(thumbnailUrl);
      if (cachedPath != null) {
        _logger.d('✅ 缩略图已缓存，直接返回: $cachedPath');
        return cachedPath;
      }

      // 下载缩略图
      final response = await http.get(
        Uri.parse(thumbnailUrl),
        headers: {
          'User-Agent': 'CC-Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // 保存到本地
        final fileName = _generateFileName(thumbnailUrl);
        final filePath = path.join(_cacheDir.path, fileName);
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        _logger.i('✅ 缩略图下载并缓存成功', extra: {
          'url': thumbnailUrl,
          'localPath': filePath,
          'size': '${response.bodyBytes.length} bytes',
        });

        return filePath;
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (error) {
      _logger
          .e('❌ 下载缩略图失败', error: error, stackTrace: StackTrace.current, extra: {
        'url': thumbnailUrl,
      });
      return null;
    }
  }

  /// 获取缩略图（优先本地，如果没有则下载）
  /// 这是主要的对外接口
  Future<String?> getThumbnail(String thumbnailUrl) async {
    try {
      // 1. 先检查本地缓存
      final cachedPath = await getCachedThumbnailPath(thumbnailUrl);
      if (cachedPath != null) {
        return cachedPath;
      }

      // 2. 如果没有缓存，下载并缓存
      return await downloadAndCacheThumbnail(thumbnailUrl);
    } catch (error) {
      _logger.e('❌ 获取缩略图失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 清理过期的缓存文件
  /// 删除超过指定天数的缓存文件
  Future<void> cleanupCache({int maxDays = 30}) async {
    if (!_initialized) await initialize();

    try {
      final now = DateTime.now();
      final files = await _cacheDir.list().toList();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified).inDays;

          if (age > maxDays) {
            await entity.delete();
            deletedCount++;
            _logger.d('🗑️ 删除过期缓存: ${entity.path} ($age天前)');
          }
        }
      }

      if (deletedCount > 0) {
        _logger.i('🧹 缓存清理完成，删除了 $deletedCount 个过期文件');
      }
    } catch (error) {
      _logger.e('❌ 缓存清理失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize() async {
    if (!_initialized) await initialize();

    try {
      final files = await _cacheDir.list().toList();
      int totalSize = 0;

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (error) {
      _logger.w('获取缓存大小失败', stackTrace: StackTrace.current);
      return 0;
    }
  }

  /// 清空所有缓存
  Future<void> clearAllCache() async {
    if (!_initialized) await initialize();

    try {
      final files = await _cacheDir.list().toList();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          await entity.delete();
          deletedCount++;
        }
      }

      _logger.i('🗑️ 清空缓存完成，删除了 $deletedCount 个文件');
    } catch (error) {
      _logger.e('❌ 清空缓存失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 根据URL生成唯一的文件名
  String _generateFileName(String url) {
    // 使用URL的MD5哈希作为文件名，确保唯一性
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
}
