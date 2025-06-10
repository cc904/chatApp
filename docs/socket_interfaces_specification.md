# Socket.io 接口详细规范

## 📋 概述

基于现有Flutter WhatsApp项目架构，详细定义所有Socket.io接口的参数、返回值和业务逻辑。

**技术栈**: Socket.io + Protocol Buffers + Next.js
**客户端架构**: ProtoSocketService + CommunicationService + ProtoEvents

## 🔌 核心接口规范

### 1. 消息同步接口

#### `messages:sync` - 统一消息同步接口

**描述**: 核心同步接口，支持所有消息获取场景

**客户端请求参数**:
```protobuf
message MessageSyncRequest {
  MessageSyncType sync_type = 1;         // 必需：同步类型
  string conversation_id = 2;            // 必需：会话ID
  optional string cursor_message_id = 5;  // 可选：游标消息ID
  optional int64 cursor_timestamp = 6;    // 可选：游标时间戳（毫秒）
  int32 limit = 7;                       // 必需：消息数量限制
  optional int32 before_count = 8;       // 可选：双向同步时，游标前的消息数量
  optional int32 after_count = 9;        // 可选：双向同步时，游标后的消息数量
  bool include_cursor = 10;              // 必需：是否包含游标消息本身
}
```

**支持的同步类型**:
- `INITIAL_LOAD = 0` - 初始加载（首次进入）
- `CURSOR_FORWARD = 1` - 向前同步（获取新消息）
- `CURSOR_AROUND = 2` - 双向同步（获取上下文消息）

**服务器响应**:
```protobuf
message MessageSyncResponse {
  bool success = 1;                      // 请求是否成功
  string conversation_id = 2;            // 会话ID
  MessageCollection messages = 3;        // 消息集合
  optional string prev_cursor = 4;       // 上一页游标（消息ID）
  optional string next_cursor = 5;       // 下一页游标（消息ID）
  bool has_more_before = 6;              // 是否还有更早的消息
  bool has_more_after = 7;               // 是否还有更新的消息
  int32 returned_count = 8;              // 实际返回的消息数量
  optional int64 oldest_timestamp = 9;   // 最旧消息时间戳
  optional int64 newest_timestamp = 10;  // 最新消息时间戳
}
```

**业务逻辑**:

##### 场景1: INITIAL_LOAD（首次进入）
```javascript
// 输入参数
{
  sync_type: INITIAL_LOAD,
  conversation_id: "conv_123",
  limit: 30
}

// 服务器逻辑
async function handleInitialLoad(request) {
  // 1. 获取最新50条消息（按时间降序）
  const messages = await db.query(`
    SELECT * FROM messages 
    WHERE conversation_id = ? 
    ORDER BY created_at DESC 
    LIMIT ?
  `, [request.conversation_id, request.limit]);

  // 2. 检查是否还有更早的历史消息
  const hasMoreBefore = messages.length === request.limit && 
    await db.exists(`
      SELECT 1 FROM messages 
      WHERE conversation_id = ? 
      AND created_at < ?
    `, [request.conversation_id, messages[messages.length - 1].created_at]);

  // 3. 返回响应
  return {
    success: true,
    conversation_id: request.conversation_id,
    messages: messages.reverse(), // 按时间正序返回（最旧的在前）
    prev_cursor: messages[0]?.message_id,      // 最旧消息ID
    next_cursor: messages[messages.length - 1]?.message_id, // 最新消息ID
    has_more_before: hasMoreBefore,
    has_more_after: false, // 初始加载获取的是最新消息
    returned_count: messages.length,
    oldest_timestamp: messages[0]?.created_at,
    newest_timestamp: messages[messages.length - 1]?.created_at
  };
}
```

