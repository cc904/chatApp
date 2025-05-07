import 'package:fixnum/fixnum.dart';
import '../database/models/message.dart' as db;
import '../database/models/user.dart' as db;
import '../database/models/conversation.dart' as db;
import '../proto/generated/message.pb.dart';
import '../proto/generated/user.pb.dart';
import '../proto/generated/conversation.pb.dart';

/// 数据模型适配器
/// 负责在数据库模型与Protobuf模型之间进行转换
class ProtoModelAdapter {
  // 单例模式
  static final ProtoModelAdapter _instance = ProtoModelAdapter._internal();

  factory ProtoModelAdapter() {
    return _instance;
  }

  ProtoModelAdapter._internal();

  /// 将数据库 Message 模型转换为 Protobuf MessageProto
  MessageProto messageToProto(db.Message message) {
    final proto = MessageProto()
      ..messageId = message.messageId
      ..conversationId = message.conversationId
      ..senderId = message.senderId;

    if (message.senderName != null) {
      proto.senderName = message.senderName!;
    }

    if (message.senderAvatar != null) {
      proto.senderAvatar = message.senderAvatar!;
    }

    proto.createdAt = Int64(message.createdAt.millisecondsSinceEpoch);
    proto.isRead = message.isRead;
    proto.status = message.status; // 直接使用字符串

    // 根据字符串设置枚举值
    switch (message.type) {
      case 'text':
        proto.type = MessageType.text;
        break;
      case 'image':
        proto.type = MessageType.image;
        break;
      case 'voice':
        proto.type = MessageType.voice;
        break;
      case 'file':
        proto.type = MessageType.file;
        break;
      case 'video':
        proto.type = MessageType.video;
        break;
      case 'location':
        proto.type = MessageType.location;
        break;
      case 'system':
        proto.type = MessageType.system;
        break;
      default:
        proto.type = MessageType.text;
    }

    // 设置内容字段
    if (message.text != null) {
      proto.text = message.text!;
    }

    // 设置媒体字段
    if (message.mediaUrl != null) {
      proto.mediaUrl = message.mediaUrl!;
    }

    if (message.localPath != null) {
      proto.localPath = message.localPath!;
    }

    if (message.duration != null) {
      proto.duration = message.duration!;
    }

    if (message.fileSize != null) {
      proto.fileSize = message.fileSize!;
    }

    if (message.fileName != null) {
      proto.fileName = message.fileName!;
    }

    if (message.thumbnailUrl != null) {
      proto.thumbnailUrl = message.thumbnailUrl!;
    }

    // 设置位置字段
    if (message.latitude != null) {
      proto.latitude = message.latitude!;
    }

    if (message.longitude != null) {
      proto.longitude = message.longitude!;
    }

    if (message.locationAddress != null) {
      proto.locationAddress = message.locationAddress!;
    }

    // 设置引用消息
    if (message.quotedMessageId != null) {
      proto.quotedMessageId = message.quotedMessageId!;
    }

    return proto;
  }

