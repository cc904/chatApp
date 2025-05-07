# Socket.IO 通信协议文档

本文档记录了CC WhatsApp克隆项目中使用的所有Socket.IO通信协议，包括事件类型、数据格式和Protobuf定义。

## 1. 事件类型

### 1.1 系统事件

| 事件名称 | 方向 | 功能描述 |
|---------|------|---------|
| `connect` | 服务器→客户端 | 连接成功 |
| `disconnect` | 服务器→客户端 | 连接断开 |
| `connecting` | 服务器→客户端 | 正在连接 |
| `connectError` | 服务器→客户端 | 连接错误 |
| `reconnect` | 服务器→客户端 | 重新连接成功 |
| `reconnectAttempt` | 服务器→客户端 | 尝试重新连接 |

### 1.2 业务事件

| 事件名称 | 方向 | 功能描述 |
|---------|------|---------|
| `user_online` | 双向 | 用户上线通知 |
| `user_offline` | 双向 | 用户下线通知 |
| `new_message` | 双向 | 新消息 |
| `message_delivered` | 双向 | 消息已送达 |
| `message_read` | 双向 | 消息已读 |
| `typing` | 双向 | 用户正在输入 |
| `stop_typing` | 双向 | 用户停止输入 |

## 2. 数据编码方式

支持三种数据编码方式：

1. **JSON格式** - 传统JSON数据编码（默认）
2. **Protobuf二进制** - 高效的二进制序列化格式
3. **Base64编码的Protobuf** - 兼容性更好的Protobuf格式

## 3. Protobuf 消息定义

### 3.1 消息协议 (message.proto)

```protobuf
syntax = "proto3";

package cc;

// 消息类型枚举
enum MessageType {
  text = 0;      // 文本消息
  image = 1;     // 图片消息
  voice = 2;     // 语音消息
  file = 3;      // 文件消息
  video = 4;     // 视频消息
  location = 5;  // 位置消息
  system = 6;    // 系统消息
}

// 消息状态枚举
enum MessageStatus {
  sending = 0;    // 发送中
  sent = 1;       // 已发送
  delivered = 2;  // 已送达
  read = 3;       // 已读
  failed = 4;     // 发送失败
}

// 基本消息结构
message MessageProto {
  // 主要字段
  string message_id = 1;        // 消息ID
  string conversation_id = 2;   // 会话ID
  string sender_id = 3;         // 发送者ID
  string sender_name = 4;       // 发送者名称
  string sender_avatar = 5;     // 发送者头像
  int64 created_at = 6;         // 创建时间
  bool is_read = 7;             // 是否已读
  string status = 8;            // 消息状态
  MessageType type = 9;         // 消息类型
  
  // 消息内容
  string text = 10;             // 文本内容
  
  // 媒体消息相关字段
  string media_url = 11;        // 媒体URL
  string local_path = 12;       // 本地路径
  int32 duration = 13;          // 语音/视频时长
  double file_size = 14;        // 文件大小
  string file_name = 15;        // 文件名
  string thumbnail_url = 16;    // 缩略图URL
  
  // 位置消息
  double latitude = 17;         // 纬度
  double longitude = 18;        // 经度
  string location_address = 19; // 地址描述
  
  // 引用消息
  string quoted_message_id = 20; // 引用的消息ID
  
  // 添加不同内容类型的嵌套消息，便于扩展
  oneof content {
    TextMessage text_message = 21;
    MediaMessage media_message = 22;
    LocationMessage location_message = 23;
    SystemMessage system_message = 24;
  }
}

// 文本消息内容
message TextMessage {
  string text = 1;              // 文本内容
}

// 媒体消息内容
message MediaMessage {
  string media_url = 1;         // 媒体URL
  string local_path = 2;        // 本地路径
  int32 duration = 3;           // 时长(毫秒)
  double file_size = 4;         // 文件大小(KB)
  string file_name = 5;         // 文件名
  string thumbnail_url = 6;     // 缩略图URL
  string mime_type = 7;         // MIME类型
}

// 位置消息内容
message LocationMessage {
  double latitude = 1;          // 纬度
  double longitude = 2;         // 经度
  string location_address = 3;  // 地址描述
}

// 系统消息内容
message SystemMessage {
  string text = 1;              // 文本内容 
  string action = 2;            // 操作类型
}

// 消息集合，用于批量操作
message MessageCollection {
  repeated MessageProto messages = 1;
}

// 消息响应结构
message MessageResponse {
  bool success = 1;             // 是否成功
  string message = 2;           // 提示信息
  string message_id = 3;        // 消息ID
  int64 timestamp = 4;          // 时间戳
}
```

### 3.2 用户协议 (user.proto)