##### 场景2: CURSOR_FORWARD（向前同步）
```javascript
// 输入参数
{
  sync_type: CURSOR_FORWARD,
  conversation_id: "conv_123",
  cursor_timestamp: 1641234567890,
  limit: 20
}

// 服务器逻辑
async function handleCursorForward(request) {
  // 1. 获取游标时间戳之后的新消息（按时间正序）
  const messages = await db.query(`
    SELECT * FROM messages 
    WHERE conversation_id = ? 
    AND created_at > ?
    ORDER BY created_at ASC 
    LIMIT ?
  `, [request.conversation_id, request.cursor_timestamp, request.limit]);

  // 2. 检查是否还有更多新消息
  const hasMoreAfter = messages.length === request.limit && 
    await db.exists(`
      SELECT 1 FROM messages 
      WHERE conversation_id = ? 
      AND created_at > ?
    `, [request.conversation_id, messages[messages.length - 1].created_at]);

  return {
    success: true,
    conversation_id: request.conversation_id,
    messages: messages,
    prev_cursor: messages[0]?.message_id,
    next_cursor: messages[messages.length - 1]?.message_id,
    has_more_before: true, // 肯定有更早的消息（游标位置之前）
    has_more_after: hasMoreAfter,
    returned_count: messages.length,
    oldest_timestamp: messages[0]?.created_at,
    newest_timestamp: messages[messages.length - 1]?.created_at
  };
}
```

##### 场景3: CURSOR_AROUND（双向同步）
```javascript
// 输入参数
{
  sync_type: CURSOR_AROUND,
  conversation_id: "conv_123",
  cursor_message_id: "msg_anchor",
  cursor_timestamp: 1641234567890,
  before_count: 10,
  after_count: 20,
  include_cursor: false
}

// 服务器逻辑
async function handleCursorAround(request) {
  // 1. 获取游标前的消息
  const beforeMessages = await db.query(`
    SELECT * FROM messages 
    WHERE conversation_id = ? 
    AND created_at < ?
    ORDER BY created_at DESC 
    LIMIT ?
  `, [request.conversation_id, request.cursor_timestamp, request.before_count]);

  // 2. 获取游标后的消息
  const afterMessages = await db.query(`
    SELECT * FROM messages 
    WHERE conversation_id = ? 
    AND created_at > ?
    ORDER BY created_at ASC 
    LIMIT ?
  `, [request.conversation_id, request.cursor_timestamp, request.after_count]);

  // 3. 可选：包含游标消息本身
  let cursorMessage = [];
  if (request.include_cursor) {
    cursorMessage = await db.query(`
      SELECT * FROM messages 
      WHERE message_id = ?
    `, [request.cursor_message_id]);
  }

  // 4. 合并消息（按时间正序）
  const allMessages = [
    ...beforeMessages.reverse(),
    ...cursorMessage,
    ...afterMessages
  ];

  return {
    success: true,
    conversation_id: request.conversation_id,
    messages: allMessages,
    prev_cursor: beforeMessages[beforeMessages.length - 1]?.message_id,
    next_cursor: afterMessages[afterMessages.length - 1]?.message_id,
    has_more_before: beforeMessages.length === request.before_count,
    has_more_after: afterMessages.length === request.after_count,
    returned_count: allMessages.length
  };
}
```

#### `messages:sync:response` - 消息同步响应事件

**描述**: 服务器响应客户端同步请求的事件

**触发时机**: 服务器处理完`messages:sync`请求后立即发送

**数据格式**: 使用上述`MessageSyncResponse`结构

---

### 2. 实时消息接口

#### `message:send` - 发送消息接口

**描述**: 客户端发送新消息到服务器

**客户端请求参数**:
```protobuf
message MessageProto {
  string message_id = 1;          // 可选：客户端临时ID
  string conversation_id = 2;     // 必需：会话ID
  string sender_id = 3;          // 必需：发送者ID（从token获取）
  string text = 4;               // 必需：消息内容
  string type = 5;               // 必需：消息类型（text, image, file等）
  int64 created_at = 6;          // 必需：创建时间戳
  optional string reply_to_message_id = 7; // 可选：回复的消息ID
  string status = 8;             // 消息状态
  optional string temp_id = 9;   // 可选：客户端临时ID
}
```

