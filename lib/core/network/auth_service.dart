import 'dart:async';
import 'package:cc/core/services/log_service.dart';
import 'socket_service.dart';
import 'proto_converter.dart';
import 'types.dart';
import 'package:fixnum/fixnum.dart';
import '../proto/generated/auth.pb.dart';
import '../database/database_initializer.dart';
import '../database/models/user.dart';
import '../services/user_service.dart';

/// 认证服务
/// 使用Socket.IO进行认证操作
class AuthService {
  // 单例模式
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  static AuthService getInstance() {
    return _instance;
  }

  AuthService._internal();

  final LogService _logger = LogService('auth_service.dart');
  final SocketService _socketService = SocketService.getInstance();
  final ProtoConverter _protoConverter = ProtoConverter();

  // 当前用户信息
  UserSession? _currentSession;
  User? _currentUser;

  // Socket配置
  String? _serverUrl;
  DataEncoding _dataEncoding = DataEncoding.json;
  bool _simulationMode = false;

  // 事件控制器
  final StreamController<AuthResponse> _authResponseController = StreamController<AuthResponse>.broadcast();

  // 事件流
  Stream<AuthResponse> get onAuthResponse => _authResponseController.stream;

  // 获取当前会话信息
  UserSession? get currentSession => _currentSession;

  // 获取当前用户信息
  User? get currentUser => _currentUser;

  // 是否已登录
  bool get isLoggedIn => _currentSession != null && _currentUser != null;

  /// 初始化认证服务
  Future<bool> init({
    required String serverUrl,
    DataEncoding encoding = DataEncoding.json,
    bool simulationMode = false,
  }) async {
    _logger.i('初始化认证服务');

    // 保存配置信息
    _serverUrl = serverUrl;
    _dataEncoding = encoding;
    _simulationMode = simulationMode;

    // 初始化Socket连接
    final success = await _socketService.initForAuth(
      serverUrl: serverUrl,
      encoding: encoding,
      simulationMode: simulationMode,
    );

    if (!success) {
      _logger.e('初始化Socket连接失败');
      return false;
    }

    // 监听socket.io认证响应事件
    _socketService.on(SocketEvent.authResponse).listen(_handleAuthResponse);
    _socketService.on(SocketEvent.authError).listen((error) {
      _logger.e('认证错误', extra: {'error': error});
    });

    return true;
  }

  /// 获取认证成功后的连接信息（供主应用使用）
  Map<String, dynamic> getConnectionInfo() {
    return {
      'serverUrl': _serverUrl,
      'token': _currentSession?.token,
      'userId': _currentSession?.userId,
      'dataEncoding': _dataEncoding,
      'simulationMode': _simulationMode,
    };
  }

  /// 处理认证响应
  void _handleAuthResponse(dynamic data) {
    _logger.i('收到认证响应', extra: {'data': data});

    AuthResponse response;
    try {
      if (data is AuthResponse) {
        // 直接使用AuthResponse对象
        response = data;
      } else if (data is List<int>) {
        // 二进制Protobuf格式
        response = AuthResponse.fromBuffer(data);
      } else if (data is String) {
        // Base64编码的Protobuf
        response = _protoConverter.base64ToAuthResponse(data);
      } else if (data is Map<String, dynamic>) {
        // JSON格式
        response = _protoConverter.mapToAuthResponse(data);
      } else {
        _logger.e('不支持的数据格式', extra: {'data': data});
        return;
      }

      // 处理响应数据
      _processAuthResponse(response);

      // 转发事件
      _authResponseController.add(response);
    } catch (e) {
      _logger.e('解析认证响应失败', error: e);
    }
  }

  /// 处理认证响应数据
  void _processAuthResponse(AuthResponse response) async {
    if (!response.success) {
      _logger.w('认证失败', extra: {'message': response.message});
      return;
    }

    if (response.hasUserId() && response.hasToken()) {
      _logger.i('认证成功，保存会话信息');

      // 创建并保存会话信息
      final session = UserSession()
        ..userId = response.userId
        ..token = response.token
        ..expireTime = Int64(DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch);

      _currentSession = session;

      // 初始化数据库
      await _initUserDatabase(response.userId);

      // 获取用户信息
      _currentUser = await UserService.getCurrentUser();
    }
  }

