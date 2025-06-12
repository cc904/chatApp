import 'dart:convert';

import 'package:cc/core/database/models/message.dart';

/// 消息更新操作类型
enum MessagesUpdateOperationType {
  /// 初始化消息
  init,

  /// 添加消息
  add,

  /// 移除消息
  remove,

  /// 更新消息
  update,

  /// 替换整个消息列表
  replace,

  /// 同步消息
  sync,

  /// 更新消息状态
  updateStatus,
}

/// 消息更新操作
class MessagesUpdateOperation {
  final MessagesUpdateOperationType operationType;
  final List<Message>? messages;
  final bool? hasMoreBefore;
  final bool? hasMoreAfter;
  final List<MessageUpdateEvent>? messageUpdateEvents;

  MessagesUpdateOperation({
    required this.operationType,
    this.messages,
    this.messageUpdateEvents,
    this.hasMoreBefore,
    this.hasMoreAfter,
  });

  @override
  String toString() {
    return 'MessageUpdateOperation{operationType: $operationType, messageCount: ${messages?.length}, messageUpdateEvents: $messageUpdateEvents}';
  }
}

enum MessageUpdateType {
  editText,
  updateStatus,
  revokeMessage,
  deleteMessage,
  pinMessage,
  replaceMessageId,
  updateReactions,
}

/// 消息更新事件 - 用于修改消息的各种操作
class MessageUpdateEvent {
  final MessageUpdateType updateType;
  final String messageId;
  final String conversationId;
  final Map<String, dynamic> updateData;
  final String? tempId; // 临时ID，用于匹配发送中的消息

  MessageUpdateEvent({
    required this.updateType,
    required this.messageId,
    required this.conversationId,
    required this.updateData,
    this.tempId,
  });

  /// 创建文本更新事件（编辑消息）
  factory MessageUpdateEvent.editText({
    required String conversationId,
    required String messageId,
    required String newText,
  }) {
    return MessageUpdateEvent(
      updateType: MessageUpdateType.editText,
      messageId: messageId,
      conversationId: conversationId,
      updateData: {
        'text': newText,
        'isEdited': true,
        'editedAt': DateTime.now(),
      },
    );
  }

  /// 创建状态更新事件
  factory MessageUpdateEvent.updateStatus({
    required String conversationId,
    required String messageId,
    required MessageStatus statusType,
    String? newMessageId,
    int? messageIndex,
  }) {
    Map<String, dynamic> updateData = {};

    switch (statusType) {
      case MessageStatus.sending:
        updateData = {'status': MessageStatus.sending};
        break;
      case MessageStatus.sent:
        updateData = {'status': MessageStatus.sent};
        if (newMessageId != null) updateData['messageId'] = newMessageId;
        if (messageIndex != null) updateData['messageIndex'] = messageIndex;
        break;
      case MessageStatus.delivered:
        updateData = {'status': MessageStatus.delivered};
        break;
      case MessageStatus.read:
        updateData = {'status': MessageStatus.read};
        break;
      case MessageStatus.failed:
        updateData = {'status': MessageStatus.failed};
        break;
      case MessageStatus.deleted:
        updateData = {
          'status': MessageStatus.deleted,
          'updatedAt': DateTime.now()
        };
        break;
      case MessageStatus.revoked:
        updateData = {
          'status': MessageStatus.revoked,
          'updatedAt': DateTime.now()
        };
        break;
    }

    return MessageUpdateEvent(
      updateType: MessageUpdateType.updateStatus,
      messageId: messageId,
      conversationId: conversationId,
      updateData: updateData,
    );
  }

  /// 创建撤销消息事件
  factory MessageUpdateEvent.revokeMessage({
    required String conversationId,
    required String messageId,
  }) {
    return MessageUpdateEvent(
      updateType: MessageUpdateType.revokeMessage,
      messageId: messageId,
      conversationId: conversationId,
      updateData: {
        'status': MessageStatus.revoked,
        'text': null, // 撤销后清除文本内容
        'updatedAt': DateTime.now(),
      },
    );
  }

