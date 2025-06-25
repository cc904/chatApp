import 'dart:async';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/network/auth_api_client.dart';

import 'package:cc/core/proto/generated/user.pb.dart';

import 'package:cc/core/services/communication_service.dart';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/auth/domain/repositories/auth_repository.dart';
// import 'package:cc/features/profile/data/repositories/profile_repository.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:isar/isar.dart';

/// AuthRepository的实现类
/// 负责auth相关的业务逻辑,包括登录、注册、重置密码等功能
class AuthRepositoryImpl implements AuthRepository {
  final LogService _logger = LogService.instance;
  final AuthApiClient _authApiClient = AuthApiClient.getInstance();
  final CommunicationService _communicationService = CommunicationService();
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  // 服务器URL
  final String _serverUrl;

  // 存储auth状态
  String? _currentUserId;
  String? _currentToken;
  bool _isInitialized = false;

  // auth响应订阅
  StreamSubscription? _authResponseSubscription;

  // 单例实例
  static AuthRepositoryImpl? _instance;

  // 工厂方法，获取单例实例
  static AuthRepositoryImpl getInstance({required String serverUrl}) {
    _instance ??= AuthRepositoryImpl(serverUrl: serverUrl);
    return _instance!;
  }

  // 构造函数
  AuthRepositoryImpl({
    required String serverUrl,
  }) : _serverUrl = serverUrl;

  /// 初始化仓库
  @override
  Future<void> init() async {
    _logger.i('初始化AuthRepository');
    try {
      if (_isInitialized) {
        _logger.i('AuthRepository已经初始化');
        return;
      }

      // 初始化authAPI客户端
      final success = await _authApiClient.init(serverUrl: _serverUrl);
      if (!success) {
        throw Exception('初始化authAPI客户端失败');
      }

      _isInitialized = true;
      _logger.i('AuthRepository初始化完成');
    } catch (error) {
      _logger.e('初始化AuthRepository失败',
          error: error, stackTrace: StackTrace.current);
      throw Exception('初始化失败：${error.toString()}');
    }
  }

