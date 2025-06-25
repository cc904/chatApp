import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cc/core/database/models/current_user.dart';

/// 安全存储服务
///
/// 使用Flutter Secure Storage加密保存敏感数据
/// 提供读取、写入和删除操作的便捷方法
/// 在macOS等平台出现权限问题时回退到SharedPreferences（数据将进行简单编码但不加密）
/// 
/// 📝 存储策略：
/// - SecureStorage：只存储敏感认证信息（userId, token, tokenExpireTime）
/// - Isar数据库：存储用户基本信息（昵称、头像、手机号等）用于快速UI显示
/// 
/// ⚠️ 注意：避免在SecureStorage中存储大量非敏感数据，优先使用数据库
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  final _logger = LogService.instance;

  // 存储键名常量
  static const String keyUserId = 'user_id';
  static const String keyToken = 'token';
  static const String keyUserInfo = 'user_info';
  static const String keyTokenExpireTime = 'token_expire_time';
  static const String keyServerUrl = 'server_url';

  // 单例访问器
  static SecureStorageService get instance => _instance;

  // Flutter Secure Storage实例
  late final FlutterSecureStorage _storage;

  // 是否使用回退存储(SharedPreferences)
  bool _useFallbackStorage = false;
  late SharedPreferences _prefs;

  // 私有构造函数
  SecureStorageService._internal() {
    _initializeStorage();
  }

  void _initializeStorage() {
    try {
      // 配置安全存储选项
      final options = _getPlatformOptions();
      _storage = FlutterSecureStorage(
        aOptions: options.android,
        iOptions: options.iOS,
      );
      _logger.x('安全存储服务初始化完成');
    } catch (e) {
      _logger.e('安全存储服务初始化失败，将使用SharedPreferences作为回退方案',
          error: e, stackTrace: StackTrace.current);
      _useFallbackStorage = true;
      _initializeFallbackStorage();
    }
  }

  // 初始化回退存储(SharedPreferences)
  Future<void> _initializeFallbackStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.i('回退存储(SharedPreferences)初始化完成');
    } catch (e) {
      _logger.e('回退存储初始化失败', error: e, stackTrace: StackTrace.current);
    }
  }

  // 获取各平台的安全存储选项
  _SecureStorageOptions _getPlatformOptions() {
    return _SecureStorageOptions(
      android: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOS: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  /// 存储字符串值
  ///
  /// 将键值对安全存储
  ///
  /// 参数:
  /// - key: 存储键名
  /// - value: 存储的字符串值
  Future<void> write(String key, String value) async {
    try {
      if (_useFallbackStorage) {
        // 使用回退存储
        await _writeFallback(key, value);
        return;
      }

      try {
        await _storage.write(key: key, value: value);
        _logger.d('安全存储写入成功', extra: {'key': key});
      } catch (e) {
        // 如果安全存储失败，切换到回退存储
        _logger.w('安全存储写入失败，切换到回退存储', extra: {'error': e.toString()});
        _useFallbackStorage = true;
        await _initializeFallbackStorage();
        await _writeFallback(key, value);
      }
    } catch (e) {
      _logger.e('存储写入失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // 使用回退存储(SharedPreferences)写入
  Future<void> _writeFallback(String key, String value) async {
    final fallbackKey = 'secure_$key';
    final encodedValue = _encodeFallbackValue(value);
    await _prefs.setString(fallbackKey, encodedValue);
    _logger.d('回退存储写入成功', extra: {'key': key});
  }

  // 简单编码回退存储的值
  String _encodeFallbackValue(String value) {
    // 简单的Base64编码，不是真正的加密
    final bytes = utf8.encode(value);
    return base64Encode(bytes);
  }

  // 解码回退存储的值
  String _decodeFallbackValue(String encodedValue) {
    try {
      final bytes = base64Decode(encodedValue);
      return utf8.decode(bytes);
    } catch (e) {
      _logger.e('解码回退存储值失败', error: e);
      return '';
    }
  }

  /// 读取字符串值
  ///
  /// 根据键名读取安全存储的值
  ///
  /// 参数:
  /// - key: 存储键名
  ///
  /// 返回:
  /// - 字符串值，如果不存在则返回null
  Future<String?> read(String key) async {
    try {
      if (_useFallbackStorage) {
        // 使用回退存储
        return _readFallback(key);
      }

      try {
        final value = await _storage.read(key: key);
        return value;
      } catch (e) {
        // 如果安全存储读取失败，尝试从回退存储读取
        _logger.w('安全存储读取失败，尝试从回退存储读取', extra: {'error': e.toString()});
        _useFallbackStorage = true;
        await _initializeFallbackStorage();
        return _readFallback(key);
      }
    } catch (e) {
      _logger.e('存储读取失败', error: e, stackTrace: StackTrace.current);
      return null;
    }
  }

  // 从回退存储(SharedPreferences)读取
  String? _readFallback(String key) {
    final fallbackKey = 'secure_$key';
    final encodedValue = _prefs.getString(fallbackKey);
    if (encodedValue == null) return null;

    return _decodeFallbackValue(encodedValue);
  }

  /// 删除存储的值
  ///
  /// 根据键名删除安全存储的值
  ///
  /// 参数:
  /// - key: 存储键名
  Future<void> delete(String key) async {
    try {
      if (_useFallbackStorage) {
        // 使用回退存储
        await _deleteFallback(key);
        return;
      }

      try {
        await _storage.delete(key: key);
        _logger.d('安全存储删除成功', extra: {'key': key});
      } catch (e) {
        // 如果安全存储删除失败，尝试从回退存储删除
        _logger.w('安全存储删除失败，尝试从回退存储删除', extra: {'error': e.toString()});
        _useFallbackStorage = true;
        await _initializeFallbackStorage();
        await _deleteFallback(key);
      }
    } catch (e) {
      _logger.e('存储删除失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // 从回退存储(SharedPreferences)删除
  Future<void> _deleteFallback(String key) async {
    final fallbackKey = 'secure_$key';
    await _prefs.remove(fallbackKey);
    _logger.d('回退存储删除成功', extra: {'key': key});
  }

  /// 清除所有存储的值
  ///
  /// 删除安全存储中的所有数据
  Future<void> deleteAll() async {
    try {
      if (_useFallbackStorage) {
        // 使用回退存储
        await _deleteAllFallback();
        return;
      }

      try {
        await _storage.deleteAll();
        _logger.i('安全存储已清空');
      } catch (e) {
        // 如果安全存储清空失败，尝试清空回退存储
        _logger.w('安全存储清空失败，尝试清空回退存储', extra: {'error': e.toString()});
        _useFallbackStorage = true;
        await _initializeFallbackStorage();
        await _deleteAllFallback();
      }
    } catch (e) {
      _logger.e('清空存储失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // 清空回退存储(SharedPreferences)中相关的键
  Future<void> _deleteAllFallback() async {
    final allKeys = _prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('secure_')) {
        await _prefs.remove(key);
      }
    }
    _logger.i('回退存储已清空');
  }

  /// 存储对象
  ///
  /// 将对象转换为JSON并安全存储
  ///
  /// 参数:
  /// - key: 存储键名
  /// - value: 要存储的对象
  Future<void> writeObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await write(key, jsonString);
    } catch (e) {
      _logger.e('安全存储对象写入失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 读取对象
  ///
  /// 读取并解析JSON格式的存储对象
  ///
  /// 参数:
  /// - key: 存储键名
  ///
  /// 返回:
  /// - 解析后的Map对象，如果不存在则返回null
  Future<Map<String, dynamic>?> readObject(String key) async {
    try {
      final jsonString = await read(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('安全存储对象读取失败', error: e, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 保存用户凭证
  ///
  /// 将用户信息保存到安全存储中
  ///
  /// 参数:
  /// - currentUser: 用户信息对象
  Future<void> saveUserCredentials(CurrentUser currentUser) async {
    try {
      // 保存基本凭证
      await write(keyUserId, currentUser.userId);
      await write(keyToken, currentUser.token);

      // 保存过期时间
      if (currentUser.tokenExpireTime != null) {
        await write(keyTokenExpireTime,
            currentUser.tokenExpireTime!.millisecondsSinceEpoch.toString());
      }

      // 保存用户信息详情
      final userInfo = {
        'userId': currentUser.userId,
        'token': currentUser.token,
      };

      // 添加可选字段
      if (currentUser.name.isNotEmpty) {
        userInfo['name'] = currentUser.name;
        await write('userName', currentUser.name);
      }

      if (currentUser.avatar != null && currentUser.avatar!.isNotEmpty) {
        userInfo['avatar'] = currentUser.avatar!;
        await write('userAvatar', currentUser.avatar!);
      }

      if (currentUser.phone != null && currentUser.phone!.isNotEmpty) {
        userInfo['phone'] = currentUser.phone!;
        await write('userPhone', currentUser.phone!);
      }

      if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        userInfo['email'] = currentUser.email!;
        await write('userEmail', currentUser.email!);
      }

      if (currentUser.status != null && currentUser.status!.isNotEmpty) {
        userInfo['status'] = currentUser.status!;
        await write('userStatus', currentUser.status!);
      }

      if (currentUser.lastLoginTime != null) {
        userInfo['lastLoginTime'] =
            currentUser.lastLoginTime!.millisecondsSinceEpoch.toString();
        await write('lastLoginTime',
            currentUser.lastLoginTime!.millisecondsSinceEpoch.toString());
      }

      await writeObject(keyUserInfo, userInfo);

      _logger.i('用户凭证保存成功', extra: {'userId': currentUser.userId});
    } catch (e) {
      _logger.e('保存用户凭证失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取完整用户信息
  ///
  /// 从安全存储中读取完整的用户信息
  ///
  /// 返回:
  /// - 完整的用户信息对象，如果不存在则返回null
  Future<CurrentUser?> getFullUserInfo() async {
    try {
      // 获取基本凭证
      final userId = await getUserId();
      final token = await getToken();

      if (userId == null || token == null) {
        _logger.i('安全存储中未找到用户ID或令牌');
        return null;
      }

      // 创建用户对象
      final user = CurrentUser()
        ..userId = userId
        ..token = token;

      // 获取可选字段
      final name = await read('userName');
      if (name != null && name.isNotEmpty) {
        user.name = name;
      } else {
        user.name = ''; // 确保name不为null
      }

      final avatar = await read('userAvatar');
      if (avatar != null && avatar.isNotEmpty) {
        user.avatar = avatar;
      }

      final phone = await read('userPhone');
      if (phone != null && phone.isNotEmpty) {
        user.phone = phone;
      }

      final email = await read('userEmail');
      if (email != null && email.isNotEmpty) {
        user.email = email;
      }

      final statusStr = await read('userStatus');
      if (statusStr != null && statusStr.isNotEmpty) {
        user.status = statusStr;
      }

      final lastLoginTimeStr = await read('lastLoginTime');
      if (lastLoginTimeStr != null) {
        try {
          final lastLoginTime = int.parse(lastLoginTimeStr);
          user.lastLoginTime =
              DateTime.fromMillisecondsSinceEpoch(lastLoginTime);
        } catch (e) {
          _logger.w('解析lastLoginTime失败', extra: {'error': e.toString()});
        }
      }

      // 获取令牌过期时间
      final expireTime = await getTokenExpireTime();
      if (expireTime != null) {
        user.tokenExpireTime = expireTime;
      }

      _logger.i('从安全存储获取完整用户信息成功', extra: {'userId': userId});
      return user;
    } catch (e) {
      _logger.e('从安全存储获取完整用户信息失败', error: e, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取用户ID
  ///
  /// 从安全存储中读取用户ID
  ///
  /// 返回:
  /// - 用户ID，如果不存在则返回null
  Future<String?> getUserId() async {
    return read(keyUserId);
  }

  /// 获取认证令牌
  ///
  /// 从安全存储中读取认证令牌
  ///
  /// 返回:
  /// - 认证令牌，如果不存在则返回null
  Future<String?> getToken() async {
    return read(keyToken);
  }

  /// 获取令牌过期时间
  ///
  /// 从安全存储中读取令牌过期时间
  ///
  /// 返回:
  /// - 令牌过期时间，如果不存在则返回null
  Future<DateTime?> getTokenExpireTime() async {
    try {
      final timeStr = await read(keyTokenExpireTime);
      if (timeStr == null) return null;

      final timestamp = int.parse(timeStr);
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      _logger.e('读取令牌过期时间失败', error: e, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 检查令牌是否有效
  ///
  /// 检查存储的令牌是否存在且未过期
  ///
  /// 返回:
  /// - true: 令牌有效
  /// - false: 令牌不存在或已过期
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final expireTime = await getTokenExpireTime();
      if (expireTime != null) {
        return expireTime.isAfter(DateTime.now());
      }

      // 如果没有过期时间，假设令牌有效
      return true;
    } catch (e) {
      _logger.e('检查令牌有效性失败', error: e, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 清除用户凭证
  ///
  /// 从安全存储中删除用户ID和认证令牌
  Future<void> clearUserCredentials() async {
    try {
      await delete(keyUserId);
      await delete(keyToken);
      await delete(keyTokenExpireTime);
      await delete(keyUserInfo);

      // 清除扩展的用户信息字段
      await delete('userName');
      await delete('userAvatar');
      await delete('userPhone');
      await delete('userEmail');
      await delete('userStatus');
      await delete('lastLoginTime');

      _logger.i('用户凭证已清除');
    } catch (e) {
      _logger.e('清除用户凭证失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 保存用户信息
  ///
  /// 将用户详细信息保存为JSON对象
  ///
  /// 参数:
  /// - userInfo: 包含用户详细信息的Map
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await writeObject(keyUserInfo, userInfo);
  }

  /// 获取用户信息
  ///
  /// 读取存储的用户详细信息
  ///
  /// 返回:
  /// - 用户信息Map，如果不存在则返回null
  Future<Map<String, dynamic>?> getUserInfo() async {
    return readObject(keyUserInfo);
  }

  /// 保存服务器URL
  ///
  /// 存储应用服务器的URL
  ///
  /// 参数:
  /// - url: 服务器URL
  Future<void> saveServerUrl(String url) async {
    await write(keyServerUrl, url);
  }

  /// 获取服务器URL
  ///
  /// 读取存储的服务器URL
  ///
  /// 返回:
  /// - 服务器URL，如果不存在则返回null
  Future<String?> getServerUrl() async {
    return read(keyServerUrl);
  }
}

// 平台选项辅助类
class _SecureStorageOptions {
  final AndroidOptions android;
  final IOSOptions iOS;

  _SecureStorageOptions({
    required this.android,
    required this.iOS,
  });
}
