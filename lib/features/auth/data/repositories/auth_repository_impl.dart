import 'dart:async';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/network/auth_api_client.dart';

import 'package:cc/core/proto/generated/user.pb.dart';

import 'package:cc/core/services/communication_service.dart';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/auth/domain/repositories/auth_repository.dart';
// import 'package:cc/features/profile/data/repositories/profile_repository.dart';
import 'package:fixnum/fixnum.dart';
import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';

/// AuthRepository的实现类
/// 负责auth相关的业务逻辑,包括登录、注册、重置密码等功能
class AuthRepositoryImpl implements AuthRepository {
  final LogService _logger = LogService.instance;
  final AuthApiClient _authApiClient = AuthApiClient.getInstance();
  // final ProfileRepository _profileRepository = ProfileRepository();
  final CommunicationService _communicationService = CommunicationService();

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

      // 仍然需要订阅auth响应，用于处理实时通信等
      _authResponseSubscription =
          _authApiClient.onAuthResponse.listen(_handleAuthResponse);

      // 尝试从本地数据获取用户信息
      final userInfo = await getUserInfo();
      if (userInfo != null && userInfo.token.isNotEmpty) {
        _currentUserId = userInfo.userId;
        _currentToken = userInfo.token;

        // 如果已经有登录用户，确保数据库已初始化
        if (!DatabaseInitializer.isInitialized && _currentUserId != null) {
          await DatabaseInitializer.init(userId: _currentUserId!);
        }
      }

