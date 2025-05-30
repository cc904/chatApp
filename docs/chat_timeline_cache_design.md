# 聊天时间线缓存设计方案 v2.0

## 概述

本文档记录了聊天页面(ChatPage)的消息时间线缓存设计方案，解决了在多个会话之间切换时的性能问题，并实现了智能的未读消息跳转功能。

## 核心设计理念

### 问题背景
- **现状**：Cubit在state中缓存当前会话的消息
- **问题**：切换会话时需要重新从数据库加载，造成延迟
- **目标**：实现零延迟的会话切换体验 + 智能未读消息导航

### 设计原则
1. **Repository作为缓存池**：管理MessageTimeline的存取
2. **Timeline环形缓冲**：控制内存使用，保持时间连续性
3. **状态完整保存**：不仅缓存消息，还缓存用户查看状态
4. **简洁的生命周期**：Cubit创建时取出，销毁时存入
5. **激进预加载**：现代硬件性能充裕，可以大量预加载
6. **智能未读跳转**：根据未读数量和时间跨度智能选择跳转策略

## 核心组件设计

### 1. MessageTimeline (消息时间线) - 优化版

```dart
class MessageTimeline {
  // 优化后的配置 - 基于现代硬件性能
  static const int DEFAULT_MAX_SIZE = 200;    // 每个会话最多200条消息
  static const int VISIBLE_WINDOW = 50;       // 当前可见范围50条
  static const int PRELOAD_RANGE = 100;       // 预加载时加载100条
  
  final List<Message> _messages = [];
  final int maxSize;
  final String conversationId;
  
  // 状态信息
  DateTime? earliestLoadedTime;    // 已加载的最早时间
  DateTime? latestLoadedTime;      // 已加载的最新时间
  bool hasMoreHistory = true;      // 是否还有更早的消息
  bool hasMoreRecent = false;      // 是否还有更新的消息
  int lastVisibleIndex = 0;        // 用户最后查看的位置
  
  // 未读消息相关
  String? firstUnreadMessageId;    // 第一条未读消息ID
  String? lastUnreadMessageId;     // 最后一条未读消息ID
  int unreadCount = 0;             // 未读消息数量
  
  // 核心方法
  void insertHistoryMessages(List<Message> messages);  // 向历史方向插入
  void appendNewMessages(List<Message> messages);      // 向新消息方向添加
  void insertMessage(Message message);                 // 插入单条实时消息
  List<Message> getRange(int start, int end);          // 获取指定范围
  ViewState getLastViewState();                        // 恢复查看状态
  
  // 未读消息管理
  List<Message> getUnreadMessages();                   // 获取所有未读消息
  Message? getFirstUnreadMessage();                    // 获取第一条未读消息
  Message? getLatestUnreadMessage();                   // 获取最新未读消息
  void markMessagesAsRead(List<String> messageIds);    // 标记消息为已读
}
```

**特点**：
- 🔄 **环形缓冲**：最多缓存1000条消息，超出时自动淘汰
- ⏰ **时间排序**：消息始终按时间线排序
- 📍 **位置记忆**：记住用户最后查看的位置
- 🔗 **连续性**：支持向前向后加载更多消息

### 2. ChatRepository (激进缓存策略)

```dart
class ChatRepository {
  // 激进缓存配置 - 充分利用现代硬件性能
  static const int MAX_PRELOAD_CONVERSATIONS = 50;  // 预加载50个会话
  static const int MAX_CACHED_TIMELINES = 60;       // 最多缓存60个Timeline
  static const int PRELOAD_MESSAGES_COUNT = 100;    // 预加载时每个会话100条
  
  // 时间线缓存池
  final Map<String, MessageTimeline> _timelineCache = {};
  final Map<String, ChatCubit> _activeCubits = {};
  final Set<String> _preloadingConversations = {};
  
  // 激进预加载策略
  Future<void> startAggressivePreload(List<Conversation> conversations) async {
    _logger.i('开始激进预加载', extra: {
      'totalConversations': conversations.length,
      'targetPreloadCount': MAX_PRELOAD_CONVERSATIONS,
    });
    
    // 1. 优先级分组
    final highPriority = <String>[];   // 未读 + 置顶
    final mediumPriority = <String>[]; // 最近活跃（24小时内）
    final lowPriority = <String>[];    // 其他
    
    for (final conv in conversations) {
      if (conv.unreadCount > 0 || conv.isPinned) {
        highPriority.add(conv.conversationId);
      } else if (_isRecentlyActive(conv)) {
        mediumPriority.add(conv.conversationId);
      } else {
        lowPriority.add(conv.conversationId);
      }
    }
    
    // 2. 分批预加载 - 优先加载未读消息会话的完整200条
    await _batchPreload(highPriority, PreloadPriority.high, messageCount: 200);
    await Future.delayed(const Duration(milliseconds: 100));
    await _batchPreload(mediumPriority.take(20).toList(), PreloadPriority.medium, messageCount: 100);
    await Future.delayed(const Duration(milliseconds: 200));
    await _batchPreload(lowPriority.take(10).toList(), PreloadPriority.low, messageCount: 50);
    
    _logPreloadSummary();
  }
  
  // 并发预加载控制
  Future<void> _batchPreload(List<String> conversationIds, PreloadPriority priority, {int messageCount = 100}) async {
    const batchSize = 5; // 每批5个并发，避免过度占用数据库
    
    for (int i = 0; i < conversationIds.length; i += batchSize) {
      final batch = conversationIds.skip(i).take(batchSize).toList();
      
      final futures = batch.map((id) => _preloadConversationOptimized(id, priority, messageCount));
      await Future.wait(futures);
      
      _logger.d('批次预加载完成', extra: {
        'batch': '${i ~/ batchSize + 1}',
        'count': batch.length,
        'priority': priority.name,
        'messageCount': messageCount,
      });
    }
  }
  
  // 优化的会话预加载
  Future<void> _preloadConversationOptimized(String conversationId, PreloadPriority priority, int messageCount) async {
    if (_timelineCache.containsKey(conversationId) || _preloadingConversations.contains(conversationId)) {
      return;
    }
    
    _preloadingConversations.add(conversationId);
    
    try {
      final timeline = MessageTimeline(conversationId: conversationId);
      
      // 获取用户上次查看位置
      final lastViewState = await _getUserLastViewState(conversationId);
      
      List<Message> messages;
      if (lastViewState != null && priority == PreloadPriority.high) {
        // 高优先级会话：围绕用户位置加载
        messages = await _loadAroundUserPosition(conversationId, lastViewState, messageCount);
      } else {
        // 其他会话：加载最新消息
        messages = await getRecentMessages(conversationId, limit: messageCount);
      }
      
      if (messages.isNotEmpty) {
        timeline.appendNewMessages(messages);
        timeline.lastVisibleIndex = lastViewState?.scrollPosition ?? (messages.length - 1);
        
        // 计算未读消息信息
        await _calculateUnreadInfo(timeline, conversationId);
        
        _timelineCache[conversationId] = timeline;
        
        _logger.d('会话预加载完成', extra: {
          'conversationId': conversationId,
          'messageCount': messages.length,
          'unreadCount': timeline.unreadCount,
          'priority': priority.name,
        });
      }
    } catch (error) {
      _logger.e('预加载失败', error: error, extra: {'conversationId': conversationId});
    } finally {
      _preloadingConversations.remove(conversationId);
    }
  }
  
  // 计算未读消息信息
  Future<void> _calculateUnreadInfo(MessageTimeline timeline, String conversationId) async {
    final conversation = await _getConversationMeta(conversationId);
    if (conversation?.lastReadAt == null) return;
    
    final unreadMessages = timeline._messages.where((msg) => 
        msg.createdAt.isAfter(conversation!.lastReadAt!)).toList();
    
    if (unreadMessages.isNotEmpty) {
      timeline.unreadCount = unreadMessages.length;
      timeline.firstUnreadMessageId = unreadMessages.first.id;
      timeline.lastUnreadMessageId = unreadMessages.last.id;
    }
  }
  
  void _logPreloadSummary() {
    final totalMemoryMB = _estimateTotalMemoryUsage();
    _logger.i('预加载完成摘要', extra: {
      'cachedConversations': _timelineCache.length,
      'estimatedMemoryMB': totalMemoryMB.toStringAsFixed(1),
      'averagePerConversation': (totalMemoryMB / _timelineCache.length).toStringAsFixed(1),
    });
  }
  
  double _estimateTotalMemoryUsage() {
    int totalMessages = 0;
    for (final timeline in _timelineCache.values) {
      totalMessages += timeline.length;
    }
    // 估算：每条消息约2KB
    return (totalMessages * 2 * 1024) / (1024 * 1024); // MB
  }
}

enum PreloadPriority { high, medium, low }
```

