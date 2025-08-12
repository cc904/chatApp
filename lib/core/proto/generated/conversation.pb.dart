// This is a generated file - do not edit.
//
// Generated from conversation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

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
    $core.int? roleId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (unreadCount != null) result.unreadCount = unreadCount;
    if (muted != null) result.muted = muted;
    if (pinned != null) result.pinned = pinned;
    if (joinedAt != null) result.joinedAt = joinedAt;
    if (deliveredMessageIndex != null)
      result.deliveredMessageIndex = deliveredMessageIndex;
    if (readMessageIndex != null) result.readMessageIndex = readMessageIndex;
    if (role != null) result.role = role;
    if (addedBy != null) result.addedBy = addedBy;
    if (online != null) result.online = online;
    if (isActive != null) result.isActive = isActive;
    if (roleId != null) result.roleId = roleId;
    return result;
  }

  ParticipantProto._();

  factory ParticipantProto.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantProto.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantProto',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'unreadCount', $pb.PbFieldType.O3)
    ..aOB(5, _omitFieldNames ? '' : 'muted')
    ..aOB(6, _omitFieldNames ? '' : 'pinned')
    ..aInt64(7, _omitFieldNames ? '' : 'joinedAt')
    ..a<$core.int>(
        8, _omitFieldNames ? '' : 'deliveredMessageIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(
        9, _omitFieldNames ? '' : 'readMessageIndex', $pb.PbFieldType.O3)
    ..e<MemberRole>(10, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE,
        defaultOrMaker: MemberRole.MEMBER,
        valueOf: MemberRole.valueOf,
        enumValues: MemberRole.values)
    ..aOS(11, _omitFieldNames ? '' : 'addedBy')
    ..aOB(12, _omitFieldNames ? '' : 'online')
    ..aOB(13, _omitFieldNames ? '' : 'isActive')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'roleId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantProto clone() => ParticipantProto()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantProto copyWith(void Function(ParticipantProto) updates) =>
      super.copyWith((message) => updates(message as ParticipantProto))
          as ParticipantProto;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantProto create() => ParticipantProto._();
  @$core.override
  ParticipantProto createEmptyInstance() => create();
  static $pb.PbList<ParticipantProto> createRepeated() =>
      $pb.PbList<ParticipantProto>();
  @$core.pragma('dart2js:noInline')
  static ParticipantProto getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantProto>(create);
  static ParticipantProto? _defaultInstance;

  /// user_id
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 用户名称
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 用户头像
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// unread_count
  @$pb.TagNumber(4)
  $core.int get unreadCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set unreadCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUnreadCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnreadCount() => $_clearField(4);

  /// muted
  @$pb.TagNumber(5)
  $core.bool get muted => $_getBF(4);
  @$pb.TagNumber(5)
  set muted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMuted() => $_has(4);
  @$pb.TagNumber(5)
  void clearMuted() => $_clearField(5);

  /// pinned
  @$pb.TagNumber(6)
  $core.bool get pinned => $_getBF(5);
  @$pb.TagNumber(6)
  set pinned($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPinned() => $_has(5);
  @$pb.TagNumber(6)
  void clearPinned() => $_clearField(6);

  /// joined_at
  @$pb.TagNumber(7)
  $fixnum.Int64 get joinedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set joinedAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasJoinedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearJoinedAt() => $_clearField(7);

  /// 送达消息索引 - 最后送达的消息索引
  @$pb.TagNumber(8)
  $core.int get deliveredMessageIndex => $_getIZ(7);
  @$pb.TagNumber(8)
  set deliveredMessageIndex($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDeliveredMessageIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearDeliveredMessageIndex() => $_clearField(8);

  /// 已读消息索引 - 最后已读的消息索引
  @$pb.TagNumber(9)
  $core.int get readMessageIndex => $_getIZ(8);
  @$pb.TagNumber(9)
  set readMessageIndex($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasReadMessageIndex() => $_has(8);
  @$pb.TagNumber(9)
  void clearReadMessageIndex() => $_clearField(9);

  /// role
  @$pb.TagNumber(10)
  MemberRole get role => $_getN(9);
  @$pb.TagNumber(10)
  set role(MemberRole value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasRole() => $_has(9);
  @$pb.TagNumber(10)
  void clearRole() => $_clearField(10);

  /// added_by
  @$pb.TagNumber(11)
  $core.String get addedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set addedBy($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAddedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearAddedBy() => $_clearField(11);

  /// 是否在线
  @$pb.TagNumber(12)
  $core.bool get online => $_getBF(11);
  @$pb.TagNumber(12)
  set online($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasOnline() => $_has(11);
  @$pb.TagNumber(12)
  void clearOnline() => $_clearField(12);

  /// 是否活跃
  @$pb.TagNumber(13)
  $core.bool get isActive => $_getBF(12);
  @$pb.TagNumber(13)
  set isActive($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsActive() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsActive() => $_clearField(13);

  /// 用户角色ID
  @$pb.TagNumber(14)
  $core.int get roleId => $_getIZ(13);
  @$pb.TagNumber(14)
  set roleId($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRoleId() => $_has(13);
  @$pb.TagNumber(14)
  void clearRoleId() => $_clearField(14);
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
    $core.bool? requiresApproval,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (type != null) result.type = type;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (createdAt != null) result.createdAt = createdAt;
    if (createdBy != null) result.createdBy = createdBy;
    if (firstMessageIndex != null) result.firstMessageIndex = firstMessageIndex;
    if (lastMessageIndex != null) result.lastMessageIndex = lastMessageIndex;
    if (lastMessageTime != null) result.lastMessageTime = lastMessageTime;
    if (lastMessagePreview != null)
      result.lastMessagePreview = lastMessagePreview;
    if (lastMessageName != null) result.lastMessageName = lastMessageName;
    if (participants != null) result.participants.addAll(participants);
    if (description != null) result.description = description;
    if (requiresApproval != null) result.requiresApproval = requiresApproval;
    return result;
  }

  ConversationProto._();

  factory ConversationProto.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationProto.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationProto',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..e<ConversationType>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: ConversationType.PRIVATE,
        valueOf: ConversationType.valueOf,
        enumValues: ConversationType.values)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'createdBy')
    ..a<$core.int>(
        7, _omitFieldNames ? '' : 'firstMessageIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(
        8, _omitFieldNames ? '' : 'lastMessageIndex', $pb.PbFieldType.O3)
    ..aInt64(9, _omitFieldNames ? '' : 'lastMessageTime')
    ..aOS(10, _omitFieldNames ? '' : 'lastMessagePreview')
    ..aOS(11, _omitFieldNames ? '' : 'lastMessageName')
    ..pc<ParticipantProto>(
        12, _omitFieldNames ? '' : 'participants', $pb.PbFieldType.PM,
        subBuilder: ParticipantProto.create)
    ..aOS(13, _omitFieldNames ? '' : 'description')
    ..aOB(14, _omitFieldNames ? '' : 'requiresApproval')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationProto clone() => ConversationProto()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationProto copyWith(void Function(ConversationProto) updates) =>
      super.copyWith((message) => updates(message as ConversationProto))
          as ConversationProto;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationProto create() => ConversationProto._();
  @$core.override
  ConversationProto createEmptyInstance() => create();
  static $pb.PbList<ConversationProto> createRepeated() =>
      $pb.PbList<ConversationProto>();
  @$core.pragma('dart2js:noInline')
  static ConversationProto getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationProto>(create);
  static ConversationProto? _defaultInstance;

  /// 主要字段，完全匹配数据库模型
  /// conversation_id
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// type
  @$pb.TagNumber(2)
  ConversationType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ConversationType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  /// name
  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  /// avatar
  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  /// created_at
  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  /// created_by
  @$pb.TagNumber(6)
  $core.String get createdBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedBy() => $_clearField(6);

  /// 第一条消息的索引
  @$pb.TagNumber(7)
  $core.int get firstMessageIndex => $_getIZ(6);
  @$pb.TagNumber(7)
  set firstMessageIndex($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFirstMessageIndex() => $_has(6);
  @$pb.TagNumber(7)
  void clearFirstMessageIndex() => $_clearField(7);

  /// 最后一条消息的索引
  @$pb.TagNumber(8)
  $core.int get lastMessageIndex => $_getIZ(7);
  @$pb.TagNumber(8)
  set lastMessageIndex($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLastMessageIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastMessageIndex() => $_clearField(8);

  /// 最后一条消息的时间 保持兼容性
  @$pb.TagNumber(9)
  $fixnum.Int64 get lastMessageTime => $_getI64(8);
  @$pb.TagNumber(9)
  set lastMessageTime($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLastMessageTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastMessageTime() => $_clearField(9);

  /// 最后一条消息的内容, 如果是语音或者视频消息, 则显示 [语音] 或 [视频]
  @$pb.TagNumber(10)
  $core.String get lastMessagePreview => $_getSZ(9);
  @$pb.TagNumber(10)
  set lastMessagePreview($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLastMessagePreview() => $_has(9);
  @$pb.TagNumber(10)
  void clearLastMessagePreview() => $_clearField(10);

  /// 最后一条消息的发送者名称 在群聊或者频道中使用
  @$pb.TagNumber(11)
  $core.String get lastMessageName => $_getSZ(10);
  @$pb.TagNumber(11)
  set lastMessageName($core.String value) => $_setString(10, value);
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
  set description($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDescription() => $_has(12);
  @$pb.TagNumber(13)
  void clearDescription() => $_clearField(13);

  /// 是否需要加入验证（群聊/频道可选）
  @$pb.TagNumber(14)
  $core.bool get requiresApproval => $_getBF(13);
  @$pb.TagNumber(14)
  set requiresApproval($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRequiresApproval() => $_has(13);
  @$pb.TagNumber(14)
  void clearRequiresApproval() => $_clearField(14);
}

/// 会话列表
/// Socket.io事件: conversation:sync:response
class ConversationCollection extends $pb.GeneratedMessage {
  factory ConversationCollection({
    $core.Iterable<ConversationProto>? conversations,
  }) {
    final result = create();
    if (conversations != null) result.conversations.addAll(conversations);
    return result;
  }

  ConversationCollection._();

  factory ConversationCollection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationCollection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationCollection',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..pc<ConversationProto>(
        1, _omitFieldNames ? '' : 'conversations', $pb.PbFieldType.PM,
        subBuilder: ConversationProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationCollection clone() =>
      ConversationCollection()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationCollection copyWith(
          void Function(ConversationCollection) updates) =>
      super.copyWith((message) => updates(message as ConversationCollection))
          as ConversationCollection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationCollection create() => ConversationCollection._();
  @$core.override
  ConversationCollection createEmptyInstance() => create();
  static $pb.PbList<ConversationCollection> createRepeated() =>
      $pb.PbList<ConversationCollection>();
  @$core.pragma('dart2js:noInline')
  static ConversationCollection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationCollection>(create);
  static ConversationCollection? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConversationProto> get conversations => $_getList(0);
}

/// 同步会话请求
/// 客户端发送此请求以获取服务器上的最新会话数据
/// Socket.io事件: conversation:sync
/// 注意：服务器现在采用全量同步，忽略last_sync_time参数，每次返回用户的所有会话
class SyncConversationsRequest extends $pb.GeneratedMessage {
  factory SyncConversationsRequest({
    $fixnum.Int64? lastSyncTime,
  }) {
    final result = create();
    if (lastSyncTime != null) result.lastSyncTime = lastSyncTime;
    return result;
  }

  SyncConversationsRequest._();

  factory SyncConversationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncConversationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncConversationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'lastSyncTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncConversationsRequest clone() =>
      SyncConversationsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncConversationsRequest copyWith(
          void Function(SyncConversationsRequest) updates) =>
      super.copyWith((message) => updates(message as SyncConversationsRequest))
          as SyncConversationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncConversationsRequest create() => SyncConversationsRequest._();
  @$core.override
  SyncConversationsRequest createEmptyInstance() => create();
  static $pb.PbList<SyncConversationsRequest> createRepeated() =>
      $pb.PbList<SyncConversationsRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncConversationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncConversationsRequest>(create);
  static SyncConversationsRequest? _defaultInstance;

  /// 上次同步时间戳（毫秒）- 已废弃，服务器将忽略此参数并进行全量同步
  /// 保留此字段是为了向后兼容，但建议客户端传递0或不传递此字段
  @$pb.TagNumber(1)
  $fixnum.Int64 get lastSyncTime => $_getI64(0);
  @$pb.TagNumber(1)
  set lastSyncTime($fixnum.Int64 value) => $_setInt64(0, value);
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
    final result = create();
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (type != null) result.type = type;
    if (participantIds != null) result.participantIds.addAll(participantIds);
    if (contactUserId != null) result.contactUserId = contactUserId;
    if (description != null) result.description = description;
    return result;
  }

  ConversationCreateRequest._();

  factory ConversationCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'avatar')
    ..e<ConversationType>(3, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: ConversationType.PRIVATE,
        valueOf: ConversationType.valueOf,
        enumValues: ConversationType.values)
    ..pPS(4, _omitFieldNames ? '' : 'participantIds')
    ..aOS(5, _omitFieldNames ? '' : 'contactUserId')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationCreateRequest clone() =>
      ConversationCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationCreateRequest copyWith(
          void Function(ConversationCreateRequest) updates) =>
      super.copyWith((message) => updates(message as ConversationCreateRequest))
          as ConversationCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationCreateRequest create() => ConversationCreateRequest._();
  @$core.override
  ConversationCreateRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationCreateRequest> createRepeated() =>
      $pb.PbList<ConversationCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationCreateRequest>(create);
  static ConversationCreateRequest? _defaultInstance;

  /// 会话名称（群聊必填）
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// 会话头像
  @$pb.TagNumber(2)
  $core.String get avatar => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatar($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvatar() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatar() => $_clearField(2);

  /// 会话类型
  @$pb.TagNumber(3)
  ConversationType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(ConversationType value) => $_setField(3, value);
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
  set contactUserId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContactUserId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactUserId() => $_clearField(5);

  /// 会话描述（群聊/频道可选）
  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
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
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (conversation != null) result.conversation = conversation;
    return result;
  }

  ConversationCreateResponse._();

  factory ConversationCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<ConversationProto>(3, _omitFieldNames ? '' : 'conversation',
        subBuilder: ConversationProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationCreateResponse clone() =>
      ConversationCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationCreateResponse copyWith(
          void Function(ConversationCreateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationCreateResponse))
          as ConversationCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationCreateResponse create() => ConversationCreateResponse._();
  @$core.override
  ConversationCreateResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationCreateResponse> createRepeated() =>
      $pb.PbList<ConversationCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationCreateResponse>(create);
  static ConversationCreateResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 创建的会话
  @$pb.TagNumber(3)
  ConversationProto get conversation => $_getN(2);
  @$pb.TagNumber(3)
  set conversation(ConversationProto value) => $_setField(3, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  ConversationDetailRequest._();

  factory ConversationDetailRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationDetailRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationDetailRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationDetailRequest clone() =>
      ConversationDetailRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationDetailRequest copyWith(
          void Function(ConversationDetailRequest) updates) =>
      super.copyWith((message) => updates(message as ConversationDetailRequest))
          as ConversationDetailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationDetailRequest create() => ConversationDetailRequest._();
  @$core.override
  ConversationDetailRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationDetailRequest> createRepeated() =>
      $pb.PbList<ConversationDetailRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationDetailRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationDetailRequest>(create);
  static ConversationDetailRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
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
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (conversation != null) result.conversation = conversation;
    return result;
  }

  ConversationDetailResponse._();

  factory ConversationDetailResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationDetailResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationDetailResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<ConversationProto>(3, _omitFieldNames ? '' : 'conversation',
        subBuilder: ConversationProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationDetailResponse clone() =>
      ConversationDetailResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationDetailResponse copyWith(
          void Function(ConversationDetailResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationDetailResponse))
          as ConversationDetailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationDetailResponse create() => ConversationDetailResponse._();
  @$core.override
  ConversationDetailResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationDetailResponse> createRepeated() =>
      $pb.PbList<ConversationDetailResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationDetailResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationDetailResponse>(create);
  static ConversationDetailResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息（失败时）
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 会话详情
  @$pb.TagNumber(3)
  ConversationProto get conversation => $_getN(2);
  @$pb.TagNumber(3)
  set conversation(ConversationProto value) => $_setField(3, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (muted != null) result.muted = muted;
    if (pinned != null) result.pinned = pinned;
    return result;
  }

  ConversationSettingsUpdateRequest._();

  factory ConversationSettingsUpdateRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationSettingsUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationSettingsUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOB(2, _omitFieldNames ? '' : 'muted')
    ..aOB(3, _omitFieldNames ? '' : 'pinned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationSettingsUpdateRequest clone() =>
      ConversationSettingsUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationSettingsUpdateRequest copyWith(
          void Function(ConversationSettingsUpdateRequest) updates) =>
      super.copyWith((message) =>
              updates(message as ConversationSettingsUpdateRequest))
          as ConversationSettingsUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateRequest create() =>
      ConversationSettingsUpdateRequest._();
  @$core.override
  ConversationSettingsUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationSettingsUpdateRequest> createRepeated() =>
      $pb.PbList<ConversationSettingsUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationSettingsUpdateRequest>(
          create);
  static ConversationSettingsUpdateRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 静音状态
  @$pb.TagNumber(2)
  $core.bool get muted => $_getBF(1);
  @$pb.TagNumber(2)
  set muted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMuted() => $_has(1);
  @$pb.TagNumber(2)
  void clearMuted() => $_clearField(2);

  /// 置顶状态
  @$pb.TagNumber(3)
  $core.bool get pinned => $_getBF(2);
  @$pb.TagNumber(3)
  set pinned($core.bool value) => $_setBool(2, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (success != null) result.success = success;
    if (muted != null) result.muted = muted;
    if (pinned != null) result.pinned = pinned;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ConversationSettingsUpdateResponse._();

  factory ConversationSettingsUpdateResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationSettingsUpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationSettingsUpdateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOB(3, _omitFieldNames ? '' : 'muted')
    ..aOB(4, _omitFieldNames ? '' : 'pinned')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationSettingsUpdateResponse clone() =>
      ConversationSettingsUpdateResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationSettingsUpdateResponse copyWith(
          void Function(ConversationSettingsUpdateResponse) updates) =>
      super.copyWith((message) =>
              updates(message as ConversationSettingsUpdateResponse))
          as ConversationSettingsUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateResponse create() =>
      ConversationSettingsUpdateResponse._();
  @$core.override
  ConversationSettingsUpdateResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationSettingsUpdateResponse> createRepeated() =>
      $pb.PbList<ConversationSettingsUpdateResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationSettingsUpdateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationSettingsUpdateResponse>(
          create);
  static ConversationSettingsUpdateResponse? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 是否成功
  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  /// 更新后的静音状态
  @$pb.TagNumber(3)
  $core.bool get muted => $_getBF(2);
  @$pb.TagNumber(3)
  set muted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMuted() => $_has(2);
  @$pb.TagNumber(3)
  void clearMuted() => $_clearField(3);

  /// 更新后的置顶状态
  @$pb.TagNumber(4)
  $core.bool get pinned => $_getBF(3);
  @$pb.TagNumber(4)
  set pinned($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPinned() => $_has(3);
  @$pb.TagNumber(4)
  void clearPinned() => $_clearField(4);

  /// 更新时间戳
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 会话信息更新请求
/// Socket.io事件: conversation:info:update
class ConversationInfoUpdateRequest extends $pb.GeneratedMessage {
  factory ConversationInfoUpdateRequest({
    $core.String? conversationId,
    $core.String? name,
    $core.String? avatar,
    $core.String? description,
    $core.bool? requiresApproval,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (description != null) result.description = description;
    if (requiresApproval != null) result.requiresApproval = requiresApproval;
    return result;
  }

  ConversationInfoUpdateRequest._();

  factory ConversationInfoUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationInfoUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationInfoUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOB(5, _omitFieldNames ? '' : 'requiresApproval')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationInfoUpdateRequest clone() =>
      ConversationInfoUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationInfoUpdateRequest copyWith(
          void Function(ConversationInfoUpdateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationInfoUpdateRequest))
          as ConversationInfoUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationInfoUpdateRequest create() =>
      ConversationInfoUpdateRequest._();
  @$core.override
  ConversationInfoUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationInfoUpdateRequest> createRepeated() =>
      $pb.PbList<ConversationInfoUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationInfoUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationInfoUpdateRequest>(create);
  static ConversationInfoUpdateRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 新的会话名称
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 新的会话头像
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// 新的会话描述
  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  /// 是否需要加入验证
  @$pb.TagNumber(5)
  $core.bool get requiresApproval => $_getBF(4);
  @$pb.TagNumber(5)
  set requiresApproval($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRequiresApproval() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequiresApproval() => $_clearField(5);
}

/// 会话信息更新响应
/// Socket.io事件: conversation:info:update:response
class ConversationInfoUpdateResponse extends $pb.GeneratedMessage {
  factory ConversationInfoUpdateResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  ConversationInfoUpdateResponse._();

  factory ConversationInfoUpdateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationInfoUpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationInfoUpdateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationInfoUpdateResponse clone() =>
      ConversationInfoUpdateResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationInfoUpdateResponse copyWith(
          void Function(ConversationInfoUpdateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationInfoUpdateResponse))
          as ConversationInfoUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationInfoUpdateResponse create() =>
      ConversationInfoUpdateResponse._();
  @$core.override
  ConversationInfoUpdateResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationInfoUpdateResponse> createRepeated() =>
      $pb.PbList<ConversationInfoUpdateResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationInfoUpdateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationInfoUpdateResponse>(create);
  static ConversationInfoUpdateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// 会话信息更新通知
/// Socket.io事件: conversation:info:updated
class ConversationInfoUpdated extends $pb.GeneratedMessage {
  factory ConversationInfoUpdated({
    $core.String? conversationId,
    $core.String? name,
    $core.String? avatar,
    $core.String? description,
    $core.bool? requiresApproval,
    $core.String? updatedBy,
    $fixnum.Int64? updatedAt,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (description != null) result.description = description;
    if (requiresApproval != null) result.requiresApproval = requiresApproval;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  ConversationInfoUpdated._();

  factory ConversationInfoUpdated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationInfoUpdated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationInfoUpdated',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOB(5, _omitFieldNames ? '' : 'requiresApproval')
    ..aOS(6, _omitFieldNames ? '' : 'updatedBy')
    ..aInt64(7, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationInfoUpdated clone() =>
      ConversationInfoUpdated()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationInfoUpdated copyWith(
          void Function(ConversationInfoUpdated) updates) =>
      super.copyWith((message) => updates(message as ConversationInfoUpdated))
          as ConversationInfoUpdated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationInfoUpdated create() => ConversationInfoUpdated._();
  @$core.override
  ConversationInfoUpdated createEmptyInstance() => create();
  static $pb.PbList<ConversationInfoUpdated> createRepeated() =>
      $pb.PbList<ConversationInfoUpdated>();
  @$core.pragma('dart2js:noInline')
  static ConversationInfoUpdated getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationInfoUpdated>(create);
  static ConversationInfoUpdated? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 更新后的会话名称
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 更新后的会话头像
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// 更新后的会话描述
  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  /// 是否需要加入验证
  @$pb.TagNumber(5)
  $core.bool get requiresApproval => $_getBF(4);
  @$pb.TagNumber(5)
  set requiresApproval($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRequiresApproval() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequiresApproval() => $_clearField(5);

  /// 更新者ID
  @$pb.TagNumber(6)
  $core.String get updatedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set updatedBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdatedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedBy() => $_clearField(6);

  /// 更新时间
  @$pb.TagNumber(7)
  $fixnum.Int64 get updatedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set updatedAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdatedAt() => $_clearField(7);
}

/// 废弃的会话响应 (保持兼容性)
class ConversationResponse extends $pb.GeneratedMessage {
  factory ConversationResponse({
    $core.bool? success,
    $core.String? message,
    ConversationProto? conversation,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (conversation != null) result.conversation = conversation;
    return result;
  }

  ConversationResponse._();

  factory ConversationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<ConversationProto>(3, _omitFieldNames ? '' : 'conversation',
        subBuilder: ConversationProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationResponse clone() =>
      ConversationResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationResponse copyWith(void Function(ConversationResponse) updates) =>
      super.copyWith((message) => updates(message as ConversationResponse))
          as ConversationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationResponse create() => ConversationResponse._();
  @$core.override
  ConversationResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationResponse> createRepeated() =>
      $pb.PbList<ConversationResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationResponse>(create);
  static ConversationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  ConversationProto get conversation => $_getN(2);
  @$pb.TagNumber(3)
  set conversation(ConversationProto value) => $_setField(3, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    return result;
  }

  ConversationJoinLeaveRequest._();

  factory ConversationJoinLeaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationJoinLeaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationJoinLeaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationJoinLeaveRequest clone() =>
      ConversationJoinLeaveRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationJoinLeaveRequest copyWith(
          void Function(ConversationJoinLeaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationJoinLeaveRequest))
          as ConversationJoinLeaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveRequest create() =>
      ConversationJoinLeaveRequest._();
  @$core.override
  ConversationJoinLeaveRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationJoinLeaveRequest> createRepeated() =>
      $pb.PbList<ConversationJoinLeaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationJoinLeaveRequest>(create);
  static ConversationJoinLeaveRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID，可选，如果不提供则使用当前用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
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
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  ConversationJoinLeaveResponse._();

  factory ConversationJoinLeaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationJoinLeaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationJoinLeaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationJoinLeaveResponse clone() =>
      ConversationJoinLeaveResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationJoinLeaveResponse copyWith(
          void Function(ConversationJoinLeaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationJoinLeaveResponse))
          as ConversationJoinLeaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveResponse create() =>
      ConversationJoinLeaveResponse._();
  @$core.override
  ConversationJoinLeaveResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationJoinLeaveResponse> createRepeated() =>
      $pb.PbList<ConversationJoinLeaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationJoinLeaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationJoinLeaveResponse>(create);
  static ConversationJoinLeaveResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 会话ID
  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (readMessageIndex != null) result.readMessageIndex = readMessageIndex;
    if (muted != null) result.muted = muted;
    if (pinned != null) result.pinned = pinned;
    return result;
  }

  ParticipantStatusUpdateRequest._();

  factory ParticipantStatusUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantStatusUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantStatusUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..a<$core.int>(
        3, _omitFieldNames ? '' : 'readMessageIndex', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'muted')
    ..aOB(5, _omitFieldNames ? '' : 'pinned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantStatusUpdateRequest clone() =>
      ParticipantStatusUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantStatusUpdateRequest copyWith(
          void Function(ParticipantStatusUpdateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ParticipantStatusUpdateRequest))
          as ParticipantStatusUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateRequest create() =>
      ParticipantStatusUpdateRequest._();
  @$core.override
  ParticipantStatusUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<ParticipantStatusUpdateRequest> createRepeated() =>
      $pb.PbList<ParticipantStatusUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantStatusUpdateRequest>(create);
  static ParticipantStatusUpdateRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 已读消息索引
  @$pb.TagNumber(3)
  $core.int get readMessageIndex => $_getIZ(1);
  @$pb.TagNumber(3)
  set readMessageIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(3)
  $core.bool hasReadMessageIndex() => $_has(1);
  @$pb.TagNumber(3)
  void clearReadMessageIndex() => $_clearField(3);

  /// 静音状态
  @$pb.TagNumber(4)
  $core.bool get muted => $_getBF(2);
  @$pb.TagNumber(4)
  set muted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(4)
  $core.bool hasMuted() => $_has(2);
  @$pb.TagNumber(4)
  void clearMuted() => $_clearField(4);

  /// 置顶状态
  @$pb.TagNumber(5)
  $core.bool get pinned => $_getBF(3);
  @$pb.TagNumber(5)
  set pinned($core.bool value) => $_setBool(3, value);
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
    final result = create();
    if (success != null) result.success = success;
    if (conversationId != null) result.conversationId = conversationId;
    if (participant != null) result.participant = participant;
    return result;
  }

  ParticipantStatusUpdateResponse._();

  factory ParticipantStatusUpdateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantStatusUpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantStatusUpdateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOM<ParticipantProto>(3, _omitFieldNames ? '' : 'participant',
        subBuilder: ParticipantProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantStatusUpdateResponse clone() =>
      ParticipantStatusUpdateResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantStatusUpdateResponse copyWith(
          void Function(ParticipantStatusUpdateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ParticipantStatusUpdateResponse))
          as ParticipantStatusUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateResponse create() =>
      ParticipantStatusUpdateResponse._();
  @$core.override
  ParticipantStatusUpdateResponse createEmptyInstance() => create();
  static $pb.PbList<ParticipantStatusUpdateResponse> createRepeated() =>
      $pb.PbList<ParticipantStatusUpdateResponse>();
  @$core.pragma('dart2js:noInline')
  static ParticipantStatusUpdateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantStatusUpdateResponse>(
          create);
  static ParticipantStatusUpdateResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 会话ID
  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  /// 更新后的参与者信息
  @$pb.TagNumber(3)
  ParticipantProto get participant => $_getN(2);
  @$pb.TagNumber(3)
  set participant(ParticipantProto value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasParticipant() => $_has(2);
  @$pb.TagNumber(3)
  void clearParticipant() => $_clearField(3);
  @$pb.TagNumber(3)
  ParticipantProto ensureParticipant() => $_ensure(2);
}

/// 参与者索引变更通知（统一的已读/送达索引通知）
/// Socket.io事件: conversation:participant:index:updated
class ParticipantIndexUpdatedNotification extends $pb.GeneratedMessage {
  factory ParticipantIndexUpdatedNotification({
    $core.String? conversationId,
    $core.String? userId,
    $core.int? readMessageIndex,
    $core.int? deliveredMessageIndex,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (readMessageIndex != null) result.readMessageIndex = readMessageIndex;
    if (deliveredMessageIndex != null)
      result.deliveredMessageIndex = deliveredMessageIndex;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ParticipantIndexUpdatedNotification._();

  factory ParticipantIndexUpdatedNotification.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantIndexUpdatedNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantIndexUpdatedNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.int>(
        3, _omitFieldNames ? '' : 'readMessageIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(
        4, _omitFieldNames ? '' : 'deliveredMessageIndex', $pb.PbFieldType.O3)
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantIndexUpdatedNotification clone() =>
      ParticipantIndexUpdatedNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantIndexUpdatedNotification copyWith(
          void Function(ParticipantIndexUpdatedNotification) updates) =>
      super.copyWith((message) =>
              updates(message as ParticipantIndexUpdatedNotification))
          as ParticipantIndexUpdatedNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantIndexUpdatedNotification create() =>
      ParticipantIndexUpdatedNotification._();
  @$core.override
  ParticipantIndexUpdatedNotification createEmptyInstance() => create();
  static $pb.PbList<ParticipantIndexUpdatedNotification> createRepeated() =>
      $pb.PbList<ParticipantIndexUpdatedNotification>();
  @$core.pragma('dart2js:noInline')
  static ParticipantIndexUpdatedNotification getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          ParticipantIndexUpdatedNotification>(create);
  static ParticipantIndexUpdatedNotification? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 发生变更的用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 更新后的已读消息索引（可选，只有在变化时才下发）
  @$pb.TagNumber(3)
  $core.int get readMessageIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set readMessageIndex($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReadMessageIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearReadMessageIndex() => $_clearField(3);

  /// 更新后的送达消息索引（可选，只有在变化时才下发）
  @$pb.TagNumber(4)
  $core.int get deliveredMessageIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set deliveredMessageIndex($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeliveredMessageIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeliveredMessageIndex() => $_clearField(4);

  /// 服务器时间戳（毫秒）
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 获取会话成员请求
class ConversationMembersRequest extends $pb.GeneratedMessage {
  factory ConversationMembersRequest({
    $core.String? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  ConversationMembersRequest._();

  factory ConversationMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationMembersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMembersRequest clone() =>
      ConversationMembersRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMembersRequest copyWith(
          void Function(ConversationMembersRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationMembersRequest))
          as ConversationMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMembersRequest create() => ConversationMembersRequest._();
  @$core.override
  ConversationMembersRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationMembersRequest> createRepeated() =>
      $pb.PbList<ConversationMembersRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationMembersRequest>(create);
  static ConversationMembersRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (members != null) result.members.addAll(members);
    return result;
  }

  ConversationMembersResponse._();

  factory ConversationMembersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationMembersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationMembersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..pc<ParticipantProto>(
        2, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM,
        subBuilder: ParticipantProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMembersResponse clone() =>
      ConversationMembersResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMembersResponse copyWith(
          void Function(ConversationMembersResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationMembersResponse))
          as ConversationMembersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMembersResponse create() =>
      ConversationMembersResponse._();
  @$core.override
  ConversationMembersResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationMembersResponse> createRepeated() =>
      $pb.PbList<ConversationMembersResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationMembersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationMembersResponse>(create);
  static ConversationMembersResponse? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (action != null) result.action = action;
    return result;
  }

  ConversationMemberChangeRequest._();

  factory ConversationMemberChangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationMemberChangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationMemberChangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMemberChangeRequest clone() =>
      ConversationMemberChangeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMemberChangeRequest copyWith(
          void Function(ConversationMemberChangeRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationMemberChangeRequest))
          as ConversationMemberChangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeRequest create() =>
      ConversationMemberChangeRequest._();
  @$core.override
  ConversationMemberChangeRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationMemberChangeRequest> createRepeated() =>
      $pb.PbList<ConversationMemberChangeRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationMemberChangeRequest>(
          create);
  static ConversationMemberChangeRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 操作类型: add, remove, promote, demote
  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String value) => $_setString(2, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (member != null) result.member = member;
    if (action != null) result.action = action;
    if (actionBy != null) result.actionBy = actionBy;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ConversationMemberChangeResponse._();

  factory ConversationMemberChangeResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationMemberChangeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationMemberChangeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOM<ParticipantProto>(2, _omitFieldNames ? '' : 'member',
        subBuilder: ParticipantProto.create)
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..aOS(4, _omitFieldNames ? '' : 'actionBy')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMemberChangeResponse clone() =>
      ConversationMemberChangeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationMemberChangeResponse copyWith(
          void Function(ConversationMemberChangeResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationMemberChangeResponse))
          as ConversationMemberChangeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeResponse create() =>
      ConversationMemberChangeResponse._();
  @$core.override
  ConversationMemberChangeResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationMemberChangeResponse> createRepeated() =>
      $pb.PbList<ConversationMemberChangeResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationMemberChangeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationMemberChangeResponse>(
          create);
  static ConversationMemberChangeResponse? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 成员信息
  @$pb.TagNumber(2)
  ParticipantProto get member => $_getN(1);
  @$pb.TagNumber(2)
  set member(ParticipantProto value) => $_setField(2, value);
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
  set action($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  /// 操作执行者ID
  @$pb.TagNumber(4)
  $core.String get actionBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set actionBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActionBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearActionBy() => $_clearField(4);

  /// 操作时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 会话预览更新通知
/// Socket.io事件: conversation:preview:updated
class ConversationPreviewUpdated extends $pb.GeneratedMessage {
  factory ConversationPreviewUpdated({
    $core.String? conversationId,
    $core.int? lastMessageIndex,
    $core.String? lastMessagePreview,
    $core.String? lastMessageName,
    $fixnum.Int64? lastMessageTime,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (lastMessageIndex != null) result.lastMessageIndex = lastMessageIndex;
    if (lastMessagePreview != null)
      result.lastMessagePreview = lastMessagePreview;
    if (lastMessageName != null) result.lastMessageName = lastMessageName;
    if (lastMessageTime != null) result.lastMessageTime = lastMessageTime;
    return result;
  }

  ConversationPreviewUpdated._();

  factory ConversationPreviewUpdated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationPreviewUpdated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationPreviewUpdated',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..a<$core.int>(
        2, _omitFieldNames ? '' : 'lastMessageIndex', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'lastMessagePreview')
    ..aOS(4, _omitFieldNames ? '' : 'lastMessageName')
    ..aInt64(5, _omitFieldNames ? '' : 'lastMessageTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationPreviewUpdated clone() =>
      ConversationPreviewUpdated()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationPreviewUpdated copyWith(
          void Function(ConversationPreviewUpdated) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationPreviewUpdated))
          as ConversationPreviewUpdated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationPreviewUpdated create() => ConversationPreviewUpdated._();
  @$core.override
  ConversationPreviewUpdated createEmptyInstance() => create();
  static $pb.PbList<ConversationPreviewUpdated> createRepeated() =>
      $pb.PbList<ConversationPreviewUpdated>();
  @$core.pragma('dart2js:noInline')
  static ConversationPreviewUpdated getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationPreviewUpdated>(create);
  static ConversationPreviewUpdated? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 最后消息索引
  @$pb.TagNumber(2)
  $core.int get lastMessageIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set lastMessageIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastMessageIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMessageIndex() => $_clearField(2);

  /// 最后消息预览
  @$pb.TagNumber(3)
  $core.String get lastMessagePreview => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastMessagePreview($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastMessagePreview() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastMessagePreview() => $_clearField(3);

  /// 发送者名称
  @$pb.TagNumber(4)
  $core.String get lastMessageName => $_getSZ(3);
  @$pb.TagNumber(4)
  set lastMessageName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastMessageName() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastMessageName() => $_clearField(4);

  /// 最后消息时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get lastMessageTime => $_getI64(4);
  @$pb.TagNumber(5)
  set lastMessageTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLastMessageTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastMessageTime() => $_clearField(5);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (userAvatar != null) result.userAvatar = userAvatar;
    if (joinedAt != null) result.joinedAt = joinedAt;
    if (joinedBy != null) result.joinedBy = joinedBy;
    return result;
  }

  UserJoinedNotification._();

  factory UserJoinedNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserJoinedNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserJoinedNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'userName')
    ..aOS(4, _omitFieldNames ? '' : 'userAvatar')
    ..aInt64(5, _omitFieldNames ? '' : 'joinedAt')
    ..aOS(6, _omitFieldNames ? '' : 'joinedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserJoinedNotification clone() =>
      UserJoinedNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserJoinedNotification copyWith(
          void Function(UserJoinedNotification) updates) =>
      super.copyWith((message) => updates(message as UserJoinedNotification))
          as UserJoinedNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserJoinedNotification create() => UserJoinedNotification._();
  @$core.override
  UserJoinedNotification createEmptyInstance() => create();
  static $pb.PbList<UserJoinedNotification> createRepeated() =>
      $pb.PbList<UserJoinedNotification>();
  @$core.pragma('dart2js:noInline')
  static UserJoinedNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserJoinedNotification>(create);
  static UserJoinedNotification? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 用户名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  /// 用户头像
  @$pb.TagNumber(4)
  $core.String get userAvatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set userAvatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUserAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserAvatar() => $_clearField(4);

  /// 加入时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get joinedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set joinedAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasJoinedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearJoinedAt() => $_clearField(5);

  /// 由谁邀请加入（如适用）
  @$pb.TagNumber(6)
  $core.String get joinedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set joinedBy($core.String value) => $_setString(5, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (leftAt != null) result.leftAt = leftAt;
    if (reason != null) result.reason = reason;
    return result;
  }

  UserLeftNotification._();

  factory UserLeftNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserLeftNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserLeftNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'userName')
    ..aInt64(4, _omitFieldNames ? '' : 'leftAt')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLeftNotification clone() =>
      UserLeftNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLeftNotification copyWith(void Function(UserLeftNotification) updates) =>
      super.copyWith((message) => updates(message as UserLeftNotification))
          as UserLeftNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserLeftNotification create() => UserLeftNotification._();
  @$core.override
  UserLeftNotification createEmptyInstance() => create();
  static $pb.PbList<UserLeftNotification> createRepeated() =>
      $pb.PbList<UserLeftNotification>();
  @$core.pragma('dart2js:noInline')
  static UserLeftNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserLeftNotification>(create);
  static UserLeftNotification? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 用户名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  /// 离开时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get leftAt => $_getI64(3);
  @$pb.TagNumber(4)
  set leftAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLeftAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeftAt() => $_clearField(4);

  /// 离开原因（自行离开/被移除等）
  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
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
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (participantIds != null) result.participantIds.addAll(participantIds);
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (action != null) result.action = action;
    return result;
  }

  ConversationUpdate._();

  factory ConversationUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..pPS(4, _omitFieldNames ? '' : 'participantIds')
    ..aInt64(5, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(6, _omitFieldNames ? '' : 'updatedBy')
    ..aOS(7, _omitFieldNames ? '' : 'action')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationUpdate clone() => ConversationUpdate()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationUpdate copyWith(void Function(ConversationUpdate) updates) =>
      super.copyWith((message) => updates(message as ConversationUpdate))
          as ConversationUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationUpdate create() => ConversationUpdate._();
  @$core.override
  ConversationUpdate createEmptyInstance() => create();
  static $pb.PbList<ConversationUpdate> createRepeated() =>
      $pb.PbList<ConversationUpdate>();
  @$core.pragma('dart2js:noInline')
  static ConversationUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationUpdate>(create);
  static ConversationUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get participantIds => $_getList(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get updatedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set updatedAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get updatedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set updatedBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdatedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedBy() => $_clearField(6);

  /// 更新动作：add_member, remove_member, change_title, etc.
  @$pb.TagNumber(7)
  $core.String get action => $_getSZ(6);
  @$pb.TagNumber(7)
  set action($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearAction() => $_clearField(7);
}

/// 退出会话请求
/// Socket.io事件: conversation:exit
class ConversationExitRequest extends $pb.GeneratedMessage {
  factory ConversationExitRequest({
    $core.String? conversationId,
    $core.String? reason,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ConversationExitRequest._();

  factory ConversationExitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationExitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationExitRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationExitRequest clone() =>
      ConversationExitRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationExitRequest copyWith(
          void Function(ConversationExitRequest) updates) =>
      super.copyWith((message) => updates(message as ConversationExitRequest))
          as ConversationExitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationExitRequest create() => ConversationExitRequest._();
  @$core.override
  ConversationExitRequest createEmptyInstance() => create();
  static $pb.PbList<ConversationExitRequest> createRepeated() =>
      $pb.PbList<ConversationExitRequest>();
  @$core.pragma('dart2js:noInline')
  static ConversationExitRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationExitRequest>(create);
  static ConversationExitRequest? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 退出原因（可选）
  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

/// 退出会话响应
/// Socket.io事件: conversation:exit:response
class ConversationExitResponse extends $pb.GeneratedMessage {
  factory ConversationExitResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? conversationId,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  ConversationExitResponse._();

  factory ConversationExitResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationExitResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationExitResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationExitResponse clone() =>
      ConversationExitResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationExitResponse copyWith(
          void Function(ConversationExitResponse) updates) =>
      super.copyWith((message) => updates(message as ConversationExitResponse))
          as ConversationExitResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationExitResponse create() => ConversationExitResponse._();
  @$core.override
  ConversationExitResponse createEmptyInstance() => create();
  static $pb.PbList<ConversationExitResponse> createRepeated() =>
      $pb.PbList<ConversationExitResponse>();
  @$core.pragma('dart2js:noInline')
  static ConversationExitResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationExitResponse>(create);
  static ConversationExitResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 会话ID
  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);
}

/// 成员退出通知（用于广播给其他成员）
/// Socket.io事件: conversation:member:exited
class MemberExitedNotification extends $pb.GeneratedMessage {
  factory MemberExitedNotification({
    $core.String? conversationId,
    $core.String? userId,
    $core.String? userName,
    $fixnum.Int64? exitedAt,
    $core.String? reason,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (exitedAt != null) result.exitedAt = exitedAt;
    if (reason != null) result.reason = reason;
    return result;
  }

  MemberExitedNotification._();

  factory MemberExitedNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MemberExitedNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberExitedNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'userName')
    ..aInt64(4, _omitFieldNames ? '' : 'exitedAt')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberExitedNotification clone() =>
      MemberExitedNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberExitedNotification copyWith(
          void Function(MemberExitedNotification) updates) =>
      super.copyWith((message) => updates(message as MemberExitedNotification))
          as MemberExitedNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberExitedNotification create() => MemberExitedNotification._();
  @$core.override
  MemberExitedNotification createEmptyInstance() => create();
  static $pb.PbList<MemberExitedNotification> createRepeated() =>
      $pb.PbList<MemberExitedNotification>();
  @$core.pragma('dart2js:noInline')
  static MemberExitedNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemberExitedNotification>(create);
  static MemberExitedNotification? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 退出的用户ID
  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 退出的用户名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  /// 退出时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get exitedAt => $_getI64(3);
  @$pb.TagNumber(4)
  set exitedAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExitedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExitedAt() => $_clearField(4);

  /// 退出原因
  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);
}

/// 会话移除通知（发送给被退出的用户自己）
/// Socket.io事件: conversation:removed
class ConversationRemovedNotification extends $pb.GeneratedMessage {
  factory ConversationRemovedNotification({
    $core.String? conversationId,
    $core.String? conversationName,
    $fixnum.Int64? removedAt,
    $core.String? reason,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (conversationName != null) result.conversationName = conversationName;
    if (removedAt != null) result.removedAt = removedAt;
    if (reason != null) result.reason = reason;
    return result;
  }

  ConversationRemovedNotification._();

  factory ConversationRemovedNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationRemovedNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationRemovedNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationName')
    ..aInt64(3, _omitFieldNames ? '' : 'removedAt')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationRemovedNotification clone() =>
      ConversationRemovedNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationRemovedNotification copyWith(
          void Function(ConversationRemovedNotification) updates) =>
      super.copyWith(
              (message) => updates(message as ConversationRemovedNotification))
          as ConversationRemovedNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationRemovedNotification create() =>
      ConversationRemovedNotification._();
  @$core.override
  ConversationRemovedNotification createEmptyInstance() => create();
  static $pb.PbList<ConversationRemovedNotification> createRepeated() =>
      $pb.PbList<ConversationRemovedNotification>();
  @$core.pragma('dart2js:noInline')
  static ConversationRemovedNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationRemovedNotification>(
          create);
  static ConversationRemovedNotification? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 会话名称
  @$pb.TagNumber(2)
  $core.String get conversationName => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationName() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationName() => $_clearField(2);

  /// 移除时间
  @$pb.TagNumber(3)
  $fixnum.Int64 get removedAt => $_getI64(2);
  @$pb.TagNumber(3)
  set removedAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRemovedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemovedAt() => $_clearField(3);

  /// 移除原因
  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);
}

/// 加入请求数据结构
class JoinRequestProto extends $pb.GeneratedMessage {
  factory JoinRequestProto({
    $core.String? requestId,
    $core.String? conversationId,
    $core.String? userId,
    $core.String? userName,
    $core.String? userAvatar,
    $core.String? message,
    JoinRequestStatus? status,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? processedAt,
    $core.String? processedBy,
    $core.String? processedByName,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (userAvatar != null) result.userAvatar = userAvatar;
    if (message != null) result.message = message;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (processedAt != null) result.processedAt = processedAt;
    if (processedBy != null) result.processedBy = processedBy;
    if (processedByName != null) result.processedByName = processedByName;
    return result;
  }

  JoinRequestProto._();

  factory JoinRequestProto.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestProto.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestProto',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'userName')
    ..aOS(5, _omitFieldNames ? '' : 'userAvatar')
    ..aOS(6, _omitFieldNames ? '' : 'message')
    ..e<JoinRequestStatus>(
        7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE,
        defaultOrMaker: JoinRequestStatus.JOIN_PENDING,
        valueOf: JoinRequestStatus.valueOf,
        enumValues: JoinRequestStatus.values)
    ..aInt64(8, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(9, _omitFieldNames ? '' : 'processedAt')
    ..aOS(10, _omitFieldNames ? '' : 'processedBy')
    ..aOS(11, _omitFieldNames ? '' : 'processedByName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestProto clone() => JoinRequestProto()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestProto copyWith(void Function(JoinRequestProto) updates) =>
      super.copyWith((message) => updates(message as JoinRequestProto))
          as JoinRequestProto;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestProto create() => JoinRequestProto._();
  @$core.override
  JoinRequestProto createEmptyInstance() => create();
  static $pb.PbList<JoinRequestProto> createRepeated() =>
      $pb.PbList<JoinRequestProto>();
  @$core.pragma('dart2js:noInline')
  static JoinRequestProto getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestProto>(create);
  static JoinRequestProto? _defaultInstance;

  /// 请求ID
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// 会话ID
  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  /// 申请者ID
  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  /// 申请者名称
  @$pb.TagNumber(4)
  $core.String get userName => $_getSZ(3);
  @$pb.TagNumber(4)
  set userName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUserName() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserName() => $_clearField(4);

  /// 申请者头像
  @$pb.TagNumber(5)
  $core.String get userAvatar => $_getSZ(4);
  @$pb.TagNumber(5)
  set userAvatar($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUserAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserAvatar() => $_clearField(5);

  /// 申请消息
  @$pb.TagNumber(6)
  $core.String get message => $_getSZ(5);
  @$pb.TagNumber(6)
  set message($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);

  /// 请求状态
  @$pb.TagNumber(7)
  JoinRequestStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(JoinRequestStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  /// 创建时间
  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAt => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);

  /// 处理时间
  @$pb.TagNumber(9)
  $fixnum.Int64 get processedAt => $_getI64(8);
  @$pb.TagNumber(9)
  set processedAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasProcessedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearProcessedAt() => $_clearField(9);

  /// 处理者ID
  @$pb.TagNumber(10)
  $core.String get processedBy => $_getSZ(9);
  @$pb.TagNumber(10)
  set processedBy($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasProcessedBy() => $_has(9);
  @$pb.TagNumber(10)
  void clearProcessedBy() => $_clearField(10);

  /// 处理者名称
  @$pb.TagNumber(11)
  $core.String get processedByName => $_getSZ(10);
  @$pb.TagNumber(11)
  set processedByName($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasProcessedByName() => $_has(10);
  @$pb.TagNumber(11)
  void clearProcessedByName() => $_clearField(11);
}

/// 发送加入请求
/// Socket.io事件: conversation:join:request:send
class SendJoinRequestMessage extends $pb.GeneratedMessage {
  factory SendJoinRequestMessage({
    $core.String? conversationId,
    $core.String? message,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (message != null) result.message = message;
    return result;
  }

  SendJoinRequestMessage._();

  factory SendJoinRequestMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendJoinRequestMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendJoinRequestMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendJoinRequestMessage clone() =>
      SendJoinRequestMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendJoinRequestMessage copyWith(
          void Function(SendJoinRequestMessage) updates) =>
      super.copyWith((message) => updates(message as SendJoinRequestMessage))
          as SendJoinRequestMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendJoinRequestMessage create() => SendJoinRequestMessage._();
  @$core.override
  SendJoinRequestMessage createEmptyInstance() => create();
  static $pb.PbList<SendJoinRequestMessage> createRepeated() =>
      $pb.PbList<SendJoinRequestMessage>();
  @$core.pragma('dart2js:noInline')
  static SendJoinRequestMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendJoinRequestMessage>(create);
  static SendJoinRequestMessage? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 申请消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// 发送加入请求响应
/// Socket.io事件: conversation:join:request:send:response
class SendJoinRequestResponse extends $pb.GeneratedMessage {
  factory SendJoinRequestResponse({
    $core.bool? success,
    $core.String? message,
    JoinRequestProto? request,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (request != null) result.request = request;
    return result;
  }

  SendJoinRequestResponse._();

  factory SendJoinRequestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendJoinRequestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendJoinRequestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<JoinRequestProto>(3, _omitFieldNames ? '' : 'request',
        subBuilder: JoinRequestProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendJoinRequestResponse clone() =>
      SendJoinRequestResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendJoinRequestResponse copyWith(
          void Function(SendJoinRequestResponse) updates) =>
      super.copyWith((message) => updates(message as SendJoinRequestResponse))
          as SendJoinRequestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendJoinRequestResponse create() => SendJoinRequestResponse._();
  @$core.override
  SendJoinRequestResponse createEmptyInstance() => create();
  static $pb.PbList<SendJoinRequestResponse> createRepeated() =>
      $pb.PbList<SendJoinRequestResponse>();
  @$core.pragma('dart2js:noInline')
  static SendJoinRequestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendJoinRequestResponse>(create);
  static SendJoinRequestResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 请求详情（成功时）
  @$pb.TagNumber(3)
  JoinRequestProto get request => $_getN(2);
  @$pb.TagNumber(3)
  set request(JoinRequestProto value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  JoinRequestProto ensureRequest() => $_ensure(2);
}

/// 处理加入请求
/// Socket.io事件: conversation:join:request:process
class ProcessJoinRequestMessage extends $pb.GeneratedMessage {
  factory ProcessJoinRequestMessage({
    $core.String? requestId,
    $core.String? action,
    $core.String? reason,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (action != null) result.action = action;
    if (reason != null) result.reason = reason;
    return result;
  }

  ProcessJoinRequestMessage._();

  factory ProcessJoinRequestMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessJoinRequestMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessJoinRequestMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'action')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessJoinRequestMessage clone() =>
      ProcessJoinRequestMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessJoinRequestMessage copyWith(
          void Function(ProcessJoinRequestMessage) updates) =>
      super.copyWith((message) => updates(message as ProcessJoinRequestMessage))
          as ProcessJoinRequestMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessJoinRequestMessage create() => ProcessJoinRequestMessage._();
  @$core.override
  ProcessJoinRequestMessage createEmptyInstance() => create();
  static $pb.PbList<ProcessJoinRequestMessage> createRepeated() =>
      $pb.PbList<ProcessJoinRequestMessage>();
  @$core.pragma('dart2js:noInline')
  static ProcessJoinRequestMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessJoinRequestMessage>(create);
  static ProcessJoinRequestMessage? _defaultInstance;

  /// 请求ID
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// 操作：approve（通过）、reject（拒绝）
  @$pb.TagNumber(2)
  $core.String get action => $_getSZ(1);
  @$pb.TagNumber(2)
  set action($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  /// 处理理由（可选）
  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

/// 处理加入请求响应
/// Socket.io事件: conversation:join:request:process:response
class ProcessJoinRequestResponse extends $pb.GeneratedMessage {
  factory ProcessJoinRequestResponse({
    $core.bool? success,
    $core.String? message,
    JoinRequestProto? request,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (request != null) result.request = request;
    return result;
  }

  ProcessJoinRequestResponse._();

  factory ProcessJoinRequestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessJoinRequestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessJoinRequestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<JoinRequestProto>(3, _omitFieldNames ? '' : 'request',
        subBuilder: JoinRequestProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessJoinRequestResponse clone() =>
      ProcessJoinRequestResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessJoinRequestResponse copyWith(
          void Function(ProcessJoinRequestResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ProcessJoinRequestResponse))
          as ProcessJoinRequestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessJoinRequestResponse create() => ProcessJoinRequestResponse._();
  @$core.override
  ProcessJoinRequestResponse createEmptyInstance() => create();
  static $pb.PbList<ProcessJoinRequestResponse> createRepeated() =>
      $pb.PbList<ProcessJoinRequestResponse>();
  @$core.pragma('dart2js:noInline')
  static ProcessJoinRequestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessJoinRequestResponse>(create);
  static ProcessJoinRequestResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 更新后的请求详情
  @$pb.TagNumber(3)
  JoinRequestProto get request => $_getN(2);
  @$pb.TagNumber(3)
  set request(JoinRequestProto value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  JoinRequestProto ensureRequest() => $_ensure(2);
}

/// 获取加入请求列表
/// Socket.io事件: conversation:join:requests:get
class GetJoinRequestsMessage extends $pb.GeneratedMessage {
  factory GetJoinRequestsMessage({
    $core.String? conversationId,
    JoinRequestStatus? status,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (status != null) result.status = status;
    return result;
  }

  GetJoinRequestsMessage._();

  factory GetJoinRequestsMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetJoinRequestsMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetJoinRequestsMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..e<JoinRequestStatus>(
        2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE,
        defaultOrMaker: JoinRequestStatus.JOIN_PENDING,
        valueOf: JoinRequestStatus.valueOf,
        enumValues: JoinRequestStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJoinRequestsMessage clone() =>
      GetJoinRequestsMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJoinRequestsMessage copyWith(
          void Function(GetJoinRequestsMessage) updates) =>
      super.copyWith((message) => updates(message as GetJoinRequestsMessage))
          as GetJoinRequestsMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetJoinRequestsMessage create() => GetJoinRequestsMessage._();
  @$core.override
  GetJoinRequestsMessage createEmptyInstance() => create();
  static $pb.PbList<GetJoinRequestsMessage> createRepeated() =>
      $pb.PbList<GetJoinRequestsMessage>();
  @$core.pragma('dart2js:noInline')
  static GetJoinRequestsMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetJoinRequestsMessage>(create);
  static GetJoinRequestsMessage? _defaultInstance;

  /// 会话ID
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  /// 状态筛选（可选）
  @$pb.TagNumber(2)
  JoinRequestStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(JoinRequestStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

/// 获取加入请求列表响应
/// Socket.io事件: conversation:join:requests:get:response
class GetJoinRequestsResponse extends $pb.GeneratedMessage {
  factory GetJoinRequestsResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<JoinRequestProto>? requests,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (requests != null) result.requests.addAll(requests);
    return result;
  }

  GetJoinRequestsResponse._();

  factory GetJoinRequestsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetJoinRequestsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetJoinRequestsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pc<JoinRequestProto>(
        3, _omitFieldNames ? '' : 'requests', $pb.PbFieldType.PM,
        subBuilder: JoinRequestProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJoinRequestsResponse clone() =>
      GetJoinRequestsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJoinRequestsResponse copyWith(
          void Function(GetJoinRequestsResponse) updates) =>
      super.copyWith((message) => updates(message as GetJoinRequestsResponse))
          as GetJoinRequestsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetJoinRequestsResponse create() => GetJoinRequestsResponse._();
  @$core.override
  GetJoinRequestsResponse createEmptyInstance() => create();
  static $pb.PbList<GetJoinRequestsResponse> createRepeated() =>
      $pb.PbList<GetJoinRequestsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetJoinRequestsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetJoinRequestsResponse>(create);
  static GetJoinRequestsResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 请求列表
  @$pb.TagNumber(3)
  $pb.PbList<JoinRequestProto> get requests => $_getList(2);
}

/// 加入请求状态变更通知
/// Socket.io事件: conversation:join:request:updated
class JoinRequestUpdatedNotification extends $pb.GeneratedMessage {
  factory JoinRequestUpdatedNotification({
    JoinRequestProto? request,
    $core.String? notificationType,
  }) {
    final result = create();
    if (request != null) result.request = request;
    if (notificationType != null) result.notificationType = notificationType;
    return result;
  }

  JoinRequestUpdatedNotification._();

  factory JoinRequestUpdatedNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestUpdatedNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestUpdatedNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOM<JoinRequestProto>(1, _omitFieldNames ? '' : 'request',
        subBuilder: JoinRequestProto.create)
    ..aOS(2, _omitFieldNames ? '' : 'notificationType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestUpdatedNotification clone() =>
      JoinRequestUpdatedNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestUpdatedNotification copyWith(
          void Function(JoinRequestUpdatedNotification) updates) =>
      super.copyWith(
              (message) => updates(message as JoinRequestUpdatedNotification))
          as JoinRequestUpdatedNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestUpdatedNotification create() =>
      JoinRequestUpdatedNotification._();
  @$core.override
  JoinRequestUpdatedNotification createEmptyInstance() => create();
  static $pb.PbList<JoinRequestUpdatedNotification> createRepeated() =>
      $pb.PbList<JoinRequestUpdatedNotification>();
  @$core.pragma('dart2js:noInline')
  static JoinRequestUpdatedNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestUpdatedNotification>(create);
  static JoinRequestUpdatedNotification? _defaultInstance;

  /// 请求详情
  @$pb.TagNumber(1)
  JoinRequestProto get request => $_getN(0);
  @$pb.TagNumber(1)
  set request(JoinRequestProto value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRequest() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequest() => $_clearField(1);
  @$pb.TagNumber(1)
  JoinRequestProto ensureRequest() => $_ensure(0);

  /// 通知类型：new（新请求）、processed（已处理）、cancelled（已取消）
  @$pb.TagNumber(2)
  $core.String get notificationType => $_getSZ(1);
  @$pb.TagNumber(2)
  set notificationType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNotificationType() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotificationType() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
