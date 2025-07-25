# 文件类型限制配置示例

## 🎯 配置结构（包含分类限制）

### 服务端登录响应

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

## 📋 文件大小限制说明

| 文件类型 | 字段名 | 默认限制 | 说明 |
|----------|--------|----------|------|
| 图片 | `imageMaxSize` | 10MB | 支持 jpg, png, gif 等格式 |
| 视频 | `videoMaxSize` | 500MB | 支持 mp4, avi, mov 等格式 |
| 音频 | `audioMaxSize` | 50MB | 支持 mp3, wav, aac 等格式 |
| 文档 | `documentMaxSize` | 100MB | 支持 pdf, doc, txt 等格式 |

## 🔧 客户端使用示例

### 1. 文件大小验证

```dart
// 获取配置
final config = DynamicFileServerConfig().currentConfig;

if (config != null) {
  // 根据文件类型进行大小验证
  bool isValidSize = config.isFileSizeValidForType(fileSize, fileType);
  
  if (!isValidSize) {
    switch (fileType.toLowerCase()) {
      case 'image':
        throw Exception('图片大小超过限制: ${config.limits?.imageMaxSize ?? config.maxFileSize} 字节');
      case 'video':
        throw Exception('视频大小超过限制: ${config.limits?.videoMaxSize ?? config.maxFileSize} 字节');
      case 'audio':
      case 'voice':
        throw Exception('音频大小超过限制: ${config.limits?.audioMaxSize ?? config.maxFileSize} 字节');
      case 'document':
        throw Exception('文档大小超过限制: ${config.limits?.documentMaxSize ?? config.maxFileSize} 字节');
      default:
        throw Exception('文件大小超过限制: ${config.maxFileSize} 字节');
    }
  }
}
```

### 2. 上传前验证示例

```dart
class FileUploadValidator {
  final DynamicFileServerConfig _config = DynamicFileServerConfig();

  /// 验证图片文件
  bool validateImageFile(File imageFile) {
    final fileSize = imageFile.lengthSync();
    final config = _config.currentConfig;
    
    if (config == null) return true; // 没有配置时允许上传
    
    return config.isFileSizeValidForType(fileSize, 'image');
  }

  /// 验证视频文件
  bool validateVideoFile(File videoFile) {
    final fileSize = videoFile.lengthSync();
    final config = _config.currentConfig;
    
    if (config == null) return true;
    
    return config.isFileSizeValidForType(fileSize, 'video');
  }

  /// 验证音频文件
  bool validateAudioFile(File audioFile) {
    final fileSize = audioFile.lengthSync();
    final config = _config.currentConfig;
    
    if (config == null) return true;
    
    return config.isFileSizeValidForType(fileSize, 'audio');
  }

  /// 验证文档文件
  bool validateDocumentFile(File documentFile) {
    final fileSize = documentFile.lengthSync();
    final config = _config.currentConfig;
    
    if (config == null) return true;
    
    return config.isFileSizeValidForType(fileSize, 'document');
  }

  /// 获取文件类型的大小限制
  int? getFileSizeLimit(String fileType) {
    final config = _config.currentConfig;
    if (config?.limits == null) return config?.maxFileSize;
    
    switch (fileType.toLowerCase()) {
      case 'image':
      case 'images':
        return config!.limits!.imageMaxSize;
      case 'video':
      case 'videos':
        return config!.limits!.videoMaxSize;
      case 'audio':
      case 'voice':
        return config!.limits!.audioMaxSize;
      case 'document':
      case 'files':
        return config!.limits!.documentMaxSize;
      default:
        return config!.maxFileSize;
    }
  }
}
```

### 3. UI 中显示限制信息

```dart
class FileUploadLimitsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = DynamicFileServerConfig().currentConfig;
    
    if (config?.limits == null) {
      return Text('文件大小限制: ${_formatFileSize(config?.maxFileSize ?? 500 * 1024 * 1024)}');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('文件大小限制:'),
        Text('• 图片: ${_formatFileSize(config!.limits!.imageMaxSize)}'),
        Text('• 视频: ${_formatFileSize(config!.limits!.videoMaxSize)}'),
        Text('• 音频: ${_formatFileSize(config!.limits!.audioMaxSize)}'),
        Text('• 文档: ${_formatFileSize(config!.limits!.documentMaxSize)}'),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)}${suffixes[i]}';
  }
}
```

## 🔄 工作流程

### 1. 配置获取流程
```
用户登录 → 服务器返回配置 → 解析limits字段 → 保存到本地 → 应用到文件验证
```

### 2. 文件上传流程
```
选择文件 → 检测文件类型 → 验证对应类型限制 → 上传或提示错误
```

### 3. 限制检查优先级
```
1. 检查特定类型限制（limits.xxxMaxSize）
2. 如果没有特定限制，使用通用限制（maxFileSize）
3. 如果没有配置，使用默认值
```

## 📊 配置示例

### 生产环境（严格限制）
```json
{
  "maxFileSize": 524288000,
  "limits": {
    "imageMaxSize": 5242880,     // 5MB
    "videoMaxSize": 104857600,   // 100MB
    "audioMaxSize": 26214400,    // 25MB
    "documentMaxSize": 52428800  // 50MB
  }
}
```

### 开发环境（宽松限制）
```json
{
  "maxFileSize": 1073741824,
  "limits": {
    "imageMaxSize": 20971520,    // 20MB
    "videoMaxSize": 524288000,   // 500MB
    "audioMaxSize": 104857600,   // 100MB
    "documentMaxSize": 209715200 // 200MB
  }
}
```

## 🚀 优势

1. **精细控制**: 可以为不同文件类型设置不同的大小限制
2. **灵活配置**: 服务端可以根据需要调整各类型限制
3. **向后兼容**: 如果没有limits字段，使用maxFileSize作为统一限制
4. **用户友好**: 可以为用户显示每种文件类型的具体限制

## 📝 与服务端协商要点

1. **limits字段是可选的**: 如果不提供，客户端使用maxFileSize
2. **默认值设置**: 确定每种文件类型的合理默认限制
3. **错误提示**: 当文件超过限制时，返回具体的错误信息
4. **动态调整**: 支持运行时修改限制配置

---

**总结**: 分类文件大小限制提供了更精细的控制能力，让不同类型的文件可以有不同的大小限制，提升用户体验和系统灵活性。