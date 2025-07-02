# Proto事件映射说明

## 概述

`lib/core/services/proto_events.dart` 文件定义了Socket.io事件名称与Protobuf消息类型之间的映射关系。每个事件都有详细的备注说明，包括事件用途和对应的消息类型。

## 事件分类

### 1. 用户相关事件 (User Events)
- `user:set` → SetCurrentUserRequest - 设置当前用户信息请求
- `user:set:response` → SetCurrentUserResponse - 设置当前用户信息响应
- `user:updated` → CurrentUserUpdateEvent - 用户信息更新事件
- `user:online` → UserStatusUpdate - 用户上线状态通知
- `user:offline` → UserStatusUpdate - 用户下线状态通知
- `user:typing` → UserTypingUpdate - 用户正在输入通知
- `user:typing:stop` → UserTypingUpdate - 用户停止输入通知
- `user:profile:updated` → UserProto - 用户资料更新通知

### 2. 搜索相关事件 (Search Events)
- `search:universal` → UniversalSearchRequest - 全局搜索请求
- `search:universal:response` → UniversalSearchResponse - 全局搜索响应

### 3. 消息相关事件 (Message Events)
- `message:new` → MessageProto - 新消息通知
- `message:delivered` → MessageProto - 消息送达通知
- `message:read` → MessageProto - 消息已读通知
- `message:send` → MessageProto - 发送消息请求
- `message:send:response` → MessageSendResponse - 发送消息响应
- `message:updated` → MessageProto - 消息状态更新广播
- `messages:fetch` → MessagesFetchRequest - 批量获取消息请求
- `messages:fetch:response` → MessagesFetchResponse - 批量获取消息响应

### 4. 消息操作事件 (Message Actions)
- `message:edit` → MessageEditRequest - 编辑消息请求
- `message:edit:response` → MessageEditResponse - 编辑消息响应
- `message:revoke` → MessageRevokeRequest - 撤回消息请求
- `message:revoke:response` → MessageRevokeResponse - 撤回消息响应
- `message:delete` → MessageDeleteRequest - 删除消息请求
- `message:delete:response` → MessageDeleteResponse - 删除消息响应

### 5. 会话相关事件 (Conversation Events)
- `conversation:update` → ConversationProto - 会话更新通知
- `conversation:created` → ConversationProto - 会话创建通知
- `conversation:deleted` → ConversationProto - 会话删除通知
- `conversation:sync` → SyncConversationsRequest - 同步会话请求
- `conversation:sync:response` → ConversationCollection - 同步会话响应
- `conversation:update:notification` → ConversationUpdateNotification - 会话更新通知

### 6. 会话设置事件 (Conversation Settings)
- `conversation:settings:update` → ConversationSettingsUpdateRequest - 会话设置更新请求
- `conversation:settings:updated` → ConversationSettingsUpdateResponse - 会话设置更新响应

### 7. 会话房间管理 (Room Management)
- `conversation:join` → ConversationJoinLeaveRequest - 加入会话房间请求
- `conversation:leave` → ConversationJoinLeaveRequest - 离开会话房间请求
- `conversation:leave:response` → ConversationJoinLeaveResponse - 离开会话房间响应

### 8. 会话创建管理 (Conversation Creation)
- `conversation:create` → ConversationCreateRequest - 创建会话请求
- `conversation:create:response` → ConversationCreateResponse - 创建会话响应
- `conversation:detail:response` → ConversationDetailResponse - 获取会话详情响应

### 9. 参与者状态管理 (Participant Status)
- `participant:status:update` → ParticipantStatusUpdateRequest - 参与者状态更新请求
- `participant:status:update:response` → ParticipantStatusUpdateResponse - 参与者状态更新响应

### 10. 会话成员管理 (Member Management)
- `conversation:member:add` → ConversationMemberChangeRequest - 会话成员管理请求（添加成员）
- `conversation:member:change` → ConversationMemberChangeRequest - 会话成员管理请求（添加/移除/角色变更/屏蔽）
- `conversation:members` → ConversationMembersResponse - 会话成员列表响应
- `conversation:member:changed:response` → ConversationMemberChangeResponse - 会话成员管理响应（服务器确认）
- `conversation:member:changed` → ConversationMemberChangeResponse - 会话成员变更通知（服务器广播）
- `conversation:user:joined` → UserJoinedNotification - 用户加入会话通知
- `conversation:user:left` → UserLeftNotification - 用户离开会话通知

### 11. 联系人相关事件 (Contact Events)
- `contact:synced` → UserCollection - 联系人同步通知
- `contact:sync` → SyncContactsRequest - 联系人同步请求
- `contact:sync:response` → SyncContactsResponse - 联系人同步响应

### 12. 系统相关事件 (System Events)
- `system:message` → SystemMessage - 系统消息通知

## 命名规范

### 事件命名约定
1. **模块:操作[:子操作]** 格式
   - 模块：user、message、conversation、contact、system等
   - 操作：send、fetch、update、create、delete等
   - 子操作：response、notification等

2. **请求与响应配对**
   - 请求：`module:action`
   - 响应：`module:action:response`

3. **通知事件**
   - 广播通知：`module:action:notification`
   - 状态更新：`module:updated`

### 消息类型说明
- **Request**：客户端发送给服务器的请求消息
- **Response**：服务器回复给客户端的响应消息
- **Notification**：服务器主动推送的通知消息
- **Event**：事件类型的消息
- **Proto**：基础proto消息类型

## 使用方法

```dart
// 获取事件的消息创建函数
final creator = ProtoEvents.getEventCreator('message:send');
if (creator != null) {
  final message = creator();
  // 使用消息...
}

// 检查事件是否已注册
if (ProtoEvents.isEventRegistered('user:online')) {
  // 事件已注册...
}

// 注册自定义事件
ProtoEvents.registerEvent('custom:event', () => CustomMessage());
```

## 注意事项

1. **事件名称必须唯一**：不同的事件不能使用相同的名称
2. **消息类型匹配**：事件名称必须与对应的Protobuf消息类型匹配
3. **请求响应对应**：请求事件和响应事件应该成对出现
4. **向后兼容**：修改现有事件时要考虑向后兼容性

## 维护指南

当添加新的事件时：
1. 确定事件所属的分类
2. 遵循命名规范
3. 添加详细的备注说明
4. 确保Protobuf消息类型正确
5. 更新此文档

当修改现有事件时：
1. 检查是否影响现有功能
2. 确保向后兼容性
3. 更新相关文档和注释 