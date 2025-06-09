# 精确的进入会话逻辑（修正版）

## 核心原则

1. **不满一页的新消息 = 自动连续**（无需检查连续性）
2. **满一页+的新消息 = 需要检查连续性**
3. **未读场景需要双重连续性检查**：本地→未读，未读内部
4. **服务器填补仅在特定条件下进行**

## 三大场景详细逻辑

### 场景1：无本地消息（首次进入）

```dart
async enterFirstTime(String conversationId) {
  final result = await requestInitialMessages(conversationId);
  displayMessages(result.messages);
  // 简单场景，无需复杂判断
}
```

### 场景2：有消息+无未读

```dart
async enterWithoutUnread(String conversationId) {
  // 1. 发送本地最新游标
  final localCursor = getLocalLatestCursor(conversationId);
  
  // 2. 服务器返回所有新消息（不做任何填补）
  final newMessages = await requestNewMessages(conversationId, localCursor);
  
  if (newMessages.isEmpty) {
    // 无新消息：显示本地最新在底部
    showLocalLatestAtBottom();
    return;
  }
  
  // 3. 根据新消息数量判断
  if (newMessages.length < PAGE_SIZE) {
    // 不满一页 = 自动连续
    displayNewMessages(newMessages);
    setNormalMode(); // 常规上拉加载
  } else {
    // 满一页+ = 检查连续性
    if (isContinuous(localCursor, newMessages)) {
      displayNewMessages(newMessages);
      setNormalMode();
    } else {
      enterMultiCursorMode();
      displayNewMessagesWithGapIndicator(newMessages);
      // 上拉时填补空档
    }
  }
}
```

### 场景3：有消息+有未读

```dart
async enterWithUnread(String conversationId) {
  // 1. 发送本地游标，请求未读消息
  final localCursor = getLocalLatestCursor(conversationId);
  final unreadResult = await requestUnreadMessages(conversationId, localCursor);
  
  // 2. 双重连续性检查
  final isLocalToUnreadContinuous = isContinuous(
    localCursor, 
    unreadResult.firstUnreadCursor
  );
  
  if (isLocalToUnreadContinuous) {
    // 连续：按正常未读逻辑显示
    displayUnreadNormally(unreadResult.messages);
  } else {
    // 不连续：根据未读数量决定策略
    if (unreadResult.messages.length >= PAGE_SIZE) {
      // 满一页+：多游标模式
      enterMultiCursorMode();
      displayUnreadWithGapIndicator(unreadResult.messages);
    } else {
      // 不满一页：请求服务器填补空档
      final filledResult = await requestFillGap(
        localCursor,
        unreadResult.firstUnreadCursor,
        unreadResult.messages
      );
      displayContinuousMessages(filledResult.messages);
    }
  }
}
```

## 服务器端逻辑

### 场景2：返回新消息
```dart
// 服务器不做填补，只返回新消息
class NewMessagesResponse {
  List<Message> newMessages;      // 从客户端游标到最新的所有消息
  bool hasMore;                   // 是否还有更多历史消息
  MessageCursor latestCursor;     // 最新消息游标
}
```

### 场景3：返回未读消息
```dart
// 情况A：未读与本地连续
class UnreadMessagesResponse {
  List<Message> unreadMessages;   // 所有未读消息
  MessageCursor firstUnreadCursor; // 第一条未读消息游标
  bool isContinuous;              // 与客户端游标是否连续
}

// 情况B：未读与本地不连续且不满一页时，服务器填补
class FilledUnreadResponse {
  List<Message> gapMessages;      // 空档期消息
  List<Message> unreadMessages;   // 未读消息
  bool isComplete;                // 是否填补完整
}
```

## 连续性判断算法

```dart
bool isContinuous(MessageCursor clientCursor, dynamic serverData) {
  // 1. 时间戳连续性（容差1分钟）
  final timeDiff = serverData.timestamp.difference(clientCursor.timestamp);
  if (timeDiff.inMinutes > 1) {
    return false;
  }
  
  // 2. 消息ID连续性（如果有序列号）
  if (hasSequenceNumbers()) {
    return isSequenceContinuous(clientCursor.messageId, serverData.messageId);
  }
  
  // 3. 消息密度检查（可选）
  final expectedMessageCount = estimateMessageCount(timeDiff);
  final actualGap = calculateActualGap(clientCursor, serverData);
  
  return actualGap <= expectedMessageCount * 1.2; // 允许20%误差
}
```

## 多游标状态管理

```dart
class MultiCursorManager {
  bool isMultiCursorMode = false;
  List<MessageGap> knownGaps = [];
  
  void enterMultiCursorMode(MessageGap primaryGap) {
    isMultiCursorMode = true;
    knownGaps.add(primaryGap);
    showGapIndicator();
  }
  
  Future<void> fillNextGap() async {
    if (knownGaps.isEmpty) return;
    
    final gap = knownGaps.removeAt(0);
    final gapMessages = await loadGapMessages(gap);
    insertMessagesAtCorrectPosition(gapMessages);
    
    if (knownGaps.isEmpty) {
      exitMultiCursorMode();
    }
  }
  
  void exitMultiCursorMode() {
    isMultiCursorMode = false;
    knownGaps.clear();
    hideGapIndicator();
  }
}
```

## 关键差异总结

| 场景 | 消息量 | 连续性检查 | 服务器行为 | 客户端行为 |
|------|--------|------------|------------|------------|
| 无未读-不满页 | < PAGE_SIZE | ❌ 跳过 | 返回所有新消息 | 自动连续显示 |
| 无未读-满页+ | ≥ PAGE_SIZE | ✅ 检查 | 返回所有新消息 | 连续性判断 |
| 有未读-连续 | 任意 | ✅ 通过 | 返回未读消息 | 正常未读显示 |
| 有未读-不连续-满页+ | ≥ PAGE_SIZE | ❌ 失败 | 返回未读消息 | 多游标模式 |
| 有未读-不连续-不满页 | < PAGE_SIZE | ❌ 失败 | 填补+返回 | 连续显示 |

这样的设计更加精确和高效！✨ 