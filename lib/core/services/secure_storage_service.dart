import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cc/core/database/drift_database.dart';
import 'log_service.dart';

// 条件导入：根据平台导入不同的安全存储实现
import 'secure_storage_stub.dart'
    if (dart.library.io) 'secure_storage_io.dart'
    if (dart.library.html) 'secure_storage_web.dart';

/// 安全存储服务单例类
///
/// 提供跨平台的安全存储功能，仅使用系统提供的安全存储：
/// - iOS: Keychain
/// - Android: Keystore + EncryptedSharedPreferences
/// - 其他平台: FlutterSecureStorage默认实现
class SecureStorageService {
  // 单例实例
  static final SecureStorageService _instance = SecureStorageService._internal();

  /// 获取单例实例
  factory SecureStorageService() => _instance;

  // 日志器
  static final _logger = LogService.instance;

  // Flutter Secure Storage实例 - 平台特定配置
  static final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // 检查是否应该使用fallback模式
  static bool get _shouldUseFallback {
    // 使用平台特定的实现
    return shouldUseFallback();
  }

  // 私有构造函数
  SecureStorageService._internal();

  /// 存储字符串值
  ///
  /// 将键值对安全存储到Keychain
  ///
  /// 参数:
  /// - key: 存储键名
  /// - value: 存储的字符串值
  Future<void> write(String key, String value) async {
    // 如果预知需要使用fallback，直接使用SharedPreferences
    if (_shouldUseFallback) {
      _logger.i('使用SharedPreferences存储 (${getPlatformName()}平台)', extra: {'key': key});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('secure_$key', value);
      return;
    }
    
    try {
      await _storage.write(key: key, value: value);
      _logger.d('Keychain写入成功', extra: {'key': key});
    } catch (e) {
      _logger.w('Keychain写入失败，使用SharedPreferences fallback', extra: {'key': key, 'error': e.toString()});
      try {
        // 使用SharedPreferences作为fallback
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('secure_$key', value);
        _logger.d('SharedPreferences fallback写入成功', extra: {'key': key});
      } catch (fallbackError) {
        _logger.e('所有存储方式都失败', error: e, stackTrace: StackTrace.current);
        rethrow;
      }
    }
  }

  /// 读取字符串值
  ///
  /// 根据键名从Keychain读取值
  ///
  /// 参数:
  /// - key: 存储键名
  ///
  /// 返回:
  /// - 字符串值，如果不存在或Keychain不可访问则返回null
  Future<String?> read(String key) async {
    // 如果预知需要使用fallback，直接使用SharedPreferences
    if (_shouldUseFallback) {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString('secure_$key');
      if (value != null) {
        _logger.d('从SharedPreferences读取成功 (${getPlatformName()}平台)', extra: {'key': key});
      }
      return value;
    }
    
    try {
      final value = await _storage.read(key: key);
      return value;
    } catch (e) {
      _logger.w('Keychain读取失败，尝试SharedPreferences fallback', extra: {'key': key, 'error': e.toString()});
      
      try {
        // 使用SharedPreferences作为fallback
        final prefs = await SharedPreferences.getInstance();
        final value = prefs.getString('secure_$key');
        if (value != null) {
          _logger.d('SharedPreferences fallback读取成功', extra: {'key': key});
        }
        return value;
      } catch (fallbackError) {
        _logger.w('SharedPreferences fallback也失败', extra: {'key': key, 'error': fallbackError.toString()});
        return null;
      }
    }
  }

  /// 删除存储的值
  ///
  /// 根据键名从Keychain删除值
  ///
  /// 参数:
  /// - key: 存储键名
  Future<void> delete(String key) async {
    // 如果预知需要使用fallback，直接使用SharedPreferences
    if (_shouldUseFallback) {
      _logger.i('使用SharedPreferences删除 (${getPlatformName()}平台)', extra: {'key': key});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('secure_$key');
      return;
    }
    
    try {
      await _storage.delete(key: key);
      _logger.d('Keychain删除成功', extra: {'key': key});
    } catch (e) {
      _logger.w('Keychain删除失败，使用SharedPreferences fallback', extra: {'key': key, 'error': e.toString()});
      try {
        // 使用SharedPreferences作为fallback
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('secure_$key');
        _logger.d('SharedPreferences fallback删除成功', extra: {'key': key});
      } catch (fallbackError) {
        _logger.e('所有删除方式都失败', error: e, stackTrace: StackTrace.current);
        rethrow;
      }
    }
  }

