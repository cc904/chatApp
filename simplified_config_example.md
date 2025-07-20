# 简化后的文件服务器配置示例

## 🎯 配置结构

### 服务端返回的配置（简化版）

```json
{
  "success": true,
  "currentUser": {
    "userId": "user123",
    "nickname": "张三",
    "phone": "13800138000"
  },
  "tokens": {
    "apiToken": "jwt_token_here",
    "refreshToken": "refresh_token_here"
  },
  "serverConfig": {
    "fileServer": {
      "baseUrl": "http://fileserver.example.com",
      "uploadApiUrl": "http://fileserver.example.com/api/v1/upload",
      "downloadBaseUrl": "http://fileserver.example.com",
      "maxFileSize": 524288000,
      "limits": {
        "imageMaxSize": 10485760,
        "videoMaxSize": 524288000,
        "audioMaxSize": 52428800,
        "documentMaxSize": 104857600
      }
    }
  }
}
```

## 🔧 客户端使用示例

### 1. 配置解析和存储

```dart
// 从登录响应中解析配置
final config = DynamicFileServerConfig().parseConfigFromLoginResponse(loginResponse);

// 如果解析成功，更新配置
if (config != null) {
  await DynamicFileServerConfig().updateConfig(config);
}
```

### 2. 文件上传

```dart
// 上传API会自动使用配置的地址
final result = await UploadApiService().uploadImage(
  imageFile,
  conversationId: 'conv123',
  caption: '图片说明',
);
```

### 3. 文件URL构建

```dart
// 构建文件URL
final fileUrl = FileServerConfig().buildFileUrl(
  type: 'images',
  conversationId: 'conv123',
  timestamp: '1642678800000',
  userId: 'user456',
  fileName: 'abc123.jpg',
);
// 结果: http://fileserver.example.com/images/conv123/1642678800000/user456/abc123.jpg

// 构建缩略图URL
final thumbnailUrl = FileServerConfig().buildThumbnailUrl(
  conversationId: 'conv123',
  timestamp: '1642678800000',
  userId: 'user456',
  thumbnailFileName: 'thumb_abc123.jpg',
);
// 结果: http://fileserver.example.com/thumbnail/conv123/1642678800000/user456/thumb_abc123.jpg
```

### 4. 文件大小验证

```dart
// 检查文件大小是否符合限制
final config = DynamicFileServerConfig().currentConfig;
if (config != null) {
  final isValidSize = config.isFileSizeValid(fileSize);
  if (!isValidSize) {
    print('文件大小超过限制');
  }
}
```

## 📋 配置字段说明

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `baseUrl` | string | ✅ | 文件服务器基础URL |
| `uploadApiUrl` | string | ✅ | 上传API完整URL |
| `downloadBaseUrl` | string | ✅ | 下载基础URL |
| `maxFileSize` | number | ❌ | 最大文件大小(字节) |
| `limits` | object | ❌ | 各类型文件大小限制 |

## 🔄 配置流程

1. **应用启动** → 加载本地缓存的配置
2. **用户登录** → 从服务器获取最新配置
3. **配置更新** → 保存到本地 + 同步到各服务
4. **文件操作** → 自动使用最新配置
5. **用户登出** → 清除配置

## 🚀 优势

- **简化**: 保留核心配置字段
- **专注**: URL配置 + 分类文件大小限制
- **灵活**: 仍然支持动态配置更新
- **可靠**: 有完善的错误处理和后备机制

## 📝 与服务端协商重点

1. **必需字段**: 确保 `baseUrl`, `uploadApiUrl`, `downloadBaseUrl` 始终存在
2. **默认值**: 当可选字段缺失时的默认行为
3. **错误处理**: 配置解析失败时的处理方式
4. **兼容性**: 确保老版本客户端不受影响

---

**注意**: 这个版本保留了核心配置字段，包括分类文件大小限制，在灵活性和简洁性之间取得平衡。