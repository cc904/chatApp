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

// 缓存目录
const CACHE_DIR = path.join(__dirname, 'cache');
const CHARACTER_SETS_DIR = path.join(__dirname, 'character-sets');

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
    environment: NODE_ENV 
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