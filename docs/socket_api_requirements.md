# Socket.io 服务器端API需求文档

## 📋 项目概述

本文档定义了Flutter WhatsApp克隆项目中基于Socket.io的服务器端API需求。

**通信协议**: Socket.io + Protocol Buffers
**后端技术**: Next.js + Socket.io服务器
**数据格式**: Protocol Buffers序列化

## 🎯 核心业务规则

### 消息同步的三种场景

1. **场景1：首次进入聊天**
   - 客户端请求最新30条消息
   - 服务器返回按时间降序排列的消息列表

2. **场景2：有新消息+无未读**
   - 客户端请求某个时间点后的新消息
   - 服务器返回增量消息数据

3. **场景3：有未读消息**
   - 客户端请求未读消息列表
   - 服务器返回所有未读消息

### 统一显示原则
- **无论什么情况都显示到最新消息**
- **最新消息在UI底部第一条显示**

## 🔌 Socket.io 事件定义

### 1. 连接管理事件

#### `connect`
客户端连接到服务器时触发（已在ProtoSocketService中实现）

**服务器响应**:
```javascript
// 确认连接成功
socket.emit('connect_ack', {
  status: 'connected',
  timestamp: Date.now(),
  userId: authenticatedUserId
});
```

#### `disconnect`
客户端断开连接时触发

**服务器处理**:
- 清理用户在线状态
- 离开所有房间
- 记录断开时间

### 2. 用户认证事件（已在ProtoSocketService中实现）

客户端通过JWT Token在连接时认证：
```javascript
// 连接配置中包含认证信息
auth: {'token': token}
```

### 3. 会话管理事件（已在ProtoEvents中定义）

#### `conversation:join`
加入特定会话房间

**客户端发送** (使用Proto):
```dart
// 已在ProtoEvents中定义
'conversation:join': () => conversation.ConversationJoinLeaveRequest()
```

**服务器响应**:
```javascript
socket.emit('conversation:joined', /* ConversationJoinLeaveResponse proto */);
```

#### `conversation:leave`
离开会话房间

**客户端发送** (使用Proto):
```dart
// 已在ProtoEvents中定义
'conversation:leave': () => conversation.ConversationJoinLeaveRequest()
```

### 4. 消息同步事件（核心功能 - 基于现有MessageSyncRequest）

#### `messages:sync` (统一的消息同步事件)
**这是项目已实现的核心事件，支持所有同步场景**

**客户端发送** (使用Proto):
```dart
// 场景1: 初始加载（首次进入）
final request = MessageSyncRequest()
  ..syncType = MessageSyncType.INITIAL_LOAD
  ..conversationId = conversationId
  ..limit = 30;

socket.emitProto('messages:sync', request);
```

```dart
// 场景2: 向前同步（增量同步新消息）
final request = MessageSyncRequest()
  ..syncType = MessageSyncType.CURSOR_FORWARD
  ..conversationId = conversationId
  ..cursorMessageId = lastMessageId
  ..cursorTimestamp = Int64(lastTimestamp.millisecondsSinceEpoch)
  ..limit = 20;

socket.emitProto('messages:sync', request);
```

```dart  
// 场景3: 双向同步（获取上下文消息）
final request = MessageSyncRequest()
  ..syncType = MessageSyncType.CURSOR_AROUND
  ..conversationId = conversationId
  ..cursorMessageId = anchorMessageId
  ..cursorTimestamp = Int64(anchorTimestamp.millisecondsSinceEpoch)
  ..beforeCount = 10
  ..afterCount = 20
  ..includeCursor = false;

socket.emitProto('messages:sync', request);
```

#### `messages:sync:response`
**统一的消息同步响应事件**

**服务器响应** (使用Proto):
```dart
// 已在ProtoEvents中定义
'messages:sync:response': () => message.MessageSyncResponse()
```

**响应内容**:
```dart
MessageSyncResponse {
  bool success = 1;                     // 请求是否成功
  string conversationId = 2;            // 会话ID
  MessageCollection messages = 3;       // 消息集合
  optional string prevCursor = 4;       // 上一页游标
  optional string nextCursor = 5;       // 下一页游标
  bool hasMoreBefore = 6;               // 是否还有更早的消息
  bool hasMoreAfter = 7;                // 是否还有更新的消息
  int32 returnedCount = 8;              // 实际返回的消息数量
  optional int64 oldestTimestamp = 9;   // 最旧消息时间戳
  optional int64 newestTimestamp = 10;  // 最新消息时间戳
}
```

### 5. 实时消息事件

