import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';

/// 后备域名服务
///
/// 从assets中读取AES-128加密的域名文件并解密使用
/// 当安全存储中没有可用的登录服务器时，使用此服务提供后备域名
class BackupDomainService {
  static final BackupDomainService _instance = BackupDomainService._internal();
  static BackupDomainService get instance => _instance;
  BackupDomainService._internal();

  final LogService _logger = LogService.instance;

  // AES-128加密相关配置
  static const String _encryptionKey = 'CC_LOGIN_DOMAINS_AES128_KEY_2025';
  static const String _encryptedFilePath = 'assets/encrypted_domains.dat';
  static const int _aesBlockSize = 16;

  List<String>? _cachedDomains;
  bool _isInitialized = false;

  /// 初始化服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('🔧 初始化后备域名服务');
      await _loadEncryptedDomains();
      _isInitialized = true;
      _logger.i('🔧 后备域名服务初始化完成');
    } catch (error) {
      _logger.e('🔧 初始化后备域名服务失败', error: error);
    }
  }

  /// 从assets加载并解密域名文件
  Future<void> _loadEncryptedDomains() async {
    try {
      _logger.d('🔧 从assets加载加密域名文件');

      // 从assets读取加密文件
      final encryptedData = await rootBundle.loadString(_encryptedFilePath);

      // 解密域名列表
      final decryptedJson = _decryptData(encryptedData);
      final domains = (jsonDecode(decryptedJson) as List).cast<String>();

      // 验证域名格式
      _cachedDomains = domains.where(_isValidDomain).toList();

      _logger.i('🔧 成功解密并加载域名', extra: {
        'totalDomains': domains.length,
        'validDomains': _cachedDomains?.length ?? 0,
      });
    } catch (error) {
      _logger.e('🔧 加载加密域名失败', error: error);

      // 降级使用紧急后备域名
      _cachedDomains = _getEmergencyDomains();
      _logger.w('🔧 使用紧急后备域名', extra: {
        'emergencyDomains': _cachedDomains?.length ?? 0,
      });
    }
  }

  /// AES-128-CBC解密
  String _decryptData(String encryptedBase64) {
    try {
      // 生成密钥
      final key = _generateAES128Key();

      // 解码Base64数据
      final encryptedData = base64Decode(encryptedBase64);

      if (encryptedData.length < _aesBlockSize * 2) {
        throw '加密数据长度不足';
      }

      // 提取IV（前16字节）和密文
      final iv = encryptedData.sublist(0, _aesBlockSize);
      final ciphertext = encryptedData.sublist(_aesBlockSize);

      // 执行AES-128-CBC解密
      final decrypted = _aesDecryptCBC(ciphertext, key, iv);

      return utf8.decode(decrypted);
    } catch (error) {
      _logger.e('AES解密失败', error: error);
      rethrow;
    }
  }

  /// 生成AES-128密钥
  Uint8List _generateAES128Key() {
    final keyBytes = utf8.encode(_encryptionKey);
    final digest = sha256.convert(keyBytes);
    return Uint8List.fromList(digest.bytes.take(16).toList());
  }

  /// AES-128-CBC解密
  Uint8List _aesDecryptCBC(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    try {
      final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final keyParam = KeyParameter(key);
      final params = PaddedBlockCipherParameters(
        ParametersWithIV(keyParam, iv),
        null,
      );

      cipher.init(false, params); // false表示解密模式
      return cipher.process(ciphertext);
    } catch (error) {
      _logger.e('AES-128-CBC解密失败', error: error);
      rethrow;
    }
  }

  /// 验证域名格式
  bool _isValidDomain(String domain) {
    try {
      final uri = Uri.parse(domain);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// 获取紧急后备域名（从加密文件加载失败时使用）
  List<String> _getEmergencyDomains() {
    // 返回空列表，不使用硬编码域名
    // 所有域名都应该从加密文件中获取
    return [];
  }

  /// 获取所有后备域名
  Future<List<String>> getBackupDomains() async {
    await _ensureInitialized();
    return List.from(_cachedDomains ?? []);
  }

  /// 根据可用性检查从安全存储和后备域名中获取完整的登录服务器列表
  Future<List<String>> getCombinedLoginServers() async {
    await _ensureInitialized();

    final servers = <String>[];

    try {
      // 1. 首先尝试从安全存储获取登录服务器
      final storedServers = await _getStoredLoginServers();
      if (storedServers.isNotEmpty) {
        servers.addAll(storedServers);
        _logger.i('🔧 使用安全存储中的登录服务器', extra: {
          'count': storedServers.length,
        });
      }

      // 2. 如果安全存储为空或失效，添加后备域名
      if (servers.isEmpty) {
        _logger.i('🔧 安全存储中无可用登录服务器，使用后备域名', extra: {
          'reason': '存储为空或格式错误',
          'willLoadBackupDomains': true,
        });
        final backupDomains = await getBackupDomains();
        servers.addAll(backupDomains);
        _logger.i('🔧 已加载后备域名', extra: {
          'backupCount': backupDomains.length,
        });
      } else {
        // 3. 即使有存储的服务器，也添加一些后备域名作为补充
        final backupDomains = await getBackupDomains();
        final firstBackup = backupDomains.take(2); // 只添加前两个作为补充
        for (final domain in firstBackup) {
          if (!servers.contains(domain)) {
            servers.add(domain);
          }
        }
      }

      _logger.i('🔧 获取完整登录服务器列表', extra: {
        'totalServers': servers.length,
        'firstServer': servers.isNotEmpty ? servers.first : null,
      });

      return servers;
    } catch (error) {
      _logger.e('🔧 获取登录服务器列表失败', error: error);

      // 发生错误时返回紧急后备域名
      final emergency = _getEmergencyDomains();
      _logger.w('🔧 使用紧急后备域名', extra: {
        'count': emergency.length,
      });

      return emergency;
    }
  }

  /// 从安全存储获取登录服务器
  Future<List<String>> _getStoredLoginServers() async {
    try {
      final secureStorage = SecureStorageService();
      final serversJson = await secureStorage.read('login_servers');

      if (serversJson != null) {
        final decodedData = jsonDecode(serversJson);
        List<String> servers = [];

        // 处理不同的数据格式
        if (decodedData is List) {
          // 新格式：直接是字符串列表
          servers = decodedData.cast<String>();
        } else if (decodedData is Map<String, dynamic>) {
          // 旧格式：可能是对象格式，尝试提取服务器列表
          if (decodedData.containsKey('servers') && decodedData['servers'] is List) {
            servers = (decodedData['servers'] as List).cast<String>();
          } else if (decodedData.containsKey('domains') && decodedData['domains'] is List) {
            servers = (decodedData['domains'] as List).cast<String>();
          } else {
            // 处理空Map或格式不匹配的情况
            if (decodedData.isEmpty) {
              _logger.d('🔧 存储的登录服务器数据为空Map，清理并使用后备域名', extra: {
                'dataType': 'Map',
                'isEmpty': true,
              });
              // 清理损坏的数据
              await _clearCorruptedLoginServers();
            } else {
              // 如果是Map但没有预期的键，记录详细信息
              _logger.w('🔧 存储的登录服务器格式不匹配，清理并使用后备域名', extra: {
                'dataType': 'Map',
                'keys': decodedData.keys.toList(),
                'data': decodedData.toString().length > 200 ? '${decodedData.toString().substring(0, 200)}...' : decodedData.toString(),
              });
              // 清理格式错误的数据
              await _clearCorruptedLoginServers();
            }
            return [];
          }
        } else {
          _logger.w('🔧 存储的登录服务器格式不支持', extra: {
            'dataType': decodedData.runtimeType.toString(),
          });
          return [];
        }

        // 验证服务器URL格式
        final validServers = servers.where(_isValidDomain).toList();

        if (validServers.length != servers.length) {
          _logger.w('🔧 过滤掉无效的存储服务器', extra: {
            'original': servers.length,
            'valid': validServers.length,
          });
        }

        return validServers;
      }

      return [];
    } catch (error) {
      _logger.e('🔧 从安全存储读取登录服务器失败', error: error);
      return [];
    }
  }

  /// 清理损坏的登录服务器数据
  /// 当检测到存储格式错误或空数据时调用
  Future<void> _clearCorruptedLoginServers() async {
    try {
      final secureStorage = SecureStorageService();
      await secureStorage.delete('login_servers');
      _logger.i('🔧 已清理损坏的登录服务器存储数据');
    } catch (error) {
      _logger.e('🔧 清理损坏的登录服务器数据失败', error: error);
    }
  }

  /// 保存登录服务器到安全存储
  /// 确保使用正确的格式（字符串列表）保存
  /// [servers] - 要保存的服务器列表
  Future<void> saveLoginServers(List<String> servers) async {
    try {
      if (servers.isEmpty) {
        _logger.w('🔧 尝试保存空的登录服务器列表');
        return;
      }

      // 验证服务器格式
      final validServers = servers.where(_isValidDomain).toList();
      if (validServers.length != servers.length) {
        _logger.w('🔧 过滤掉无效的服务器', extra: {
          'original': servers.length,
          'valid': validServers.length,
          'invalid': servers.where((s) => !_isValidDomain(s)).toList(),
        });
      }

      if (validServers.isEmpty) {
        _logger.w('🔧 所有服务器都无效，不保存');
        return;
      }

      // 保存为字符串数组格式
      final serversJson = jsonEncode(validServers);
      final secureStorage = SecureStorageService();
      await secureStorage.write('login_servers', serversJson);

      _logger.i('🔧 登录服务器已保存到安全存储', extra: {
        'count': validServers.length,
        'format': 'List<String>',
      });
    } catch (error) {
      _logger.e('🔧 保存登录服务器失败', error: error);
      rethrow;
    }
  }

  /// 获取服务状态信息
  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'domainCount': _cachedDomains?.length ?? 0,
      'encrypted': true,
      'encryptionAlgorithm': 'AES-128-CBC',
      'sourceFile': _encryptedFilePath,
    };
  }

  /// 重新加载配置
  Future<void> reloadConfiguration() async {
    _isInitialized = false;
    _cachedDomains = null;
    await initialize();
    _logger.i('🔧 重新加载后备域名配置');
  }

  /// 确保服务已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}