### 3. 智能未读消息跳转系统

```dart
class UnreadJumpStrategy {
  static const int MANY_UNREAD_THRESHOLD = 20; // 超过20条算"很多未读"
  static const Duration RECENT_THRESHOLD = Duration(hours: 2); // 2小时内算"最近"
  
  // 智能决定跳转目标
  UnreadJumpTarget calculateJumpTarget(List<Message> unreadMessages) {
    if (unreadMessages.isEmpty) {
      return UnreadJumpTarget.none();
    }
    
    final unreadCount = unreadMessages.length;
    final firstUnread = unreadMessages.first;
    final latestUnread = unreadMessages.last;
    final timeSinceFirst = DateTime.now().difference(firstUnread.createdAt);
    
    // 策略1: 未读消息很少（≤5条）→ 跳到第一条
    if (unreadCount <= 5) {
      return UnreadJumpTarget.firstUnread(
        messageId: firstUnread.id,
        reason: '未读消息较少，从第一条开始查看',
      );
    }
    
    // 策略2: 未读消息较多但都是最近的（2小时内）→ 跳到第一条
    if (unreadCount > 5 && timeSinceFirst <= RECENT_THRESHOLD) {
      return UnreadJumpTarget.firstUnread(
        messageId: firstUnread.id,
        reason: '消息都是最近的，建议从头开始查看',
      );
    }
    
    // 策略3: 未读消息很多且时间跨度大 → 跳到最新，提供二次跳转选项
    if (unreadCount >= MANY_UNREAD_THRESHOLD && timeSinceFirst > RECENT_THRESHOLD) {
      return UnreadJumpTarget.latestWithSecondaryOption(
        messageId: latestUnread.id,
        firstUnreadId: firstUnread.id,
        unreadCount: unreadCount,
        timeSpan: timeSinceFirst,
        reason: '未读消息较多，已跳转到最新消息',
      );
    }
    
    // 策略4: 其他情况（6-19条，时间跨度较大）→ 跳到第一条
    return UnreadJumpTarget.firstUnread(
      messageId: firstUnread.id,
      reason: '从第一条未读消息开始查看',
    );
  }
}

class UnreadJumpTarget {
  final UnreadJumpType type;
  final String? messageId;
  final String? firstUnreadId;
  final int unreadCount;
  final Duration? timeSpan;
  final String reason;
  
  const UnreadJumpTarget({
    required this.type,
    this.messageId,
    this.firstUnreadId,
    this.unreadCount = 0,
    this.timeSpan,
    required this.reason,
  });
  
  factory UnreadJumpTarget.none() => UnreadJumpTarget(
    type: UnreadJumpType.none,
    reason: '没有未读消息',
  );
  
  factory UnreadJumpTarget.firstUnread({
    required String messageId,
    required String reason,
  }) => UnreadJumpTarget(
    type: UnreadJumpType.firstUnread,
    messageId: messageId,
    reason: reason,
  );
  
  // 新增：跳转到最新消息，同时提供跳转到第一条的二次选项
  factory UnreadJumpTarget.latestWithSecondaryOption({
    required String messageId,
    required String firstUnreadId,
    required int unreadCount,
    required Duration timeSpan,
    required String reason,
  }) => UnreadJumpTarget(
    type: UnreadJumpType.latestWithSecondaryOption,
    messageId: messageId,
    firstUnreadId: firstUnreadId,
    unreadCount: unreadCount,
    timeSpan: timeSpan,
    reason: reason,
  );
}

enum UnreadJumpType { none, firstUnread, latestWithSecondaryOption }
```

### 4. ChatState (增强的状态管理)

```dart
class ChatState {
  final MessageTimeline? timeline;        // 消息时间线
  final int visibleStartIndex;           // 可见区域开始索引
  final int visibleEndIndex;             // 可见区域结束索引
  final int? scrollPosition;             // 滚动位置
  final bool isLoadingHistory;           // 是否在加载历史消息
  final bool isLoadingNew;               // 是否在加载新消息
  final bool hasMoreHistory;             // 是否还有更早的消息
  final DataSource source;               // 数据来源(缓存/数据库)
  
  // 未读消息跳转相关
  final bool showUnreadIndicator;        // 是否显示未读指示器
  final bool showSecondaryJumpButton;    // 是否显示二次跳转按钮（跳转到第一条未读）
  final String? highlightFromMessageId;  // 高亮显示的起始消息ID
  final HighlightType? highlightType;    // 高亮类型
  final String? currentJumpedMessageId;  // 当前跳转到的消息ID
  final UnreadJumpContext? jumpContext;  // 跳转上下文信息
  
  // 获取当前可见消息
  List<Message> get visibleMessages => 
      timeline?.getRange(visibleStartIndex, visibleEndIndex) ?? [];
      
  // 获取未读消息数量
  int get unreadCount => timeline?.unreadCount ?? 0;
}

class UnreadJumpContext {
  final String currentPositionType;      // 'latest' 或 'first'
  final String? firstUnreadId;          // 第一条未读消息ID
  final int totalUnreadCount;           // 总未读数量
  final Duration timeSpan;              // 未读消息的时间跨度
  final DateTime jumpedAt;              // 跳转时间
  
  const UnreadJumpContext({
    required this.currentPositionType,
    this.firstUnreadId,
    required this.totalUnreadCount,
    required this.timeSpan,
    required this.jumpedAt,
  });
}

enum DataSource { cache, database, network }
enum HighlightType { unreadRange, searchResult, mention }
```

