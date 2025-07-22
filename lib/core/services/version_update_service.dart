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
  /// 
  /// 参数:
  /// - requireAuth: 是否需要认证token，默认为false（启动时检查不需要认证）
  Future<VersionCheckResult?> checkForUpdate({bool requireAuth = false}) async {
    try {
      // Web平台无需检查版本更新
      if (_versionService.platformName == 'Web') {
        _logger.i('Web平台无需检查版本更新，跳过检查');
        return null;
      }

      _logger.i('开始检查版本更新', extra: {
        'currentVersion': _versionService.currentVersion,
        'buildNumber': _versionService.buildNumber,
        'platform': _versionService.platformName,
        'packageName': _versionService.packageName,
        'requireAuth': requireAuth,
      });
      
      // 获取API token（如果需要认证）
      String? token;
      if (requireAuth) {
        token = await EnhancedTokenManager.instance.getApiToken();
        if (token == null) {
          _logger.w('无法获取API token，跳过版本检查');
          return null;
        }
      }

      // 构建完整的版本检查请求数据
      final clientInfo = _versionService.getClientInfo();
      final requestData = {
        // 核心版本信息
        'currentVersion': _versionService.currentVersion,
        'buildNumber': _versionService.buildNumber,
        'platform': _versionService.platformName,
        'packageName': _versionService.packageName,
        'appName': _versionService.appName,
        
        // 设备信息
        'deviceInfo': {
          'platform': _versionService.platformName,
          'osVersion': _versionService.deviceInfo?.osVersion ?? 'unknown',
          'model': _versionService.deviceInfo?.model ?? 'unknown',
          'brand': _versionService.deviceInfo?.brand ?? 'unknown',
          'systemName': _versionService.deviceInfo?.systemName ?? 'unknown',
        },
        
        // 完整客户端信息
        'clientInfo': clientInfo,
        
        // 请求时间戳
        'requestTimestamp': DateTime.now().millisecondsSinceEpoch,
        
        // 调试模式标识
        'isDebugMode': _versionService.isDebugMode,
      };

      // 记录请求信息
      final url = '${AppConfig().serverUrl}/api/v1/version/check';
      _logger.i('🌐 发送版本检查请求', extra: {
        'url': url,
        'hasAuth': token != null,
        'requestDataKeys': requestData.keys.toList(),
      });

      // 构建请求头
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // 发送版本检查请求
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestData),
      );

      _logger.i('🌐 版本检查请求响应', extra: {
        'statusCode': response.statusCode,
        'contentLength': response.body.length,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 添加响应数据的详细日志
        _logger.d('版本检查响应数据', extra: {
          'responseData': data,
          'dataTypes': {
            'hasUpdate': data['hasUpdate']?.runtimeType,
            'latestVersion': data['latestVersion']?.runtimeType,
            'releaseNotes': data['releaseNotes']?.runtimeType,
            'isForced': data['isForced']?.runtimeType,
            'downloadUrl': data['downloadUrl']?.runtimeType,
            'releaseDate': data['releaseDate']?.runtimeType,
          }
        });
        
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
      // 如果是强制更新，不关闭对话框，直接打开下载链接
      if (!result.isForced) {
        Navigator.of(context).pop(); // 只有非强制更新才关闭对话框
      }
      
      String downloadUrl = '';
      
      // 只使用服务器提供的下载链接
      if (result.downloadUrl.isNotEmpty) {
        downloadUrl = result.downloadUrl;
      } else {
        // 如果服务器没有提供下载链接，显示错误提示
        if (context.mounted) {
          _showUpdateInfoDialog(context, '服务器未提供下载链接，请联系管理员。');
        }
        return;
      }
      
      // 打开下载链接
      final success = await _openDownloadUrl(context, downloadUrl);
      
      // 如果成功打开下载链接，直接退出程序
      if (success) {
        _logger.i('📱 下载链接已打开，退出程序进行更新');
        exit(0);
      }
    } catch (error) {
      _logger.e('处理更新操作失败', error: error);
      if (context.mounted) {
        _showErrorDialog(context, '打开下载链接失败: $error');
      }
    }
  }

  /// 打开下载链接
  /// 返回true表示成功打开链接，false表示失败
  Future<bool> _openDownloadUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 在外部浏览器中打开
        );
        _logger.i('已打开下载链接', extra: {'url': url});
        return true;
      } else {
        throw '无法打开链接: $url';
      }
    } catch (error) {
      _logger.e('打开下载链接失败', error: error);
      if (context.mounted) {
        _showUpdateInfoDialog(context, '无法自动打开下载链接，请手动复制以下链接到浏览器：\n\n$url');
      }
      return false;
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


  /// 检查是否需要强制更新（登录前调用）
  /// 返回true表示需要强制更新，应阻止登录
  Future<bool> isForceUpdateRequired() async {
    try {
      _logger.i('检查是否需要强制更新');
      
      // 登录前检查不需要认证token
      final result = await checkForUpdate(requireAuth: false);
      if (result != null && result.hasUpdate && result.isForced) {
        _logger.w('检测到强制更新，阻止登录', extra: {
          'currentVersion': _versionService.currentVersion,
          'latestVersion': result.latestVersion,
          'isForced': result.isForced,
        });
        return true;
      }
      
      return false;
    } catch (error) {
      _logger.e('检查强制更新状态失败', error: error);
      return false; // 检查失败时不阻止登录
    }
  }

  /// 显示强制更新对话框并阻止继续操作
  Future<void> showForceUpdateDialog(BuildContext context) async {
    final result = await checkForUpdate(requireAuth: false);
    if (result != null && result.hasUpdate && result.isForced && context.mounted) {
      await showUpdateDialog(context, result);
    }
  }

  /// 应用启动时检查更新
  Future<void> checkUpdateOnStartup(BuildContext context) async {
    _logger.i('🚀 开始启动时版本检查');
    
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
    _logger.i('🔍 检查是否需要进行版本检查');
    final shouldCheck = await shouldCheckVersion();
    _logger.i('🔍 版本检查间隔判断结果: $shouldCheck');
    
    // 启动时强制检查，忽略24小时间隔限制
    _logger.i('🔍 启动时强制执行版本检查');
    
    // if (shouldCheck) { // 注释掉间隔检查，启动时总是检查
      _logger.i('📡 开始执行版本检查请求');
      final result = await checkForUpdate(requireAuth: false); // 启动时检查不需要认证
      _logger.i('📡 版本检查请求完成', extra: {
        'hasResult': result != null,
        'hasUpdate': result?.hasUpdate ?? false,
        'latestVersion': result?.latestVersion ?? 'unknown',
      });
      
      if (result != null && result.hasUpdate) {
        _logger.i('🎯 发现版本更新，准备显示对话框');
        // 延迟显示对话框，避免影响启动流程
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            _logger.i('💬 显示版本更新对话框');
            showUpdateDialog(context, result);
          } else {
            _logger.w('💬 Context已unmounted，取消显示版本更新对话框');
          }
        });
      } else {
        _logger.i('✅ 无版本更新或检查失败');
      }
    // } else {
    //   _logger.i('⏭️ 跳过版本检查（未到检查间隔）');
    // }
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

    final result = await checkForUpdate(requireAuth: true); // 手动检查需要认证
    
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