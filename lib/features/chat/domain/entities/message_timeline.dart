import '../../../../core/database/models/message.dart';

/// 消息时间线
///
/// 管理单个会话的消息列表，提供环形缓冲、时间线排序等功能
class MessageTimeline {
  static const int defaultMaxSize = 200; // 每个会话最多200条消息
  static const int visibleWindow = 50; // 当前可见范围50条
  static const int preloadRange = 100; // 预加载时加载100条

  final List<Message> _messages = [];
  final int maxSize;
  final String conversationId;

  // 状态信息
  DateTime? earliestLoadedTime; // 已加载的最早时间
  DateTime? latestLoadedTime; // 已加载的最新时间
  bool hasMoreHistory = true; // 是否还有更早的消息
  bool hasMoreRecent = false; // 是否还有更新的消息
  int lastVisibleIndex = 0; // 用户最后查看的位置

  // 未读消息相关
  String? firstUnreadMessageId; // 第一条未读消息ID
  String? lastUnreadMessageId; // 最后一条未读消息ID
  int unreadCount = 0; // 未读消息数量

  MessageTimeline({
    required this.conversationId,
    this.maxSize = defaultMaxSize,
  });

  /// 获取消息列表长度
  int get length => _messages.length;

  /// 检查是否为空
  bool get isEmpty => _messages.isEmpty;

  /// 检查是否非空
  bool get isNotEmpty => _messages.isNotEmpty;

  /// 向历史方向插入消息（时间更早的消息）
  void insertHistoryMessages(List<Message> messages) {
    if (messages.isEmpty) return;

    // 按时间升序排序（早的在前）
    final sortedMessages = List<Message>.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // 插入到列表开头
    _messages.insertAll(0, sortedMessages);

    // 更新时间边界
    _updateTimeBounds();

    // 执行环形缓冲清理
    _manageCacheSize();
  }

  /// 向新消息方向添加消息（时间更新的消息）
  void appendNewMessages(List<Message> messages) {
    if (messages.isEmpty) return;

    // 按时间升序排序（早的在前）
    final sortedMessages = List<Message>.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // 添加到列表末尾
    _messages.addAll(sortedMessages);

    // 更新时间边界
    _updateTimeBounds();

    // 执行环形缓冲清理
    _manageCacheSize();
  }

  /// 插入单条实时消息
  void insertMessage(Message message) {
    // 找到正确的插入位置（保持时间排序）
    int insertIndex = _findInsertIndex(message.createdAt);

    _messages.insert(insertIndex, message);

    // 更新时间边界
    _updateTimeBounds();

    // 执行环形缓冲清理
    _manageCacheSize();
  }

  /// 获取指定范围的消息
  List<Message> getRange(int start, int end) {
    if (start < 0 || end < 0 || start >= _messages.length) {
      return [];
    }

    final safeEnd = end > _messages.length ? _messages.length : end;
    return _messages.sublist(start, safeEnd);
  }

