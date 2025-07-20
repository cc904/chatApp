#!/usr/bin/env dart

/// 域名加密工具
/// 
/// 将项目根目录的 login_domains.json 用 AES-128 加密后放到 assets 目录中

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class DomainEncryptor {
  static const String _encryptionKey = 'CC_LOGIN_DOMAINS_AES128_KEY_2025';
  static const int _aesBlockSize = 16;

  /// 生成AES-128密钥
  Uint8List _generateAES128Key() {
    final keyBytes = utf8.encode(_encryptionKey);
    final digest = sha256.convert(keyBytes);
    return Uint8List.fromList(digest.bytes.take(16).toList());
  }

  /// 生成随机IV
  Uint8List _generateRandomIV() {
    final random = Random.secure();
    final iv = Uint8List(_aesBlockSize);
    for (int i = 0; i < _aesBlockSize; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  /// AES-128-CBC加密
  Uint8List _aesEncryptCBC(Uint8List plaintext, Uint8List key, Uint8List iv) {
    final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
    final keyParam = KeyParameter(key);
    final params = PaddedBlockCipherParameters(
      ParametersWithIV(keyParam, iv),
      null,
    );

    cipher.init(true, params);
    return cipher.process(plaintext);
  }

  /// 加密JSON数据
  String encryptJson(String jsonContent) {
    try {
      final key = _generateAES128Key();
      final iv = _generateRandomIV();
      final plaintext = utf8.encode(jsonContent);

      final ciphertext = _aesEncryptCBC(plaintext, key, iv);
      
      // 组合 IV + 密文
      final combined = Uint8List(iv.length + ciphertext.length);
      combined.setRange(0, iv.length, iv);
      combined.setRange(iv.length, combined.length, ciphertext);

      return base64Encode(combined);
    } catch (error) {
      throw '加密失败: $error';
    }
  }

  /// 处理域名文件
  Future<void> processDomainsFile() async {
    try {
      // 读取源文件
      final sourceFile = File('login_domains.json');
      if (!sourceFile.existsSync()) {
        throw '找不到源文件: login_domains.json';
      }

      final jsonContent = await sourceFile.readAsString();
      
      // 验证JSON格式
      try {
        final domains = jsonDecode(jsonContent) as List;
        if (domains.isEmpty) {
          throw '域名列表为空';
        }
        print('✅ 找到 ${domains.length} 个域名');
      } catch (e) {
        throw '无效的JSON格式: $e';
      }

      // 加密JSON内容
      print('🔐 开始AES-128加密...');
      final encryptedData = encryptJson(jsonContent);

      // 确保assets目录存在
      final assetsDir = Directory('assets');
      if (!assetsDir.existsSync()) {
        await assetsDir.create(recursive: true);
        print('📁 创建assets目录');
      }

      // 写入加密文件
      final outputFile = File('assets/encrypted_domains.dat');
      await outputFile.writeAsString(encryptedData);

      print('🎉 加密完成！');
      print('📄 输出文件: ${outputFile.path}');
      print('📊 原文件大小: ${jsonContent.length} 字节');
      print('📊 加密后大小: ${encryptedData.length} 字符');

    } catch (error) {
      print('❌ 处理失败: $error');
      exit(1);
    }
  }

  /// 获取加密密钥（供Dart代码使用）
  static String get encryptionKey => _encryptionKey;
}

Future<void> main() async {
  print('=== 域名加密工具 ===');
  
  final encryptor = DomainEncryptor();
  await encryptor.processDomainsFile();
}