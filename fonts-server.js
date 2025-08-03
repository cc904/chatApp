const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs').promises;
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 7000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

// CORS配置 - 支持多个端口
const corsOptions = {
  origin: [
    'http://localhost:9003',
    'http://localhost:3000', 
    'http://localhost:7000',
    'http://localhost:7002',
    'http://localhost:62878',
    /^http:\/\/localhost:\d+$/
  ],
  credentials: true,
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

app.use(cors(corsOptions));
app.use(express.json());

// 日志中间件
app.use((req, res, next) => {
  if (LOG_LEVEL === 'debug') {
    console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  }
  next();
});

// 缓存配置
const CACHE_DIR = path.join(__dirname, 'cache');
const CHARACTER_SETS_DIR = path.join(__dirname, 'character-sets');

// 双层缓存系统 (内存 + 磁盘)
class FontCache {
  constructor() {
    // L1: 内存缓存 (按体积限制)
    this.memoryCache = new Map();
    this.maxMemorySize = 50 * 1024 * 1024; // 50MB内存限制
    this.currentMemorySize = 0;
    this.accessOrder = new Map(); // LRU跟踪
  }
  
  async get(key) {
    // L1: 检查内存缓存
    if (this.memoryCache.has(key)) {
      this.updateAccessOrder(key);
      console.log(`💾 Memory cache hit: ${key} (${this.formatSize(this.currentMemorySize)} used)`);
      return this.memoryCache.get(key);
    }
    
    // L2: 检查磁盘缓存
    try {
      const cacheFile = path.join(CACHE_DIR, `font_${key}.woff2`);
      const cached = await fs.readFile(cacheFile);
      console.log(`💿 Disk cache hit: ${key} (${this.formatSize(cached.length)})`);
      
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
    fs.writeFile(cacheFile, data).catch(console.error);
  }
  
  setMemory(key, data) {
    const dataSize = data.length;
    
    // 如果单个文件太大，不放入内存缓存
    if (dataSize > this.maxMemorySize * 0.5) {
      console.log(`⚠️ Font too large for memory cache: ${this.formatSize(dataSize)}`);
      return;
    }
    
    // 腾出空间
    this.freeMemorySpace(dataSize);
    
    // 添加到缓存
    this.memoryCache.set(key, data);
    this.currentMemorySize += dataSize;
    this.updateAccessOrder(key);
    
    console.log(`💾 Cached in memory: ${key} (${this.formatSize(dataSize)}, total: ${this.formatSize(this.currentMemorySize)})`);
  }
  
  freeMemorySpace(requiredSize) {
    while (this.currentMemorySize + requiredSize > this.maxMemorySize && this.memoryCache.size > 0) {
      // LRU淘汰最久未使用的
      const oldestKey = this.accessOrder.keys().next().value;
      const oldData = this.memoryCache.get(oldestKey);
      
      this.memoryCache.delete(oldestKey);
      this.accessOrder.delete(oldestKey);
      this.currentMemorySize -= oldData.length;
      
      console.log(`🗑️ Evicted from memory: ${oldestKey} (${this.formatSize(oldData.length)})`);
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

// 确保缓存目录存在
async function ensureCacheDir() {
  try {
    await fs.access(CACHE_DIR);
  } catch {
    await fs.mkdir(CACHE_DIR, { recursive: true });
  }
}

// 字体子集API端点
app.post('/subset', async (req, res) => {
  try {
    const { text, fontFamily = 'NotoSansCJK' } = req.body;
    
    if (!text) {
      return res.status(400).json({ error: 'Text parameter is required' });
    }

    // 生成缓存键
    const cacheKey = crypto.createHash('md5')
      .update(`${fontFamily}:${text}`)
      .digest('hex');
    
    const cacheFile = path.join(CACHE_DIR, `${cacheKey}.woff2`);
    
    // 检查缓存
    try {
      await fs.access(cacheFile);
      const fontData = await fs.readFile(cacheFile);
      
      res.setHeader('Content-Type', 'font/woff2');
      res.setHeader('Cache-Control', 'public, max-age=31536000'); // 1年缓存
      res.setHeader('Access-Control-Allow-Origin', '*');
      
      if (LOG_LEVEL === 'debug') {
        console.log(`Cache hit for: ${text.substring(0, 20)}...`);
      }
      
      return res.send(fontData);
    } catch {
      // 缓存未命中，生成新的字体子集
    }

    // 模拟字体子集生成（实际项目中需要使用真实的字体子集工具）
    const mockFontData = Buffer.from(`mock-font-data-for-${text}`);
    
    // 保存到缓存
    await fs.writeFile(cacheFile, mockFontData);
    
    res.setHeader('Content-Type', 'font/woff2');
    res.setHeader('Cache-Control', 'public, max-age=31536000');
    res.setHeader('Access-Control-Allow-Origin', '*');
    
    if (LOG_LEVEL === 'debug') {
      console.log(`Generated subset for: ${text.substring(0, 20)}...`);
    }
    
    res.send(mockFontData);
    
  } catch (error) {
    console.error('Font subset error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 健康检查端点
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    environment: NODE_ENV,
    cache: fontCache.getStats()
  });
});

// 缓存状态端点
app.get('/cache/stats', (req, res) => {
  res.json({
    status: 'success',
    data: fontCache.getStats(),
    timestamp: new Date().toISOString()
  });
});

// 字体清单端点
app.get('/manifest', (req, res) => {
  res.json({
    fonts: [
      {
        family: 'NotoSansCJK',
        variants: ['regular', 'bold'],
        format: 'woff2'
      }
    ],
    version: '1.0.0'
  });
});

// 字符集文件服务
app.use('/character-sets', express.static(CHARACTER_SETS_DIR, {
  setHeaders: (res, path) => {
    // 设置适当的缓存头
    if (path.endsWith('.js')) {
      res.setHeader('Content-Type', 'application/javascript; charset=utf-8');
      res.setHeader('Cache-Control', 'public, max-age=3600'); // 1小时缓存
    } else if (path.endsWith('.txt')) {
      res.setHeader('Content-Type', 'text/plain; charset=utf-8');
      res.setHeader('Cache-Control', 'public, max-age=3600');
    }
    res.setHeader('Access-Control-Allow-Origin', '*');
  }
}));

// Google Fonts API代理服务 - 混合缓存
// 处理格式: /:fontFamily/:version/:filename
app.get('/:fontFamily/:version/:filename', async (req, res) => {
  const { fontFamily, version, filename } = req.params;
  const googleFontsUrl = `https://fonts.gstatic.com/s/${fontFamily}/${version}/${filename}`;
  
  console.log(`🔄 Font proxy request: ${fontFamily}/${version}/${filename}`);
  
  // 生成缓存键
  const cacheKey = crypto.createHash('md5')
    .update(`${fontFamily}:${version}:${filename}`)
    .digest('hex');
  
  try {
    // 从混合缓存获取
    const cachedFont = await fontCache.get(cacheKey);
    
    if (cachedFont) {
      // 设置响应头
      res.setHeader('Content-Type', 'font/woff2');
      res.setHeader('Cache-Control', 'public, max-age=31536000');
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
      res.setHeader('X-Font-Source', 'hybrid-cache');
      res.setHeader('X-Cache-Status', 'hit');
      
      return res.send(cachedFont);
    }
    
    // 缓存未命中，从Google获取
    console.log(`🌐 Fetching from Google: ${googleFontsUrl}`);
    
    const fetch = require('node-fetch');
    const response = await fetch(googleFontsUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      },
      timeout: 15000 // 15秒超时
    });
    
    if (!response.ok) {
      console.error(`❌ Google Fonts returned ${response.status} for ${filename}`);
      return res.status(response.status).json({ 
        error: 'Font not found at Google Fonts',
        originalStatus: response.status 
      });
    }
    
    // 获取字体数据
    const fontBuffer = await response.buffer();
    
    // 保存到混合缓存
    await fontCache.set(cacheKey, fontBuffer);
    console.log(`💾 Cached font: ${filename} (${fontBuffer.length} bytes)`);
    
    // 设置响应头
    res.setHeader('Content-Type', 'font/woff2');
    res.setHeader('Cache-Control', 'public, max-age=31536000');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('X-Font-Source', 'google-fonts-proxy');
    res.setHeader('X-Cache-Status', 'miss');
    res.setHeader('X-Original-URL', googleFontsUrl);
    
    console.log(`✅ Proxied and cached: ${filename}`);
    res.send(fontBuffer);
    
  } catch (error) {
    console.error('❌ Font proxy error:', error.message);
    res.status(500).json({ 
      error: 'Failed to fetch font',
      message: error.message,
      fontFamily,
      filename
    });
  }
});

// 兼容/fonts/前缀的请求
app.get('/fonts/:fontFamily/:version/:filename', (req, res) => {
  // 重定向到无前缀的路由
  res.redirect(301, `/${req.params.fontFamily}/${req.params.version}/${req.params.filename}`);
});

// 字符集统计API
app.get('/api/character-stats', async (req, res) => {
  try {
    const reportPath = path.join(CHARACTER_SETS_DIR, 'character_report.md');
    const reportContent = await fs.readFile(reportPath, 'utf-8');
    
    // 解析统计数据
    const stats = {};
    const lines = reportContent.split('\n');
    
    for (const line of lines) {
      if (line.startsWith('- 总字符数:')) {
        stats.totalChars = parseInt(line.match(/\d+/)[0]);
      } else if (line.startsWith('- 中文字符:')) {
        stats.chineseChars = parseInt(line.match(/\d+/)[0]);
      } else if (line.startsWith('- 标点符号:')) {
        stats.punctuationChars = parseInt(line.match(/\d+/)[0]);
      }
    }
    
    res.json({
      status: 'success',
      data: stats,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Character stats error:', error);
    res.status(500).json({ error: 'Failed to load character statistics' });
  }
});

// 启动服务器
async function startServer() {
  await ensureCacheDir();
  
  app.listen(PORT, () => {
    console.log(`🚀 Font subset server running on port ${PORT}`);
    console.log(`📁 Cache directory: ${CACHE_DIR}`);
    console.log(`🌍 Environment: ${NODE_ENV}`);
    console.log(`📝 Log level: ${LOG_LEVEL}`);
  });
}

startServer().catch(console.error);