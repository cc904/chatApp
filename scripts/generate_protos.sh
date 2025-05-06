#!/bin/bash

# 确保目录存在
mkdir -p lib/core/proto/generated

# 检查protoc是否安装
if ! command -v protoc &> /dev/null; then
    echo "错误: protoc 未安装"
    echo "请访问 https://github.com/protocolbuffers/protobuf/releases 下载并安装protoc"
    exit 1
fi

# 检查dart插件是否可用
if ! protoc --dart_out=. -I. protos/message.proto &> /dev/null; then
    echo "错误: protoc-gen-dart 插件未安装"
    echo "请运行 dart pub global activate protoc_plugin 安装插件"
    exit 1
fi

# 生成dart文件
echo "开始生成dart文件..."
protoc --dart_out=lib/core/proto/generated -Iprotos protos/*.proto

# 移动生成的文件到正确位置（如果有嵌套目录）
if [ -d "lib/core/proto/generated/protos" ]; then
    echo "移动生成的文件..."
    mv lib/core/proto/generated/protos/* lib/core/proto/generated/ 2>/dev/null || :
    rmdir lib/core/proto/generated/protos 2>/dev/null || :
fi

echo "完成！生成的文件位于 lib/core/proto/generated/ 目录" 