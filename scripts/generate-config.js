#!/usr/bin/env node
/**
 * 生成开发环境配置文件
 */

const fs = require('fs');
const path = require('path');

// 读取环境文件
function loadEnvFile(filePath) {
  try {
    const envContent = fs.readFileSync(filePath, 'utf8');
    const envVars = {};
    
    envContent.split('\n').forEach(line => {
      line = line.trim();
      if (line && !line.startsWith('#')) {
        const [key, ...valueParts] = line.split('=');
        if (key && valueParts.length > 0) {
          envVars[key.trim()] = valueParts.join('=').trim();
        }
      }
    });
    
    return envVars;
  } catch (error) {
    return {};
  }
}

// 生成配置文件
function generateConfig() {
  // 加载环境文件（优先级：.env.dev > .env）
  const projectRoot = path.join(__dirname, '..');
  const envDevPath = path.join(projectRoot, '.env.dev');
  const envPath = path.join(projectRoot, '.env');
  
  let envVars = {};
  if (fs.existsSync(envDevPath)) {
    console.log('📁 加载开发环境文件: .env.dev');
    envVars = loadEnvFile(envDevPath);
  } else if (fs.existsSync(envPath)) {
    console.log('📁 加载环境文件: .env');
    envVars = loadEnvFile(envPath);
  } else {
    console.log('⚠️  未找到环境文件，使用默认配置');
  }
  
  // 获取字体服务URL并确保以/结尾
  let fontServiceUrl = envVars.FONT_SERVICE_URL || 'http://localhost:7002/';
  if (!fontServiceUrl.endsWith('/')) {
    fontServiceUrl += '/';
  }
  
  const config = {
    fontService: {
      baseUrl: fontServiceUrl
    }
  };
  
  const configPath = path.join(projectRoot, 'web', 'app-config.json');
  
  try {
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    console.log(`✅ 配置文件已生成: ${configPath}`);
    console.log(`   FONT_SERVICE_URL: "${config.fontService.baseUrl}"`);
  } catch (error) {
    console.error(`❌ 生成配置文件失败: ${error.message}`);
    process.exit(1);
  }
}

generateConfig();