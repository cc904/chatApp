#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║            🐳 Flutter Web Docker            ║"
echo "║                 构建 & 部署                  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# 构建选项选择
echo "┌──────────────────────────────────────────────┐"
echo "│                🔧 构建选项                  │"
echo "└──────────────────────────────────────────────┘"
echo ""
echo "请选择构建模式:"
echo "  1) 🚀 完全重新构建 (推荐) - 清理+构建+打包"
echo "  2) 📦 仅打包现有构建 - 使用已有build/web"
echo "  3) 🛠️  仅构建不打包 - 只更新build/web"
echo ""
read -t 10 -p "请输入选择 (1-3) [默认: 1, 10秒后自动选择]: " BUILD_CHOICE

# 处理超时或空输入
if [ $? -gt 128 ] || [ -z "$BUILD_CHOICE" ]; then
    BUILD_CHOICE=1
    echo "⏰ 超时，使用默认选项: 完全重新构建"
fi

# 验证输入
case $BUILD_CHOICE in
    1)
        echo "✅ 选择: 完全重新构建 (清理+构建+打包)"
        DO_CLEAN=true
        DO_BUILD=true
        DO_DOCKER=true
        ;;
    2)
        echo "✅ 选择: 仅打包现有构建"
        DO_CLEAN=false
        DO_BUILD=false
        DO_DOCKER=true
        ;;
    3)
        echo "✅ 选择: 仅构建不打包"
        DO_CLEAN=true
        DO_BUILD=true
        DO_DOCKER=false
        ;;
    *)
        echo "❌ 无效选择，使用默认: 完全重新构建"
        DO_CLEAN=true
        DO_BUILD=true
        DO_DOCKER=true
        ;;
esac

echo ""

