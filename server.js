#!/usr/bin/env node
/**
 * Node.js 服务器 - 完美支持 Flutter Web 和 WASM
 */

const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');
const url = require('url');
const crypto = require('crypto');

// MIME 类型映射
const mimeTypes = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript', 
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.wav': 'audio/wav',
  '.mp4': 'video/mp4',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',  // 关键！
  '.map': 'application/json'
};

function getMimeType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  return mimeTypes[ext] || 'text/plain';
}

function serveFile(res, filePath, req, statusCode = 200) {
  const mimeType = getMimeType(filePath);
  
  fs.readFile(filePath, (err, data) => {
    if (err) {
      console.log(`❌ 读取文件失败: ${filePath}`);
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('File not found');
      return;
    }
    
    // 设置响应头
    const headers = {
      'Content-Type': mimeType,
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Cross-Origin-Resource-Policy': 'cross-origin'
    };
    
    // 只在HTTPS或localhost环境下设置COOP和COEP头，且未禁用时
    if (req && !DISABLE_CORS_HEADERS) {
      const isSecureContext = req.connection.encrypted || 
                            req.headers.host?.includes('localhost') || 
                            req.headers.host?.includes('127.0.0.1');
      
      if (isSecureContext) {
        headers['Cross-Origin-Embedder-Policy'] = 'require-corp';
        headers['Cross-Origin-Opener-Policy'] = 'same-origin';
      }
    }
    
    res.writeHead(statusCode, headers);
    res.end(data);
    
    // 记录特殊文件类型
    if (filePath.endsWith('.wasm')) {
      const size = data.length;
      console.log(`📦 WASM: ${filePath} (${size.toLocaleString()} bytes) -> ${mimeType}`);
    } else if (filePath.includes('drift') || filePath.includes('sqlite')) {
      console.log(`🗄️  DB: ${filePath} -> ${mimeType}`);
    } else if (filePath.includes('canvaskit')) {
      console.log(`🎨 CanvasKit: ${filePath} -> ${mimeType}`);
    }
  });
}

// 统一的请求处理函数
function handleRequest(req, res) {
  const parsedUrl = url.parse(req.url);
  let pathname = parsedUrl.pathname;
  
  // 处理根路径
  if (pathname === '/') {
    pathname = '/index.html';
  }
  
  // 移除查询参数，映射到实际文件
  let filePath = path.join(__dirname, CONFIG.webDir, pathname);
  
  // 处理Service Worker的版本查询参数
  if (pathname.startsWith('/flutter_service_worker.js')) {
    filePath = path.join(__dirname, CONFIG.webDir, 'flutter_service_worker.js');
    console.log(`⚙️  Service Worker: ${req.url} -> flutter_service_worker.js`);
  }
  
  // 检查文件是否存在
  fs.access(filePath, fs.constants.F_OK, (err) => {
    if (err) {
      console.log(`❌ 文件不存在: ${pathname}`);
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('File not found');
      return;
    }
    
    serveFile(res, filePath, req);
  });
}

// 配置对象
const CONFIG = {
  webDir: 'build/web'
};

const server = http.createServer(handleRequest);

// 从环境变量获取配置，提供默认值
const PORT = process.env.PORT || 80;
const HTTPS_PORT = process.env.HTTPS_PORT || 443;
const HOST = process.env.HOST || '0.0.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';
const ENABLE_HTTPS = process.env.ENABLE_HTTPS !== 'false'; // 默认启用HTTPS
const DISABLE_CORS_HEADERS = process.env.DISABLE_CORS_HEADERS === 'true'; // 禁用CORS头部
const SSL_CERT_PATH = process.env.SSL_CERT_PATH || './ssl-certs/fullchain.pem';
const SSL_KEY_PATH = process.env.SSL_KEY_PATH || './ssl-certs/privkey.pem';

// Docker容器外部访问地址配置
const EXTERNAL_HTTP_PORT = process.env.EXTERNAL_HTTP_PORT || PORT;
const EXTERNAL_HTTPS_PORT = process.env.EXTERNAL_HTTPS_PORT || HTTPS_PORT;
const EXTERNAL_HOST = process.env.EXTERNAL_HOST || 'localhost';


// 删除了未使用的 getApiServerAddresses() 和 formatServerUrl() 函数