#### `send_message`
发送新消息

**客户端发送**:
```javascript
socket.emit('send_message', {
  conversationId: 'conv_123',
  tempMessageId: 'temp_msg_123', // 客户端临时ID
  message: {
    text: '消息内容',
    type: 'text',
    replyToMessageId: null, // 可选：回复的消息ID
    attachments: [] // 可选：附件列表
  }
});
```

**服务器响应** (给发送者):
```javascript
socket.emit('message_sent', {
  tempMessageId: 'temp_msg_123',
  message: {
    messageId: 'msg_real_123', // 服务器生成的真实ID
    text: '消息内容',
    senderId: 'user123',
    conversationId: 'conv_123',
    createdAt: 1641234567890,
    type: 'text',
    status: 'sent'
  }
});
```

**广播给其他成员**:
```javascript
// 向会话房间内其他用户广播
socket.to('conv_123').emit('new_message', {
  conversationId: 'conv_123',
  message: {
    messageId: 'msg_real_123',
    text: '消息内容',
    senderId: 'user123',
    senderName: '发送者姓名',
    senderAvatar: 'avatar_url',
    createdAt: 1641234567890,
    type: 'text',
    status: 'sent'
  }
});
```

#### `message_read`
标记消息为已读

**客户端发送**:
```javascript
socket.emit('message_read', {
  conversationId: 'conv_123',
  messageIds: ['msg_123', 'msg_124', 'msg_125'], // 批量标记
  userId: 'user123'
});
```

**服务器响应**:
```javascript
socket.emit('read_status_updated', {
  conversationId: 'conv_123',
  readMessageIds: ['msg_123', 'msg_124', 'msg_125'],
  readAt: 1641234567890
});

// 通知发送者消息已被读取
socket.to('sender_socket_id').emit('message_read_by_user', {
  conversationId: 'conv_123',
  messageIds: ['msg_123', 'msg_124', 'msg_125'],
  readBy: {
    userId: 'user123',
    userName: '读取者姓名'
  },
  readAt: 1641234567890
});
```

### 6. 在线状态事件

#### `user_online`
用户上线通知

**服务器广播**:
```javascript
socket.to('user_contacts').emit('user_status_changed', {
  userId: 'user123',
  status: 'online',
  lastSeen: null
});
```

#### `user_offline`
用户下线通知

**服务器广播**:
```javascript
socket.to('user_contacts').emit('user_status_changed', {
  userId: 'user123',
  status: 'offline',
  lastSeen: 1641234567890
});
```

#### `typing_start`
开始输入通知

**客户端发送**:
```javascript
socket.emit('typing_start', {
  conversationId: 'conv_123'
});
```

**服务器广播**:
```javascript
socket.to('conv_123').emit('user_typing', {
  conversationId: 'conv_123',
  userId: 'user123',
  userName: '用户名',
  isTyping: true
});
```

#### `typing_stop`
停止输入通知

**客户端发送**:
```javascript
socket.emit('typing_stop', {
  conversationId: 'conv_123'
});
```

**服务器广播**:
```javascript
socket.to('conv_123').emit('user_typing', {
  conversationId: 'conv_123',
  userId: 'user123',
  isTyping: false
});
```

## 🗄️ 数据库设计

### 消息表 (messages)
```sql
CREATE TABLE messages (
  id VARCHAR(36) PRIMARY KEY,
  conversation_id VARCHAR(36) NOT NULL,
  sender_id VARCHAR(36) NOT NULL,
  text TEXT,
  type VARCHAR(20) NOT NULL DEFAULT 'text',
  reply_to_message_id VARCHAR(36),
  created_at BIGINT NOT NULL,
  updated_at BIGINT,
  status VARCHAR(20) DEFAULT 'sent',
  attachments JSON,
  
  INDEX idx_conversation_time (conversation_id, created_at DESC),
  INDEX idx_sender_time (sender_id, created_at DESC),
  FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  FOREIGN KEY (sender_id) REFERENCES users(id)
);
```

### 未读状态表 (message_read_status)
```sql
CREATE TABLE message_read_status (
  id VARCHAR(36) PRIMARY KEY,
  message_id VARCHAR(36) NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  conversation_id VARCHAR(36) NOT NULL,
  read_at BIGINT,
  created_at BIGINT NOT NULL,
  
  UNIQUE KEY unique_user_message (user_id, message_id),
  INDEX idx_user_conversation (user_id, conversation_id, read_at),
  INDEX idx_conversation_unread (conversation_id, read_at),
  FOREIGN KEY (message_id) REFERENCES messages(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);
```