# 创建部署包的函数
create_deployment_package() {
    # 创建时间戳（不包含年份）
    TIMESTAMP=$(date +"%m%d_%H%M%S")
    ARCHIVE_NAME="${IMAGE_NAME}_${TIMESTAMP}.tar.gz"
    BUILD_OUTPUT_DIR="build-output"
    TEMP_DIR="temp_chatapp"
    
    # 创建临时目录结构
    mkdir -p "$BUILD_OUTPUT_DIR"
    mkdir -p "$TEMP_DIR/chatapp"
    
    # 复制并重命名配置文件
    if [ -f "docker-compose.prod.yml" ]; then
        cp "docker-compose.prod.yml" "$TEMP_DIR/chatapp/docker-compose.yml"
        echo "   ✅ 复制 docker-compose.yml"
    else
        echo "   ❌ docker-compose.prod.yml 不存在"
    fi
    
    if [ -f ".env.prod" ]; then
        cp ".env.prod" "$TEMP_DIR/chatapp/.env"
        echo "   ✅ 复制 .env"
    else
        echo "   ❌ .env.prod 不存在"
    fi
    
    # 创建部署说明文件
    cat > "$TEMP_DIR/chatapp/README.md" << EOF
# ChatApp 部署包

## 部署信息
- 镜像名称: \`$FULL_IMAGE_NAME\`
- 构建时间: \`$(date '+%Y-%m-%d %H:%M:%S')\`
- 版本: \`$TAG\`

## 快速部署

### 1. 启动服务
\`\`\`bash
docker-compose up -d
\`\`\`

### 2. 查看日志
\`\`\`bash
docker-compose logs -f
\`\`\`

### 3. 停止服务
\`\`\`bash
docker-compose down
\`\`\`

### 4. 更新镜像
\`\`\`bash
docker-compose pull
docker-compose up -d
\`\`\`

## 访问地址
- 默认访问: http://localhost:8080
- 修改端口: 编辑 .env 文件中的 HOST_PORT

## 环境变量配置
所有配置项请参考 .env 文件中的说明。
EOF
    
    # 创建压缩包
    tar -czf "$BUILD_OUTPUT_DIR/$ARCHIVE_NAME" -C "$TEMP_DIR" .
    
    # 清理临时目录
    rm -rf "$TEMP_DIR"
    
    if [ $? -eq 0 ]; then
        # 显示压缩包信息
        ARCHIVE_SIZE=$(ls -lh "$BUILD_OUTPUT_DIR/$ARCHIVE_NAME" | awk '{print $5}')
        echo "✅ 压缩包创建成功: $BUILD_OUTPUT_DIR/$ARCHIVE_NAME ($ARCHIVE_SIZE)"
        echo ""
        
        echo "╔══════════════════════════════════════════════╗"
        echo "║                 🎯 部署信息                  ║"
        echo "╚══════════════════════════════════════════════╝"
        echo ""
        echo "📦 本地镜像: $IMAGE_NAME:$TAG"
        echo "🌐 远程镜像: $FULL_IMAGE_NAME"
        echo "📁 部署包: $BUILD_OUTPUT_DIR/$ARCHIVE_NAME"
        echo ""
        echo "┌─ 📦 部署包结构 ──────────────────────────────┐"
        echo "│  chatapp/                                    │"
        echo "│  ├── docker-compose.yml                     │"
        echo "│  ├── .env                                   │"
        echo "│  └── README.md                              │"
        echo "└──────────────────────────────────────────────┘"
        echo ""
        echo "┌─ 🚀 快速部署 ────────────────────────────────┐"
        echo "│  tar -xzf $BUILD_OUTPUT_DIR/$ARCHIVE_NAME   │"
        echo "│  cd chatapp                                  │"
        echo "│  docker-compose up -d                       │"
        echo "└──────────────────────────────────────────────┘"
        echo ""
        echo "┌─ 🌐 访问地址 ────────────────────────────────┐"
        echo "│  http://localhost:8080                      │"
        echo "└──────────────────────────────────────────────┘"
        echo ""
        echo "╔══════════════════════════════════════════════╗"
        echo "║              ✨ 构建完成! ✨               ║"
        echo "╚══════════════════════════════════════════════╝"
    else
        echo "❌ 压缩包创建失败"
    fi
}

# Flutter构建逻辑
if [ "$DO_CLEAN" = true ] || [ "$DO_BUILD" = true ]; then
    echo "┌──────────────────────────────────────────────┐"
    echo "│               🔨 Flutter构建                │"
    echo "└──────────────────────────────────────────────┘"
    
    if [ "$DO_CLEAN" = true ]; then
        echo "🧹 清理旧构建文件..."
        flutter clean
        echo "✅ 清理完成"
        echo ""
    fi
    
    if [ "$DO_BUILD" = true ]; then
        echo "📦 获取依赖..."
        if flutter pub get; then
            echo "✅ 依赖获取成功"
        else
            echo "❌ 依赖获取失败"
            exit 1
        fi
        echo ""
        
        echo "🚀 构建Web版本..."
        if flutter build web --release; then
            echo "✅ Web构建成功"
        else
            echo "❌ Web构建失败"
            exit 1
        fi
        echo ""
    fi
fi

# 检查build/web是否存在
if [ ! -d "build/web" ]; then
    echo "❌ build/web 目录不存在"
    if [ "$DO_BUILD" != true ]; then
        echo "   提示: 选择选项1或3来构建项目"
    fi
    exit 1
fi

echo "📁 验证构建文件: build/web"

# 检查关键文件
CRITICAL_FILES=(
    "build/web/index.html"
    "build/web/main.dart.js"
    "build/web/flutter_bootstrap.js"
    "server.js"
)

echo "📋 检查关键文件..."
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        size=$(wc -c < "$file" | tr -d ' ')
        echo "   ✅ $file (${size} bytes)"
    else
        echo "   ❌ $file (缺失)"
        exit 1
    fi
done

# Docker构建和部署
if [ "$DO_DOCKER" = true ]; then
    # 构建Docker镜像
    IMAGE_NAME="x0x-chatapp"
    TAG="latest"
    REGISTRY="18.183.101.229:15000"
    FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"

    echo "┌──────────────────────────────────────────────┐"
    echo "│                🔨 构建镜像                  │"
    echo "└──────────────────────────────────────────────┘"
    echo "📦 本地镜像: $IMAGE_NAME:$TAG"
    echo "🌐 远程镜像: $FULL_IMAGE_NAME"
    echo ""

    docker build -f Dockerfile -t $IMAGE_NAME:$TAG .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Docker镜像构建成功!"
    echo ""
    echo "┌──────────────────────────────────────────────┐"
    echo "│               📊 镜像信息                   │"
    echo "└──────────────────────────────────────────────┘"
    docker images $IMAGE_NAME:$TAG
    
    # 检查Docker登录状态
    echo ""
    echo "┌──────────────────────────────────────────────┐"
    echo "│              🔐 检查登录状态                │"
    echo "└──────────────────────────────────────────────┘"
    
    # 简化的登录检查和处理
    echo "🔍 检查 $REGISTRY 登录状态..."
    
    # 检查是否有登录凭据
    if grep -q "$REGISTRY" ~/.docker/config.json 2>/dev/null; then
        echo "✅ 发现登录凭据，将直接尝试推送"
        echo "💡 如推送失败，会自动提示重新登录"
    else
        echo "❌ 未找到登录凭据"
        echo "📝 请输入登录信息:"
        
        # 提示用户登录
        if docker login $REGISTRY; then
            echo "✅ 登录成功!"
        else
            echo "❌ 登录失败"
            exit 1
        fi
    fi
    
    # 标记并推送镜像
    echo ""
    echo "┌──────────────────────────────────────────────┐"
    echo "│              📤 推送到仓库                  │"
    echo "└──────────────────────────────────────────────┘"
    echo "🏷️  为镜像添加远程标签..."
    docker tag $IMAGE_NAME:$TAG $FULL_IMAGE_NAME
    
    echo "📤 推送镜像到私有仓库..."
    echo "🎯 推送目标: $FULL_IMAGE_NAME"
    echo ""
    
    # 尝试推送镜像，如果失败则重新登录
    if docker push $FULL_IMAGE_NAME; then
        echo ""
        echo "┌──────────────────────────────────────────────┐"
        echo "│            🎉 推送成功! 创建部署包          │"
        echo "└──────────────────────────────────────────────┘"
        
        # 调用部署包创建函数
        create_deployment_package
        
    else
        echo ""
        echo "❌ 镜像推送失败，可能是登录凭据过期"
        echo "📝 请重新输入登录信息:"
        
        # 重新登录并再次尝试推送
        if docker login $REGISTRY; then
            echo "✅ 重新登录成功，再次尝试推送..."
            if docker push $FULL_IMAGE_NAME; then
                echo ""
                echo "┌──────────────────────────────────────────────┐"
                echo "│            🎉 推送成功! 创建部署包          │"
                echo "└──────────────────────────────────────────────┘"
                
                # 调用部署包创建函数
                create_deployment_package
            else
                echo "❌ 重新推送仍然失败"
                exit 1
            fi
        else
            echo "❌ 重新登录失败"
            exit 1
        fi
    fi
    
    else
        echo ""
        echo "❌ Docker镜像构建失败"
        exit 1
    fi

else
    echo "┌──────────────────────────────────────────────┐"
    echo "│              ✅ 构建完成                    │"
    echo "└──────────────────────────────────────────────┘"
    echo ""
    echo "📁 Flutter Web 构建文件已更新: build/web/"
    echo "💡 如需Docker部署，请重新运行脚本选择选项1或2"
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║            ✨ 仅构建任务完成! ✨            ║"
    echo "╚══════════════════════════════════════════════╝"
fi