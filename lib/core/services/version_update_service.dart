import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/version_info_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 版本更新检查服务
class VersionUpdateService {
  static final VersionUpdateService _instance = VersionUpdateService._internal();
  static VersionUpdateService get instance => _instance;
  VersionUpdateService._internal();

  final LogService _logger = LogService.instance;
  final VersionInfoService _versionService = VersionInfoService.instance;
  
  static const String _lastCheckKey = 'last_version_check';
  static const Duration _checkInterval = Duration(hours: 24); // 24小时检查一次

  /// 检查是否需要进行版本检查
  Future<bool> shouldCheckVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey);
      
      if (lastCheck == null) return true;
      
      final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
      final now = DateTime.now();
      
      return now.difference(lastCheckTime) > _checkInterval;
    } catch (error) {
      _logger.e('检查版本检查间隔失败', error: error);
      return true;
    }
  }

  /// 检查版本更新
  Future<VersionCheckResult?> checkForUpdate() async {
    try {
      _logger.i('开始检查版本更新');
      
      // 获取API token
      final token = await EnhancedTokenManager.instance.getApiToken();
      if (token == null) {
        _logger.w('无法获取API token，跳过版本检查');
        return null;
      }

      // 构建请求数据
      final clientInfo = _versionService.getClientInfo();
      final requestData = {
        'currentVersion': _versionService.currentVersion,
        'platform': _versionService.platformName,
        'clientInfo': clientInfo,
      };

      // 发送版本检查请求
      final response = await http.post(
        Uri.parse('${AppConfig().serverUrl}/api/version/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = VersionCheckResult.fromJson(data);
        
        _logger.i('版本检查完成', extra: {
          'hasUpdate': result.hasUpdate,
          'latestVersion': result.latestVersion,
          'isForced': result.isForced,
        });

        // 更新最后检查时间
        await _updateLastCheckTime();
        
        return result;
      } else {
        _logger.w('版本检查失败', extra: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        return null;
      }
    } catch (error) {
      _logger.e('版本检查异常', error: error);
      return null;
    }
  }

  /// 更新最后检查时间
  Future<void> _updateLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    } catch (error) {
      _logger.e('更新版本检查时间失败', error: error);
    }
  }

  /// 显示更新对话框
  Future<void> showUpdateDialog(BuildContext context, VersionCheckResult result) async {
    if (!result.hasUpdate) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: !result.isForced,
      builder: (BuildContext context) {
        return PopScope(
          canPop: !result.isForced,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(
                  result.isForced ? Icons.system_update_alt : Icons.info_outline,
                  color: result.isForced ? Colors.orange : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(result.isForced ? '强制更新' : '版本更新'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '发现新版本: ${result.latestVersion}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前版本: ${_versionService.currentVersion}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (result.releaseNotes.isNotEmpty) ...[
                    const Text(
                      '更新内容:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(result.releaseNotes),
                    const SizedBox(height: 16),
                  ],
                  if (result.isForced) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '此版本为强制更新，必须更新后才能继续使用。',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (!result.isForced)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('稍后再说'),
                ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _handleUpdateAction(context, result);
                },
                child: const Text('立即更新'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 处理更新操作
  Future<void> _handleUpdateAction(BuildContext context, VersionCheckResult result) async {
    try {
      Navigator.of(context).pop(); // 关闭更新对话框
      
      String downloadUrl = '';
      
      // 优先使用服务器提供的下载链接
      if (result.downloadUrl.isNotEmpty) {
        downloadUrl = result.downloadUrl;
      } else {
        // 根据平台生成应用商店链接
        if (Platform.isIOS) {
          downloadUrl = 'https://apps.apple.com/app/id123456789'; // 替换为实际的App Store链接
        } else if (Platform.isAndroid) {
          downloadUrl = 'https://play.google.com/store/apps/details?id=${_versionService.packageName}';
        } else {
          // 桌面平台显示提示信息
          if (context.mounted) {
            _showUpdateInfoDialog(context, '当前平台不支持自动更新，请手动下载最新版本');
          }
          return;
        }
      }
      
      // 打开下载链接
      await _openDownloadUrl(context, downloadUrl);
    } catch (error) {
      _logger.e('处理更新操作失败', error: error);
      if (context.mounted) {
        _showErrorDialog(context, '打开下载链接失败: $error');
      }
    }
  }

  /// 打开下载链接
  Future<void> _openDownloadUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 在外部浏览器中打开
        );
        _logger.i('已打开下载链接', extra: {'url': url});
      } else {
        throw '无法打开链接: $url';
      }
    } catch (error) {
      _logger.e('打开下载链接失败', error: error);
      if (context.mounted) {
        _showUpdateInfoDialog(context, '无法自动打开下载链接，请手动复制以下链接到浏览器：\n\n$url');
      }
    }
  }

  /// 显示更新信息对话框（用于错误提示或桌面平台）
  void _showUpdateInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新信息'),
        content: SelectableText(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示错误对话框
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 应用启动时检查更新
  Future<void> checkUpdateOnStartup(BuildContext context) async {
    // 优先检查登录时的版本更新信息
    final loginVersionUpdate = await _checkLoginVersionUpdate();
    if (loginVersionUpdate != null) {
      _logger.i('📱 处理登录时的版本更新信息');
      // 延迟显示对话框，避免影响启动流程
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          showUpdateDialog(context, loginVersionUpdate);
        }
      });
      return;
    }

    // 如果没有登录版本更新信息，执行常规检查
    if (await shouldCheckVersion()) {
      final result = await checkForUpdate();
      if (result != null && result.hasUpdate) {
        // 延迟显示对话框，避免影响启动流程
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            showUpdateDialog(context, result);
          }
        });
      }
    }
  }

  /// 检查登录时的版本更新信息
  Future<VersionCheckResult?> _checkLoginVersionUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versionUpdateString = prefs.getString('pending_version_update');
      
      if (versionUpdateString != null) {
        _logger.i('📱 发现登录时的版本更新信息');
        
        // 清除已保存的版本更新信息
        await prefs.remove('pending_version_update');
        
        // 解析版本更新信息
        final versionUpdateData = jsonDecode(versionUpdateString);
        return VersionCheckResult.fromJson(versionUpdateData);
      }
      
      return null;
    } catch (error) {
      _logger.e('检查登录版本更新信息失败', error: error);
      return null;
    }
  }

  /// 检查并处理登录时的版本更新
  Future<void> checkAndHandleLoginVersionUpdate(BuildContext context) async {
    final loginVersionUpdate = await _checkLoginVersionUpdate();
    if (loginVersionUpdate != null) {
      _logger.i('📱 处理登录时的版本更新信息');
      if (context.mounted) {
        showUpdateDialog(context, loginVersionUpdate);
      }
    }
  }

  /// 模拟登录时的版本更新（测试用）
  Future<void> simulateLoginVersionUpdate(BuildContext context) async {
    try {
      // 模拟服务器返回的版本更新信息
      final testVersionUpdate = VersionCheckResult(
        hasUpdate: true,
        latestVersion: '1.2.0',
        releaseNotes: '• 新增聊天功能\n• 修复已知问题\n• 优化性能表现',
        isForced: false,
        downloadUrl: 'https://example.com/download/app-v1.2.0.apk',
        releaseDate: DateTime.now(),
      );

      // 保存到SharedPreferences模拟登录时的版本更新
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_version_update', jsonEncode(testVersionUpdate.toJson()));

      _logger.i('📱 已模拟登录版本更新信息', extra: {
        'latestVersion': testVersionUpdate.latestVersion,
        'isForced': testVersionUpdate.isForced,
      });

      // 立即检查并显示
      if (context.mounted) {
        await checkAndHandleLoginVersionUpdate(context);
      }
    } catch (error) {
      _logger.e('模拟登录版本更新失败', error: error);
    }
  }

  /// 手动检查更新
  Future<void> manualCheckUpdate(BuildContext context) async {
    // 显示检查中对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在检查更新...'),
          ],
        ),
      ),
    );

    final result = await checkForUpdate();
    
    // 关闭检查中对话框
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (result != null) {
      if (result.hasUpdate) {
        if (context.mounted) {
          showUpdateDialog(context, result);
        }
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('检查更新'),
              content: const Text('当前已是最新版本'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        _showErrorDialog(context, '检查更新失败，请稍后再试');
      }
    }
  }
}

/// 版本检查结果
class VersionCheckResult {
  final bool hasUpdate;
  final String latestVersion;
  final String releaseNotes;
  final bool isForced;
  final String downloadUrl;
  final DateTime releaseDate;

  const VersionCheckResult({
    required this.hasUpdate,
    required this.latestVersion,
    required this.releaseNotes,
    required this.isForced,
    required this.downloadUrl,
    required this.releaseDate,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      hasUpdate: json['hasUpdate'] ?? false,
      latestVersion: json['latestVersion'] ?? '',
      releaseNotes: json['releaseNotes'] ?? '',
      isForced: json['isForced'] ?? false,
      downloadUrl: json['downloadUrl'] ?? '',
      releaseDate: DateTime.tryParse(json['releaseDate'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasUpdate': hasUpdate,
      'latestVersion': latestVersion,
      'releaseNotes': releaseNotes,
      'isForced': isForced,
      'downloadUrl': downloadUrl,
      'releaseDate': releaseDate.toIso8601String(),
    };
  }
}