### 会话表 (conversations)
```sql
CREATE TABLE conversations (
  id VARCHAR(36) PRIMARY KEY,
  type VARCHAR(20) NOT NULL DEFAULT 'private',
  name VARCHAR(255),
  avatar VARCHAR(500),
  created_at BIGINT NOT NULL,
  updated_at BIGINT,
  last_message_id VARCHAR(36),
  last_message_at BIGINT,
  
  INDEX idx_updated (updated_at DESC),
  FOREIGN KEY (last_message_id) REFERENCES messages(id)
);
```

### 会话成员表 (conversation_members)
```sql
CREATE TABLE conversation_members (
  id VARCHAR(36) PRIMARY KEY,
  conversation_id VARCHAR(36) NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  role VARCHAR(20) DEFAULT 'member',
  joined_at BIGINT NOT NULL,
  left_at BIGINT,
  
  UNIQUE KEY unique_conversation_user (conversation_id, user_id),
  INDEX idx_user_conversations (user_id, left_at),
  FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 🚀 服务器端实现要点

### 1. Socket.io服务器配置

```javascript
// socket-server.js
const io = require('socket.io')(server, {
  cors: {
    origin: process.env.CLIENT_ORIGIN || "http://localhost:3000",
    methods: ["GET", "POST"]
  },
  transports: ['websocket', 'polling']
});

// JWT认证中间件
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.userId;
    socket.userInfo = await getUserInfo(decoded.userId);
    next();
  } catch (err) {
    next(new Error('Authentication error'));
  }
});
```

### 2. 房间管理

```javascript
// 加入会话房间
socket.on('join_conversation', async ({ conversationId }) => {
  try {
    // 验证用户是否有权限加入该会话
    const hasAccess = await checkConversationAccess(socket.userId, conversationId);
    if (!hasAccess) {
      socket.emit('join_error', { 
        conversationId, 
        error: 'Access denied', 
        code: 403 
      });
      return;
    }

    // 加入房间
    socket.join(conversationId);
    
    // 记录用户在线状态
    await updateUserOnlineStatus(socket.userId, conversationId, true);
    
    socket.emit('conversation_joined', {
      conversationId,
      memberCount: io.sockets.adapter.rooms.get(conversationId)?.size || 0,
      status: 'joined'
    });
  } catch (error) {
    socket.emit('join_error', { 
      conversationId, 
      error: error.message, 
      code: 500 
    });
  }
});
```

### 3. 消息同步实现

#### 场景1: 最新消息
```javascript
socket.on('request_latest_messages', async ({ conversationId, limit = 30, userId }) => {
  try {
    const messages = await getLatestMessages(conversationId, limit);
    const totalCount = await getMessageCount(conversationId);
    
    socket.emit('latest_messages_response', {
      conversationId,
      messages: messages.map(msg => messageToProto(msg)),
      totalCount,
      hasMore: messages.length === limit,
      requestId: generateRequestId()
    });
  } catch (error) {
    socket.emit('sync_error', { 
      type: 'latest_messages',
      error: error.message 
    });
  }
});
```

#### 场景2: 增量同步
```javascript
socket.on('request_messages_after', async ({ conversationId, afterTimestamp, userId }) => {
  try {
    const newMessages = await getMessagesAfter(conversationId, afterTimestamp);
    
    socket.emit('messages_after_response', {
      conversationId,
      messages: newMessages.map(msg => messageToProto(msg)),
      newCount: newMessages.length,
      latestTimestamp: newMessages.length > 0 ? newMessages[0].createdAt : afterTimestamp,
      requestId: generateRequestId()
    });
  } catch (error) {
    socket.emit('sync_error', { 
      type: 'messages_after',
      error: error.message 
    });
  }
});
```

#### 场景3: 未读消息
```javascript
socket.on('request_unread_messages', async ({ conversationId, userId }) => {
  try {
    const unreadMessages = await getUnreadMessages(conversationId, userId);
    
    socket.emit('unread_messages_response', {
      conversationId,
      unreadMessages: unreadMessages.map(msg => messageToProto(msg)),
      unreadCount: unreadMessages.length,
      firstUnreadTimestamp: unreadMessages.length > 0 ? unreadMessages[0].createdAt : null,
      lastUnreadTimestamp: unreadMessages.length > 0 ? unreadMessages[unreadMessages.length - 1].createdAt : null,
      requestId: generateRequestId()
    });
  } catch (error) {
    socket.emit('sync_error', { 
      type: 'unread_messages',
      error: error.message 
    });
  }
});
```

### 4. 实时消息处理

```javascript
socket.on('send_message', async ({ conversationId, tempMessageId, message }) => {
  try {
    // 保存消息到数据库
    const savedMessage = await saveMessage({
      conversationId,
      senderId: socket.userId,
      text: message.text,
      type: message.type,
      replyToMessageId: message.replyToMessageId,
      attachments: message.attachments
    });

    // 响应发送者
    socket.emit('message_sent', {
      tempMessageId,
      message: messageToProto(savedMessage)
    });

    // 广播给其他成员
    socket.to(conversationId).emit('new_message', {
      conversationId,
      message: {
        ...messageToProto(savedMessage),
        senderName: socket.userInfo.name,
        senderAvatar: socket.userInfo.avatar
      }
    });

    // 更新会话最后消息
    await updateConversationLastMessage(conversationId, savedMessage);

  } catch (error) {
    socket.emit('send_error', { 
      tempMessageId,
      error: error.message 
    });
  }
});
```

### 5. 已读状态管理

```javascript
socket.on('message_read', async ({ conversationId, messageIds, userId }) => {
  try {
    const readAt = Date.now();
    
    // 批量更新已读状态
    await markMessagesAsRead(messageIds, userId, readAt);
    
    // 确认更新
    socket.emit('read_status_updated', {
      conversationId,
      readMessageIds: messageIds,
      readAt
    });

    // 通知消息发送者
    const messageDetails = await getMessageDetails(messageIds);
    for (const msg of messageDetails) {
      const senderSocketId = await getUserSocketId(msg.senderId);
      if (senderSocketId) {
        io.to(senderSocketId).emit('message_read_by_user', {
          conversationId,
          messageIds: [msg.id],
          readBy: {
            userId: socket.userId,
            userName: socket.userInfo.name
          },
          readAt
        });
      }
    }
    
  } catch (error) {
    socket.emit('read_error', { 
      error: error.message 
    });
  }
});
```

## 📊 性能优化

### 1. Redis缓存策略
```javascript
// 缓存最新消息
const CACHE_KEY_LATEST = `latest_messages:${conversationId}`;
await redis.setex(CACHE_KEY_LATEST, 300, JSON.stringify(messages)); // 5分钟缓存