```protobuf
syntax = "proto3";

package cc;

// 用户在线状态枚举
enum UserStatus {
  offline = 0;                  // 离线
  online = 1;                   // 在线
  away = 2;                     // 离开
}

// 用户信息
message UserProto {
  // 主要字段
  string user_id = 1;           // 用户ID
  string name = 2;              // 用户名称
  string avatar = 3;            // 用户头像
  string phone = 4;             // 电话号码
  string email = 5;             // 电子邮箱
  string pinyin = 6;            // 拼音索引
  int64 last_active_time = 7;   // 最后活跃时间
  bool is_friend = 8;           // 是否是好友
  string status = 9;            // 在线状态
  
  // 扩展字段
  string username = 10;         // 用户名
  string display_name = 11;     // 显示名称
  bool is_typing = 12;          // 是否正在输入
  string typing_in_conversation = 13; // 正在输入的会话ID
}

// 用户在线状态更新
message UserStatusUpdate {
  string user_id = 1;           // 用户ID
  string status = 2;            // 状态
  int64 timestamp = 3;          // 时间戳
}

// 用户打字状态更新
message UserTypingUpdate {
  string user_id = 1;           // 用户ID
  string conversation_id = 2;   // 会话ID
  bool is_typing = 3;           // 是否正在输入
  int64 timestamp = 4;          // 时间戳
}

// 用户请求响应
message UserResponse {
  bool success = 1;             // 是否成功
  string message = 2;           // 提示信息
  UserProto user = 3;           // 用户信息
}

// 用户列表
message UserCollection {
  repeated UserProto users = 1; // 用户列表
}
```

### 3.3 会话协议 (conversation.proto)

```protobuf
syntax = "proto3";

package cc;

import "message.proto";

// 会话类型枚举
enum ConversationType {
  private = 0;                  // 私聊
  group = 1;                    // 群聊
}

// 会话信息
message ConversationProto {
  // 主要字段
  string conversation_id = 1;   // 会话ID
  string name = 2;              // 会话名称
  string avatar = 3;            // 会话头像
  ConversationType type = 4;    // 会话类型
  int64 created_at = 5;         // 创建时间
  int64 last_message_time = 6;  // 最后消息时间
  string last_message_preview = 7; // 最后消息预览
  int32 unread_count = 8;       // 未读消息数
  string contact_user_id = 9;   // 联系人用户ID
  
  // 参与者ID
  repeated string participant_ids = 10; // 参与者ID列表
  
  // 扩展字段
  int64 updated_at = 11;        // 更新时间
  string last_message_id = 12;  // 最后消息ID
  bool muted = 13;              // 是否静音
  bool pinned = 14;             // 是否置顶
  string created_by = 15;       // 创建者
  MessageProto last_message = 16; // 最后一条消息
}

// 会话更新
message ConversationUpdate {
  string conversation_id = 1;   // 会话ID
  string name = 2;              // 会话名称
  string avatar = 3;            // 会话头像
  repeated string participant_ids = 4; // 参与者ID列表
  int64 updated_at = 5;         // 更新时间
  string updated_by = 6;        // 更新者
  string action = 7;            // 更新动作
}

// 会话请求响应
message ConversationResponse {
  bool success = 1;             // 是否成功
  string message = 2;           // 提示信息
  ConversationProto conversation = 3; // 会话信息
}

// 会话列表
message ConversationCollection {
  repeated ConversationProto conversations = 1; // 会话列表
}
```

## 4. Socket.IO 事件数据格式

### 4.1 用户上线/下线事件

发送：
```javascript
{
  "userId": "user123"
}
```

接收：
```javascript
{
  "userId": "user123",
  "name": "张三",
  "status": "online",
  "timestamp": 1625123456789
}
```

### 4.2 新消息事件

发送：
```javascript
{
  "messageId": "msg123",
  "conversationId": "conv456",
  "senderId": "user123",
  "text": "你好！",
  "type": "text",
  "createdAt": 1625123456789
}
```

接收：
```javascript
{
  "messageId": "msg123",
  "conversationId": "conv456",
  "senderId": "user123",
  "senderName": "张三",
  "senderAvatar": "https://example.com/avatar.jpg",
  "text": "你好！",
  "type": "text",
  "status": "sent",
  "createdAt": 1625123456789
}
```

### 4.3 消息状态事件

发送：
```javascript
{
  "messageId": "msg123",
  "conversationId": "conv456"
}
```

接收：
```javascript
{
  "messageId": "msg123",
  "conversationId": "conv456",
  "status": "read",
  "timestamp": 1625123456789
}
```

### 4.4 用户输入状态事件

发送：
```javascript
{
  "conversationId": "conv456"
}
```

接收：
```javascript
{
  "userId": "user123",
  "conversationId": "conv456",
  "isTyping": true,
  "timestamp": 1625123456789
}
```

## 5. 模拟模式

### 5.1 模拟事件延迟设置

模拟模式下，各事件的默认响应延迟（毫秒）：

| 事件名称 | 默认延迟 |
|---------|---------|
| `new_message` | 300ms |
| `message_delivered` | 500ms |
| `message_read` | 1000ms |
| `user_online` | 200ms |
| `user_offline` | 200ms |
| `typing` | 100ms |
| `stop_typing` | 100ms | 