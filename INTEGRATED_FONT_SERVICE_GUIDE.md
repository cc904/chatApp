# 集成字体服务使用指南

## 概述

现在`server.js`已经集成了完整的Google Fonts代理缓存服务，可以直接为Flutter Web应用提供字体服务，无需单独运行`fonts-server.js`。

## 新功能特性

### ✅ 已集成功能
1. **Google Fonts代理** - 自动缓存和代理Google字体
2. **字体子集API** - 支持动态字体子集生成
3. **双层缓存系统** - 内存+磁盘缓存
4. **REST API接口** - 完整的API支持
5. **CORS支持** - 跨域访问
6. **健康检查** - 服务状态监控

### 🔧 服务端点

| 端点 | 方法 | 描述 |
|---|---|---|
| `/health` | GET | 健康检查 |
| `/cache/stats` | GET | 缓存统计 |
| `/manifest` | GET | 字体清单 |
| `/subset` | POST | 字体子集生成 |
| `/{fontFamily}/{version}/{filename}` | GET | Google字体代理 |
| `/fonts/{fontFamily}/{version}/{filename}` | GET | Google字体代理（兼容前缀） |
| `/character-sets/*` | GET | 字符集文件服务 |

## 容器配置

### 1. 构建和运行

```bash
# 构建镜像
docker build -t x0x-chatapp:latest .

# 运行容器（开发环境）
docker-compose up flutter-web

# 或者使用环境变量
docker run -p 7002:80 \
  -e EXTERNAL_HOST=localhost \
  -e NODE_ENV=production \
  x0x-chatapp:latest
```

### 2. 字体缓存持久化

容器会自动创建`/app/cache`目录用于字体缓存，并通过卷挂载实现持久化：

```yaml
# docker-compose.yml中已配置
volumes:
  - font-cache-dev:/app/cache
```

## Flutter Web集成

### 1. 基本配置

在Flutter Web应用中配置字体服务地址：

```javascript
// 在index.html中添加
window.initializeEngine({
  fontFallbackBaseUrl: window.location.origin + "/",
});
```

### 2. 使用本地字体代理

```javascript
// 使用本地Google字体代理
const fontUrl = window.location.origin + "/noto-sans-cjk-sc/v26/NotoSansCJKsc-Regular.woff2";
```

### 3. 动态字体子集

```javascript
// 使用字体子集API
const response = await fetch('/subset', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    text: "你好世界",
    fontFamily: "NotoSansCJK"
  })
});
```

## 测试验证

### 1. 检查服务状态

```bash
# 健康检查
curl http://localhost:7002/health

# 缓存统计
curl http://localhost:7002/cache/stats
```

### 2. 测试字体代理

```bash
# 测试Google字体代理
curl -I http://localhost:7002/noto-sans-cjk-sc/v26/NotoSansCJKsc-Regular.woff2

# 测试字体子集
curl -X POST http://localhost:7002/subset \
  -H "Content-Type: application/json" \
  -d '{"text":"测试","fontFamily":"NotoSansCJK"}'
```

## 性能优化

### 1. 缓存策略
- **内存缓存**: 50MB限制，LRU淘汰
- **磁盘缓存**: 永久存储，自动管理
- **HTTP缓存**: 1年有效期

### 2. 监控指标

通过`/cache/stats`可以查看：
- 内存缓存命中率
- 磁盘缓存使用情况
- 缓存项数量

## 故障排除

### 常见问题

1. **node-fetch未安装**
   - 已在Dockerfile中自动安装
   - 手动安装: `npm install node-fetch@2`

2. **字体加载失败**
   - 检查网络连接
   - 查看容器日志: `docker-compose logs flutter-web`

3. **缓存不生效**
   - 检查卷挂载: `docker volume ls`
   - 查看缓存目录: `docker exec -it x0x-chatapp ls -la /app/cache`

## 环境变量

| 变量 | 默认值 | 描述 |
|---|---|---|
| `NODE_ENV` | production | 运行环境 |
| `LOG_LEVEL` | info | 日志级别 |
| `PORT` | 80 | HTTP端口 |
| `EXTERNAL_HOST` | localhost | 外部访问地址 |

## 迁移说明

### 从独立字体服务迁移

1. **停止旧服务**
   ```bash
   # 如果之前运行了fonts-server.js
   pkill -f fonts-server.js
   ```

2. **更新配置**
   - 所有字体请求现在直接指向主服务端口（7002）
   - 无需额外的7000端口

3. **验证功能**
   - 原有API完全兼容
   - 性能提升（减少网络跳转）

## 使用示例

### 完整集成代码

```html
<!-- 在web/index.html中添加 -->
<script>
  // 配置字体服务
  window.flutterFontConfig = {
    baseUrl: window.location.origin,
    enableCache: true,
    preloadFonts: [
      "/noto-sans-cjk-sc/v26/NotoSansCJKsc-Regular.woff2"
    ]
  };
  
  // 初始化Flutter
  window.addEventListener('load', function() {
    initializeFontEngine();
    checkFontServiceHealth();
  });
</script>
```

现在您的Flutter Web应用可以直接使用集成在`server.js`中的字体服务，无需额外配置！