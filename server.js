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

// 用于Google Fonts代理
let fetch;
try {
  fetch = require('node-fetch');
} catch (e) {
  console.warn('⚠️  node-fetch未安装，Google Fonts代理功能将不可用');
}

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

// 字体缓存配置
const CACHE_DIR = path.join(__dirname, 'cache');
const CHARACTER_SETS_DIR = path.join(__dirname, 'character-sets');

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
    
    // Safari兼容性：检测Safari浏览器并调整安全头
    const userAgent = req?.headers['user-agent'] || '';
    const isSafari = /safari/i.test(userAgent) && !/chrome/i.test(userAgent);
    
    // 开发环境：完全禁用COOP/COEP头以避免跨域问题
    if (req && !DISABLE_CORS_HEADERS && NODE_ENV !== 'development') {
      const isSecureContext = req.connection.encrypted || 
                            req.headers.host?.includes('localhost') || 
                            req.headers.host?.includes('127.0.0.1');
      
      if (isSecureContext && !isSafari) {
        headers['Cross-Origin-Embedder-Policy'] = 'require-corp';
        headers['Cross-Origin-Opener-Policy'] = 'same-origin';
      } else if (isSafari) {
        headers['Cross-Origin-Embedder-Policy'] = 'cross-origin';
        headers['Cross-Origin-Opener-Policy'] = 'same-origin-allow-popups';
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

// 确保缓存目录存在
async function ensureCacheDir() {
  try {
    await fs.promises.access(CACHE_DIR);
  } catch {
    await fs.promises.mkdir(CACHE_DIR, { recursive: true });
  }
}

// Google Fonts代理服务
async function handleGoogleFontsProxy(req, res, fontFamily, version, filename) {
  if (!fetch) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Google Fonts代理功能需要安装node-fetch');
    return;
  }

  const googleFontsUrl = `https://fonts.gstatic.com/s/${fontFamily}/${version}/${filename}`;
  
  console.log(`🔄 字体代理请求: ${fontFamily}/${version}/${filename}`);
  
  // 生成缓存键
  const cacheKey = crypto.createHash('md5')
    .update(`${fontFamily}:${version}:${filename}`)
    .digest('hex');
  
  try {
    // 从混合缓存获取
    const cachedFont = await fontCache.get(cacheKey);
    
    if (cachedFont) {
      // 设置响应头
      res.writeHead(200, {
        'Content-Type': 'font/woff2',
        'Cache-Control': 'public, max-age=31536000',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'X-Font-Source': 'hybrid-cache',
        'X-Cache-Status': 'hit'
      });
      
      res.end(cachedFont);
      return;
    }
    
    // 缓存未命中，从Google获取
    console.log(`🌐 从Google获取: ${googleFontsUrl}`);
    
    const response = await fetch(googleFontsUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      },
      timeout: 15000 // 15秒超时
    });
    
    if (!response.ok) {
      console.error(`❌ Google Fonts返回 ${response.status} 对于 ${filename}`);
      res.writeHead(response.status, { 'Content-Type': 'text/plain' });
      res.end('Font not found at Google Fonts');
      return;
    }
    
    // 获取字体数据
    const fontBuffer = await response.buffer();
    
    // 保存到混合缓存
    await fontCache.set(cacheKey, fontBuffer);
    console.log(`💾 已缓存字体: ${filename} (${fontBuffer.length} 字节)`);
    
    // 设置响应头
    res.writeHead(200, {
      'Content-Type': 'font/woff2',
      'Cache-Control': 'public, max-age=31536000',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'X-Font-Source': 'google-fonts-proxy',
      'X-Cache-Status': 'miss',
      'X-Original-URL': googleFontsUrl
    });
    
    console.log(`✅ 代理并缓存: ${filename}`);
    res.end(fontBuffer);
    
  } catch (error) {
    console.error('❌ 字体代理错误:', error.message);
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('获取字体失败: ' + error.message);
  }
}

