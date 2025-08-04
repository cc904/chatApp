#!/bin/bash

# APK大小分析和优化脚本
# 
# 功能：
# 1. 构建优化的APK
# 2. 分析APK大小和组成
# 3. 提供优化建议

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}🔍 APK大小分析和优化工具${NC}"
echo "=================================="

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter未安装或未在PATH中${NC}"
    exit 1
fi

# 清理之前的构建
echo -e "${YELLOW}🧹 清理之前的构建...${NC}"
flutter clean
flutter pub get

# 构建优化的APK
echo -e "${YELLOW}🔨 构建优化的Release APK (arm64-v8a)...${NC}"
flutter build apk --release --target-platform android-arm64 --analyze-size

# APK输出目录
APK_DIR="build/app/outputs/flutter-apk"

echo ""
echo -e "${GREEN}📊 APK大小分析结果：${NC}"
echo "=================================="

# 分析每个ABI的APK大小
for apk in "$APK_DIR"/*.apk; do
    if [ -f "$apk" ]; then
        filename=$(basename "$apk")
        size=$(du -h "$apk" | cut -f1)
        size_bytes=$(stat -f%z "$apk" 2>/dev/null || stat -c%s "$apk" 2>/dev/null)
        size_mb=$(echo "scale=2; $size_bytes / 1024 / 1024" | bc)
        
        echo -e "${BLUE}📱 $filename${NC}"
        echo "   大小: $size (${size_mb}MB)"
        echo "   路径: $apk"
        echo ""
    fi
done

# 分析最小的APK（通常是arm64-v8a）
ARM64_APK="$APK_DIR/app-arm64-v8a-release.apk"
if [ -f "$ARM64_APK" ]; then
    echo -e "${GREEN}🎯 主要APK分析 (arm64-v8a):${NC}"
    echo "=================================="
    
    # 使用aapt分析APK内容（如果可用）
    if command -v aapt &> /dev/null; then
        echo -e "${YELLOW}📋 APK内容概览:${NC}"
        aapt list -v "$ARM64_APK" | head -20
        echo ""
        
        echo -e "${YELLOW}📦 APK配置信息:${NC}"
        aapt dump configurations "$ARM64_APK"
        echo ""
    fi
    
    # 使用unzip分析APK结构
    echo -e "${YELLOW}📁 APK文件结构分析:${NC}"
    temp_dir=$(mktemp -d)
    unzip -q "$ARM64_APK" -d "$temp_dir"
    
    echo "主要组件大小："
    du -sh "$temp_dir"/* 2>/dev/null | sort -hr | head -10
    
    # 分析lib目录（native库）
    if [ -d "$temp_dir/lib" ]; then
        echo ""
        echo "Native库大小："
        du -sh "$temp_dir/lib"/* 2>/dev/null | sort -hr
    fi
    
    # 分析assets目录
    if [ -d "$temp_dir/assets" ]; then
        echo ""
        echo "Assets大小："
        du -sh "$temp_dir/assets"/* 2>/dev/null | sort -hr | head -10
    fi
    
    # 清理临时目录
    rm -rf "$temp_dir"
fi

echo ""
echo -e "${GREEN}💡 APK大小优化建议：${NC}"
echo "=================================="
echo "1. ✅ 已启用代码混淆和资源压缩"
echo "2. ✅ 已启用ABI分包（减小单个APK大小）"
echo "3. ✅ 已启用R8完整模式优化"
echo "4. 📱 建议只发布arm64-v8a版本（现代设备）"
echo "5. 🗜️  考虑使用App Bundle而不是APK"
echo "6. 🎨 检查是否有未使用的资源文件"
echo "7. 📚 考虑移除不必要的依赖库"

echo ""
echo -e "${GREEN}🚀 构建App Bundle (推荐):${NC}"
echo "flutter build appbundle --release"

echo ""
echo -e "${BLUE}📍 APK文件位置: $APK_DIR${NC}"
echo -e "${GREEN}✅ 分析完成！${NC}"