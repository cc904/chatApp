import 'dart:async';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/enhanced_api_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/services/device_manager.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:dio/dio.dart';

import 'package:cc/core/utils/api_error_handler.dart';
import 'package:cc/core/services/version_info_service.dart';
import 'package:cc/core/services/file_server_config_service.dart';
import 'package:cc/core/services/server_selection_service.dart';
import 'package:cc/core/database/current_user_builder.dart';

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
      _logger.e('AuthRepository初始化失败', error: error, stackTrace: StackTrace.current);
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
        final allUsers = await DatabaseInitializer.database
            .select(DatabaseInitializer.database.currentUsers)
            .get();
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
          await DatabaseInitializer.database.transaction(() async {
            await DatabaseInitializer.database
                .into(DatabaseInitializer.database.currentUsers)
                .insert(fullUserInfo);
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
  Future<Map<String, dynamic>> loginWithPassword(String username, String password) async {
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
      _logger.d('开始保存登录信息');
      await _saveLoginResponse(data);

      _logger.i('密码登录成功');
      return data;
    } catch (error) {
      _logger.e('密码登录失败', error: error, stackTrace: StackTrace.current);
      // 使用统一的错误处理器提取错误信息
      final errorMessage = ApiErrorHandler.extractErrorMessage(error);
      throw Exception(errorMessage);
    }
  }

  /// 使用验证码登录用户账户
  ///
  /// 该函数通过手机号和验证码完成用户身份验证，并处理登录后的相关配置。
  /// 包含设备信息收集、版本检查、Token保存等完整登录流程。
  ///
  /// [username] 用户的手机号码，用于身份验证
  /// [code] 短信验证码，用于验证用户身份
  ///
  /// 返回包含用户信息和登录状态的Map对象，结构如下：
  /// ```json
  /// {
  ///   "success": true,
  ///   "token": "用户访问令牌",
  ///   "refreshToken": "刷新令牌",
  ///   "currentUser": {
  ///     "userId": "用户ID",
  ///     "nickname": "用户昵称",
  ///     "phone": "手机号"
  ///   }
  /// }
  /// ```
  ///
  /// 抛出异常：
  /// - [Exception] 当手机号或验证码为空时
  /// - [DioException] 当网络请求失败时
  /// - [FormatException] 当响应格式无效时
  @override
  Future<Map<String, dynamic>> loginWithCode(String username, String code) async {
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
      _logger.d('开始保存登录信息');
      await _saveLoginResponse(data);

      _logger.i('验证码登录成功');
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
      _logger.d('开始Token登录流程');
      final bestToken = await _tokenManager.getApiToken();
      if (bestToken == null) {
        _logger.w('没有可用的认证令牌');
        throw Exception('没有可用的认证令牌');
      }

      _logger.d('获得可用Token，准备验证', extra: {
        'tokenLength': bestToken.length,
      });

      // 获取设备信息
      final deviceInfo = await DeviceManager.getDeviceInfo();

      // 获取客户端版本信息
      final versionInfo = VersionInfoService.instance;

      // 构建符合新接口规范的请求数据
      final requestData = {
        'token': bestToken, // 使用refresh token
        'autoRefresh': true, // 启用自动刷新功能
        'clientInfo': {
          'version': versionInfo.currentVersion,
          'buildNumber': versionInfo.buildNumber,
          'platform': versionInfo.platformName,
          'deviceInfo': {
            'deviceId': deviceInfo.deviceId,
            'deviceName': deviceInfo.deviceModel, // 使用设备型号作为设备名称
            'systemVersion': deviceInfo.osVersion,
            'deviceModel': deviceInfo.deviceModel,
          }
        }
      };

      // 验证Token - 不需要附加认证头，token在请求体中
      _logger.d('发送Token验证请求', extra: {
        'endpoint': '/api/v1/auth/verifyToken',
        'tokenPresent': requestData.containsKey('token'),
        'autoRefresh': requestData['autoRefresh'],
      });
      final response = await _apiService.post('/api/v1/auth/verifyToken', data: requestData, attachToken: false);

      final data = response.data;
      _logger.d('收到Token验证响应', extra: {
        'success': data['success'],
        'hasTokens': data.containsKey('tokens'),
        'hasCurrentUser': data.containsKey('currentUser'),
        'hasUser': data.containsKey('user'),
      });
      
      if (data['success'] != true) {
        _logger.w('Token验证失败', extra: {
          'message': data['message'],
          'success': data['success'],
        });
        throw Exception(data['message'] ?? 'Token验证失败');
      }

      // 检查是否有新的token返回（自动刷新的结果）
      if (data['tokens'] != null) {
        _logger.d('服务器返回了新的Token，更新本地存储');
        await _tokenManager.saveLoginTokens(data);
      }

      // 修复：Token登录成功后也需要保存用户信息
      _logger.d('开始保存登录信息');
      await _saveLoginResponse(data);

      _logger.i('Token登录成功');
      return data;
    } catch (error) {
      // 检查是否是401认证失败（token过期/无效）
      if (error is DioException && error.response?.statusCode == 401) {
        _logger.i('🔐 Token已过期或无效，需要重新登录', extra: {
          'statusCode': 401,
          'endpoint': '/api/v1/auth/verifyToken',
        });
        throw Exception('认证令牌已过期，请重新登录');
      } else {
        // 其他错误正常记录
        _logger.e('Token登录失败', error: error, stackTrace: StackTrace.current);
      }
      
      // 使用统一的错误处理器提取错误信息
      final errorMessage = ApiErrorHandler.extractErrorMessage(error);
      throw Exception(errorMessage);
    }
  }

  /// 注册
  @override
  Future<Map<String, dynamic>> register(String username, String password, String verificationCode, String name) async {
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
      _logger.d('开始保存注册信息');
      await _saveLoginResponse(data);

      _logger.i('用户注册成功');
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
      // 添加详细的响应数据日志，帮助诊断字段映射问题
      _logger.d('登录响应详情', extra: {
        'responseKeys': response.keys.toList(),
        'hasCurrentUser': response.containsKey('currentUser'),
        'hasUser': response.containsKey('user'),
        'hasTokens': response.containsKey('tokens'),
        'hasServerConfig': response.containsKey('serverConfig'),
        'hasVersionUpdate': response.containsKey('versionUpdate'),
      });

      // 保存Token信息
      _logger.d('开始保存Token信息');
      await _tokenManager.saveLoginTokens(response);

      // 保存服务器配置信息
      await _handleServerConfigFromLogin(response);

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

        // 🔧 使用全局构建方法创建CurrentUser，确保所有字段都被正确处理
        final currentUser = CurrentUserBuilder.fromJson(userData);

        // 记录最终创建的用户对象
        _logger.d('创建的CurrentUser对象', extra: {
          'userId': currentUser.userId,
          'name': currentUser.name,
          'phone': currentUser.phone,
          'email': currentUser.email,
          'avatar': currentUser.avatar,
          'status': currentUser.status,
          'lastLoginTime': currentUser.lastLoginTime?.toString(),
        });

        // 保存到安全存储
        await _secureStorage.saveUserCredentials(currentUser);

        // 保存到数据库
        if (DatabaseInitializer.isInitialized) {
          await DatabaseInitializer.database.transaction(() async {
            await DatabaseInitializer.database
                .delete(DatabaseInitializer.database.currentUsers)
                .go();
            await DatabaseInitializer.database
                .into(DatabaseInitializer.database.currentUsers)
                .insert(currentUser);
          });
        }

        // 用户ID保存在CurrentUser对象中，不需要单独存储
      } else {
        _logger.w('⚠️ 登录响应中没有找到用户数据');
      }

      // Token管理已在saveLoginTokens中启动，无需重复启动

      _logger.d('登录信息保存完成');
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

      // 清除服务器配置
      await FileServerConfigService.instance.clearConfig();

      // 清除数据库中的用户信息
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.database.transaction(() async {
          await DatabaseInitializer.database
              .delete(DatabaseInitializer.database.currentUsers)
              .go();
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
      final hasValidToken = await _secureStorage.isRefreshTokenValid();

      return userId != null && userId.isNotEmpty && hasValidToken;
    } catch (error) {
      _logger.e('检查登录状态失败', error: error);
      return false;
    }
  }

  /// 重置密码
  @override
  Future<bool> resetPassword(String phoneOrEmail, String code, String newPassword) async {
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

      _logger.i('📨 发送验证码', extra: {'phoneOrEmail': phoneOrEmail, 'type': type});

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

      _logger.d('开始刷新Token流程');

      // 尝试刷新Token
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _logger.w('没有可用的Refresh Token');
        return null;
      }

      _logger.d('找到Refresh Token，发送刷新请求', extra: {
        'tokenLength': refreshToken.length,
      });

      // 调用刷新Token API
      final response = await _apiService.post('/api/v1/auth/refreshToken', 
          data: {'refreshToken': refreshToken});

      final data = response.data;
      _logger.d('收到刷新响应', extra: {
        'success': data['success'],
        'hasTokens': data.containsKey('tokens'),
      });

      if (data['success'] == true && data['tokens'] != null) {
        // 保存新Token
        _logger.d('保存新Token');
        await _tokenManager.saveLoginTokens(data);
        
        // 返回新的 API Token（已废除 accessToken）
        final newApiToken = await _tokenManager.getApiToken();
        _logger.i('Token刷新成功', extra: {
          'newTokenLength': newApiToken?.length,
        });
        return newApiToken;
      }

      _logger.w('Token刷新失败 - 响应无效');
      return null;
    } catch (error) {
      _logger.e('Token刷新异常', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 删除账户
  @override
  Future<bool> deleteAccount() async {
    try {
      await _ensureInitialized();

      _logger.i('🗑️ 删除账户');

      final response = await _apiService.delete('/api/v1/auth/deleteAccount', requireAuth: true);

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

  /// 处理登录时的服务器配置信息
  Future<void> _handleServerConfigFromLogin(Map<String, dynamic> response) async {
    try {
      final serverConfigData = response['serverConfig'];
      if (serverConfigData != null) {
        _logger.i('🔧 登录时检测到服务器配置信息', extra: {
          'hasChatServers': serverConfigData.containsKey('ss'),
          'hasLoginServers': serverConfigData.containsKey('ls'),
          'hasDefaultFileServer': serverConfigData.containsKey('defs'),
          'hasFileServers': serverConfigData.containsKey('fsUrl'),
          'hasFileLimits': serverConfigData.containsKey('limits'),
        });

        // 保存服务器配置
        await FileServerConfigService.instance.saveServerConfig(serverConfigData);
        
        // 如果登录返回了聊天服务器配置，更新首选聊天服务器
        if (serverConfigData['ss'] != null) {
          final chatServers = Map<String, String>.from(serverConfigData['ss']);
          await ServerSelectionService.instance.updatePreferredChatServerFromLogin(chatServers);
          _logger.i('✅ 已更新首选聊天服务器配置');
        }
        
        _logger.i('✅ 服务器配置处理完成');
      }
    } catch (error) {
      _logger.e('处理登录服务器配置信息失败', error: error, stackTrace: StackTrace.current);
      // 服务器配置处理失败不影响登录流程
    }
  }


}