**服务器响应**:
```protobuf
message MessageResponse {
  bool success = 1;              // 发送是否成功
  string message_id = 2;         // 服务器生成的真实messageId
  optional string temp_id = 3;   // 客户端临时ID（用于匹配）
  int64 timestamp = 4;           // 服务器时间戳
  string status = 5;             // 消息状态
  optional string error_message = 6; // 错误信息（如果失败）
}
```

**业务逻辑**:
```javascript
async function handleMessageSend(socket, messageProto) {
  try {
    // 1. 验证用户权限
    const hasAccess = await checkConversationAccess(
      socket.userId, 
      messageProto.conversation_id
    );
    if (!hasAccess) {
      throw new Error('无权限发送消息到此会话');
    }

    // 2. 保存消息到数据库
    const savedMessage = await db.insertMessage({
      id: generateMessageId(),
      conversation_id: messageProto.conversation_id,
      sender_id: socket.userId, // 从认证token获取
      text: messageProto.text,
      type: messageProto.type,
      created_at: Date.now(),
      status: 'sent',
      reply_to_message_id: messageProto.reply_to_message_id
    });

    // 3. 更新会话最后消息信息
    await db.updateConversation(messageProto.conversation_id, {
      last_message_id: savedMessage.id,
      last_message_at: savedMessage.created_at,
      updated_at: savedMessage.created_at
    });

    // 4. 响应发送者
    const response = {
      success: true,
      message_id: savedMessage.id,
      temp_id: messageProto.temp_id,
      timestamp: savedMessage.created_at,
      status: 'sent'
    };
    socket.emit('message:send:response', MessageResponse.encode(response).finish());

    // 5. 广播给房间内其他成员
    const broadcastMessage = {
      message_id: savedMessage.id,
      conversation_id: savedMessage.conversation_id,
      sender_id: savedMessage.sender_id,
      text: savedMessage.text,
      type: savedMessage.type,
      created_at: savedMessage.created_at,
      status: 'sent'
    };
    
    socket.to(savedMessage.conversation_id).emit('message:new', 
      MessageProto.encode(broadcastMessage).finish());

    return true;
  } catch (error) {
    // 6. 发送错误响应
    const errorResponse = {
      success: false,
      temp_id: messageProto.temp_id,
      error_message: error.message
    };
    socket.emit('message:send:response', 
      MessageResponse.encode(errorResponse).finish());
    
    return false;
  }
}
```

#### `message:send:response` - 发送消息响应事件

**描述**: 服务器确认消息发送结果

**触发时机**: 处理完`message:send`请求后立即发送给发送者

#### `message:new` - 新消息通知事件

**描述**: 服务器广播新消息给会话房间内的其他成员

**触发时机**: 消息保存成功后广播给除发送者外的房间成员

**参数**: 使用`MessageProto`格式

---

### 3. 消息状态接口

#### `message:read` - 标记消息已读接口

**描述**: 客户端标记单条或多条消息为已读

**客户端请求参数**:
```protobuf
message MessageReadProto {
  string message_id = 1;         // 必需：消息ID
  string conversation_id = 2;    // 必需：会话ID
  string user_id = 3;           // 必需：读取者ID
  int64 read_at = 4;            // 必需：读取时间戳
}
```

**业务逻辑**:
```javascript
async function handleMessageRead(socket, readProto) {
  try {
    // 1. 记录已读状态
    await db.insertOrUpdate('message_read_status', {
      message_id: readProto.message_id,
      user_id: socket.userId,
      conversation_id: readProto.conversation_id,
      read_at: Date.now(),
      created_at: Date.now()
    });

    // 2. 获取消息的发送者
    const message = await db.getMessageById(readProto.message_id);
    if (!message) return;

    // 3. 通知发送者消息已被读取（如果发送者在线）
    const senderSocketId = await getUserSocketId(message.sender_id);
    if (senderSocketId) {
      const notification = {
        message_id: readProto.message_id,
        conversation_id: readProto.conversation_id,
        read_by_user_id: socket.userId,
        read_by_user_name: socket.userInfo.name,
        read_at: Date.now()
      };
      
      io.to(senderSocketId).emit('message:read:notification', notification);
    }

    return true;
  } catch (error) {
    console.error('标记消息已读失败:', error);
    return false;
  }
}
```

