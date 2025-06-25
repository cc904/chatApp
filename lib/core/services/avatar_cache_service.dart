import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cc/core/services/log_service.dart';

/// 头像缓存服务
/// 负责下载网络头像并保存到本地，实现"保存到本地后再使用"的设计原则
class AvatarCacheService {
  final LogService _logger = LogService.instance;
  static final AvatarCacheService _instance = AvatarCacheService._internal();

  factory AvatarCacheService() => _instance;
  AvatarCacheService._internal();

  /// 缓存目录路径
  late final Directory _cacheDir;
  bool _initialized = false;

  /// 初始化缓存服务
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDocDir.path}/media/avatars');

      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
        _logger.i('📁 创建头像缓存目录: ${_cacheDir.path}');
      }

      _initialized = true;
      _logger.i('✅ 头像缓存服务初始化完成');
    } catch (error) {
      _logger.e('❌ 头像缓存服务初始化失败', error: error, stackTrace: StackTrace.current);
      throw Exception('头像缓存服务初始化失败: $error');
    }
  }

  /// 获取头像（优先本地，如果没有则下载）
  /// 这是主要的对外接口
  Future<String?> getAvatar(String avatarUrl) async {
    try {
      // 1. 先检查本地缓存
      final cachedPath = await getCachedAvatarPath(avatarUrl);
      if (cachedPath != null) {
        return cachedPath;
      }

      // 2. 如果没有缓存，下载并缓存
      return await downloadAndCacheAvatar(avatarUrl);
    } catch (error) {
      _logger.e('❌ 获取头像失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取头像本地路径（如果已缓存）
  Future<String?> getCachedAvatarPath(String avatarUrl) async {
    if (!_initialized) await initialize();

    try {
      final fileName = _generateFileName(avatarUrl);
      final filePath = path.join(_cacheDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      return null;
    } catch (error) {
      _logger.w('检查头像缓存失败', stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 下载并缓存头像
  Future<String?> downloadAndCacheAvatar(String avatarUrl) async {
    if (!_initialized) await initialize();

    try {
      _logger.i('⬇️ 开始下载头像', extra: {'url': avatarUrl});

      // 检查是否已经缓存
      final cachedPath = await getCachedAvatarPath(avatarUrl);
      if (cachedPath != null) {
        _logger.d('✅ 头像已缓存，直接返回: $cachedPath');
        return cachedPath;
      }

      // 下载头像
      final response = await http.get(
        Uri.parse(avatarUrl),
        headers: {
          'User-Agent': 'CC-Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // 保存到本地
        final fileName = _generateFileName(avatarUrl);
        final filePath = path.join(_cacheDir.path, fileName);
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        _logger.i('✅ 头像下载并缓存成功', extra: {
          'url': avatarUrl,
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
          .e('❌ 下载头像失败', error: error, stackTrace: StackTrace.current, extra: {
        'url': avatarUrl,
      });
      return null;
    }
  }

  /// 根据URL生成唯一的文件名
  /// 优先提取服务器的UUID文件名，如果失败则使用MD5哈希
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
}
