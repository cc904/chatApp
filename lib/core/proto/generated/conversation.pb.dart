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
    $core.int? deliveredMessageIndex,
    $core.int? readMessageIndex,
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
    if (deliveredMessageIndex != null) {
      $result.deliveredMessageIndex = deliveredMessageIndex;
    }
    if (readMessageIndex != null) {
      $result.readMessageIndex = readMessageIndex;
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
    ..a<$core.int>(8, _omitFieldNames ? '' : 'deliveredMessageIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'readMessageIndex', $pb.PbFieldType.O3)
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

  /// userId
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 用户名称
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 用户头像
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// unreadCount
  @$pb.TagNumber(4)
  $core.int get unreadCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set unreadCount($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnreadCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnreadCount() => $_clearField(4);

  /// muted
  @$pb.TagNumber(5)
  $core.bool get muted => $_getBF(4);
  @$pb.TagNumber(5)
  set muted($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMuted() => $_has(4);
  @$pb.TagNumber(5)
  void clearMuted() => $_clearField(5);

  /// pinned
  @$pb.TagNumber(6)
  $core.bool get pinned => $_getBF(5);
  @$pb.TagNumber(6)
  set pinned($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPinned() => $_has(5);
  @$pb.TagNumber(6)
  void clearPinned() => $_clearField(6);

  /// joinedAt
  @$pb.TagNumber(7)
  $fixnum.Int64 get joinedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set joinedAt($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasJoinedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearJoinedAt() => $_clearField(7);

  /// 送达消息索引 - 最后送达的消息索引
  @$pb.TagNumber(8)
  $core.int get deliveredMessageIndex => $_getIZ(7);
  @$pb.TagNumber(8)
  set deliveredMessageIndex($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasDeliveredMessageIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearDeliveredMessageIndex() => $_clearField(8);

  /// 已读消息索引 - 最后已读的消息索引
  @$pb.TagNumber(9)
  $core.int get readMessageIndex => $_getIZ(8);
  @$pb.TagNumber(9)
  set readMessageIndex($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasReadMessageIndex() => $_has(8);
  @$pb.TagNumber(9)
  void clearReadMessageIndex() => $_clearField(9);

  /// role
  @$pb.TagNumber(10)
  MemberRole get role => $_getN(9);
  @$pb.TagNumber(10)
  set role(MemberRole v) { $_setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasRole() => $_has(9);
  @$pb.TagNumber(10)
  void clearRole() => $_clearField(10);

  /// addedBy
  @$pb.TagNumber(11)
  $core.String get addedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set addedBy($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasAddedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearAddedBy() => $_clearField(11);

  /// 是否在线
  @$pb.TagNumber(12)
  $core.bool get online => $_getBF(11);
  @$pb.TagNumber(12)
  set online($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasOnline() => $_has(11);
  @$pb.TagNumber(12)
  void clearOnline() => $_clearField(12);

  /// 是否活跃
  @$pb.TagNumber(13)
  $core.bool get isActive => $_getBF(12);
  @$pb.TagNumber(13)
  set isActive($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasIsActive() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsActive() => $_clearField(13);
}

/// 会话消息类型，匹配数据库模型
/// Socket.io事件: conversation:update, conversation:created, conversation:deleted
class ConversationProto extends $pb.GeneratedMessage {
  factory ConversationProto({
    $core.String? conversationId,
    ConversationType? type,
    $core.String? name,
    $core.String? avatar,
    $fixnum.Int64? createdAt,
    $core.String? createdBy,
    $core.int? firstMessageIndex,
    $core.int? lastMessageIndex,
    $fixnum.Int64? lastMessageTime,
    $core.String? lastMessagePreview,
    $core.String? lastMessageName,
    $core.Iterable<ParticipantProto>? participants,
    $core.String? description,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (type != null) {
      $result.type = type;
    }
    if (name != null) {
      $result.name = name;
    }
    if (avatar != null) {
      $result.avatar = avatar;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (createdBy != null) {
      $result.createdBy = createdBy;
    }
    if (firstMessageIndex != null) {
      $result.firstMessageIndex = firstMessageIndex;
    }
    if (lastMessageIndex != null) {
      $result.lastMessageIndex = lastMessageIndex;
    }
    if (lastMessageTime != null) {
      $result.lastMessageTime = lastMessageTime;
    }
    if (lastMessagePreview != null) {
      $result.lastMessagePreview = lastMessagePreview;
    }
    if (lastMessageName != null) {
      $result.lastMessageName = lastMessageName;
    }
    if (participants != null) {
      $result.participants.addAll(participants);
    }
    if (description != null) {
      $result.description = description;
    }
    return $result;
  }
  ConversationProto._() : super();
  factory ConversationProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..e<ConversationType>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ConversationType.PRIVATE, valueOf: ConversationType.valueOf, enumValues: ConversationType.values)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'createdBy')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'firstMessageIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'lastMessageIndex', $pb.PbFieldType.O3)
    ..aInt64(9, _omitFieldNames ? '' : 'lastMessageTime')
    ..aOS(10, _omitFieldNames ? '' : 'lastMessagePreview')
    ..aOS(11, _omitFieldNames ? '' : 'lastMessageName')
    ..pc<ParticipantProto>(12, _omitFieldNames ? '' : 'participants', $pb.PbFieldType.PM, subBuilder: ParticipantProto.create)
    ..aOS(13, _omitFieldNames ? '' : 'description')
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
  /// conversationId
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// type
  @$pb.TagNumber(2)
  ConversationType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ConversationType v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  /// name
  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  /// avatar
  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  /// createdAt
  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  /// createdBy
  @$pb.TagNumber(6)
  $core.String get createdBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdBy($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreatedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedBy() => $_clearField(6);

  /// 第一条消息的索引
  @$pb.TagNumber(7)
  $core.int get firstMessageIndex => $_getIZ(6);
  @$pb.TagNumber(7)
  set firstMessageIndex($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFirstMessageIndex() => $_has(6);
  @$pb.TagNumber(7)
  void clearFirstMessageIndex() => $_clearField(7);

  /// 最后一条消息的索引
  @$pb.TagNumber(8)
  $core.int get lastMessageIndex => $_getIZ(7);
  @$pb.TagNumber(8)
  set lastMessageIndex($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLastMessageIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastMessageIndex() => $_clearField(8);

  /// 最后一条消息的时间 保持兼容性
  @$pb.TagNumber(9)
  $fixnum.Int64 get lastMessageTime => $_getI64(8);
  @$pb.TagNumber(9)
  set lastMessageTime($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasLastMessageTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastMessageTime() => $_clearField(9);

  /// 最后一条消息的内容, 如果是语音或者视频消息, 则显示 [语音] 或 [视频]
  @$pb.TagNumber(10)
  $core.String get lastMessagePreview => $_getSZ(9);
  @$pb.TagNumber(10)
  set lastMessagePreview($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasLastMessagePreview() => $_has(9);
  @$pb.TagNumber(10)
  void clearLastMessagePreview() => $_clearField(10);

  /// 最后一条消息的发送者名称 在群聊或者频道中使用
  @$pb.TagNumber(11)
  $core.String get lastMessageName => $_getSZ(10);
  @$pb.TagNumber(11)
  set lastMessageName($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasLastMessageName() => $_has(10);
  @$pb.TagNumber(11)
  void clearLastMessageName() => $_clearField(11);

  /// 参与者详细信息，包含所有参与者的完整信息
  @$pb.TagNumber(12)
  $pb.PbList<ParticipantProto> get participants => $_getList(11);

  /// 会话描述（群聊/频道可选）
  @$pb.TagNumber(13)
  $core.String get description => $_getSZ(12);
  @$pb.TagNumber(13)
  set description($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDescription() => $_has(12);
  @$pb.TagNumber(13)
  void clearDescription() => $_clearField(13);
}

/// 会话列表
/// Socket.io事件: conversation:sync:response
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
/// Socket.io事件: conversation:sync
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

  /// 上次同步时间戳（毫秒），如果为0或不提供则获取所有会话
  @$pb.TagNumber(1)
  $fixnum.Int64 get lastSyncTime => $_getI64(0);
  @$pb.TagNumber(1)
  set lastSyncTime($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLastSyncTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastSyncTime() => $_clearField(1);
}

/// 会话创建请求
/// Socket.io事件: conversation:create
class ConversationCreateRequest extends $pb.GeneratedMessage {
  factory ConversationCreateRequest({
    $core.String? name,
    $core.String? avatar,
    ConversationType? type,
    $core.Iterable<$core.String>? participantIds,
    $core.String? contactUserId,
    $core.String? description,
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
    if (description != null) {
      $result.description = description;
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
    ..aOS(6, _omitFieldNames ? '' : 'description')
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

  /// 会话名称（群聊必填）
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// 会话头像
  @$pb.TagNumber(2)
  $core.String get avatar => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatar($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvatar() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatar() => $_clearField(2);

  /// 会话类型
  @$pb.TagNumber(3)
  ConversationType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(ConversationType v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  /// 初始参与者ID列表
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get participantIds => $_getList(3);

  /// 私聊对象ID（私聊必填）
  @$pb.TagNumber(5)
  $core.String get contactUserId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactUserId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactUserId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactUserId() => $_clearField(5);

  /// 会话描述（群聊/频道可选）
  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);
}

/// 会话创建成功响应
/// Socket.io事件: conversation:create:response
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

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 创建的会话
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

/// 获取单个会话详情请求
/// Socket.io事件: conversation:detail
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// 获取单个会话详情响应
/// Socket.io事件: conversation:detail:response
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

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息（失败时）
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 会话详情
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

/// 会话设置更新请求
/// Socket.io事件: conversation:settings:update
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 静音状态
  @$pb.TagNumber(2)
  $core.bool get muted => $_getBF(1);
  @$pb.TagNumber(2)
  set muted($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMuted() => $_has(1);
  @$pb.TagNumber(2)
  void clearMuted() => $_clearField(2);

  /// 置顶状态
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
/// Socket.io事件: conversation:settings:updated
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 是否成功
  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  /// 更新后的静音状态
  @$pb.TagNumber(3)
  $core.bool get muted => $_getBF(2);
  @$pb.TagNumber(3)
  set muted($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMuted() => $_has(2);
  @$pb.TagNumber(3)
  void clearMuted() => $_clearField(3);

  /// 更新后的置顶状态
  @$pb.TagNumber(4)
  $core.bool get pinned => $_getBF(3);
  @$pb.TagNumber(4)
  set pinned($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPinned() => $_has(3);
  @$pb.TagNumber(4)
  void clearPinned() => $_clearField(4);

  /// 更新时间戳
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 会话信息更新请求
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 新的会话名称
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 新的会话头像
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);
}

/// 会话信息更新响应 (使用ConversationResponse)
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

/// 会话加入/离开请求
/// Socket.io事件: conversation:join, conversation:leave
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID，可选，如果不提供则使用当前用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// 会话加入/离开响应
/// Socket.io事件: conversation:leave:response
class ConversationJoinLeaveResponse extends $pb.GeneratedMessage {
  factory ConversationJoinLeaveResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? conversationId,
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
    return $result;
  }
  ConversationJoinLeaveResponse._() : super();
  factory ConversationJoinLeaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationJoinLeaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationJoinLeaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationJoinLeaveResponse clone() => ConversationJoinLeaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationJoinLeaveResponse copyWith(void Function(ConversationJoinLeaveResponse) updates) => super.copyWith((message) => updates(message as ConversationJoinLeaveResponse)) as ConversationJoinLeaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveResponse create() => ConversationJoinLeaveResponse._();
  ConversationJoinLeaveResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationJoinLeaveResponse> createRepeated() => $pb.PbList<ConversationJoinLeaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationJoinLeaveResponse>(create);
  static ConversationJoinLeaveResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 会话ID
  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);
}

/// 参与者设置更新请求
/// Socket.io事件: participant:status:update
class ParticipantStatusUpdateRequest extends $pb.GeneratedMessage {
  factory ParticipantStatusUpdateRequest({
    $core.String? conversationId,
    $core.int? readMessageIndex,
    $core.bool? muted,
    $core.bool? pinned,
  }) {
    final $result = create();
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (readMessageIndex != null) {
      $result.readMessageIndex = readMessageIndex;
    }
    if (muted != null) {
      $result.muted = muted;
    }
    if (pinned != null) {
      $result.pinned = pinned;
    }
    return $result;
  }
  ParticipantStatusUpdateRequest._() : super();
  factory ParticipantStatusUpdateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ParticipantStatusUpdateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParticipantStatusUpdateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'readMessageIndex', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'muted')
    ..aOB(5, _omitFieldNames ? '' : 'pinned')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ParticipantStatusUpdateRequest clone() => ParticipantStatusUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ParticipantStatusUpdateRequest copyWith(void Function(ParticipantStatusUpdateRequest) updates) => super.copyWith((message) => updates(message as ParticipantStatusUpdateRequest)) as ParticipantStatusUpdateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateRequest create() => ParticipantStatusUpdateRequest._();
  ParticipantStatusUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<ParticipantStatusUpdateRequest> createRepeated() => $pb.PbList<ParticipantStatusUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParticipantStatusUpdateRequest>(create);
  static ParticipantStatusUpdateRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 已读消息索引
  @$pb.TagNumber(3)
  $core.int get readMessageIndex => $_getIZ(1);
  @$pb.TagNumber(3)
  set readMessageIndex($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasReadMessageIndex() => $_has(1);
  @$pb.TagNumber(3)
  void clearReadMessageIndex() => $_clearField(3);

  /// 静音状态
  @$pb.TagNumber(4)
  $core.bool get muted => $_getBF(2);
  @$pb.TagNumber(4)
  set muted($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasMuted() => $_has(2);
  @$pb.TagNumber(4)
  void clearMuted() => $_clearField(4);

  /// 置顶状态
  @$pb.TagNumber(5)
  $core.bool get pinned => $_getBF(3);
  @$pb.TagNumber(5)
  set pinned($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasPinned() => $_has(3);
  @$pb.TagNumber(5)
  void clearPinned() => $_clearField(5);
}

/// 参与者设置更新响应
/// Socket.io事件: participant:status:update:response
class ParticipantStatusUpdateResponse extends $pb.GeneratedMessage {
  factory ParticipantStatusUpdateResponse({
    $core.bool? success,
    $core.String? conversationId,
    ParticipantProto? participant,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (conversationId != null) {
      $result.conversationId = conversationId;
    }
    if (participant != null) {
      $result.participant = participant;
    }
    return $result;
  }
  ParticipantStatusUpdateResponse._() : super();
  factory ParticipantStatusUpdateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ParticipantStatusUpdateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParticipantStatusUpdateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOM<ParticipantProto>(3, _omitFieldNames ? '' : 'participant', subBuilder: ParticipantProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ParticipantStatusUpdateResponse clone() => ParticipantStatusUpdateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ParticipantStatusUpdateResponse copyWith(void Function(ParticipantStatusUpdateResponse) updates) => super.copyWith((message) => updates(message as ParticipantStatusUpdateResponse)) as ParticipantStatusUpdateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateResponse create() => ParticipantStatusUpdateResponse._();
  ParticipantStatusUpdateResponse createEmptyInstance() => create();
  static $pb.PbList<ParticipantStatusUpdateResponse> createRepeated() => $pb.PbList<ParticipantStatusUpdateResponse>();
  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParticipantStatusUpdateResponse>(create);
  static ParticipantStatusUpdateResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 会话ID
  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  /// 更新后的参与者信息
  @$pb.TagNumber(3)
  ParticipantProto get participant => $_getN(2);
  @$pb.TagNumber(3)
  set participant(ParticipantProto v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasParticipant() => $_has(2);
  @$pb.TagNumber(3)
  void clearParticipant() => $_clearField(3);
  @$pb.TagNumber(3)
  ParticipantProto ensureParticipant() => $_ensure(2);
}

/// 获取会话成员请求
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// 会话成员列表响应
/// Socket.io事件: conversation:members
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 成员列表
  @$pb.TagNumber(2)
  $pb.PbList<ParticipantProto> get members => $_getList(1);
}

/// 会话成员管理请求
/// Socket.io事件: conversation:member:add, conversation:member:change
class ConversationMemberChangeRequest extends $pb.GeneratedMessage {
  factory ConversationMemberChangeRequest({
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
  ConversationMemberChangeRequest._() : super();
  factory ConversationMemberChangeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMemberChangeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMemberChangeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConversationMemberChangeRequest clone() => ConversationMemberChangeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMemberChangeRequest copyWith(void Function(ConversationMemberChangeRequest) updates) => super.copyWith((message) => updates(message as ConversationMemberChangeRequest)) as ConversationMemberChangeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeRequest create() => ConversationMemberChangeRequest._();
  ConversationMemberChangeRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationMemberChangeRequest> createRepeated() => $pb.PbList<ConversationMemberChangeRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMemberChangeRequest>(create);
  static ConversationMemberChangeRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 操作类型: add, remove, promote, demote
  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);
}

/// 会话成员变更通知
/// Socket.io事件: conversation:member:change:Response
class ConversationMemberChangeResponse extends $pb.GeneratedMessage {
  factory ConversationMemberChangeResponse({
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
  ConversationMemberChangeResponse._() : super();
  factory ConversationMemberChangeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConversationMemberChangeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConversationMemberChangeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
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
  ConversationMemberChangeResponse clone() => ConversationMemberChangeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConversationMemberChangeResponse copyWith(void Function(ConversationMemberChangeResponse) updates) => super.copyWith((message) => updates(message as ConversationMemberChangeResponse)) as ConversationMemberChangeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeResponse create() => ConversationMemberChangeResponse._();
  ConversationMemberChangeResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationMemberChangeResponse> createRepeated() => $pb.PbList<ConversationMemberChangeResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationMemberChangeResponse>(create);
  static ConversationMemberChangeResponse? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 成员信息
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

  /// 操作类型: added, removed, promoted, demoted
  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  /// 操作执行者ID
  @$pb.TagNumber(4)
  $core.String get actionBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set actionBy($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasActionBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearActionBy() => $_clearField(4);

  /// 操作时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 会话更新通知
/// Socket.io事件: conversation:update:notification
class ConversationUpdateNotification extends $pb.GeneratedMessage {
  factory ConversationUpdateNotification({
    $core.String? conversationId,
    $core.int? lastMessageIndex,
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
    ..a<$core.int>(2, _omitFieldNames ? '' : 'lastMessageIndex', $pb.PbFieldType.O3)
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 最后消息索引
  @$pb.TagNumber(2)
  $core.int get lastMessageIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set lastMessageIndex($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastMessageIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMessageIndex() => $_clearField(2);

  /// 最后消息预览
  @$pb.TagNumber(3)
  $core.String get lastMessagePreview => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastMessagePreview($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLastMessagePreview() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastMessagePreview() => $_clearField(3);

  /// 发送者名称
  @$pb.TagNumber(4)
  $core.String get lastMessageName => $_getSZ(3);
  @$pb.TagNumber(4)
  set lastMessageName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLastMessageName() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastMessageName() => $_clearField(4);

  /// 未读消息数
  @$pb.TagNumber(5)
  $core.int get unreadCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set unreadCount($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUnreadCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnreadCount() => $_clearField(5);
}

/// 用户加入会话通知
/// Socket.io事件: conversation:user:joined
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 用户名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  /// 用户头像
  @$pb.TagNumber(4)
  $core.String get userAvatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set userAvatar($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserAvatar() => $_clearField(4);

  /// 加入时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get joinedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set joinedAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasJoinedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearJoinedAt() => $_clearField(5);

  /// 由谁邀请加入（如适用）
  @$pb.TagNumber(6)
  $core.String get joinedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set joinedBy($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasJoinedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearJoinedBy() => $_clearField(6);
}

/// 用户离开会话通知
/// Socket.io事件: conversation:user:left
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

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 用户名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  /// 离开时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get leftAt => $_getI64(3);
  @$pb.TagNumber(4)
  set leftAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLeftAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeftAt() => $_clearField(4);

  /// 离开原因（自行离开/被移除等）
  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);
}

/// 会话更新 (建议使用ConversationUpdateRequest)
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

  /// 更新动作：add_member, remove_member, change_title, etc.
  @$pb.TagNumber(7)
  $core.String get action => $_getSZ(6);
  @$pb.TagNumber(7)
  set action($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearAction() => $_clearField(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