#### `message:delivered` - 消息送达通知接口

**描述**: 服务器通知发送者消息已送达到接收者

**触发时机**: 接收者收到消息时自动触发

**参数**: 使用`MessageProto`格式

---

### 4. 会话管理接口

#### `conversation:join` - 加入会话房间接口

**描述**: 用户加入特定会话的Socket.io房间

**客户端请求参数**:
```protobuf
message ConversationJoinLeaveRequest {
  string conversation_id = 1;    // 必需：会话ID
  string user_id = 2;           // 必需：用户ID
}
```

**服务器响应**:
```protobuf
message ConversationJoinLeaveResponse {
  bool success = 1;              // 操作是否成功
  string conversation_id = 2;    // 会话ID
  string user_id = 3;           // 用户ID
  int64 timestamp = 4;          // 操作时间戳
  optional string error_message = 5; // 错误信息
}
```

**业务逻辑**:
```javascript
async function handleConversationJoin(socket, request) {
  try {
    // 1. 验证用户是否有权限加入该会话
    const hasAccess = await checkConversationAccess(
      socket.userId, 
      request.conversation_id
    );
    if (!hasAccess) {
      throw new Error('无权限加入此会话');
    }

    // 2. 将用户Socket加入房间
    socket.join(request.conversation_id);

    // 3. 更新用户在线状态
    await updateUserOnlineStatus(socket.userId, request.conversation_id, true);

    // 4. 响应成功
    const response = {
      success: true,
      conversation_id: request.conversation_id,
      user_id: socket.userId,
      timestamp: Date.now()
    };
    
    socket.emit('conversation:joined', 
      ConversationJoinLeaveResponse.encode(response).finish());

    // 5. 可选：通知其他成员用户上线
    socket.to(request.conversation_id).emit('user:online', {
      user_id: socket.userId,
      user_name: socket.userInfo.name,
      timestamp: Date.now()
    });

    return true;
  } catch (error) {
    // 发送错误响应
    const errorResponse = {
      success: false,
      conversation_id: request.conversation_id,
      error_message: error.message
    };
    
    socket.emit('conversation:join:error', 
      ConversationJoinLeaveResponse.encode(errorResponse).finish());
    
    return false;
  }
}
```

#### `conversation:leave` - 离开会话房间接口

**描述**: 用户离开特定会话的Socket.io房间

**客户端请求参数**: 同`ConversationJoinLeaveRequest`

**业务逻辑**:
```javascript
async function handleConversationLeave(socket, request) {
  try {
    // 1. 将用户Socket从房间移除
    socket.leave(request.conversation_id);

    // 2. 更新用户在线状态
    await updateUserOnlineStatus(socket.userId, request.conversation_id, false);

    // 3. 同步最后已读位置（离开时标记为已读到最新）
    await markConversationAsRead(socket.userId, request.conversation_id);

    // 4. 响应成功
    const response = {
      success: true,
      conversation_id: request.conversation_id,
      user_id: socket.userId,
      timestamp: Date.now()
    };
    
    socket.emit('conversation:left', response);

    // 5. 通知其他成员用户离线
    socket.to(request.conversation_id).emit('user:offline', {
      user_id: socket.userId,
      timestamp: Date.now()
    });

    return true;
  } catch (error) {
    console.error('离开会话失败:', error);
    return false;
  }
}
```

---

### 5. 用户状态接口

#### `user:typing` - 用户输入状态接口

**描述**: 通知其他用户当前用户正在输入

