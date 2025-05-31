import 'package:cc/core/database/models/message.dart';

/// 智能未读消息跳转策略
///
/// 根据未读消息数量、时间跨度等因素，智能决定跳转策略
/// 提供最佳的用户体验
class UnreadJumpStrategy {
  /// 跳转决策结果
  static const String jumpToFirst = 'jump_to_first';
  static const String jumpToLatest = 'jump_to_latest';
  static const String showSecondaryOption = 'show_secondary_option';

  /// 时间阈值配置
  static const Duration shortTimeSpan = Duration(hours: 2);
  static const Duration mediumTimeSpan = Duration(hours: 24);
  static const Duration longTimeSpan = Duration(days: 7);

  /// 消息数量阈值
  static const int fewMessages = 5;
  static const int moderateMessages = 20;
  static const int manyMessages = 50;

  /// 分析未读消息并返回跳转策略
  ///
  /// [unreadMessages] 未读消息列表
  /// [currentTime] 当前时间，用于测试
  ///
  /// 返回跳转策略决策
  static JumpDecision analyzeUnreadMessages(
    List<Message> unreadMessages, {
    DateTime? currentTime,
  }) {
    currentTime ??= DateTime.now();

    if (unreadMessages.isEmpty) {
      return const JumpDecision(
        strategy: jumpToLatest,
        reason: '无未读消息',
        confidence: 1.0,
      );
    }

    final unreadCount = unreadMessages.length;
    final firstUnread = unreadMessages.first;
    final lastUnread = unreadMessages.last;

    final timeSpanFromFirst = currentTime.difference(firstUnread.createdAt);
    final timeSpanFromLast = currentTime.difference(lastUnread.createdAt);

    // 策略1: 少量未读消息 (≤5条) - 直接跳转到第一条
    if (unreadCount <= fewMessages) {
      return JumpDecision(
        strategy: jumpToFirst,
        reason: '未读消息较少($unreadCount条)，直接跳转到第一条',
        confidence: 0.9,
        targetMessageId: firstUnread.messageId,
      );
    }

    // 策略2: 中等数量未读消息 (6-20条)
    if (unreadCount <= moderateMessages) {
      // 如果时间跨度较短 (2小时内) - 跳转到第一条
      if (timeSpanFromFirst <= shortTimeSpan) {
        return JumpDecision(
          strategy: jumpToFirst,
          reason: '未读消息适中($unreadCount条)且时间跨度较短，跳转到第一条',
          confidence: 0.85,
          targetMessageId: firstUnread.messageId,
        );
      }

      // 如果时间跨度中等 (24小时内) - 提供二次选择
      if (timeSpanFromFirst <= mediumTimeSpan) {
        return JumpDecision(
          strategy: showSecondaryOption,
          reason: '未读消息适中($unreadCount条)且时间跨度中等，提供选择',
          confidence: 0.8,
          targetMessageId: firstUnread.messageId,
          secondaryTargetId: lastUnread.messageId,
        );
      }

      // 时间跨度较长 - 跳转到最新
      return JumpDecision(
        strategy: jumpToLatest,
        reason: '未读消息适中($unreadCount条)但时间跨度较长，跳转到最新',
        confidence: 0.75,
        targetMessageId: lastUnread.messageId,
      );
    }

    // 策略3: 大量未读消息 (>20条)
    if (unreadCount <= manyMessages) {
      // 如果最新消息很新 (1小时内) - 跳转到最新并提供二次选择
      if (timeSpanFromLast <= const Duration(hours: 1)) {
        return JumpDecision(
          strategy: showSecondaryOption,
          reason: '未读消息较多($unreadCount条)且有新消息，跳转到最新并提供选择',
          confidence: 0.9,
          targetMessageId: lastUnread.messageId,
          secondaryTargetId: firstUnread.messageId,
        );
      }

      // 否则跳转到最新
      return JumpDecision(
        strategy: jumpToLatest,
        reason: '未读消息较多($unreadCount条)，跳转到最新',
        confidence: 0.85,
        targetMessageId: lastUnread.messageId,
      );
    }

    // 策略4: 超大量未读消息 (>50条) - 总是跳转到最新
    return JumpDecision(
      strategy: jumpToLatest,
      reason: '未读消息过多($unreadCount条)，跳转到最新',
      confidence: 0.95,
      targetMessageId: lastUnread.messageId,
    );
  }

  /// 计算跳转上下文信息
  ///
  /// 用于在跳转后提供额外的上下文信息
  static JumpContext calculateJumpContext(
    List<Message> unreadMessages,
    JumpDecision decision,
  ) {
    if (unreadMessages.isEmpty) {
      return const JumpContext(
        totalUnreadCount: 0,
        jumpedToIndex: 0,
        remainingUnreadCount: 0,
      );
    }

    final totalCount = unreadMessages.length;
    int jumpedToIndex = 0;
    int remainingCount = 0;

    if (decision.strategy == jumpToFirst) {
      jumpedToIndex = 0;
      remainingCount = totalCount - 1;
    } else if (decision.strategy == jumpToLatest) {
      jumpedToIndex = totalCount - 1;
      remainingCount = 0;
    } else if (decision.strategy == showSecondaryOption) {
      // 默认跳转到主要目标
      if (decision.targetMessageId == unreadMessages.first.messageId) {
        jumpedToIndex = 0;
        remainingCount = totalCount - 1;
      } else {
        jumpedToIndex = totalCount - 1;
        remainingCount = 0;
      }
    }

    return JumpContext(
      totalUnreadCount: totalCount,
      jumpedToIndex: jumpedToIndex,
      remainingUnreadCount: remainingCount,
      firstUnreadMessageId: unreadMessages.first.messageId,
      lastUnreadMessageId: unreadMessages.last.messageId,
      timeSpan: unreadMessages.last.createdAt
          .difference(unreadMessages.first.createdAt),
    );
  }

  /// 获取用户友好的跳转描述
  static String getJumpDescription(JumpDecision decision, JumpContext context) {
    switch (decision.strategy) {
      case jumpToFirst:
        if (context.remainingUnreadCount > 0) {
          return '跳转到第一条未读消息，还有${context.remainingUnreadCount}条未读';
        }
        return '跳转到唯一的未读消息';

      case jumpToLatest:
        if (context.totalUnreadCount > 1) {
          return '跳转到最新消息，共${context.totalUnreadCount}条未读';
        }
        return '跳转到最新消息';

      case showSecondaryOption:
        return '有${context.totalUnreadCount}条未读消息，可选择跳转位置';

      default:
        return '跳转到未读消息';
    }
  }
}

/// 跳转决策结果
class JumpDecision {
  /// 跳转策略
  final String strategy;

  /// 决策原因
  final String reason;

  /// 决策置信度 (0.0-1.0)
  final double confidence;

  /// 主要目标消息ID
  final String? targetMessageId;

  /// 次要目标消息ID (用于二次选择)
  final String? secondaryTargetId;

  const JumpDecision({
    required this.strategy,
    required this.reason,
    required this.confidence,
    this.targetMessageId,
    this.secondaryTargetId,
  });

  @override
  String toString() {
    return 'JumpDecision(strategy: $strategy, reason: $reason, confidence: $confidence)';
  }
}

/// 跳转上下文信息
class JumpContext {
  /// 总未读消息数量
  final int totalUnreadCount;

  /// 跳转到的消息索引
  final int jumpedToIndex;

  /// 剩余未读消息数量
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