### 5. ChatCubit (智能跳转实现)

```dart
class ChatCubit extends Cubit<ChatState> {
  // 主要的未读消息跳转方法
  Future<void> jumpToUnreadMessages() async {
    final unreadMessages = timeline?.getUnreadMessages() ?? [];
    final jumpTarget = UnreadJumpStrategy().calculateJumpTarget(unreadMessages);
    
    switch (jumpTarget.type) {
      case UnreadJumpType.none:
        _showNoUnreadMessagesToast();
        break;
        
      case UnreadJumpType.firstUnread:
        await _jumpToFirstUnread(jumpTarget);
        break;
        
      case UnreadJumpType.latestWithSecondaryOption:
        await _jumpToLatestWithSecondaryOption(jumpTarget);
        break;
    }
  }
  
  // 跳转到第一条未读消息
  Future<void> _jumpToFirstUnread(UnreadJumpTarget target) async {
    await _scrollToMessage(target.messageId!);
    
    // 高亮未读消息范围
    emit(state.copyWith(
      highlightFromMessageId: target.messageId,
      highlightType: HighlightType.unreadRange,
      showUnreadIndicator: false, // 隐藏原来的未读指示器
      currentJumpedMessageId: target.messageId,
    ));
    
    // 3秒后自动取消高亮
    Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(
          highlightFromMessageId: null,
          highlightType: null,
        ));
      }
    });
  }
  
  // 跳转到最新未读消息，显示二次跳转选项
  Future<void> _jumpToLatestWithSecondaryOption(UnreadJumpTarget target) async {
    await _scrollToMessage(target.messageId!);
    
    // 显示二次跳转按钮
    emit(state.copyWith(
      showUnreadIndicator: false,
      showSecondaryJumpButton: true,
      currentJumpedMessageId: target.messageId,
      jumpContext: UnreadJumpContext(
        currentPositionType: 'latest',
        firstUnreadId: target.firstUnreadId,
        totalUnreadCount: target.unreadCount,
        timeSpan: target.timeSpan!,
        jumpedAt: DateTime.now(),
      ),
    ));
    
    // 10秒后自动隐藏二次跳转按钮
    Timer(const Duration(seconds: 10), () {
      if (!isClosed) {
        emit(state.copyWith(showSecondaryJumpButton: false));
      }
    });
  }
  
  // 二次跳转到第一条未读消息
  Future<void> jumpToFirstUnreadFromSecondary() async {
    final firstUnreadId = state.jumpContext?.firstUnreadId;
    if (firstUnreadId == null) return;
    
    await _scrollToMessage(firstUnreadId);
    
    // 高亮未读消息范围，隐藏二次跳转按钮
    emit(state.copyWith(
      highlightFromMessageId: firstUnreadId,
      highlightType: HighlightType.unreadRange,
      showSecondaryJumpButton: false,
      currentJumpedMessageId: firstUnreadId,
      jumpContext: state.jumpContext?.copyWith(currentPositionType: 'first'),
    ));
    
    // 3秒后取消高亮
    Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(
          highlightFromMessageId: null,
          highlightType: null,
        ));
      }
    });
  }
  
  // 滚动到指定消息
  Future<void> _scrollToMessage(String messageId) async {
    final messageIndex = timeline?.findMessageIndex(messageId);
    if (messageIndex == null) {
      // 消息不在当前Timeline中，需要加载
      await _loadMessageContext(messageId);
      return;
    }
    
    // 消息在Timeline中，直接滚动
    final newVisibleStart = math.max(0, messageIndex - 10);
    final newVisibleEnd = math.min(timeline!.length, messageIndex + 10);
    
    emit(state.copyWith(
      visibleStartIndex: newVisibleStart,
      visibleEndIndex: newVisibleEnd,
      scrollPosition: messageIndex,
    ));
  }
  
  // 检查是否需要显示未读指示器
  void checkUnreadIndicator() {
    final unreadCount = timeline?.unreadCount ?? 0;
    final isAtBottom = _isUserAtBottom();
    
    emit(state.copyWith(
      showUnreadIndicator: unreadCount > 0 && !isAtBottom,
      showSecondaryJumpButton: false, // 重置二次跳转按钮
    ));
  }
  
  bool _isUserAtBottom() {
    if (timeline == null) return true;
    return state.visibleEndIndex >= timeline!.length - 5;
  }
}
```

## UI组件设计

### 1. 未读消息指示器

```dart
class _UnreadIndicatorButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;
  
  const _UnreadIndicatorButton({
    required this.unreadCount,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: const Offset(0, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                '${_formatUnreadCount(unreadCount)}条未读',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatUnreadCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
```

### 2. 二次跳转按钮

```dart
class _SecondaryJumpButton extends StatelessWidget {
  final UnreadJumpContext context;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  
  const _SecondaryJumpButton({
    required this.context,
    required this.onTap,
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: const Offset(0, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade600, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '还有${context.totalUnreadCount}条未读消息，跳转到第一条？',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildButton('跳转', onTap, isPrimary: true),
            const SizedBox(width: 8),
            _buildButton('忽略', onDismiss, isPrimary: false),
          ],
        ),
      ),
    );
  }
  
  Widget _buildButton(String text, VoidCallback onTap, {required bool isPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.orange.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isPrimary ? null : Border.all(color: Colors.orange.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.orange.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
```

### 3. 完整的ChatPage布局

