# Proto文件Socket.io事件映射总结

## 概述

为了统一服务器和客户端的Socket.io事件定义，我们在所有proto文件中添加了事件名称备注。这样服务器和客户端开发人员都可以通过proto文件清楚地了解每个消息类型对应的Socket.io事件名称。

## 修改的文件

### 1. message.proto
添加了以下消息的Socket.io事件备注：

| 消息类型 | Socket.io事件 | 用途 |
|---------|---------------|------|
| MessageProto | message:new, message:delivered, message:read, message:send, message:updated | 基本消息结构 |
| MessageSendResponse | message:send:response | 发送消息响应 |
| TypingProto | user:typing, user:typing:stop | 输入状态 |
| MessageReadProto | message:read | 消息已读 |
| MessagesFetchRequest | messages:fetch | 消息获取请求 |
| MessagesFetchResponse | messages:fetch:response | 消息获取响应 |
| MessageEditRequest | message:edit | 消息编辑请求 |
| MessageEditResponse | message:edit:response | 消息编辑响应 |
| MessageRevokeRequest | message:revoke | 消息撤回请求 |
| MessageRevokeResponse | message:revoke:response | 消息撤回响应 |
| MessageDeleteRequest | message:delete | 消息删除请求 |
| MessageDeleteResponse | message:delete:response | 消息删除响应 |

### 2. conversation.proto
添加了以下消息的Socket.io事件备注：

| 消息类型 | Socket.io事件 | 用途 |
|---------|---------------|------|
| ConversationProto | conversation:update, conversation:created, conversation:deleted | 会话基本信息 |
| ConversationCollection | conversation:sync:response | 会话列表响应 |
| SyncConversationsRequest | conversation:sync | 同步会话请求 |
| ConversationUpdateNotification | conversation:update:notification | 会话更新通知 |
| ConversationSettingsUpdateRequest | conversation:settings:update | 会话设置更新请求 |
| ConversationSettingsUpdateResponse | conversation:settings:updated | 会话设置更新响应 |
| ConversationJoinLeaveRequest | conversation:join, conversation:leave | 会话加入/离开请求 |
| ConversationJoinLeaveResponse | conversation:leave:response | 会话离开响应 |
| ConversationCreateRequest | conversation:create | 会话创建请求 |
| ConversationCreateResponse | conversation:create:response | 会话创建响应 |
| UserJoinedNotification | conversation:user:joined | 用户加入通知 |
| UserLeftNotification | conversation:user:left | 用户离开通知 |
| ParticipantStatusUpdateRequest | participant:status:update | 参与者状态更新请求 |
| ParticipantStatusUpdateResponse | participant:status:update:response | 参与者状态更新响应 |
| ConversationMemberChangeRequest | conversation:member:add, conversation:member:change | 会话成员管理请求 |
| ConversationMembersResponse | conversation:members | 会话成员列表响应 |
| ConversationMemberChangeResponse | conversation:member:changed:response | 会话成员管理响应 |
| ConversationMemberChangeResponse | conversation:member:changed | 会话成员变更通知 |
| ConversationDetailRequest | conversation:detail | 获取会话详情请求 |
| ConversationDetailResponse | conversation:detail:response | 获取会话详情响应 |

### 3. user.proto
添加了以下消息的Socket.io事件备注：

| 消息类型 | Socket.io事件 | 用途 |
|---------|---------------|------|
| UserProto | user:profile:updated | 用户基本信息 |
| SetCurrentUserRequest | user:set | 设置当前用户信息请求 |
| SetCurrentUserResponse | user:set:response | 设置当前用户信息响应 |
| CurrentUserUpdateEvent | user:updated | 当前用户信息更新事件 |
| UserStatusUpdate | user:online, user:offline | 用户在线状态更新 |
| UserTypingUpdate | user:typing, user:typing:stop | 用户打字状态更新 |
| UserCollection | contact:synced | 用户列表/联系人同步 |
| UniversalSearchRequest | search:universal | 统一搜索请求 |
| UniversalSearchResponse | search:universal:response | 统一搜索响应 |

### 4. contacts.proto
添加了以下消息的Socket.io事件备注：

| 消息类型 | Socket.io事件 | 用途 |
|---------|---------------|------|
| SyncContactsRequest | contact:sync | 同步联系人请求 |
| SyncContactsResponse | contact:sync:response | 同步联系人响应 |

### 5. auth.proto
此文件中的消息主要用于HTTP REST API认证，不通过Socket.io发送，因此没有添加Socket.io事件备注。

## 重要修改点

### 1. MessagesFetchRequest和MessagesFetchResponse
- 添加了 `anchor_message_index` 字段，用于支持JUMP_TO_INDEX加载类型
- 这个修改解决了之前跳转到指定消息索引功能失效的问题

### 2. 事件映射修正
在 `lib/core/services/proto_events.dart` 中修正了以下映射：
- `conversation:member:change` → ConversationMemberChangeRequest（客户端请求）
- `conversation:member:changed:response` → ConversationMemberChangeResponse（服务器响应）
- `conversation:member:changed` → ConversationMemberChangeResponse（服务器广播）

## 使用方式

### 服务器端 (Next.js)
服务器开发人员可以通过查看proto文件中的Socket.io事件备注，了解应该使用哪个事件名称：

```javascript
// 发送新消息通知，参考 MessageProto 的事件备注
socket.emit('message:new', messageData);

// 响应消息获取请求，参考 MessagesFetchResponse 的事件备注  
socket.emit('messages:fetch:response', responseData);
```

### 客户端 (Flutter)
客户端开发人员同样可以通过proto文件确认事件名称：

```dart
// 发送消息获取请求，参考 MessagesFetchRequest 的事件备注
communicationService.emitProto('messages:fetch', request);

// 监听新消息，参考 MessageProto 的事件备注
communicationService.on('message:new', _handleNewMessage);
```

## 规范约定

### 1. 备注格式
```protobuf
// 消息描述
// Socket.io事件: event:name1, event:name2
message MessageType {
  // 字段定义...
}
```

### 2. 事件命名规则
- **模块:操作[:子操作]** 格式
- 请求事件：`module:action`
- 响应事件：`module:action:response`  
- 通知事件：`module:action:notification`

### 3. 多事件支持
一个消息类型可能对应多个Socket.io事件，用逗号分隔：
```protobuf
// Socket.io事件: message:new, message:delivered, message:read
```

## 维护指南

### 1. 添加新消息时
- 确定消息对应的Socket.io事件名称
- 遵循事件命名规则
- 在消息定义前添加事件备注
- 更新 `proto_events.dart` 中的映射表

### 2. 修改现有消息时
- 如果事件名称发生变化，同时更新备注和映射表
- 确保服务器和客户端代码同步更新
- 考虑向后兼容性

### 3. 生成proto文件
修改proto源文件后，使用以下命令重新生成：
```bash
./scripts/generate_protos.sh
```

## 好处

1. **统一性**：服务器和客户端通过同一个proto文件了解事件名称
2. **可维护性**：事件名称集中管理，减少不一致的风险
3. **开发效率**：开发人员无需来回确认事件名称
4. **文档化**：proto文件本身就是最权威的事件文档
5. **版本控制**：事件名称变更可以通过git历史追踪

## 注意事项

1. proto文件中的备注不会影响生成的代码
2. 某些消息类型可能不对应Socket.io事件（如认证相关消息）
3. 事件名称修改需要同时更新服务器和客户端代码
4. 保持事件名称与proto_events.dart映射表的一致性 