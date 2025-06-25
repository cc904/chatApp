# 头像上传API接口需求文档

## 接口概述
客户端需要一个专门的头像上传接口，用于用户上传和更新个人头像。

## 接口详情

### 请求信息
- **方法**: `POST`
- **路径**: `/api/v1/upload/avatar`
- **Content-Type**: `multipart/form-data`
- **认证**: 需要 `Authorization: Bearer <token>` 头部

### 请求参数

#### 表单数据 (multipart/form-data)
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `file` | File | 是 | 头像图片文件 |

#### 文件限制
- **文件类型**: 支持 `image/jpeg`, `image/png`, `image/gif`, `image/webp`
- **文件大小**: 最大 10MB
- **图片尺寸**: 建议最大 800x800 像素（服务端可以自动压缩）

### 响应格式

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "fileId": "avatar_12345",
    "url": "https://your-domain.com/uploads/avatars/user123_avatar.jpg",
    "localPath": "/uploads/avatars/user123_avatar.jpg",
    "thumbnailUrl": "https://your-domain.com/uploads/avatars/thumbs/user123_avatar_thumb.jpg",
    "metadata": {
      "originalName": "my_avatar.jpg",
      "size": 245760,
      "mimeType": "image/jpeg",
      "width": 400,
      "height": 400
    }
  }
}
```

#### 错误响应

##### 401 - 未授权
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "认证失败，请登录"
  }
}
```

##### 400 - 请求错误
```json
{
  "success": false,
  "error": {
    "code": "NO_FILE",
    "message": "请选择要上传的文件"
  }
}
```

##### 413 - 文件过大
```json
{
  "success": false,
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "文件大小超过限制，最大允许 10MB",
    "details": {
      "maxSize": 10485760
    }
  }
}
```

##### 415 - 不支持的文件类型
```json
{
  "success": false,
  "error": {
    "code": "INVALID_MIME_TYPE",
    "message": "不支持的文件类型，请上传图片文件"
  }
}
```

##### 429 - 频率限制
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "上传过于频繁，请稍后再试"
  }
}
```

## 业务逻辑要求

### 1. 文件处理
- 自动检测文件类型和MIME类型
- 生成唯一的文件名（建议格式：`user_{userId}_{timestamp}.{ext}`）
- 保存原图和缩略图（推荐尺寸：128x128）
- 自动压缩大尺寸图片

### 2. 安全要求
- 验证JWT token有效性
- 检查文件头信息，防止恶意文件上传
- 限制单个用户的上传频率（建议：每分钟最多5次）
- 自动删除用户之前的头像文件（可选）

### 3. 存储要求
- 文件存储到独立的存储服务（如阿里云OSS、AWS S3等）
- 返回可公开访问的URL
- 支持CDN加速

### 4. 数据库更新
- **不需要**更新用户表中的头像字段
- 客户端会调用单独的用户信息更新接口来更新头像URL
- 只需要返回文件的访问URL即可

## 错误码说明

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `UNAUTHORIZED` | 401 | JWT token无效或过期 |
| `NO_FILE` | 400 | 未上传文件 |
| `INVALID_MIME_TYPE` | 415 | 文件类型不支持 |
| `INVALID_FILE_EXTENSION` | 415 | 文件扩展名不支持 |
| `FILE_TOO_LARGE` | 413 | 文件大小超过限制 |
| `FILENAME_TOO_LONG` | 400 | 文件名过长 |
| `INVALID_FILENAME` | 400 | 文件名包含非法字符 |
| `INVALID_FILE_HEADER` | 415 | 文件格式验证失败 |
| `UPLOAD_FAILED` | 500 | 服务器上传处理失败 |
| `RATE_LIMIT_EXCEEDED` | 429 | 上传频率超过限制 |

## 实现建议

### Node.js + Express 示例结构
```javascript
// routes/upload.js
router.post('/avatar', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    // 1. 验证文件
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: { code: 'NO_FILE', message: '请选择要上传的文件' }
      });
    }

    // 2. 文件类型检查
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(req.file.mimetype)) {
      return res.status(415).json({
        success: false,
        error: { code: 'INVALID_MIME_TYPE', message: '不支持的文件类型' }
      });
    }

    // 3. 上传到云存储
    const uploadResult = await uploadToCloudStorage(req.file, req.user.id);

    // 4. 返回结果
    res.json({
      success: true,
      data: {
        fileId: uploadResult.fileId,
        url: uploadResult.url,
        localPath: uploadResult.path,
        thumbnailUrl: uploadResult.thumbnailUrl,
        metadata: {
          originalName: req.file.originalname,
          size: req.file.size,
          mimeType: req.file.mimetype,
          width: uploadResult.width,
          height: uploadResult.height
        }
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { code: 'UPLOAD_FAILED', message: '上传失败' }
    });
  }
});
```

## 测试用例

### 正常上传测试
```bash
curl -X POST \
  http://localhost:3000/api/v1/upload/avatar \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/avatar.jpg"
```

### 无文件测试
```bash
curl -X POST \
  http://localhost:3000/api/v1/upload/avatar \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 无认证测试
```bash
curl -X POST \
  http://localhost:3000/api/v1/upload/avatar \
  -F "file=@/path/to/avatar.jpg"
```

## 注意事项

1. **与现有上传接口的区别**：
   - 头像上传不需要 `conversationId` 参数
   - 专门用于用户头像，有特殊的处理逻辑
   - 可能需要特殊的存储路径和命名规则

2. **安全考虑**：
   - 必须验证文件头信息，不能仅依赖扩展名
   - 建议对上传的图片进行重新编码，去除可能的恶意代码
   - 实施适当的速率限制

3. **性能优化**：
   - 支持图片压缩和格式转换
   - 生成多种尺寸的缩略图
   - 使用CDN分发静态资源

4. **用户体验**：
   - 支持上传进度回调
   - 提供清晰的错误信息
   - 快速响应和处理 