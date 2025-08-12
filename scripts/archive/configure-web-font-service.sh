#!/bin/bash

# Flutter Web 字体服务配置脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$(cd "$SCRIPT_DIR/../web" && pwd)"
CONFIG_FILE="$WEB_DIR/config.js"

# 默认配置
ENVIRONMENT="development"
FONT_SERVICE_URL="http://localhost:7002/"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --font-url)
      FONT_SERVICE_URL="$2"
      shift 2
      ;;
    --help)
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --env ENV          设置环境 (development|production|docker)"
      echo "  --font-url URL     设置字体服务地址"
      echo "  --help            显示帮助信息"
      echo ""
      echo "示例:"
      echo "  $0 --env production --font-url https://fonts.example.com/"
      echo "  $0 --env docker --font-url http://fontss:7000/"
      exit 0
      ;;
    *)
      echo "未知选项: $1"
      exit 1
      ;;
  esac
done

echo "📝 配置Flutter Web字体服务..."
echo "🌍 环境: $ENVIRONMENT"
echo "🔤 字体服务地址: $FONT_SERVICE_URL"

# 备份原配置
if [[ -f "$CONFIG_FILE" ]]; then
  cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
  echo "💾 已备份原配置: $CONFIG_FILE.backup"
fi

# 更新配置文件
sed -i.tmp "s/environment: '[^']*'/environment: '$ENVIRONMENT'/g" "$CONFIG_FILE"
rm "$CONFIG_FILE.tmp"

# 如果提供了自定义URL，更新对应环境的配置
if [[ "$FONT_SERVICE_URL" != "http://localhost:7002/" ]]; then
  sed -i.tmp "s|$ENVIRONMENT: '[^']*'|$ENVIRONMENT: '$FONT_SERVICE_URL'|g" "$CONFIG_FILE"
  rm "$CONFIG_FILE.tmp"
fi

echo "✅ 配置完成!"
echo ""
echo "当前配置:"
grep -A 10 "fontService:" "$CONFIG_FILE" | head -15
echo ""
echo "要恢复原配置，请运行:"
echo "  cp $CONFIG_FILE.backup $CONFIG_FILE"