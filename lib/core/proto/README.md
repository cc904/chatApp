# Protocol Buffers 定义

本目录包含项目中使用的 Protocol Buffers 定义文件。

## 目录结构

```
proto/
├── source/          # 原始 .proto 文件
│   ├── message.proto    # 消息相关定义
│   ├── user.proto       # 用户相关定义
│   └── conversation.proto # 会话相关定义
├── generated/       # 生成的 Dart 代码
└── README.md       # 本文档
```

## 文件说明

### message.proto

定义了消息相关的数据结构，包括：

#### 核心枚举
- `MessageType` - 消息类型（文本、图片、语音、文件等）
- `MessageStatus` - 消息状态（发送中、已发送、已送达、已读、失败）

#### 主要消息结构
- `MessageProto` - 基础消息结构，包含所有消息字段
- `TextMessage` - 文本消息内容
- `MediaMessage` - 媒体消息内容（图片、语音、文件、视频）
- `LocationMessage` - 位置消息内容
- `SystemMessage` - 系统消息内容
- `StickerMessage` - 表情包消息
- `ContactMessage` - 联系人名片消息
- `PollMessage` - 投票消息
- `LinkMessage` - 链接消息

#### 辅助结构
- `LinkPreview` - 链接预览
- `PollOption` - 投票选项
- `MessageCollection` - 消息集合
- `MessageResponse` - 消息响应
- `TypingProto` - 输入状态
- `MessageReadProto` - 消息已读状态

### 设计特点

#### 1. 本地优先设计
- 所有结构都针对本地存储和处理优化
- 移除了服务器端搜索和复杂查询接口
- 专注于消息的基本传输和存储

#### 2. 与数据库模型匹配
- `MessageProto` 结构完全匹配 Isar 数据库的 `Message` 模型
- 字段名称和类型保持一致，便于转换
- 支持所有消息类型和扩展字段

#### 3. 扩展性设计
- 使用 `oneof` 支持不同类型的消息内容
- 预留扩展字段支持未来功能
- 支持消息反应、标签、优先级等高级功能

#### 4. 简化的网络接口
- 保留基本的消息传输接口
- 移除复杂的搜索和分页接口
- 专注于实时消息同步

## 使用方式

### 1. 生成 Dart 代码

```bash
# 在项目根目录执行
protoc --dart_out=lib/core/proto/generated lib/core/proto/source/*.proto
```

### 2. 在代码中使用

```dart
import 'package:cc/core/proto/generated/message.pb.dart' as proto;

// 创建消息
final message = proto.MessageProto(
  messageId: 'msg_123',
  conversationId: 'conv_456',
  senderId: 'user_789',
  text: 'Hello World',
  type: proto.MessageType.TEXT,
);

// 转换为数据库模型
final dbMessage = Message.fromProto(message);

// 从数据库模型转换
final protoMessage = dbMessage.toProto();
```

### 3. 消息类型处理

```dart
// 处理不同类型的消息
switch (message.type) {
  case proto.MessageType.TEXT:
    // 处理文本消息
    break;
  case proto.MessageType.IMAGE:
    // 处理图片消息
    break;
  case proto.MessageType.VOICE:
    // 处理语音消息
    break;
  // ... 其他类型
}
```

## 版本历史

### v2.0.0 (当前版本)
- 移除服务器端搜索和获取接口
- 简化为本地优先的消息结构
- 保留核心消息传输功能
- 优化与本地数据库的兼容性

### v1.0.0 (已废弃)
- 包含完整的服务器端搜索接口
- 复杂的分页和过滤功能
- 服务器端聚合和统计

## 注意事项

1. **本地搜索**：项目使用本地搜索方案，不需要服务器端搜索接口
2. **数据库同步**：proto 结构与 Isar 数据库模型保持同步
3. **向后兼容**：移除的接口不影响现有的消息传输功能
4. **性能优化**：简化的结构提高了序列化/反序列化性能

## 开发指南

### 添加新的消息类型

1. 在 `MessageType` 枚举中添加新类型
2. 创建对应的消息内容结构
3. 在 `MessageProto` 的 `oneof content` 中添加新字段
4. 更新数据库模型的转换方法
5. 重新生成 Dart 代码

### 修改现有结构

1. 确保修改不会破坏现有数据
2. 考虑向后兼容性
3. 更新相关的转换方法
4. 测试数据库迁移

这个简化的 proto 结构专注于本地消息处理，提供了高效、简洁的消息定义，完全满足项目的本地搜索和消息管理需求。 