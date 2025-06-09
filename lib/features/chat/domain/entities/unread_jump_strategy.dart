import 'package:cc/core/database/models/message.dart';

/// 智能未读消息跳转策略
///
/// 💢💢💢 修正业务逻辑：
/// 1. "有新消息+无未读" 不会存在0条的状况，总是显示到最新的一条
/// 2. "有新消息未读" 都显示到最新的一条（最新一条在UI底部第一条）
///
/// 核心原则：无论什么情况，用户进入聊天页面都应该看到最新的对话状态
class UnreadJumpStrategy {
  /// 跳转决策结果 - 简化为单一策略
  static const String jumpToLatest = 'jump_to_latest';

  /// 分析未读消息并返回跳转策略
  ///
  /// [unreadMessages] 未读消息列表
  /// [latestMessage] 最新消息（可能已读或未读）
  /// [currentTime] 当前时间，用于测试
  ///
  /// 💢💢💢 修正：始终返回跳转到最新消息的策略
  static JumpDecision analyzeUnreadMessages(
    List<Message> unreadMessages, {
    Message? latestMessage,
    DateTime? currentTime,
  }) {
    currentTime ??= DateTime.now();

    // 💢💢💢 核心逻辑：无论什么情况都跳转到最新消息
    if (unreadMessages.isEmpty) {
      // 场景1：有新消息+无未读 - 显示到最新消息
      return JumpDecision(
        strategy: jumpToLatest,
        reason: '有新消息但无未读，显示到最新消息',
        confidence: 1.0,
        targetMessageId: latestMessage?.messageId,
        totalUnreadCount: 0,
        hasUnreadMessages: false,
      );
    }

    // 场景2：有未读消息 - 显示到最新消息（最新一条在UI底部第一条）
    final unreadCount = unreadMessages.length;
    final latestUnreadMessage = unreadMessages.last; // 最新的未读消息

    return JumpDecision(
      strategy: jumpToLatest,
      reason: '有$unreadCount条未读消息，显示到最新消息（在UI底部第一条）',
      confidence: 1.0,
      targetMessageId: latestUnreadMessage.messageId,
      totalUnreadCount: unreadCount,
      hasUnreadMessages: true,
    );
  }

  /// 计算跳转上下文信息
  ///
  /// 💢💢💢 简化：由于总是跳转到最新，上下文信息主要用于UI提示
  static JumpContext calculateJumpContext(
    List<Message> unreadMessages,
    JumpDecision decision,
  ) {
    final totalCount = unreadMessages.length;

    return JumpContext(
      totalUnreadCount: totalCount,
      jumpedToIndex: totalCount > 0 ? totalCount - 1 : 0, // 总是跳转到最新
      remainingUnreadCount: 0, // 跳转到最新后无剩余未读
      firstUnreadMessageId:
          unreadMessages.isNotEmpty ? unreadMessages.first.messageId : null,
      lastUnreadMessageId:
          unreadMessages.isNotEmpty ? unreadMessages.last.messageId : null,
      timeSpan: unreadMessages.length > 1
          ? unreadMessages.last.createdAt
              .difference(unreadMessages.first.createdAt)
          : null,
    );
  }

  /// 获取用户友好的跳转描述
  static String getJumpDescription(JumpDecision decision, JumpContext context) {
    if (!decision.hasUnreadMessages) {
      return '显示最新对话';
    }

    if (context.totalUnreadCount == 1) {
      return '显示最新消息（1条未读）';
    }

    return '显示最新消息（${context.totalUnreadCount}条未读）';
  }
}

/// 跳转决策结果
class JumpDecision {
  /// 跳转策略（简化为单一策略）
  final String strategy;

  /// 决策原因
  final String reason;

  /// 决策置信度 (0.0-1.0)
  final double confidence;

  /// 目标消息ID（总是最新消息）
  final String? targetMessageId;

  /// 💢💢💢 新增：未读消息总数
  final int totalUnreadCount;

  /// 💢💢💢 新增：是否有未读消息
  final bool hasUnreadMessages;

  const JumpDecision({
    required this.strategy,
    required this.reason,
    required this.confidence,
    this.targetMessageId,
    required this.totalUnreadCount,
    required this.hasUnreadMessages,
  });

  @override
  String toString() {
    return 'JumpDecision(strategy: $strategy, reason: $reason, unread: $totalUnreadCount)';
  }
}

/// 跳转上下文信息
class JumpContext {
  /// 总未读消息数量
  final int totalUnreadCount;

  /// 跳转到的消息索引（总是最新）
  final int jumpedToIndex;

  /// 剩余未读消息数量（总是0，因为跳转到最新）
  final int remainingUnreadCount;

  /// 第一条未读消息ID
  final String? firstUnreadMessageId;

  /// 最后一条未读消息ID
  final String? lastUnreadMessageId;

  /// 未读消息时间跨度
  final Duration? timeSpan;

  const JumpContext({
    required this.totalUnreadCount,
    required this.jumpedToIndex,
    required this.remainingUnreadCount,
    this.firstUnreadMessageId,
    this.lastUnreadMessageId,
    this.timeSpan,
  });

  @override
  String toString() {
    return 'JumpContext(total: $totalUnreadCount, jumped: $jumpedToIndex, remaining: $remainingUnreadCount)';
  }
}
