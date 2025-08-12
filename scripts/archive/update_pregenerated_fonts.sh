#!/bin/bash

# 更新预生成字体脚本
# 提取程序字符并生成对应的字体切片文件

set -e

echo "🎯 更新预生成字体系统..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📁 项目目录: $PROJECT_ROOT"

# 运行预生成字体工具
echo "🚀 生成字体切片..."
if ! dart run scripts/pregenerate_fonts.dart; then
    echo "❌ 字体生成失败"
    exit 1
fi

# 统计生成的文件
echo ""
echo "📂 生成的字体文件:"
ls -la web/fonts/pregenerated/ | grep -E '\.woff2$' | wc -l | xargs echo "   字体文件:" "个"
ls -la web/fonts/pregenerated/ | grep -E '\.woff2$' | awk '{sum+=$5} END {print "   总大小: " sum " bytes"}'

echo ""
echo "📂 生成的配置文件:"
ls -la web/ | grep -E '(pregenerated-fonts\.(js|css))' | awk '{print "   " $9 " (" $5 " bytes)"}'

echo ""
echo "✅ 预生成字体更新完成!"
echo ""
echo "📋 优势:"
echo "   ✓ 无网络请求 - 字体文件直接打包"
echo "   ✓ 即时可用 - 程序启动即可显示"
echo "   ✓ 离线可用 - 不依赖字体服务器"
echo "   ✓ 性能最优 - 避免动态加载延迟"
echo ""
echo "🔄 建议在项目代码更新后重新运行此脚本"