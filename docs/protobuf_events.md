# Protobuf 事件文档

本文档记录了项目中使用的所有 Protobuf 事件定义。

## 消息事件 (Message Events)

### 发送消息
- 事件名: `message:new`
- 方向: 客户端 -> 服务器
- 数据结构:
```protobuf
message NewMessage {
  string id = 1;
  string sender_id = 2;
  string conversation_id = 3;
  string content = 4;
  int64 timestamp = 5;
  string type = 6;  // "text" | "image" | "video" | "audio" | "file"
  map<string, string> metadata = 7;
}
```

### 接收消息
- 事件名: `message:received`
- 方向: 服务器 -> 客户端
- 数据结构:
```protobuf
message MessageReceived {
  string message_id = 1;
  string receiver_id = 2;
  int64 received_at = 3;
}
```

### 消息已读
- 事件名: `message:read`
- 方向: 双向
- 数据结构:
```protobuf
message MessageRead {
  string message_id = 1;
  string reader_id = 2;
  string conversation_id = 3;
  int64 read_at = 4;
}
```

### 消息删除
- 事件名: `message:delete`
- 方向: 客户端 -> 服务器
- 数据结构:
```protobuf
message MessageDelete {
  string message_id = 1;
  string deleter_id = 2;
  string conversation_id = 3;
  bool delete_for_everyone = 4;
}
```

## 用户事件 (User Events)

### 用户状态更新
- 事件名: `user:status`
- 方向: 双向
- 数据结构:
```protobuf
message UserStatus {
  string user_id = 1;
  string status = 2;  // "online" | "offline" | "away"
  int64 last_seen = 3;
}
```

### 用户输入状态
- 事件名: `user:typing`
- 方向: 双向
- 数据结构:
```protobuf
message TypingStatus {
  string user_id = 1;
  string conversation_id = 2;
  bool is_typing = 3;
}
```

### 用户资料更新
- 事件名: `user:profile_update`
- 方向: 客户端 -> 服务器
- 数据结构:
```protobuf
message UserProfileUpdate {
  string user_id = 1;
  optional string name = 2;
  optional string avatar_url = 3;
  optional string status_message = 4;
  map<string, string> custom_fields = 5;
}
```

## 会话事件 (Conversation Events)

### 创建会话
- 事件名: `conversation:create`
- 方向: 客户端 -> 服务器
- 数据结构:
```protobuf
message CreateConversation {
  string id = 1;
  repeated string participant_ids = 2;
  string type = 3;  // "private" | "group"
  string name = 4;  // 仅用于群组
  optional string avatar_url = 5;
  map<string, string> metadata = 6;
}
```

### 会话更新
- 事件名: `conversation:update`
- 方向: 服务器 -> 客户端
- 数据结构:
```protobuf
message ConversationUpdated {
  string conversation_id = 1;
  map<string, string> updates = 2;
  int64 updated_at = 3;
}
```

### 会话成员变更
- 事件名: `conversation:members`
- 方向: 双向
- 数据结构:
```protobuf
message ConversationMembers {
  string conversation_id = 1;
  repeated string added_members = 2;
  repeated string removed_members = 3;
  string action_by = 4;
  int64 timestamp = 5;
}
```

### 会话已读位置
- 事件名: `conversation:read_position`
- 方向: 客户端 -> 服务器
- 数据结构:
```protobuf
message ConversationReadPosition {
  string conversation_id = 1;
  string user_id = 2;
  string last_read_message_id = 3;
  int64 timestamp = 4;
}
```

## 媒体事件 (Media Events)

### 媒体上传开始
- 事件名: `media:upload_start`
- 方向: 客户端 -> 服务器
- 数据结构:
```protobuf
message MediaUploadStart {
  string upload_id = 1;
  string file_name = 2;
  string mime_type = 3;
  int64 total_size = 4;
  string uploader_id = 5;
}
```

### 媒体上传完成
- 事件名: `media:uploaded`
- 方向: 服务器 -> 客户端
- 数据结构:
```protobuf
message MediaUploaded {
  string media_id = 1;
  string url = 2;
  string type = 3;  // "image" | "video" | "audio" | "file"
  int64 size = 4;
  string mime_type = 5;
  map<string, string> metadata = 6;
}
```

### 媒体下载进度
- 事件名: `media:download_progress`
- 方向: 服务器 -> 客户端
- 数据结构:
```protobuf
message MediaDownloadProgress {
  string media_id = 1;
  int64 bytes_downloaded = 2;
  int64 total_bytes = 3;
  float progress = 4;
}
```

## 错误事件 (Error Events)

### 错误通知
- 事件名: `error:notify`
- 方向: 双向
- 数据结构:
```protobuf
message Error {
  string code = 1;
  string message = 2;
  map<string, string> details = 3;
  string request_id = 4;
}
```

## 连接事件 (Connection Events)

### 连接状态
- 事件名: `connection:status`
- 方向: 双向
- 数据结构:
```protobuf
message ConnectionStatus {
  string client_id = 1;
  string status = 2;  // "connected" | "disconnected" | "reconnecting"
  int64 timestamp = 3;
  optional string error = 4;
}
```

### 心跳检测
- 事件名: `connection:ping`
- 方向: 双向
- 数据结构:
```protobuf
message Ping {
  int64 timestamp = 1;
  string client_id = 2;
}
```

## 注意事项

1. 所有时间戳使用 Unix 时间戳（毫秒）
2. 所有ID字段使用UUID格式
3. 消息内容支持纯文本和特定格式的富文本
4. 媒体文件需要先上传获取URL后再发送消息
5. 错误处理遵循统一的错误码规范
6. 事件名称统一使用 `category:action` 格式
7. 可选字段使用 optional 关键字标注
8. 复杂数据使用 map 类型存储额外信息

## 版本信息

- 当前版本: v1.0.0
- 最后更新: 2024-03-21
- 协议兼容性: 向下兼容 