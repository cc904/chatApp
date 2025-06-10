//
//  Generated code. Do not modify.
//  source: message.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'message.pbenum.dart';

enum MessageProto_Content {
  textMessage, 
  mediaMessage, 
  systemMessage, 
  stickerMessage, 
  contactMessage, 
  pollMessage, 
  linkMessage, 
  notSet
}

/// 基本消息结构
class MessageProto extends $pb.GeneratedMessage {
  factory MessageProto({
    $core.String? messageId,
    $core.String? conversationId,
    $core.String? senderId,
    $core.String? senderName,
    $core.String? senderAvatar,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
    $fixnum.Int64? index,
    MessageType? type,
    MessageStatus? status,
    $core.String? text,
    $core.String? mediaUrl,
    $core.String? localPath,
    $core.int? duration,
    $core.double? fileSize,
    $core.String? fileName,
    $core.String? thumbnailUrl,
    $core.String? quotedMessageId,
    $core.bool? isDeleted,
    $core.bool? isRevoked,
    $core.bool? isEdited,
    $fixnum.Int64? editedAt,
    $fixnum.Int64? revokedAt,
    $core.String? originalText,
    $core.String? quotedMessageText,
    $core.String? quotedMessageSenderName,
    $core.String? quotedMessageType,
    $core.String? repliedToMessageId,
    $core.String? forwardedFromConversationId,
    $core.String? forwardedFromMessageId,
    $pb.PbMap<$core.String, $core.int>? reactions,
    $core.String? priority,
    $core.Iterable<$core.String>? tags,
    $core.bool? isPinned,
    TextMessage? textMessage,
    MediaMessage? mediaMessage,
    SystemMessage? systemMessage,
    StickerMessage? stickerMessage,
    ContactMessage? contactMessage,
    PollMessage? pollMessage,
    LinkMessage? linkMessage,
  }) {
    final $result = create();
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (senderName != null) {
      $result.senderName = senderName;
    }
    if (senderAvatar != null) {
      $result.senderAvatar = senderAvatar;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    if (index != null) {
      $result.index = index;
    }
    if (type != null) {
      $result.type = type;
    }
    if (status != null) {
      $result.status = status;
    }
    if (text != null) {
      $result.text = text;
    }
    if (mediaUrl != null) {
      $result.mediaUrl = mediaUrl;
    }
    if (localPath != null) {
      $result.localPath = localPath;
    }
    if (duration != null) {
      $result.duration = duration;
    }
    if (fileSize != null) {
      $result.fileSize = fileSize;
    }
    if (fileName != null) {
      $result.fileName = fileName;
    }
    if (thumbnailUrl != null) {
      $result.thumbnailUrl = thumbnailUrl;
    }
    if (quotedMessageId != null) {
      $result.quotedMessageId = quotedMessageId;
    }
    if (isDeleted != null) {
      $result.isDeleted = isDeleted;
    }
    if (isRevoked != null) {
      $result.isRevoked = isRevoked;
    }
    if (isEdited != null) {
      $result.isEdited = isEdited;
    }
    if (editedAt != null) {
      $result.editedAt = editedAt;
    }
    if (revokedAt != null) {
      $result.revokedAt = revokedAt;
    }
    if (originalText != null) {
      $result.originalText = originalText;
    }
    if (quotedMessageText != null) {
      $result.quotedMessageText = quotedMessageText;
    }
    if (quotedMessageSenderName != null) {
      $result.quotedMessageSenderName = quotedMessageSenderName;
    }
    if (quotedMessageType != null) {
      $result.quotedMessageType = quotedMessageType;
    }
    if (repliedToMessageId != null) {
      $result.repliedToMessageId = repliedToMessageId;
    }
    if (forwardedFromConversationId != null) {
      $result.forwardedFromConversationId = forwardedFromConversationId;
    }
    if (forwardedFromMessageId != null) {
      $result.forwardedFromMessageId = forwardedFromMessageId;
    }
    if (reactions != null) {
      $result.reactions.addAll(reactions);
    }
    if (priority != null) {
      $result.priority = priority;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    if (isPinned != null) {
      $result.isPinned = isPinned;
    }
    if (textMessage != null) {
      $result.textMessage = textMessage;
    }
    if (mediaMessage != null) {
      $result.mediaMessage = mediaMessage;
    }
    if (systemMessage != null) {
      $result.systemMessage = systemMessage;
    }
    if (stickerMessage != null) {
      $result.stickerMessage = stickerMessage;
    }
    if (contactMessage != null) {
      $result.contactMessage = contactMessage;
    }
    if (pollMessage != null) {
      $result.pollMessage = pollMessage;
    }
    if (linkMessage != null) {
      $result.linkMessage = linkMessage;
    }
    return $result;
  }
  MessageProto._() : super();
  factory MessageProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, MessageProto_Content> _MessageProto_ContentByTag = {
    38 : MessageProto_Content.textMessage,
    39 : MessageProto_Content.mediaMessage,
    41 : MessageProto_Content.systemMessage,
    42 : MessageProto_Content.stickerMessage,
    43 : MessageProto_Content.contactMessage,
    44 : MessageProto_Content.pollMessage,
    45 : MessageProto_Content.linkMessage,
    0 : MessageProto_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..oo(0, [38, 39, 41, 42, 43, 44, 45])
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'senderId')
    ..aOS(4, _omitFieldNames ? '' : 'senderName')
    ..aOS(5, _omitFieldNames ? '' : 'senderAvatar')
    ..aInt64(6, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(7, _omitFieldNames ? '' : 'updatedAt')
    ..aInt64(8, _omitFieldNames ? '' : 'index')
    ..e<MessageType>(9, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: MessageType.TEXT, valueOf: MessageType.valueOf, enumValues: MessageType.values)
    ..e<MessageStatus>(10, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: MessageStatus.SENDING, valueOf: MessageStatus.valueOf, enumValues: MessageStatus.values)
    ..aOS(11, _omitFieldNames ? '' : 'text')
    ..aOS(12, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(13, _omitFieldNames ? '' : 'localPath')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..a<$core.double>(15, _omitFieldNames ? '' : 'fileSize', $pb.PbFieldType.OD)
    ..aOS(16, _omitFieldNames ? '' : 'fileName')
    ..aOS(17, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aOS(21, _omitFieldNames ? '' : 'quotedMessageId')
    ..aOB(22, _omitFieldNames ? '' : 'isDeleted')
    ..aOB(23, _omitFieldNames ? '' : 'isRevoked')
    ..aOB(24, _omitFieldNames ? '' : 'isEdited')
    ..aInt64(25, _omitFieldNames ? '' : 'editedAt')
    ..aInt64(26, _omitFieldNames ? '' : 'revokedAt')
    ..aOS(27, _omitFieldNames ? '' : 'originalText')
    ..aOS(28, _omitFieldNames ? '' : 'quotedMessageText')
    ..aOS(29, _omitFieldNames ? '' : 'quotedMessageSenderName')
    ..aOS(30, _omitFieldNames ? '' : 'quotedMessageType')
    ..aOS(31, _omitFieldNames ? '' : 'repliedToMessageId')
    ..aOS(32, _omitFieldNames ? '' : 'forwardedFromConversationId')
    ..aOS(33, _omitFieldNames ? '' : 'forwardedFromMessageId')
    ..m<$core.String, $core.int>(34, _omitFieldNames ? '' : 'reactions', entryClassName: 'MessageProto.ReactionsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O3, packageName: const $pb.PackageName('cc'))
    ..aOS(35, _omitFieldNames ? '' : 'priority')
    ..pPS(36, _omitFieldNames ? '' : 'tags')
    ..aOB(37, _omitFieldNames ? '' : 'isPinned')
    ..aOM<TextMessage>(38, _omitFieldNames ? '' : 'textMessage', subBuilder: TextMessage.create)
    ..aOM<MediaMessage>(39, _omitFieldNames ? '' : 'mediaMessage', subBuilder: MediaMessage.create)
    ..aOM<SystemMessage>(41, _omitFieldNames ? '' : 'systemMessage', subBuilder: SystemMessage.create)
    ..aOM<StickerMessage>(42, _omitFieldNames ? '' : 'stickerMessage', subBuilder: StickerMessage.create)
    ..aOM<ContactMessage>(43, _omitFieldNames ? '' : 'contactMessage', subBuilder: ContactMessage.create)
    ..aOM<PollMessage>(44, _omitFieldNames ? '' : 'pollMessage', subBuilder: PollMessage.create)
    ..aOM<LinkMessage>(45, _omitFieldNames ? '' : 'linkMessage', subBuilder: LinkMessage.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageProto clone() => MessageProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageProto copyWith(void Function(MessageProto) updates) => super.copyWith((message) => updates(message as MessageProto)) as MessageProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageProto create() => MessageProto._();
  MessageProto createEmptyInstance() => create();
  static $pb.PbList<MessageProto> createRepeated() => $pb.PbList<MessageProto>();
  @$core.pragma('dart2js:noInline')
  static MessageProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageProto>(create);
  static MessageProto? _defaultInstance;

  MessageProto_Content whichContent() => _MessageProto_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => $_clearField($_whichOneof(0));

  /// 主要字段，完全匹配数据库模型
  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get senderId => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSenderId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderName => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSenderName() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get senderAvatar => $_getSZ(4);
  @$pb.TagNumber(5)
  set senderAvatar($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSenderAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearSenderAvatar() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get createdAt => $_getI64(5);
  @$pb.TagNumber(6)
  set createdAt($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get updatedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set updatedAt($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdatedAt() => $_clearField(7);

  /// 消息序列号 - 用于简化游标管理和排序
  /// 每个会话内的消息有唯一的递增序列号
  /// 服务器分配，客户端不能修改
  @$pb.TagNumber(8)
  $fixnum.Int64 get index => $_getI64(7);
  @$pb.TagNumber(8)
  set index($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearIndex() => $_clearField(8);

  /// 消息状态字段
  @$pb.TagNumber(9)
  MessageType get type => $_getN(8);
  @$pb.TagNumber(9)
  set type(MessageType v) { $_setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => $_clearField(9);

  @$pb.TagNumber(10)
  MessageStatus get status => $_getN(9);
  @$pb.TagNumber(10)
  set status(MessageStatus v) { $_setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatus() => $_clearField(10);

  /// 消息内容
  @$pb.TagNumber(11)
  $core.String get text => $_getSZ(10);
  @$pb.TagNumber(11)
  set text($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasText() => $_has(10);
  @$pb.TagNumber(11)
  void clearText() => $_clearField(11);

  /// 媒体消息相关字段
  @$pb.TagNumber(12)
  $core.String get mediaUrl => $_getSZ(11);
  @$pb.TagNumber(12)
  set mediaUrl($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasMediaUrl() => $_has(11);
  @$pb.TagNumber(12)
  void clearMediaUrl() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get localPath => $_getSZ(12);
  @$pb.TagNumber(13)
  set localPath($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasLocalPath() => $_has(12);
  @$pb.TagNumber(13)
  void clearLocalPath() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get duration => $_getIZ(13);
  @$pb.TagNumber(14)
  set duration($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasDuration() => $_has(13);
  @$pb.TagNumber(14)
  void clearDuration() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get fileSize => $_getN(14);
  @$pb.TagNumber(15)
  set fileSize($core.double v) { $_setDouble(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasFileSize() => $_has(14);
  @$pb.TagNumber(15)
  void clearFileSize() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get fileName => $_getSZ(15);
  @$pb.TagNumber(16)
  set fileName($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasFileName() => $_has(15);
  @$pb.TagNumber(16)
  void clearFileName() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get thumbnailUrl => $_getSZ(16);
  @$pb.TagNumber(17)
  set thumbnailUrl($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasThumbnailUrl() => $_has(16);
  @$pb.TagNumber(17)
  void clearThumbnailUrl() => $_clearField(17);

  /// 引用消息
  @$pb.TagNumber(21)
  $core.String get quotedMessageId => $_getSZ(17);
  @$pb.TagNumber(21)
  set quotedMessageId($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(21)
  $core.bool hasQuotedMessageId() => $_has(17);
  @$pb.TagNumber(21)
  void clearQuotedMessageId() => $_clearField(21);

  /// 扩展字段
  @$pb.TagNumber(22)
  $core.bool get isDeleted => $_getBF(18);
  @$pb.TagNumber(22)
  set isDeleted($core.bool v) { $_setBool(18, v); }
  @$pb.TagNumber(22)
  $core.bool hasIsDeleted() => $_has(18);
  @$pb.TagNumber(22)
  void clearIsDeleted() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.bool get isRevoked => $_getBF(19);
  @$pb.TagNumber(23)
  set isRevoked($core.bool v) { $_setBool(19, v); }
  @$pb.TagNumber(23)
  $core.bool hasIsRevoked() => $_has(19);
  @$pb.TagNumber(23)
  void clearIsRevoked() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.bool get isEdited => $_getBF(20);
  @$pb.TagNumber(24)
  set isEdited($core.bool v) { $_setBool(20, v); }
  @$pb.TagNumber(24)
  $core.bool hasIsEdited() => $_has(20);
  @$pb.TagNumber(24)
  void clearIsEdited() => $_clearField(24);

  @$pb.TagNumber(25)
  $fixnum.Int64 get editedAt => $_getI64(21);
  @$pb.TagNumber(25)
  set editedAt($fixnum.Int64 v) { $_setInt64(21, v); }
  @$pb.TagNumber(25)
  $core.bool hasEditedAt() => $_has(21);
  @$pb.TagNumber(25)
  void clearEditedAt() => $_clearField(25);

  @$pb.TagNumber(26)
  $fixnum.Int64 get revokedAt => $_getI64(22);
  @$pb.TagNumber(26)
  set revokedAt($fixnum.Int64 v) { $_setInt64(22, v); }
  @$pb.TagNumber(26)
  $core.bool hasRevokedAt() => $_has(22);
  @$pb.TagNumber(26)
  void clearRevokedAt() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.String get originalText => $_getSZ(23);
  @$pb.TagNumber(27)
  set originalText($core.String v) { $_setString(23, v); }
  @$pb.TagNumber(27)
  $core.bool hasOriginalText() => $_has(23);
  @$pb.TagNumber(27)
  void clearOriginalText() => $_clearField(27);

  /// 引用消息详细信息（缓存）
  @$pb.TagNumber(28)
  $core.String get quotedMessageText => $_getSZ(24);
  @$pb.TagNumber(28)
  set quotedMessageText($core.String v) { $_setString(24, v); }
  @$pb.TagNumber(28)
  $core.bool hasQuotedMessageText() => $_has(24);
  @$pb.TagNumber(28)
  void clearQuotedMessageText() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get quotedMessageSenderName => $_getSZ(25);
  @$pb.TagNumber(29)
  set quotedMessageSenderName($core.String v) { $_setString(25, v); }
  @$pb.TagNumber(29)
  $core.bool hasQuotedMessageSenderName() => $_has(25);
  @$pb.TagNumber(29)
  void clearQuotedMessageSenderName() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.String get quotedMessageType => $_getSZ(26);
  @$pb.TagNumber(30)
  set quotedMessageType($core.String v) { $_setString(26, v); }
  @$pb.TagNumber(30)
  $core.bool hasQuotedMessageType() => $_has(26);
  @$pb.TagNumber(30)
  void clearQuotedMessageType() => $_clearField(30);

  /// 回复和转发
  @$pb.TagNumber(31)
  $core.String get repliedToMessageId => $_getSZ(27);
  @$pb.TagNumber(31)
  set repliedToMessageId($core.String v) { $_setString(27, v); }
  @$pb.TagNumber(31)
  $core.bool hasRepliedToMessageId() => $_has(27);
  @$pb.TagNumber(31)
  void clearRepliedToMessageId() => $_clearField(31);

  @$pb.TagNumber(32)
  $core.String get forwardedFromConversationId => $_getSZ(28);
  @$pb.TagNumber(32)
  set forwardedFromConversationId($core.String v) { $_setString(28, v); }
  @$pb.TagNumber(32)
  $core.bool hasForwardedFromConversationId() => $_has(28);
  @$pb.TagNumber(32)
  void clearForwardedFromConversationId() => $_clearField(32);

  @$pb.TagNumber(33)
  $core.String get forwardedFromMessageId => $_getSZ(29);
  @$pb.TagNumber(33)
  set forwardedFromMessageId($core.String v) { $_setString(29, v); }
  @$pb.TagNumber(33)
  $core.bool hasForwardedFromMessageId() => $_has(29);
  @$pb.TagNumber(33)
  void clearForwardedFromMessageId() => $_clearField(33);

  /// 消息反应（点赞、表情等）
  @$pb.TagNumber(34)
  $pb.PbMap<$core.String, $core.int> get reactions => $_getMap(30);

  /// 消息优先级和标记
  @$pb.TagNumber(35)
  $core.String get priority => $_getSZ(31);
  @$pb.TagNumber(35)
  set priority($core.String v) { $_setString(31, v); }
  @$pb.TagNumber(35)
  $core.bool hasPriority() => $_has(31);
  @$pb.TagNumber(35)
  void clearPriority() => $_clearField(35);

  @$pb.TagNumber(36)
  $pb.PbList<$core.String> get tags => $_getList(32);

  @$pb.TagNumber(37)
  $core.bool get isPinned => $_getBF(33);
  @$pb.TagNumber(37)
  set isPinned($core.bool v) { $_setBool(33, v); }
  @$pb.TagNumber(37)
  $core.bool hasIsPinned() => $_has(33);
  @$pb.TagNumber(37)
  void clearIsPinned() => $_clearField(37);

  @$pb.TagNumber(38)
  TextMessage get textMessage => $_getN(34);
  @$pb.TagNumber(38)
  set textMessage(TextMessage v) { $_setField(38, v); }
  @$pb.TagNumber(38)
  $core.bool hasTextMessage() => $_has(34);
  @$pb.TagNumber(38)
  void clearTextMessage() => $_clearField(38);
  @$pb.TagNumber(38)
  TextMessage ensureTextMessage() => $_ensure(34);

  @$pb.TagNumber(39)
  MediaMessage get mediaMessage => $_getN(35);
  @$pb.TagNumber(39)
  set mediaMessage(MediaMessage v) { $_setField(39, v); }
  @$pb.TagNumber(39)
  $core.bool hasMediaMessage() => $_has(35);
  @$pb.TagNumber(39)
  void clearMediaMessage() => $_clearField(39);
  @$pb.TagNumber(39)
  MediaMessage ensureMediaMessage() => $_ensure(35);

  @$pb.TagNumber(41)
  SystemMessage get systemMessage => $_getN(36);
  @$pb.TagNumber(41)
  set systemMessage(SystemMessage v) { $_setField(41, v); }
  @$pb.TagNumber(41)
  $core.bool hasSystemMessage() => $_has(36);
  @$pb.TagNumber(41)
  void clearSystemMessage() => $_clearField(41);
  @$pb.TagNumber(41)
  SystemMessage ensureSystemMessage() => $_ensure(36);

  @$pb.TagNumber(42)
  StickerMessage get stickerMessage => $_getN(37);
  @$pb.TagNumber(42)
  set stickerMessage(StickerMessage v) { $_setField(42, v); }
  @$pb.TagNumber(42)
  $core.bool hasStickerMessage() => $_has(37);
  @$pb.TagNumber(42)
  void clearStickerMessage() => $_clearField(42);
  @$pb.TagNumber(42)
  StickerMessage ensureStickerMessage() => $_ensure(37);

  @$pb.TagNumber(43)
  ContactMessage get contactMessage => $_getN(38);
  @$pb.TagNumber(43)
  set contactMessage(ContactMessage v) { $_setField(43, v); }
  @$pb.TagNumber(43)
  $core.bool hasContactMessage() => $_has(38);
  @$pb.TagNumber(43)
  void clearContactMessage() => $_clearField(43);
  @$pb.TagNumber(43)
  ContactMessage ensureContactMessage() => $_ensure(38);

  @$pb.TagNumber(44)
  PollMessage get pollMessage => $_getN(39);
  @$pb.TagNumber(44)
  set pollMessage(PollMessage v) { $_setField(44, v); }
  @$pb.TagNumber(44)
  $core.bool hasPollMessage() => $_has(39);
  @$pb.TagNumber(44)
  void clearPollMessage() => $_clearField(44);
  @$pb.TagNumber(44)
  PollMessage ensurePollMessage() => $_ensure(39);

  @$pb.TagNumber(45)
  LinkMessage get linkMessage => $_getN(40);
  @$pb.TagNumber(45)
  set linkMessage(LinkMessage v) { $_setField(45, v); }
  @$pb.TagNumber(45)
  $core.bool hasLinkMessage() => $_has(40);
  @$pb.TagNumber(45)
  void clearLinkMessage() => $_clearField(45);
  @$pb.TagNumber(45)
  LinkMessage ensureLinkMessage() => $_ensure(40);
}

/// 文本消息内容
class TextMessage extends $pb.GeneratedMessage {
  factory TextMessage({
    $core.String? text,
    $core.Iterable<$core.String>? mentions,
    $core.Iterable<$core.String>? hashtags,
    $core.Iterable<LinkPreview>? links,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    if (mentions != null) {
      $result.mentions.addAll(mentions);
    }
    if (hashtags != null) {
      $result.hashtags.addAll(hashtags);
    }
    if (links != null) {
      $result.links.addAll(links);
    }
    return $result;
  }
  TextMessage._() : super();
  factory TextMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TextMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TextMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..pPS(2, _omitFieldNames ? '' : 'mentions')
    ..pPS(3, _omitFieldNames ? '' : 'hashtags')
    ..pc<LinkPreview>(4, _omitFieldNames ? '' : 'links', $pb.PbFieldType.PM, subBuilder: LinkPreview.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TextMessage clone() => TextMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TextMessage copyWith(void Function(TextMessage) updates) => super.copyWith((message) => updates(message as TextMessage)) as TextMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextMessage create() => TextMessage._();
  TextMessage createEmptyInstance() => create();
  static $pb.PbList<TextMessage> createRepeated() => $pb.PbList<TextMessage>();
  @$core.pragma('dart2js:noInline')
  static TextMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TextMessage>(create);
  static TextMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get mentions => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get hashtags => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<LinkPreview> get links => $_getList(3);
}

/// 媒体消息内容（图片、语音、文件、视频）
class MediaMessage extends $pb.GeneratedMessage {
  factory MediaMessage({
    $core.String? mediaUrl,
    $core.String? localPath,
    $core.int? duration,
    $core.double? fileSize,
    $core.String? fileName,
    $core.String? thumbnailUrl,
    $core.String? mimeType,
    $core.int? width,
    $core.int? height,
    $core.String? caption,
  }) {
    final $result = create();
    if (mediaUrl != null) {
      $result.mediaUrl = mediaUrl;
    }
    if (localPath != null) {
      $result.localPath = localPath;
    }
    if (duration != null) {
      $result.duration = duration;
    }
    if (fileSize != null) {
      $result.fileSize = fileSize;
    }
    if (fileName != null) {
      $result.fileName = fileName;
    }
    if (thumbnailUrl != null) {
      $result.thumbnailUrl = thumbnailUrl;
    }
    if (mimeType != null) {
      $result.mimeType = mimeType;
    }
    if (width != null) {
      $result.width = width;
    }
    if (height != null) {
      $result.height = height;
    }
    if (caption != null) {
      $result.caption = caption;
    }
    return $result;
  }
  MediaMessage._() : super();
  factory MediaMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MediaMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(2, _omitFieldNames ? '' : 'localPath')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'fileSize', $pb.PbFieldType.OD)
    ..aOS(5, _omitFieldNames ? '' : 'fileName')
    ..aOS(6, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aOS(7, _omitFieldNames ? '' : 'mimeType')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..aOS(10, _omitFieldNames ? '' : 'caption')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MediaMessage clone() => MediaMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MediaMessage copyWith(void Function(MediaMessage) updates) => super.copyWith((message) => updates(message as MediaMessage)) as MediaMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaMessage create() => MediaMessage._();
  MediaMessage createEmptyInstance() => create();
  static $pb.PbList<MediaMessage> createRepeated() => $pb.PbList<MediaMessage>();
  @$core.pragma('dart2js:noInline')
  static MediaMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaMessage>(create);
  static MediaMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaUrl($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMediaUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get localPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set localPath($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLocalPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearLocalPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get duration => $_getIZ(2);
  @$pb.TagNumber(3)
  set duration($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDuration() => $_has(2);
  @$pb.TagNumber(3)
  void clearDuration() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get fileSize => $_getN(3);
  @$pb.TagNumber(4)
  set fileSize($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFileSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fileName => $_getSZ(4);
  @$pb.TagNumber(5)
  set fileName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFileName() => $_has(4);
  @$pb.TagNumber(5)
  void clearFileName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get thumbnailUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set thumbnailUrl($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasThumbnailUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearThumbnailUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get mimeType => $_getSZ(6);
  @$pb.TagNumber(7)
  set mimeType($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMimeType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMimeType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get width => $_getIZ(7);
  @$pb.TagNumber(8)
  set width($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasWidth() => $_has(7);
  @$pb.TagNumber(8)
  void clearWidth() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get height => $_getIZ(8);
  @$pb.TagNumber(9)
  set height($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearHeight() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get caption => $_getSZ(9);
  @$pb.TagNumber(10)
  set caption($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasCaption() => $_has(9);
  @$pb.TagNumber(10)
  void clearCaption() => $_clearField(10);
}

/// 系统消息内容
class SystemMessage extends $pb.GeneratedMessage {
  factory SystemMessage({
    $core.String? text,
    $core.String? action,
    $pb.PbMap<$core.String, $core.String>? params,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    if (action != null) {
      $result.action = action;
    }
    if (params != null) {
      $result.params.addAll(params);
    }
    return $result;
  }
  SystemMessage._() : super();
  factory SystemMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SystemMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'action')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'params', entryClassName: 'SystemMessage.ParamsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('cc'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SystemMessage clone() => SystemMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SystemMessage copyWith(void Function(SystemMessage) updates) => super.copyWith((message) => updates(message as SystemMessage)) as SystemMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemMessage create() => SystemMessage._();
  SystemMessage createEmptyInstance() => create();
  static $pb.PbList<SystemMessage> createRepeated() => $pb.PbList<SystemMessage>();
  @$core.pragma('dart2js:noInline')
  static SystemMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemMessage>(create);
  static SystemMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get action => $_getSZ(1);
  @$pb.TagNumber(2)
  set action($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get params => $_getMap(2);
}

/// 表情包消息
class StickerMessage extends $pb.GeneratedMessage {
  factory StickerMessage({
    $core.String? stickerId,
    $core.String? stickerUrl,
    $core.String? stickerPackId,
    $core.String? stickerPackName,
  }) {
    final $result = create();
    if (stickerId != null) {
      $result.stickerId = stickerId;
    }
    if (stickerUrl != null) {
      $result.stickerUrl = stickerUrl;
    }
    if (stickerPackId != null) {
      $result.stickerPackId = stickerPackId;
    }
    if (stickerPackName != null) {
      $result.stickerPackName = stickerPackName;
    }
    return $result;
  }
  StickerMessage._() : super();
  factory StickerMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StickerMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StickerMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stickerId')
    ..aOS(2, _omitFieldNames ? '' : 'stickerUrl')
    ..aOS(3, _omitFieldNames ? '' : 'stickerPackId')
    ..aOS(4, _omitFieldNames ? '' : 'stickerPackName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StickerMessage clone() => StickerMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StickerMessage copyWith(void Function(StickerMessage) updates) => super.copyWith((message) => updates(message as StickerMessage)) as StickerMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StickerMessage create() => StickerMessage._();
  StickerMessage createEmptyInstance() => create();
  static $pb.PbList<StickerMessage> createRepeated() => $pb.PbList<StickerMessage>();
  @$core.pragma('dart2js:noInline')
  static StickerMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StickerMessage>(create);
  static StickerMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stickerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set stickerId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStickerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStickerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get stickerUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set stickerUrl($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStickerUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearStickerUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get stickerPackId => $_getSZ(2);
  @$pb.TagNumber(3)
  set stickerPackId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStickerPackId() => $_has(2);
  @$pb.TagNumber(3)
  void clearStickerPackId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get stickerPackName => $_getSZ(3);
  @$pb.TagNumber(4)
  set stickerPackName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStickerPackName() => $_has(3);
  @$pb.TagNumber(4)
  void clearStickerPackName() => $_clearField(4);
}

/// 联系人名片消息
class ContactMessage extends $pb.GeneratedMessage {
  factory ContactMessage({
    $core.String? contactId,
    $core.String? contactName,
    $core.String? contactPhone,
    $core.String? contactAvatar,
    $core.String? contactEmail,
  }) {
    final $result = create();
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (contactName != null) {
      $result.contactName = contactName;
    }
    if (contactPhone != null) {
      $result.contactPhone = contactPhone;
    }
    if (contactAvatar != null) {
      $result.contactAvatar = contactAvatar;
    }
    if (contactEmail != null) {
      $result.contactEmail = contactEmail;
    }
    return $result;
  }
  ContactMessage._() : super();
  factory ContactMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contactId')
    ..aOS(2, _omitFieldNames ? '' : 'contactName')
    ..aOS(3, _omitFieldNames ? '' : 'contactPhone')
    ..aOS(4, _omitFieldNames ? '' : 'contactAvatar')
    ..aOS(5, _omitFieldNames ? '' : 'contactEmail')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactMessage clone() => ContactMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactMessage copyWith(void Function(ContactMessage) updates) => super.copyWith((message) => updates(message as ContactMessage)) as ContactMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactMessage create() => ContactMessage._();
  ContactMessage createEmptyInstance() => create();
  static $pb.PbList<ContactMessage> createRepeated() => $pb.PbList<ContactMessage>();
  @$core.pragma('dart2js:noInline')
  static ContactMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactMessage>(create);
  static ContactMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contactId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contactId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get contactName => $_getSZ(1);
  @$pb.TagNumber(2)
  set contactName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasContactName() => $_has(1);
  @$pb.TagNumber(2)
  void clearContactName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get contactPhone => $_getSZ(2);
  @$pb.TagNumber(3)
  set contactPhone($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContactPhone() => $_has(2);
  @$pb.TagNumber(3)
  void clearContactPhone() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get contactAvatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set contactAvatar($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasContactAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearContactAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get contactEmail => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactEmail($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactEmail() => $_clearField(5);
}

/// 投票消息
class PollMessage extends $pb.GeneratedMessage {
  factory PollMessage({
    $core.String? pollId,
    $core.String? question,
    $core.Iterable<PollOption>? options,
    $core.bool? isMultipleChoice,
    $fixnum.Int64? expiresAt,
    $core.bool? isAnonymous,
  }) {
    final $result = create();
    if (pollId != null) {
      $result.pollId = pollId;
    }
    if (question != null) {
      $result.question = question;
    }
    if (options != null) {
      $result.options.addAll(options);
    }
    if (isMultipleChoice != null) {
      $result.isMultipleChoice = isMultipleChoice;
    }
    if (expiresAt != null) {
      $result.expiresAt = expiresAt;
    }
    if (isAnonymous != null) {
      $result.isAnonymous = isAnonymous;
    }
    return $result;
  }
  PollMessage._() : super();
  factory PollMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PollMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PollMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pollId')
    ..aOS(2, _omitFieldNames ? '' : 'question')
    ..pc<PollOption>(3, _omitFieldNames ? '' : 'options', $pb.PbFieldType.PM, subBuilder: PollOption.create)
    ..aOB(4, _omitFieldNames ? '' : 'isMultipleChoice')
    ..aInt64(5, _omitFieldNames ? '' : 'expiresAt')
    ..aOB(6, _omitFieldNames ? '' : 'isAnonymous')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PollMessage clone() => PollMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PollMessage copyWith(void Function(PollMessage) updates) => super.copyWith((message) => updates(message as PollMessage)) as PollMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PollMessage create() => PollMessage._();
  PollMessage createEmptyInstance() => create();
  static $pb.PbList<PollMessage> createRepeated() => $pb.PbList<PollMessage>();
  @$core.pragma('dart2js:noInline')
  static PollMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PollMessage>(create);
  static PollMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pollId => $_getSZ(0);
  @$pb.TagNumber(1)
  set pollId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPollId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPollId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get question => $_getSZ(1);
  @$pb.TagNumber(2)
  set question($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuestion() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuestion() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<PollOption> get options => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get isMultipleChoice => $_getBF(3);
  @$pb.TagNumber(4)
  set isMultipleChoice($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsMultipleChoice() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsMultipleChoice() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expiresAt => $_getI64(4);
  @$pb.TagNumber(5)
  set expiresAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiresAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isAnonymous => $_getBF(5);
  @$pb.TagNumber(6)
  set isAnonymous($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsAnonymous() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsAnonymous() => $_clearField(6);
}

/// 投票选项
class PollOption extends $pb.GeneratedMessage {
  factory PollOption({
    $core.String? optionId,
    $core.String? text,
    $core.int? voteCount,
    $core.Iterable<$core.String>? voterIds,
  }) {
    final $result = create();
    if (optionId != null) {
      $result.optionId = optionId;
    }
    if (text != null) {
      $result.text = text;
    }
    if (voteCount != null) {
      $result.voteCount = voteCount;
    }
    if (voterIds != null) {
      $result.voterIds.addAll(voterIds);
    }
    return $result;
  }
  PollOption._() : super();
  factory PollOption.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PollOption.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PollOption', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'optionId')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'voteCount', $pb.PbFieldType.O3)
    ..pPS(4, _omitFieldNames ? '' : 'voterIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PollOption clone() => PollOption()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PollOption copyWith(void Function(PollOption) updates) => super.copyWith((message) => updates(message as PollOption)) as PollOption;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PollOption create() => PollOption._();
  PollOption createEmptyInstance() => create();
  static $pb.PbList<PollOption> createRepeated() => $pb.PbList<PollOption>();
  @$core.pragma('dart2js:noInline')
  static PollOption getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PollOption>(create);
  static PollOption? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get optionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set optionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOptionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get voteCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set voteCount($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVoteCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoteCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get voterIds => $_getList(3);
}

/// 链接消息
class LinkMessage extends $pb.GeneratedMessage {
  factory LinkMessage({
    $core.String? url,
    LinkPreview? preview,
  }) {
    final $result = create();
    if (url != null) {
      $result.url = url;
    }
    if (preview != null) {
      $result.preview = preview;
    }
    return $result;
  }
  LinkMessage._() : super();
  factory LinkMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LinkMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOM<LinkPreview>(2, _omitFieldNames ? '' : 'preview', subBuilder: LinkPreview.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LinkMessage clone() => LinkMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LinkMessage copyWith(void Function(LinkMessage) updates) => super.copyWith((message) => updates(message as LinkMessage)) as LinkMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkMessage create() => LinkMessage._();
  LinkMessage createEmptyInstance() => create();
  static $pb.PbList<LinkMessage> createRepeated() => $pb.PbList<LinkMessage>();
  @$core.pragma('dart2js:noInline')
  static LinkMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkMessage>(create);
  static LinkMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  LinkPreview get preview => $_getN(1);
  @$pb.TagNumber(2)
  set preview(LinkPreview v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPreview() => $_has(1);
  @$pb.TagNumber(2)
  void clearPreview() => $_clearField(2);
  @$pb.TagNumber(2)
  LinkPreview ensurePreview() => $_ensure(1);
}

/// 链接预览
class LinkPreview extends $pb.GeneratedMessage {
  factory LinkPreview({
    $core.String? url,
    $core.String? title,
    $core.String? description,
    $core.String? imageUrl,
    $core.String? siteName,
    $core.String? faviconUrl,
  }) {
    final $result = create();
    if (url != null) {
      $result.url = url;
    }
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (imageUrl != null) {
      $result.imageUrl = imageUrl;
    }
    if (siteName != null) {
      $result.siteName = siteName;
    }
    if (faviconUrl != null) {
      $result.faviconUrl = faviconUrl;
    }
    return $result;
  }
  LinkPreview._() : super();
  factory LinkPreview.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LinkPreview.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkPreview', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'imageUrl')
    ..aOS(5, _omitFieldNames ? '' : 'siteName')
    ..aOS(6, _omitFieldNames ? '' : 'faviconUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LinkPreview clone() => LinkPreview()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LinkPreview copyWith(void Function(LinkPreview) updates) => super.copyWith((message) => updates(message as LinkPreview)) as LinkPreview;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkPreview create() => LinkPreview._();
  LinkPreview createEmptyInstance() => create();
  static $pb.PbList<LinkPreview> createRepeated() => $pb.PbList<LinkPreview>();
  @$core.pragma('dart2js:noInline')
  static LinkPreview getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkPreview>(create);
  static LinkPreview? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get imageUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set imageUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasImageUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get siteName => $_getSZ(4);
  @$pb.TagNumber(5)
  set siteName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSiteName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSiteName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get faviconUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set faviconUrl($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFaviconUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearFaviconUrl() => $_clearField(6);
}

/// 消息集合，用于批量操作
class MessageCollection extends $pb.GeneratedMessage {
  factory MessageCollection({
    $core.Iterable<MessageProto>? messages,
    $core.int? totalCount,
    $core.bool? hasMore,
    $core.String? nextCursor,
  }) {
    final $result = create();
    if (messages != null) {
      $result.messages.addAll(messages);
    }
    if (totalCount != null) {
      $result.totalCount = totalCount;
    }
    if (hasMore != null) {
      $result.hasMore = hasMore;
    }
    if (nextCursor != null) {
      $result.nextCursor = nextCursor;
    }
    return $result;
  }
  MessageCollection._() : super();
  factory MessageCollection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageCollection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageCollection', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<MessageProto>(1, _omitFieldNames ? '' : 'messages', $pb.PbFieldType.PM, subBuilder: MessageProto.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'hasMore')
    ..aOS(4, _omitFieldNames ? '' : 'nextCursor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageCollection clone() => MessageCollection()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageCollection copyWith(void Function(MessageCollection) updates) => super.copyWith((message) => updates(message as MessageCollection)) as MessageCollection;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageCollection create() => MessageCollection._();
  MessageCollection createEmptyInstance() => create();
  static $pb.PbList<MessageCollection> createRepeated() => $pb.PbList<MessageCollection>();
  @$core.pragma('dart2js:noInline')
  static MessageCollection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageCollection>(create);
  static MessageCollection? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MessageProto> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasMore => $_getBF(2);
  @$pb.TagNumber(3)
  set hasMore($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHasMore() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasMore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get nextCursor => $_getSZ(3);
  @$pb.TagNumber(4)
  set nextCursor($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNextCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearNextCursor() => $_clearField(4);
}

/// 消息响应结构
class MessageResponse extends $pb.GeneratedMessage {
  factory MessageResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? messageId,
    $fixnum.Int64? timestamp,
    $core.String? tempId,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (tempId != null) {
      $result.tempId = tempId;
    }
    return $result;
  }
  MessageResponse._() : super();
  factory MessageResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'messageId')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..aOS(5, _omitFieldNames ? '' : 'tempId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageResponse clone() => MessageResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageResponse copyWith(void Function(MessageResponse) updates) => super.copyWith((message) => updates(message as MessageResponse)) as MessageResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageResponse create() => MessageResponse._();
  MessageResponse createEmptyInstance() => create();
  static $pb.PbList<MessageResponse> createRepeated() => $pb.PbList<MessageResponse>();
  @$core.pragma('dart2js:noInline')
  static MessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageResponse>(create);
  static MessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get messageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get tempId => $_getSZ(4);
  @$pb.TagNumber(5)
  set tempId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTempId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTempId() => $_clearField(5);
}

/// 输入状态
/// 只有私聊会话需要同步输入状态
class TypingProto extends $pb.GeneratedMessage {
  factory TypingProto({
    $core.String? conversationId,
    $core.bool? isTyping,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (isTyping != null) {
      $result.isTyping = isTyping;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  TypingProto._() : super();
  factory TypingProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TypingProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TypingProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TypingProto clone() => TypingProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TypingProto copyWith(void Function(TypingProto) updates) => super.copyWith((message) => updates(message as TypingProto)) as TypingProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingProto create() => TypingProto._();
  TypingProto createEmptyInstance() => create();
  static $pb.PbList<TypingProto> createRepeated() => $pb.PbList<TypingProto>();
  @$core.pragma('dart2js:noInline')
  static TypingProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TypingProto>(create);
  static TypingProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(1);
  @$pb.TagNumber(3)
  set isTyping($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(1);
  @$pb.TagNumber(3)
  void clearIsTyping() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// 消息已读
class MessageReadProto extends $pb.GeneratedMessage {
  factory MessageReadProto({
    $core.String? messageId,
    $core.String? conversationId,
    $core.String? userId,
    $fixnum.Int64? readAt,
  }) {
    final $result = create();
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (readAt != null) {
      $result.readAt = readAt;
    }
    return $result;
  }
  MessageReadProto._() : super();
  factory MessageReadProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageReadProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageReadProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aInt64(4, _omitFieldNames ? '' : 'readAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageReadProto clone() => MessageReadProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageReadProto copyWith(void Function(MessageReadProto) updates) => super.copyWith((message) => updates(message as MessageReadProto)) as MessageReadProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageReadProto create() => MessageReadProto._();
  MessageReadProto createEmptyInstance() => create();
  static $pb.PbList<MessageReadProto> createRepeated() => $pb.PbList<MessageReadProto>();
  @$core.pragma('dart2js:noInline')
  static MessageReadProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageReadProto>(create);
  static MessageReadProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get readAt => $_getI64(3);
  @$pb.TagNumber(4)
  set readAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReadAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadAt() => $_clearField(4);
}

/// 每日消息统计
class DailyMessageCount extends $pb.GeneratedMessage {
  factory DailyMessageCount({
    $core.String? date,
    $core.int? count,
  }) {
    final $result = create();
    if (date != null) {
      $result.date = date;
    }
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  DailyMessageCount._() : super();
  factory DailyMessageCount.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DailyMessageCount.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DailyMessageCount', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DailyMessageCount clone() => DailyMessageCount()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DailyMessageCount copyWith(void Function(DailyMessageCount) updates) => super.copyWith((message) => updates(message as DailyMessageCount)) as DailyMessageCount;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DailyMessageCount create() => DailyMessageCount._();
  DailyMessageCount createEmptyInstance() => create();
  static $pb.PbList<DailyMessageCount> createRepeated() => $pb.PbList<DailyMessageCount>();
  @$core.pragma('dart2js:noInline')
  static DailyMessageCount getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DailyMessageCount>(create);
  static DailyMessageCount? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

/// 消息同步请求 - 使用index简化游标管理 messages:sync
/// 业务逻辑说明：
/// 1. conversation_id: 必填，指定要同步的会话
/// 2. from_index: 可选，客户端本地最新消息的index
///    - 如果为空或0：表示客户端本地无消息，同步最新一页的消息即可
///    - 如果有值：表示客户端有本地消息，同步该index之后的消息
/// 3. limit: 可选，获取消息数量，默认50
class MessageSyncRequest extends $pb.GeneratedMessage {
  factory MessageSyncRequest({
    $core.String? conversationId,
    $fixnum.Int64? fromIndex,
    $core.int? limit,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (fromIndex != null) {
      $result.fromIndex = fromIndex;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  MessageSyncRequest._() : super();
  factory MessageSyncRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageSyncRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageSyncRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'fromIndex')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageSyncRequest clone() => MessageSyncRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageSyncRequest copyWith(void Function(MessageSyncRequest) updates) => super.copyWith((message) => updates(message as MessageSyncRequest)) as MessageSyncRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageSyncRequest create() => MessageSyncRequest._();
  MessageSyncRequest createEmptyInstance() => create();
  static $pb.PbList<MessageSyncRequest> createRepeated() => $pb.PbList<MessageSyncRequest>();
  @$core.pragma('dart2js:noInline')
  static MessageSyncRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageSyncRequest>(create);
  static MessageSyncRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get fromIndex => $_getI64(1);
  @$pb.TagNumber(2)
  set fromIndex($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFromIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

///  消息同步响应 - 基于Index的极简处理逻辑 messages:sync:response
///  🚀 服务器端处理逻辑（Index-based，极大简化）：
///  当收到MessageSyncRequest时：
///
///  1. 如果from_index为空或为0：
///     - 初始加载：返回该会话最新的一页消息（默认50条）
///     - 按message_index降序排列，然后反转为升序返回
///     - 设置has_more_before=true（如果消息数量=limit）
///     - 设置has_more_after=false（因为是最新消息）
///
///  2. 如果from_index有值：
///     - 增量同步：返回message_index > from_index的所有新消息
///     - 按message_index升序排列
///     - 设置has_more_before=true（肯定有更早的消息）
///     - 设置has_more_after=true（如果返回消息数量=limit，表示可能还有更多）
///
///  🔥 极简SQL查询示例：
///  初始加载：SELECT * FROM messages WHERE conversation_id=? ORDER BY message_index DESC LIMIT ?
///  增量同步：SELECT * FROM messages WHERE conversation_id=? AND message_index>? ORDER BY message_index ASC LIMIT ?
///
///  🎯 优势对比：
///  ❌ 旧方案：复杂的未读消息判断 + 时间戳计算 + 游标管理
///  ✅ 新方案：简单的数字比较 + 单一索引查询 + 绝对可靠排序
///
///  📈 性能提升：
///  - 查询复杂度：O(log n) 稳定性能
///  - 服务器逻辑：从几百行代码简化到几十行
///  - 调试难度：从几乎不可能变成一目了然
class MessageSyncResponse extends $pb.GeneratedMessage {
  factory MessageSyncResponse({
    $core.bool? success,
    $core.String? conversationId,
    MessageCollection? messages,
    $core.bool? hasMoreBefore,
    $core.bool? hasMoreAfter,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (messages != null) {
      $result.messages = messages;
    }
    if (hasMoreBefore != null) {
      $result.hasMoreBefore = hasMoreBefore;
    }
    if (hasMoreAfter != null) {
      $result.hasMoreAfter = hasMoreAfter;
    }
    return $result;
  }
  MessageSyncResponse._() : super();
  factory MessageSyncResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageSyncResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageSyncResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOM<MessageCollection>(3, _omitFieldNames ? '' : 'messages', subBuilder: MessageCollection.create)
    ..aOB(4, _omitFieldNames ? '' : 'hasMoreBefore')
    ..aOB(5, _omitFieldNames ? '' : 'hasMoreAfter')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageSyncResponse clone() => MessageSyncResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageSyncResponse copyWith(void Function(MessageSyncResponse) updates) => super.copyWith((message) => updates(message as MessageSyncResponse)) as MessageSyncResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageSyncResponse create() => MessageSyncResponse._();
  MessageSyncResponse createEmptyInstance() => create();
  static $pb.PbList<MessageSyncResponse> createRepeated() => $pb.PbList<MessageSyncResponse>();
  @$core.pragma('dart2js:noInline')
  static MessageSyncResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageSyncResponse>(create);
  static MessageSyncResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  MessageCollection get messages => $_getN(2);
  @$pb.TagNumber(3)
  set messages(MessageCollection v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessages() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessages() => $_clearField(3);
  @$pb.TagNumber(3)
  MessageCollection ensureMessages() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.bool get hasMoreBefore => $_getBF(3);
  @$pb.TagNumber(4)
  set hasMoreBefore($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHasMoreBefore() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasMoreBefore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasMoreAfter => $_getBF(4);
  @$pb.TagNumber(5)
  set hasMoreAfter($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHasMoreAfter() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasMoreAfter() => $_clearField(5);
}

///  历史消息获取请求 - 基于Index的极简实现 messages:history
///  🚀 服务器端处理逻辑（Index-based，超级简单）：
///  1. 获取message_index < before_index的消息
///  2. 按message_index降序排列，取limit条
///  3. 反转为升序返回（保持时间顺序）
///  4. 设置has_more_history=true（如果返回数量=limit）
///
///  🔥 极简SQL查询：
///  SELECT * FROM messages
///  WHERE conversation_id=? AND message_index<?
///  ORDER BY message_index DESC
///  LIMIT ?
///
///  🎯 优势：
///  ❌ 旧方案：复杂的时间戳范围查询 + 偏移量计算 + 边界处理
///  ✅ 新方案：简单的数字比较 + 单一查询 + 绝对可靠分页
class HistoryMessagesRequest extends $pb.GeneratedMessage {
  factory HistoryMessagesRequest({
    $core.String? conversationId,
    $fixnum.Int64? beforeIndex,
    $core.int? limit,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (beforeIndex != null) {
      $result.beforeIndex = beforeIndex;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  HistoryMessagesRequest._() : super();
  factory HistoryMessagesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HistoryMessagesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HistoryMessagesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'beforeIndex')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HistoryMessagesRequest clone() => HistoryMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HistoryMessagesRequest copyWith(void Function(HistoryMessagesRequest) updates) => super.copyWith((message) => updates(message as HistoryMessagesRequest)) as HistoryMessagesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HistoryMessagesRequest create() => HistoryMessagesRequest._();
  HistoryMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<HistoryMessagesRequest> createRepeated() => $pb.PbList<HistoryMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static HistoryMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HistoryMessagesRequest>(create);
  static HistoryMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get beforeIndex => $_getI64(1);
  @$pb.TagNumber(2)
  set beforeIndex($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBeforeIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearBeforeIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

/// 历史消息获取响应
class HistoryMessagesResponse extends $pb.GeneratedMessage {
  factory HistoryMessagesResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? conversationId,
    MessageCollection? messagesCollection,
    $core.bool? hasMoreHistory,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (messagesCollection != null) {
      $result.messagesCollection = messagesCollection;
    }
    if (hasMoreHistory != null) {
      $result.hasMoreHistory = hasMoreHistory;
    }
    return $result;
  }
  HistoryMessagesResponse._() : super();
  factory HistoryMessagesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HistoryMessagesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HistoryMessagesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOM<MessageCollection>(4, _omitFieldNames ? '' : 'messagesCollection', protoName: 'messagesCollection', subBuilder: MessageCollection.create)
    ..aOB(5, _omitFieldNames ? '' : 'hasMoreHistory')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HistoryMessagesResponse clone() => HistoryMessagesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HistoryMessagesResponse copyWith(void Function(HistoryMessagesResponse) updates) => super.copyWith((message) => updates(message as HistoryMessagesResponse)) as HistoryMessagesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HistoryMessagesResponse create() => HistoryMessagesResponse._();
  HistoryMessagesResponse createEmptyInstance() => create();
  static $pb.PbList<HistoryMessagesResponse> createRepeated() => $pb.PbList<HistoryMessagesResponse>();
  @$core.pragma('dart2js:noInline')
  static HistoryMessagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HistoryMessagesResponse>(create);
  static HistoryMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  MessageCollection get messagesCollection => $_getN(3);
  @$pb.TagNumber(4)
  set messagesCollection(MessageCollection v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMessagesCollection() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessagesCollection() => $_clearField(4);
  @$pb.TagNumber(4)
  MessageCollection ensureMessagesCollection() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get hasMoreHistory => $_getBF(4);
  @$pb.TagNumber(5)
  set hasMoreHistory($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHasMoreHistory() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasMoreHistory() => $_clearField(5);
}

/// 消息范围查询请求（根据时间范围）- 🔄 在Index方案中已简化
/// 注意：Index-based方案中，大部分范围查询都可以用简单的index比较替代
/// 如需要时间范围查询，建议先转换为index范围，然后使用上述简化接口
class MessageRangeRequest extends $pb.GeneratedMessage {
  factory MessageRangeRequest({
    $core.String? conversationId,
    $fixnum.Int64? startTimestamp,
    $fixnum.Int64? endTimestamp,
    $core.int? limit,
    $core.int? offset,
    $core.String? order,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (startTimestamp != null) {
      $result.startTimestamp = startTimestamp;
    }
    if (endTimestamp != null) {
      $result.endTimestamp = endTimestamp;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    if (order != null) {
      $result.order = order;
    }
    return $result;
  }
  MessageRangeRequest._() : super();
  factory MessageRangeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageRangeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageRangeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'startTimestamp')
    ..aInt64(3, _omitFieldNames ? '' : 'endTimestamp')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'order')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageRangeRequest clone() => MessageRangeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageRangeRequest copyWith(void Function(MessageRangeRequest) updates) => super.copyWith((message) => updates(message as MessageRangeRequest)) as MessageRangeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageRangeRequest create() => MessageRangeRequest._();
  MessageRangeRequest createEmptyInstance() => create();
  static $pb.PbList<MessageRangeRequest> createRepeated() => $pb.PbList<MessageRangeRequest>();
  @$core.pragma('dart2js:noInline')
  static MessageRangeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageRangeRequest>(create);
  static MessageRangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set startTimestamp($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTimestamp() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set endTimestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEndTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get offset => $_getIZ(4);
  @$pb.TagNumber(5)
  set offset($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearOffset() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get order => $_getSZ(5);
  @$pb.TagNumber(6)
  set order($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasOrder() => $_has(5);
  @$pb.TagNumber(6)
  void clearOrder() => $_clearField(6);
}

/// 消息范围查询响应
class MessageRangeResponse extends $pb.GeneratedMessage {
  factory MessageRangeResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? conversationId,
    MessageCollection? messagesCollection,
    $core.int? totalCount,
    $core.bool? hasMore,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (messagesCollection != null) {
      $result.messagesCollection = messagesCollection;
    }
    if (totalCount != null) {
      $result.totalCount = totalCount;
    }
    if (hasMore != null) {
      $result.hasMore = hasMore;
    }
    return $result;
  }
  MessageRangeResponse._() : super();
  factory MessageRangeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageRangeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageRangeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOM<MessageCollection>(4, _omitFieldNames ? '' : 'messagesCollection', protoName: 'messagesCollection', subBuilder: MessageCollection.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..aOB(6, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageRangeResponse clone() => MessageRangeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageRangeResponse copyWith(void Function(MessageRangeResponse) updates) => super.copyWith((message) => updates(message as MessageRangeResponse)) as MessageRangeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageRangeResponse create() => MessageRangeResponse._();
  MessageRangeResponse createEmptyInstance() => create();
  static $pb.PbList<MessageRangeResponse> createRepeated() => $pb.PbList<MessageRangeResponse>();
  @$core.pragma('dart2js:noInline')
  static MessageRangeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageRangeResponse>(create);
  static MessageRangeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  MessageCollection get messagesCollection => $_getN(3);
  @$pb.TagNumber(4)
  set messagesCollection(MessageCollection v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMessagesCollection() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessagesCollection() => $_clearField(4);
  @$pb.TagNumber(4)
  MessageCollection ensureMessagesCollection() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get totalCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set totalCount($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get hasMore => $_getBF(5);
  @$pb.TagNumber(6)
  set hasMore($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasHasMore() => $_has(5);
  @$pb.TagNumber(6)
  void clearHasMore() => $_clearField(6);
}

///  周围消息获取请求（获取指定消息前后的消息）- 🔄 在Index方案中已极大简化
///  🚀 新的实现方式：
///  1. 根据anchor_message_id查询其message_index
///  2. 获取index范围内的消息：[anchor_index-before_count, anchor_index+after_count]
///  3. 单次查询即可获得所有结果，无需复杂的前后分别查询
///
///  🔥 极简SQL查询：
///  SELECT * FROM messages
///  WHERE conversation_id=?
///  AND message_index BETWEEN (anchor_index-before_count) AND (anchor_index+after_count)
///  ORDER BY message_index ASC
class SurroundingMessagesRequest extends $pb.GeneratedMessage {
  factory SurroundingMessagesRequest({
    $core.String? conversationId,
    $core.String? anchorMessageId,
    $core.int? beforeCount,
    $core.int? afterCount,
    $core.bool? includeAnchor,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (anchorMessageId != null) {
      $result.anchorMessageId = anchorMessageId;
    }
    if (beforeCount != null) {
      $result.beforeCount = beforeCount;
    }
    if (afterCount != null) {
      $result.afterCount = afterCount;
    }
    if (includeAnchor != null) {
      $result.includeAnchor = includeAnchor;
    }
    return $result;
  }
  SurroundingMessagesRequest._() : super();
  factory SurroundingMessagesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SurroundingMessagesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SurroundingMessagesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'anchorMessageId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'beforeCount', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'afterCount', $pb.PbFieldType.O3)
    ..aOB(5, _omitFieldNames ? '' : 'includeAnchor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SurroundingMessagesRequest clone() => SurroundingMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SurroundingMessagesRequest copyWith(void Function(SurroundingMessagesRequest) updates) => super.copyWith((message) => updates(message as SurroundingMessagesRequest)) as SurroundingMessagesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SurroundingMessagesRequest create() => SurroundingMessagesRequest._();
  SurroundingMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<SurroundingMessagesRequest> createRepeated() => $pb.PbList<SurroundingMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static SurroundingMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SurroundingMessagesRequest>(create);
  static SurroundingMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get anchorMessageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set anchorMessageId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAnchorMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAnchorMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get beforeCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set beforeCount($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBeforeCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearBeforeCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get afterCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set afterCount($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAfterCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAfterCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeAnchor => $_getBF(4);
  @$pb.TagNumber(5)
  set includeAnchor($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIncludeAnchor() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeAnchor() => $_clearField(5);
}

/// 周围消息获取响应 - 🔄 简化版本，无需分别处理前后消息
class SurroundingMessagesResponse extends $pb.GeneratedMessage {
  factory SurroundingMessagesResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? conversationId,
    $core.String? anchorMessageId,
    $core.Iterable<MessageProto>? messages,
    $core.bool? hasMoreBefore,
    $core.bool? hasMoreAfter,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (anchorMessageId != null) {
      $result.anchorMessageId = anchorMessageId;
    }
    if (messages != null) {
      $result.messages.addAll(messages);
    }
    if (hasMoreBefore != null) {
      $result.hasMoreBefore = hasMoreBefore;
    }
    if (hasMoreAfter != null) {
      $result.hasMoreAfter = hasMoreAfter;
    }
    return $result;
  }
  SurroundingMessagesResponse._() : super();
  factory SurroundingMessagesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SurroundingMessagesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SurroundingMessagesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOS(4, _omitFieldNames ? '' : 'anchorMessageId')
    ..pc<MessageProto>(5, _omitFieldNames ? '' : 'messages', $pb.PbFieldType.PM, subBuilder: MessageProto.create)
    ..aOB(8, _omitFieldNames ? '' : 'hasMoreBefore')
    ..aOB(9, _omitFieldNames ? '' : 'hasMoreAfter')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SurroundingMessagesResponse clone() => SurroundingMessagesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SurroundingMessagesResponse copyWith(void Function(SurroundingMessagesResponse) updates) => super.copyWith((message) => updates(message as SurroundingMessagesResponse)) as SurroundingMessagesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SurroundingMessagesResponse create() => SurroundingMessagesResponse._();
  SurroundingMessagesResponse createEmptyInstance() => create();
  static $pb.PbList<SurroundingMessagesResponse> createRepeated() => $pb.PbList<SurroundingMessagesResponse>();
  @$core.pragma('dart2js:noInline')
  static SurroundingMessagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SurroundingMessagesResponse>(create);
  static SurroundingMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get anchorMessageId => $_getSZ(3);
  @$pb.TagNumber(4)
  set anchorMessageId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAnchorMessageId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAnchorMessageId() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<MessageProto> get messages => $_getList(4);

  @$pb.TagNumber(8)
  $core.bool get hasMoreBefore => $_getBF(5);
  @$pb.TagNumber(8)
  set hasMoreBefore($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(8)
  $core.bool hasHasMoreBefore() => $_has(5);
  @$pb.TagNumber(8)
  void clearHasMoreBefore() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get hasMoreAfter => $_getBF(6);
  @$pb.TagNumber(9)
  set hasMoreAfter($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(9)
  $core.bool hasHasMoreAfter() => $_has(6);
  @$pb.TagNumber(9)
  void clearHasMoreAfter() => $_clearField(9);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