  /// 清除所有存储的值
  ///
  /// 删除Keychain中的所有应用数据
  Future<void> deleteAll() async {
    // 如果预知需要使用fallback，直接使用SharedPreferences
    if (_shouldUseFallback) {
      _logger.i('使用SharedPreferences清空 (${getPlatformName()}平台)');
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('secure_')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
      _logger.d('SharedPreferences清空完成', extra: {'removedKeys': keys.length});
      return;
    }
    
    try {
      await _storage.deleteAll();
      _logger.i('Keychain已清空');
    } catch (e) {
      _logger.w('Keychain清空失败，使用SharedPreferences fallback', extra: {'error': e.toString()});
      try {
        // 使用SharedPreferences作为fallback
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys().where((key) => key.startsWith('secure_')).toList();
        for (final key in keys) {
          await prefs.remove(key);
        }
        _logger.d('SharedPreferences fallback清空完成', extra: {'removedKeys': keys.length});
      } catch (fallbackError) {
        _logger.e('所有清空方式都失败', error: e, stackTrace: StackTrace.current);
        rethrow;
      }
    }
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
      _logger.e('Keychain对象写入失败', error: e, stackTrace: StackTrace.current);
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
      _logger.e('Keychain对象读取失败', error: e, stackTrace: StackTrace.current);
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

      // 保存完整的用户信息详情
      final userInfo = {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'avatar': currentUser.avatar,
        'phone': currentUser.phone,
        'email': currentUser.email,
        'status': currentUser.status,
        'lastLoginTime': currentUser.lastLoginTime?.millisecondsSinceEpoch,
      };

      await writeObject(keyUserInfo, userInfo);
      _logger.i('用户凭证已保存到Keychain', extra: {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'hasAvatar': currentUser.avatar != null,
        'hasPhone': currentUser.phone != null,
        'hasEmail': currentUser.email != null,
      });
    } catch (e) {
      _logger.e('保存用户凭证失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 读取用户凭证
  ///
  /// 从安全存储中读取用户信息
  ///
  /// 返回:
  /// - CurrentUser对象，如果不存在则返回null
  Future<CurrentUser?> readUserCredentials() async {
    try {
      final userId = await read(keyUserId);
      if (userId == null) {
        _logger.d('Keychain中无用户凭证');
        return null;
      }

      final userInfo = await readObject(keyUserInfo);
      if (userInfo == null) {
        _logger.w('用户信息缺失，清理孤立的userId');
        await delete(keyUserId);
        return null;
      }

      // 从存储的信息中恢复完整的用户对象
      final currentUser = CurrentUser(
        userId: userId,
        name: userInfo['name'] ?? '未知用户', // 提供默认值以避免late初始化错误
        avatar: userInfo['avatar'],
        phone: userInfo['phone'],
        email: userInfo['email'],
        status: userInfo['status'],
        lastLoginTime: userInfo['lastLoginTime'] != null ? DateTime.fromMillisecondsSinceEpoch(userInfo['lastLoginTime']) : null,
        hasSetPassword: userInfo['hasSetPassword'] ?? false,
      );

      _logger.d('从Keychain读取用户凭证成功', extra: {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'hasAvatar': currentUser.avatar != null,
        'hasPhone': currentUser.phone != null,
        'hasEmail': currentUser.email != null,
      });

      return currentUser;
    } catch (e) {
      _logger.e('读取用户凭证失败', error: e, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 清除用户凭证
  ///
  /// 从安全存储中删除所有用户相关信息
  Future<void> clearUserCredentials() async {
    try {
      await delete(keyUserId);
      await delete(keyUserInfo);
      _logger.i('用户凭证已从Keychain清除');
    } catch (e) {
      _logger.e('清除用户凭证失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // === Token 管理 ===

  /// 保存 Refresh Token
  Future<void> saveRefreshToken(String token, DateTime expireTime) async {
    try {
      _logger.d('保存Refresh Token到Keychain', extra: {
        'tokenLength': token.length,
        'expireTime': expireTime.toIso8601String(),
        'validForDays': expireTime.difference(DateTime.now()).inDays,
      });

      await write(keyRefreshToken, token);
      await write(keyRefreshTokenExpireTime, expireTime.toIso8601String());

      _logger.d('Refresh Token已成功保存到Keychain');
    } catch (e) {
      _logger.e('保存Refresh Token失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 保存 Socket Token
  Future<void> saveSocketToken(String token, DateTime expireTime) async {
    try {
      _logger.d('保存Socket Token到Keychain', extra: {
        'tokenLength': token.length,
        'expireTime': expireTime.toIso8601String(),
        'validForHours': expireTime.difference(DateTime.now()).inHours,
      });

      await write(keySocketToken, token);
      await write(keySocketTokenExpireTime, expireTime.toIso8601String());

      _logger.d('Socket Token已成功保存到Keychain');
    } catch (e) {
      _logger.e('保存Socket Token失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取 Refresh Token
  Future<String?> getRefreshToken() async {
    final token = await read(keyRefreshToken);
    if (token != null) {
      _logger.d('从Keychain读取到Refresh Token', extra: {
        'tokenLength': token.length,
      });
    } else {
      _logger.d('Keychain中未找到Refresh Token');
    }
    return token;
  }

  /// 获取 Refresh Token 过期时间
  Future<DateTime?> getRefreshTokenExpiry() async => getRefreshTokenExpireTime();

  /// 获取 Refresh Token 过期时间
  Future<DateTime?> getRefreshTokenExpireTime() async {
    final expireTimeStr = await read(keyRefreshTokenExpireTime);
    if (expireTimeStr == null) return null;
    try {
      return DateTime.parse(expireTimeStr);
    } catch (e) {
      _logger.e('解析Refresh Token过期时间失败', error: e);
      return null;
    }
  }

  /// 获取 Socket Token
  Future<String?> getSocketToken() async {
    final token = await read(keySocketToken);
    if (token != null) {
      _logger.d('从Keychain读取到Socket Token',
          extra: {
            'tokenLength': token.length,
          },
          stackTrace: StackTrace.current);
    } else {
      _logger.d('Keychain中未找到Socket Token');
    }
    return token;
  }

  /// 获取 Socket Token 过期时间
  Future<DateTime?> getSocketTokenExpiry() async => getSocketTokenExpireTime();

  /// 获取 Socket Token 过期时间
  Future<DateTime?> getSocketTokenExpireTime() async {
    final expireTimeStr = await read(keySocketTokenExpireTime);
    if (expireTimeStr == null) return null;
    try {
      return DateTime.parse(expireTimeStr);
    } catch (e) {
      _logger.e('解析Socket Token过期时间失败', error: e);
      return null;
    }
  }

  /// 检查 Refresh Token 是否有效
  Future<bool> isRefreshTokenValid() async {
    try {
      final token = await getRefreshToken();
      if (token == null) return false;

      final expireTime = await getRefreshTokenExpireTime();
      if (expireTime == null) return false;

      final isValid = DateTime.now().isBefore(expireTime);
      final timeUntilExpiry = expireTime.difference(DateTime.now()).inDays;

      _logger.d('Refresh Token有效性检查', extra: {
        'hasToken': true,
        'expireTime': expireTime.toIso8601String(),
        'currentTime': DateTime.now().toIso8601String(),
        'isValid': isValid,
        'timeUntilExpiry': timeUntilExpiry,
      });

      return isValid;
    } catch (e) {
      _logger.e('检查Refresh Token有效性失败', error: e);
      return false;
    }
  }

  /// 检查 Socket Token 是否有效
  Future<bool> isSocketTokenValid() async {
    try {
      final token = await getSocketToken();
      if (token == null) return false;

      final expireTime = await getSocketTokenExpireTime();
      if (expireTime == null) return false;

      final isValid = DateTime.now().isBefore(expireTime);
      final timeUntilExpiry = expireTime.difference(DateTime.now()).inDays;

      _logger.d('Socket Token有效性检查', extra: {
        'hasToken': true,
        'expireTime': expireTime.toIso8601String(),
        'currentTime': DateTime.now().toIso8601String(),
        'isValid': isValid,
        'timeUntilExpiry': timeUntilExpiry,
      });

      return isValid;
    } catch (e) {
      _logger.e('检查Socket Token有效性失败', error: e);
      return false;
    }
  }

  /// 清除所有Token
  Future<void> clearAllTokens() async {
    try {
      await delete(keyRefreshToken);
      await delete(keyRefreshTokenExpireTime);
      await delete(keySocketToken);
      await delete(keySocketTokenExpireTime);
      _logger.i('所有Token已从Keychain清除');
    } catch (e) {
      _logger.e('清除所有Token失败', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 一次性清理方法
  ///
  /// 彻底清除可能残留的旧数据和冗余数据
  Future<void> performOneTimeCleanup() async {
    try {
      // 清理可能残留的旧JWT字段
      await delete('keyToken');
      await delete('keyTokenExpireTime');

      _logger.i('一次性清理完成');
    } catch (e) {
      _logger.w('一次性清理过程中发生错误', extra: {'error': e.toString()});
      // 不抛出异常，清理错误不应影响应用启动
    }
  }

  // === 存储键名常量 ===

  /// 用户ID存储键
  static const String keyUserId = 'user_id';

  /// 用户信息存储键
  static const String keyUserInfo = 'user_info';

  /// Refresh Token存储键
  static const String keyRefreshToken = 'refresh_token';

  /// Refresh Token过期时间存储键
  static const String keyRefreshTokenExpireTime = 'refresh_token_expire_time';

  /// Socket Token存储键
  static const String keySocketToken = 'socket_token';

  /// Socket Token过期时间存储键
  static const String keySocketTokenExpireTime = 'socket_token_expire_time';
}
