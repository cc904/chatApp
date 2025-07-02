//
//  Generated code. Do not modify.
//  source: contacts.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'contacts.pbenum.dart';
import 'user.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'contacts.pbenum.dart';

/// 好友请求消息
/// 包含好友请求的详细信息
class FriendRequestProto extends $pb.GeneratedMessage {
  factory FriendRequestProto({
    $core.String? requestId,
    $core.String? senderId,
    $core.String? receiverId,
    FriendRequestStatus? status,
    $core.String? message,
    $fixnum.Int64? sentAt,
    $fixnum.Int64? processedAt,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (receiverId != null) {
      $result.receiverId = receiverId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (message != null) {
      $result.message = message;
    }
    if (sentAt != null) {
      $result.sentAt = sentAt;
    }
    if (processedAt != null) {
      $result.processedAt = processedAt;
    }
    return $result;
  }
  FriendRequestProto._() : super();
  factory FriendRequestProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FriendRequestProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendRequestProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'senderId')
    ..aOS(3, _omitFieldNames ? '' : 'receiverId')
    ..e<FriendRequestStatus>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FriendRequestStatus.PENDING, valueOf: FriendRequestStatus.valueOf, enumValues: FriendRequestStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..aInt64(6, _omitFieldNames ? '' : 'sentAt')
    ..aInt64(7, _omitFieldNames ? '' : 'processedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FriendRequestProto clone() => FriendRequestProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FriendRequestProto copyWith(void Function(FriendRequestProto) updates) => super.copyWith((message) => updates(message as FriendRequestProto)) as FriendRequestProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendRequestProto create() => FriendRequestProto._();
  FriendRequestProto createEmptyInstance() => create();
  static $pb.PbList<FriendRequestProto> createRepeated() => $pb.PbList<FriendRequestProto>();
  @$core.pragma('dart2js:noInline')
  static FriendRequestProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendRequestProto>(create);
  static FriendRequestProto? _defaultInstance;

  /// 请求ID
  /// 系统分配的唯一标识
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// 发送者ID
  /// 发起好友请求的用户
  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  /// 接收者ID
  /// 接收好友请求的用户
  @$pb.TagNumber(3)
  $core.String get receiverId => $_getSZ(2);
  @$pb.TagNumber(3)
  set receiverId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReceiverId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceiverId() => $_clearField(3);

  /// 请求状态
  @$pb.TagNumber(4)
  FriendRequestStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(FriendRequestStatus v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  /// 请求消息
  /// 好友请求的附加信息
  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);
  @$pb.TagNumber(5)
  set message($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessage() => $_clearField(5);

  /// 发送时间（毫秒时间戳）
  @$pb.TagNumber(6)
  $fixnum.Int64 get sentAt => $_getI64(5);
  @$pb.TagNumber(6)
  set sentAt($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSentAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearSentAt() => $_clearField(6);

  /// 处理时间（毫秒时间戳）
  @$pb.TagNumber(7)
  $fixnum.Int64 get processedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set processedAt($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasProcessedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearProcessedAt() => $_clearField(7);
}

/// 同步联系人请求消息
/// 客户端请求同步联系人列表时使用
/// 在服务端实现中，用户ID直接从 socket 中获取，不需要客户端提供
/// 采用全量同步策略，确保客户端和服务器数据一致性
/// Socket.io事件: contact:sync
class SyncContactsRequest extends $pb.GeneratedMessage {
  factory SyncContactsRequest() => create();
  SyncContactsRequest._() : super();
  factory SyncContactsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncContactsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncContactsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncContactsRequest clone() => SyncContactsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncContactsRequest copyWith(void Function(SyncContactsRequest) updates) => super.copyWith((message) => updates(message as SyncContactsRequest)) as SyncContactsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncContactsRequest create() => SyncContactsRequest._();
  SyncContactsRequest createEmptyInstance() => create();
  static $pb.PbList<SyncContactsRequest> createRepeated() => $pb.PbList<SyncContactsRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncContactsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncContactsRequest>(create);
  static SyncContactsRequest? _defaultInstance;
}

/// 同步联系人响应消息
/// 服务器返回同步结果
/// Socket.io事件: contact:sync:response
class SyncContactsResponse extends $pb.GeneratedMessage {
  factory SyncContactsResponse({
    $core.Iterable<$0.UserProto>? contacts,
    $fixnum.Int64? syncTime,
  }) {
    final $result = create();
    if (contacts != null) {
      $result.contacts.addAll(contacts);
    }
    if (syncTime != null) {
      $result.syncTime = syncTime;
    }
    return $result;
  }
  SyncContactsResponse._() : super();
  factory SyncContactsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncContactsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncContactsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<$0.UserProto>(1, _omitFieldNames ? '' : 'contacts', $pb.PbFieldType.PM, subBuilder: $0.UserProto.create)
    ..aInt64(2, _omitFieldNames ? '' : 'syncTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncContactsResponse clone() => SyncContactsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncContactsResponse copyWith(void Function(SyncContactsResponse) updates) => super.copyWith((message) => updates(message as SyncContactsResponse)) as SyncContactsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncContactsResponse create() => SyncContactsResponse._();
  SyncContactsResponse createEmptyInstance() => create();
  static $pb.PbList<SyncContactsResponse> createRepeated() => $pb.PbList<SyncContactsResponse>();
  @$core.pragma('dart2js:noInline')
  static SyncContactsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncContactsResponse>(create);
  static SyncContactsResponse? _defaultInstance;

  /// 联系人列表
  /// 包含所有好友的基本信息
  @$pb.TagNumber(1)
  $pb.PbList<$0.UserProto> get contacts => $_getList(0);

  /// 同步时间（毫秒时间戳）
  @$pb.TagNumber(2)
  $fixnum.Int64 get syncTime => $_getI64(1);
  @$pb.TagNumber(2)
  set syncTime($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSyncTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearSyncTime() => $_clearField(2);
}

/// 发送好友请求消息
/// 客户端发送好友请求时使用
class SendFriendRequestProto extends $pb.GeneratedMessage {
  factory SendFriendRequestProto({
    $core.String? senderId,
    $core.String? receiverId,
    $core.String? message,
  }) {
    final $result = create();
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (receiverId != null) {
      $result.receiverId = receiverId;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  SendFriendRequestProto._() : super();
  factory SendFriendRequestProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendFriendRequestProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendFriendRequestProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'senderId')
    ..aOS(2, _omitFieldNames ? '' : 'receiverId')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendFriendRequestProto clone() => SendFriendRequestProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendFriendRequestProto copyWith(void Function(SendFriendRequestProto) updates) => super.copyWith((message) => updates(message as SendFriendRequestProto)) as SendFriendRequestProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendFriendRequestProto create() => SendFriendRequestProto._();
  SendFriendRequestProto createEmptyInstance() => create();
  static $pb.PbList<SendFriendRequestProto> createRepeated() => $pb.PbList<SendFriendRequestProto>();
  @$core.pragma('dart2js:noInline')
  static SendFriendRequestProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendFriendRequestProto>(create);
  static SendFriendRequestProto? _defaultInstance;

  /// 发送者ID
  @$pb.TagNumber(1)
  $core.String get senderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set senderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSenderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderId() => $_clearField(1);

  /// 接收者ID
  @$pb.TagNumber(2)
  $core.String get receiverId => $_getSZ(1);
  @$pb.TagNumber(2)
  set receiverId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReceiverId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReceiverId() => $_clearField(2);

  /// 请求消息
  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

/// 处理好友请求消息
/// 客户端处理好友请求时使用
class ProcessFriendRequestProto extends $pb.GeneratedMessage {
  factory ProcessFriendRequestProto({
    $core.String? requestId,
    FriendRequestStatus? status,
    $core.String? rejectReason,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (rejectReason != null) {
      $result.rejectReason = rejectReason;
    }
    return $result;
  }
  ProcessFriendRequestProto._() : super();
  factory ProcessFriendRequestProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessFriendRequestProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProcessFriendRequestProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..e<FriendRequestStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FriendRequestStatus.PENDING, valueOf: FriendRequestStatus.valueOf, enumValues: FriendRequestStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'rejectReason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProcessFriendRequestProto clone() => ProcessFriendRequestProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProcessFriendRequestProto copyWith(void Function(ProcessFriendRequestProto) updates) => super.copyWith((message) => updates(message as ProcessFriendRequestProto)) as ProcessFriendRequestProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessFriendRequestProto create() => ProcessFriendRequestProto._();
  ProcessFriendRequestProto createEmptyInstance() => create();
  static $pb.PbList<ProcessFriendRequestProto> createRepeated() => $pb.PbList<ProcessFriendRequestProto>();
  @$core.pragma('dart2js:noInline')
  static ProcessFriendRequestProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessFriendRequestProto>(create);
  static ProcessFriendRequestProto? _defaultInstance;

  /// 请求ID
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// 请求状态
  @$pb.TagNumber(2)
  FriendRequestStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(FriendRequestStatus v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  /// 拒绝原因
  /// 当status为REJECTED时，说明拒绝原因
  @$pb.TagNumber(3)
  $core.String get rejectReason => $_getSZ(2);
  @$pb.TagNumber(3)
  set rejectReason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRejectReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearRejectReason() => $_clearField(3);
}

/// 获取好友列表请求消息
/// 客户端请求获取好友列表时使用
class GetFriendsRequest extends $pb.GeneratedMessage {
  factory GetFriendsRequest({
    $core.String? userId,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  GetFriendsRequest._() : super();
  factory GetFriendsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFriendsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFriendsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFriendsRequest clone() => GetFriendsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFriendsRequest copyWith(void Function(GetFriendsRequest) updates) => super.copyWith((message) => updates(message as GetFriendsRequest)) as GetFriendsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendsRequest create() => GetFriendsRequest._();
  GetFriendsRequest createEmptyInstance() => create();
  static $pb.PbList<GetFriendsRequest> createRepeated() => $pb.PbList<GetFriendsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFriendsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFriendsRequest>(create);
  static GetFriendsRequest? _defaultInstance;

  /// 用户ID
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

/// 获取好友列表响应消息
/// 服务器返回好友列表
class GetFriendsResponse extends $pb.GeneratedMessage {
  factory GetFriendsResponse({
    $core.Iterable<$0.UserProto>? friends,
  }) {
    final $result = create();
    if (friends != null) {
      $result.friends.addAll(friends);
    }
    return $result;
  }
  GetFriendsResponse._() : super();
  factory GetFriendsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFriendsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFriendsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<$0.UserProto>(1, _omitFieldNames ? '' : 'friends', $pb.PbFieldType.PM, subBuilder: $0.UserProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFriendsResponse clone() => GetFriendsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFriendsResponse copyWith(void Function(GetFriendsResponse) updates) => super.copyWith((message) => updates(message as GetFriendsResponse)) as GetFriendsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendsResponse create() => GetFriendsResponse._();
  GetFriendsResponse createEmptyInstance() => create();
  static $pb.PbList<GetFriendsResponse> createRepeated() => $pb.PbList<GetFriendsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFriendsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFriendsResponse>(create);
  static GetFriendsResponse? _defaultInstance;

  /// 好友列表
  @$pb.TagNumber(1)
  $pb.PbList<$0.UserProto> get friends => $_getList(0);
}

/// 获取好友请求列表请求消息
/// 客户端请求获取好友请求列表时使用
class GetFriendRequestsRequest extends $pb.GeneratedMessage {
  factory GetFriendRequestsRequest({
    $core.String? userId,
    FriendRequestStatus? status,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  GetFriendRequestsRequest._() : super();
  factory GetFriendRequestsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFriendRequestsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFriendRequestsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..e<FriendRequestStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FriendRequestStatus.PENDING, valueOf: FriendRequestStatus.valueOf, enumValues: FriendRequestStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFriendRequestsRequest clone() => GetFriendRequestsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFriendRequestsRequest copyWith(void Function(GetFriendRequestsRequest) updates) => super.copyWith((message) => updates(message as GetFriendRequestsRequest)) as GetFriendRequestsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendRequestsRequest create() => GetFriendRequestsRequest._();
  GetFriendRequestsRequest createEmptyInstance() => create();
  static $pb.PbList<GetFriendRequestsRequest> createRepeated() => $pb.PbList<GetFriendRequestsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFriendRequestsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFriendRequestsRequest>(create);
  static GetFriendRequestsRequest? _defaultInstance;

  /// 用户ID
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 请求状态
  /// 可选，不传则获取所有状态
  @$pb.TagNumber(2)
  FriendRequestStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(FriendRequestStatus v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

/// 获取好友请求列表响应消息
/// 服务器返回好友请求列表
class GetFriendRequestsResponse extends $pb.GeneratedMessage {
  factory GetFriendRequestsResponse({
    $core.Iterable<FriendRequestProto>? requests,
  }) {
    final $result = create();
    if (requests != null) {
      $result.requests.addAll(requests);
    }
    return $result;
  }
  GetFriendRequestsResponse._() : super();
  factory GetFriendRequestsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFriendRequestsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFriendRequestsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<FriendRequestProto>(1, _omitFieldNames ? '' : 'requests', $pb.PbFieldType.PM, subBuilder: FriendRequestProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFriendRequestsResponse clone() => GetFriendRequestsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFriendRequestsResponse copyWith(void Function(GetFriendRequestsResponse) updates) => super.copyWith((message) => updates(message as GetFriendRequestsResponse)) as GetFriendRequestsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendRequestsResponse create() => GetFriendRequestsResponse._();
  GetFriendRequestsResponse createEmptyInstance() => create();
  static $pb.PbList<GetFriendRequestsResponse> createRepeated() => $pb.PbList<GetFriendRequestsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFriendRequestsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFriendRequestsResponse>(create);
  static GetFriendRequestsResponse? _defaultInstance;

  /// 好友请求列表
  @$pb.TagNumber(1)
  $pb.PbList<FriendRequestProto> get requests => $_getList(0);
}

/// 删除好友请求消息
/// 客户端请求删除好友时使用
class DeleteFriendRequest extends $pb.GeneratedMessage {
  factory DeleteFriendRequest({
    $core.String? friendId,
  }) {
    final $result = create();
    if (friendId != null) {
      $result.friendId = friendId;
    }
    return $result;
  }
  DeleteFriendRequest._() : super();
  factory DeleteFriendRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteFriendRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFriendRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'friendId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteFriendRequest clone() => DeleteFriendRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteFriendRequest copyWith(void Function(DeleteFriendRequest) updates) => super.copyWith((message) => updates(message as DeleteFriendRequest)) as DeleteFriendRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFriendRequest create() => DeleteFriendRequest._();
  DeleteFriendRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteFriendRequest> createRepeated() => $pb.PbList<DeleteFriendRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteFriendRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFriendRequest>(create);
  static DeleteFriendRequest? _defaultInstance;

  /// 好友ID
  @$pb.TagNumber(1)
  $core.String get friendId => $_getSZ(0);
  @$pb.TagNumber(1)
  set friendId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => $_clearField(1);
}

/// 删除好友响应消息
/// 服务器返回删除结果
class DeleteFriendResponse extends $pb.GeneratedMessage {
  factory DeleteFriendResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    return $result;
  }
  DeleteFriendResponse._() : super();
  factory DeleteFriendResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteFriendResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFriendResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteFriendResponse clone() => DeleteFriendResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteFriendResponse copyWith(void Function(DeleteFriendResponse) updates) => super.copyWith((message) => updates(message as DeleteFriendResponse)) as DeleteFriendResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFriendResponse create() => DeleteFriendResponse._();
  DeleteFriendResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteFriendResponse> createRepeated() => $pb.PbList<DeleteFriendResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteFriendResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFriendResponse>(create);
  static DeleteFriendResponse? _defaultInstance;

  /// 删除是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 错误信息
  /// 当success为false时，说明具体的错误原因
  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

/// 更新联系人信息请求消息
/// 客户端更新联系人信息时使用
/// Socket.io事件: contact:update
class UpdateContactRequest extends $pb.GeneratedMessage {
  factory UpdateContactRequest({
    $core.String? contactId,
    $core.String? nickname,
    $core.String? remark,
    $core.bool? blocked,
    $core.bool? isFavorite,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (nickname != null) {
      $result.nickname = nickname;
    }
    if (remark != null) {
      $result.remark = remark;
    }
    if (blocked != null) {
      $result.blocked = blocked;
    }
    if (isFavorite != null) {
      $result.isFavorite = isFavorite;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  UpdateContactRequest._() : super();
  factory UpdateContactRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateContactRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateContactRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contactId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'remark')
    ..aOB(4, _omitFieldNames ? '' : 'blocked')
    ..aOB(5, _omitFieldNames ? '' : 'isFavorite')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateContactRequest clone() => UpdateContactRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateContactRequest copyWith(void Function(UpdateContactRequest) updates) => super.copyWith((message) => updates(message as UpdateContactRequest)) as UpdateContactRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateContactRequest create() => UpdateContactRequest._();
  UpdateContactRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateContactRequest> createRepeated() => $pb.PbList<UpdateContactRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateContactRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateContactRequest>(create);
  static UpdateContactRequest? _defaultInstance;

  /// 联系人ID
  @$pb.TagNumber(1)
  $core.String get contactId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contactId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactId() => $_clearField(1);

  /// 自定义昵称（可选）
  /// 如果不提供则不更新此字段
  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  /// 备注信息（可选）
  /// 如果不提供则不更新此字段
  @$pb.TagNumber(3)
  $core.String get remark => $_getSZ(2);
  @$pb.TagNumber(3)
  set remark($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRemark() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemark() => $_clearField(3);

  /// 是否拉黑（可选）
  /// 如果不提供则不更新此字段
  @$pb.TagNumber(4)
  $core.bool get blocked => $_getBF(3);
  @$pb.TagNumber(4)
  set blocked($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlocked() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlocked() => $_clearField(4);

  /// 是否收藏（可选）
  /// 如果不提供则不更新此字段
  @$pb.TagNumber(5)
  $core.bool get isFavorite => $_getBF(4);
  @$pb.TagNumber(5)
  set isFavorite($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsFavorite() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsFavorite() => $_clearField(5);

  /// 更新时间戳
  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);
}

/// 更新联系人信息响应消息
/// 服务器返回更新结果
/// Socket.io事件: contact:update:response
class UpdateContactResponse extends $pb.GeneratedMessage {
  factory UpdateContactResponse({
    $core.bool? success,
    $core.String? message,
    $0.UserProto? contact,
    $core.Iterable<$core.String>? updatedFields,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (contact != null) {
      $result.contact = contact;
    }
    if (updatedFields != null) {
      $result.updatedFields.addAll(updatedFields);
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  UpdateContactResponse._() : super();
  factory UpdateContactResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateContactResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateContactResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<$0.UserProto>(3, _omitFieldNames ? '' : 'contact', subBuilder: $0.UserProto.create)
    ..pPS(4, _omitFieldNames ? '' : 'updatedFields')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateContactResponse clone() => UpdateContactResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateContactResponse copyWith(void Function(UpdateContactResponse) updates) => super.copyWith((message) => updates(message as UpdateContactResponse)) as UpdateContactResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateContactResponse create() => UpdateContactResponse._();
  UpdateContactResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateContactResponse> createRepeated() => $pb.PbList<UpdateContactResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateContactResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateContactResponse>(create);
  static UpdateContactResponse? _defaultInstance;

  /// 操作是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 响应消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 更新后的联系人信息
  @$pb.TagNumber(3)
  $0.UserProto get contact => $_getN(2);
  @$pb.TagNumber(3)
  set contact($0.UserProto v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasContact() => $_has(2);
  @$pb.TagNumber(3)
  void clearContact() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.UserProto ensureContact() => $_ensure(2);

  /// 更新的字段列表
  /// 用于标识哪些字段发生了变化
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get updatedFields => $_getList(3);

  /// 操作时间戳
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 联系人信息更新事件
/// 当联系人信息发生变化时通知客户端
/// Socket.io事件: contact:updated
class ContactUpdateEvent extends $pb.GeneratedMessage {
  factory ContactUpdateEvent({
    $0.UserProto? contact,
    $core.Iterable<$core.String>? updatedFields,
    $fixnum.Int64? timestamp,
    $core.String? updateSource,
  }) {
    final $result = create();
    if (contact != null) {
      $result.contact = contact;
    }
    if (updatedFields != null) {
      $result.updatedFields.addAll(updatedFields);
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (updateSource != null) {
      $result.updateSource = updateSource;
    }
    return $result;
  }
  ContactUpdateEvent._() : super();
  factory ContactUpdateEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactUpdateEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactUpdateEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOM<$0.UserProto>(1, _omitFieldNames ? '' : 'contact', subBuilder: $0.UserProto.create)
    ..pPS(2, _omitFieldNames ? '' : 'updatedFields')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..aOS(4, _omitFieldNames ? '' : 'updateSource')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactUpdateEvent clone() => ContactUpdateEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactUpdateEvent copyWith(void Function(ContactUpdateEvent) updates) => super.copyWith((message) => updates(message as ContactUpdateEvent)) as ContactUpdateEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactUpdateEvent create() => ContactUpdateEvent._();
  ContactUpdateEvent createEmptyInstance() => create();
  static $pb.PbList<ContactUpdateEvent> createRepeated() => $pb.PbList<ContactUpdateEvent>();
  @$core.pragma('dart2js:noInline')
  static ContactUpdateEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactUpdateEvent>(create);
  static ContactUpdateEvent? _defaultInstance;

  /// 更新的联系人信息
  @$pb.TagNumber(1)
  $0.UserProto get contact => $_getN(0);
  @$pb.TagNumber(1)
  set contact($0.UserProto v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContact() => $_has(0);
  @$pb.TagNumber(1)
  void clearContact() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.UserProto ensureContact() => $_ensure(0);

  /// 更新的字段列表
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get updatedFields => $_getList(1);

  /// 更新时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  /// 更新来源
  /// 如：user_action, system_sync等
  @$pb.TagNumber(4)
  $core.String get updateSource => $_getSZ(3);
  @$pb.TagNumber(4)
  set updateSource($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUpdateSource() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdateSource() => $_clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
