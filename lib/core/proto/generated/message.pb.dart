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
    $core.String? quotedMessageId,
    $core.bool? isEdited,
    $fixnum.Int64? editedAt,
    $core.String? repliedToMessageId,
    $core.String? forwardedFromConversationId,
    $core.String? forwardedFromMessageId,
    $pb.PbMap<$core.String, $core.int>? reactions,
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
    if (quotedMessageId != null) {
      $result.quotedMessageId = quotedMessageId;
    }
    if (isEdited != null) {
      $result.isEdited = isEdited;
    }
    if (editedAt != null) {
      $result.editedAt = editedAt;
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
    ..aOS(21, _omitFieldNames ? '' : 'quotedMessageId')
    ..aOB(24, _omitFieldNames ? '' : 'isEdited')
    ..aInt64(25, _omitFieldNames ? '' : 'editedAt')
    ..aOS(31, _omitFieldNames ? '' : 'repliedToMessageId')
    ..aOS(32, _omitFieldNames ? '' : 'forwardedFromConversationId')
    ..aOS(33, _omitFieldNames ? '' : 'forwardedFromMessageId')
    ..m<$core.String, $core.int>(34, _omitFieldNames ? '' : 'reactions', entryClassName: 'MessageProto.ReactionsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O3, packageName: const $pb.PackageName('cc'))
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

  /// 消息状态（包含删除、撤销等所有状态）
  @$pb.TagNumber(10)
  MessageStatus get status => $_getN(9);
  @$pb.TagNumber(10)
  set status(MessageStatus v) { $_setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatus() => $_clearField(10);

  /// 引用消息
  @$pb.TagNumber(21)
  $core.String get quotedMessageId => $_getSZ(10);
  @$pb.TagNumber(21)
  set quotedMessageId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(21)
  $core.bool hasQuotedMessageId() => $_has(10);
  @$pb.TagNumber(21)
  void clearQuotedMessageId() => $_clearField(21);

  /// 编辑相关字段
  /// 是否已编辑
  @$pb.TagNumber(24)
  $core.bool get isEdited => $_getBF(11);
  @$pb.TagNumber(24)
  set isEdited($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(24)
  $core.bool hasIsEdited() => $_has(11);
  @$pb.TagNumber(24)
  void clearIsEdited() => $_clearField(24);

  /// 编辑时间
  @$pb.TagNumber(25)
  $fixnum.Int64 get editedAt => $_getI64(12);
  @$pb.TagNumber(25)
  set editedAt($fixnum.Int64 v) { $_setInt64(12, v); }
  @$pb.TagNumber(25)
  $core.bool hasEditedAt() => $_has(12);
  @$pb.TagNumber(25)
  void clearEditedAt() => $_clearField(25);

  /// 回复和转发
  /// 回复的消息ID
  @$pb.TagNumber(31)
  $core.String get repliedToMessageId => $_getSZ(13);
  @$pb.TagNumber(31)
  set repliedToMessageId($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(31)
  $core.bool hasRepliedToMessageId() => $_has(13);
  @$pb.TagNumber(31)
  void clearRepliedToMessageId() => $_clearField(31);

  /// 转发来源会话ID
  @$pb.TagNumber(32)
  $core.String get forwardedFromConversationId => $_getSZ(14);
  @$pb.TagNumber(32)
  set forwardedFromConversationId($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(32)
  $core.bool hasForwardedFromConversationId() => $_has(14);
  @$pb.TagNumber(32)
  void clearForwardedFromConversationId() => $_clearField(32);

  /// 转发来源消息ID
  @$pb.TagNumber(33)
  $core.String get forwardedFromMessageId => $_getSZ(15);
  @$pb.TagNumber(33)
  set forwardedFromMessageId($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(33)
  $core.bool hasForwardedFromMessageId() => $_has(15);
  @$pb.TagNumber(33)
  void clearForwardedFromMessageId() => $_clearField(33);

  /// 消息反应（点赞、表情等）
  /// 反应类型 -> 用户ID列表（逗号分隔）
  @$pb.TagNumber(34)
  $pb.PbMap<$core.String, $core.int> get reactions => $_getMap(16);

  /// 消息标记
  /// 消息标签
  @$pb.TagNumber(36)
  $pb.PbList<$core.String> get tags => $_getList(17);

  /// 是否置顶
  @$pb.TagNumber(37)
  $core.bool get isPinned => $_getBF(18);
  @$pb.TagNumber(37)
  set isPinned($core.bool v) { $_setBool(18, v); }
  @$pb.TagNumber(37)
  $core.bool hasIsPinned() => $_has(18);
  @$pb.TagNumber(37)
  void clearIsPinned() => $_clearField(37);

  @$pb.TagNumber(38)
  TextMessage get textMessage => $_getN(19);
  @$pb.TagNumber(38)
  set textMessage(TextMessage v) { $_setField(38, v); }
  @$pb.TagNumber(38)
  $core.bool hasTextMessage() => $_has(19);
  @$pb.TagNumber(38)
  void clearTextMessage() => $_clearField(38);
  @$pb.TagNumber(38)
  TextMessage ensureTextMessage() => $_ensure(19);

  @$pb.TagNumber(39)
  MediaMessage get mediaMessage => $_getN(20);
  @$pb.TagNumber(39)
  set mediaMessage(MediaMessage v) { $_setField(39, v); }
  @$pb.TagNumber(39)
  $core.bool hasMediaMessage() => $_has(20);
  @$pb.TagNumber(39)
  void clearMediaMessage() => $_clearField(39);
  @$pb.TagNumber(39)
  MediaMessage ensureMediaMessage() => $_ensure(20);

  @$pb.TagNumber(41)
  SystemMessage get systemMessage => $_getN(21);
  @$pb.TagNumber(41)
  set systemMessage(SystemMessage v) { $_setField(41, v); }
  @$pb.TagNumber(41)
  $core.bool hasSystemMessage() => $_has(21);
  @$pb.TagNumber(41)
  void clearSystemMessage() => $_clearField(41);
  @$pb.TagNumber(41)
  SystemMessage ensureSystemMessage() => $_ensure(21);

  @$pb.TagNumber(42)
  StickerMessage get stickerMessage => $_getN(22);
  @$pb.TagNumber(42)
  set stickerMessage(StickerMessage v) { $_setField(42, v); }
  @$pb.TagNumber(42)
  $core.bool hasStickerMessage() => $_has(22);
  @$pb.TagNumber(42)
  void clearStickerMessage() => $_clearField(42);
  @$pb.TagNumber(42)
  StickerMessage ensureStickerMessage() => $_ensure(22);

  @$pb.TagNumber(43)
  ContactMessage get contactMessage => $_getN(23);
  @$pb.TagNumber(43)
  set contactMessage(ContactMessage v) { $_setField(43, v); }
  @$pb.TagNumber(43)
  $core.bool hasContactMessage() => $_has(23);
  @$pb.TagNumber(43)
  void clearContactMessage() => $_clearField(43);
  @$pb.TagNumber(43)
  ContactMessage ensureContactMessage() => $_ensure(23);

  @$pb.TagNumber(44)
  PollMessage get pollMessage => $_getN(24);
  @$pb.TagNumber(44)
  set pollMessage(PollMessage v) { $_setField(44, v); }
  @$pb.TagNumber(44)
  $core.bool hasPollMessage() => $_has(24);
  @$pb.TagNumber(44)
  void clearPollMessage() => $_clearField(44);
  @$pb.TagNumber(44)
  PollMessage ensurePollMessage() => $_ensure(24);

  @$pb.TagNumber(45)
  LinkMessage get linkMessage => $_getN(25);
  @$pb.TagNumber(45)
  set linkMessage(LinkMessage v) { $_setField(45, v); }
  @$pb.TagNumber(45)
  $core.bool hasLinkMessage() => $_has(25);
  @$pb.TagNumber(45)
  void clearLinkMessage() => $_clearField(45);
  @$pb.TagNumber(45)
  LinkMessage ensureLinkMessage() => $_ensure(25);
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

  /// @用户列表
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get mentions => $_getList(1);

  /// #话题标签列表
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get hashtags => $_getList(2);

  /// 链接预览
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

  /// 语音/视频时长(毫秒)
  @$pb.TagNumber(3)
  $core.int get duration => $_getIZ(2);
  @$pb.TagNumber(3)
  set duration($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDuration() => $_has(2);
  @$pb.TagNumber(3)
  void clearDuration() => $_clearField(3);

  /// 文件大小(KB)
  @$pb.TagNumber(4)
  $core.double get fileSize => $_getN(3);
  @$pb.TagNumber(4)
  set fileSize($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFileSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileSize() => $_clearField(4);

  /// 文件名
  @$pb.TagNumber(5)
  $core.String get fileName => $_getSZ(4);
  @$pb.TagNumber(5)
  set fileName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFileName() => $_has(4);
  @$pb.TagNumber(5)
  void clearFileName() => $_clearField(5);

  /// 缩略图URL
  @$pb.TagNumber(6)
  $core.String get thumbnailUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set thumbnailUrl($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasThumbnailUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearThumbnailUrl() => $_clearField(6);

  /// MIME类型
  @$pb.TagNumber(7)
  $core.String get mimeType => $_getSZ(6);
  @$pb.TagNumber(7)
  set mimeType($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMimeType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMimeType() => $_clearField(7);

  /// 图片/视频宽度
  @$pb.TagNumber(8)
  $core.int get width => $_getIZ(7);
  @$pb.TagNumber(8)
  set width($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasWidth() => $_has(7);
  @$pb.TagNumber(8)
  void clearWidth() => $_clearField(8);

  /// 图片/视频高度
  @$pb.TagNumber(9)
  $core.int get height => $_getIZ(8);
  @$pb.TagNumber(9)
  set height($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearHeight() => $_clearField(9);

  /// 媒体说明文字
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

  /// 例如：group_created, member_added等
  @$pb.TagNumber(2)
  $core.String get action => $_getSZ(1);
  @$pb.TagNumber(2)
  set action($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  /// 系统消息参数
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

/// 消息响应结构
class MessageSendResponse extends $pb.GeneratedMessage {
  factory MessageSendResponse({
    $core.bool? success,
    $core.String? msg,
    $core.String? conversationId,
    $core.String? tempId,
    $core.String? messageId,
    $fixnum.Int64? messageIndex,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (tempId != null) {
      $result.tempId = tempId;
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (messageIndex != null) {
      $result.messageIndex = messageIndex;
    }
    return $result;
  }
  MessageSendResponse._() : super();
  factory MessageSendResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageSendResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageSendResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOS(4, _omitFieldNames ? '' : 'tempId')
    ..aOS(5, _omitFieldNames ? '' : 'messageId')
    ..aInt64(6, _omitFieldNames ? '' : 'messageIndex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageSendResponse clone() => MessageSendResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageSendResponse copyWith(void Function(MessageSendResponse) updates) => super.copyWith((message) => updates(message as MessageSendResponse)) as MessageSendResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageSendResponse create() => MessageSendResponse._();
  MessageSendResponse createEmptyInstance() => create();
  static $pb.PbList<MessageSendResponse> createRepeated() => $pb.PbList<MessageSendResponse>();
  @$core.pragma('dart2js:noInline')
  static MessageSendResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageSendResponse>(create);
  static MessageSendResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 错误信息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get tempId => $_getSZ(3);
  @$pb.TagNumber(4)
  set tempId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTempId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTempId() => $_clearField(4);

  /// 消息ID
  @$pb.TagNumber(5)
  $core.String get messageId => $_getSZ(4);
  @$pb.TagNumber(5)
  set messageId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMessageId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageId() => $_clearField(5);

  /// 消息索引
  @$pb.TagNumber(6)
  $fixnum.Int64 get messageIndex => $_getI64(5);
  @$pb.TagNumber(6)
  set messageIndex($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMessageIndex() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessageIndex() => $_clearField(6);
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

/// 消息获取请求 - 使用index简化游标管理 messages:fetch
class MessagesFetchRequest extends $pb.GeneratedMessage {
  factory MessagesFetchRequest({
    $core.String? conversationId,
    $fixnum.Int64? messageIndex,
    $core.int? limit,
    $core.bool? isBefore,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (messageIndex != null) {
      $result.messageIndex = messageIndex;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    if (isBefore != null) {
      $result.isBefore = isBefore;
    }
    return $result;
  }
  MessagesFetchRequest._() : super();
  factory MessagesFetchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessagesFetchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessagesFetchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'messageIndex')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'isBefore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessagesFetchRequest clone() => MessagesFetchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessagesFetchRequest copyWith(void Function(MessagesFetchRequest) updates) => super.copyWith((message) => updates(message as MessagesFetchRequest)) as MessagesFetchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessagesFetchRequest create() => MessagesFetchRequest._();
  MessagesFetchRequest createEmptyInstance() => create();
  static $pb.PbList<MessagesFetchRequest> createRepeated() => $pb.PbList<MessagesFetchRequest>();
  @$core.pragma('dart2js:noInline')
  static MessagesFetchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessagesFetchRequest>(create);
  static MessagesFetchRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 锚点消息Index
  @$pb.TagNumber(2)
  $fixnum.Int64 get messageIndex => $_getI64(1);
  @$pb.TagNumber(2)
  set messageIndex($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessageIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageIndex() => $_clearField(2);

  /// 获取消息数量限制，默认50
  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);

  /// 是否是获取更早的消息
  @$pb.TagNumber(4)
  $core.bool get isBefore => $_getBF(3);
  @$pb.TagNumber(4)
  set isBefore($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsBefore() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsBefore() => $_clearField(4);
}

/// 消息获取请求 - 使用index简化游标管理 messages:fetch:response
class MessagesFetchResponse extends $pb.GeneratedMessage {
  factory MessagesFetchResponse({
    $core.bool? success,
    $core.String? msg,
    $core.String? conversationId,
    $core.Iterable<MessageProto>? messages,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (messages != null) {
      $result.messages.addAll(messages);
    }
    return $result;
  }
  MessagesFetchResponse._() : super();
  factory MessagesFetchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessagesFetchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessagesFetchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..pc<MessageProto>(4, _omitFieldNames ? '' : 'messages', $pb.PbFieldType.PM, subBuilder: MessageProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessagesFetchResponse clone() => MessagesFetchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessagesFetchResponse copyWith(void Function(MessagesFetchResponse) updates) => super.copyWith((message) => updates(message as MessagesFetchResponse)) as MessagesFetchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessagesFetchResponse create() => MessagesFetchResponse._();
  MessagesFetchResponse createEmptyInstance() => create();
  static $pb.PbList<MessagesFetchResponse> createRepeated() => $pb.PbList<MessagesFetchResponse>();
  @$core.pragma('dart2js:noInline')
  static MessagesFetchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessagesFetchResponse>(create);
  static MessagesFetchResponse? _defaultInstance;

  /// 请求是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 错误信息（失败时）
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => $_clearField(2);

  /// 会话ID
  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  /// 消息集合
  @$pb.TagNumber(4)
  $pb.PbList<MessageProto> get messages => $_getList(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
