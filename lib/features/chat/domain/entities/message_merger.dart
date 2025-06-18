import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/entities/message_update_event.dart';
import 'package:cc/core/services/log_service.dart';

/// 消息智能合并工具类
/// 负责处理消息列表的合并、去重、排序等操作
class MessageMerger {
  static final LogService _logger = LogService.instance;

  /// 智能合并消息列表，保持排序和去重
  /// [currentMessages] - 当前的消息列表
  /// [newMessages] - 新的消息列表
  /// [maintainScrollPosition] - 是否保持滚动位置
  static List<Message> smartMergeMessages(
    List<Message> currentMessages,
    List<Message> newMessages, {
    bool maintainScrollPosition = true,
  }) {
    if (newMessages.isEmpty) {
      return currentMessages;
    }

    // 使用Map进行去重，messageId作为key
    final messageMap = <String, Message>{};

    // 先添加现有消息
    for (final message in currentMessages) {
      messageMap[message.messageId] = message;
    }

    // 添加新消息（会覆盖重复的，实现更新）
    for (final message in newMessages) {
      messageMap[message.messageId] = message;
    }

    // 转换为列表并按messageIndex降序排序（最新消息在前）
    final mergedList = messageMap.values.toList();
    mergedList.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));

    _logger.d('智能合并消息完成', extra: {
      'originalCount': currentMessages.length,
      'newCount': newMessages.length,
      'mergedCount': mergedList.length,
      'duplicatesRemoved':
          (currentMessages.length + newMessages.length) - mergedList.length,
    });

    return mergedList;
  }

  /// 增量插入消息到指定位置
  /// [currentMessages] - 当前消息列表
  /// [newMessages] - 新消息列表
  /// [position] - 插入位置
  static List<Message> insertMessages(
    List<Message> currentMessages,
    List<Message> newMessages,
    MessageInsertPosition position,
  ) {
    if (newMessages.isEmpty) {
      return currentMessages;
    }

    switch (position) {
      case MessageInsertPosition.before:
        // 历史消息：添加到列表末尾（降序排列）
        final combined = [...currentMessages, ...newMessages];
        combined.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));
        return _removeDuplicates(combined);

      case MessageInsertPosition.after:
        // 新消息：添加到列表开头
        final combined = [...newMessages, ...currentMessages];
        combined.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));
        return _removeDuplicates(combined);

      case MessageInsertPosition.replace:
        // 完全替换
        final sorted = [...newMessages];
        sorted.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));
        return sorted;

      case MessageInsertPosition.merge:
        // 智能合并
        return smartMergeMessages(currentMessages, newMessages);
    }
  }

  /// 更新单条消息
  /// [currentMessages] - 当前消息列表
  /// [updatedMessage] - 更新的消息
  static List<Message> updateSingleMessage(
    List<Message> currentMessages,
    Message updatedMessage,
  ) {
    final updatedList = currentMessages.map((message) {
      return message.messageId == updatedMessage.messageId
          ? updatedMessage
          : message;
    }).toList();

    _logger.d('单条消息更新完成', extra: {
      'messageId': updatedMessage.messageId,
      'messageCount': updatedList.length,
    });

    return updatedList;
  }

  /// 移除单条消息
  /// [currentMessages] - 当前消息列表
  /// [messageId] - 要移除的消息ID
  static List<Message> removeSingleMessage(
    List<Message> currentMessages,
    String messageId,
  ) {
    final filteredList = currentMessages
        .where((message) => message.messageId != messageId)
        .toList();

    _logger.d('单条消息移除完成', extra: {
      'messageId': messageId,
      'originalCount': currentMessages.length,
      'newCount': filteredList.length,
    });

    return filteredList;
  }

  /// 移除重复消息，保持messageIndex降序
  /// [messages] - 消息列表
  static List<Message> _removeDuplicates(List<Message> messages) {
    final seen = <String>{};
    final deduplicated = <Message>[];

    for (final message in messages) {
      if (!seen.contains(message.messageId)) {
        seen.add(message.messageId);
        deduplicated.add(message);
      }
    }

    return deduplicated;
  }

  /// 检查两个消息列表是否相等（内容和顺序）
  /// [list1] - 第一个消息列表
  /// [list2] - 第二个消息列表
  static bool areMessageListsEqual(List<Message> list1, List<Message> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].messageId != list2[i].messageId) {
        return false;
      }
    }

    return true;
  }

  /// 获取消息列表的统计信息
  /// [messages] - 消息列表
  static Map<String, dynamic> getMessageListStats(List<Message> messages) {
    if (messages.isEmpty) {
      return {
        'count': 0,
        'oldestIndex': null,
        'newestIndex': null,
        'timeSpan': null,
      };
    }

    // 由于列表是按messageIndex降序排列，第一个是最新的，最后一个是最老的
    final newestMessage = messages.first;
    final oldestMessage = messages.last;

    return {
      'count': messages.length,
      'oldestIndex': oldestMessage.messageIndex,
      'newestIndex': newestMessage.messageIndex,
      'oldestTime': oldestMessage.createdAt,
      'newestTime': newestMessage.createdAt,
      'timeSpan': newestMessage.createdAt.difference(oldestMessage.createdAt),
    };
  }

  /// 验证消息列表的排序是否正确
  /// [messages] - 消息列表
  static bool validateMessageListOrder(List<Message> messages) {
    if (messages.length <= 1) {
      return true;
    }

    for (int i = 0; i < messages.length - 1; i++) {
      // 检查是否按messageIndex降序排列
      if (messages[i].messageIndex < messages[i + 1].messageIndex) {
        _logger.w('消息列表排序不正确', extra: {
          'position': i,
          'currentIndex': messages[i].messageIndex,
          'nextIndex': messages[i + 1].messageIndex,
        });
        return false;
      }
    }

    return true;
  }

  /// 修复消息列表排序
  /// [messages] - 消息列表
  static List<Message> fixMessageListOrder(List<Message> messages) {
    final sorted = [...messages];
    sorted.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));

    if (!areMessageListsEqual(messages, sorted)) {
      _logger.i('消息列表排序已修复', extra: {
        'originalCount': messages.length,
        'sortedCount': sorted.length,
      });
    }

    return sorted;
  }
}