  /// 初始化用户数据库
  Future<void> _initUserDatabase(String userId) async {
    try {
      _logger.i('初始化用户数据库: $userId');

      // 检查用户数据库是否存在
      final dbExists = await DatabaseInitializer.userDatabaseExists(userId);

      // 检查数据库是否已初始化
      final isInitialized = DatabaseInitializer.isInitialized;

      if (!isInitialized) {
        _logger.i('数据库尚未初始化，首次创建数据库');
      }

      if (dbExists) {
        _logger.i('用户数据库已存在，切换到该数据库');
        await DatabaseInitializer.switchUserDatabase(userId);
      } else {
        _logger.i('用户数据库不存在，创建新数据库');
        await DatabaseInitializer.init(userId: userId);
      }
    } catch (e) {
      _logger.e('初始化用户数据库失败', error: e);
      // 如果用户数据库初始化失败，回退到默认数据库
      if (!DatabaseInitializer.isInitialized) {
        _logger.i('尝试回退到默认数据库');
        await DatabaseInitializer.init();
      }
    }
  }

  /// 使用验证码登录
  Future<bool> loginWithCode(String phoneNumber, String verificationCode) async {
    try {
      _logger.i('使用验证码登录', extra: {'phoneNumber': phoneNumber});

      // 创建登录请求
      final request = AuthRequest()
        ..operationType = AuthOperationType.login
        ..phoneNumber = phoneNumber
        ..verificationCode = verificationCode
        ..isQuickLogin = true;

      // 发送请求
      return _sendAuthRequest('auth', request);
    } catch (e) {
      _logger.e('验证码登录失败', error: e);
      return false;
    }
  }

  /// 使用密码登录
  Future<bool> loginWithPassword(String phoneNumber, String password) async {
    try {
      _logger.i('使用密码登录', extra: {'phoneNumber': phoneNumber});

      // 创建登录请求
      final request = AuthRequest()
        ..operationType = AuthOperationType.login
        ..phoneNumber = phoneNumber
        ..password = password
        ..isQuickLogin = false;

      // 发送请求
      return _sendAuthRequest('auth', request);
    } catch (e) {
      _logger.e('密码登录失败', error: e);
      return false;
    }
  }

  /// 注册账号
  Future<bool> register(String phoneNumber, String verificationCode, String password, String nickname) async {
    try {
      _logger.i('注册账号', extra: {'phoneNumber': phoneNumber, 'nickname': nickname});

      // 创建注册请求
      final request = AuthRequest()
        ..operationType = AuthOperationType.register
        ..phoneNumber = phoneNumber
        ..verificationCode = verificationCode
        ..password = password
        ..nickname = nickname;

      // 发送请求
      return _sendAuthRequest('auth', request);
    } catch (e) {
      _logger.e('注册失败', error: e);
      return false;
    }
  }

  /// 重置密码
  Future<bool> resetPassword(String phoneNumber, String verificationCode, String newPassword) async {
    try {
      _logger.i('重置密码', extra: {'phoneNumber': phoneNumber});

      // 创建重置密码请求
      final request = AuthRequest()
        ..operationType = AuthOperationType.reset_password
        ..phoneNumber = phoneNumber
        ..verificationCode = verificationCode
        ..password = newPassword;

      // 发送请求
      return _sendAuthRequest('auth', request);
    } catch (e) {
      _logger.e('重置密码失败', error: e);
      return false;
    }
  }

