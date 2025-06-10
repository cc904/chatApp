# 统一消息同步协议规范

## 概述

使用统一的 `MessageSyncRequest` 和 `MessageSyncResponse` 替代废弃的 `CursorSyncRequest` 和 `CursorSyncResponse`，实现智能的消息同步逻辑。

## 核心设计原则

1. **统一接口**：使用单一请求响应结构处理所有同步场景
2. **智能判断**：服务器根据参数自动选择同步策略
3. **简化实现**：减少客户端和服务器的复杂性
4. **默认优化**：统一使用50条作为默认消息数量

## 协议定义

### MessageSyncRequest
```protobuf
message MessageSyncRequest {
  string conversation_id = 1;                    // 会话ID（必填）
  optional string next_cursor_message_id = 2;    // 客户端本地最新消息ID
  optional int64 next_cursor_timestamp = 3;      // 游标消息时间戳（毫秒）
}
```

### MessageSyncResponse
```protobuf
message MessageSyncResponse {
  bool success = 1;                 // 同步是否成功
  string conversation_id = 2;       // 会话ID
  MessageCollection messages = 3;   // 消息集合
  bool has_more_before = 4;         // 是否还有更早的消息
  bool has_more_after = 5;          // 是否还有更新的消息
}
```

## 服务器端处理逻辑

### 场景一：客户端本地无消息
**条件**: `next_cursor_message_id` 为空

**处理**: 
- 返回该会话最新的一页消息（30-50条）
- 按时间降序排列（最新消息在前）

**示例**:
```json
{
  "conversation_id": "conv_123",
  "next_cursor_message_id": null
}
```

**响应**:
```json
{
  "success": true,
  "conversation_id": "conv_123",
  "messages": [...], // 最新30条消息
  "has_more_before": true,
  "has_more_after": false
}
```

### 场景二：客户端有本地消息且服务器有未读消息

**条件**: 
- `next_cursor_message_id` 有值
- 服务器端该会话有未读消息

**子场景2.1**: 最早未读消息和客户端游标之间有已读消息
```
客户端游标 <- 已读消息 <- 最早未读消息 <- 更多未读消息
```

**处理**:
- 返回：最早未读消息前10条 + 最早未读消息(含)后50条
- 总计最多60条消息
- 设置合适的 `has_more_before` 和 `has_more_after`

**子场景2.2**: 最早未读消息紧跟客户端游标
```
客户端游标 <- 最早未读消息 <- 更多未读消息
```

**处理**:
- 从最早未读消息开始返回50条
- 设置 `has_more_after` 如果还有更多未读消息

### 场景三：客户端有本地消息但服务器无未读消息

**条件**:
- `next_cursor_message_id` 有值  
- 服务器端该会话无未读消息
- 但有已读消息

**处理**:
- 返回最新50条已读消息
- 如果总消息数超过50条，设置 `has_more_before = true`
- 如果不足50条，返回实际数量

### 场景四：会话无任何消息

**条件**: 会话中没有任何消息

**处理**:
- 返回空消息列表
- `has_more_before = false`
- `has_more_after = false`

## 客户端使用指南

### 场景1：首次进入会话（初始加载）

客户端本地无消息时，只需要提供会话ID：

```dart
final request = MessageSyncRequest()
  ..conversationId = conversationId;

socket.emitProto('messages:sync', request);
```

### 场景2：增量同步（有本地消息）

客户端本地有消息时，提供最新消息的游标信息：

```dart
final request = MessageSyncRequest()
  ..conversationId = conversationId
  ..nextCursorMessageId = localLatestMessageId
  ..nextCursorTimestamp = Int64(localLatestTimestamp);

socket.emitProto('messages:sync', request);
```

### 处理响应
```dart
void handleSyncResponse(MessageSyncResponse response) {
  if (response.success) {
    // 合并消息到本地
    mergeMessages(response.messages);
    
    // 根据标记决定是否还需要加载更多
    if (response.hasMoreBefore) {
      // 可以向前加载更多历史消息
    }
    
    if (response.hasMoreAfter) {
      // 可能还有更新的消息
    }
  }
}
```

## 性能考虑

1. **消息数量限制**: 单次返回最多60条消息（10+50）
2. **时间窗口**: 优先返回未读消息周围的消息
3. **分页支持**: 通过 `has_more_before/after` 支持增量加载
4. **智能范围**: 根据未读状态智能确定返回范围

## 错误处理

### 常见错误情况
1. **会话不存在**: `success = false`
2. **权限不足**: `success = false`  
3. **游标消息不存在**: 忽略游标，按场景一处理
4. **时间戳不匹配**: 以 `message_id` 为准

### 错误响应示例
```json
{
  "success": false,
  "conversation_id": "conv_123",
  "messages": null,
  "has_more_before": false,
  "has_more_after": false
}
```

## 与旧版本兼容性

- 完全替代 `CursorSyncRequest/Response`
- 保持 `messages:sync` 事件名称不变
- 响应格式向后兼容
- 客户端可以逐步迁移到新的请求格式 