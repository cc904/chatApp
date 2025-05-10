# WhatsApp克隆应用后端需求文档

本文档详细描述了WhatsApp克隆Flutter应用所需的NextJS后端服务规范，包括API接口、Socket.io通信协议、数据模型及认证流程等。后端开发人员可参考本文档实现与Flutter客户端兼容的服务。

## 目录
1. [技术栈要求](#技术栈要求)
2. [认证API](#认证API)
3. [Socket.io通信](#Socket-io通信)
4. [Protocol Buffers数据序列化](#Protocol-Buffers数据序列化)
5. [数据模型](#数据模型)
6. [用户系统](#用户系统)
7. [聊天功能](#聊天功能)
8. [媒体文件处理](#媒体文件处理)
9. [好友关系管理](#好友关系管理)
10. [安全性考虑](#安全性考虑)
11. [部署建议](#部署建议)

## 技术栈要求

后端服务需使用以下技术栈：

| 组件 | 技术选择 | 说明 |
|-----|---------|-----|
| 框架 | Next.js | 用于构建API和服务端渲染 |
| 实时通信 | Socket.io | 与Flutter客户端通信的Socket服务 |
| 数据序列化 | Protocol Buffers | 高效的二进制数据序列化格式 |
| 数据库 | MongoDB | 存储用户、消息和会话数据 |
| 认证 | JWT | 用于用户认证和授权 |
| 媒体存储 | 云存储服务(如AWS S3) | 存储用户上传的媒体文件 |

## 认证API

Flutter客户端使用REST API进行用户认证，接口规范如下：

### 1. 发送验证码

**端点:** `/api/auth/send-code`  
**方法:** POST  
**内容类型:** application/json

**请求参数:**
```json
{
  "phoneNumber": "13800138000",
  "purpose": "login" // 可选值: login, register, reset
}
```

**响应:**
```json
{
  "success": true,
  "message": "验证码已发送"
}
```

### 2. 验证码登录

**端点:** `/api/auth/login`  
**方法:** POST  
**内容类型:** application/json

**请求参数:**
```json
{
  "phoneNumber": "13800138000",
  "verificationCode": "123456",
  "loginType": "code"
}
```

**响应:**
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "userId": "user_12345",
    "token": "jwt_token_string",
    "nickname": "用户昵称"
  }
}
```

### 3. 密码登录

**端点:** `/api/auth/login`  
**方法:** POST  
**内容类型:** application/json

**请求参数:**
```json
{
  "phoneNumber": "13800138000",
  "password": "用户密码",
  "loginType": "password"
}
```

**响应:** 与验证码登录相同

### 4. 用户注册

**端点:** `/api/auth/register`  
**方法:** POST  
**内容类型:** application/json

**请求参数:**
```json
{
  "phoneNumber": "13800138000",
  "verificationCode": "123456",
  "password": "用户密码",
  "nickname": "用户昵称"
}
```

**响应:**
```json
{
  "success": true,
  "message": "注册成功",
  "data": {
    "userId": "user_12345",
    "token": "jwt_token_string",
    "nickname": "用户昵称"
  }
}
```

### 5. 重置密码

**端点:** `/api/auth/reset-password`  
**方法:** POST  
**内容类型:** application/json

**请求参数:**
```json
{
  "phoneNumber": "13800138000",
  "verificationCode": "123456",
  "newPassword": "新密码"
}
```

**响应:**
```json
{
  "success": true,
  "message": "密码重置成功"
}
```

### 模拟登录支持

对于开发和测试环境，后端应支持以下模拟账号登录：
- 手机号: `13800138000`
- 验证码: `123456`

## Socket.io通信

Flutter客户端使用Socket.io进行实时通信，通信规范如下：

### 连接认证

Socket.io连接需要进行认证，Flutter客户端会在连接时提供认证信息：

```javascript
// Flutter客户端连接时会提供以下认证信息
const socket = io(serverUrl, {
  auth: {
    userId: "user_12345",
    token: "jwt_token_string"
  }
});
```

后端需验证token的有效性，对无效token应拒绝连接。

### 数据序列化

Flutter客户端使用Protocol Buffers（protobuf）进行数据序列化，而不是普通的JSON格式。后端需要处理以下格式的数据：

1. **接收数据**：从Flutter客户端接收的是protobuf编码的二进制数据
2. **发送数据**：向Flutter客户端发送的也应是protobuf编码的二进制数据

这要求后端实现相应的protobuf消息编码与解码功能。

### 事件列表

Socket.io服务器需要处理以下事件：

| 事件名称 | 方向 | 数据格式 | 说明 |
|---------|------|---------|-----|
| `user_online` | 客户端→服务器 | Protobuf二进制 | 用户上线通知 |
| `user_offline` | 客户端→服务器 | Protobuf二进制 | 用户下线通知 |
| `new_message` | 客户端→服务器 | Protobuf二进制 | 发送新消息 |
| `message_delivered` | 服务器→客户端 | Protobuf二进制 | 消息已送达 |
| `message_read` | 服务器→客户端 | Protobuf二进制 | 消息已读 |
| `typing` | 客户端→服务器 | Protobuf二进制 | 用户正在输入 |
| `stop_typing` | 客户端→服务器 | Protobuf二进制 | 用户停止输入 |
| `contacts_synced` | 服务器→客户端 | Protobuf二进制 | 联系人同步完成 |
| `system_message` | 服务器→客户端 | Protobuf二进制 | 系统消息 |

## Protocol Buffers数据序列化

项目使用Protocol Buffers (protobuf)作为二进制数据序列化格式，以提升性能和减小数据包大小。

### 为什么使用Protocol Buffers

- **高效性**：比JSON更小的数据体积，更快的序列化/反序列化速度
- **类型安全**：强类型定义，减少运行时错误
- **向前兼容**：协议演化时保持向后兼容性
- **跨平台**：支持多种语言，便于前后端集成

### Protobuf消息定义

后端需要实现与Flutter客户端相同的消息定义。以下是核心消息类型示例：

#### 消息(Message)定义

```protobuf
syntax = "proto3";

message MessageProto {
  string message_id = 1;
  string conversation_id = 2;
  string sender_id = 3;
  string content = 4;
  string type = 5;  // text, image, voice, file
  int64 timestamp = 6;
  MessageStatus status = 7;
  MessageMetadata metadata = 8;
  
  enum MessageStatus {
    SENT = 0;
    DELIVERED = 1;
    READ = 2;
  }
  
  message MessageMetadata {
    string file_name = 1;
    int64 file_size = 2;
    string mime_type = 3;
    int32 duration = 4;  // 语音消息时长(秒)
    int32 width = 5;     // 图片宽度
    int32 height = 6;    // 图片高度
    string thumbnail_url = 7;  // 缩略图URL
  }
}
```

#### 会话(Conversation)定义

```protobuf
syntax = "proto3";

message ConversationProto {
  string conversation_id = 1;
  string type = 2;  // private, group
  string name = 3;  // 群聊名称
  string avatar = 4;  // 群聊头像
  repeated string participants = 5;  // 参与者userId列表
  string last_message_id = 6;
  int64 last_message_time = 7;
}
```

#### 用户状态定义

```protobuf
syntax = "proto3";

message UserStatusProto {
  string user_id = 1;
  bool is_online = 2;
  int64 last_active = 3;
  string status_message = 4;
}
```

### 序列化实现

后端需要使用相应语言的protobuf库实现消息的编码和解码：

```javascript
// Node.js中的protobuf示例
const protobuf = require('protobufjs');
const root = protobuf.loadSync("message.proto");
const MessageProto = root.lookupType("MessageProto");

// 编码消息
function encodeMessage(message) {
  const errMsg = MessageProto.verify(message);
  if (errMsg) throw Error(errMsg);
  
  const messageObj = MessageProto.create(message);
  return MessageProto.encode(messageObj).finish();
}

// 解码消息
function decodeMessage(binary) {
  const decoded = MessageProto.decode(binary);
  return MessageProto.toObject(decoded);
}
```

## 数据模型

后端需要维护以下核心数据模型：

### 用户(User)
```javascript
{
  _id: ObjectId,
  userId: String, // 客户端使用的用户ID
  phoneNumber: String,
  password: String, // 加密存储
  nickname: String,
  avatar: String, // 头像URL
  status: String, // 用户状态
  createdAt: Date,
  updatedAt: Date,
  lastActive: Date, // 最后活跃时间
  contacts: [{ 
    userId: String,
    nickname: String,
    relationship: String // friend, blocked, etc.
  }]
}
```

### 会话(Conversation)
```javascript
{
  _id: ObjectId,
  conversationId: String, // 客户端使用的会话ID
  type: String, // private, group
  name: String, // 群聊名称(私聊为null)
  avatar: String, // 群聊头像(私聊为null)
  participants: [String], // 参与者userId列表
  createdAt: Date,
  updatedAt: Date,
  lastMessageId: String, // 最后一条消息ID
  lastMessageTime: Date // 最后一条消息时间
}
```

### 消息(Message)
```javascript
{
  _id: ObjectId,
  messageId: String, // 客户端使用的消息ID
  conversationId: String,
  senderId: String,
  content: String,
  type: String, // text, image, voice, file
  status: String, // sent, delivered, read
  timestamp: Date,
  metadata: Object, // 根据类型存储不同元数据
  isDeleted: Boolean, // 是否已删除
  deletedFor: [String] // 对哪些用户删除
}
```

### 好友请求(FriendRequest)
```javascript
{
  _id: ObjectId,
  senderId: String,
  receiverId: String,
  status: String, // pending, accepted, rejected
  message: String, // 请求消息
  createdAt: Date,
  updatedAt: Date
}
```

## 用户系统

### 联系人同步

当用户登录后，后端应提供联系人同步API：

**端点:** `/api/contacts/sync`  
**方法:** GET  
**认证:** Bearer Token

**响应:**
```json
{
  "success": true,
  "contacts": [
    {
      "userId": "user_12345",
      "nickname": "联系人1",
      "avatar": "avatar_url",
      "phoneNumber": "13800138001",
      "status": "Hey there! I am using WhatsApp"
    },
    // 更多联系人...
  ]
}
```

### 联系人搜索

**端点:** `/api/contacts/search`  
**方法:** GET  
**认证:** Bearer Token  
**参数:** `q` (查询关键字)

**响应:**
```json
{
  "success": true,
  "results": [
    {
      "userId": "user_12345",
      "nickname": "搜索结果1",
      "avatar": "avatar_url",
      "phoneNumber": "13800138001",
      "status": "用户状态"
    },
    // 更多结果...
  ]
}
```

## 聊天功能

### 获取会话列表

**端点:** `/api/conversations`  
**方法:** GET  
**认证:** Bearer Token

**响应:**
```json
{
  "success": true,
  "conversations": [
    {
      "conversationId": "conv_12345",
      "type": "private",
      "participants": [
        {
          "userId": "user_12345",
          "nickname": "用户1",
          "avatar": "avatar_url"
        },
        {
          "userId": "user_67890",
          "nickname": "用户2",
          "avatar": "avatar_url"
        }
      ],
      "lastMessage": {
        "messageId": "msg_12345",
        "content": "最后一条消息",
        "type": "text",
        "senderId": "user_12345",
        "timestamp": 1625097600000,
        "status": "read"
      },
      "unreadCount": 0
    },
    // 更多会话...
  ]
}
```

### 获取会话消息

**端点:** `/api/conversations/{conversationId}/messages`  
**方法:** GET  
**认证:** Bearer Token  
**参数:** `limit`, `before` (消息ID，用于分页)

**响应:**
```json
{
  "success": true,
  "messages": [
    {
      "messageId": "msg_12345",
      "conversationId": "conv_12345",
      "senderId": "user_12345",
      "content": "消息内容",
      "type": "text",
      "timestamp": 1625097600000,
      "status": "read"
    },
    // 更多消息...
  ],
  "hasMore": true
}
```

## 媒体文件处理

### 上传媒体文件

**端点:** `/api/media/upload`  
**方法:** POST  
**认证:** Bearer Token  
**内容类型:** multipart/form-data

**请求参数:**
- `file`: 文件数据
- `type`: 文件类型 (image, voice, file)
- `conversationId`: 会话ID

**响应:**
```json
{
  "success": true,
  "fileUrl": "https://example.com/files/image.jpg",
  "thumbnailUrl": "https://example.com/files/thumb.jpg", // 对图片有效
  "metadata": {
    "fileName": "image.jpg",
    "fileSize": 1024000,
    "mimeType": "image/jpeg",
    "width": 800, // 对图片有效
    "height": 600, // 对图片有效
    "duration": 30 // 对语音有效
  }
}
```

## 好友关系管理

### 发送好友请求

**端点:** `/api/friends/request`  
**方法:** POST  
**认证:** Bearer Token  
**内容类型:** application/json

**请求参数:**
```json
{
  "receiverId": "user_67890",
  "message": "请求添加您为好友"
}
```

**响应:**
```json
{
  "success": true,
  "message": "好友请求已发送",
  "requestId": "request_12345"
}
```

### 处理好友请求

**端点:** `/api/friends/request/{requestId}`  
**方法:** PUT  
**认证:** Bearer Token  
**内容类型:** application/json

**请求参数:**
```json
{
  "action": "accept" // 可选值: accept, reject
}
```

**响应:**
```json
{
  "success": true,
  "message": "已添加好友"
}
```

## 安全性考虑

1. **认证安全**
   - 使用JWT并设置适当的过期时间
   - 实现令牌刷新机制
   - 保存密码时使用bcrypt等安全哈希算法

2. **Socket连接安全**
   - 验证每个Socket.io连接的认证信息
   - 定期验证连接的有效性
   - 对异常连接行为进行限流

3. **数据验证**
   - 对所有API输入进行严格验证
   - 实现请求频率限制
   - 设置最大请求体积限制

4. **媒体文件安全**
   - 验证上传文件的MIME类型
   - 限制文件大小(建议图片10MB，语音2MB，文件50MB)
   - 扫描上传文件(选配)

## 部署建议

1. **基础架构**
   - 使用容器化部署(Docker + Kubernetes)
   - 设置自动扩展以应对负载变化
   - 使用CDN加速媒体文件分发

2. **数据库配置**
   - MongoDB集群确保高可用性
   - 配置适当的索引提升查询性能
   - 实现定期备份策略

3. **监控与日志**
   - 实现请求日志记录
   - 配置性能监控
   - 设置错误警报机制

4. **测试环境**
   - 支持模拟数据生成
   - 配置单独的测试数据库
   - 启用模拟账号登录(13800138000/123456)

## 结语

本文档提供了实现WhatsApp克隆应用后端服务的技术规范。后端开发人员应严格遵循此规范，确保与Flutter客户端的兼容性。对于规范中未明确的细节，可参考Flutter客户端代码或联系前端开发团队进行澄清。 