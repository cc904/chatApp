#!/bin/sh

# Docker容器启动脚本
# 在容器启动时从环境变量生成配置文件

set -e

echo "🚀 容器启动初始化..."

# 容器直接使用环境变量，不加载 .env 文件
echo "📡 使用 Docker 环境变量配置"

# 环境变量配置 (只有字体服务地址需要配置)
# 记录原始环境变量值
ORIGINAL_FONT_SERVICE_URL="$FONT_SERVICE_URL"
FONT_SERVICE_URL=${FONT_SERVICE_URL:-http://localhost:7002/}

# 确保URL以/结尾
case "$FONT_SERVICE_URL" in
    */) ;;
    *) FONT_SERVICE_URL="${FONT_SERVICE_URL}/" ;;
esac

echo "🔧 生成运行时配置..."
echo "📋 环境变量信息:"
if [ -n "$ORIGINAL_FONT_SERVICE_URL" ]; then
    echo "   ✅ Docker容器环境变量 FONT_SERVICE_URL: $ORIGINAL_FONT_SERVICE_URL"
    echo "   📡 来源: Docker Compose environment 配置"
else
    echo "   ❌ Docker容器环境变量 FONT_SERVICE_URL: 未设置"
    echo "   🔄 使用默认值: http://localhost:7002/"
fi
echo "   🎯 最终字体服务地址: $FONT_SERVICE_URL"

# 生成配置文件到web目录
CONFIG_FILE="/app/web/app-config.json"

cat > "$CONFIG_FILE" << EOF
{
  "fontService": {
    "baseUrl": "$FONT_SERVICE_URL"
  }
}
EOF

echo "✅ 配置文件生成完成: $CONFIG_FILE"

# 验证JSON格式
if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "✅ JSON格式验证通过"
    else
        echo "❌ JSON格式验证失败"
        exit 1
    fi
fi

echo "📋 配置内容预览:"
cat "$CONFIG_FILE" | head -10
echo "    ..."

# 启动nginx或其他web服务器
echo "🌐 启动Web服务器..."
exec "$@"