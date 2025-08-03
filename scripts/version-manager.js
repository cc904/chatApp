#!/usr/bin/env node

/**
 * 版本管理器
 * 自动递增构建版本号（第三位数字）
 */

const fs = require('fs');
const path = require('path');

const PACKAGE_JSON_PATH = path.join(__dirname, '..', 'package.json');

function incrementBuildVersion(quiet = false) {
  try {
    // 读取 package.json
    const packageJson = JSON.parse(fs.readFileSync(PACKAGE_JSON_PATH, 'utf8'));
    
    // 解析当前版本 (例如: "1.0.5")
    const currentVersion = packageJson.version;
    const versionParts = currentVersion.split('.');
    
    if (versionParts.length !== 3) {
      console.error('❌ 版本号格式错误，应为 x.y.z 格式:', currentVersion);
      process.exit(1);
    }
    
    const major = parseInt(versionParts[0]);
    const minor = parseInt(versionParts[1]);
    let build = parseInt(versionParts[2]);
    
    // 自增构建版本号
    build += 1;
    
    // 生成新版本号
    const newVersion = `${major}.${minor}.${build}`;
    
    // 更新 package.json
    packageJson.version = newVersion;
    fs.writeFileSync(PACKAGE_JSON_PATH, JSON.stringify(packageJson, null, 2) + '\n');
    
    // 只在非静默模式下输出
    if (!quiet) {
      console.log(`📈 版本号已更新: ${currentVersion} → ${newVersion}`);
    }
    
    return {
      oldVersion: currentVersion,
      newVersion: newVersion,
      major,
      minor,
      build
    };
    
  } catch (error) {
    console.error('❌ 版本管理失败:', error.message);
    process.exit(1);
  }
}

function getCurrentVersion() {
  try {
    const packageJson = JSON.parse(fs.readFileSync(PACKAGE_JSON_PATH, 'utf8'));
    return packageJson.version;
  } catch (error) {
    console.error('❌ 获取版本号失败:', error.message);
    process.exit(1);
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const isQuiet = process.argv.includes('--quiet');
  
  if (process.argv.includes('--get-current')) {
    // 只获取当前版本，不递增
    const currentVersion = getCurrentVersion();
    if (isQuiet) {
      console.log(currentVersion);
    } else {
      console.log(`当前版本: ${currentVersion}`);
    }
  } else {
    // 递增版本号
    const result = incrementBuildVersion(isQuiet);
    
    // 输出新版本号供脚本使用
    if (isQuiet) {
      console.log(result.newVersion);
    }
  }
}

module.exports = { incrementBuildVersion, getCurrentVersion };