  /// 从Proto保存用户凭证
  ///
  /// 将Proto格式的用户信息转换并保存到安全存储和数据库
  ///
  /// 参数:
  /// - userProto: Proto格式的用户信息
  Future<void> saveUserCredentialsFromProto(CurrentUserProto userProto) async {
    try {
      _logger.i('开始保存用户凭证从Proto', extra: {'userId': userProto.userId});

      // 转换为CurrentUser模型
      final currentUser = CurrentUser.fromProto(userProto);

      // 💡 确保数据库已初始化（以当前用户ID作为数据库名称）
      try {
        await DatabaseInitializer.init(currentUser: currentUser);
      } catch (e) {
        _logger.w('DatabaseInitializer.init 失败，将跳过数据库保存',
            extra: {'error': e.toString()});
      }

      // 🔐 SecurityStorage：只存储敏感的认证信息
      await _secureStorage.write(
          SecureStorageService.keyUserId, currentUser.userId);
      await _secureStorage.write(
          SecureStorageService.keyToken, currentUser.token);

      if (currentUser.tokenExpireTime != null) {
        await _secureStorage.write(
          SecureStorageService.keyTokenExpireTime,
          currentUser.tokenExpireTime!.millisecondsSinceEpoch.toString(),
        );
      }

      // 💾 数据库：存储用户基本信息用于快速UI显示
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.isar.writeTxn(() async {
          await DatabaseInitializer.isar.currentUsers.clear();
          await DatabaseInitializer.isar.currentUsers.put(currentUser);
        });
        _logger.i('用户信息已保存到数据库');
      }

      _logger.i('用户凭证保存成功', extra: {
        'userId': currentUser.userId,
        'hasToken': currentUser.token.isNotEmpty,
        'hasExpireTime': currentUser.tokenExpireTime != null,
        'savedToDatabase': DatabaseInitializer.isInitialized,
      });
    } catch (e) {
      _logger.e('保存用户凭证失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取当前用户信息
  ///
  /// 优先从数据库获取用户信息，如果数据库中没有则从安全存储获取
  ///
  /// 返回:
  /// - 用户信息（CurrentUser），不存在则返回null
  @override
  Future<CurrentUser?> getCurrentUser() async {
    try {
      // 1. 优先从数据库获取完整用户信息
      if (DatabaseInitializer.isInitialized) {
        // 直接获取所有CurrentUser记录
        final collection = DatabaseInitializer.isar.currentUsers;
        final allUsers = await collection.where().findAll();
        if (allUsers.isNotEmpty) {
          final user = allUsers.first;
          _logger.d('从数据库获取用户信息成功', extra: {'userId': user.userId});
          return user;
        }
      }

      // 2. 如果数据库中没有，从安全存储获取基本信息
      final fullUserInfo = await _secureStorage.getFullUserInfo();
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

      _logger.d('未找到用户信息', stackTrace: StackTrace.current);
      return null;
    } catch (error) {
      _logger.e('获取用户信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 使用密码登录
  ///
  /// 使用用户名和密码进行登录
  ///
  /// 参数:
  /// - username: 用户名/手机号
  /// - password: 密码
  ///
  /// 返回:
  /// - 登录成功返回AuthResponse
  @override
  Future<AuthResponse> loginWithPassword(
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

      // 直接使用ApiClient登录并获取响应
      final response =
          await _authApiClient.loginWithPassword(username, password);

      // 如果登录不成功，抛出异常
      if (!response.success) {
        throw Exception(response.message);
      }

      // 如果没有用户ID，抛出异常
      if (!response.hasUserId()) {
        throw Exception('登录成功但未返回用户ID');
      }

      // 保存用户凭证
      await saveUserCredentialsFromProto(response.currentUser!);

      return response;
    } catch (error) {
      _logger.e('密码登录失败', error: error, stackTrace: StackTrace.current);
      return AuthResponse(success: false, message: '登录失败：${error.toString()}');
    }
  }

  /// 使用验证码登录
  ///
  /// 使用手机号和验证码进行登录
  ///
  /// 参数:
  /// - username: 用户名/手机号
  /// - code: 验证码
  ///
  /// 返回:
  /// - 登录成功返回AuthResponse
  @override
  Future<AuthResponse> loginWithCode(String username, String code) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (username.isEmpty) {
        throw Exception('请输入手机号码');
      }
      if (code.isEmpty) {
        throw Exception('请输入验证码');
      }

      // 直接使用ApiClient登录并获取响应
      final response = await _authApiClient.loginWithCode(username, code);

      // 如果登录不成功，抛出异常
      if (!response.success) {
        throw Exception(response.message);
      }

      // 如果没有用户ID，抛出异常
      if (!response.hasUserId()) {
        throw Exception('登录成功但未返回用户ID');
      }

      // 保存用户凭证
      await saveUserCredentialsFromProto(response.currentUser!);

      return response;
    } catch (error) {
      _logger.e('验证码登录失败', error: error, stackTrace: StackTrace.current);
      return AuthResponse(success: false, message: '登录失败：${error.toString()}');
    }
  }

  /// 使用令牌登录
  ///
  /// 尝试使用存储的令牌自动登录
  ///
  /// 返回:
  /// - 成功返回包含用户信息的AuthResponse，失败返回错误信息的AuthResponse
  @override
  Future<AuthResponse> loginWithToken() async {
    try {
      await _ensureInitialized();

      // 优先从安全存储获取凭证
      final userId = await _secureStorage.getUserId();
      final token = await _secureStorage.getToken();
      final isTokenValid = await _secureStorage.isTokenValid();

      if (userId == null || token == null || !isTokenValid) {
        // 如果安全存储中没有有效凭证，直接返回null
        _logger.x('没有可用的登录令牌', extra: {'reason': '安全存储中无凭证或凭证已过期'});
        return AuthResponse(success: false, message: '令牌不存在或已过期');
      }

      // 直接使用安全存储中的凭证
      _currentUserId = userId;
      _currentToken = token;

      // 验证令牌有效性
      final tokenResponse = await _authApiClient.verifyToken(_currentToken!);
      if (!tokenResponse.success) {
        _logger.w('令牌验证失败，需要重新登录', extra: {'message': tokenResponse.message});
        return tokenResponse;
      }

      // ⚠️ 确保将服务器返回的完整用户信息保存到本地（数据库 + SecureStorage）
      if (tokenResponse.currentUser != null) {
        try {
          await saveUserCredentialsFromProto(tokenResponse.currentUser!);
        } catch (e) {
          _logger.w('保存用户凭证失败（非致命）', extra: {'error': e.toString()});
        }
      }

      // 创建成功响应，包含用户信息
      return AuthResponse(
        success: true,
        message: '令牌登录成功',
        currentUser: tokenResponse.currentUser,
      );
    } catch (error) {
      _logger.e('令牌登录失败', error: error, stackTrace: StackTrace.current);
      return AuthResponse(
          success: false, message: '令牌登录失败: ${error.toString()}');
    }
  }

  /// 注册
  ///
  /// 创建新账户
  ///
  /// 参数:
  /// - username: 用户名/手机号
  /// - password: 密码
  /// - verificationCode: 验证码
  /// - name: 用户昵称
  ///
  /// 返回:
  /// - 注册成功返回包含用户信息的AuthResponse，失败返回错误信息的AuthResponse
  @override
  Future<AuthResponse> register(String username, String password,
      String verificationCode, String name) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (username.isEmpty) {
        throw Exception('请输入手机号码');
      }
      if (password.isEmpty) {
        throw Exception('请输入密码');
      }
      if (name.isEmpty) {
        throw Exception('请输入昵称');
      }
      if (verificationCode.isEmpty) {
        throw Exception('请输入验证码');
      }

      // 这里假设已经获取了验证码
      // const verificationCode = '123456'; // 实际应用中应从用户输入获取

      // 直接使用ApiClient注册并获取响应
      final response = await _authApiClient.register(
          username, verificationCode, password, name);

      // 如果注册不成功，直接返回错误响应
      if (!response.success) {
        return response;
      }

      // 如果没有用户ID，返回错误响应
      if (!response.hasUserId()) {
        return AuthResponse(success: false, message: '注册成功但未返回用户ID');
      }

      // 保存用户凭证
      await saveUserCredentialsFromProto(response.currentUser!);

      // 返回成功响应
      return response;
    } catch (error) {
      _logger.e('注册失败', error: error, stackTrace: StackTrace.current);
      return AuthResponse(success: false, message: '注册失败：${error.toString()}');
    }
  }