**客户端请求参数**:
```protobuf
message UserTypingUpdate {
  string conversation_id = 1;    // 必需：会话ID
  string user_id = 2;           // 必需：用户ID
  bool is_typing = 3;           // 必需：是否正在输入
  int64 timestamp = 4;          // 必需：时间戳
}
```

**业务逻辑**:
```javascript
async function handleUserTyping(socket, typingUpdate) {
  // 1. 设置输入状态过期时间（3秒后自动停止）
  const typingKey = `typing:${typingUpdate.conversation_id}:${socket.userId}`;
  
  if (typingUpdate.is_typing) {
    await redis.setex(typingKey, 3, 'typing');
    
    // 2. 广播给房间内其他成员
    socket.to(typingUpdate.conversation_id).emit('user:typing', {
      conversation_id: typingUpdate.conversation_id,
      user_id: socket.userId,
      user_name: socket.userInfo.name,
      is_typing: true,
      timestamp: Date.now()
    });
  } else {
    await redis.del(typingKey);
    
    // 3. 通知停止输入
    socket.to(typingUpdate.conversation_id).emit('user:typing', {
      conversation_id: typingUpdate.conversation_id,
      user_id: socket.userId,
      is_typing: false,
      timestamp: Date.now()
    });
  }
}
```

#### `user:online` / `user:offline` - 用户在线状态接口

**描述**: 用户上线/下线状态广播

**触发时机**: 
- 用户连接/断开Socket时
- 用户加入/离开会话时

**参数**:
```javascript
{
  user_id: "user123",
  user_name: "用户名",
  status: "online" | "offline",
  timestamp: 1641234567890,
  last_seen: 1641234567890 // 仅offline时提供
}
```

---

### 6. 会话同步接口

#### `conversation:sync` - 同步会话列表接口

**描述**: 获取用户的所有会话列表

**客户端请求参数**:
```protobuf
message SyncConversationsRequest {
  optional int64 last_sync_time = 1; // 可选：上次同步时间（增量同步）
}
```

**服务器响应**:
```protobuf
message ConversationCollection {
  repeated ConversationProto conversations = 1; // 会话列表
  int64 sync_time = 2;                         // 同步时间戳
}
```

**业务逻辑**:
```javascript
async function handleConversationSync(socket, request) {
  try {
    let whereClause = `
      WHERE cm.user_id = ? 
      AND cm.left_at IS NULL
    `;
    let params = [socket.userId];

    // 支持增量同步
    if (request.last_sync_time) {
      whereClause += ` AND c.updated_at > ?`;
      params.push(request.last_sync_time);
    }

    // 获取用户的会话列表
    const conversations = await db.query(`
      SELECT c.*, 
             cm.role,
             cm.joined_at,
             lm.text as last_message_text,
             lm.sender_id as last_message_sender,
             lm.created_at as last_message_time,
             (
               SELECT COUNT(*) 
               FROM messages m 
               LEFT JOIN message_read_status mrs ON m.id = mrs.message_id AND mrs.user_id = ?
               WHERE m.conversation_id = c.id 
               AND mrs.read_at IS NULL
             ) as unread_count
      FROM conversations c
      JOIN conversation_members cm ON c.id = cm.conversation_id
      LEFT JOIN messages lm ON c.last_message_id = lm.id
      ${whereClause}
      ORDER BY c.updated_at DESC
    `, [socket.userId, ...params]);

    const response = {
      conversations: conversations,
      sync_time: Date.now()
    };

    socket.emit('conversation:sync:response', 
      ConversationCollection.encode(response).finish());

    return true;
  } catch (error) {
    console.error('同步会话列表失败:', error);
    socket.emit('conversation:sync:error', { error: error.message });
    return false;
  }
}
```

---

## 🗄️ 数据库设计要求

### 核心表结构

