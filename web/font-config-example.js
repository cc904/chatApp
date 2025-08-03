/**
 * 字体服务配置示例
 * 用于Flutter Web集成新的字体代理服务
 */

// 配置示例1: 使用本地字体代理
const FONT_CONFIG_LOCAL = {
  // 使用本地服务器作为字体源
  fontFallbackBaseUrl: window.location.origin + "/",
  
  // Google字体代理路径
  googleFontsBaseUrl: window.location.origin + "/",
  
  // 字体子集API
  fontSubsetApi: window.location.origin + "/subset",
  
  // 缓存状态检查
  cacheStatusApi: window.location.origin + "/cache/stats"
};

// 配置示例2: 使用CDN + 本地代理混合模式
const FONT_CONFIG_HYBRID = {
  // 优先使用CDN，失败时使用本地代理
  fontFallbackBaseUrl: "https://fonts.gstatic.com/",
  localFontBaseUrl: window.location.origin + "/",
  
  // 启用本地缓存
  enableLocalCache: true,
  
  // 自定义字体
  customFonts: {
    "NotoSansCJK": {
      regular: "/noto-sans-cjk-sc/v26/NotoSansCJKsc-Regular.woff2",
      bold: "/noto-sans-cjk-sc/v26/NotoSansCJKsc-Bold.woff2"
    }
  }
};

// Flutter Web集成示例
function initializeFontEngine(config = FONT_CONFIG_LOCAL) {
  // 在Flutter初始化前设置字体配置
  window.flutterFontConfig = config;
  
  // 预加载常用字体
  preloadFonts([
    "/noto-sans-cjk-sc/v26/NotoSansCJKsc-Regular.woff2",
    "/noto-sans-cjk-sc/v26/NotoSansCJKsc-Bold.woff2"
  ]);
  
  console.log("✅ 字体服务配置完成", config);
}

// 字体预加载函数
function preloadFonts(fontUrls) {
  fontUrls.forEach(url => {
    const link = document.createElement('link');
    link.rel = 'preload';
    link.as = 'font';
    link.type = 'font/woff2';
    link.crossOrigin = 'anonymous';
    link.href = url;
    document.head.appendChild(link);
  });
}

// 检查字体服务状态
async function checkFontServiceHealth() {
  try {
    const response = await fetch('/health');
    const data = await response.json();
    console.log("字体服务状态:", data);
    return data.status === 'healthy';
  } catch (error) {
    console.error("字体服务检查失败:", error);
    return false;
  }
}

// 获取缓存统计
async function getFontCacheStats() {
  try {
    const response = await fetch('/cache/stats');
    const data = await response.json();
    console.log("字体缓存统计:", data.data);
    return data.data;
  } catch (error) {
    console.error("获取缓存统计失败:", error);
    return null;
  }
}

// 使用示例
// 在index.html中添加:
// <script src="font-config-example.js"></script>
// <script>
//   initializeFontEngine();
//   checkFontServiceHealth();
// </script>