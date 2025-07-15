#!/bin/bash

# 版本更新脚本
# 用法: ./scripts/update_version.sh [patch|minor|major]

set -e

PUBSPEC_FILE="pubspec.yaml"

# 获取当前版本
current_version=$(grep "version:" $PUBSPEC_FILE | sed 's/version: //' | sed 's/+.*//')
current_build=$(grep "version:" $PUBSPEC_FILE | sed 's/.*+//')

echo "当前版本: $current_version+$current_build"

# 解析版本号
IFS='.' read -ra VERSION_PARTS <<< "$current_version"
major=${VERSION_PARTS[0]}
minor=${VERSION_PARTS[1]}
patch=${VERSION_PARTS[2]}

# 根据参数更新版本
case $1 in
  "major")
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  "minor")
    minor=$((minor + 1))
    patch=0
    ;;
  "patch"|"")
    patch=$((patch + 1))
    ;;
  *)
    echo "用法: $0 [patch|minor|major]"
    exit 1
    ;;
esac

# 构建号递增
new_build=$((current_build + 1))
new_version="$major.$minor.$patch"

echo "新版本: $new_version+$new_build"

# 更新pubspec.yaml
sed -i.bak "s/version: .*/version: $new_version+$new_build/" $PUBSPEC_FILE

echo "版本已更新到: $new_version+$new_build"
echo "请运行 'flutter pub get' 刷新依赖"