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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'conversation.pbenum.dart';

/// 参与者消息类型，匹配数据库模型中的 IParticipant 接口
class ParticipantProto extends $pb.GeneratedMessage {
  factory ParticipantProto({
    $core.String? userId,
    $core.String? name,
    $core.String? avatar,
    $core.int? unreadCount,
    $core.bool? muted,
    $core.bool? pinned,
    $fixnum.Int64? joinedAt,
    $fixnum.Int64? lastReadAt,
    $core.String? lastReadMessageId,
    MemberRole? role,
    $core.String? addedBy,
    $core.bool? online,
    $core.bool? isActive,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (avatar != null) {
      $result.avatar = avatar;
    }
    if (unreadCount != null) {
      $result.unreadCount = unreadCount;
    }
    if (muted != null) {
      $result.muted = muted;
    }
    if (pinned != null) {
      $result.pinned = pinned;
    }
    if (joinedAt != null) {
      $result.joinedAt = joinedAt;
    }
    if (lastReadAt != null) {
      $result.lastReadAt = lastReadAt;
    }
    if (lastReadMessageId != null) {
      $result.lastReadMessageId = lastReadMessageId;
    }
    if (role != null) {
      $result.role = role;
    }
    if (addedBy != null) {
      $result.addedBy = addedBy;
    }
    if (online != null) {
      $result.online = online;
    }
    if (isActive != null) {
      $result.isActive = isActive;
    }
    return $result;
  }
  ParticipantProto._() : super();
  factory ParticipantProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ParticipantProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParticipantProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'unreadCount', $pb.PbFieldType.O3)
    ..aOB(5, _omitFieldNames ? '' : 'muted')
    ..aOB(6, _omitFieldNames ? '' : 'pinned')
    ..aInt64(7, _omitFieldNames ? '' : 'joinedAt')
    ..aInt64(8, _omitFieldNames ? '' : 'lastReadAt')
    ..aOS(9, _omitFieldNames ? '' : 'lastReadMessageId')
    ..e<MemberRole>(10, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE, defaultOrMaker: MemberRole.MEMBER, valueOf: MemberRole.valueOf, enumValues: MemberRole.values)
    ..aOS(11, _omitFieldNames ? '' : 'addedBy')
    ..aOB(12, _omitFieldNames ? '' : 'online')
    ..aOB(13, _omitFieldNames ? '' : 'isActive')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ParticipantProto clone() => ParticipantProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ParticipantProto copyWith(void Function(ParticipantProto) updates) => super.copyWith((message) => updates(message as ParticipantProto)) as ParticipantProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantProto create() => ParticipantProto._();
  ParticipantProto createEmptyInstance() => create();
  static $pb.PbList<ParticipantProto> createRepeated() => $pb.PbList<ParticipantProto>();
  @$core.pragma('dart2js:noInline')
  static ParticipantProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParticipantProto>(create);
  static ParticipantProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

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
  $core.int get unreadCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set unreadCount($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnreadCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnreadCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get muted => $_getBF(4);
  @$pb.TagNumber(5)
  set muted($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMuted() => $_has(4);
  @$pb.TagNumber(5)
  void clearMuted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get pinned => $_getBF(5);
  @$pb.TagNumber(6)
  set pinned($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPinned() => $_has(5);
  @$pb.TagNumber(6)
  void clearPinned() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get joinedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set joinedAt($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasJoinedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearJoinedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get lastReadAt => $_getI64(7);
  @$pb.TagNumber(8)
  set lastReadAt($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLastReadAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastReadAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get lastReadMessageId => $_getSZ(8);
  @$pb.TagNumber(9)
  set lastReadMessageId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasLastReadMessageId() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastReadMessageId() => $_clearField(9);

  @$pb.TagNumber(10)
  MemberRole get role => $_getN(9);
  @$pb.TagNumber(10)
  set role(MemberRole v) { $_setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasRole() => $_has(9);
  @$pb.TagNumber(10)
  void clearRole() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get addedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set addedBy($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasAddedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearAddedBy() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get online => $_getBF(11);
  @$pb.TagNumber(12)
  set online($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasOnline() => $_has(11);
  @$pb.TagNumber(12)
  void clearOnline() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get isActive => $_getBF(12);
  @$pb.TagNumber(13)
  set isActive($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasIsActive() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsActive() => $_clearField(13);
}

class ConversationProto extends $pb.GeneratedMessage {
  factory ConversationProto({
    $core.String? conversationId,
    $core.String? name,
    $core.String? avatar,
    ConversationType? type,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? lastMessageTime,
    $fixnum.Int64? lastMessageIndex,
    $core.String? lastMessagePreview,
    $core.String? lastMessageName,
    $core.int? unreadCount,
    $core.String? contactUserId,
    $core.Iterable<ParticipantProto>? participants,
    $core.bool? muted,
    $core.bool? pinned,
    $core.String? createdBy,
    $fixnum.Int64? lastReadAtIndex,
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
    if (lastMessageIndex != null) {
      $result.lastMessageIndex = lastMessageIndex;
    }
    if (lastMessagePreview != null) {
      $result.lastMessagePreview = lastMessagePreview;
    }
    if (lastMessageName != null) {
      $result.lastMessageName = lastMessageName;
    }
    if (unreadCount != null) {
      $result.unreadCount = unreadCount;
    }
    if (contactUserId != null) {
      $result.contactUserId = contactUserId;
    }
    if (participants != null) {
      $result.participants.addAll(participants);
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
    if (lastReadAtIndex != null) {
      $result.lastReadAtIndex = lastReadAtIndex;
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
    ..e<ConversationType>(4, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ConversationType.PRIVATE, valueOf: ConversationType.valueOf, enumValues: ConversationType.values)
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(6, _omitFieldNames ? '' : 'lastMessageTime')
    ..aInt64(7, _omitFieldNames ? '' : 'lastMessageIndex')
    ..aOS(8, _omitFieldNames ? '' : 'lastMessagePreview')
    ..aOS(9, _omitFieldNames ? '' : 'lastMessageName')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'unreadCount', $pb.PbFieldType.O3)
    ..aOS(11, _omitFieldNames ? '' : 'contactUserId')
    ..pc<ParticipantProto>(12, _omitFieldNames ? '' : 'participants', $pb.PbFieldType.PM, subBuilder: ParticipantProto.create)
    ..aOB(13, _omitFieldNames ? '' : 'muted')
    ..aOB(14, _omitFieldNames ? '' : 'pinned')
    ..aOS(15, _omitFieldNames ? '' : 'createdBy')
    ..aInt64(16, _omitFieldNames ? '' : 'lastReadAtIndex')
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
  $fixnum.Int64 get lastMessageIndex => $_getI64(6);
  @$pb.TagNumber(7)
  set lastMessageIndex($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLastMessageIndex() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastMessageIndex() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get lastMessagePreview => $_getSZ(7);
  @$pb.TagNumber(8)
  set lastMessagePreview($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLastMessagePreview() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastMessagePreview() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get lastMessageName => $_getSZ(8);
  @$pb.TagNumber(9)
  set lastMessageName($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasLastMessageName() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastMessageName() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get unreadCount => $_getIZ(9);
  @$pb.TagNumber(10)
  set unreadCount($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasUnreadCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearUnreadCount() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get contactUserId => $_getSZ(10);
  @$pb.TagNumber(11)
  set contactUserId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasContactUserId() => $_has(10);
  @$pb.TagNumber(11)
  void clearContactUserId() => $_clearField(11);

  /// 参与者详细信息，包含所有参与者的完整信息
  @$pb.TagNumber(12)
  $pb.PbList<ParticipantProto> get participants => $_getList(11);

  /// 扩展字段，用于通信但数据库中可能没有
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

  /// 最后阅读消息索引，用于客户端计算会话未读状态
  @$pb.TagNumber(16)
  $fixnum.Int64 get lastReadAtIndex => $_getI64(15);
  @$pb.TagNumber(16)
  set lastReadAtIndex($fixnum.Int64 v) { $_setInt64(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasLastReadAtIndex() => $_has(15);
  @$pb.TagNumber(16)
  void clearLastReadAtIndex() => $_clearField(16);
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
/// 客户端发送此请求以获取服务器上的最新会话数据
/// 服务器会根据当前用户的会话返回所有最新数据
/// 可以提供上次同步时间来实现增量同步，只获取新的或有更新的会话
class SyncConversationsRequest extends $pb.GeneratedMessage {
  factory SyncConversationsRequest({
    $fixnum.Int64? lastSyncTime,
  }) {
    final $result = create();
    if (lastSyncTime != null) {
      $result.lastSyncTime = lastSyncTime;
    }
    return $result;
  }
  SyncConversationsRequest._() : super();
  factory SyncConversationsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncConversationsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncConversationsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'lastSyncTime')
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
  $fixnum.Int64 get lastSyncTime => $_getI64(0);
  @$pb.TagNumber(1)
  set lastSyncTime($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLastSyncTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastSyncTime() => $_clearField(1);
}

/// 会话更新通知
class ConversationUpdateNotification extends $pb.GeneratedMessage {
  factory ConversationUpdateNotification({
    $core.String? conversationId,
    $fixnum.Int64? lastMessageIndex,
    $core.String? lastMessagePreview,
    $core.String? lastMessageName,
    $core.int? unreadCount,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (lastMessageIndex != null) {
      $result.lastMessageIndex = lastMessageIndex;
    }
    if (lastMessagePreview != null) {
      $result.lastMessagePreview = lastMessagePreview;
    }
    if (lastMessageName != null) {
      $result.lastMessageName = lastMessageName;
    }
    if (unreadCount != null) {
      $result.unreadCount = unreadCount;
    }
    return $result;
  }
  ConversationUpdateNotification._() : super();
  factory ConversationUpdateNotification.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationUpdateNotification.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationUpdateNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'lastMessageIndex')
    ..aOS(3, _omitFieldNames ? '' : 'lastMessagePreview')
    ..aOS(4, _omitFieldNames ? '' : 'lastMessageName')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'unreadCount', $pb.PbFieldType.O3)
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
  $fixnum.Int64 get lastMessageIndex => $_getI64(1);
  @$pb.TagNumber(2)
  set lastMessageIndex($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastMessageIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMessageIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get lastMessagePreview => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastMessagePreview($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLastMessagePreview() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastMessagePreview() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get lastMessageName => $_getSZ(3);
  @$pb.TagNumber(4)
  set lastMessageName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLastMessageName() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastMessageName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get unreadCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set unreadCount($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUnreadCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnreadCount() => $_clearField(5);
}

/// 会话设置更新请求
class ConversationSettingsUpdateRequest extends $pb.GeneratedMessage {
  factory ConversationSettingsUpdateRequest({
    $core.String? conversationId,
    $core.bool? muted,
    $core.bool? pinned,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (muted != null) {
      $result.muted = muted;
    }
    if (pinned != null) {
      $result.pinned = pinned;
    }
    return $result;
  }
  ConversationSettingsUpdateRequest._() : super();
  factory ConversationSettingsUpdateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationSettingsUpdateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationSettingsUpdateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOB(2, _omitFieldNames ? '' : 'muted')
    ..aOB(3, _omitFieldNames ? '' : 'pinned')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationSettingsUpdateRequest clone() => ConversationSettingsUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationSettingsUpdateRequest copyWith(void Function(ConversationSettingsUpdateRequest) updates) => super.copyWith((message) => updates(message as ConversationSettingsUpdateRequest)) as ConversationSettingsUpdateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateRequest create() => ConversationSettingsUpdateRequest._();
  ConversationSettingsUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationSettingsUpdateRequest> createRepeated() => $pb.PbList<ConversationSettingsUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationSettingsUpdateRequest>(create);
  static ConversationSettingsUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get muted => $_getBF(1);
  @$pb.TagNumber(2)
  set muted($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMuted() => $_has(1);
  @$pb.TagNumber(2)
  void clearMuted() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get pinned => $_getBF(2);
  @$pb.TagNumber(3)
  set pinned($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPinned() => $_has(2);
  @$pb.TagNumber(3)
  void clearPinned() => $_clearField(3);
}

/// 会话设置更新响应
class ConversationSettingsUpdateResponse extends $pb.GeneratedMessage {
  factory ConversationSettingsUpdateResponse({
    $core.String? conversationId,
    $core.bool? success,
    $core.bool? muted,
    $core.bool? pinned,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (success != null) {
      $result.success = success;
    }
    if (muted != null) {
      $result.muted = muted;
    }
    if (pinned != null) {
      $result.pinned = pinned;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  ConversationSettingsUpdateResponse._() : super();
  factory ConversationSettingsUpdateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationSettingsUpdateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationSettingsUpdateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOB(3, _omitFieldNames ? '' : 'muted')
    ..aOB(4, _omitFieldNames ? '' : 'pinned')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationSettingsUpdateResponse clone() => ConversationSettingsUpdateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationSettingsUpdateResponse copyWith(void Function(ConversationSettingsUpdateResponse) updates) => super.copyWith((message) => updates(message as ConversationSettingsUpdateResponse)) as ConversationSettingsUpdateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateResponse create() => ConversationSettingsUpdateResponse._();
  ConversationSettingsUpdateResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationSettingsUpdateResponse> createRepeated() => $pb.PbList<ConversationSettingsUpdateResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationSettingsUpdateResponse>(create);
  static ConversationSettingsUpdateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get muted => $_getBF(2);
  @$pb.TagNumber(3)
  set muted($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMuted() => $_has(2);
  @$pb.TagNumber(3)
  void clearMuted() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get pinned => $_getBF(3);
  @$pb.TagNumber(4)
  set pinned($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPinned() => $_has(3);
  @$pb.TagNumber(4)
  void clearPinned() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 会话加入/离开请求
/// 用于处理用户加入或离开会话的请求
/// 在服务端代码中，加入和离开操作使用相同的结构
class ConversationJoinLeaveRequest extends $pb.GeneratedMessage {
  factory ConversationJoinLeaveRequest({
    $core.String? conversationId,
    $core.String? userId,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  ConversationJoinLeaveRequest._() : super();
  factory ConversationJoinLeaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationJoinLeaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationJoinLeaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationJoinLeaveRequest clone() => ConversationJoinLeaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationJoinLeaveRequest copyWith(void Function(ConversationJoinLeaveRequest) updates) => super.copyWith((message) => updates(message as ConversationJoinLeaveRequest)) as ConversationJoinLeaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveRequest create() => ConversationJoinLeaveRequest._();
  ConversationJoinLeaveRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationJoinLeaveRequest> createRepeated() => $pb.PbList<ConversationJoinLeaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationJoinLeaveRequest>(create);
  static ConversationJoinLeaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// 新增：会话创建请求
class ConversationCreateRequest extends $pb.GeneratedMessage {
  factory ConversationCreateRequest({
    $core.String? name,
    $core.String? avatar,
    ConversationType? type,
    $core.Iterable<$core.String>? participantIds,
    $core.String? contactUserId,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (avatar != null) {
      $result.avatar = avatar;
    }
    if (type != null) {
      $result.type = type;
    }
    if (participantIds != null) {
      $result.participantIds.addAll(participantIds);
    }
    if (contactUserId != null) {
      $result.contactUserId = contactUserId;
    }
    return $result;
  }
  ConversationCreateRequest._() : super();
  factory ConversationCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'avatar')
    ..e<ConversationType>(3, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ConversationType.PRIVATE, valueOf: ConversationType.valueOf, enumValues: ConversationType.values)
    ..pPS(4, _omitFieldNames ? '' : 'participantIds')
    ..aOS(5, _omitFieldNames ? '' : 'contactUserId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationCreateRequest clone() => ConversationCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationCreateRequest copyWith(void Function(ConversationCreateRequest) updates) => super.copyWith((message) => updates(message as ConversationCreateRequest)) as ConversationCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationCreateRequest create() => ConversationCreateRequest._();
  ConversationCreateRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationCreateRequest> createRepeated() => $pb.PbList<ConversationCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationCreateRequest>(create);
  static ConversationCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatar => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatar($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvatar() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatar() => $_clearField(2);

  @$pb.TagNumber(3)
  ConversationType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(ConversationType v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get participantIds => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get contactUserId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactUserId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactUserId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactUserId() => $_clearField(5);
}

/// 新增：用户加入会话通知
class UserJoinedNotification extends $pb.GeneratedMessage {
  factory UserJoinedNotification({
    $core.String? conversationId,
    $core.String? userId,
    $core.String? userName,
    $core.String? userAvatar,
    $fixnum.Int64? joinedAt,
    $core.String? joinedBy,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (userAvatar != null) {
      $result.userAvatar = userAvatar;
    }
    if (joinedAt != null) {
      $result.joinedAt = joinedAt;
    }
    if (joinedBy != null) {
      $result.joinedBy = joinedBy;
    }
    return $result;
  }
  UserJoinedNotification._() : super();
  factory UserJoinedNotification.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserJoinedNotification.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserJoinedNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'userName')
    ..aOS(4, _omitFieldNames ? '' : 'userAvatar')
    ..aInt64(5, _omitFieldNames ? '' : 'joinedAt')
    ..aOS(6, _omitFieldNames ? '' : 'joinedBy')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserJoinedNotification clone() => UserJoinedNotification()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserJoinedNotification copyWith(void Function(UserJoinedNotification) updates) => super.copyWith((message) => updates(message as UserJoinedNotification)) as UserJoinedNotification;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserJoinedNotification create() => UserJoinedNotification._();
  UserJoinedNotification createEmptyInstance() => create();
  static $pb.PbList<UserJoinedNotification> createRepeated() => $pb.PbList<UserJoinedNotification>();
  @$core.pragma('dart2js:noInline')
  static UserJoinedNotification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserJoinedNotification>(create);
  static UserJoinedNotification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get userAvatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set userAvatar($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get joinedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set joinedAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasJoinedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearJoinedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get joinedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set joinedBy($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasJoinedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearJoinedBy() => $_clearField(6);
}

/// 新增：用户离开会话通知
class UserLeftNotification extends $pb.GeneratedMessage {
  factory UserLeftNotification({
    $core.String? conversationId,
    $core.String? userId,
    $core.String? userName,
    $fixnum.Int64? leftAt,
    $core.String? reason,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (leftAt != null) {
      $result.leftAt = leftAt;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  UserLeftNotification._() : super();
  factory UserLeftNotification.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserLeftNotification.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserLeftNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'userName')
    ..aInt64(4, _omitFieldNames ? '' : 'leftAt')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserLeftNotification clone() => UserLeftNotification()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserLeftNotification copyWith(void Function(UserLeftNotification) updates) => super.copyWith((message) => updates(message as UserLeftNotification)) as UserLeftNotification;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserLeftNotification create() => UserLeftNotification._();
  UserLeftNotification createEmptyInstance() => create();
  static $pb.PbList<UserLeftNotification> createRepeated() => $pb.PbList<UserLeftNotification>();
  @$core.pragma('dart2js:noInline')
  static UserLeftNotification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserLeftNotification>(create);
  static UserLeftNotification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get leftAt => $_getI64(3);
  @$pb.TagNumber(4)
  set leftAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLeftAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeftAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);
}

/// 新增：会话创建成功响应
class ConversationCreateResponse extends $pb.GeneratedMessage {
  factory ConversationCreateResponse({
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
  ConversationCreateResponse._() : super();
  factory ConversationCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<ConversationProto>(3, _omitFieldNames ? '' : 'conversation', subBuilder: ConversationProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationCreateResponse clone() => ConversationCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationCreateResponse copyWith(void Function(ConversationCreateResponse) updates) => super.copyWith((message) => updates(message as ConversationCreateResponse)) as ConversationCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationCreateResponse create() => ConversationCreateResponse._();
  ConversationCreateResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationCreateResponse> createRepeated() => $pb.PbList<ConversationCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationCreateResponse>(create);
  static ConversationCreateResponse? _defaultInstance;

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

/// 新增：会话已读标记请求
class ConversationMarkReadRequest extends $pb.GeneratedMessage {
  factory ConversationMarkReadRequest({
    $core.String? conversationId,
    $fixnum.Int64? readAt,
    $core.String? messageId,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (readAt != null) {
      $result.readAt = readAt;
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    return $result;
  }
  ConversationMarkReadRequest._() : super();
  factory ConversationMarkReadRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMarkReadRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMarkReadRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'readAt')
    ..aOS(3, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationMarkReadRequest clone() => ConversationMarkReadRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMarkReadRequest copyWith(void Function(ConversationMarkReadRequest) updates) => super.copyWith((message) => updates(message as ConversationMarkReadRequest)) as ConversationMarkReadRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMarkReadRequest create() => ConversationMarkReadRequest._();
  ConversationMarkReadRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationMarkReadRequest> createRepeated() => $pb.PbList<ConversationMarkReadRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationMarkReadRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMarkReadRequest>(create);
  static ConversationMarkReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get readAt => $_getI64(1);
  @$pb.TagNumber(2)
  set readAt($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReadAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearReadAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get messageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageId() => $_clearField(3);
}

/// 新增：会话已读标记响应
class ConversationMarkReadResponse extends $pb.GeneratedMessage {
  factory ConversationMarkReadResponse({
    $core.bool? success,
    $core.String? conversationId,
    $core.int? remainingUnread,
    $fixnum.Int64? readAt,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (remainingUnread != null) {
      $result.remainingUnread = remainingUnread;
    }
    if (readAt != null) {
      $result.readAt = readAt;
    }
    return $result;
  }
  ConversationMarkReadResponse._() : super();
  factory ConversationMarkReadResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMarkReadResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMarkReadResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'remainingUnread', $pb.PbFieldType.O3)
    ..aInt64(4, _omitFieldNames ? '' : 'readAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationMarkReadResponse clone() => ConversationMarkReadResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMarkReadResponse copyWith(void Function(ConversationMarkReadResponse) updates) => super.copyWith((message) => updates(message as ConversationMarkReadResponse)) as ConversationMarkReadResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMarkReadResponse create() => ConversationMarkReadResponse._();
  ConversationMarkReadResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationMarkReadResponse> createRepeated() => $pb.PbList<ConversationMarkReadResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationMarkReadResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMarkReadResponse>(create);
  static ConversationMarkReadResponse? _defaultInstance;

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
  $core.int get remainingUnread => $_getIZ(2);
  @$pb.TagNumber(3)
  set remainingUnread($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRemainingUnread() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemainingUnread() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get readAt => $_getI64(3);
  @$pb.TagNumber(4)
  set readAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReadAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadAt() => $_clearField(4);
}

/// 新增：会话信息更新请求
class ConversationUpdateRequest extends $pb.GeneratedMessage {
  factory ConversationUpdateRequest({
    $core.String? conversationId,
    $core.String? name,
    $core.String? avatar,
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
    return $result;
  }
  ConversationUpdateRequest._() : super();
  factory ConversationUpdateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationUpdateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationUpdateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationUpdateRequest clone() => ConversationUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationUpdateRequest copyWith(void Function(ConversationUpdateRequest) updates) => super.copyWith((message) => updates(message as ConversationUpdateRequest)) as ConversationUpdateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationUpdateRequest create() => ConversationUpdateRequest._();
  ConversationUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationUpdateRequest> createRepeated() => $pb.PbList<ConversationUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationUpdateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationUpdateRequest>(create);
  static ConversationUpdateRequest? _defaultInstance;

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
}

/// 新增：会话成员管理请求
class ConversationMemberRequest extends $pb.GeneratedMessage {
  factory ConversationMemberRequest({
    $core.String? conversationId,
    $core.String? userId,
    $core.String? action,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (action != null) {
      $result.action = action;
    }
    return $result;
  }
  ConversationMemberRequest._() : super();
  factory ConversationMemberRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMemberRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMemberRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationMemberRequest clone() => ConversationMemberRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMemberRequest copyWith(void Function(ConversationMemberRequest) updates) => super.copyWith((message) => updates(message as ConversationMemberRequest)) as ConversationMemberRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMemberRequest create() => ConversationMemberRequest._();
  ConversationMemberRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationMemberRequest> createRepeated() => $pb.PbList<ConversationMemberRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationMemberRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMemberRequest>(create);
  static ConversationMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);
}

/// 新增：会话成员列表响应
class ConversationMembersResponse extends $pb.GeneratedMessage {
  factory ConversationMembersResponse({
    $core.String? conversationId,
    $core.Iterable<ParticipantProto>? members,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (members != null) {
      $result.members.addAll(members);
    }
    return $result;
  }
  ConversationMembersResponse._() : super();
  factory ConversationMembersResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMembersResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMembersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..pc<ParticipantProto>(2, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM, subBuilder: ParticipantProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationMembersResponse clone() => ConversationMembersResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMembersResponse copyWith(void Function(ConversationMembersResponse) updates) => super.copyWith((message) => updates(message as ConversationMembersResponse)) as ConversationMembersResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMembersResponse create() => ConversationMembersResponse._();
  ConversationMembersResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationMembersResponse> createRepeated() => $pb.PbList<ConversationMembersResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationMembersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMembersResponse>(create);
  static ConversationMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ParticipantProto> get members => $_getList(1);
}

/// 新增：会话成员变更通知
class ConversationMemberChangeNotification extends $pb.GeneratedMessage {
  factory ConversationMemberChangeNotification({
    $core.String? conversationId,
    ParticipantProto? member,
    $core.String? action,
    $core.String? actionBy,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (member != null) {
      $result.member = member;
    }
    if (action != null) {
      $result.action = action;
    }
    if (actionBy != null) {
      $result.actionBy = actionBy;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  ConversationMemberChangeNotification._() : super();
  factory ConversationMemberChangeNotification.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMemberChangeNotification.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMemberChangeNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOM<ParticipantProto>(2, _omitFieldNames ? '' : 'member', subBuilder: ParticipantProto.create)
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..aOS(4, _omitFieldNames ? '' : 'actionBy')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationMemberChangeNotification clone() => ConversationMemberChangeNotification()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMemberChangeNotification copyWith(void Function(ConversationMemberChangeNotification) updates) => super.copyWith((message) => updates(message as ConversationMemberChangeNotification)) as ConversationMemberChangeNotification;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeNotification create() => ConversationMemberChangeNotification._();
  ConversationMemberChangeNotification createEmptyInstance() => create();
  static $pb.PbList<ConversationMemberChangeNotification> createRepeated() => $pb.PbList<ConversationMemberChangeNotification>();
  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeNotification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMemberChangeNotification>(create);
  static ConversationMemberChangeNotification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  ParticipantProto get member => $_getN(1);
  @$pb.TagNumber(2)
  set member(ParticipantProto v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMember() => $_has(1);
  @$pb.TagNumber(2)
  void clearMember() => $_clearField(2);
  @$pb.TagNumber(2)
  ParticipantProto ensureMember() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get actionBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set actionBy($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasActionBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearActionBy() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 新增：获取会话成员请求
class ConversationMembersRequest extends $pb.GeneratedMessage {
  factory ConversationMembersRequest({
    $core.String? conversationId,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    return $result;
  }
  ConversationMembersRequest._() : super();
  factory ConversationMembersRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMembersRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMembersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationMembersRequest clone() => ConversationMembersRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMembersRequest copyWith(void Function(ConversationMembersRequest) updates) => super.copyWith((message) => updates(message as ConversationMembersRequest)) as ConversationMembersRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMembersRequest create() => ConversationMembersRequest._();
  ConversationMembersRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationMembersRequest> createRepeated() => $pb.PbList<ConversationMembersRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationMembersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMembersRequest>(create);
  static ConversationMembersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// 新增：获取单个会话详情请求
class ConversationDetailRequest extends $pb.GeneratedMessage {
  factory ConversationDetailRequest({
    $core.String? conversationId,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    return $result;
  }
  ConversationDetailRequest._() : super();
  factory ConversationDetailRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationDetailRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationDetailRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationDetailRequest clone() => ConversationDetailRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationDetailRequest copyWith(void Function(ConversationDetailRequest) updates) => super.copyWith((message) => updates(message as ConversationDetailRequest)) as ConversationDetailRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationDetailRequest create() => ConversationDetailRequest._();
  ConversationDetailRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationDetailRequest> createRepeated() => $pb.PbList<ConversationDetailRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationDetailRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationDetailRequest>(create);
  static ConversationDetailRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// 新增：获取单个会话详情响应
class ConversationDetailResponse extends $pb.GeneratedMessage {
  factory ConversationDetailResponse({
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
  ConversationDetailResponse._() : super();
  factory ConversationDetailResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationDetailResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationDetailResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<ConversationProto>(3, _omitFieldNames ? '' : 'conversation', subBuilder: ConversationProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationDetailResponse clone() => ConversationDetailResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationDetailResponse copyWith(void Function(ConversationDetailResponse) updates) => super.copyWith((message) => updates(message as ConversationDetailResponse)) as ConversationDetailResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationDetailResponse create() => ConversationDetailResponse._();
  ConversationDetailResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationDetailResponse> createRepeated() => $pb.PbList<ConversationDetailResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationDetailResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationDetailResponse>(create);
  static ConversationDetailResponse? _defaultInstance;

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


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
