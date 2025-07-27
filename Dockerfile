# Flutter Web Docker - 支持WASM MIME类型的优化版本
FROM node:18-alpine AS runtime

# 安装基础工具
RUN apk add --no-cache curl

WORKDIR /app

# 复制构建好的web文件
COPY build/web ./web/

# 复制Node.js服务器和配置文件
COPY server.js ./
COPY login_domains.json ./
# current_server.json 是可选文件，不复制（程序会自动创建）

# 创建启动脚本，确保正确的MIME类型支持
RUN printf '#!/bin/sh\n\
set -e\n\
\n\
echo "🚀 Flutter Web Docker 启动"\n\
echo "📱 应用名称: ${APP_NAME}"\n\
echo "🏷️  版本: ${APP_VERSION}"\n\
echo "🌐 监听: ${HOST}:${PORT}"\n\
echo "🔧 环境: ${NODE_ENV}"\n\
echo "📊 日志级别: ${LOG_LEVEL}"\n\
echo "🔧 WASM MIME支持: 已启用"\n\
echo "📦 字体: 完全本地化"\n\
\n\
# 启动Node.js服务器（支持正确的MIME类型）\n\
cd /app\n\
exec node server.js\n' > start.sh

# 修改Node.js服务器配置
RUN sed -i 's|build/web|web|g' server.js

RUN chmod +x start.sh

# 环境变量配置
ENV NODE_ENV=production
ENV PORT=80
ENV HOST=0.0.0.0
ENV APP_NAME="Flutter Web App"
ENV APP_VERSION="1.0.0"
ENV LOG_LEVEL=info

# 暴露HTTP和HTTPS端口
EXPOSE 80 443

# 健康检查（优先检查HTTPS，失败则检查HTTP）
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
  CMD curl -k -f https://localhost:443/ || curl -f http://localhost:80/ || exit 1

# 检查并使用现有用户或创建新用户
RUN if getent passwd 1000 > /dev/null 2>&1; then \
        # 如果UID 1000已存在，使用该用户
        existing_user=$(getent passwd 1000 | cut -d: -f1) && \
        chown -R $existing_user:$(id -gn $existing_user) /app && \
        chmod -R 755 /app && \
        echo "Using existing user: $existing_user"; \
    else \
        # 如果UID 1000不存在，创建新用户
        adduser -D -u 1000 appuser && \
        chown -R appuser:appuser /app && \
        chmod -R 755 /app && \
        echo "Created new user: appuser"; \
    fi

# 切换到UID 1000用户（无论用户名是什么）
USER 1000

# 启动命令
CMD ["./start.sh"]