  /// 登出
  ///
  /// 清除用户身份认证相关数据
  ///
  /// 返回:
  /// - 成功返回true，失败返回false
  @override
  Future<bool> logout() async {
    try {
      _logger.i('开始登出操作');

      // 断开通信连接
      await _communicationService.disconnect();

      // 清除本地用户数据
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.isar.writeTxn(() async {
          await DatabaseInitializer.isar.currentUsers.clear();
        });
      }

      // 关闭数据库
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.close();
      }

      // 清除安全存储中的凭证
      await _secureStorage.clearUserCredentials();

      // 重置auth状态
      _currentUserId = null;
      _currentToken = null;

      _logger.i('用户已登出，所有凭证已清除');
      return true;
    } catch (error) {
      _logger.e('登出失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 检查是否已登录
  ///
  /// 返回:
  /// - 已登录返回true，未登录返回false
  @override
  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null && user.token.isNotEmpty;
    } catch (error) {
      _logger.e('检查登录状态失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 重置密码
  ///
  /// 通过验证码重置用户密码
  ///
  /// 参数:
  /// - phoneOrEmail: 手机号或邮箱
  /// - code: 验证码
  /// - newPassword: 新密码
  ///
  /// 返回:
  /// - 操作成功返回true
  @override
  Future<bool> resetPassword(
      String phoneOrEmail, String code, String newPassword) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (phoneOrEmail.isEmpty) {
        throw Exception('请输入手机号或邮箱');
      }
      if (code.isEmpty) {
        throw Exception('请输入验证码');
      }
      if (newPassword.isEmpty) {
        throw Exception('请输入新密码');
      }

      // 调用API方法并获取响应
      final response =
          await _authApiClient.resetPassword(phoneOrEmail, code, newPassword);

      // 返回操作是否成功
      return response.success;
    } catch (error) {
      _logger.e('重置密码失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 发送验证码
  ///
  /// 向指定手机号或邮箱发送验证码
  ///
  /// 参数:
  /// - phoneOrEmail: 手机号或邮箱
  /// - type: 验证码类型（注册/重置密码）
  ///
  /// 返回:
  /// - 发送成功返回true
  @override
  Future<bool> sendVerificationCode(String phoneOrEmail, String type) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (phoneOrEmail.isEmpty) {
        throw Exception('请输入手机号或邮箱');
      }

      // 调用API方法并直接返回布尔结果
      return await _authApiClient.sendVerificationCode(phoneOrEmail, type);
    } catch (error) {
      _logger.e('发送验证码失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 验证验证码
  ///
  /// 验证用户输入的验证码是否正确
  ///
  /// 参数:
  /// - phoneOrEmail: 手机号或邮箱
  /// - code: 验证码
  ///
  /// 返回:
  /// - 验证成功返回true
  @override
  Future<bool> verifyCode(String phoneOrEmail, String code) async {
    try {
      await _ensureInitialized();

      // 验证输入
      if (phoneOrEmail.isEmpty) {
        throw Exception('请输入手机号或邮箱');
      }
      if (code.isEmpty) {
        throw Exception('请输入验证码');
      }

      // TODO 实现验证码验证API
      // 目前直接返回成功
      return true;
    } catch (error) {
      _logger.e('验证验证码失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 更新用户令牌
  ///
  /// 刷新当前用户的auth令牌
  ///
  /// 返回:
  /// - 新的令牌，失败返回null
  @override
  Future<String?> refreshToken() async {
    try {
      await _ensureInitialized();

      // 获取当前token
      final currentToken = await _secureStorage.getToken();
      if (currentToken == null) {
        _logger.w('没有当前Token，无法刷新');
        return null;
      }

      _logger.i('开始刷新Token...');

      // 通过验证token接口尝试获取新token
      final verifyResponse = await _authApiClient.verifyToken(currentToken);

      if (!verifyResponse.success || verifyResponse.currentUser == null) {
        _logger
            .w('Token刷新失败，验证响应失败', extra: {'message': verifyResponse.message});
        return null;
      }

      final currentUser = verifyResponse.currentUser!;
      String? newToken;
      DateTime? newExpireTime;

      // 检查是否返回了新token
      if (currentUser.hasToken() && currentUser.token != currentToken) {
        newToken = currentUser.token;
        _logger.i('获取到新Token');
      }

      // 检查是否返回了新的过期时间
      if (currentUser.hasTokenExpireTime()) {
        newExpireTime = DateTime.fromMillisecondsSinceEpoch(
            currentUser.tokenExpireTime.toInt());
        _logger.i('获取到新的过期时间: ${newExpireTime.toIso8601String()}');
      }

      // 如果有更新，保存新的token信息
      if (newToken != null || newExpireTime != null) {
        await _updateStoredToken(newToken ?? currentToken, newExpireTime);

        // 更新内存中的token
        _currentToken = newToken ?? currentToken;

        _logger.i('Token刷新成功');
        return newToken ?? currentToken;
      } else {
        _logger.d('服务器没有返回新Token，当前Token仍然有效');
        return currentToken;
      }
    } catch (error) {
      _logger.e('刷新令牌失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 更新存储中的Token信息
  Future<void> _updateStoredToken(String token, DateTime? expireTime) async {
    try {
      // 获取当前完整用户信息
      final currentUser = await _secureStorage.getFullUserInfo();
      if (currentUser == null) {
        _logger.w('无法获取当前用户信息，跳过Token更新');
        return;
      }

      // 更新token和过期时间
      currentUser.token = token;
      if (expireTime != null) {
        currentUser.tokenExpireTime = expireTime;
      }

      // 保存到安全存储
      await _secureStorage.saveUserCredentials(currentUser);

      // 更新数据库中的用户信息
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.isar.writeTxn(() async {
          await DatabaseInitializer.isar.currentUsers.clear();
          await DatabaseInitializer.isar.currentUsers.put(currentUser);
        });
      }

      _logger.i('Token信息已更新到存储');
    } catch (error) {
      _logger.e('更新Token信息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 删除账户
  ///
  /// 删除当前用户账户及相关数据
  ///
  /// 返回:
  /// - 操作成功返回true
  @override
  Future<bool> deleteAccount() async {
    try {
      await _ensureInitialized();

      // 确保有登录用户
      if (_currentUserId == null) {
        throw Exception('未登录，无法删除账户');
      }

      // TODO 实现删除账户API
      // 先登出
      await logout();

      // 删除本地数据库
      final userId = _currentUserId!;
      await DatabaseInitializer.deleteUserDatabase(userId);

      return true;
    } catch (error) {
      _logger.e('删除账户失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 从安全存储中获取用户信息
  ///
  /// 直接返回安全存储中的用户ID和令牌，不访问数据库
  ///
  /// 返回:
  /// - 包含userId和token的Map，如果不存在则对应值为null
  Future<Map<String, String?>> getLocalUserInfo() async {
    try {
      // 从安全存储中获取用户凭证
      final userId = await _secureStorage.getUserId();
      final token = await _secureStorage.getToken();

      _logger.x('从安全存储获取用户信息', extra: {'userId': userId ?? '未找到'});

      return {
        'userId': userId,
        'token': token,
      };
    } catch (error) {
      _logger.e('从安全存储获取用户信息失败', error: error, stackTrace: StackTrace.current);
      return {
        'userId': null,
        'token': null,
      };
    }
  }

  /// 确保仓库已初始化
  ///
  /// 检查仓库是否已初始化，未初始化则初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      // 标记为已经开始初始化，防止递归调用
      _isInitialized = true;
      try {
        await init();
      } catch (e) {
        // 如果初始化失败，重置标记
        _isInitialized = false;
        rethrow;
      }
    }
  }

  /// 释放资源
  ///
  /// 取消订阅、关闭流控制器等
  Future<void> dispose() async {
    _authResponseSubscription?.cancel();
  }
}
