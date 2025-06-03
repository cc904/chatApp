# 聊天页面滚动位置优化

## 问题描述

原始实现中，`_updateCurrentScrollPosition`方法被频繁调用，导致`ChatCubit.updateCurrentScrollPosition`方法也被频繁调用，引起以下问题：

1. **滚动监听器过于敏感**：每次滚动都会立即触发位置更新
2. **状态频繁更新**：`emit(state.copyWith(...))` 被频繁调用
3. **时间戳导致状态不等**：`CurrentScrollPosition.fromAnchor`中的`timestamp: DateTime.now()`每次都产生新的时间戳

## 优化方案

### 1. 防抖机制（Debouncing）

在`_onScrollPositionChanged`方法中添加200ms的防抖延迟：

```dart
// 使用防抖机制，避免过于频繁的位置更新
_scrollUpdateTimer?.cancel();
_scrollUpdateTimer = Timer(const Duration(milliseconds: 200), () {
  _updateCurrentScrollPosition();
});
```

### 2. 位置变化检测

记录上次更新的位置信息，只有在位置发生实际变化时才更新状态：

```dart
// 检查位置是否发生了实际变化
if (_lastUpdatedMessageId == message.messageId && 
    _lastUpdatedMessageIndex == centerPosition.index) {
  // 位置没有变化，不需要更新状态
  return;
}
```

### 3. 移除时间戳比较

从`CurrentScrollPosition`的`props`中移除`timestamp`，避免因时间戳导致的状态对象不等：

```dart
@override
List<Object?> get props => [
  messageId,
  messageIndex,
  relativePosition,
  scrollOffset,
  // 移除timestamp，避免因时间戳导致的频繁状态更新
];
```

### 4. 优化方法签名

添加`updateCurrentScrollPositionDirect`方法，支持直接传递参数而不需要重新计算位置：

```dart
void updateCurrentScrollPositionDirect({
  required String messageId,
  required int messageIndex,
  double? relativePosition,
}) {
  // 只有当位置确实发生变化时才更新状态
  final existingPosition = state.currentScrollPosition;
  if (existingPosition.messageId != messageId || 
      existingPosition.messageIndex != messageIndex) {
    emit(state.copyWith(currentScrollPosition: currentScrollPosition));
  }
}
```

### 5. 分离已读消息处理

将已读消息标记逻辑从滚动位置更新中分离出来，避免耦合：

```dart
/// 更新已读消息状态（从滚动位置更新中分离出来）
void _updateReadMessages(List<ItemPosition> sortedPositions) {
  // 独立处理已读消息逻辑
}
```

## 优化效果

1. **减少状态更新频率**：通过防抖和变化检测，大幅减少不必要的状态更新
2. **提升滚动性能**：减少UI重建次数，提升滚动流畅度
3. **降低CPU占用**：减少重复计算和状态比较
4. **保持功能完整**：确保滚动位置恢复和已读消息标记功能正常工作

## 使用注意事项

1. 防抖延迟设置为200ms，在响应性和性能之间取得平衡
2. 已读消息标记不使用防抖，确保及时响应
3. 历史消息加载检查也不使用防抖，保证滚动体验
4. 调试日志可以帮助监控优化效果，生产环境可移除 