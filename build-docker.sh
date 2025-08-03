#!/bin/bash

# Flutter Web Docker 构建脚本
# 
# 环境变量支持:
# - DOCKER_REGISTRY_USERNAME: Docker仓库用户名
# - DOCKER_REGISTRY_PASSWORD: Docker仓库密码
# 
# 如果未设置环境变量，脚本会提示交互式输入
# 密码使用 --password-stdin 方式安全传输

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
echo "  1) 🚀 完全重新构建 (推荐) - Release版本+HTTP/HTTPS"
echo "  2) 📦 仅打包现有构建 - 使用已有build/web"
echo "  3) 🛠️  仅构建不打包 - 只更新build/web"
echo "  4) 🐛 Debug模式构建 - 调试版本+详细日志+HTTP/HTTPS"
echo ""
read -t 10 -p "请输入选择 (1-4) [默认: 1, 10秒后自动选择]: " BUILD_CHOICE

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
        BUILD_MODE="release"
        ;;
    2)
        echo "✅ 选择: 仅打包现有构建"
        DO_CLEAN=false
        DO_BUILD=false
        DO_DOCKER=true
        BUILD_MODE="release"
        ;;
    3)
        echo "✅ 选择: 仅构建不打包"
        DO_CLEAN=true
        DO_BUILD=true
        DO_DOCKER=false
        BUILD_MODE="release"
        ;;
    4)
        echo "✅ 选择: Debug模式构建 (包含HTTP/HTTPS支持)"
        DO_CLEAN=true
        DO_BUILD=true
        DO_DOCKER=true
        BUILD_MODE="debug"
        ;;
    *)
        echo "❌ 无效选择，使用默认: 完全重新构建"
        DO_CLEAN=true
        DO_BUILD=true
        DO_DOCKER=true
        BUILD_MODE="release"
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
- 构建版本: \`$VERSION_TAG\`
- 环境标签: \`$ENV_TAG\`
- 版本+Git标签: \`$VERSION_GIT_TAG\`
- 构建时间: \`$(date '+%Y-%m-%d %H:%M:%S')\`
- 镜像仓库: \`$REGISTRY/$IMAGE_NAME\`

## 可用镜像标签
- \`$REGISTRY/$IMAGE_NAME:$ENV_TAG\` (环境标签)
- \`$REGISTRY/$IMAGE_NAME:$VERSION_GIT_TAG\` (版本+Git标签)

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

## 🔧 文件权限说明

### Docker Compose中已配置用户
\`\`\`yaml
user: "1000:1000"  # 容器内使用UID 1000运行
\`\`\`

### 如果遇到权限问题
如果Docker容器无法访问挂载的文件，可以设置文件权限：
\`\`\`bash
# 可选：设置为Docker用户权限
sudo chown -R 1000:1000 ./

# 或者使用当前用户权限
sudo chown -R \$(id -u):\$(id -g) ./
\`\`\`

### 推荐做法
1. 使用Docker Compose的user配置（已设置）
2. 文件权限保持解压者权限即可
3. 容器会自动适配权限
EOF
    
    # 创建压缩包 (使用当前用户权限，避免sudo)
    echo "📦 创建压缩包，使用当前用户权限..."
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
        echo "📦 本地镜像: $IMAGE_NAME:$ENV_TAG"
        echo "🏷️  版本+Git标签: $VERSION_GIT_TAG"
        echo "🌐 远程仓库: $REGISTRY/$IMAGE_NAME"
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
        echo "│                                              │"
        echo "│  💡 Docker会自动处理用户权限                │"
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
        
        # 🔐 根据构建模式配置域名加密
        echo "🔐 配置登录域名..."
        if [ "$BUILD_MODE" = "debug" ]; then
            echo "   📍 使用开发环境域名 (development)"
            DOMAIN_MODE="development"
            DOMAIN_CHOICE="1"
        else
            echo "   📍 使用生产环境域名 (production)"
            DOMAIN_MODE="production"
            DOMAIN_CHOICE="2"
        fi
        
        # 显示即将加密的域名列表
        if [ -f "login_domains.json" ]; then
            echo "   🔍 读取域名配置..."
            # 提取指定环境的域名列表
            DOMAINS=$(python3 -c "
import json
import sys
try:
    with open('login_domains.json', 'r') as f:
        data = json.load(f)
    domains = data.get('$DOMAIN_MODE', [])
    for domain in domains:
        print(domain)
except Exception as e:
    sys.exit(1)
" 2>/dev/null)
            
            if [ -n "$DOMAINS" ]; then
                echo "   📋 即将加密的域名列表 ($DOMAIN_MODE 环境):"
                echo "$DOMAINS" | while read domain; do
                    if [ -n "$domain" ] && [ "$domain" != "null" ]; then
                        echo "      🌐 $domain (无http前缀)"
                    fi
                done
            else
                echo "   ⚠️  未找到 $DOMAIN_MODE 环境的域名配置"
                echo "   💡 请检查 login_domains.json 格式是否正确"
                exit 1
            fi
        else
            echo "   ❌ login_domains.json 文件不存在"
            exit 1
        fi
        
        # 检查域名加密工具是否存在
        if [ ! -f "scripts/auto_encrypt_domains.dart" ]; then
            echo "   ❌ 域名加密工具不存在: scripts/auto_encrypt_domains.dart"
            echo "   💡 请确保项目包含域名加密工具"
            exit 1
        fi
        
        # 自动运行域名加密工具
        echo "   🔒 加密域名到assets文件..."
        if echo "y" | dart run scripts/auto_encrypt_domains.dart > /dev/null 2>&1; then
            echo "   ✅ 域名加密完成 (完整配置)"
        else
            echo "   ❌ 域名加密失败"
            echo "   💡 请检查 login_domains.json 配置是否正确"
            echo "   💡 确保域名格式为: \"domain.com:port\" (不带http前缀)"
            exit 1
        fi
        echo ""
        
        if [ "$BUILD_MODE" = "debug" ]; then
            echo "🐛 构建Debug版本..."
            if flutter build web --debug \
                --no-web-resources-cdn \
                --dart-define=FLUTTER_WEB_CANVASKIT_URL=./canvaskit/; then
                echo "✅ Debug Web构建成功 (包含调试符号 + 详细日志)"
            else
                echo "❌ Debug Web构建失败"
                exit 1
            fi
        else
            echo "🚀 构建Release版本..."
            if flutter build web --release \
                --no-web-resources-cdn \
                --dart-define=FLUTTER_WEB_CANVASKIT_URL=./canvaskit/; then
                echo "✅ Release Web构建成功 (CanvasKit本地化 + 完全无CDN依赖)"
            else
                echo "❌ Release Web构建失败"
                exit 1
            fi
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
    # 版本管理 - 自动递增版本号
    echo "┌──────────────────────────────────────────────┐"
    echo "│               📊 版本管理                   │"
    echo "└──────────────────────────────────────────────┘"
    
    # 检查版本管理器是否存在
    if [ ! -f "scripts/version-manager.js" ]; then
        echo "❌ 版本管理器不存在: scripts/version-manager.js"
        exit 1
    fi
    
    # 自动递增版本号
    echo "📈 递增构建版本号..."
    BUILD_VERSION=$(node scripts/version-manager.js --quiet 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$BUILD_VERSION" ]; then
        echo "✅ 新版本号: v$BUILD_VERSION"
        
        # 验证版本号格式（只包含数字和点）
        if [[ ! "$BUILD_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "❌ 版本号格式无效: $BUILD_VERSION"
            echo "💡 Docker标签只能包含字母、数字、点、连字符和下划线"
            exit 1
        fi
    else
        echo "❌ 版本号递增失败"
        exit 1
    fi
    
    # 获取Git短hash（可选）
    GIT_HASH=""
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "")
        if [ -n "$GIT_HASH" ]; then
            # 验证Git hash格式（只包含小写字母和数字）
            if [[ "$GIT_HASH" =~ ^[a-f0-9]+$ ]]; then
                echo "🔖 Git提交: $GIT_HASH"
            else
                echo "⚠️  Git hash格式异常，跳过Git标签: $GIT_HASH"
                GIT_HASH=""
            fi
        fi
    fi
    echo ""
    
    # 构建Docker镜像
    IMAGE_NAME="x0x-chatapp"
    if [ "$BUILD_MODE" = "debug" ]; then
        ENV_TAG="debug"
        DOCKERFILE="Dockerfile.debug"
    else
        ENV_TAG="latest"
        DOCKERFILE="Dockerfile"
    fi
    REGISTRY="nrt.vultrcr.com/ex00"
    
    # 定义标签 - 合并版本和git为一个标签
    VERSION_TAG="v$BUILD_VERSION"
    if [ -n "$GIT_HASH" ]; then
        VERSION_GIT_TAG="v$BUILD_VERSION-$GIT_HASH"
    else
        VERSION_GIT_TAG="v$BUILD_VERSION"
    fi

    echo "┌──────────────────────────────────────────────┐"
    echo "│                🔨 构建镜像                  │"
    echo "└──────────────────────────────────────────────┘"
    echo "🔧 构建模式: $BUILD_MODE"
    echo "📄 Dockerfile: $DOCKERFILE"
    echo "📦 本地镜像: $IMAGE_NAME:$ENV_TAG"
    echo "🏷️  版本+Git标签: $VERSION_GIT_TAG"
    echo ""

    # 构建镜像（使用环境标签作为主标签）
    docker build -f $DOCKERFILE -t $IMAGE_NAME:$ENV_TAG .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Docker镜像构建成功!"
    
    # 为镜像添加所有标签
    echo ""
    echo "🏷️  为镜像添加多个标签..."
    
    # 添加合并的版本+git标签
    docker tag $IMAGE_NAME:$ENV_TAG $IMAGE_NAME:$VERSION_GIT_TAG
    echo "   ✅ 版本+Git标签: $IMAGE_NAME:$VERSION_GIT_TAG"
    
    echo ""
    echo "┌──────────────────────────────────────────────┐"
    echo "│               📊 镜像信息                   │"
    echo "└──────────────────────────────────────────────┘"
    docker images $IMAGE_NAME
    
    # 检查Docker登录状态
    echo ""
    echo "┌──────────────────────────────────────────────┐"
    echo "│              🔐 检查登录状态                │"
    echo "└──────────────────────────────────────────────┘"
    
    # 简化的登录检查和处理
    echo "🔍 检查 $REGISTRY 登录状态..."
    
    # Docker登录函数 - 自动登录
    docker_login_secure() {
        # 自动登录 - 使用预设凭据
        echo "🔑 自动登录Docker仓库..."
        local username="0e16fc27-2c9d-46ab-b3f5-0f529a7341e9"
        local password="Ja6oDYWFAASWPSxB4yfZDf8d8GpMfnrexP3N"
        
        # 使用 --password-stdin 安全登录
        if echo "$password" | docker login $REGISTRY --username "$username" --password-stdin; then
            echo "✅ 登录成功!"
            return 0
        else
            echo "❌ 登录失败"
            return 1
        fi
    }
    
    # 检查是否有登录凭据
    if grep -q "$REGISTRY" ~/.docker/config.json 2>/dev/null; then
        echo "✅ 发现登录凭据，跳过登录"
    else
        echo "❌ 未找到登录凭据，自动执行登录..."
        if ! docker_login_secure; then
            echo "❌ 自动登录失败，无法继续推送"
            exit 1
        fi
    fi
    
    # 标记并推送镜像
    echo ""
    echo "┌──────────────────────────────────────────────┐"
    echo "│              📤 推送到仓库                  │"
    echo "└──────────────────────────────────────────────┘"
    
    # 定义远程标签
    REMOTE_ENV_TAG="$REGISTRY/$IMAGE_NAME:$ENV_TAG"
    REMOTE_VERSION_GIT_TAG="$REGISTRY/$IMAGE_NAME:$VERSION_GIT_TAG"
    
    # 为镜像添加远程标签
    echo "🏷️  为镜像添加远程标签..."
    docker tag $IMAGE_NAME:$ENV_TAG $REMOTE_ENV_TAG
    echo "   ✅ 环境标签: $REMOTE_ENV_TAG"
    
    docker tag $IMAGE_NAME:$ENV_TAG $REMOTE_VERSION_GIT_TAG
    echo "   ✅ 版本+Git标签: $REMOTE_VERSION_GIT_TAG"
    
    echo ""
    echo "📤 推送所有标签到私有仓库..."
    
    # 推送函数
    push_all_tags() {
        local success=true
        
        echo "🎯 推送环境标签: $REMOTE_ENV_TAG"
        if ! docker push $REMOTE_ENV_TAG; then
            success=false
        fi
        
        echo "🎯 推送版本+Git标签: $REMOTE_VERSION_GIT_TAG"
        if ! docker push $REMOTE_VERSION_GIT_TAG; then
            success=false
        fi
        
        return $([ "$success" = true ] && echo 0 || echo 1)
    }
    
    # 尝试推送所有镜像标签，如果失败则重新登录
    if push_all_tags; then
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
        if docker_login_secure; then
            echo "再次尝试推送所有标签..."
            if push_all_tags; then
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