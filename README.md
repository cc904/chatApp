# WhatsApp克隆应用

这是一个使用Flutter实现的WhatsApp克隆应用，主要用于展示聊天应用的实现方式。

## 技术栈

- **Flutter**: UI框架
- **Cubit**: 状态管理
- **Isar**: 本地数据库
- **Socket.IO**: 实时通信
- **Protocol Buffers**: 数据序列化

## 主要功能

- 用户认证
- 私聊和群聊
- 多媒体消息（图片、语音、视频等）
- 实时状态更新（在线状态、已读状态等）
- 消息搜索

## Protobuf通信

### 概述

本项目使用Protocol Buffers (protobuf)作为Socket.IO实时通信的唯一数据序列化格式，具有以下优势：

- 更高效的二进制数据传输
- 严格的类型定义
- 更小的网络带宽消耗
- 更快的解析速度
- 简化的代码结构和通信逻辑

### 实现步骤

1. **定义.proto文件**：
   - 在`protos/`目录中定义各类数据结构
   - 包括message.proto、user.proto和conversation.proto

2. **生成代码**：
   - 使用`protoc`编译器和`protoc_plugin`插件生成Dart代码
   - 执行`scripts/generate_protos.sh`脚本自动生成

3. **实现数据转换**：
   - `ProtoConverter`类：负责Protobuf与应用数据模型的转换
   - 统一使用二进制格式进行传输，不再支持JSON或Base64编码

4. **Socket通信**：
   - 统一使用二进制Protobuf作为唯一的数据序列化格式
   - `CommunicationService`封装了所有Socket.IO通信细节

### 使用方式

使用`CommunicationService`进行实时通信：

```dart
final communicationService = CommunicationService();
await communicationService.connect(
  userId: userId,
  token: token,
  serverUrl: 'ws://example.com',
);

// 发送消息
communicationService.emitEvent('message:new', {
  'id': messageId,
  'senderId': senderId,
  'conversationId': conversationId,
  'content': messageText,
  'timestamp': DateTime.now().millisecondsSinceEpoch,
});

// 监听消息
communicationService.onEvent('message:new').listen((data) {
  // 处理接收到的消息
});
```

更多详细信息请参考 [Protobuf通信实现文档](docs/protobuf_communication.md)。

## 快速开始

1. 确保安装了Flutter SDK和依赖工具
2. 克隆此仓库
3. 运行 `flutter pub get` 安装依赖
4. 运行 `./scripts/generate_protos.sh` 生成Protobuf代码
5. 运行 `flutter run` 启动应用

## 文档

更详细的开发文档位于`docs/`目录。
