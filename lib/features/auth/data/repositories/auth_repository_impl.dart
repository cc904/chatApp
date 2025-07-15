import 'dart:async';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/enhanced_api_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/services/device_manager.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:cc/core/utils/api_error_handler.dart';
import 'package:cc/core/services/version_info_service.dart';
import 'package:cc/core/services/version_update_service.dart';

/// AuthRepository的实现类
/// 负责认证相关的业务逻辑，支持多设备登录和新Token管理

class AuthRepositoryImpl implements AuthRepository {
  final LogService _logger = LogService.instance;
  final EnhancedApiService _apiService = EnhancedApiService.instance;
  final EnhancedTokenManager _tokenManager = EnhancedTokenManager.instance;
  final SecureStorageService _secureStorage = SecureStorageService();

  // 服务器URL
  final String _serverUrl;

  // 存储认证状态
  bool _isInitialized = false;

  // 单例实例和对应的服务器URL
  static AuthRepositoryImpl? _instance;
  static String? _currentServerUrl;

  // 工厂方法，获取单例实例
  static AuthRepositoryImpl getInstance({required String serverUrl}) {
    // 如果服务器URL发生变化，重新创建实例
    if (_instance == null || _currentServerUrl != serverUrl) {
      _instance = AuthRepositoryImpl(serverUrl: serverUrl);
      _currentServerUrl = serverUrl;
      // 重置初始化状态，确保新实例会重新初始化
      _instance!._isInitialized = false;
    }
    return _instance!;
  }

  // 构造函数
  AuthRepositoryImpl({
    required String serverUrl,
  }) : _serverUrl = serverUrl;

  /// 初始化仓库
  @override
  Future<void> init() async {
    if (_isInitialized) {
      _logger.i('AuthRepository已经初始化，跳过重复初始化');
      return;
    }

    try {
      _logger.i('🚀 初始化AuthRepository (多设备模式)');

      // 设置API基础URL
      _apiService.setBaseUrl(_serverUrl);

      // 更新TokenManager的基础URL
      _tokenManager.updateBaseUrl(_serverUrl);

      // 初始化设备管理器
      final deviceId = await DeviceManager.getDeviceId();
      _logger.i('📱 设备ID已生成', extra: {'deviceId': deviceId});

      // Token管理器无需初始化，它是静态的

      _isInitialized = true;
      _logger.i('✅ AuthRepository初始化完成');
    } catch (error) {
      _logger.e('AuthRepository初始化失败',
          error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// 优先从数据库获取用户信息，如果数据库中没有则从安全存储获取
  @override
  Future<CurrentUser?> getCurrentUser() async {
    try {
      // 1. 优先从数据库获取完整用户信息
      if (DatabaseInitializer.isInitialized) {
        final collection = DatabaseInitializer.isar.currentUsers;
        final allUsers = await collection.where().findAll();
        if (allUsers.isNotEmpty) {
          final user = allUsers.first;
          _logger.d('从数据库获取用户信息成功', extra: {'userId': user.userId});
          return user;
        }
      }

      // 2. 如果数据库中没有，从安全存储获取基本信息
      final fullUserInfo = await _secureStorage.readUserCredentials();
      if (fullUserInfo != null) {
        _logger.d('从安全存储获取用户信息成功', extra: {'userId': fullUserInfo.userId});

        // 同时保存到数据库中以备下次使用
        if (DatabaseInitializer.isInitialized) {
          await DatabaseInitializer.isar.writeTxn(() async {
            await DatabaseInitializer.isar.currentUsers.put(fullUserInfo);
          });
        }

        return fullUserInfo;
      }

      _logger.d('未找到用户信息');
      return null;
    } catch (error) {
      _logger.e('获取用户信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 使用密码登录
  @override
  Future<Map<String, dynamic>> loginWithPassword(
      String username, String password) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (username.isEmpty) {
        throw Exception('请输入手机号码');
      }
      if (password.isEmpty) {
        throw Exception('请输入密码');
      }

      _logger.i('🔐 密码登录', extra: {'username': username});

      // 获取设备信息
      final deviceInfo = await DeviceManager.getDeviceInfo();
      
      // 获取客户端版本信息
      final clientInfo = VersionInfoService.instance.getClientInfo();

      // 发送登录请求
      final response = await _apiService.post('/api/v1/auth/login',
          data: {
            'phone': username, // 修复：使用统一的字段名 'phone'
            'password': password,
            'loginType': 'password',
            'device': {
              'deviceId': deviceInfo.deviceId,
              'deviceType': deviceInfo.deviceType,
              'deviceModel': deviceInfo.deviceModel,
              'osVersion': deviceInfo.osVersion,
              'appVersion': deviceInfo.appVersion,
            },
            'clientInfo': clientInfo, // 添加客户端版本信息
          },
          attachToken: false);

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? '登录失败');
      }

      // 保存Token和用户信息
      await _saveLoginResponse(data);

      _logger.i('✅ 密码登录成功');
      return data;
    } catch (error) {
      _logger.e('密码登录失败', error: error, stackTrace: StackTrace.current);
      // 使用统一的错误处理器提取错误信息
      final errorMessage = ApiErrorHandler.extractErrorMessage(error);
      throw Exception(errorMessage);
    }
  }

  /// 使用验证码登录
  @override
  Future<Map<String, dynamic>> loginWithCode(
      String username, String code) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (username.isEmpty) {
        throw Exception('请输入手机号码');
      }
      if (code.isEmpty) {
        throw Exception('请输入验证码');
      }

      _logger.i('📱 验证码登录', extra: {'username': username});

      // 获取设备信息
      final deviceInfo = await DeviceManager.getDeviceInfo();
      
      // 获取客户端版本信息
      final clientInfo = VersionInfoService.instance.getClientInfo();

      // 发送登录请求
      final response = await _apiService.post('/api/v1/auth/login',
          data: {
            'phone': username, // 修复：使用统一的字段名 'phone'
            'verificationCode': code,
            'loginType': 'code',
            'device': {
              'deviceId': deviceInfo.deviceId,
              'deviceType': deviceInfo.deviceType,
              'deviceModel': deviceInfo.deviceModel,
              'osVersion': deviceInfo.osVersion,
              'appVersion': deviceInfo.appVersion,
            },
            'clientInfo': clientInfo, // 添加客户端版本信息
          },
          attachToken: false);

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? '登录失败');
      }

