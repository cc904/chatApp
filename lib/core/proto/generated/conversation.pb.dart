//
//  Generated code. Do not modify.
//  source: conversation.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'conversation.pbenum.dart';
import 'message.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'conversation.pbenum.dart';

/// 会话信息
class ConversationProto extends $pb.GeneratedMessage {
  factory ConversationProto({
    $core.String? conversationId,
    $core.String? name,
    $core.String? avatar,
    ConversationType? type,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? lastMessageTime,
    $core.String? lastMessagePreview,
    $core.int? unreadCount,
    $core.String? contactUserId,
    $core.Iterable<$core.String>? participantIds,
    $fixnum.Int64? updatedAt,
    $core.String? lastMessageId,
    $core.bool? muted,
    $core.bool? pinned,
    $core.String? createdBy,
    $1.MessageProto? lastMessage,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (avatar != null) {
      $result.avatar = avatar;
    }
    if (type != null) {
      $result.type = type;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (lastMessageTime != null) {
      $result.lastMessageTime = lastMessageTime;
    }
    if (lastMessagePreview != null) {
      $result.lastMessagePreview = lastMessagePreview;
    }
    if (unreadCount != null) {
      $result.unreadCount = unreadCount;
    }
    if (contactUserId != null) {
      $result.contactUserId = contactUserId;
    }
    if (participantIds != null) {
      $result.participantIds.addAll(participantIds);
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    if (lastMessageId != null) {
      $result.lastMessageId = lastMessageId;
    }
    if (muted != null) {
      $result.muted = muted;
    }
    if (pinned != null) {
      $result.pinned = pinned;
    }
    if (createdBy != null) {
      $result.createdBy = createdBy;
    }
    if (lastMessage != null) {
      $result.lastMessage = lastMessage;
    }
    return $result;
  }
  ConversationProto._() : super();
  factory ConversationProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..e<ConversationType>(4, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ConversationType.private, valueOf: ConversationType.valueOf, enumValues: ConversationType.values)
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(6, _omitFieldNames ? '' : 'lastMessageTime')
    ..aOS(7, _omitFieldNames ? '' : 'lastMessagePreview')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'unreadCount', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'contactUserId')
    ..pPS(10, _omitFieldNames ? '' : 'participantIds')
    ..aInt64(11, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(12, _omitFieldNames ? '' : 'lastMessageId')
    ..aOB(13, _omitFieldNames ? '' : 'muted')
    ..aOB(14, _omitFieldNames ? '' : 'pinned')
    ..aOS(15, _omitFieldNames ? '' : 'createdBy')
    ..aOM<$1.MessageProto>(16, _omitFieldNames ? '' : 'lastMessage', subBuilder: $1.MessageProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationProto clone() => ConversationProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationProto copyWith(void Function(ConversationProto) updates) => super.copyWith((message) => updates(message as ConversationProto)) as ConversationProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationProto create() => ConversationProto._();
  ConversationProto createEmptyInstance() => create();
  static $pb.PbList<ConversationProto> createRepeated() => $pb.PbList<ConversationProto>();
  @$core.pragma('dart2js:noInline')
  static ConversationProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationProto>(create);
  static ConversationProto? _defaultInstance;

  /// 主要字段，完全匹配数据库模型
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  @$pb.TagNumber(4)
  ConversationType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(ConversationType v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get lastMessageTime => $_getI64(5);
  @$pb.TagNumber(6)
  set lastMessageTime($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLastMessageTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastMessageTime() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get lastMessagePreview => $_getSZ(6);
  @$pb.TagNumber(7)
  set lastMessagePreview($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLastMessagePreview() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastMessagePreview() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get unreadCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set unreadCount($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasUnreadCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnreadCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get contactUserId => $_getSZ(8);
  @$pb.TagNumber(9)
  set contactUserId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasContactUserId() => $_has(8);
  @$pb.TagNumber(9)
  void clearContactUserId() => $_clearField(9);

  /// 参与者ID，对应数据库中的links
  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get participantIds => $_getList(9);

  /// 扩展字段，用于通信但数据库中可能没有
  @$pb.TagNumber(11)
  $fixnum.Int64 get updatedAt => $_getI64(10);
  @$pb.TagNumber(11)
  set updatedAt($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get lastMessageId => $_getSZ(11);
  @$pb.TagNumber(12)
  set lastMessageId($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasLastMessageId() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastMessageId() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get muted => $_getBF(12);
  @$pb.TagNumber(13)
  set muted($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasMuted() => $_has(12);
  @$pb.TagNumber(13)
  void clearMuted() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get pinned => $_getBF(13);
  @$pb.TagNumber(14)
  set pinned($core.bool v) { $_setBool(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasPinned() => $_has(13);
  @$pb.TagNumber(14)
  void clearPinned() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get createdBy => $_getSZ(14);
  @$pb.TagNumber(15)
  set createdBy($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedBy() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedBy() => $_clearField(15);

  @$pb.TagNumber(16)
  $1.MessageProto get lastMessage => $_getN(15);
  @$pb.TagNumber(16)
  set lastMessage($1.MessageProto v) { $_setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasLastMessage() => $_has(15);
  @$pb.TagNumber(16)
  void clearLastMessage() => $_clearField(16);
  @$pb.TagNumber(16)
  $1.MessageProto ensureLastMessage() => $_ensure(15);
}

/// 会话更新
class ConversationUpdate extends $pb.GeneratedMessage {
  factory ConversationUpdate({
    $core.String? conversationId,
    $core.String? name,
    $core.String? avatar,
    $core.Iterable<$core.String>? participantIds,
    $fixnum.Int64? updatedAt,
    $core.String? updatedBy,
    $core.String? action,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (avatar != null) {
      $result.avatar = avatar;
    }
    if (participantIds != null) {
      $result.participantIds.addAll(participantIds);
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    if (updatedBy != null) {
      $result.updatedBy = updatedBy;
    }
    if (action != null) {
      $result.action = action;
    }
    return $result;
  }
  ConversationUpdate._() : super();
  factory ConversationUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..pPS(4, _omitFieldNames ? '' : 'participantIds')
    ..aInt64(5, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(6, _omitFieldNames ? '' : 'updatedBy')
    ..aOS(7, _omitFieldNames ? '' : 'action')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationUpdate clone() => ConversationUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationUpdate copyWith(void Function(ConversationUpdate) updates) => super.copyWith((message) => updates(message as ConversationUpdate)) as ConversationUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationUpdate create() => ConversationUpdate._();
  ConversationUpdate createEmptyInstance() => create();
  static $pb.PbList<ConversationUpdate> createRepeated() => $pb.PbList<ConversationUpdate>();
  @$core.pragma('dart2js:noInline')
  static ConversationUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationUpdate>(create);
  static ConversationUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get participantIds => $_getList(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get updatedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set updatedAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get updatedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set updatedBy($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUpdatedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedBy() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get action => $_getSZ(6);
  @$pb.TagNumber(7)
  set action($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearAction() => $_clearField(7);
}

/// 会话请求响应
class ConversationResponse extends $pb.GeneratedMessage {
  factory ConversationResponse({
    $core.bool? success,
    $core.String? message,
    ConversationProto? conversation,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (conversation != null) {
      $result.conversation = conversation;
    }
    return $result;
  }
  ConversationResponse._() : super();
  factory ConversationResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<ConversationProto>(3, _omitFieldNames ? '' : 'conversation', subBuilder: ConversationProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationResponse clone() => ConversationResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationResponse copyWith(void Function(ConversationResponse) updates) => super.copyWith((message) => updates(message as ConversationResponse)) as ConversationResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationResponse create() => ConversationResponse._();
  ConversationResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationResponse> createRepeated() => $pb.PbList<ConversationResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationResponse>(create);
  static ConversationResponse? _defaultInstance;

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
  ConversationProto get conversation => $_getN(2);
  @$pb.TagNumber(3)
  set conversation(ConversationProto v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversation() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversation() => $_clearField(3);
  @$pb.TagNumber(3)
  ConversationProto ensureConversation() => $_ensure(2);
}

/// 会话列表
class ConversationCollection extends $pb.GeneratedMessage {
  factory ConversationCollection({
    $core.Iterable<ConversationProto>? conversations,
  }) {
    final $result = create();
    if (conversations != null) {
      $result.conversations.addAll(conversations);
    }
    return $result;
  }
  ConversationCollection._() : super();
  factory ConversationCollection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationCollection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationCollection', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<ConversationProto>(1, _omitFieldNames ? '' : 'conversations', $pb.PbFieldType.PM, subBuilder: ConversationProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationCollection clone() => ConversationCollection()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationCollection copyWith(void Function(ConversationCollection) updates) => super.copyWith((message) => updates(message as ConversationCollection)) as ConversationCollection;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationCollection create() => ConversationCollection._();
  ConversationCollection createEmptyInstance() => create();
  static $pb.PbList<ConversationCollection> createRepeated() => $pb.PbList<ConversationCollection>();
  @$core.pragma('dart2js:noInline')
  static ConversationCollection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationCollection>(create);
  static ConversationCollection? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConversationProto> get conversations => $_getList(0);
}

/// 同步会话请求
class SyncConversationsRequest extends $pb.GeneratedMessage {
  factory SyncConversationsRequest({
    $core.Iterable<$core.String>? localConversationIds,
    $core.String? userId,
  }) {
    final $result = create();
    if (localConversationIds != null) {
      $result.localConversationIds.addAll(localConversationIds);
    }
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  SyncConversationsRequest._() : super();
  factory SyncConversationsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncConversationsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncConversationsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'localConversationIds')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncConversationsRequest clone() => SyncConversationsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncConversationsRequest copyWith(void Function(SyncConversationsRequest) updates) => super.copyWith((message) => updates(message as SyncConversationsRequest)) as SyncConversationsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncConversationsRequest create() => SyncConversationsRequest._();
  SyncConversationsRequest createEmptyInstance() => create();
  static $pb.PbList<SyncConversationsRequest> createRepeated() => $pb.PbList<SyncConversationsRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncConversationsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncConversationsRequest>(create);
  static SyncConversationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get localConversationIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// 会话更新通知
class ConversationUpdateNotification extends $pb.GeneratedMessage {
  factory ConversationUpdateNotification({
    $core.String? conversationId,
    $core.String? lastMessagePreview,
    $fixnum.Int64? lastMessageTime,
    $core.int? unreadCount,
    $core.String? senderId,
    $core.String? senderName,
    $core.String? messageType,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (lastMessagePreview != null) {
      $result.lastMessagePreview = lastMessagePreview;
    }
    if (lastMessageTime != null) {
      $result.lastMessageTime = lastMessageTime;
    }
    if (unreadCount != null) {
      $result.unreadCount = unreadCount;
    }
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (senderName != null) {
      $result.senderName = senderName;
    }
    if (messageType != null) {
      $result.messageType = messageType;
    }
    return $result;
  }
  ConversationUpdateNotification._() : super();
  factory ConversationUpdateNotification.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationUpdateNotification.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationUpdateNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'lastMessagePreview')
    ..aInt64(3, _omitFieldNames ? '' : 'lastMessageTime')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'unreadCount', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'senderId')
    ..aOS(6, _omitFieldNames ? '' : 'senderName')
    ..aOS(7, _omitFieldNames ? '' : 'messageType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationUpdateNotification clone() => ConversationUpdateNotification()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationUpdateNotification copyWith(void Function(ConversationUpdateNotification) updates) => super.copyWith((message) => updates(message as ConversationUpdateNotification)) as ConversationUpdateNotification;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationUpdateNotification create() => ConversationUpdateNotification._();
  ConversationUpdateNotification createEmptyInstance() => create();
  static $pb.PbList<ConversationUpdateNotification> createRepeated() => $pb.PbList<ConversationUpdateNotification>();
  @$core.pragma('dart2js:noInline')
  static ConversationUpdateNotification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationUpdateNotification>(create);
  static ConversationUpdateNotification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get lastMessagePreview => $_getSZ(1);
  @$pb.TagNumber(2)
  set lastMessagePreview($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastMessagePreview() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMessagePreview() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lastMessageTime => $_getI64(2);
  @$pb.TagNumber(3)
  set lastMessageTime($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLastMessageTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastMessageTime() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get unreadCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set unreadCount($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnreadCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnreadCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get senderId => $_getSZ(4);
  @$pb.TagNumber(5)
  set senderId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSenderId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSenderId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get senderName => $_getSZ(5);
  @$pb.TagNumber(6)
  set senderName($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSenderName() => $_has(5);
  @$pb.TagNumber(6)
  void clearSenderName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get messageType => $_getSZ(6);
  @$pb.TagNumber(7)
  set messageType($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMessageType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMessageType() => $_clearField(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
