#!/usr/bin/env node
/**
 * Node.js 服务器 - 完美支持 Flutter Web 和 WASM
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

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

function serveFile(res, filePath, statusCode = 200) {
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
      'Cross-Origin-Embedder-Policy': 'require-corp',
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Resource-Policy': 'cross-origin'
    };
    
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

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url);
  let pathname = parsedUrl.pathname;
  
  // 处理根路径
  if (pathname === '/') {
    pathname = '/index.html';
  }
  
  // 移除查询参数，映射到实际文件
  let filePath = path.join(__dirname, 'build/web', pathname);
  
  // 处理Service Worker的版本查询参数
  if (pathname.startsWith('/flutter_service_worker.js')) {
    filePath = path.join(__dirname, 'build/web/flutter_service_worker.js');
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
    
    serveFile(res, filePath);
  });
});

// 从环境变量获取配置，提供默认值
const PORT = process.env.PORT || 9014;
const HOST = process.env.HOST || 'localhost';
const NODE_ENV = process.env.NODE_ENV || 'development';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

server.listen(PORT, () => {
  console.log(`🚀 Node.js Flutter Web 服务器启动成功!`);
  console.log(`📡 地址: http://${HOST}:${PORT}`);
  console.log(`🔧 环境: ${NODE_ENV}`);
  console.log(`📊 日志级别: ${LOG_LEVEL}`);
  console.log(`📁 目录: ${path.join(__dirname, 'build/web')}`);
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
  console.log(`🌐 请在浏览器中打开: http://localhost:${PORT}`);
  console.log(`👀 观察控制台日志，特别关注 WASM 文件加载`);
  console.log(`按 Ctrl+C 停止服务器`);
});

// 优雅关闭
process.on('SIGINT', () => {
  console.log('\n👋 服务器正在关闭...');
  server.close(() => {
    console.log('✅ 服务器已关闭');
    process.exit(0);
  });
});