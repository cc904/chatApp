# API参考文档

本文档提供了CC WhatsApp克隆项目的完整API参考，包括客户端API和通信协议。

## 目录

1. [通信服务 API](#通信服务-api)
2. [会话服务 API](#会话服务-api)
3. [聊天服务 API](#聊天服务-api)
4. [联系人服务 API](#联系人服务-api)
5. [文件上传服务 API](#文件上传服务-api)
6. [Socket.IO 事件](#socketio-事件)
7. [Protobuf 消息类型](#protobuf-消息类型)

## 通信服务 API

`CommunicationService` 类提供了与服务器通信的核心功能。

### 连接管理

```dart
/// 连接到服务器
Future<bool> connect({
  required String serverUrl,
  required String userId,
  required String token,
});

/// 断开连接
Future<void> disconnect();

/// 获取连接状态
bool get isConnected;
bool get isInitialized;

/// 连接状态流
Stream<bool> get connectionStateStream;
```

### 消息传输

```dart
/// 发送Protobuf消息
Future<void> emitProto<T extends GeneratedMessage>(String eventName, T message);

/// 监听特定类型的事件
Stream<T> onProto<T extends GeneratedMessage>(String eventName);

/// 注册自定义事件
void registerCustomEvent<T extends GeneratedMessage>(String eventName, T Function() creator);

/// 发送事件(兼容旧版API)
void emitEvent(String eventName, Map<String, dynamic> data);

/// 监听事件(兼容旧版API)
Stream<Map<String, dynamic>> onEvent(String eventName);
```

## 会话服务 API

`ConversationService` 类处理会话相关操作。

### 会话管理

```dart
/// 初始化服务
Future<void> init();

/// 同步会话
Future<void> syncConversations();

/// 获取会话详情
Future<ConversationProto?> getConversation(String conversationId);

/// 创建新会话
Future<void> createConversation({
  required List<String> participants,
  String? name,
  ConversationType type = ConversationType.private,
});

/// 会话列表流
Stream<List<ConversationProto>> get conversationsStream;

/// 当前会话列表
List<ConversationProto> get conversations;
```

### 数据库操作

```dart
/// 创建私聊会话
static Future<Conversation?> createPrivateConversation(String contactUserId);

/// 创建群聊会话
static Future<Conversation?> createGroupConversation(String name, List<String> participantIds);

/// 获取会话列表
static Future<List<Conversation>> getConversations({int limit = 20, int offset = 0});

/// 更新会话信息
static Future<bool> updateConversation(String conversationId, {String? name, String? avatar});

/// 删除会话
static Future<bool> deleteConversation(String conversationId);
```

## 聊天服务 API

`ChatService` 类处理消息发送和接收。

```dart
/// 初始化服务
Future<void> init();

/// 发送消息
Future<void> sendMessage({
  required String conversationId, 
  required String text, 
  required String senderId
});

/// 标记消息为已读
Future<void> markMessageAsRead(String messageId, String conversationId);

/// 获取会话消息
Future<void> fetchMessages({
  required String conversationId,
  int limit = 20,
  int? beforeTimestamp,
});

/// 消息流
Stream<MessageProto> get messageStream;

/// 会话更新流
Stream<ConversationProto> get conversationStream;
```

## 联系人服务 API

`ContactsService` 类处理联系人相关操作。

```dart
/// 同步联系人
Future<void> syncContacts();

/// 添加联系人
Future<bool> addContact(String userId, {String? displayName});

/// 获取联系人列表
Future<List<User>> getContacts();

/// 搜索联系人
Future<List<User>> searchContacts(String query);

/// 联系人更新流
Stream<List<User>> get contactsStream;
```

## 文件上传服务 API

`FileUploadService` 类处理文件上传。

```dart
/// 上传图片
Future<String?> uploadImage(File file, {
  required String type,
  required String id,
  UploadProgressCallback? onProgress
});

/// 上传语音消息
Future<String?> uploadVoiceMessage(File file, String conversationId);

/// 上传文件
Future<String?> uploadFile(File file, String conversationId);
```

## Socket.IO 事件

以下是应用中使用的主要Socket.IO事件:

| 事件名称 | 方向 | 数据类型 | 描述 |
|---------|------|---------|------|
| `new_message` | 双向 | MessageProto | 发送或接收新消息 |
| `message_delivered` | 双向 | MessageProto | 消息已送达 |
| `message_read` | 双向 | MessageProto | 消息已读 |
| `conversation_update` | 双向 | ConversationProto | 会话更新 |
| `conversation_created` | 双向 | ConversationProto | 会话创建 |
| `conversation_deleted` | 双向 | ConversationProto | 会话删除 |
| `sync_conversations` | 客户端→服务器 | SyncConversationsRequest | 同步会话请求 |
| `sync_conversations_response` | 服务器→客户端 | SyncConversationsResponse | 同步会话响应 |
| `user_online` | 双向 | UserStatusUpdate | 用户上线 |
| `user_offline` | 双向 | UserStatusUpdate | 用户下线 |
| `user_typing` | 双向 | UserTypingUpdate | 用户正在输入 |
| `user_updated` | 服务器→客户端 | UserProto | 用户信息更新 |

## Protobuf 消息类型

应用中使用的主要Protobuf消息类型:

### MessageProto

消息协议，定义在`protos/message.proto`中。

```protobuf
message MessageProto {
  string message_id = 1;        // 消息ID
  string conversation_id = 2;   // 会话ID
  string sender_id = 3;         // 发送者ID
  string text = 10;             // 文本内容
  MessageType type = 9;         // 消息类型
  bool is_read = 7;             // 是否已读
  string status = 8;            // 消息状态
  // ... 其他字段
}
```

### ConversationProto

会话协议，定义在`protos/conversation.proto`中。

```protobuf
message ConversationProto {
  string conversation_id = 1;   // 会话ID
  string name = 2;              // 会话名称
  string avatar = 3;            // 会话头像
  ConversationType type = 4;    // 会话类型
  repeated string participant_ids = 10; // 参与者ID列表
  // ... 其他字段
}
```

### UserProto

用户协议，定义在`protos/user.proto`中。

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

### SyncConversationsRequest/Response

会话同步协议，定义在`protos/conversation_collection.proto`中。

```protobuf
message SyncConversationsRequest {
  string user_id = 1;
  int64 last_sync_time = 2;
  int32 limit = 3;
}

message SyncConversationsResponse {
  bool success = 1;
  string message = 2;
  ConversationCollection data = 3;
}
```

---

有关更详细的协议定义，请参考`protos/`目录下的原始Proto文件或`docs/socket_io_protocol.md`文档。 