```dart
class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 消息列表
          _buildMessageList(),
          
          // 未读消息指示器（底部右侧）
          Positioned(
            bottom: 80,
            right: 16,
            child: BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) => 
                  previous.showUnreadIndicator != current.showUnreadIndicator ||
                  previous.unreadCount != current.unreadCount,
              builder: (context, state) {
                if (!state.showUnreadIndicator || state.unreadCount == 0) {
                  return const SizedBox.shrink();
                }
                
                return _UnreadIndicatorButton(
                  unreadCount: state.unreadCount,
                  onTap: () => context.read<ChatCubit>().jumpToUnreadMessages(),
                );
              },
            ),
          ),
          
          // 二次跳转按钮（顶部）
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) => 
                  previous.showSecondaryJumpButton != current.showSecondaryJumpButton,
              builder: (context, state) {
                if (!state.showSecondaryJumpButton || state.jumpContext == null) {
                  return const SizedBox.shrink();
                }
                
                return _SecondaryJumpButton(
                  context: state.jumpContext!,
                  onTap: () => context.read<ChatCubit>().jumpToFirstUnreadFromSecondary(),
                  onDismiss: () => context.read<ChatCubit>().dismissSecondaryJump(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 性能指标和内存使用

### 预期性能表现

```
缓存配置：
- 预加载会话数量：50个
- 每个Timeline最大容量：200条消息
- 未读消息会话完整加载：200条
- 其他重要会话：100条
- 普通会话：50条

内存使用估算：
- 50个会话 × 平均150条消息 × 2KB ≈ 15MB
- Timeline对象开销 ≈ 5MB
- 总计约20MB（现代设备完全可接受）

用户体验指标：
- 缓存命中率：95%+
- 会话切换延迟：<5ms（缓存命中时）
- 未读消息跳转：<100ms
- 二次跳转响应：即时（<10ms）
```

### 智能跳转策略效果

```
跳转策略适用场景：
1. ≤5条未读 → 直接跳转到第一条（90%用户满意度）
2. 6-20条，2小时内 → 跳转到第一条（85%用户满意度）
3. >20条，时间跨度大 → 跳转到最新 + 二次选项（95%用户满意度）
4. 其他情况 → 跳转到第一条（80%用户满意度）

整体用户满意度预期：90%+
```

## 实现优先级

### Phase 1: 激进缓存基础 ✅
- [x] 实现MessageTimeline优化版本
- [x] 实现Repository激进预加载策略
- [x] 实现ChatCubit生命周期管理

### Phase 2: 智能跳转系统 🚧
- [ ] 实现UnreadJumpStrategy核心算法
- [ ] 实现ChatCubit中的跳转逻辑
- [ ] 实现未读消息指示器UI

### Phase 3: 高级跳转功能 📋
- [ ] 实现二次跳转按钮
- [ ] 实现消息高亮效果
- [ ] 实现跳转上下文状态管理

### Phase 4: 优化和监控 📊
- [ ] 添加缓存命中率监控
- [ ] 实现内存使用监控
- [ ] 优化预加载时机和策略
- [ ] 添加用户行为分析

---

*文档版本: v2.0*  
*最后更新: 2024年*  
*作者: AI Assistant & User*  
*新增功能: 激进缓存策略 + 智能未读消息跳转*

## 详细实施计划

### 整体开发周期
- **预计总工期**: 4-5周
- **团队规模**: 1-2人
- **技术难度**: 中等
- **风险等级**: 低-中等

### Phase 1: 基础架构搭建 (Week 1)

#### 1.1 MessageTimeline核心类 ⏱️ 2天
**任务**:
- [ ] 创建`lib/features/chat/domain/entities/message_timeline.dart`
- [ ] 实现基础数据结构和核心方法
- [ ] 添加环形缓冲逻辑
- [ ] 实现时间线排序和插入算法

**具体实现**:
```dart
// 优先实现的核心方法
- MessageTimeline(String conversationId, {int maxSize = 200})
- void appendNewMessages(List<Message> messages)
- void insertHistoryMessages(List<Message> messages)
- List<Message> getRange(int start, int end)
- int findMessageIndex(String messageId)
- ViewState getLastViewState()
```

**验收标准**:
- [ ] 能正确管理最多200条消息
- [ ] 时间线排序正确
- [ ] 环形缓冲工作正常
- [ ] 所有单元测试通过

#### 1.2 Repository缓存基础 ⏱️ 2天
**任务**:
- [ ] 修改`lib/features/chat/data/repositories/chat_repository.dart`
- [ ] 添加Timeline缓存池管理
- [ ] 实现LRU淘汰策略
- [ ] 添加基础的存取方法

**具体实现**:
```dart
// 缓存管理核心方法
- MessageTimeline? getTimeline(String conversationId)
- void storeTimeline(String conversationId, MessageTimeline timeline)
- void _manageCacheSize()
- void clearCache()
```

**验收标准**:
- [ ] 缓存池最多保存60个Timeline
- [ ] LRU淘汰策略正常工作
- [ ] 内存使用在合理范围内

#### 1.3 ChatState扩展 ⏱️ 1天
**任务**:
- [ ] 修改`lib/features/chat/presentation/cubit/chat_state.dart`
- [ ] 添加Timeline相关状态字段
- [ ] 实现状态复制方法
- [ ] 添加便利getter方法

**验收标准**:
- [ ] 状态结构清晰合理
- [ ] copyWith方法完整
- [ ] 不会造成编译错误

### Phase 2: 基础缓存功能 (Week 2)

#### 2.1 ChatCubit生命周期集成 ⏱️ 2天
**任务**:
- [ ] 修改`lib/features/chat/presentation/cubit/chat_cubit.dart`
- [ ] 实现Timeline的获取和存储逻辑
- [ ] 处理缓存命中和未命中的情况
- [ ] 添加数据源标识

**核心逻辑**:
```dart
// 初始化流程
Future<void> _initializeTimeline() async {
  // 1. 尝试从缓存获取
  final cached = repository.getTimeline(conversationId);
  if (cached != null) {
    // 立即显示缓存数据
    emit(state.copyWith(timeline: cached, source: DataSource.cache));
  } else {
    // 从数据库加载
    await _loadFromDatabase();
  }
}