#### 消息表 (messages)
```sql
CREATE TABLE messages (
  id VARCHAR(36) PRIMARY KEY,              -- messageId
  conversation_id VARCHAR(36) NOT NULL,    -- 会话ID
  sender_id VARCHAR(36) NOT NULL,          -- 发送者ID
  text TEXT,                               -- 消息内容
  type VARCHAR(20) NOT NULL DEFAULT 'text', -- 消息类型
  reply_to_message_id VARCHAR(36),         -- 回复的消息ID
  created_at BIGINT NOT NULL,              -- 创建时间戳（毫秒）
  updated_at BIGINT,                       -- 更新时间戳
  status VARCHAR(20) DEFAULT 'sent',       -- 消息状态
  
  -- 关键索引（支持高效查询）
  INDEX idx_conversation_time (conversation_id, created_at DESC),
  INDEX idx_conversation_time_asc (conversation_id, created_at ASC),
  INDEX idx_message_lookup (conversation_id, id),
  
  FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  FOREIGN KEY (sender_id) REFERENCES users(id)
);
```

#### 消息已读状态表 (message_read_status)
```sql
CREATE TABLE message_read_status (
  id VARCHAR(36) PRIMARY KEY,
  message_id VARCHAR(36) NOT NULL,         -- 消息ID
  user_id VARCHAR(36) NOT NULL,            -- 读取者ID
  conversation_id VARCHAR(36) NOT NULL,    -- 会话ID  
  read_at BIGINT NOT NULL,                 -- 读取时间戳
  created_at BIGINT NOT NULL,              -- 记录创建时间
  
  -- 唯一约束和索引
  UNIQUE KEY unique_user_message (user_id, message_id),
  INDEX idx_user_conversation_read (user_id, conversation_id, read_at),
  INDEX idx_conversation_read_status (conversation_id, message_id, user_id),
  
  FOREIGN KEY (message_id) REFERENCES messages(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);
```

### 关键查询示例

#### 1. 获取最新消息（INITIAL_LOAD）
```sql
SELECT * FROM messages 
WHERE conversation_id = ? 
ORDER BY created_at DESC 
LIMIT ?;
```

#### 2. 获取新消息（CURSOR_FORWARD）
```sql
SELECT * FROM messages 
WHERE conversation_id = ? 
AND created_at > ?
ORDER BY created_at ASC 
LIMIT ?;
```

#### 3. 获取未读消息
```sql
SELECT m.* 
FROM messages m
LEFT JOIN message_read_status mrs ON m.id = mrs.message_id AND mrs.user_id = ?
WHERE m.conversation_id = ? 
AND mrs.read_at IS NULL
ORDER BY m.created_at ASC;
```

#### 4. 获取会话未读计数
```sql
SELECT COUNT(*) as unread_count
FROM messages m 
LEFT JOIN message_read_status mrs ON m.id = mrs.message_id AND mrs.user_id = ?
WHERE m.conversation_id = ? 
AND mrs.read_at IS NULL;
```

---

## 🚀 实现优先级

### 第一阶段（核心功能）
1. **消息同步**: `messages:sync` + `messages:sync:response`
2. **会话管理**: `conversation:join` + `conversation:leave`
3. **基础数据库结构**

### 第二阶段（实时通信）
1. **发送消息**: `message:send` + `message:send:response` + `message:new`
2. **已读状态**: `message:read`
3. **会话同步**: `conversation:sync`

### 第三阶段（增强功能）
1. **用户状态**: `user:typing` + `user:online/offline`
2. **消息送达**: `message:delivered`
3. **性能优化和缓存**

---

## 💡 关键实现点

1. **认证**: JWT Token通过Socket连接的`auth.token`参数传递
2. **房间管理**: 使用会话ID作为Socket.io房间名称
3. **错误处理**: 所有接口都需要适当的错误响应
4. **性能**: 使用Redis缓存热点数据和用户状态
5. **扩展性**: 支持分布式部署的Socket.io集群

服务器端按照此规范实现，客户端已完全准备就绪！🚀