      // 保存Token和用户信息
      await _saveLoginResponse(data);

      _logger.i('✅ 验证码登录成功');
      return data;
    } catch (error) {
      _logger.e('验证码登录失败', error: error, stackTrace: StackTrace.current);
      // 使用统一的错误处理器提取错误信息
      final errorMessage = ApiErrorHandler.extractErrorMessage(error);
      throw Exception(errorMessage);
    }
  }

  /// 使用令牌登录
  @override
  Future<Map<String, dynamic>> loginWithToken() async {
    try {
      await _ensureInitialized();

      // 检查是否有可用的Token（自动处理过期刷新）
      final bestToken = await _tokenManager.getApiToken();
      if (bestToken == null) {
        throw Exception('没有可用的认证令牌');
      }

      _logger.i('🎫 Token登录');

      // 获取客户端版本信息
      final clientInfo = VersionInfoService.instance.getClientInfo();

      // 验证Token
      final response = await _apiService.post('/api/v1/auth/verifyToken',
          data: {
            'token': bestToken,
            'clientInfo': clientInfo, // 添加客户端版本信息
          }, requireAuth: true);

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Token验证失败');
      }

      // 🔧 修复：Token登录成功后也需要保存用户信息
      await _saveLoginResponse(data);

      _logger.i('✅ Token登录成功');
      return data;
    } catch (error) {
      _logger.e('Token登录失败', error: error, stackTrace: StackTrace.current);
      // 使用统一的错误处理器提取错误信息
      final errorMessage = ApiErrorHandler.extractErrorMessage(error);
      throw Exception(errorMessage);
    }
  }

  /// 注册
  @override
  Future<Map<String, dynamic>> register(String username, String password,
      String verificationCode, String name) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (username.isEmpty) throw Exception('请输入手机号码');
      if (password.isEmpty) throw Exception('请输入密码');
      if (verificationCode.isEmpty) throw Exception('请输入验证码');
      if (name.isEmpty) throw Exception('请输入昵称');

      _logger.i('📝 用户注册', extra: {'username': username, 'name': name});

      // 获取设备信息
      final deviceInfo = await DeviceManager.getDeviceInfo();
      
      // 获取客户端版本信息
      final clientInfo = VersionInfoService.instance.getClientInfo();

      // 发送注册请求
      final response = await _apiService.post(
        '/api/v1/auth/register',
        data: {
          'phone': username, // 修复：使用统一的字段名 'phone'
          'password': password,
          'verificationCode': verificationCode,
          'name': name, // 修复：使用正确的字段名 'name'
          'device': {
            'deviceId': deviceInfo.deviceId,
            'deviceType': deviceInfo.deviceType,
            'deviceModel': deviceInfo.deviceModel,
            'osVersion': deviceInfo.osVersion,
            'appVersion': deviceInfo.appVersion,
          },
          'clientInfo': clientInfo, // 添加客户端版本信息
        },
        attachToken: false, // 注册不需要token认证
      );

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? '注册失败');
      }

      // 保存Token和用户信息
      await _saveLoginResponse(data);

      _logger.i('✅ 用户注册成功');
      return data;
    } catch (error) {
      _logger.e('用户注册失败', error: error, stackTrace: StackTrace.current);
      // 使用统一的错误处理器提取错误信息
      final errorMessage = ApiErrorHandler.extractErrorMessage(error);
      throw Exception(errorMessage);
    }
  }

  /// 保存登录响应
  Future<void> _saveLoginResponse(Map<String, dynamic> response) async {
    try {
      // 🔍 添加详细的响应数据日志，帮助诊断字段映射问题
      _logger.i('🔍 登录响应详情', extra: {
        'responseKeys': response.keys.toList(),
        'hasCurrentUser': response.containsKey('currentUser'),
        'hasUser': response.containsKey('user'),
        'hasTokens': response.containsKey('tokens'),
        'hasVersionUpdate': response.containsKey('versionUpdate'),
      });

      // 🔄 检查是否有版本更新信息
      await _handleVersionUpdateFromLogin(response);

      // 保存Token信息
      await _tokenManager.saveLoginTokens(response);

      // 提取用户信息 - 改进字段映射逻辑
      final userData = response['currentUser'] ?? response['user'];
      if (userData != null) {
        _logger.i('📋 用户数据详情', extra: {
          'userDataKeys': userData.keys.toList(),
          'userId': userData['userId'],
          'nickname': userData['nickname'],
          'name': userData['name'],
          'phone': userData['phone'],
          'email': userData['email'],
          'avatar': userData['avatar'],
          'status': userData['status'],
          'lastLoginTime': userData['lastLoginTime'],
        });

        // 创建CurrentUser对象，确保所有字段都有合适的默认值
        final currentUser = CurrentUser()
          ..userId = userData['userId']?.toString() ?? ''
          ..name = userData['nickname']?.toString() ??
              userData['name']?.toString() ??
              userData['username']?.toString() ??
              '用户${userData['userId']?.toString().substring(0, 6) ?? 'Unknown'}'
          ..phone = userData['phone']?.toString() ?? ''
          ..email = userData['email']?.toString() ?? ''
          ..avatar = userData['avatar']?.toString() ?? ''
          ..status = userData['status']?.toString() ?? 'offline'
          ..lastLoginTime = userData['lastLoginTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(userData['lastLoginTime'])
              : DateTime.now();

        // 🔍 记录最终创建的用户对象
        _logger.i('👤 创建的CurrentUser对象', extra: {
          'userId': currentUser.userId,
          'name': currentUser.name,
          'phone': currentUser.phone,
          'email': currentUser.email,
          'avatar': currentUser.avatar,
          'status': currentUser.status,
          'lastLoginTime': currentUser.lastLoginTime?.toIso8601String(),
        });

        // 保存到安全存储
        await _secureStorage.saveUserCredentials(currentUser);

        // 保存到数据库
        if (DatabaseInitializer.isInitialized) {
          await DatabaseInitializer.isar.writeTxn(() async {
            await DatabaseInitializer.isar.currentUsers.clear();
            await DatabaseInitializer.isar.currentUsers.put(currentUser);
          });
        }

        // 用户ID保存在CurrentUser对象中，不需要单独存储
      } else {
        _logger.w('⚠️ 登录响应中没有找到用户数据');
      }

      // Token管理已在saveLoginTokens中启动，无需重复启动

      _logger.i('💾 登录信息保存完成');
    } catch (error) {
      _logger.e('保存登录信息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 登出
  @override
  Future<bool> logout() async {
    try {
      _logger.i('🚪 用户登出');

      // 停止Token管理
      _tokenManager.stopTokenManagement();

      // 清除所有Token
      await _secureStorage.clearAllTokens();

      // 清除用户凭证
      await _secureStorage.clearUserCredentials();

      // 清除数据库中的用户信息
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.isar.writeTxn(() async {
          await DatabaseInitializer.isar.currentUsers.clear();
        });
      }

      // 用户信息已在数据库中清除，不需要单独管理ID

      _logger.i('✅ 用户登出完成');
      return true;
    } catch (error) {
      _logger.e('用户登出失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 检查是否已登录
  @override
  Future<bool> isLoggedIn() async {
    try {
      final userId = await _secureStorage.read('user_id');
      final hasValidToken = await _secureStorage.isAccessTokenValid() ||
          await _secureStorage.isRefreshTokenValid();

      return userId != null && userId.isNotEmpty && hasValidToken;
    } catch (error) {
      _logger.e('检查登录状态失败', error: error);
      return false;
    }
  }

  /// 重置密码
  @override
  Future<bool> resetPassword(
      String phoneOrEmail, String code, String newPassword) async {
    try {
      await _ensureInitialized();

      _logger.i('🔄 重置密码', extra: {'phoneOrEmail': phoneOrEmail});

      final response = await _apiService.post(
        '/api/v1/auth/resetPassword',
        data: {
          'phone': phoneOrEmail, // 修复：使用正确的字段名 'phone'
          'code': code, // 修复：使用正确的字段名 'code'
          'newPassword': newPassword,
        },
        attachToken: false, // 重置密码不需要token认证
      );

      final data = response.data;
      return data['success'] == true;
    } catch (error) {
      _logger.e('重置密码失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 发送验证码
  @override
  Future<bool> sendVerificationCode(String phoneOrEmail, String type) async {
    try {
      await _ensureInitialized();

      _logger
          .i('📨 发送验证码', extra: {'phoneOrEmail': phoneOrEmail, 'type': type});

      final response = await _apiService.post(
        '/api/v1/auth/sendCode',
        data: {
          'phone': phoneOrEmail, // 修复：使用正确的字段名 'phone'
          'purpose': type,
        },
        attachToken: false, // 发送验证码不需要token认证
      );

      final data = response.data;
      return data['success'] == true;
    } catch (error) {
      _logger.e('发送验证码失败', error: error, stackTrace: StackTrace.current);
      // 使用统一的错误处理器提取错误信息
      final errorMessage = ApiErrorHandler.extractErrorMessage(error);
      throw errorMessage;
    }
  }

  /// 验证验证码
  @override
  Future<bool> verifyCode(String phoneOrEmail, String code) async {
    try {
      await _ensureInitialized();

      _logger.i('✅ 验证验证码', extra: {'phoneOrEmail': phoneOrEmail});

      // TODO: 实现验证码验证API，当前直接返回成功
      return true;
    } catch (error) {
      _logger.e('验证验证码失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 刷新Token
  @override
  Future<String?> refreshToken() async {
    try {
      await _ensureInitialized();

      _logger.i('🔄 刷新Token');

      // 尝试刷新Token
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      // 调用刷新Token API
      final response = await _apiService.post('/api/v1/auth/refreshToken',
          data: {'refreshToken': refreshToken});

      final data = response.data;
      if (data['success'] == true && data['tokens'] != null) {
        // 保存新Token
        await _tokenManager.saveLoginTokens(data);
        return data['tokens']['accessToken'];
      }

      return null;
    } catch (error) {
      _logger.e('刷新Token失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 删除账户
  @override
  Future<bool> deleteAccount() async {
    try {
      await _ensureInitialized();

      _logger.i('🗑️ 删除账户');

      final response = await _apiService.delete('/api/v1/auth/deleteAccount',
          requireAuth: true);

      final data = response.data;
      if (data['success'] == true) {
        // 删除成功后清除本地数据
        await logout();
        return true;
      }

      return false;
    } catch (error) {
      _logger.e('删除账户失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 处理登录时的版本更新信息
  Future<void> _handleVersionUpdateFromLogin(Map<String, dynamic> response) async {
    try {
      final versionUpdateData = response['versionUpdate'];
      if (versionUpdateData != null) {
        _logger.i('📱 登录时检测到版本更新信息', extra: {
          'versionUpdateData': versionUpdateData,
        });

        // 创建版本检查结果对象
        final versionResult = VersionCheckResult.fromJson(versionUpdateData);
        
        if (versionResult.hasUpdate) {
          _logger.i('🔄 服务器要求版本更新', extra: {
            'currentVersion': VersionInfoService.instance.currentVersion,
            'latestVersion': versionResult.latestVersion,
            'isForced': versionResult.isForced,
          });

          // 保存版本更新信息，延迟显示对话框
          await _scheduleVersionUpdateDialog(versionResult);
        }
      }
    } catch (error) {
      _logger.e('处理登录版本更新信息失败', error: error, stackTrace: StackTrace.current);
      // 版本更新处理失败不影响登录流程
    }
  }

  /// 计划显示版本更新对话框
  Future<void> _scheduleVersionUpdateDialog(VersionCheckResult versionResult) async {
    try {
      // 使用SharedPreferences存储版本更新信息
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_version_update', jsonEncode(versionResult.toJson()));
      
      _logger.i('📅 已计划版本更新对话框', extra: {
        'latestVersion': versionResult.latestVersion,
        'isForced': versionResult.isForced,
      });
    } catch (error) {
      _logger.e('计划版本更新对话框失败', error: error);
    }
  }
}
