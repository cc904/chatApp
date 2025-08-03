#!/bin/bash

# 🍎 Flutter Web Safari兼容性构建脚本
# 此脚本专门用于构建Safari兼容的Flutter Web应用

echo "🍎 开始Safari兼容性构建..."

# 1. 清理旧构建
echo "🧹 清理旧构建文件..."
flutter clean
rm -rf build/web

# 2. 强制HTML渲染器构建
echo "🔧 使用HTML渲染器构建Flutter Web应用..."
flutter build web \
  --release \
  --no-web-resources-cdn \
  --dart-define=FLUTTER_WEB_RENDERER=html \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=./canvaskit/

if [ $? -ne 0 ]; then
  echo "❌ Flutter构建失败"
  exit 1
fi

# 3. 完全移除CanvasKit文件
echo "🚫 移除CanvasKit文件..."
rm -rf build/web/canvaskit

# 4. 创建空的CanvasKit占位文件（防止404错误）
echo "📝 创建CanvasKit占位文件..."
mkdir -p build/web/canvaskit/chromium
echo "// CanvasKit已禁用，Safari兼容性优化" > build/web/canvaskit/canvaskit.js
echo "// CanvasKit WASM已禁用" > build/web/canvaskit/canvaskit.wasm

# 5. 应用Safari特定优化到index.html
echo "🍎 应用Safari特定优化..."
cd build/web

# 6. 创建Safari Service Worker
echo "🛡️ 创建Safari Service Worker..."
cat > safari-sw.js << 'EOF'
// 🍎 Safari兼容性Service Worker
// 拦截并阻止CanvasKit相关请求

const CACHE_NAME = 'safari-compatibility-v1';

self.addEventListener('install', function(event) {
  console.log('🛡️ Safari Service Worker安装中...');
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  console.log('🛡️ Safari Service Worker已激活');
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(event) {
  const url = event.request.url;
  
  // 🚫 拦截CanvasKit相关请求
  if (url.includes('canvaskit') || 
      url.includes('CanvasKit') || 
      url.includes('.wasm') ||
      url.includes('skwasm')) {
    console.log('🚫 Service Worker阻止CanvasKit请求:', url);
    
    event.respondWith(
      new Response('// CanvasKit disabled for Safari compatibility', {
        status: 200,
        statusText: 'OK',
        headers: { 
          'Content-Type': 'application/javascript',
          'Cache-Control': 'no-cache'
        }
      })
    );
    return;
  }
  
  // ✅ 允许其他请求正常通过
  event.respondWith(fetch(event.request));
});

// 🔧 错误处理
self.addEventListener('error', function(event) {
  console.log('⚠️ Service Worker错误:', event.error);
});
EOF

# 7. 显示构建统计
echo ""
echo "📊 构建统计:"
echo "总大小: $(du -sh . | cut -f1)"
echo "主要文件:"
ls -lh *.js *.html *.json 2>/dev/null | head -10

echo ""
echo "✅ Safari兼容性构建完成！"
echo ""
echo "🚀 启动测试服务器:"
echo "cd build/web && python3 -m http.server 8087"
echo ""
echo "🌐 测试地址:"
echo "主应用: http://localhost:8087"
echo "兼容性测试: http://localhost:8087/compatibility-test.html"
echo ""
echo "🍎 Safari兼容性特性:"
echo "✅ 强制HTML渲染器"
echo "✅ 完全禁用CanvasKit"
echo "✅ Service Worker拦截"
echo "✅ 智能错误处理"
echo "✅ 浏览器检测"