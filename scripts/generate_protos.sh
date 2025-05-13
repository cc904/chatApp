#!/bin/bash

# 添加 pub-cache/bin 到 PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# 清理之前生成的文件
rm -rf lib/core/proto/generated/*

# 确保目录存在
mkdir -p lib/core/proto/generated

# 检查protoc是否安装
if ! command -v protoc &> /dev/null; then
    echo "错误: protoc 未安装"
    echo "请访问 https://github.com/protocolbuffers/protobuf/releases 下载并安装protoc"
    exit 1
fi

# 检查dart插件是否可用
if ! command -v protoc-gen-dart &> /dev/null; then
    echo "错误: protoc-gen-dart 插件未安装"
    echo "请运行 dart pub global activate protoc_plugin 安装插件"
    exit 1
fi

# 生成dart文件
echo "开始生成dart文件..."

# 使用新的 submodule 路径
cd lib/core/proto/source
protoc --dart_out=../generated *.proto
cd ../../../..

echo "完成！生成的文件位于 lib/core/proto/generated/ 目录" 