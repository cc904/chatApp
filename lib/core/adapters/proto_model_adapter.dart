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
    proto.type = _convertMessageType(message.type);

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
      ..status = proto.status
      ..type = _convertProtoMessageType(proto.type);

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

  /// 将数据库 User 模型转换为 Protobuf UserProto
  UserProto userToProto(db.User user) {
    final proto = UserProto()
      ..userId = user.userId
      ..name = user.name;

    // 适应数据库模型的字段
    if (user.avatar != null) {
      proto.avatar = user.avatar!;
    }

    if (user.phone != null) {
      proto.phone = user.phone!;
    }

    if (user.email != null) {
      proto.email = user.email!;
    }

    if (user.pinyin != null) {
      proto.pinyin = user.pinyin!;
    }

    proto.lastActiveTime = Int64(user.lastActiveTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);
    proto.isFriend = user.isFriend;
    proto.status = user.status ?? 'offline';

    // 设置扩展字段
    proto.username = user.name; // 使用name作为username
    proto.displayName = user.name; // 使用name作为displayName

    return proto;
  }

  /// 将 Protobuf UserProto 转换为数据库 User 模型
  db.User protoToUser(UserProto proto) {
    final user = db.User()
      ..userId = proto.userId
      ..name = proto.name
      ..avatar = proto.hasAvatar() ? proto.avatar : null
      ..phone = proto.hasPhone() ? proto.phone : null
      ..email = proto.hasEmail() ? proto.email : null
      ..pinyin = proto.hasPinyin() ? proto.pinyin : null
      ..lastActiveTime = DateTime.fromMillisecondsSinceEpoch(proto.lastActiveTime.toInt())
      ..isFriend = proto.isFriend
      ..status = proto.status;

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

  // 辅助方法：转换消息类型
  MessageType _convertMessageType(db.MessageType dbType) {
    switch (dbType) {
      case db.MessageType.text:
        return MessageType.text;
      case db.MessageType.image:
        return MessageType.image;
      case db.MessageType.voice:
        return MessageType.voice;
      case db.MessageType.file:
        return MessageType.file;
      case db.MessageType.video:
        return MessageType.video;
      case db.MessageType.location:
        return MessageType.location;
      case db.MessageType.system:
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  // 辅助方法：从Proto转换消息类型
  db.MessageType _convertProtoMessageType(MessageType protoType) {
    switch (protoType) {
      case MessageType.text:
        return db.MessageType.text;
      case MessageType.image:
        return db.MessageType.image;
      case MessageType.voice:
        return db.MessageType.voice;
      case MessageType.file:
        return db.MessageType.file;
      case MessageType.video:
        return db.MessageType.video;
      case MessageType.location:
        return db.MessageType.location;
      case MessageType.system:
        return db.MessageType.system;
      default:
        return db.MessageType.text;
    }
  }
}