  /// 将 Protobuf MessageProto 转换为数据库 Message 模型
  db.Message protoToMessage(MessageProto proto) {
    final message = db.Message()
      ..messageId = proto.messageId
      ..conversationId = proto.conversationId
      ..senderId = proto.senderId
      ..senderName = proto.hasSenderName() ? proto.senderName : null
      ..senderAvatar = proto.hasSenderAvatar() ? proto.senderAvatar : null
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(proto.createdAt.toInt())
      ..isRead = proto.isRead
      ..status = proto.status;

    // 根据枚举值设置字符串类型
    switch (proto.type) {
      case MessageType.text:
        message.type = 'text';
        break;
      case MessageType.image:
        message.type = 'image';
        break;
      case MessageType.voice:
        message.type = 'voice';
        break;
      case MessageType.file:
        message.type = 'file';
        break;
      case MessageType.video:
        message.type = 'video';
        break;
      case MessageType.location:
        message.type = 'location';
        break;
      case MessageType.system:
        message.type = 'system';
        break;
      default:
        message.type = 'text';
    }

    // 设置内容字段
    if (proto.hasText()) {
      message.text = proto.text;
    }

    // 设置媒体字段
    if (proto.hasMediaUrl()) {
      message.mediaUrl = proto.mediaUrl;
    }

    if (proto.hasLocalPath()) {
      message.localPath = proto.localPath;
    }

    if (proto.hasDuration()) {
      message.duration = proto.duration;
    }

    if (proto.hasFileSize()) {
      message.fileSize = proto.fileSize;
    }

    if (proto.hasFileName()) {
      message.fileName = proto.fileName;
    }

    if (proto.hasThumbnailUrl()) {
      message.thumbnailUrl = proto.thumbnailUrl;
    }

    // 设置位置字段
    if (proto.hasLatitude()) {
      message.latitude = proto.latitude;
    }

    if (proto.hasLongitude()) {
      message.longitude = proto.longitude;
    }

    if (proto.hasLocationAddress()) {
      message.locationAddress = proto.locationAddress;
    }

    // 设置引用消息
    if (proto.hasQuotedMessageId()) {
      message.quotedMessageId = proto.quotedMessageId;
    }

    return message;
  }

  /// 将数据库 User 模型转换为 UserSession
  UserSession userToSession(db.User user) {
    final session = UserSession()..userId = user.userId;

    if (user.phone != null) {
      session.phoneNumber = user.phone!;
    }

    return session;
  }

  /// 将 UserSession 转换为数据库 User 模型
  db.User sessionToUser(UserSession session) {
    final user = db.User()
      ..userId = session.userId
      ..name = '' // 需要从其他地方获取名称
      ..phone = session.phoneNumber;

    return user;
  }

  /// 将数据库 Conversation 模型转换为 Protobuf ConversationProto
  ConversationProto conversationToProto(db.Conversation conversation) {
    final proto = ConversationProto()
      ..conversationId = conversation.conversationId
      ..type = conversation.type == db.ConversationType.group ? ConversationType.group : ConversationType.private;

    if (conversation.name != null) {
      proto.name = conversation.name!;
    }

    if (conversation.avatar != null) {
      proto.avatar = conversation.avatar!;
    }

    // 添加参与者ID
    for (final participant in conversation.participants) {
      proto.participantIds.add(participant.userId);
    }

    proto.createdAt = Int64(conversation.createdAt.millisecondsSinceEpoch);

    if (conversation.lastMessageTime != null) {
      proto.lastMessageTime = Int64(conversation.lastMessageTime!.millisecondsSinceEpoch);
    }

    if (conversation.lastMessagePreview != null) {
      proto.lastMessagePreview = conversation.lastMessagePreview!;
    }

    proto.unreadCount = conversation.unreadCount;

    if (conversation.contactUserId != null) {
      proto.contactUserId = conversation.contactUserId!;
    }

    return proto;
  }

  /// 将 Protobuf ConversationProto 转换为数据库 Conversation 模型
  db.Conversation protoToConversation(ConversationProto proto) {
    final conversation = db.Conversation()
      ..conversationId = proto.conversationId
      ..type = proto.type == ConversationType.group ? db.ConversationType.group : db.ConversationType.private
      ..name = proto.hasName() ? proto.name : null
      ..avatar = proto.hasAvatar() ? proto.avatar : null
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(proto.createdAt.toInt())
      ..unreadCount = proto.unreadCount;

    if (proto.hasLastMessageTime()) {
      conversation.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(proto.lastMessageTime.toInt());
    }

    if (proto.hasLastMessagePreview()) {
      conversation.lastMessagePreview = proto.lastMessagePreview;
    }

    if (proto.hasContactUserId()) {
      conversation.contactUserId = proto.contactUserId;
    }

    return conversation;
  }
}
