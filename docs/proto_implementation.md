# Protocol Buffers 实现文档

## 概述

本项目使用Protocol Buffers (protobuf)作为Socket.io通信的数据序列化格式，以提高通信效率和类型安全性。

## 主要组件

### 1. Protobuf定义文件

位于`protos/`目录中的`.proto`文件定义了通信数据结构：

- `message.proto` - 消息相关数据结构
- `user.proto` - 用户相关数据结构
- `conversation.proto` - 会话相关数据结构
- `auth.proto` - 认证相关数据结构

### 2. 生成的代码

生成的Dart代码位于`lib/core/proto/generated/`目录中，包括：

- `.pb.dart` - 主要的消息类定义
- `.pbenum.dart` - 枚举定义
- `.pbserver.dart` - 服务器相关代码
- `.pbjson.dart` - JSON序列化支持

### 3. ProtoConverter工具类

`lib/core/services/proto_converter.dart`提供了Protobuf与JSON/二进制/Base64之间的转换功能：

```dart
// 将Map转换为MessageProto
MessageProto mapToMessage(Map<String, dynamic> map)

// 将MessageProto转换为Map
Map<String, dynamic> messageToMap(MessageProto message)

// 将MessageProto转换为二进制数据
Uint8List messageToBytes(MessageProto message)

// 将二进制数据转换为MessageProto
MessageProto bytesToMessage(Uint8List bytes)

// 将MessageProto转换为Base64字符串
String messageToBase64(MessageProto message)

// 将Base64字符串转换为MessageProto
MessageProto base64ToMessage(String base64Str)
```

### 4. 通信服务中的应用

`CommunicationService`支持三种编码方式：

- `DataEncoding.json` - 传统JSON格式
- `DataEncoding.protobuf` - Protobuf二进制 (默认)
- `DataEncoding.base64` - Base64编码的Protobuf (兼容性好)

发送事件时，会根据设置的编码方式自动选择合适的序列化方法。

## 使用示例

### 1. 初始化通信服务

```dart
// 使用protobuf编码连接
await communicationService.connect(
  userId: 'user123',
  token: 'auth-token',
  serverUrl: 'https://example.com',
  encoding: DataEncoding.protobuf, // 默认值，可省略
);
```

### 2. 发送消息

```dart
// 构建Protobuf消息
final messageProto = MessageProto()
  ..messageId = 'msg123'
  ..conversationId = 'conv456'
  ..senderId = 'user123'
  ..text = '你好！'
  ..type = MessageType.text;

// 转换为Map
final messageMap = protoConverter.messageToMap(messageProto);

// 发送事件 (底层会根据编码设置自动处理)
communicationService.emitEvent('new_message', messageMap);
```

### 3. 接收消息

```dart
// 监听消息事件
communicationService.onEvent('new_message').listen((data) {
  // data已经被自动解析为Map<String, dynamic>
  final messageProto = protoConverter.mapToMessage(data);
  print('收到消息: ${messageProto.text}');
});
```

## 注意事项

1. 确保服务器端支持相应的Protobuf协议
2. 二进制数据在Web平台可能需要额外处理，建议在Web平台使用Base64编码
3. 协议变更时需要保持向后兼容性 