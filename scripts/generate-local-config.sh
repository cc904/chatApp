#!/bin/bash

# 本地开发配置生成脚本
# 从 .env.prod 或 .env 文件生成 app-config.json

set -e

echo "🔧 本地开发配置生成..."

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 加载环境文件（优先级：.env.prod > .env）
if [[ -f "$PROJECT_ROOT/.env.prod" ]]; then
    echo "📁 加载生产环境文件: .env.prod"
    set -a
    source "$PROJECT_ROOT/.env.prod"
    set +a
elif [[ -f "$PROJECT_ROOT/.env" ]]; then
    echo "📁 加载环境文件: .env"
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
else
    echo "⚠️  未找到环境文件，使用默认配置"
fi

# 环境变量配置 (只有字体服务地址需要配置)
FONT_SERVICE_URL=${FONT_SERVICE_URL:-http://localhost:7002}

echo "🔤 字体服务: $FONT_SERVICE_URL"

# 生成配置文件到web目录
CONFIG_FILE="$PROJECT_ROOT/web/app-config.json"

cat > "$CONFIG_FILE" << EOF
{
  "fontService": {
    "baseUrl": "$FONT_SERVICE_URL"
  }
}
EOF

echo "✅ 本地配置文件生成完成: $CONFIG_FILE"

# 验证JSON格式
if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "✅ JSON格式验证通过"
    else
        echo "❌ JSON格式验证失败"
        exit 1
    fi
fi

echo "📋 配置内容:"
cat "$CONFIG_FILE"