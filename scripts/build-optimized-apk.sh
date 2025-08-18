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
# 仅构建：arm64-v8a 分包 + 通用包（arm64+v7a）；不输出 v7a 单包到 build-output
BUILD_MINIMAL=true
BUILD_COMPATIBLE=true

echo -e "${YELLOW}📋 将构建以下产物：${NC}"
echo "   • arm64-v8a 分包"
echo "   • 通用APK (arm64-v8a + armeabi-v7a，单包)"
echo ""

# 清理和准备
if true; then
    echo -e "${YELLOW}🧹 清理之前的构建...${NC}"
    flutter clean
    flutter pub get
    echo ""
fi

############################################################
# 构建 1：最小 APK（仅 arm64-v8a）
# 说明：
# - 通过 Gradle 属性启用 ABI 拆分并仅包含 arm64-v8a
# - 关闭通用 APK 以避免生成 ABI 为空的通用包
############################################################
if [ "$BUILD_MINIMAL" = true ]; then
  echo -e "${YELLOW}🔨 构建最小APK (仅 arm64-v8a)...${NC}"
  # 使用 Flutter 官方 --split-per-abi，让工具正确感知产物位置，避免找不到APK的误判
  set +e
  flutter build apk \
    --release \
    --target-platform android-arm64 \
    --split-per-abi \
    -PenableAbiSplits=true -PabiInclude=arm64-v8a -PenableUniversalApk=false \
    --analyze-size
  status=$?
  set -e

  # 某些组合下 Flutter 会误判“未生成APK”，这里做一次兜底检测
  MIN_APK="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
  ALT_MIN_APK="build/app/outputs/apk/release/app-arm64-v8a-release.apk"
  if [ $status -ne 0 ]; then
    if [ -f "$MIN_APK" ] || [ -f "$ALT_MIN_APK" ]; then
      echo -e "${YELLOW}⚠️ Flutter 返回非零退出码，但APK已生成，继续...${NC}"
    else
      echo -e "${RED}❌ 构建最小APK失败，且未找到产物${NC}"
      exit 1
    fi
  fi
fi

############################################################
# 构建 2：兼容 APK（arm64-v8a + armeabi-v7a，单包）
# 说明：
# - 关闭 ABI 拆分，使一个 APK 同时包含 arm64-v8a 与 armeabi-v7a
# - 不使用 --split-per-abi，避免生成多包
############################################################
if [ "$BUILD_COMPATIBLE" = true ]; then
  echo -e "${YELLOW}🔨 构建通用APK (arm64-v8a + armeabi-v7a，单包)...${NC}"
  set +e
  # 方案：关闭 splits，以生成单一多ABI APK（包含 v7a + v8a），避免生成各自分包
  flutter build apk \
    --release \
    --target-platform android-arm,android-arm64 \
    -PenableAbiSplits=false
  status=$?
  set -e

  # 兜底检测“兼容单包”产物（Flutter 默认命名为 app-release.apk）
  COMPAT_DIR="build/app/outputs/flutter-apk"
  UNIVERSAL_APK="$COMPAT_DIR/app-release.apk"
  if [ $status -ne 0 ]; then
    if [ -f "$UNIVERSAL_APK" ]; then
      echo -e "${YELLOW}⚠️ Flutter 返回非零退出码，但兼容APK已生成，继续...${NC}"
    else
      echo -e "${RED}❌ 构建兼容APK失败，且未找到产物${NC}"
      exit 1
    fi
  fi
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

        # 输出目录
        OUT_DIR="./build-output"
        mkdir -p "$OUT_DIR"

        # 如果存在 arm64-v8a 产物，复制到 output 目录
        if [ -f "$APK_DIR/app-arm64-v8a-release.apk" ]; then
          cp -f "$APK_DIR/app-arm64-v8a-release.apk" "$OUT_DIR/app-release-arm64.apk" || true
          echo -e "${GREEN}✅ 已复制: $OUT_DIR/app-release-arm64.apk${NC}"
        fi

        # 不再复制 v7a 单包到输出目录（只保留 arm64 与 universal）

        # 如果存在 universal 产物，复制到 output 目录
        if [ -f "$APK_DIR/app-universal-release.apk" ]; then
          cp -f "$APK_DIR/app-universal-release.apk" "$OUT_DIR/app-release-universal.apk" || true
          echo -e "${GREEN}✅ 已复制: $OUT_DIR/app-release-universal.apk${NC}"
        fi
        # Flutter 默认 universal 名称（当 -PenableAbiSplits=false）
        if [ -f "$APK_DIR/app-release.apk" ]; then
          cp -f "$APK_DIR/app-release.apk" "$OUT_DIR/app-release-universal.apk" || true
          echo -e "${GREEN}✅ 已复制: $OUT_DIR/app-release-universal.apk${NC}"
        fi
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