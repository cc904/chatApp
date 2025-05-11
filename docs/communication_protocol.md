# 通信协议文档

本文档整合了CC WhatsApp克隆项目的通信协议，包括Socket.IO通信和Protobuf数据格式。

## 目录

1. [架构概述](#架构概述)
2. [通信流程](#通信流程)
3. [Socket.IO 事件](#socketio-事件)
4. [Protobuf 消息结构](#protobuf-消息结构) 
5. [认证流程](#认证流程)
6. [典型场景](#典型场景)

## 架构概述

### 通信层次

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│                 │      │                  │      │                 │
│  Flutter 客户端  ├─────►│  Socket.IO 通道   ├─────►│   Next.js 服务端  │
│                 │      │                  │      │                 │
└─────────────────┘      └──────────────────┘      └─────────────────┘
        │                        │                         │
        │                        │                         │
        ▼                        ▼                         ▼
   Protobuf 编码           WebSocket/HTTP            Protobuf 解码
   JSON 兼容层              长连接通信               数据库操作
```

### 核心组件

- **CommunicationService**: 基于ProtoSocketService的类型安全通信服务
- **ProtoSocketService**: 底层Socket.IO连接和消息传递
- **ProtoEvents**: 注册和管理Protobuf消息类型与事件的映射

## 通信流程

### 基本通信流程

1. **初始化连接**:
   - 应用启动时，通过`CommunicationService.connect()`建立连接
   - 连接请求包含用户ID和认证令牌

2. **消息传输**:
   - 使用`emitProto<T>()`发送类型安全的消息
   - 使用`onProto<T>()`接收特定类型的消息

3. **连接状态管理**:
   - 监听`connectionStateStream`获取连接状态变化
   - 自动重连机制处理网络波动

### 序列化流程

```
发送消息:
Dart对象 ► Protobuf对象 ► 二进制数据 ► Socket.IO ► 服务器

接收消息:
服务器 ► Socket.IO ► 二进制数据 ► Protobuf对象 ► Dart对象
```

## Socket.IO 事件

### 系统事件

| 事件名称 | 描述 |
|---------|------|
| `connect` | 连接成功 |
| `disconnect` | 连接断开 |
| `connect_error` | 连接错误 |
| `reconnect` | 重新连接成功 |

### 用户状态事件

| 事件名称 | 方向 | 数据类型 | 描述 |
|---------|------|---------|------|
| `user_online` | 双向 | UserStatusUpdate | 用户上线 |
| `user_offline` | 双向 | UserStatusUpdate | 用户下线 |
| `user_typing` | 双向 | UserTypingUpdate | 用户正在输入 |
| `user_updated` | 服务器→客户端 | UserProto | 用户信息更新 |

### 消息事件

| 事件名称 | 方向 | 数据类型 | 描述 |
|---------|------|---------|------|
| `new_message` | 双向 | MessageProto | 发送或接收新消息 |
| `message_delivered` | 双向 | MessageProto | 消息已送达 |
| `message_read` | 双向 | MessageProto | 消息已读 |

### 会话事件

| 事件名称 | 方向 | 数据类型 | 描述 |
|---------|------|---------|------|
| `conversation_update` | 双向 | ConversationProto | 会话更新 |
| `conversation_created` | 双向 | ConversationProto | 会话创建 |
| `conversation_deleted` | 双向 | ConversationProto | 会话删除 |
| `sync_conversations` | 客户端→服务器 | SyncConversationsRequest | 同步会话请求 |
| `sync_conversations_response` | 服务器→客户端 | SyncConversationsResponse | 同步会话响应 |

## Protobuf 消息结构

### 主要消息类型

| 消息类型 | 文件路径 | 主要用途 |
|---------|---------|---------|
| MessageProto | protos/message.proto | 聊天消息 |
| ConversationProto | protos/conversation.proto | 会话信息 |
| UserProto | protos/user.proto | 用户信息 |
| SyncConversationsRequest | protos/conversation_collection.proto | 同步会话请求 |
| SyncConversationsResponse | protos/conversation_collection.proto | 同步会话响应 |

### 核心消息定义

#### MessageProto

```protobuf
message MessageProto {
  string message_id = 1;        // 消息ID
  string conversation_id = 2;   // 会话ID
  string sender_id = 3;         // 发送者ID
  string sender_name = 4;       // 发送者名称
  string sender_avatar = 5;     // 发送者头像
  int64 created_at = 6;         // 创建时间
  bool is_read = 7;             // 是否已读
  string status = 8;            // 消息状态
  MessageType type = 9;         // 消息类型
  string text = 10;             // 文本内容
  // ... 其他字段
}
```

#### ConversationProto

```protobuf
message ConversationProto {
  string conversation_id = 1;   // 会话ID
  string name = 2;              // 会话名称
  string avatar = 3;            // 会话头像
  ConversationType type = 4;    // 会话类型
  int64 created_at = 5;         // 创建时间
  int64 last_message_time = 6;  // 最后消息时间
  // ... 其他字段
  repeated string participant_ids = 10; // 参与者ID列表
}
```

#### UserProto

```protobuf
message UserProto {
  string user_id = 1;           // 用户ID
  string name = 2;              // 用户名称
  string avatar = 3;            // 用户头像
  string phone = 4;             // 电话号码
  string email = 5;             // 电子邮箱
  // ... 其他字段
}
```

## 认证流程

1. **初始连接认证**:
   - 通过connect()方法传递userId和token
   - 服务器验证令牌有效性
   - 认证失败则断开连接

2. **会话保持**:
   - 保持长连接，自动处理心跳
   - 重连时自动重新验证身份

3. **安全措施**:
   - 所有敏感操作都需要验证令牌
   - 使用HTTPS加密传输层

## 典型场景

### 发送新消息

1. 客户端创建MessageProto对象
2. 使用emitProto('new_message', message)发送
3. 服务器处理并广播给接收方
4. 接收方通过onProto<MessageProto>('new_message')监听

```dart
// 客户端代码示例
final message = MessageProto(
  messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
  conversationId: conversationId,
  senderId: currentUserId,
  text: messageText,
  createdAt: Int64(DateTime.now().millisecondsSinceEpoch),
);

await communicationService.emitProto('new_message', message);
```

### 同步会话

1. 客户端发送SyncConversationsRequest
2. 服务器查询最新会话数据
3. 服务器返回SyncConversationsResponse
4. 客户端更新本地会话列表

```dart
// 客户端代码示例
final request = SyncConversationsRequest()
  ..userId = currentUserId
  ..lastSyncTime = Int64(lastSyncTimestamp)
  ..limit = 50;

await communicationService.emitProto('sync_conversations', request);

// 监听响应
communicationService.onProto<SyncConversationsResponse>('sync_conversations_response')
  .listen((response) {
    if (response.success && response.data != null) {
      // 更新本地会话列表
    }
  });
```

---

详细的API文档请参阅[API参考文档](api_reference.md)。完整的Protobuf定义请查看`protos/`目录下的原始文件。 