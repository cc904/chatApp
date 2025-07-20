# 文件服务器配置接口规范

## 概述

本文档定义了客户端在登录时如何从服务器获取文件服务器配置信息的接口规范。

## 1. 登录响应扩展

### 1.1 现有登录响应结构

```json
{
  "success": true,
  "currentUser": {
    "userId": "user_id",
    "nickname": "display_name",
    "phone": "phone_number",
    "email": "email",
    "avatar": "avatar_url",
    "status": "online",
    "lastLoginTime": 1642678800000
  },
  "tokens": {
    "refreshToken": "refresh_token",
    "refreshTokenExpiresAt": 1642678800000,
    "socketToken": "socket_token",
    "socketTokenExpiresAt": 1642678800000
  }
}
```

### 1.2 新增服务器配置字段

需要在登录响应中新增 `serverConfig` 字段：

```json
{
  "success": true,
  "currentUser": { ... },
  "tokens": { ... },
  "serverConfig": {
    "ss": {
      "1": "http://server1.example.com",
      "2": "http://server2.example.com"
    },
    "defs": "1",
    "fsUrl": {
      "1": "http://fs1.example.com",
      "2": "http://fs2.example.com"
    },
    "limits": {
      "imageMaxSize": 10485760,
      "videoMaxSize": 524288000,
      "fileMaxSize": 104857600
    }
  }
}
```

## 2. 文件服务器配置字段说明

### 2.1 必需字段

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `ss` | object | 服务器端点映射 | `{"1": "http://server1.com", "2": "http://server2.com"}` |
| `defs` | string | 默认服务器ID | `"1"` |
| `fsUrl` | object | 文件服务器URL映射 | `{"1": "http://fs1.com", "2": "http://fs2.com"}` |
| `limits` | object | 各类型文件的大小限制 | 见下表 |

### 2.2 可选字段

无可选字段，所有字段都是必需的。

### 2.3 limits 字段详细说明

| 字段名 | 类型 | 说明 | 默认值 |
|--------|------|------|-------|
| `imageMaxSize` | number | 图片最大大小(字节) | `10485760` (10MB) |
| `videoMaxSize` | number | 视频最大大小(字节) | `524288000` (500MB) |
| `fileMaxSize` | number | 文件最大大小(字节) | `104857600` (100MB) |

**注意**: 语音文件不再进行大小限制，仅通过时长进行限制。

### 2.4 文件服务器特性

文件服务器默认支持以下特性：
- 自动生成缩略图
- 无需认证下载
- 批量上传

## 3. 实现要求

### 3.1 服务端要求

1. **必须在所有登录接口中包含 `serverConfig` 字段**
   - `POST /api/v1/auth/login` (密码登录)
   - `POST /api/v1/auth/login` (验证码登录)
   - `POST /api/v1/auth/verifyToken` (token验证)

2. **配置信息应该是动态的**
   - 支持不同环境的不同配置
   - 支持运行时配置更新

3. **错误处理**
   - 如果文件服务器配置不可用，应提供默认配置
   - 确保登录不会因为文件服务器配置问题而失败

### 3.2 客户端处理

1. **配置优先级**
   - 登录响应配置 > 本地缓存配置 > 硬编码默认配置

2. **配置缓存**
   - 将配置信息缓存到本地安全存储
   - 支持离线时使用缓存配置

3. **配置更新**
   - 每次登录时更新配置
   - 支持配置热更新

## 4. 文件路径结构

### 4.1 文件上传路径

```
POST {uploadApiUrl}/{fileType}
```

参数：
- `file`: 文件内容
- `conversationId`: 会话ID
- `timestamp`: UTC时间戳
- `type`: 文件类型 (images/voice/videos/files/avatar)
- `metadata`: 元数据(JSON字符串)

### 4.2 文件存储路径

```
{fsUrl}/{type}/{conversationId}/{date}/{userId}/{fileName}
```

