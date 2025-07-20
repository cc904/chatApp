#!/bin/bash

# 编译时域名加密脚本
# 在 flutter build 之前运行此脚本

echo "🔐 开始加密域名到assets..."

# 检查工具文件
if [ ! -f "tools/encrypt_domains_to_assets.dart" ]; then
    echo "❌ 找不到加密工具 tools/encrypt_domains_to_assets.dart"
    exit 1
fi

# 检查域名配置文件
if [ ! -f "login_domains.json" ]; then
    echo "❌ 找不到域名配置文件 login_domains.json"
    exit 1
fi

# 运行加密工具
dart tools/encrypt_domains_to_assets.dart

if [ $? -eq 0 ]; then
    echo "🎉 域名加密完成！可以继续构建应用"
    echo "💡 提示: 现在可以运行 flutter build"
else
    echo "❌ 加密失败"
    exit 1
fi