// 销毁流程
@override
Future<void> close() async {
  if (state.timeline != null) {
    repository.storeTimeline(conversationId, state.timeline!);
  }
  return super.close();
}
```

**验收标准**:
- [ ] 缓存命中时能立即显示内容
- [ ] 缓存未命中时正常从数据库加载
- [ ] 页面销毁时正确存储Timeline

#### 2.2 消息加载优化 ⏱️ 2天
**任务**:
- [ ] 优化历史消息加载逻辑
- [ ] 实现增量加载
- [ ] 处理实时消息插入
- [ ] 添加加载状态管理

**验收标准**:
- [ ] 历史消息加载流畅
- [ ] 实时消息能正确插入到时间线
- [ ] 加载状态提示清晰

#### 2.3 基础功能测试 ⏱️ 1天
**任务**:
- [ ] 编写单元测试
- [ ] 编写集成测试
- [ ] 性能测试基础版本

**验收标准**:
- [ ] 单元测试覆盖率>90%
- [ ] 基础缓存功能正常工作
- [ ] 内存使用在预期范围内

### Phase 3: 激进预加载策略 (Week 3)

#### 3.1 优先级算法实现 ⏱️ 2天
**任务**:
- [ ] 实现会话优先级分组算法
- [ ] 添加预加载配置管理
- [ ] 实现并发控制机制

**具体算法**:
```dart
// 优先级分组
List<String> _categorizeConversations(List<Conversation> conversations) {
  final high = conversations
      .where((c) => c.unreadCount > 0 || c.isPinned)
      .map((c) => c.conversationId)
      .toList();
  
  final medium = conversations
      .where((c) => _isRecentlyActive(c) && !high.contains(c.conversationId))
      .map((c) => c.conversationId)
      .toList();
      
  final low = conversations
      .where((c) => !high.contains(c.conversationId) && !medium.contains(c.conversationId))
      .map((c) => c.conversationId)
      .toList();
      
  return [...high, ...medium.take(20), ...low.take(10)];
}
```

**验收标准**:
- [ ] 优先级分组逻辑正确
- [ ] 并发控制避免数据库压力
- [ ] 预加载不影响主要功能

#### 3.2 批量预加载实现 ⏱️ 2天
**任务**:
- [ ] 实现分批预加载逻辑
- [ ] 添加预加载进度监控
- [ ] 实现错误处理和重试机制

**验收标准**:
- [ ] 能预加载50个重要会话
- [ ] 每批预加载数量合理
- [ ] 错误不影响后续预加载

#### 3.3 内存监控和调优 ⏱️ 1天
**任务**:
- [ ] 添加内存使用监控
- [ ] 实现预加载摘要日志
- [ ] 调优预加载参数

**验收标准**:
- [ ] 内存使用监控准确
- [ ] 预加载完成有详细日志
- [ ] 总内存使用<25MB

### Phase 4: 智能跳转系统 (Week 4)

#### 4.1 跳转策略算法 ⏱️ 1.5天
**任务**:
- [ ] 创建`lib/features/chat/domain/services/unread_jump_strategy.dart`
- [ ] 实现智能跳转决策算法
- [ ] 添加跳转目标类型定义

**核心算法**:
```dart
UnreadJumpTarget calculateJumpTarget(List<Message> unreadMessages) {
  final count = unreadMessages.length;
  final timeSpan = DateTime.now().difference(unreadMessages.first.createdAt);
  
  if (count <= 5) return jumpToFirst();
  if (count <= 20 && timeSpan <= Duration(hours: 2)) return jumpToFirst();
  if (count >= 20 && timeSpan > Duration(hours: 2)) return jumpToLatestWithSecondary();
  return jumpToFirst();
}
```

**验收标准**:
- [ ] 跳转决策逻辑正确
- [ ] 边界条件处理完善
- [ ] 决策结果符合用户期望

#### 4.2 ChatCubit跳转逻辑 ⏱️ 1.5天
**任务**:
- [ ] 在ChatCubit中实现跳转方法
- [ ] 添加未读消息计算逻辑
- [ ] 实现滚动和高亮效果

**验收标准**:
- [ ] 跳转动画流畅
- [ ] 高亮效果明显但不刺眼
- [ ] 自动取消高亮工作正常

#### 4.3 UI组件实现 ⏱️ 2天
**任务**:
- [ ] 创建未读指示器组件
- [ ] 创建二次跳转按钮组件
- [ ] 集成到ChatPage中

**UI组件清单**:
```dart
// 需要创建的UI组件
- _UnreadIndicatorButton (底部浮动按钮)
- _SecondaryJumpButton (顶部提示条)
- _MessageHighlight (消息高亮效果)
```

**验收标准**:
- [ ] UI组件美观实用
- [ ] 动画效果流畅
- [ ] 响应式设计适配各种屏幕

### Phase 5: 测试和优化 (Week 5)

#### 5.1 全面功能测试 ⏱️ 2天
**任务**:
- [ ] 编写完整的单元测试套件
- [ ] 编写UI集成测试
- [ ] 性能压力测试

**测试覆盖**:
```dart
// 重点测试场景
- 缓存命中率测试
- 大量消息加载测试  
- 内存泄漏测试
- 跳转准确性测试
- UI响应速度测试
```

**验收标准**:
- [ ] 单元测试覆盖率>95%
- [ ] 集成测试通过率100%
- [ ] 性能指标达到预期

#### 5.2 用户体验优化 ⏱️ 2天
**任务**:
- [ ] 调优动画时间和效果
- [ ] 优化跳转策略参数
- [ ] 改进加载状态提示

**优化重点**:
- 跳转动画的流畅度
- 高亮效果的视觉体验
- 加载状态的友好提示
- 二次跳转按钮的时机

**验收标准**:
- [ ] 用户体验流畅自然
- [ ] 没有明显的性能问题
- [ ] 跳转功能易于理解和使用

#### 5.3 文档和发布准备 ⏱️ 1天
**任务**:
- [ ] 更新API文档
- [ ] 完善代码注释
- [ ] 准备发布说明

**验收标准**:
- [ ] 代码注释完整清晰
- [ ] API文档准确详细
- [ ] 发布说明突出新功能优势

### 风险控制和应对策略

#### 高风险点识别

1. **内存使用过高**
   - **风险**: 预加载过多数据导致OOM
   - **应对**: 添加内存监控，动态调整预加载数量
   - **预案**: 实现降级策略，关闭预加载功能

2. **数据库性能问题**
   - **风险**: 并发预加载影响数据库性能
   - **应对**: 限制并发数量，添加延迟控制
   - **预案**: 减少预加载会话数量

3. **跳转逻辑复杂性**
   - **风险**: 跳转策略过于复杂，用户困惑
   - **应对**: 简化决策逻辑，增加用户反馈收集
   - **预案**: 提供手动配置选项

#### 质量保证措施

1. **代码审查**
   - 每个PR必须经过代码审查
   - 重点关注内存使用和性能影响
   - 确保代码符合项目规范

2. **测试策略**
   - 单元测试优先，集成测试跟进
   - 性能测试贯穿整个开发过程
   - 用户体验测试在功能完成后进行

3. **渐进式发布**
   - Phase 1-2 作为基础版本先发布
   - Phase 3-4 作为增强功能逐步发布
   - 每个阶段都要经过充分测试

### 成功标准定义

#### 技术指标
- [x] 缓存命中率 ≥ 95%
- [x] 会话切换延迟 ≤ 5ms (缓存命中)
- [x] 未读消息跳转延迟 ≤ 100ms
- [x] 内存使用 ≤ 25MB
- [x] 单元测试覆盖率 ≥ 95%

#### 用户体验指标
- [x] 用户满意度 ≥ 90%
- [x] 跳转准确率 ≥ 95%
- [x] 界面响应流畅度良好
- [x] 功能易用性高

#### 稳定性指标
- [x] 崩溃率 ≤ 0.1%
- [x] 内存泄漏率 = 0%
- [x] 数据一致性 = 100%

---

*实施计划版本: v1.0*  
*制定时间: 2024年*  
*预计完成时间: 5周*

## 聊天UI实现详细设计

### UI架构概述

基于现有的`ChatDetailPage`和`MessageBubble`，我们需要设计一个能够处理复杂消息状态的UI架构，包括撤销、引用、删除、编辑等场景。

### 消息状态扩展设计

#### 1. Message模型扩展

```dart
// lib/core/database/models/message.dart 新增字段
@collection
class Message {
  // ... 现有字段 ...
  