其中：
- `fsUrl`: 根据消息中的fsID从fsUrl映射中获取
- `type`: 文件类型 (images/voice/videos/files/avatar)
- `conversationId`: 会话ID
- `date`: 从消息created_at提取的日期，格式为YYYY-MM-DD
- `userId`: 用户ID
- `fileName`: 服务器生成的文件名

### 4.3 文件上传响应

上传成功后，服务器应返回：

```json
{
  "success": true,
  "data": {
    "fileId": "file_unique_id",
    "fileName": "server_generated_name.jpg",
    "fsId": "1",
    "url": "complete_file_url",
    "metadata": {
      "originalName": "original_name.jpg",
      "size": 1024000,
      "mimeType": "image/jpeg",
      "width": 1920,
      "height": 1080
    }
  }
}
```

## 5. 示例配置

### 5.1 生产环境配置

```json
{
  "serverConfig": {
    "fileServer": {
      "baseUrl": "https://files.yourapp.com",
      "uploadApiUrl": "https://files.yourapp.com/api/v1/upload",
      "downloadBaseUrl": "https://files.yourapp.com",
      "limits": {
        "imageMaxSize": 10485760,
        "videoMaxSize": 524288000,
        "audioMaxSize": 52428800,
        "fileMaxSize": 104857600
      }
    }
  }
}
```

### 5.2 开发环境配置

```json
{
  "serverConfig": {
    "fileServer": {
      "baseUrl": "http://localhost:3001",
      "uploadApiUrl": "http://localhost:3001/api/v1/upload",
      "downloadBaseUrl": "http://localhost:3001",
      "limits": {
        "imageMaxSize": 5242880,
        "videoMaxSize": 104857600,
        "audioMaxSize": 26214400,
        "fileMaxSize": 52428800
      }
    }
  }
}
```

## 6. 错误处理

### 6.1 文件服务器不可用

如果文件服务器配置字段缺失或无效，客户端应：

1. 使用默认配置
2. 记录警告日志
3. 继续正常登录流程

### 6.2 配置验证失败

客户端应验证配置的有效性：

1. URL格式验证
2. 文件大小限制合理性检查
3. 必需字段完整性检查

## 7. 兼容性说明

### 7.1 向后兼容

- 老版本客户端不受影响
- 新字段为可选，不会导致解析错误

### 7.2 向前兼容

- 新增功能应通过版本号或其他机制标识
- 客户端应检查功能支持情况

## 8. 安全考虑

### 8.1 URL验证

- 验证文件服务器URL的合法性
- 防止恶意URL注入

### 8.2 配置加密

- 敏感配置信息应加密存储
- 传输过程使用HTTPS

## 9. 测试用例

### 9.1 正常情况

```json
{
  "success": true,
  "currentUser": { ... },
  "tokens": { ... },
  "serverConfig": {
    "fileServer": {
      "baseUrl": "http://testserver.com",
      "uploadApiUrl": "http://testserver.com/api/v1/upload",
      "downloadBaseUrl": "http://testserver.com"
    }
  }
}
```

### 9.2 配置缺失

```json
{
  "success": true,
  "currentUser": { ... },
  "tokens": { ... }
  // 缺少 serverConfig 字段
}
```

### 9.3 部分配置

```json
{
  "success": true,
  "currentUser": { ... },
  "tokens": { ... },
  "serverConfig": {
    "fileServer": {
      "baseUrl": "http://testserver.com"
      // 缺少其他字段，客户端应使用默认值
    }
  }
}
```

## 10. 实施建议

### 10.1 分阶段实施

1. **第一阶段**: 基础配置字段 (baseUrl, uploadApiUrl, downloadBaseUrl)
2. **第二阶段**: 文件限制配置 (limits)
3. **第三阶段**: 高级配置选项和优化

### 10.2 监控和日志

- 记录配置获取成功/失败情况
- 监控文件服务器配置的使用情况
- 收集客户端配置解析错误

---

**注意**: 本规范应与服务端开发团队协商确定，确保双方理解一致。