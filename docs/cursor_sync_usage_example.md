# 双向游标同步模式使用指南

## 概述

双向游标同步模式是一个高效、精确的消息同步机制，用于替代之前复杂的按日期同步和未读消息同步模式。它支持四种同步方向：

- **INITIAL_LOAD**: 初始加载（首次进入会话）
- **CURSOR_FORWARD**: 向前游标同步（获取新消息）
- **CURSOR_BACKWARD**: 向后游标同步（获取历史消息）
- **CURSOR_AROUND**: 双向游标同步（获取上下文消息）

## 核心概念

### MessageCursor（消息游标）

```dart
// 创建空游标
final emptyCursor = MessageCursor.empty;

// 从消息数据创建游标
final cursor = MessageCursor.fromMessageData(messageId, timestamp);

// 带自定义位置的游标
final cursor = MessageCursor(
  messageId: 'msg123',
  timestamp: DateTime.now(),
  position: 'custom_position',
);
```

### CursorSyncResult（同步结果）

```dart
// 成功结果
final result = CursorSyncResult.success(
  conversationId: 'conv123',
  returnedCount: 20,
  hasMoreBefore: true,
  hasMoreAfter: false,
);

// 失败结果
final result = CursorSyncResult.failure(
  conversationId: 'conv123',
  errorMessage: '网络错误',
);
```

## 使用场景

### 1. 初始进入会话

```dart
// 当用户首次打开会话时
final result = await chatRepository.syncMessagesInitial(
  conversationId,
  limit: 20, // 加载最新20条消息
);

if (result.success) {
  print('初始消息加载成功，获得 ${result.returnedCount} 条消息');
}
```

### 2. 加载历史消息（向上滚动）

```dart
// 用户向上滚动查看历史消息
final localCursor = await chatRepository.getLocalCursor(conversationId);

final result = await chatRepository.syncMessagesBackward(
  conversationId,
  cursor: localCursor.isEmpty ? null : localCursor,
  limit: 20,
);

if (result.success && result.hasMoreBefore) {
  print('还有更多历史消息可以加载');
}
```

### 3. 获取新消息（自动同步）

```dart
// 定期检查新消息或断线重连后同步
final syncCursor = await chatRepository.getSyncCursor(conversationId);

final result = await chatRepository.syncMessagesForward(
  conversationId,
  cursor: syncCursor.isEmpty ? null : syncCursor,
  limit: 50,
);

if (result.success) {
  // 更新同步游标
  if (result.nextCursor != null) {
    await chatRepository.updateSyncCursor(
      conversationId, 
      result.nextCursor!,
    );
  }
}
```

### 4. 搜索结果跳转（上下文加载）

```dart
// 用户点击搜索结果，跳转到特定消息并显示上下文
final targetCursor = MessageCursor.fromMessageData(
  searchResultMessageId,
  searchResultTimestamp,
);

final result = await chatRepository.syncMessagesAround(
  conversationId,
  cursor: targetCursor,
  beforeCount: 10, // 目标消息前10条
  afterCount: 10,  // 目标消息后10条
  includeCursor: true, // 包含目标消息本身
);

if (result.success) {
  print('获得上下文消息：${result.returnedCount} 条');
}
```

## 游标管理

### 本地游标（Local Cursor）

本地游标表示用户当前查看的消息位置，用于：
- 恢复用户的阅读位置
- 向后加载历史消息的起点

```dart
// 获取本地游标
final localCursor = await chatRepository.getLocalCursor(conversationId);

// 更新本地游标（用户滚动时）
await chatRepository.updateLocalCursor(
  conversationId,
  MessageCursor.fromMessageData(currentMessageId, currentTimestamp),
);
```

### 同步游标（Sync Cursor）

同步游标表示已同步的最新消息位置，用于：
- 获取新消息的起点
- 避免重复同步

```dart
// 获取同步游标
final syncCursor = await chatRepository.getSyncCursor(conversationId);

// 更新同步游标（收到新消息后）
await chatRepository.updateSyncCursor(
  conversationId,
  MessageCursor.fromMessageData(latestMessageId, latestTimestamp),
);
```

## 最佳实践

### 1. 智能同步策略

```dart
Future<void> smartSync(String conversationId) async {
  // 检查是否有本地消息
  final hasLocal = await chatRepository.hasLocalMessages(conversationId);
  
  if (!hasLocal) {
    // 无本地消息，执行初始加载
    await chatRepository.syncMessagesInitial(conversationId);
  } else {
    // 有本地消息，只获取新消息
    await chatRepository.syncMessagesForward(conversationId);
  }
}
```

### 2. 分页加载

```dart
Future<void> loadMoreHistory(String conversationId) async {
  final localCursor = await chatRepository.getLocalCursor(conversationId);
  
  final result = await chatRepository.syncMessagesBackward(
    conversationId,
    cursor: localCursor,
    limit: 20,
  );
  
  if (result.success) {
    // 更新本地游标到更早的位置
    if (result.prevCursor != null) {
      await chatRepository.updateLocalCursor(
        conversationId,
        result.prevCursor!,
      );
    }
    
    // 检查是否还有更多历史消息
    if (!result.hasMoreBefore) {
      print('已到达会话开始');
    }
  }
}
```

### 3. 错误处理

```dart
Future<void> syncWithRetry(String conversationId) async {
  int retryCount = 0;
  const maxRetries = 3;
  
  while (retryCount < maxRetries) {
    final result = await chatRepository.syncMessagesForward(conversationId);
    
    if (result.success) {
      break;
    }
    
    retryCount++;
    if (retryCount < maxRetries) {
      await Future.delayed(Duration(seconds: retryCount * 2));
    }
  }
}
```

## 性能优化

1. **批量同步**: 对多个会话进行批量同步时，使用合理的并发限制
2. **缓存策略**: 利用游标信息避免重复请求
3. **增量更新**: 只同步真正需要的消息，避免全量同步
4. **智能预加载**: 根据用户行为预测性地加载消息

## 向后兼容

现有的同步方法标记为 `@Deprecated` 但仍然可用：

```dart
// 旧方法（将被废弃）
@Deprecated('请使用新的游标同步方法')
Future<void> syncRecentMessages(String conversationId) async {
  // 旧的实现...
}

// 新方法
Future<void> syncMessages(String conversationId) async {
  await chatRepository.syncMessagesForward(conversationId);
}
```

## 总结

双向游标同步模式提供了：

- ✅ **精确定位**: 基于消息ID和时间戳的精确游标
- ✅ **灵活方向**: 支持前向、后向、双向同步
- ✅ **高效性能**: 避免重复和不必要的数据传输
- ✅ **易于使用**: 简洁的API设计
- ✅ **可扩展性**: 支持未来功能扩展

这种模式大大简化了消息同步逻辑，提高了用户体验和系统性能。 