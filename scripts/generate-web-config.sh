#!/bin/bash

# Flutter Web 配置生成脚本
# 从环境变量生成 app-config.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$(cd "$SCRIPT_DIR/../web" && pwd)"
CONFIG_FILE="$WEB_DIR/app-config.json"

# 读取环境变量 (支持 .env 文件)
if [[ -f "$SCRIPT_DIR/../.env" ]]; then
    echo "📁 加载环境文件: .env"
    set -a
    source "$SCRIPT_DIR/../.env"
    set +a
fi

# 环境变量配置 (带默认值)
FLUTTER_WEB_ENV=${FLUTTER_WEB_ENV:-development}
FONT_SERVICE_URL=${FONT_SERVICE_URL:-http://localhost:7002}
FONT_SERVICE_TIMEOUT=${FONT_SERVICE_TIMEOUT:-15000}
FONT_CACHE_ENABLED=${FONT_CACHE_ENABLED:-true}
API_BASE_URL=${API_BASE_URL:-http://localhost:3000}
WEBSOCKET_URL=${WEBSOCKET_URL:-ws://localhost:3000}
DEBUG_MODE=${DEBUG_MODE:-$([ "$FLUTTER_WEB_ENV" = "development" ] && echo "true" || echo "false")}

echo "🔧 生成Flutter Web配置..."
echo "📁 输出路径: $CONFIG_FILE"
echo "🌍 环境: $FLUTTER_WEB_ENV"
echo "🔤 字体服务: $FONT_SERVICE_URL"
echo "🔗 API地址: $API_BASE_URL"
echo "🔌 WebSocket: $WEBSOCKET_URL"

# 生成配置JSON文件
cat > "$CONFIG_FILE" << EOF
{
  "environment": "$FLUTTER_WEB_ENV",
  "api": {
    "baseUrl": "$API_BASE_URL",
    "timeout": 30000
  },
  "websocket": {
    "url": "$WEBSOCKET_URL",
    "reconnectInterval": 5000,
    "maxReconnectAttempts": 10
  },
  "fontService": {
    "baseUrl": "$FONT_SERVICE_URL",
    "timeout": $FONT_SERVICE_TIMEOUT,
    "cacheEnabled": $FONT_CACHE_ENABLED,
    "fallbackEnabled": true
  },
  "features": {
    "preloadCommonChars": true,
    "offlineMode": false,
    "analytics": $([ "$FLUTTER_WEB_ENV" = "production" ] && echo "true" || echo "false")
  },
  "debug": {
    "enabled": $DEBUG_MODE,
    "logFontRequests": $DEBUG_MODE,
    "showCacheStats": $DEBUG_MODE,
    "networkLogging": $DEBUG_MODE
  },
  "buildInfo": {
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "version": "${BUILD_VERSION:-1.0.0}",
    "buildNumber": "${BUILD_NUMBER:-1}",
    "gitCommit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
  }
}
EOF

echo "✅ 配置文件生成完成!"
echo ""

# 验证生成的JSON格式
if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "✅ JSON格式验证通过"
    else
        echo "❌ JSON格式验证失败"
        exit 1
    fi
fi

echo ""
echo "📋 生成的配置预览:"
cat "$CONFIG_FILE" | head -25
echo "    ..."
echo ""
echo "📝 支持的环境变量:"
echo "  FLUTTER_WEB_ENV        - 运行环境 (development|production|staging)"
echo "  FONT_SERVICE_URL       - 字体服务地址"
echo "  FONT_SERVICE_TIMEOUT   - 字体请求超时(ms)"
echo "  API_BASE_URL          - API服务地址"
echo "  WEBSOCKET_URL         - WebSocket地址"
echo "  DEBUG_MODE            - 调试模式 (true|false)"
echo "  BUILD_VERSION         - 构建版本号"
echo "  BUILD_NUMBER          - 构建编号"
echo ""
echo "💡 使用方法:"
echo "  # 开发环境"
echo "  ./scripts/generate-web-config.sh"
echo ""
echo "  # 生产环境"
echo "  FLUTTER_WEB_ENV=production FONT_SERVICE_URL=https://fonts.example.com ./scripts/generate-web-config.sh"