// 启动服务器函数
function startServer() {
  console.log(`🚀 Node.js Flutter Web 服务器启动成功!`);
  console.log(`🔧 环境: ${NODE_ENV} (实际运行环境)`);
  console.log(`📊 日志级别: ${LOG_LEVEL}`);
  console.log(`📁 目录: ${path.join(__dirname, 'build/web')}`);
  
  // API服务器地址将在实际使用时显示
  
  console.log(``);
  console.log(`🔧 MIME 类型配置:`);
  console.log(`   ✅ .wasm  -> application/wasm`);
  console.log(`   ✅ .js    -> application/javascript`);
  console.log(`   ✅ .css   -> text/css`);
  console.log(`   ✅ .ttf   -> font/ttf`);
  console.log(``);
  console.log(`📋 关键文件检查:`);
  
  // 检查关键文件
  const criticalFiles = [
    'build/web/index.html',
    'build/web/flutter_bootstrap.js',
    'build/web/flutter_service_worker.js',
    'build/web/main.dart.js',
    'build/web/sqlite3.wasm',
    'build/web/drift_worker.dart.js',
    'build/web/canvaskit/canvaskit.wasm',
    'build/web/canvaskit/skwasm.wasm'
  ];
  
  criticalFiles.forEach(file => {
    const fullPath = path.join(__dirname, file);
    if (fs.existsSync(fullPath)) {
      const stats = fs.statSync(fullPath);
      console.log(`   ✅ ${file.replace('build/web/', '')} (${stats.size.toLocaleString()} bytes)`);
    } else {
      console.log(`   ❌ ${file.replace('build/web/', '')} (缺失)`);
    }
  });
  
  console.log(``);
  console.log(`🌐 服务器访问地址:`);
  console.log(`   📡 HTTP:  http://${EXTERNAL_HOST}:${EXTERNAL_HTTP_PORT}`);
  if (ENABLE_HTTPS) {
    console.log(`   🔒 HTTPS: https://${EXTERNAL_HOST}:${EXTERNAL_HTTPS_PORT}`);
  }
  console.log(`   🏠 内部地址: http://${HOST === '0.0.0.0' ? 'localhost' : HOST}:${PORT}`);
  console.log(``);
  console.log(`👀 观察控制台日志，特别关注 WASM 文件加载`);
  console.log(`按 Ctrl+C 停止服务器`);
}

// 启动HTTP服务器
server.listen(PORT, () => {
  console.log(`✅ HTTP 服务器启动成功，端口: ${PORT}`);
});

// 启动HTTPS服务器（默认启用，除非明确禁用）
if (ENABLE_HTTPS) {
  // 检查SSL证书文件
  if (fs.existsSync(SSL_CERT_PATH) && fs.existsSync(SSL_KEY_PATH)) {
    console.log(`🔐 使用SSL证书: ${SSL_CERT_PATH}`);
    console.log(`🔑 使用SSL私钥: ${SSL_KEY_PATH}`);
    
    const options = {
      key: fs.readFileSync(SSL_KEY_PATH),
      cert: fs.readFileSync(SSL_CERT_PATH)
    };
    
    const httpsServer = https.createServer(options, handleRequest);
    
    httpsServer.listen(HTTPS_PORT, () => {
      console.log(`🔒 HTTPS 服务器启动成功，端口: ${HTTPS_PORT}`);
      // 在HTTPS服务器启动后调用startServer显示完整信息
      startServer();
    });
    
    // 优雅关闭HTTPS服务器
    process.on('SIGINT', () => {
      httpsServer.close();
    });
    
  } else {
    console.error(`❌ SSL证书文件未找到:`);
    console.error(`   📁 证书目录: ${path.dirname(SSL_CERT_PATH)}`);
    console.error(`   🔍 查找证书: ${SSL_CERT_PATH}`);
    console.error(`   🔍 查找私钥: ${SSL_KEY_PATH}`);
    
    // 列出证书目录中的文件
    const certDir = path.dirname(SSL_CERT_PATH);
    try {
      if (fs.existsSync(certDir)) {
        const files = fs.readdirSync(certDir);
        console.error(`   📂 目录中的文件:`);
        if (files.length === 0) {
          console.error(`      (目录为空)`);
        } else {
          files.forEach(file => {
            const filePath = path.join(certDir, file);
            const stats = fs.statSync(filePath);
            const fileType = stats.isDirectory() ? '📁' : '📄';
            console.error(`      ${fileType} ${file}`);
          });
        }
      } else {
        console.error(`   📂 证书目录不存在: ${certDir}`);
      }
    } catch (error) {
      console.error(`   ⚠️  无法读取证书目录: ${error.message}`);
    }
    
    console.error(`   💡 支持格式: .crt, .pem, .key`);
    console.error(`   🔧 HTTPS服务器未启动，仅运行HTTP服务器`);
    // 如果HTTPS启动失败，至少显示HTTP服务器信息
    startServer();
  }
} else {
  // 如果HTTPS被禁用，显示HTTP服务器信息
  startServer();
}

// 优雅关闭
process.on('SIGINT', () => {
  console.log('\n👋 服务器正在关闭...');
  server.close(() => {
    console.log('✅ 服务器已关闭');
    process.exit(0);
  });
});