// 字体子集API
async function handleFontSubset(req, res) {
  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });
  
  req.on('end', async () => {
    try {
      const { text, fontFamily = 'NotoSansCJK' } = JSON.parse(body);
      
      if (!text) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '需要text参数' }));
        return;
      }

      // 生成缓存键
      const cacheKey = crypto.createHash('md5')
        .update(`${fontFamily}:${text}`)
        .digest('hex');
      
      const cacheFile = path.join(CACHE_DIR, `${cacheKey}.woff2`);
      
      // 检查缓存
      try {
        await fs.promises.access(cacheFile);
        const fontData = await fs.promises.readFile(cacheFile);
        
        res.writeHead(200, {
          'Content-Type': 'font/woff2',
          'Cache-Control': 'public, max-age=31536000',
          'Access-Control-Allow-Origin': '*'
        });
        
        if (LOG_LEVEL === 'debug') {
          console.log(`缓存命中: ${text.substring(0, 20)}...`);
        }
        
        res.end(fontData);
        return;
      } catch {
        // 缓存未命中，继续处理
      }

      // 模拟字体子集生成（实际项目中需要使用真实的字体子集工具）
      const mockFontData = Buffer.from(`模拟字体数据-${text}`);
      
      // 保存到缓存
      await fs.promises.writeFile(cacheFile, mockFontData);
      
      res.writeHead(200, {
        'Content-Type': 'font/woff2',
        'Cache-Control': 'public, max-age=31536000',
        'Access-Control-Allow-Origin': '*'
      });
      
      if (LOG_LEVEL === 'debug') {
        console.log(`生成子集: ${text.substring(0, 20)}...`);
      }
      
      res.end(mockFontData);
      
    } catch (error) {
      console.error('字体子集错误:', error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: '服务器内部错误' }));
    }
  });
}

// 统一的请求处理函数
function handleRequest(req, res) {
  const parsedUrl = url.parse(req.url);
  let pathname = parsedUrl.pathname;
  
  // CORS预检请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      'Access-Control-Max-Age': '86400'
    });
    res.end();
    return;
  }
  
  // Google Fonts代理路由
  if (pathname.match(/^\/([a-zA-Z0-9-]+)\/(v\d+)\/([^\/]+\.woff2)$/)) {
    const match = pathname.match(/^\/([a-zA-Z0-9-]+)\/(v\d+)\/([^\/]+\.woff2)$/);
    const [, fontFamily, version, filename] = match;
    handleGoogleFontsProxy(req, res, fontFamily, version, filename);
    return;
  }
  
  // 兼容/fonts/前缀的Google Fonts路由
  if (pathname.startsWith('/fonts/')) {
    const fontPath = pathname.substring(7); // 移除'/fonts/'
    if (fontPath.match(/^([a-zA-Z0-9-]+)\/(v\d+)\/([^\/]+\.woff2)$/)) {
      const match = fontPath.match(/^([a-zA-Z0-9-]+)\/(v\d+)\/([^\/]+\.woff2)$/);
      const [, fontFamily, version, filename] = match;
      handleGoogleFontsProxy(req, res, fontFamily, version, filename);
      return;
    }
  }
  
  // 字体子集API
  if (pathname === '/subset' && req.method === 'POST') {
    handleFontSubset(req, res);
    return;
  }
  
  // 缓存状态API
  if (pathname === '/cache/stats') {
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify({
      status: 'success',
      data: fontCache.getStats(),
      timestamp: new Date().toISOString()
    }));
    return;
  }
  
  // 字体清单API
  if (pathname === '/manifest') {
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify({
      fonts: [
        {
          family: 'NotoSansCJK',
          variants: ['regular', 'bold'],
          format: 'woff2'
        }
      ],
      version: '1.0.0'
    }));
    return;
  }
  
  // 字符集文件服务
  if (pathname.startsWith('/character-sets/')) {
    const filePath = path.join(__dirname, pathname);
    fs.access(filePath, fs.constants.F_OK, (err) => {
      if (err) {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('文件不存在');
        return;
      }
      
      const ext = path.extname(filePath).toLowerCase();
      const headers = {
        'Access-Control-Allow-Origin': '*',
        'Cache-Control': 'public, max-age=3600' // 1小时缓存
      };
      
      if (ext === '.js') {
        headers['Content-Type'] = 'application/javascript; charset=utf-8';
      } else if (ext === '.txt') {
        headers['Content-Type'] = 'text/plain; charset=utf-8';
      }
      
      res.writeHead(200, headers);
      fs.createReadStream(filePath).pipe(res);
    });
    return;
  }
  
  // 健康检查
  if (pathname === '/health') {
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      environment: NODE_ENV,
      cache: fontCache.getStats()
    }));
    return;
  }
  
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
  webDir: 'build/web',
  enableFontProxy: true  // 启用字体代理功能
};

