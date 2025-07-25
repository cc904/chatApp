# Flutter Web Docker - 支持WASM MIME类型的优化版本
FROM node:18-alpine AS runtime

# 安装基础工具
RUN apk add --no-cache curl

WORKDIR /app

# 复制构建好的web文件
COPY build/web ./web/

# 复制Node.js服务器
COPY server.js ./

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

# 修改Node.js服务器端口为80
RUN sed -i 's/const PORT = 9014;/const PORT = 80;/' server.js

# 修改服务器路径（所有相关路径）
RUN sed -i 's|build/web|web|g' server.js

RUN chmod +x start.sh

# 环境变量配置
ENV NODE_ENV=production
ENV PORT=80
ENV HOST=0.0.0.0
ENV APP_NAME="Flutter Web App"
ENV APP_VERSION="1.0.0"
ENV LOG_LEVEL=info

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# 非root用户运行
RUN addgroup -g 1001 -S nodejs && \
    adduser -S flutter -u 1001 -G nodejs && \
    chown -R flutter:nodejs /app

USER flutter

# 启动命令
CMD ["./start.sh"]