  /// 创建删除消息事件
  factory MessageUpdateEvent.deleteMessage({
    required String conversationId,
    required String messageId,
  }) {
    return MessageUpdateEvent(
      updateType: MessageUpdateType.deleteMessage,
      messageId: messageId,
      conversationId: conversationId,
      updateData: {
        'status': MessageStatus.deleted,
        'updatedAt': DateTime.now(),
      },
    );
  }

  /// 创建置顶消息事件
  factory MessageUpdateEvent.pinMessage({
    required String conversationId,
    required String messageId,
    required bool isPinned,
  }) {
    return MessageUpdateEvent(
      updateType: MessageUpdateType.pinMessage,
      messageId: messageId,
      conversationId: conversationId,
      updateData: {
        'isPinned': isPinned,
        'updatedAt': DateTime.now(),
      },
    );
  }

  /// 创建临时消息ID替换事件（发送成功后）
  factory MessageUpdateEvent.replaceTempId({
    required String conversationId,
    required String tempId,
    required String newMessageId,
    int? messageIndex,
  }) {
    return MessageUpdateEvent(
      updateType: MessageUpdateType.replaceMessageId,
      messageId: newMessageId,
      conversationId: conversationId,
      tempId: tempId,
      updateData: {
        'messageId': newMessageId,
        'messageIndex': messageIndex,
        'status': MessageStatus.sent,
        'updatedAt': DateTime.now(),
      },
    );
  }

  /// 创建更新消息反应事件
  factory MessageUpdateEvent.updateReactions({
    required String conversationId,
    required String messageId,
    required Map<String, int> reactions,
  }) {
    return MessageUpdateEvent(
      updateType: MessageUpdateType.updateReactions,
      messageId: messageId,
      conversationId: conversationId,
      updateData: {
        'reactions': reactions,
        'updatedAt': DateTime.now(),
      },
    );
  }

  /// 应用更新到消息对象
  Message applyToMessage(Message message) {
    // 创建消息副本进行修改
    final updatedMessage = Message()
      ..id = message.id
      ..messageId = message.messageId
      ..conversationId = message.conversationId
      ..messageIndex = message.messageIndex
      ..senderId = message.senderId
      ..senderName = message.senderName
      ..senderAvatar = message.senderAvatar
      ..createdAt = message.createdAt
      ..updatedAt = message.updatedAt
      ..status = message.status
      ..isEdited = message.isEdited
      ..editedAt = message.editedAt
      ..type = message.type
      ..text = message.text
      ..mediaUrl = message.mediaUrl
      ..localPath = message.localPath
      ..duration = message.duration
      ..fileSize = message.fileSize
      ..fileName = message.fileName
      ..thumbnailUrl = message.thumbnailUrl
      ..quotedMessageId = message.quotedMessageId
      ..repliedToMessageId = message.repliedToMessageId
      ..forwardedFromConversationId = message.forwardedFromConversationId
      ..forwardedFromMessageId = message.forwardedFromMessageId
      ..reactions = message.reactions
      ..tags = message.tags
      ..isPinned = message.isPinned;

    // 应用更新数据
    updateData.forEach((key, value) {
      switch (key) {
        case 'messageId':
          updatedMessage.messageId = value as String;
          break;
        case 'messageIndex':
          updatedMessage.messageIndex = value as int;
          break;
        case 'text':
          updatedMessage.text = value as String?;
          break;
        case 'status':
          updatedMessage.status = value as MessageStatus;
          break;
        case 'isEdited':
          updatedMessage.isEdited = value as bool;
          break;
        case 'editedAt':
          updatedMessage.editedAt = value as DateTime;
          break;
        case 'reactions':
          updatedMessage.reactions =
              value is Map<String, int> ? jsonEncode(value) : value as String?;
          break;
        case 'tags':
          updatedMessage.tags =
              value is List<String> ? jsonEncode(value) : value as String?;
          break;
        case 'isPinned':
          updatedMessage.isPinned = value as bool;
          break;
        case 'updatedAt':
          updatedMessage.updatedAt = value as DateTime;
          break;
      }
    });

    return updatedMessage;
  }

  @override
  String toString() {
    return 'MessageUpdateEvent{updateType: $updateType, messageId: $messageId, conversationId: $conversationId, tempId: $tempId, updateData: $updateData}';
  }
}