// 双层缓存系统 (内存 + 磁盘)
class FontCache {
  constructor() {
    // L1: 内存缓存 (按体积限制)
    this.memoryCache = new Map();
    this.maxMemorySize = 128 * 1024 * 1024; // 128MB内存限制
    this.currentMemorySize = 0;
    this.accessOrder = new Map(); // LRU跟踪
  }
  
  async get(key) {
    // L1: 检查内存缓存
    if (this.memoryCache.has(key)) {
      this.updateAccessOrder(key);
      if (LOG_LEVEL === 'debug') {
        console.log(`💾 内存缓存命中: ${key} (${this.formatSize(this.currentMemorySize)}已使用)`);
      }
      return this.memoryCache.get(key);
    }
    
    // L2: 检查磁盘缓存
    try {
      const cacheFile = path.join(CACHE_DIR, `font_${key}.woff2`);
      const cached = await fs.promises.readFile(cacheFile);
      console.log(`💿 磁盘缓存命中: ${key} (${this.formatSize(cached.length)})`);
      
      // 提升到内存缓存
      this.setMemory(key, cached);
      
      return cached;
    } catch {
      return null;
    }
  }
  
  async set(key, data) {
    // 保存到内存缓存
    this.setMemory(key, data);
    
    // 异步保存到磁盘
    const cacheFile = path.join(CACHE_DIR, `font_${key}.woff2`);
    fs.promises.writeFile(cacheFile, data).catch(console.error);
  }
  
  setMemory(key, data) {
    const dataSize = data.length;
    
    // 如果单个文件太大，不放入内存缓存
    if (dataSize > this.maxMemorySize * 0.5) {
      console.log(`⚠️ 字体文件太大，不放入内存缓存: ${this.formatSize(dataSize)}`);
      return;
    }
    
    // 腾出空间
    this.freeMemorySpace(dataSize);
    
    // 添加到缓存
    this.memoryCache.set(key, data);
    this.currentMemorySize += dataSize;
    this.updateAccessOrder(key);
    
    if (LOG_LEVEL === 'debug') {
      console.log(`💾 已缓存到内存: ${key} (${this.formatSize(dataSize)}, 总计: ${this.formatSize(this.currentMemorySize)})`);
    }
  }
  
  freeMemorySpace(requiredSize) {
    while (this.currentMemorySize + requiredSize > this.maxMemorySize && this.memoryCache.size > 0) {
      // LRU淘汰最久未使用的
      const oldestKey = this.accessOrder.keys().next().value;
      const oldData = this.memoryCache.get(oldestKey);
      
      this.memoryCache.delete(oldestKey);
      this.accessOrder.delete(oldestKey);
      this.currentMemorySize -= oldData.length;
      
      console.log(`🗑️ 从内存中移除: ${oldestKey} (${this.formatSize(oldData.length)})`);
    }
  }
  
  updateAccessOrder(key) {
    // 删除后重新添加到末尾 (最新访问)
    this.accessOrder.delete(key);
    this.accessOrder.set(key, Date.now());
  }
  
  formatSize(bytes) {
    if (bytes < 1024) return bytes + 'B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + 'KB';
    return (bytes / (1024 * 1024)).toFixed(1) + 'MB';
  }
  
