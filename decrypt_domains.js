#!/usr/bin/env node
/**
 * 域名解密工具 - 解密 assets/encrypted_domains.dat
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

class DomainDecryptor {
  constructor() {
    this.encryptionKey = 'CC_LOGIN_DOMAINS_AES128_KEY_2025';
    this.aesBlockSize = 16;
  }

  // 生成AES-128密钥
  generateAES128Key() {
    const keyBytes = Buffer.from(this.encryptionKey, 'utf8');
    const hash = crypto.createHash('sha256').update(keyBytes).digest();
    return hash.slice(0, 16); // 取前16字节
  }

  // AES-128-CBC解密
  aesDecryptCBC(encryptedData, key, iv) {
    try {
      const decipher = crypto.createDecipheriv('aes-128-cbc', key, iv);
      let decrypted = decipher.update(encryptedData);
      decrypted = Buffer.concat([decrypted, decipher.final()]);
      return decrypted;
    } catch (error) {
      throw new Error(`解密失败: ${error.message}`);
    }
  }

  // 解密文件
  decryptFile(encryptedFilePath) {
    try {
      if (!fs.existsSync(encryptedFilePath)) {
        throw new Error(`加密文件不存在: ${encryptedFilePath}`);
      }

      const encryptedContent = fs.readFileSync(encryptedFilePath);
      
      if (encryptedContent.length < this.aesBlockSize) {
        throw new Error('加密文件太小，无法包含有效的IV');
      }

      // 提取IV和加密数据
      const iv = encryptedContent.slice(0, this.aesBlockSize);
      const encryptedData = encryptedContent.slice(this.aesBlockSize);

      // 解密
      const key = this.generateAES128Key();
      const decrypted = this.aesDecryptCBC(encryptedData, key, iv);

      // 解析JSON
      const jsonContent = decrypted.toString('utf8');
      return JSON.parse(jsonContent);
    } catch (error) {
      throw new Error(`解密域名文件失败: ${error.message}`);
    }
  }
}

// 导出给其他模块使用
module.exports = { DomainDecryptor };

// 如果直接运行此脚本
if (require.main === module) {
  const decryptor = new DomainDecryptor();
  const encryptedFile = path.join(__dirname, 'assets', 'encrypted_domains.dat');
  
  try {
    const domains = decryptor.decryptFile(encryptedFile);
    console.log('🔓 解密成功:');
    console.log(JSON.stringify(domains, null, 2));
  } catch (error) {
    console.error('❌ 解密失败:', error.message);
    process.exit(1);
  }
}