  /// 发送验证码
  Future<bool> sendVerificationCode(String phoneNumber, String purpose) async {
    try {
      _logger.i('发送验证码', extra: {'phoneNumber': phoneNumber, 'purpose': purpose});

      // 创建发送验证码请求
      final request = AuthRequest()
        ..operationType = AuthOperationType.send_code
        ..phoneNumber = phoneNumber
        ..purpose = purpose;

      // 发送请求
      return _sendAuthRequest('auth/send_code', request);
    } catch (e) {
      _logger.e('发送验证码失败', error: e);
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    _logger.i('退出登录');

    // 发送退出登录请求
    _socketService.emit('logout', {});

    // 清除会话信息
    _currentSession = null;
    _currentUser = null;
  }

  /// 发送认证请求
  bool _sendAuthRequest(String event, AuthRequest request) {
    try {
      // 如果是模拟模式，模拟响应
      if (_simulationMode) {
        _logger.i('模拟发送认证请求', extra: {'event': event, 'data': request.operationType.name});

        // 延迟返回模拟响应，模拟网络延迟
        Future.delayed(Duration(milliseconds: 300), () {
          _simulateAuthResponse(request);
        });

        return true;
      }

      Object encodedData;

      // 根据编码方式编码数据
      if (_socketService.dataEncoding == DataEncoding.json) {
        // JSON格式
        encodedData = _protoConverter.authRequestToMap(request);
      } else if (_socketService.dataEncoding == DataEncoding.protobuf) {
        // 二进制Protobuf格式
        encodedData = request.writeToBuffer();
      } else {
        // Base64编码的Protobuf
        encodedData = _protoConverter.authRequestToBase64(request);
      }

      // 发送请求
      return _socketService.emit(event, encodedData);
    } catch (e) {
      _logger.e('发送认证请求失败', error: e);
      return false;
    }
  }

  /// 模拟认证响应
  void _simulateAuthResponse(AuthRequest request) {
    _logger.i('生成模拟认证响应', extra: {'operationType': request.operationType.name});

    // 创建模拟响应
    final response = AuthResponse();

    // 模拟不同操作类型的响应
    switch (request.operationType) {
      case AuthOperationType.login:
        _simulateLoginResponse(request, response);
        break;
      case AuthOperationType.register:
        _simulateRegisterResponse(request, response);
        break;
      case AuthOperationType.send_code:
        _simulateSendCodeResponse(request, response);
        break;
      case AuthOperationType.reset_password:
        _simulateResetPasswordResponse(request, response);
        break;
      default:
        response.success = false;
        response.message = '不支持的操作类型';
    }

    // 发送模拟响应
    _handleAuthResponse(response);
  }

  /// 模拟登录响应
  void _simulateLoginResponse(AuthRequest request, AuthResponse response) {
    // 模拟简单的登录验证
    final isValidPhone = request.phoneNumber.length == 11 && request.phoneNumber.startsWith('1');
    final isValidCode = request.isQuickLogin && request.verificationCode == '123456';
    final isValidPassword = !request.isQuickLogin && request.password.length >= 6;

    if (isValidPhone && (isValidCode || isValidPassword)) {
      response.success = true;
      response.message = '登录成功';
      response.userId = 'user_${request.phoneNumber}';
      response.token = 'token_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      response.success = false;

      if (!isValidPhone) {
        response.message = '无效的手机号';
      } else if (request.isQuickLogin && !isValidCode) {
        response.message = '验证码错误';
      } else {
        response.message = '密码错误';
      }
    }
  }

  /// 模拟注册响应
  void _simulateRegisterResponse(AuthRequest request, AuthResponse response) {
    // 模拟简单的注册验证
    final isValidPhone = request.phoneNumber.length == 11 && request.phoneNumber.startsWith('1');
    final isValidCode = request.verificationCode == '123456';
    final isValidPassword = request.password.length >= 6;
    final isValidNickname = request.nickname.isNotEmpty;

    if (isValidPhone && isValidCode && isValidPassword && isValidNickname) {
      response.success = true;
      response.message = '注册成功';
      response.userId = 'user_${request.phoneNumber}';
      response.token = 'token_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      response.success = false;

      if (!isValidPhone) {
        response.message = '无效的手机号';
      } else if (!isValidCode) {
        response.message = '验证码错误';
      } else if (!isValidPassword) {
        response.message = '密码长度不足';
      } else {
        response.message = '昵称不能为空';
      }
    }
  }

  /// 模拟发送验证码响应
  void _simulateSendCodeResponse(AuthRequest request, AuthResponse response) {
    // 模拟验证码发送
    final isValidPhone = request.phoneNumber.length == 11 && request.phoneNumber.startsWith('1');

    if (isValidPhone) {
      response.success = true;
      response.message = '验证码发送成功，模拟验证码为: 123456';
    } else {
      response.success = false;
      response.message = '无效的手机号';
    }
  }

  /// 模拟重置密码响应
  void _simulateResetPasswordResponse(AuthRequest request, AuthResponse response) {
    // 模拟重置密码验证
    final isValidPhone = request.phoneNumber.length == 11 && request.phoneNumber.startsWith('1');
    final isValidCode = request.verificationCode == '123456';
    final isValidPassword = request.password.length >= 6;

    if (isValidPhone && isValidCode && isValidPassword) {
      response.success = true;
      response.message = '密码重置成功';
    } else {
      response.success = false;

      if (!isValidPhone) {
        response.message = '无效的手机号';
      } else if (!isValidCode) {
        response.message = '验证码错误';
      } else {
        response.message = '新密码长度不足';
      }
    }
  }

  /// 销毁资源
  void dispose() {
    _authResponseController.close();
  }
}