  getStats() {
    return {
      memoryItems: this.memoryCache.size,
      memoryUsed: this.formatSize(this.currentMemorySize),
      memoryLimit: this.formatSize(this.maxMemorySize),
      memoryUsage: ((this.currentMemorySize / this.maxMemorySize) * 100).toFixed(1) + '%'
    };
  }
}

const fontCache = new FontCache();

const server = http.createServer(handleRequest);

// 从环境变量获取配置，提供默认值
const PORT = process.env.PORT || 80;
const HTTPS_PORT = process.env.HTTPS_PORT || 443;
const HOST = process.env.HOST || '0.0.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';
const ENABLE_HTTPS = process.env.ENABLE_HTTPS !== 'false'; // 默认启用HTTPS
const DISABLE_CORS_HEADERS = process.env.DISABLE_CORS_HEADERS === 'true'; // 禁用CORS头部
// 容器内固定SSL证书路径（不使用环境变量，避免被.env.prod覆盖）
const SSL_CERT_PATH = '/app/ssl-certs/fullchain.pem';
const SSL_KEY_PATH = '/app/ssl-certs/privkey.pem';

// Docker容器外部访问地址配置
const EXTERNAL_HTTP_PORT = process.env.EXTERNAL_HTTP_PORT || PORT;
const EXTERNAL_HTTPS_PORT = process.env.EXTERNAL_HTTPS_PORT || HTTPS_PORT;
const EXTERNAL_HOST = process.env.EXTERNAL_HOST || 'localhost';


// 删除了未使用的 getApiServerAddresses() 和 formatServerUrl() 函数

// 启动服务器函数
async function startServer() {
  // 确保缓存目录存在
  await ensureCacheDir();
  
  console.log(`🚀 Node.js Flutter Web 服务器启动成功!`);
  console.log(`🔧 环境: ${NODE_ENV} (实际运行环境)`);
  console.log(`📊 日志级别: ${LOG_LEVEL}`);
  console.log(`📁 目录: ${path.join(__dirname, 'build/web')}`);
  console.log(`💾 缓存目录: ${CACHE_DIR}`);
  
  console.log(``);
  console.log(`🔧 MIME 类型配置:`);
  console.log(`   ✅ .wasm  -> application/wasm`);
  console.log(`   ✅ .js    -> application/javascript`);
  console.log(`   ✅ .css   -> text/css`);
  console.log(`   ✅ .ttf   -> font/ttf`);
  console.log(`   ✅ .woff2 -> font/woff2`);
  console.log(``);
  console.log(`🔧 字体服务:`);
  console.log(`   ✅ Google Fonts代理: 已启用`);
  console.log(`   ✅ 字体缓存系统: 已启用`);
  console.log(`   ✅ 字体子集API: /subset (POST)`);
  console.log(`   ✅ 缓存状态API: /cache/stats`);
  console.log(`   ✅ 字体清单: /manifest`);
  console.log(`   ✅ 字符集: /character-sets/`);
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
  console.log(`🎯 字体服务URL示例:`);
  console.log(`   📝 字体子集: POST http://${EXTERNAL_HOST}:${EXTERNAL_HTTP_PORT}/subset`);
  console.log(`   🌐 Google字体: http://${EXTERNAL_HOST}:${EXTERNAL_HTTP_PORT}/noto-sans-cjk-sc/v26/NotoSansCJKsc-Regular.woff2`);
  console.log(`   📊 缓存状态: http://${EXTERNAL_HOST}:${EXTERNAL_HTTP_PORT}/cache/stats`);
  console.log(``);
  console.log(`👀 观察控制台日志，特别关注 WASM 文件加载`);
  console.log(`按 Ctrl+C 停止服务器`);
}

// 启动HTTP服务器
server.listen(PORT, async () => {
  console.log(`✅ HTTP 服务器启动成功，端口: ${PORT}`);
  await startServer();
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