// 缓存未读计数
const CACHE_KEY_UNREAD = `unread_count:${userId}:${conversationId}`;
await redis.setex(CACHE_KEY_UNREAD, 60, unreadCount.toString()); // 1分钟缓存
```

### 2. 数据库索引优化
```sql
-- 复合索引：会话+时间（支持分页查询）
CREATE INDEX idx_conversation_time ON messages (conversation_id, created_at DESC);

-- 未读消息查询索引
CREATE INDEX idx_unread_messages ON message_read_status (user_id, conversation_id, read_at);
```

### 3. 连接池管理
```javascript
// Socket.io连接池配置
const io = require('socket.io')(server, {
  maxHttpBufferSize: 1e6, // 1MB
  pingTimeout: 60000, // 60秒
  pingInterval: 25000, // 25秒
  transports: ['websocket']
});
```

## 🔒 安全要求

### 1. 认证与授权
- JWT Token验证
- 会话访问权限检查
- 消息发送权限验证

### 2. 数据验证
- 输入内容过滤和验证
- 消息长度限制
- 文件类型和大小检查

### 3. 防护措施
- 频率限制 (Rate Limiting)
- SQL注入防护
- XSS攻击防护

## 🧪 测试建议

### 1. 单元测试
- Socket事件处理函数
- 数据库查询方法
- 消息序列化/反序列化

### 2. 集成测试  
- Socket.io客户端连接测试
- 消息同步流程测试
- 实时通信测试

### 3. 性能测试
- 并发连接测试
- 消息吞吐量测试
- 内存使用监控

## 📞 部署配置

### 1. 环境变量
```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_NAME=whatsapp_clone
DB_USER=root
DB_PASSWORD=password

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT配置
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# Socket.io配置
SOCKET_PORT=3001
CLIENT_ORIGIN=http://localhost:3000
```

### 2. Docker配置
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3001
CMD ["npm", "start"]
```

---

## ✅ 总结

✅ **完整的Socket.io事件定义**
✅ **三种消息同步场景的实现方案**  
✅ **实时通信功能支持**
✅ **数据库设计和性能优化**
✅ **安全和测试指南**

**所有通信都通过Socket.io进行，提供实时、高效的消息同步体验** 🚀 