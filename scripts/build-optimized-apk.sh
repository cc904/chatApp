#!/bin/bash

# 构建优化的Android APK脚本
# 
# 功能：
# 1. 构建最优化的生产APK
# 2. 支持不同的构建策略
# 3. 自动分析大小

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

echo -e "${BLUE}🚀 Android APK 优化构建工具${NC}"
echo "=================================="

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter未安装或未在PATH中${NC}"
    exit 1
fi

# 显示构建选项
# 默认构建两个APK：一个最小（arm64-v8a），一个兼容（arm64-v8a + armeabi-v7a）
BUILD_MINIMAL=true
BUILD_COMPATIBLE=true

echo -e "${YELLOW}📋 将构建以下产物：${NC}"
echo "   • 最小APK (arm64-v8a)"
echo "   • 兼容APK (arm64-v8a + armeabi-v7a)"
echo ""

# 清理和准备
if true; then
    echo -e "${YELLOW}🧹 清理之前的构建...${NC}"
    flutter clean
    flutter pub get
    echo ""
fi

# 执行构建：最小APK
if [ "$BUILD_MINIMAL" = true ]; then
  echo -e "${YELLOW}🔨 构建最小APK (arm64-v8a)...${NC}"
  flutter build apk --release --target-platform android-arm64 --analyze-size
fi

# 执行构建：兼容APK
if [ "$BUILD_COMPATIBLE" = true ]; then
  echo -e "${YELLOW}🔨 构建兼容APK (arm64-v8a + armeabi-v7a)...${NC}"
  flutter build apk --release --target-platform android-arm,android-arm64 --split-per-abi --analyze-size
fi

echo ""

# 分析结果
if [ "$BUILD_TYPE" = "bundle" ]; then
    # App Bundle分析
    BUNDLE_PATH="build/app/outputs/bundle/release/app-release.aab"
    if [ -f "$BUNDLE_PATH" ]; then
        echo -e "${GREEN}📦 App Bundle构建成功！${NC}"
        echo "=================================="
        
        size=$(du -h "$BUNDLE_PATH" | cut -f1)
        size_bytes=$(stat -f%z "$BUNDLE_PATH" 2>/dev/null || stat -c%s "$BUNDLE_PATH" 2>/dev/null)
        size_mb=$(echo "scale=2; $size_bytes / 1024 / 1024" | bc)
        
        echo -e "${BLUE}📱 app-release.aab${NC}"
        echo "   大小: $size (${size_mb}MB)"
        echo "   路径: $BUNDLE_PATH"
        echo ""
        echo -e "${GREEN}💡 App Bundle优势：${NC}"
        echo "   • Google Play自动优化下载大小"
        echo "   • 用户只下载适合其设备的代码"
        echo "   • 平均减少15%的下载大小"
    fi
else
    # APK分析
    APK_DIR="build/app/outputs/flutter-apk"
    
    if [ -d "$APK_DIR" ]; then
        echo -e "${GREEN}📱 APK构建成功！${NC}"
        echo "=================================="
        
        # 统计APK信息
        total_size=0
        apk_count=0
        
        for apk in "$APK_DIR"/*.apk; do
            if [ -f "$apk" ]; then
                filename=$(basename "$apk")
                size=$(du -h "$apk" | cut -f1)
                size_bytes=$(stat -f%z "$apk" 2>/dev/null || stat -c%s "$apk" 2>/dev/null)
                size_mb=$(echo "scale=2; $size_bytes / 1024 / 1024" | bc)
                
                echo -e "${BLUE}📱 $filename${NC}"
                echo "   大小: $size (${size_mb}MB)"
                
                total_size=$((total_size + size_bytes))
                apk_count=$((apk_count + 1))
            fi
        done
        
        if [ $apk_count -gt 1 ]; then
            total_mb=$(echo "scale=2; $total_size / 1024 / 1024" | bc)
            echo ""
            echo -e "${YELLOW}📊 总计: ${apk_count}个APK, ${total_mb}MB${NC}"
        fi
        
        echo ""
        echo -e "${BLUE}📍 APK位置: $APK_DIR${NC}"
    fi
fi

# 提供优化建议
echo ""
echo -e "${GREEN}💡 优化建议：${NC}"
echo "=================================="

echo "✅ 已构建：最小APK + 兼容APK"
echo "📱 发布建议：优先 arm64-v8a；兼容包用于覆盖老设备"

echo ""
echo "🔧 进一步优化："
echo "   • 运行 ./scripts/analyze-apk-size.sh 进行详细分析"
echo "   • 查看 docs/APK_SIZE_OPTIMIZATION.md 获取更多建议"
echo "   • 考虑移除不必要的依赖库"

echo ""
echo -e "${GREEN}✅ 构建完成！${NC}"