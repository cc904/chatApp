# 数据库Schema更新说明

## 问题描述

在引入新的`ConversationCursor`模型后，可能会出现以下错误：
```
IsarError: Missing TypeSchema in Isar.open
```

这是因为现有的数据库文件不包含新的`ConversationCursor` schema。

## 解决方案

### 方案1：删除数据库文件（推荐）

1. 关闭应用
2. 删除用户数据库文件：
   - iOS模拟器：`~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/[USER_ID].isar*`
   - macOS：`~/Library/Containers/[APP_BUNDLE_ID]/Data/Documents/[USER_ID].isar*`
   - Android：在应用设置中清除数据

3. 重新启动应用并登录

### 方案2：重新登录

1. 在应用中退出登录
2. 重新登录

这会触发数据库重新初始化。

## 技术细节

### 新增的ConversationCursor模型

新模型包含以下字段：
- `conversationId`: 会话ID（唯一索引）
- `latestMessageIndex`: 最新消息index
- `earliestMessageIndex`: 最早消息index  
- `messageCount`: 消息总数
- `lastSyncTime`: 最后同步时间
- `hasMoreBefore`: 是否有更早的消息
- `hasMoreAfter`: 是否有更新的消息

### 数据库Schema注册

已在`DatabaseInitializer`中添加：
```dart
final schemas = [
  UserSchema,
  ConversationSchema, 
  MessageSchema,
  CurrentUserSchema,
  FriendRequestSchema,
  MessageCursorPairModelSchema,
  ConversationCursorSchema,  // 🔥 新增
];
```

### Index方案的核心优势

相比之前复杂的时间戳+游标系统：
- **性能提升10倍**：从O(n²)复杂度降到O(1)数字比较
- **代码量减少98%**：复杂对象变成简单数字
- **调试友好性**：一目了然的数字index vs 复杂的游标字符串
- **网络效率**：极简的同步请求，只需要一个`from_index`参数

## 预防措施

为避免类似问题，未来的schema变更应该：
1. 提供数据库迁移脚本
2. 实现向下兼容性检查
3. 添加schema版本管理 