  /// 查找消息索引
  int? findMessageIndex(String messageId) {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].messageId == messageId) {
        return i;
      }
    }
    return null;
  }

  /// 获取未读消息列表
  List<Message> getUnreadMessages() {
    return _messages.where((msg) => msg.status != 'read').toList();
  }

  /// 获取第一条未读消息
  Message? getFirstUnreadMessage() {
    if (firstUnreadMessageId == null) return null;

    try {
      return _messages.firstWhere(
        (msg) => msg.messageId == firstUnreadMessageId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取最新未读消息
  Message? getLatestUnreadMessage() {
    if (lastUnreadMessageId == null) return null;

    try {
      return _messages.firstWhere(
        (msg) => msg.messageId == lastUnreadMessageId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 标记消息为已读
  void markMessagesAsRead(List<String> messageIds) {
    for (final message in _messages) {
      if (messageIds.contains(message.messageId)) {
        message.status = 'read';
      }
    }

    // 重新计算未读消息信息
    _recalculateUnreadInfo();
  }

  /// 恢复查看状态
  ViewState getLastViewState() {
    return ViewState(
      scrollPosition: lastVisibleIndex,
      conversationId: conversationId,
      lastViewTime: DateTime.now(),
    );
  }

  /// 更新最后查看位置
  void updateLastVisibleIndex(int index) {
    lastVisibleIndex = index;
  }

  /// 获取所有消息（用于调试）
  List<Message> getAllMessages() {
    return List.unmodifiable(_messages);
  }

  /// 清空时间线
  void clear() {
    _messages.clear();
    earliestLoadedTime = null;
    latestLoadedTime = null;
    hasMoreHistory = true;
    hasMoreRecent = false;
    lastVisibleIndex = 0;
    unreadCount = 0;
    firstUnreadMessageId = null;
    lastUnreadMessageId = null;
  }

  /// 查找消息插入位置（二分查找）
  int _findInsertIndex(DateTime messageTime) {
    int left = 0;
    int right = _messages.length;

    while (left < right) {
      int mid = (left + right) ~/ 2;
      if (_messages[mid].createdAt.isBefore(messageTime)) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    return left;
  }

  /// 管理缓存大小（环形缓冲）
  void _manageCacheSize() {
    if (_messages.length <= maxSize) return;

    // 计算需要删除的消息数量
    final excess = _messages.length - maxSize;

    // 从两端均匀删除，优先保留中间部分
    final removeFromStart = excess ~/ 2;
    final removeFromEnd = excess - removeFromStart;

    // 从开头删除
    if (removeFromStart > 0) {
      _messages.removeRange(0, removeFromStart);
      // 更新最早时间
      if (_messages.isNotEmpty) {
        earliestLoadedTime = _messages.first.createdAt;
        hasMoreHistory = true; // 删除了历史消息，可能还有更多
      }
    }

    // 从末尾删除
    if (removeFromEnd > 0) {
      final removeStart = _messages.length - removeFromEnd;
      _messages.removeRange(removeStart, _messages.length);
      // 更新最新时间
      if (_messages.isNotEmpty) {
        latestLoadedTime = _messages.last.createdAt;
        hasMoreRecent = true; // 删除了新消息，可能还有更多
      }
    }

    // 调整 lastVisibleIndex
    if (lastVisibleIndex >= _messages.length) {
      lastVisibleIndex = _messages.length - 1;
    } else if (lastVisibleIndex < 0) {
      lastVisibleIndex = 0;
    }
  }

  /// 更新时间边界
  void _updateTimeBounds() {
    if (_messages.isEmpty) {
      earliestLoadedTime = null;
      latestLoadedTime = null;
      return;
    }

    earliestLoadedTime = _messages.first.createdAt;
    latestLoadedTime = _messages.last.createdAt;
  }

  /// 重新计算未读消息信息
  void _recalculateUnreadInfo() {
    final unreadMessages = getUnreadMessages();
    unreadCount = unreadMessages.length;

    if (unreadMessages.isNotEmpty) {
      firstUnreadMessageId = unreadMessages.first.messageId;
      lastUnreadMessageId = unreadMessages.last.messageId;
    } else {
      firstUnreadMessageId = null;
      lastUnreadMessageId = null;
    }
  }
}

/// 查看状态
class ViewState {
  final int scrollPosition;
  final String conversationId;
  final DateTime lastViewTime;

  const ViewState({
    required this.scrollPosition,
    required this.conversationId,
    required this.lastViewTime,
  });

  ViewState copyWith({
    int? scrollPosition,
    String? conversationId,
    DateTime? lastViewTime,
  }) {
    return ViewState(
      scrollPosition: scrollPosition ?? this.scrollPosition,
      conversationId: conversationId ?? this.conversationId,
      lastViewTime: lastViewTime ?? this.lastViewTime,
    );
  }
}