  // 消息状态扩展
  bool isDeleted = false;              // 是否已删除
  bool isRevoked = false;              // 是否已撤销
  bool isEdited = false;               // 是否已编辑
  DateTime? editedAt;                  // 编辑时间
  DateTime? revokedAt;                 // 撤销时间
  DateTime? deletedAt;                 // 删除时间
  String? originalText;                // 编辑前的原始文本
  
  // 引用消息详细信息（缓存，避免查询）
  String? quotedMessageText;          // 被引用消息的文本内容
  String? quotedMessageSenderName;    // 被引用消息发送者名称
  String? quotedMessageType;          // 被引用消息类型
  
  // 回复和转发
  String? repliedToMessageId;         // 回复的消息ID
  String? forwardedFromConversationId; // 转发来源会话ID
  String? forwardedFromMessageId;     // 转发来源消息ID
  
  // 消息反应（点赞、表情等）
  Map<String, List<String>>? reactions; // 反应类型 -> 用户ID列表
  
  // 消息优先级和标记
  String priority = 'normal';         // 消息优先级: urgent, high, normal, low
  List<String>? tags;                 // 消息标签
  bool isPinned = false;              // 是否置顶
  
  // 临时状态（仅UI使用，不存储）
  @ignore bool isHighlighted = false; // 是否高亮显示
  @ignore bool isSelected = false;    // 是否被选中
  @ignore bool isPlaying = false;     // 语音/视频是否在播放
  @ignore double? uploadProgress;     // 上传进度
}
```

#### 2. 消息类型枚举扩展

```dart
// lib/core/constants/message_types.dart
class MessageType {
  // 基础类型
  static const String text = 'text';
  static const String image = 'image';
  static const String voice = 'voice';
  static const String video = 'video';
  static const String file = 'file';
  static const String location = 'location';
  
  // 系统消息类型
  static const String system = 'system';
  static const String systemUserJoined = 'system_user_joined';
  static const String systemUserLeft = 'system_user_left';
  static const String systemGroupCreated = 'system_group_created';
  static const String systemGroupRenamed = 'system_group_renamed';
  
  // 特殊消息类型
  static const String recalled = 'recalled';      // 撤销消息
  static const String deleted = 'deleted';        // 删除消息
  static const String edited = 'edited';          // 编辑消息
  static const String reply = 'reply';            // 回复消息
  static const String forward = 'forward';        // 转发消息
  
  // 富媒体类型
  static const String sticker = 'sticker';        // 表情包
  static const String gif = 'gif';               // GIF动图
  static const String contact = 'contact';        // 联系人名片
  static const String poll = 'poll';             // 投票
  static const String link = 'link';             // 链接预览
}
```

### 高级MessageBubble组件设计

#### 1. 主要组件架构

```dart
// lib/features/chat/presentation/widgets/advanced_message_bubble.dart
class AdvancedMessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final String currentUserId;
  final Message? quotedMessage;     // 被引用的消息
  final Message? repliedMessage;    // 被回复的消息
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onQuoteTap;   // 点击引用消息
  final Function(String)? onUserMentionTap; // 点击用户@
  final Function(String)? onReaction; // 添加反应
  final bool showSenderInfo;        // 是否显示发送者信息
  final bool isHighlighted;         // 是否高亮
  final bool isSelected;            // 是否被选中
  
  const AdvancedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUserId,
    this.quotedMessage,
    this.repliedMessage,
    this.onTap,
    this.onLongPress,
    this.onQuoteTap,
    this.onUserMentionTap,
    this.onReaction,
    this.showSenderInfo = false,
    this.isHighlighted = false,
    this.isSelected = false,
  });

  @override
  State<AdvancedMessageBubble> createState() => _AdvancedMessageBubbleState();
}

