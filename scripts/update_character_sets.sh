#!/bin/bash

# 字符集更新脚本
# 用于自动提取项目字符并更新字体服务器的字符集

set -e

echo "🔄 更新项目字符集..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 输出目录
OUTPUT_DIR="./font-subset-server/character-sets"

echo "📁 项目目录: $PROJECT_ROOT"
echo "📁 输出目录: $OUTPUT_DIR"

# 运行字符提取脚本
echo "🔍 提取项目字符..."
if ! dart run scripts/extract_characters.dart . "$OUTPUT_DIR"; then
    echo "❌ 字符提取失败"
    exit 1
fi

# 统计信息
if [ -f "$OUTPUT_DIR/character_report.md" ]; then
    echo ""
    echo "📊 字符统计:"
    grep "^- " "$OUTPUT_DIR/character_report.md" | head -4
fi

# 检查生成的文件
echo ""
echo "📂 生成的文件:"
ls -la "$OUTPUT_DIR" | grep -E '\.(txt|js|md)$' | awk '{print "   " $9 " (" $5 " bytes)"}'

echo ""
echo "✅ 字符集更新完成!"
echo ""
echo "📋 使用方法:"
echo "   1. 开发环境: docker-compose up font-service"
echo "   2. 访问字符集: http://localhost:3001/character-sets/"
echo "   3. 查看统计: http://localhost:3001/api/character-stats"
echo ""
echo "🔄 建议定期运行此脚本以保持字符集最新"