      _isInitialized = true;
      _logger.i('AuthRepository初始化完成');
    } catch (error) {
      _logger.e('初始化AuthRepository失败',
          error: error, stackTrace: StackTrace.current);
      throw Exception('初始化失败：${error.toString()}');
    }
  }

  /// 处理auth响应
  ///
  /// 处理来自AuthApiClient的auth响应，并管理auth状态
  ///
  /// 参数:
  /// - response: auth响应对象
  void _handleAuthResponse(AuthResponse response) {
    _logger.i('收到auth响应',
        extra: {'success': response.success, 'message': response.message});

    // 如果认证失败，不需要特别处理
    if (!response.success) {
      return;
    }

    // 如果auth成功且包含用户ID和令牌
    if (response.hasUserId() && response.hasToken()) {
      final userId = response.userId!;
      final token = response.token!;

      // 更新当前状态
      _currentUserId = userId;
      _currentToken = token;

      // 异步初始化数据库和通信服务
      _initUserSession(userId, token).catchError((error) {
        _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      });
    }
  }

  /// 初始化用户会话
  ///
  /// 完成用户auth后进行数据库初始化和通信服务连接
  ///
  /// 参数:
  /// - userId: 用户ID
  /// - token: auth令牌
  Future<void> _initUserSession(String userId, String token) async {
    try {
      _logger.d('开始初始化用户会话',
          extra: {'userId': userId}, stackTrace: StackTrace.current);

      // 初始化Isar数据库
      await DatabaseInitializer.init(userId: userId);

      // 保存用户信息
      await saveUserInfo(
        MyUserProto(
          userId: userId,
          token: token,
          name: '我',
          lastLoginTime: Int64(DateTime.now().millisecondsSinceEpoch),
        ),
      );

      // 初始化实时通信
      await _initRealTimeCommunication(userId, token);

      _logger.i('用户会话初始化完成');
    } catch (error) {
      _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      throw Exception('初始化失败：${error.toString()}');
    }
  }

  /// 保存用户信息
  ///
  /// 将用户信息保存到本地数据库
  ///
  /// 参数:
  /// - user: 用户信息（MyUserProto）
  Future<void> saveUserInfo(MyUserProto user) async {
    try {
      if (!DatabaseInitializer.isInitialized) {
        throw Exception('数据库未初始化，无法保存用户信息');
      }

      final db = DatabaseInitializer.isar;
      await db.writeTxn(() async {
        await db.myUsers.clear(); // 清除旧数据

        // 创建 MyUser 对象并保存
        final myUser = MyUser()
          ..userId = user.userId
          ..token = user.token
          ..name = user.name
          ..avatar = user.avatar
          ..phone = user.phone
          ..email = user.email
          ..tokenExpireTime = user.hasTokenExpireTime()
              ? DateTime.fromMillisecondsSinceEpoch(
                  user.tokenExpireTime.toInt())
              : null
          ..lastLoginTime = user.hasLastLoginTime()
              ? DateTime.fromMillisecondsSinceEpoch(user.lastLoginTime.toInt())
              : null
          ..status = user.status;

        await db.myUsers.put(myUser); // 保存新数据
      });
      _logger.i('用户信息保存成功', extra: {'userId': user.userId});
    } catch (e) {
      _logger.e('保存用户信息失败', error: e, stackTrace: StackTrace.current);
      throw Exception('保存用户信息失败: ${e.toString()}');
    }
  }

  /// 获取用户信息
  ///
  /// 从本地数据库获取用户信息
  ///
  /// 返回:
  /// - 用户信息（MyUserProto），不存在则返回null
  Future<MyUserProto?> getUserInfo() async {
    try {
      if (!DatabaseInitializer.isInitialized) {
        // 数据库尚未初始化时，默认返回null而不是抛出异常
        _logger.i('数据库未初始化，无法获取用户信息');
        return null;
      }

      final db = DatabaseInitializer.isar;
      final users = await db.myUsers.where().findAll();
      if (users.isEmpty) {
        return null;
      }

      // 转换为 MyUserProto
      final user = users.first;
      return MyUserProto(
        userId: user.userId,
        token: user.token,
        name: user.name,
        avatar: user.avatar,
        phone: user.phone,
        email: user.email,
        tokenExpireTime: user.tokenExpireTime != null
            ? Int64(user.tokenExpireTime!.millisecondsSinceEpoch)
            : null,
        lastLoginTime: user.lastLoginTime != null
            ? Int64(user.lastLoginTime!.millisecondsSinceEpoch)
            : null,
        status: user.status,
      );
    } catch (e) {
      _logger.e('获取用户信息失败', error: e, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 初始化实时通信
  ///
  /// 连接Socket.io服务器，建立实时通信
  ///
  /// 参数:
  /// - userId: 用户ID
  /// - token: auth令牌
  Future<void> _initRealTimeCommunication(String userId, String token) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        _logger.i('初始化实时通信，尝试次数: ${retryCount + 1}');

        final success = await _communicationService.connect(
          serverUrl: _serverUrl,
          userId: userId,
          token: token,
        );

        if (success) {
          _logger.i('实时通信初始化成功');
          return;
        } else {
          _logger.e('实时通信初始化失败', stackTrace: StackTrace.current);
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          }
        }
      } catch (error) {
        _logger.e('初始化实时通信错误', error: error, stackTrace: StackTrace.current);
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
      }
    }

    // 所有重试都失败后，记录错误但不中断流程
    _logger.e('实时通信初始化失败，已达到最大重试次数', stackTrace: StackTrace.current);
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
  /// - 登录成功返回用户ID
  @override
  Future<String> loginWithPassword(String username, String password) async {
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

      // 处理登录成功后的用户会话初始化
      if (response.hasToken()) {
        await _initUserSession(response.userId!, response.token!);
      }

      return response.userId!;
    } catch (error) {
      _logger.e('密码登录失败', error: error, stackTrace: StackTrace.current);
      throw Exception('登录失败：${error.toString()}');
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
  /// - 登录成功返回用户ID
  @override
  Future<String> loginWithCode(String username, String code) async {
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

      // 处理登录成功后的用户会话初始化
      if (response.hasToken()) {
        await _initUserSession(response.userId!, response.token!);
      }

      return response.userId!;
    } catch (error) {
      _logger.e('验证码登录失败', error: error, stackTrace: StackTrace.current);
      throw Exception('登录失败：${error.toString()}');
    }
  }

  /// 登录
  ///
  /// 使用用户名和密码进行登录（保留此方法以向后兼容）
  ///
  /// 参数:
  /// - username: 用户名/手机号
  /// - password: 密码
  ///
  /// 返回:
  /// - 登录成功返回用户ID
  @override
  Future<String> login(String username, String password) async {
    return loginWithPassword(username, password);
  }

  /// 使用令牌登录
  ///
  /// 使用保存的令牌进行自动登录
  ///
  /// 返回:
  /// - 登录成功返回用户ID，失败返回null
  @override
  Future<String?> loginWithToken() async {
    try {
      await _ensureInitialized();

      final currentUser = await getUserInfo();
      if (currentUser == null || currentUser.token.isEmpty) {
        _logger.i('没有可用的登录令牌');
        return null;
      }

      // TODO: 实现令牌验证逻辑，向服务器验证令牌有效性
      // 目前简单返回已存储的用户ID

      // 初始化数据库和通信服务
      await _initUserSession(currentUser.userId, currentUser.token);

      _currentUserId = currentUser.userId;
      _currentToken = currentUser.token;

      return currentUser.userId;
    } catch (error) {
      _logger.e('令牌登录失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 注册
  ///
  /// 创建新账户
  ///
  /// 参数:
  /// - username: 用户名/手机号
  /// - password: 密码
  /// - name: 用户昵称
  /// - avatar: 可选的头像URL
  ///
  /// 返回:
  /// - 注册成功返回用户ID
  @override
  Future<String> register(String username, String password, String name,
      {String? avatar}) async {
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

      // TODO: 获取验证码的流程需要单独实现
      // 这里假设已经获取了验证码
      const verificationCode = '123456'; // 实际应用中应从用户输入获取

      // 直接使用ApiClient注册并获取响应
      final response = await _authApiClient.register(
          username, verificationCode, password, name);

      // 如果注册不成功，抛出异常
      if (!response.success) {
        throw Exception(response.message);
      }

      // 如果没有用户ID，抛出异常
      if (!response.hasUserId()) {
        throw Exception('注册成功但未返回用户ID');
      }

      // 处理注册成功后的用户会话初始化
      if (response.hasToken()) {
        await _initUserSession(response.userId!, response.token!);
      }

      return response.userId!;
    } catch (error) {
      _logger.e('注册失败', error: error, stackTrace: StackTrace.current);
      throw Exception('注册失败：${error.toString()}');
    }
  }

  /// 登出
  ///
  /// 注销当前用户会话
  ///
  /// 返回:
  /// - 操作成功返回true
  @override
  Future<bool> logout() async {
    try {
      _logger.i('开始登出操作');

      // 断开通信连接
      await _communicationService.disconnect();

      // 清除本地用户数据
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.isar.writeTxn(() async {
          await DatabaseInitializer.isar.myUsers.clear();
        });
      }

      // 关闭数据库
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.close();
      }

      // 重置auth状态
      _currentUserId = null;
      _currentToken = null;

      _logger.i('登出成功');
      return true;
    } catch (error) {
      _logger.e('登出失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 获取当前用户
  ///
  /// 获取当前登录用户信息
  ///
  /// 返回:
  /// - 当前用户信息，未登录返回null
  @override
  Future<MyUser?> getCurrentUser() async {
    try {
      // 如果还没初始化，先尝试安全地初始化，但不递归调用
      if (!_isInitialized) {
        // 只是简单地获取用户信息，不进行完整的初始化流程
        final userInfo = await getUserInfo();
        if (userInfo != null) {
          return MyUser()
            ..userId = userInfo.userId
            ..token = userInfo.token
            ..name = userInfo.name
            ..avatar = userInfo.avatar
            ..phone = userInfo.phone
            ..email = userInfo.email
            ..tokenExpireTime = userInfo.hasTokenExpireTime()
                ? DateTime.fromMillisecondsSinceEpoch(
                    userInfo.tokenExpireTime.toInt())
                : null
            ..lastLoginTime = userInfo.hasLastLoginTime()
                ? DateTime.fromMillisecondsSinceEpoch(
                    userInfo.lastLoginTime.toInt())
                : null
            ..status = userInfo.status;
        }
        return null;
      }

      // 正常流程：获取用户信息
      final userProto = await getUserInfo();

      if (userProto == null) {
        return null;
      }

      // 将 MyUserProto 转换为 MyUser
      return MyUser()
        ..userId = userProto.userId
        ..token = userProto.token
        ..name = userProto.name
        ..avatar = userProto.avatar
        ..phone = userProto.phone
        ..email = userProto.email
        ..tokenExpireTime = userProto.hasTokenExpireTime()
            ? DateTime.fromMillisecondsSinceEpoch(
                userProto.tokenExpireTime.toInt())
            : null
        ..lastLoginTime = userProto.hasLastLoginTime()
            ? DateTime.fromMillisecondsSinceEpoch(
                userProto.lastLoginTime.toInt())
            : null
        ..status = userProto.status;
    } catch (error) {
      _logger.e('获取当前用户失败', error: error, stackTrace: StackTrace.current);
      return null;
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

      // 调用API方法并获取响应
      final response =
          await _authApiClient.sendVerificationCode(phoneOrEmail, type);

      // 返回操作是否成功
      return response.success;
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

      // TODO: 实现验证码验证API
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

      // TODO: 实现令牌刷新API
      // 目前直接返回当前令牌
      return _currentToken;
    } catch (error) {
      _logger.e('刷新令牌失败', error: error, stackTrace: StackTrace.current);
      return null;
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

      // TODO: 实现删除账户API
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