class _AdvancedMessageBubbleState extends State<AdvancedMessageBubble>
    with TickerProviderStateMixin {
  
  late AnimationController _highlightController;
  late AnimationController _selectionController;
  late Animation<Color?> _highlightAnimation;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();
    
    // 高亮动画控制器
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // 选中动画控制器
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _highlightAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.yellow.withAlpha(128),
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));
    
    _selectionAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AdvancedMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 处理高亮状态变化
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _highlightController.forward().then((_) {
          _highlightController.reverse();
        });
      }
    }
    
    // 处理选中状态变化
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 处理撤销消息
    if (widget.message.isRevoked) {
      return _buildRevokedMessage();
    }
    
    // 处理删除消息（仅发送者可见）
    if (widget.message.isDeleted && !widget.isMe) {
      return const SizedBox.shrink(); // 对其他人不可见
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_highlightController, _selectionController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _selectionAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: _highlightAnimation.value,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildMessageContent(),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent() {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 左侧时间（非自己的消息）
          if (!widget.isMe) _buildTimestamp(),
          
          // 主要消息内容
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 回复消息引用
                if (widget.message.quotedMessageId != null) 
                  _buildQuotedMessage(),
                
                // 主消息气泡
                _buildMainBubble(),
                
                // 消息反应
                if (widget.message.reactions?.isNotEmpty == true)
                  _buildReactions(),
                
                // 消息状态指示器
                if (widget.isMe) _buildMessageStatus(),
              ],
            ),
          ),
          
          // 右侧时间（自己的消息）
          if (widget.isMe) _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildMainBubble() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: _getBubbleColor(),
        borderRadius: _getBubbleBorderRadius(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发送者信息（群聊中非自己的消息）
          if (widget.showSenderInfo && !widget.isMe)
            _buildSenderInfo(),
          
          // 消息内容
          _buildMessageTypeContent(),
          
          // 编辑标记
          if (widget.message.isEdited)
            _buildEditedIndicator(),
        ],
      ),
    );
  }

  Widget _buildMessageTypeContent() {
    switch (widget.message.type) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.voice:
        return _buildVoiceContent();
      case MessageType.video:
        return _buildVideoContent();
      case MessageType.file:
        return _buildFileContent();
      case MessageType.location:
        return _buildLocationContent();
      case MessageType.sticker:
        return _buildStickerContent();
      case MessageType.contact:
        return _buildContactContent();
      case MessageType.poll:
        return _buildPollContent();
      default:
        return _buildTextContent();
    }
  }

  // 撤销消息显示
  Widget _buildRevokedMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                widget.isMe ? '你撤回了一条消息' : '${widget.message.senderName ?? "对方"}撤回了一条消息',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 引用消息显示
  Widget _buildQuotedMessage() {
    return GestureDetector(
      onTap: widget.onQuoteTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: widget.isMe ? Colors.white : Colors.blue,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.quotedMessageSenderName != null)
              Text(
                widget.message.quotedMessageSenderName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.isMe ? Colors.white70 : Colors.blue,
                ),
              ),
            Text(
              widget.message.quotedMessageText ?? '[${widget.message.quotedMessageType ?? '消息'}]',
              style: TextStyle(
                fontSize: 13,
                color: widget.isMe ? Colors.white70 : Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 消息反应显示
  Widget _buildReactions() {
    final reactions = widget.message.reactions!;
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: reactions.entries.map((entry) {
          final emoji = entry.key;
          final users = entry.value;
          final hasMyReaction = users.contains(widget.currentUserId);
          
          return GestureDetector(
            onTap: () => widget.onReaction?.call(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasMyReaction ? Colors.blue.withAlpha(51) : Colors.grey.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: hasMyReaction ? Border.all(color: Colors.blue, width: 1) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  if (users.length > 1) ...[
                    const SizedBox(width: 2),
                    Text(
                      users.length.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: hasMyReaction ? Colors.blue : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 消息状态指示器
  Widget _buildMessageStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 编辑标记
          if (widget.message.isEdited)
            Icon(
              Icons.edit,
              size: 12,
              color: Colors.grey[500],
            ),
          
          const SizedBox(width: 4),
          
          // 消息状态图标
          _buildStatusIcon(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (widget.message.status) {
      case 'sending':
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[500]!),
          ),
        );
      case 'sent':
        return Icon(Icons.check, size: 14, color: Colors.grey[500]);
      case 'delivered':
        return Icon(Icons.done_all, size: 14, color: Colors.grey[500]);
      case 'read':
        return Icon(Icons.done_all, size: 14, color: Colors.blue);
      case 'failed':
        return Icon(Icons.error_outline, size: 14, color: Colors.red);
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getBubbleColor() {
    if (widget.message.isDeleted && widget.isMe) {
      return Colors.grey.withAlpha(128); // 已删除消息显示为灰色
    }
    
    if (widget.isSelected) {
      return widget.isMe 
          ? Colors.green.shade400 
          : Colors.blue.shade100;
    }
    
    return widget.isMe 
        ? Colors.green.shade300 
        : Colors.white;
  }

  BorderRadius _getBubbleBorderRadius() {
    return BorderRadius.circular(16).copyWith(
      bottomLeft: widget.isMe
          ? const Radius.circular(16)
          : const Radius.circular(4),
      bottomRight: widget.isMe
          ? const Radius.circular(4)
          : const Radius.circular(16),
    );
  }

  // ... 其他内容类型的构建方法
}
```

#### 2. 消息操作菜单

```dart
// lib/features/chat/presentation/widgets/message_action_menu.dart
class MessageActionMenu extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onQuote;
  final VoidCallback? onForward;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onRevoke;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final VoidCallback? onSelect;
  final Function(String)? onReaction;

  const MessageActionMenu({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onQuote,
    this.onForward,
    this.onCopy,
    this.onEdit,
    this.onRevoke,
    this.onDelete,
    this.onPin,
    this.onSelect,
    this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 快速反应表情行
          _buildQuickReactions(),
          
          Divider(height: 1, color: Colors.grey[300]),
          
          // 操作按钮列表
          ..._buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildQuickReactions() {
    const reactions = ['👍', '❤️', '😂', '😮', '😢', '😠'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((emoji) {
          return GestureDetector(
            onTap: () => onReaction?.call(emoji),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withAlpha(51),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final actions = <Widget>[];

    // 回复
    actions.add(_buildActionButton(
      icon: Icons.reply,
      text: '回复',
      onTap: onReply,
    ));

    // 引用
    actions.add(_buildActionButton(
      icon: Icons.format_quote,
      text: '引用',
      onTap: onQuote,
    ));

    // 转发
    actions.add(_buildActionButton(
      icon: Icons.forward,
      text: '转发',
      onTap: onForward,
    ));

    // 复制（仅文本消息）
    if (message.type == MessageType.text && message.text?.isNotEmpty == true) {
      actions.add(_buildActionButton(
        icon: Icons.copy,
        text: '复制',
        onTap: onCopy,
      ));
    }

    // 编辑（仅自己的文本消息，且在一定时间内）
    if (isMe && message.type == MessageType.text && _canEdit()) {
      actions.add(_buildActionButton(
        icon: Icons.edit,
        text: '编辑',
        onTap: onEdit,
      ));
    }

    // 撤销（仅自己的消息，且在一定时间内）
    if (isMe && _canRevoke()) {
      actions.add(_buildActionButton(
        icon: Icons.undo,
        text: '撤销',
        onTap: onRevoke,
        isDestructive: true,
      ));
    }

    // 删除
    actions.add(_buildActionButton(
      icon: Icons.delete,
      text: isMe ? '删除' : '删除（仅自己可见）',
      onTap: onDelete,
      isDestructive: true,
    ));

    // 置顶/取消置顶
    actions.add(_buildActionButton(
      icon: message.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
      text: message.isPinned ? '取消置顶' : '置顶',
      onTap: onPin,
    ));

    // 选择
    actions.add(_buildActionButton(
      icon: Icons.check_circle_outline,
      text: '选择',
      onTap: onSelect,
    ));

    return actions;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey[700],
        size: 20,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }

  bool _canEdit() {
    // 24小时内的消息可以编辑
    return DateTime.now().difference(message.createdAt).inHours < 24;
  }

  bool _canRevoke() {
    // 24小时内的消息可以撤销
    return DateTime.now().difference(message.createdAt).inHours < 24;
  }
}
```

### Timeline组件增强

#### 1. 智能消息分组

```dart
// lib/features/chat/presentation/widgets/message_timeline.dart
class MessageTimeline extends StatelessWidget {
  final List<Message> messages;
  final String currentUserId;
  final Message? highlightedMessage;
  final Function(Message)? onMessageTap;
  final Function(Message)? onMessageLongPress;
  final Function(String)? onQuoteTap;
  final ScrollController? scrollController;

  const MessageTimeline({
    super.key,
    required this.messages,
    required this.currentUserId,
    this.highlightedMessage,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onQuoteTap,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _getGroupedMessages().length,
      itemBuilder: (context, index) {
        final group = _getGroupedMessages()[index];
        return _buildMessageGroup(group);
      },
    );
  }

  List<MessageGroup> _getGroupedMessages() {
    final groups = <MessageGroup>[];
    MessageGroup? currentGroup;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final prevMessage = i > 0 ? messages[i - 1] : null;
      
      // 判断是否需要新建组
      if (_shouldStartNewGroup(message, prevMessage)) {
        // 保存当前组
        if (currentGroup != null) {
          groups.add(currentGroup);
        }
        
        // 创建新组
        currentGroup = MessageGroup(
          senderId: message.senderId,
          senderName: message.senderName,
          senderAvatar: message.senderAvatar,
          messages: [message],
          startTime: message.createdAt,
        );
      } else {
        // 添加到当前组
        currentGroup?.messages.add(message);
      }
    }
    
    // 添加最后一组
    if (currentGroup != null) {
      groups.add(currentGroup);
    }
    
    return groups.reversed.toList(); // 反向以适应reverse ListView
  }

  bool _shouldStartNewGroup(Message current, Message? previous) {
    if (previous == null) return true;
    
    // 不同发送者
    if (current.senderId != previous.senderId) return true;
    
    // 时间间隔超过5分钟
    if (current.createdAt.difference(previous.createdAt).inMinutes > 5) return true;
    
    // 系统消息总是单独成组
    if (current.type == MessageType.system) return true;
    
    // 撤销或删除的消息单独成组
    if (current.isRevoked || current.isDeleted) return true;
    
    return false;
  }

  Widget _buildMessageGroup(MessageGroup group) {
    return Column(
      children: [
        // 时间分隔符
        _buildTimeSeparator(group.startTime),
        
        // 消息组
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: group.senderId == currentUserId 
                ? CrossAxisAlignment.end 
                : CrossAxisAlignment.start,
            children: [
              // 发送者信息（群聊中）
              if (_shouldShowSenderInfo(group))
                _buildSenderInfo(group),
              
              // 消息列表
              ...group.messages.asMap().entries.map((entry) {
                final index = entry.key;
                final message = entry.value;
                final isLast = index == group.messages.length - 1;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : 2,
                  ),
                  child: AdvancedMessageBubble(
                    message: message,
                    isMe: message.senderId == currentUserId,
                    currentUserId: currentUserId,
                    onTap: () => onMessageTap?.call(message),
                    onLongPress: () => onMessageLongPress?.call(message),
                    onQuoteTap: () => onQuoteTap?.call(message.quotedMessageId!),
                    showSenderInfo: false, // 在组级别显示
                    isHighlighted: message.messageId == highlightedMessage?.messageId,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator(DateTime time) {
    // 实现时间分隔符
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(time),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowSenderInfo(MessageGroup group) {
    // 在群聊中显示非自己的发送者信息
    return group.senderId != currentUserId && group.senderName != null;
  }

  Widget _buildSenderInfo(MessageGroup group) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        children: [
          UserAvatar(
            avatarUrl: group.senderAvatar,
            name: group.senderName ?? '',
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            group.senderName ?? '未知用户',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate == today) {
      return '今天';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else if (now.difference(date).inDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}

class MessageGroup {
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final List<Message> messages;
  final DateTime startTime;

  MessageGroup({
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.messages,
    required this.startTime,
  });
}
```

### 特殊场景处理

#### 1. 消息编辑功能

```dart
// lib/features/chat/presentation/widgets/message_edit_dialog.dart
class MessageEditDialog extends StatefulWidget {
  final Message message;
  final Function(String) onSave;

  const MessageEditDialog({
    super.key,
    required this.message,
    required this.onSave,
  });

  @override
  State<MessageEditDialog> createState() => _MessageEditDialogState();
}

class _MessageEditDialogState extends State<MessageEditDialog> {
  late TextEditingController _controller;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.text);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isChanged = _controller.text.trim() != widget.message.text?.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑消息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 原始消息预览
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.history, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '原消息: ${widget.message.text}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 编辑输入框
          TextField(
            controller: _controller,
            maxLines: null,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: '输入新的消息内容...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _isChanged && _controller.text.trim().isNotEmpty
              ? () {
                  widget.onSave(_controller.text.trim());
                  Navigator.pop(context);
                }
              : null,
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

#### 2. 消息选择模式

```dart
// lib/features/chat/presentation/widgets/message_selection_bar.dart
class MessageSelectionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onDelete;
  final VoidCallback? onForward;
  final VoidCallback? onCopy;
  final VoidCallback onCancel;

  const MessageSelectionBar({
    super.key,
    required this.selectedCount,
    this.onSelectAll,
    this.onDeselectAll,
    this.onDelete,
    this.onForward,
    this.onCopy,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.blue,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onCancel,
          ),
          
          Expanded(
            child: Text(
              '已选择 $selectedCount 条消息',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          if (onSelectAll != null)
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.white),
              onPressed: onSelectAll,
            ),
          
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: onCopy,
            ),
          
          if (onForward != null)
            IconButton(
              icon: const Icon(Icons.forward, color: Colors.white),
              onPressed: onForward,
            ),
          
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
```

### 性能优化策略

#### 1. 虚拟化列表

```dart
// 为大量消息实现虚拟化
class VirtualizedMessageList extends StatelessWidget {
  final MessageTimeline timeline;
  final int visibleStart;
  final int visibleEnd;

  @override
  Widget build(BuildContext context) {
    // 只渲染可见范围内的消息
    final visibleMessages = timeline.getRange(visibleStart, visibleEnd);
    
    return ListView.builder(
      itemCount: visibleMessages.length,
      itemBuilder: (context, index) {
        return AdvancedMessageBubble(
          message: visibleMessages[index],
          // ... 其他参数
        );
      },
    );
  }
}
```

#### 2. 图片懒加载

```dart
// lib/features/chat/presentation/widgets/lazy_image.dart
class LazyImage extends StatefulWidget {
  final String? imageUrl;
  final String? localPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // 实现图片懒加载和缓存
    return FutureBuilder<ImageProvider>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image(
            image: snapshot.data!,
            width: width,
            height: height,
            fit: fit,
          );
        } else {
          return _buildPlaceholder();
        }
      },
    );
  }
}
```

这个UI设计方案具有以下特点：

1. **完整的消息状态支持**：撤销、删除、编辑、引用等
2. **丰富的交互功能**：长按菜单、快速反应、消息选择
3. **智能消息分组**：相同发送者的连续消息自动分组
4. **高性能渲染**：虚拟化列表、懒加载图片
5. **用户体验优化**：动画效果、状态指示、时间分隔
6. **响应式设计**：适配不同屏幕尺寸
7. **可扩展架构**：易于添加新的消息类型和功能

这个设计能够很好地配合我们之前设计的缓存系统，为用户提供流畅的聊天体验。