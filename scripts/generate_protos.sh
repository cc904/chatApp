#!/bin/bash

# Protocol Buffer代码生成脚本
# 用于从.proto文件生成Dart代码

set -e

echo "🔧 开始生成Protocol Buffer代码..."

# 检查protoc是否已安装
if ! command -v protoc &> /dev/null; then
    echo "❌ protoc未安装，请先安装Protocol Buffers编译器"
    echo "macOS: brew install protobuf"
    echo "Ubuntu: sudo apt-get install protobuf-compiler"
    exit 1
fi

# 检查protoc-gen-dart是否已安装
if ! command -v protoc-gen-dart &> /dev/null; then
    echo "🔧 protoc-gen-dart未找到，正在安装..."
    dart pub global activate protoc_plugin
fi

# 定义路径
PROTO_SOURCE_DIR="lib/core/proto/source"
PROTO_OUTPUT_DIR="lib/core/proto/generated"

# 确保输出目录存在
mkdir -p "$PROTO_OUTPUT_DIR"

# 清理旧的生成文件
echo "🧹 清理旧的生成文件..."
rm -f "$PROTO_OUTPUT_DIR"/*.dart

# 生成Dart代码
echo "⚡ 生成Dart代码..."
protoc \
    --dart_out="$PROTO_OUTPUT_DIR" \
    --proto_path="$PROTO_SOURCE_DIR" \
    "$PROTO_SOURCE_DIR"/*.proto

# 检查生成是否成功
if [ $? -eq 0 ]; then
    echo "✅ Protocol Buffer代码生成成功！"
    echo "📁 生成的文件位于: $PROTO_OUTPUT_DIR"
    
    # 列出生成的文件
    echo "📄 生成的文件:"
    ls -la "$PROTO_OUTPUT_DIR"/*.dart
else
    echo "❌ Protocol Buffer代码生成失败！"
    exit 1
fi

echo "🎉 完成！"