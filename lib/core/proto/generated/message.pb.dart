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
  locationMessage, 
  systemMessage, 
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
    $core.bool? isRead,
    $core.String? status,
    MessageType? type,
    $core.String? text,
    $core.String? mediaUrl,
    $core.String? localPath,
    $core.int? duration,
    $core.double? fileSize,
    $core.String? fileName,
    $core.String? thumbnailUrl,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? locationAddress,
    $core.String? quotedMessageId,
    TextMessage? textMessage,
    MediaMessage? mediaMessage,
    LocationMessage? locationMessage,
    SystemMessage? systemMessage,
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
    if (isRead != null) {
      $result.isRead = isRead;
    }
    if (status != null) {
      $result.status = status;
    }
    if (type != null) {
      $result.type = type;
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
    if (latitude != null) {
      $result.latitude = latitude;
    }
    if (longitude != null) {
      $result.longitude = longitude;
    }
    if (locationAddress != null) {
      $result.locationAddress = locationAddress;
    }
    if (quotedMessageId != null) {
      $result.quotedMessageId = quotedMessageId;
    }
    if (textMessage != null) {
      $result.textMessage = textMessage;
    }
    if (mediaMessage != null) {
      $result.mediaMessage = mediaMessage;
    }
    if (locationMessage != null) {
      $result.locationMessage = locationMessage;
    }
    if (systemMessage != null) {
      $result.systemMessage = systemMessage;
    }
    return $result;
  }
  MessageProto._() : super();
  factory MessageProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, MessageProto_Content> _MessageProto_ContentByTag = {
    21 : MessageProto_Content.textMessage,
    22 : MessageProto_Content.mediaMessage,
    23 : MessageProto_Content.locationMessage,
    24 : MessageProto_Content.systemMessage,
    0 : MessageProto_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..oo(0, [21, 22, 23, 24])
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'senderId')
    ..aOS(4, _omitFieldNames ? '' : 'senderName')
    ..aOS(5, _omitFieldNames ? '' : 'senderAvatar')
    ..aInt64(6, _omitFieldNames ? '' : 'createdAt')
    ..aOB(7, _omitFieldNames ? '' : 'isRead')
    ..aOS(8, _omitFieldNames ? '' : 'status')
    ..e<MessageType>(9, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: MessageType.text, valueOf: MessageType.valueOf, enumValues: MessageType.values)
    ..aOS(10, _omitFieldNames ? '' : 'text')
    ..aOS(11, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(12, _omitFieldNames ? '' : 'localPath')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..a<$core.double>(14, _omitFieldNames ? '' : 'fileSize', $pb.PbFieldType.OD)
    ..aOS(15, _omitFieldNames ? '' : 'fileName')
    ..aOS(16, _omitFieldNames ? '' : 'thumbnailUrl')
    ..a<$core.double>(17, _omitFieldNames ? '' : 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(18, _omitFieldNames ? '' : 'longitude', $pb.PbFieldType.OD)
    ..aOS(19, _omitFieldNames ? '' : 'locationAddress')
    ..aOS(20, _omitFieldNames ? '' : 'quotedMessageId')
    ..aOM<TextMessage>(21, _omitFieldNames ? '' : 'textMessage', subBuilder: TextMessage.create)
    ..aOM<MediaMessage>(22, _omitFieldNames ? '' : 'mediaMessage', subBuilder: MediaMessage.create)
    ..aOM<LocationMessage>(23, _omitFieldNames ? '' : 'locationMessage', subBuilder: LocationMessage.create)
    ..aOM<SystemMessage>(24, _omitFieldNames ? '' : 'systemMessage', subBuilder: SystemMessage.create)
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
  $core.bool get isRead => $_getBF(6);
  @$pb.TagNumber(7)
  set isRead($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIsRead() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsRead() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get status => $_getSZ(7);
  @$pb.TagNumber(8)
  set status($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  MessageType get type => $_getN(8);
  @$pb.TagNumber(9)
  set type(MessageType v) { $_setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => $_clearField(9);

  /// 消息内容
  @$pb.TagNumber(10)
  $core.String get text => $_getSZ(9);
  @$pb.TagNumber(10)
  set text($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasText() => $_has(9);
  @$pb.TagNumber(10)
  void clearText() => $_clearField(10);

  /// 媒体消息相关字段
  @$pb.TagNumber(11)
  $core.String get mediaUrl => $_getSZ(10);
  @$pb.TagNumber(11)
  set mediaUrl($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasMediaUrl() => $_has(10);
  @$pb.TagNumber(11)
  void clearMediaUrl() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get localPath => $_getSZ(11);
  @$pb.TagNumber(12)
  set localPath($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasLocalPath() => $_has(11);
  @$pb.TagNumber(12)
  void clearLocalPath() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get duration => $_getIZ(12);
  @$pb.TagNumber(13)
  set duration($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDuration() => $_has(12);
  @$pb.TagNumber(13)
  void clearDuration() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get fileSize => $_getN(13);
  @$pb.TagNumber(14)
  set fileSize($core.double v) { $_setDouble(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasFileSize() => $_has(13);
  @$pb.TagNumber(14)
  void clearFileSize() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get fileName => $_getSZ(14);
  @$pb.TagNumber(15)
  set fileName($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasFileName() => $_has(14);
  @$pb.TagNumber(15)
  void clearFileName() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get thumbnailUrl => $_getSZ(15);
  @$pb.TagNumber(16)
  set thumbnailUrl($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasThumbnailUrl() => $_has(15);
  @$pb.TagNumber(16)
  void clearThumbnailUrl() => $_clearField(16);

  /// 位置消息
  @$pb.TagNumber(17)
  $core.double get latitude => $_getN(16);
  @$pb.TagNumber(17)
  set latitude($core.double v) { $_setDouble(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasLatitude() => $_has(16);
  @$pb.TagNumber(17)
  void clearLatitude() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.double get longitude => $_getN(17);
  @$pb.TagNumber(18)
  set longitude($core.double v) { $_setDouble(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasLongitude() => $_has(17);
  @$pb.TagNumber(18)
  void clearLongitude() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get locationAddress => $_getSZ(18);
  @$pb.TagNumber(19)
  set locationAddress($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasLocationAddress() => $_has(18);
  @$pb.TagNumber(19)
  void clearLocationAddress() => $_clearField(19);

  /// 引用消息
  @$pb.TagNumber(20)
  $core.String get quotedMessageId => $_getSZ(19);
  @$pb.TagNumber(20)
  set quotedMessageId($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasQuotedMessageId() => $_has(19);
  @$pb.TagNumber(20)
  void clearQuotedMessageId() => $_clearField(20);

  @$pb.TagNumber(21)
  TextMessage get textMessage => $_getN(20);
  @$pb.TagNumber(21)
  set textMessage(TextMessage v) { $_setField(21, v); }
  @$pb.TagNumber(21)
  $core.bool hasTextMessage() => $_has(20);
  @$pb.TagNumber(21)
  void clearTextMessage() => $_clearField(21);
  @$pb.TagNumber(21)
  TextMessage ensureTextMessage() => $_ensure(20);

  @$pb.TagNumber(22)
  MediaMessage get mediaMessage => $_getN(21);
  @$pb.TagNumber(22)
  set mediaMessage(MediaMessage v) { $_setField(22, v); }
  @$pb.TagNumber(22)
  $core.bool hasMediaMessage() => $_has(21);
  @$pb.TagNumber(22)
  void clearMediaMessage() => $_clearField(22);
  @$pb.TagNumber(22)
  MediaMessage ensureMediaMessage() => $_ensure(21);

  @$pb.TagNumber(23)
  LocationMessage get locationMessage => $_getN(22);
  @$pb.TagNumber(23)
  set locationMessage(LocationMessage v) { $_setField(23, v); }
  @$pb.TagNumber(23)
  $core.bool hasLocationMessage() => $_has(22);
  @$pb.TagNumber(23)
  void clearLocationMessage() => $_clearField(23);
  @$pb.TagNumber(23)
  LocationMessage ensureLocationMessage() => $_ensure(22);

  @$pb.TagNumber(24)
  SystemMessage get systemMessage => $_getN(23);
  @$pb.TagNumber(24)
  set systemMessage(SystemMessage v) { $_setField(24, v); }
  @$pb.TagNumber(24)
  $core.bool hasSystemMessage() => $_has(23);
  @$pb.TagNumber(24)
  void clearSystemMessage() => $_clearField(24);
  @$pb.TagNumber(24)
  SystemMessage ensureSystemMessage() => $_ensure(23);
}

/// 文本消息内容
class TextMessage extends $pb.GeneratedMessage {
  factory TextMessage({
    $core.String? text,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  TextMessage._() : super();
  factory TextMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TextMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TextMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
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
}

/// 位置消息内容
class LocationMessage extends $pb.GeneratedMessage {
  factory LocationMessage({
    $core.double? latitude,
    $core.double? longitude,
    $core.String? locationAddress,
  }) {
    final $result = create();
    if (latitude != null) {
      $result.latitude = latitude;
    }
    if (longitude != null) {
      $result.longitude = longitude;
    }
    if (locationAddress != null) {
      $result.locationAddress = locationAddress;
    }
    return $result;
  }
  LocationMessage._() : super();
  factory LocationMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LocationMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LocationMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'longitude', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'locationAddress')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LocationMessage clone() => LocationMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LocationMessage copyWith(void Function(LocationMessage) updates) => super.copyWith((message) => updates(message as LocationMessage)) as LocationMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationMessage create() => LocationMessage._();
  LocationMessage createEmptyInstance() => create();
  static $pb.PbList<LocationMessage> createRepeated() => $pb.PbList<LocationMessage>();
  @$core.pragma('dart2js:noInline')
  static LocationMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LocationMessage>(create);
  static LocationMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get locationAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set locationAddress($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocationAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocationAddress() => $_clearField(3);
}

/// 系统消息内容
class SystemMessage extends $pb.GeneratedMessage {
  factory SystemMessage({
    $core.String? text,
    $core.String? action,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    if (action != null) {
      $result.action = action;
    }
    return $result;
  }
  SystemMessage._() : super();
  factory SystemMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SystemMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'action')
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
}

/// 消息集合，用于批量操作
class MessageCollection extends $pb.GeneratedMessage {
  factory MessageCollection({
    $core.Iterable<MessageProto>? messages,
  }) {
    final $result = create();
    if (messages != null) {
      $result.messages.addAll(messages);
    }
    return $result;
  }
  MessageCollection._() : super();
  factory MessageCollection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageCollection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageCollection', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<MessageProto>(1, _omitFieldNames ? '' : 'messages', $pb.PbFieldType.PM, subBuilder: MessageProto.create)
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
}

/// 消息响应结构
class MessageResponse extends $pb.GeneratedMessage {
  factory MessageResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? messageId,
    $fixnum.Int64? timestamp,
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
}

/// 新消息
class NewMessageProto extends $pb.GeneratedMessage {
  factory NewMessageProto({
    $core.String? id,
    $core.String? senderId,
    $core.String? conversationId,
    $core.String? content,
    $fixnum.Int64? timestamp,
    $core.String? type,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (content != null) {
      $result.content = content;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (type != null) {
      $result.type = type;
    }
    return $result;
  }
  NewMessageProto._() : super();
  factory NewMessageProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NewMessageProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NewMessageProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'senderId')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..aOS(6, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NewMessageProto clone() => NewMessageProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NewMessageProto copyWith(void Function(NewMessageProto) updates) => super.copyWith((message) => updates(message as NewMessageProto)) as NewMessageProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NewMessageProto create() => NewMessageProto._();
  NewMessageProto createEmptyInstance() => create();
  static $pb.PbList<NewMessageProto> createRepeated() => $pb.PbList<NewMessageProto>();
  @$core.pragma('dart2js:noInline')
  static NewMessageProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NewMessageProto>(create);
  static NewMessageProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get type => $_getSZ(5);
  @$pb.TagNumber(6)
  set type($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasType() => $_has(5);
  @$pb.TagNumber(6)
  void clearType() => $_clearField(6);
}

/// 输入状态
class TypingProto extends $pb.GeneratedMessage {
  factory TypingProto({
    $core.String? conversationId,
    $core.bool? isTyping,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (isTyping != null) {
      $result.isTyping = isTyping;
    }
    return $result;
  }
  TypingProto._() : super();
  factory TypingProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TypingProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TypingProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOB(2, _omitFieldNames ? '' : 'isTyping')
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

  @$pb.TagNumber(2)
  $core.bool get isTyping => $_getBF(1);
  @$pb.TagNumber(2)
  set isTyping($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsTyping() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsTyping() => $_clearField(2);
}

/// 消息已读
class MessageReadProto extends $pb.GeneratedMessage {
  factory MessageReadProto({
    $core.String? messageId,
    $core.String? conversationId,
  }) {
    final $result = create();
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    return $result;
  }
  MessageReadProto._() : super();
  factory MessageReadProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageReadProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageReadProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
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
}

/// 消息已送达
class MessageDeliveredProto extends $pb.GeneratedMessage {
  factory MessageDeliveredProto({
    $core.String? messageId,
    $core.String? conversationId,
    $core.String? recipientId,
  }) {
    final $result = create();
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    return $result;
  }
  MessageDeliveredProto._() : super();
  factory MessageDeliveredProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageDeliveredProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageDeliveredProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'recipientId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageDeliveredProto clone() => MessageDeliveredProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageDeliveredProto copyWith(void Function(MessageDeliveredProto) updates) => super.copyWith((message) => updates(message as MessageDeliveredProto)) as MessageDeliveredProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageDeliveredProto create() => MessageDeliveredProto._();
  MessageDeliveredProto createEmptyInstance() => create();
  static $pb.PbList<MessageDeliveredProto> createRepeated() => $pb.PbList<MessageDeliveredProto>();
  @$core.pragma('dart2js:noInline')
  static MessageDeliveredProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageDeliveredProto>(create);
  static MessageDeliveredProto? _defaultInstance;

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
  $core.String get recipientId => $_getSZ(2);
  @$pb.TagNumber(3)
  set recipientId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRecipientId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecipientId() => $_clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
