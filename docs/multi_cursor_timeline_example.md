# 多游标时间线管理使用示例

## 🎯 核心概念

### 基本场景

```
用户进入聊天室的时间线管理过程：

时间线: ═══════════════════════════════════════════════════════════════
       T1         T2        T3        T4         T5         T6
       │          │         │         │          │          │
    历史消息100条   │      进入房间    空档开始   空档结束   当前时间
       │          │         │         │          │          │
       └─历史段1───┘      【用户进入】   └─空档段─┘   └新消息段┘
       已同步=true                    已同步=false   已同步=true
```

## 📊 使用示例

### 1. 初始化时间线管理器

```dart
final timelineManager = MessageTimelineManager(
  conversationId: 'conv_123',
  autoSyncEnabled: true,
  preloadHours: 24,      // 预加载24小时范围
  maxGapHours: 1,        // 超过1小时才算空档
);
```

### 2. 用户进入聊天室 - 添加历史消息段

```dart
// 用户进入时，加载最近100条消息
// 假设最近消息时间范围：2024-01-15 10:00 ~ 2024-01-15 14:00
final historyStart = MessageCursor.fromMessageData(
  'msg_history_start', 
  DateTime(2024, 1, 15, 10, 0)
);
final historyEnd = MessageCursor.fromMessageData(
  'msg_history_end', 
  DateTime(2024, 1, 15, 14, 0)
);

timelineManager.addHistorySegment(
  startCursor: historyStart,
  endCursor: historyEnd,
  messageCount: 100,
  isSynced: true,  // 已经加载了这些消息
);
```

### 3. 开始实时接收消息段

```dart
// 从进入房间的时间开始接收实时消息
// 假设当前时间：2024-01-15 16:00
final realtimeStart = MessageCursor.fromMessageData(
  'msg_realtime_start', 
  DateTime(2024, 1, 15, 16, 0)
);
final realtimeEnd = MessageCursor.fromMessageData(
  'msg_realtime_current', 
  DateTime.now()
);

timelineManager.addRealtimeSegment(
  startCursor: realtimeStart,
  endCursor: realtimeEnd,
  messageCount: 5,  // 目前收到5条新消息
);
```

### 4. 自动检测空档

```dart
// 系统会自动检测到 14:00 ~ 16:00 之间有空档
final gaps = timelineManager.detectGaps();
print('发现 ${gaps.length} 个空档需要同步');

// 输出：发现 1 个空档需要同步
// 空档详情：
// - 类型：gap
// - 时间范围：14:00 ~ 16:00
// - 时长：2小时
// - 优先级：10（高优先级）
```

### 5. 智能同步策略

```dart
// 获取下一个需要同步的目标
final nextTarget = timelineManager.getNextSyncTarget();
if (nextTarget != null) {
  print('下一个同步目标：${nextTarget.type} - ${nextTarget.timeSpanHuman}');
  
  // 模拟同步过程
  await syncMessages(nextTarget);
  
  // 标记为已同步
  timelineManager.markAsSynced(
    nextTarget.id, 
    actualMessageCount: 25  // 实际同步到25条消息
  );
}
```

### 6. 预加载策略

```dart
// 获取需要预加载的目标
final preloadTargets = timelineManager.getPreloadTargets();
print('预加载目标数量：${preloadTargets.length}');

for (final target in preloadTargets) {
  if (target.priority >= 8) {  // 只预加载高优先级的
    // 后台异步预加载
    _preloadMessagesInBackground(target);
  }
}
```

### 7. 时间线优化

```dart
// 合并相邻的兼容游标对
timelineManager.optimizeTimeline();

// 获取优化后的统计信息
final stats = timelineManager.getStats();
print('时间线统计：$stats');
```

## 🔧 高级用法

### 手动添加空档

```dart
// 用户手动滚动到某个时间段，发现需要加载更多消息
final manualGap = MessageCursorPair.gap(
  conversationId: 'conv_123',
  startCursor: MessageCursor.fromMessageData('gap_start', DateTime(2024, 1, 14, 0, 0)),
  endCursor: MessageCursor.fromMessageData('gap_end', DateTime(2024, 1, 14, 12, 0)),
  priority: 15,  // 用户手动请求，设置更高优先级
  metadata: {
    'trigger': 'user_scroll',
    'urgency': 'high',
  },
);
```

### 时间线状态持久化

```dart
// 导出时间线状态（保存到本地）
final timelineData = timelineManager.exportTimeline();
await saveTimelineToLocal(conversationId, timelineData);

// 恢复时间线状态（从本地加载）
final savedData = await loadTimelineFromLocal(conversationId);
timelineManager.importTimeline(savedData);
```

### 智能优先级调整

```dart
// 根据用户行为动态调整优先级
void adjustPriorityBasedOnUserBehavior() {
  final stats = timelineManager.getStats();
  
  // 如果空档太多，提高空档同步优先级
  if (stats.gapPairs > 3) {
    // 重新评估优先级逻辑
  }
  
  // 如果用户频繁滚动，提高预加载优先级
  if (userScrollFrequency > threshold) {
    // 增加预加载范围
  }
}
```

## 📈 监控和调试

### 实时统计

```dart
void printTimelineStatus() {
  final stats = timelineManager.getStats();
  
  print('=== 时间线状态 ===');
  print('总游标对：${stats.totalPairs}');
  print('已同步：${stats.syncedPairs}');
  print('待同步空档：${stats.gapPairs}');
  print('总消息数：${stats.totalMessages}');
  print('时间覆盖率：${stats.coveragePercentage.toStringAsFixed(1)}%');
  print('同步进度：${stats.syncProgress.toStringAsFixed(1)}%');
}
```

### 可视化展示

```dart
void visualizeTimeline() {
  final pairs = timelineManager._getSortedPairs();
  
  print('时间线可视化：');
  for (final pair in pairs) {
    final status = pair.isSynced ? '✅' : '❌';
    final type = pair.type.description;
    print('$status [$type] ${pair.timeSpanHuman} (${pair.messageCount ?? '?'} 条消息)');
  }
}

// 输出示例：
// ✅ [历史消息段] 4小时 (100 条消息)
// ❌ [空档段] 2小时 (? 条消息)  
// ✅ [实时消息段] 30分钟 (5 条消息)
```

## 🎯 最佳实践

### 1. 分层同步策略
```
优先级 15+：用户当前查看区域的空档
优先级 10+：自动检测的重要空档
优先级 5+：历史消息段的补充
优先级 1+：预加载和后台同步
```

### 2. 性能优化
- 限制同时进行的同步任务数量
- 根据网络状况调整同步频率
- 智能合并小的相邻空档

### 3. 用户体验
- 空档显示加载占位符
- 同步进度实时反馈
- 失败重试和错误提示

这个多游标系统让你可以：
✅ **精确管理**时间线上的每个消息段
✅ **智能检测**和填补空档
✅ **优先级驱动**的同步策略
✅ **性能优化**的预加载机制
✅ **用户友好**的渐进式加载体验 