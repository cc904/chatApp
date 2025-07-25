# Flutter Web Docker 部署指南

## 快速开始

### 1. 构建并启动服务

```bash
# 使用构建脚本（推荐）
./scripts/build-web-docker.sh

# 或者使用 Docker Compose
docker-compose -f docker-compose.web.yml up --build -d
```

### 2. 访问应用

应用将在 `http://localhost:8080` 启动

### 3. 查看服务状态

```bash
# 使用脚本
./scripts/build-web-docker.sh status

# 或者直接使用 Docker Compose
docker-compose -f docker-compose.web.yml ps
```

## 构建脚本命令

```bash
# 构建并启动服务（默认）
./scripts/build-web-docker.sh build

# 完全重新构建
./scripts/build-web-docker.sh rebuild

# 启动服务
./scripts/build-web-docker.sh start

# 停止服务
./scripts/build-web-docker.sh stop

# 重启服务
./scripts/build-web-docker.sh restart

# 查看日志
./scripts/build-web-docker.sh logs

# 查看状态
./scripts/build-web-docker.sh status

# 清理资源
./scripts/build-web-docker.sh clean

# 显示帮助
./scripts/build-web-docker.sh help
```

## 文件结构

```
.
├── Dockerfile.web              # Flutter Web Docker 文件
├── docker-compose.web.yml      # Docker Compose 配置
├── docker/
│   └── nginx.conf              # Nginx 配置文件
├── scripts/
│   └── build-web-docker.sh     # 构建脚本
├── .dockerignore               # Docker 忽略文件
└── logs/
    └── nginx/                  # Nginx 日志目录
```

## 配置说明

### Dockerfile.web
- 多阶段构建，减小镜像大小
- 使用 CanvasKit 渲染器
- 非 root 用户运行
- 包含健康检查

### Nginx 配置
- 优化的缓存策略
- CORS 支持
- Gzip 压缩
- Flutter Web 特定优化

### Docker Compose
- 端口映射：8080 → 80
- 日志卷挂载
- 健康检查
- 自动重启

## 生产环境部署

### 1. 修改端口映射

编辑 `docker-compose.web.yml`：

```yaml
ports:
  - "80:80"  # 或其他需要的端口
```

### 2. 配置域名

编辑 `docker/nginx.conf`：

```nginx
server_name your-domain.com;
```

### 3. 启用 HTTPS

添加 SSL 证书和配置到 Nginx。

### 4. 环境变量

在 `docker-compose.web.yml` 中添加必要的环境变量。

## 故障排除

### 查看日志

```bash
# 容器日志
docker logs cc-flutter-web

# Nginx 日志
cat logs/nginx/access.log
cat logs/nginx/error.log
```

### 常见问题

1. **构建失败**：检查 Flutter 版本和依赖
2. **访问失败**：检查端口映射和防火墙
3. **静态资源404**：检查 Nginx 配置和文件路径

## 性能优化

### 镜像优化
- 使用 `.dockerignore` 减少构建上下文
- 多阶段构建减小最终镜像大小
- 使用 Alpine Linux 基础镜像

### 运行时优化
- Nginx Gzip 压缩
- 静态资源缓存
- CanvasKit 渲染器

## 监控

### 健康检查

Docker 会自动进行健康检查：

```bash
docker inspect cc-flutter-web --format='{{.State.Health.Status}}'
```

### 资源使用

```bash
docker stats cc-flutter-web
```