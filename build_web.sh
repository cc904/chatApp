#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # 无颜色

# 清理函数，用于恢复文件并清理临时文件
cleanup() {
  echo -e "${YELLOW}清理环境中...${NC}"
  
  # 如果备份文件存在，恢复main.dart
  if [ -f .web_build_temp/main.dart.bak ]; then
    cp .web_build_temp/main.dart.bak lib/main.dart
    echo -e "${GREEN}已恢复main.dart${NC}"
  fi
  
  # 清理临时目录
  rm -rf .web_build_temp
  echo -e "${GREEN}临时文件已清理${NC}"
}

# 设置退出捕获，确保在脚本中断时执行清理
trap cleanup EXIT INT TERM

echo -e "${GREEN}开始构建Web版本...${NC}"

# 创建临时目录用于构建
mkdir -p .web_build_temp

# 创建main.dart的备份
echo -e "${GREEN}备份main.dart...${NC}"
cp lib/main.dart .web_build_temp/main.dart.bak

# 确认web_main.dart存在
if [ ! -f lib/web_main.dart ]; then
  echo -e "${RED}错误: web_main.dart不存在！${NC}"
  exit 1
fi

# 复制web_main.dart到main.dart
echo -e "${GREEN}使用web_main.dart替换main.dart...${NC}"
cp lib/web_main.dart lib/main.dart

# 修改pubspec.yaml临时排除Isar依赖
if [ -f pubspec.yaml ]; then
  echo -e "${YELLOW}暂时修改pubspec.yaml以优化Web构建...${NC}"
  cp pubspec.yaml .web_build_temp/pubspec.yaml.bak
  # 在这里可以添加sed命令来临时修改pubspec.yaml
fi

# 构建Web版本
echo -e "${GREEN}执行Flutter Web构建...${NC}"
flutter build web --release

# 检查构建是否成功
if [ $? -eq 0 ]; then
  echo -e "${GREEN}构建成功！${NC}"
  
  # 确保index.html中加载了flutter_bootstrap.js
  echo -e "${YELLOW}检查并更新web/index.html...${NC}"
  if [ -f build/web/index.html ]; then
    # 复制flutter_bootstrap.js到build/web目录
    if [ -f web/flutter_bootstrap.js ]; then
      cp web/flutter_bootstrap.js build/web/
      echo -e "${GREEN}已复制flutter_bootstrap.js到build/web/目录${NC}"
    fi
  fi
  
  echo -e "${GREEN}Web版本已成功构建到 build/web/ 目录${NC}"
  echo -e "${GREEN}可以通过以下命令运行Web版本:${NC}"
  echo -e "${GREEN}  cd build/web && python -m http.server 8000${NC}"
  echo -e "${GREEN}然后在浏览器中访问 http://localhost:8000${NC}"
else
  echo -e "${RED}构建失败！${NC}"
fi

# 如果修改了pubspec.yaml，恢复它
if [ -f .web_build_temp/pubspec.yaml.bak ]; then
  cp .web_build_temp/pubspec.yaml.bak pubspec.yaml
  echo -e "${GREEN}已恢复pubspec.yaml${NC}"
fi

# 结束
echo -e "${GREEN}构建过程完成${NC}"
exit 0 