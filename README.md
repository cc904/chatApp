# WhatsApp克隆应用

这是一个使用Flutter实现的WhatsApp克隆应用，主要用于展示聊天应用的实现方式。

## 技术栈

- **Flutter**: UI框架
- **Cubit**: 状态管理
- **Isar**: 本地数据库
- **Socket.IO**: 实时通信
- **Proto Buffers**: 数据序列化

## 主要功能

- 用户认证
- 私聊和群聊
- 多媒体消息（图片、语音、视频等）
- 实时状态更新（在线状态、已读状态等）
- 消息搜索

## Protobuf通信

### 概述

本项目使用Protocol Buffers (protobuf)作为Socket.IO实时通信的数据序列化格式，具有以下优势：

- 更高效的二进制数据传输
- 严格的类型定义
- 更小的网络带宽消耗
- 更快的解析速度

### 实现步骤

1. **定义.proto文件**：
   - 在`protos/`目录中定义各类数据结构
   - 包括message.proto、user.proto和conversation.proto

2. **生成代码**：
   - 使用`protoc`编译器和`protoc_plugin`插件生成Dart代码
   - 执行`scripts/generate_protos.sh`脚本自动生成

3. **实现数据转换**：
   - `ProtoConverter`类：负责Protobuf与JSON/二进制数据的转换
   - `ProtoModelAdapter`类：负责数据库模型与Protobuf模型的转换

4. **Socket通信**：
   - 支持三种数据编码方式：JSON、二进制Protobuf和Base64编码的Protobuf
   - 根据平台选择合适的编码方式（Web平台使用Base64，原生平台使用二进制）

### 使用方式

在初始化Socket连接时指定数据编码方式：

```dart
final socketService = SocketService();
await socketService.init(
  serverUrl: 'ws://example.com',
  authToken: token,
  encoding: DataEncoding.protobuf,
);
```

## 快速开始

1. 确保安装了Flutter SDK和依赖工具
2. 克隆此仓库
3. 运行 `flutter pub get` 安装依赖
4. 运行 `./scripts/generate_protos.sh` 生成Protobuf代码
5. 运行 `flutter run` 启动应用

## 文档

更详细的开发文档位于`docs/`目录。
