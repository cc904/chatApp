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

/// 好友请求
class FriendRequestProto extends $pb.GeneratedMessage {
  factory FriendRequestProto({
    $core.String? requestId,
    $core.String? senderId,
    $core.String? senderName,
    $core.String? senderAvatar,
    $core.String? receiverId,
    $core.String? message,
    FriendRequestStatus? status,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? processedAt,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
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
    if (receiverId != null) {
      $result.receiverId = receiverId;
    }
    if (message != null) {
      $result.message = message;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
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
    ..aOS(3, _omitFieldNames ? '' : 'senderName')
    ..aOS(4, _omitFieldNames ? '' : 'senderAvatar')
    ..aOS(5, _omitFieldNames ? '' : 'receiverId')
    ..aOS(6, _omitFieldNames ? '' : 'message')
    ..e<FriendRequestStatus>(7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FriendRequestStatus.pending, valueOf: FriendRequestStatus.valueOf, enumValues: FriendRequestStatus.values)
    ..aInt64(8, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(9, _omitFieldNames ? '' : 'processedAt')
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

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get senderName => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSenderName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderAvatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderAvatar($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSenderAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get receiverId => $_getSZ(4);
  @$pb.TagNumber(5)
  set receiverId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReceiverId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceiverId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get message => $_getSZ(5);
  @$pb.TagNumber(6)
  set message($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);

  @$pb.TagNumber(7)
  FriendRequestStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(FriendRequestStatus v) { $_setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAt => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAt($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get processedAt => $_getI64(8);
  @$pb.TagNumber(9)
  set processedAt($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasProcessedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearProcessedAt() => $_clearField(9);
}

/// 好友请求列表
class FriendRequestCollection extends $pb.GeneratedMessage {
  factory FriendRequestCollection({
    $core.Iterable<FriendRequestProto>? requests,
  }) {
    final $result = create();
    if (requests != null) {
      $result.requests.addAll(requests);
    }
    return $result;
  }
  FriendRequestCollection._() : super();
  factory FriendRequestCollection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FriendRequestCollection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendRequestCollection', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<FriendRequestProto>(1, _omitFieldNames ? '' : 'requests', $pb.PbFieldType.PM, subBuilder: FriendRequestProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FriendRequestCollection clone() => FriendRequestCollection()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FriendRequestCollection copyWith(void Function(FriendRequestCollection) updates) => super.copyWith((message) => updates(message as FriendRequestCollection)) as FriendRequestCollection;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendRequestCollection create() => FriendRequestCollection._();
  FriendRequestCollection createEmptyInstance() => create();
  static $pb.PbList<FriendRequestCollection> createRepeated() => $pb.PbList<FriendRequestCollection>();
  @$core.pragma('dart2js:noInline')
  static FriendRequestCollection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendRequestCollection>(create);
  static FriendRequestCollection? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FriendRequestProto> get requests => $_getList(0);
}

/// 同步联系人请求
class SyncContactsRequest extends $pb.GeneratedMessage {
  factory SyncContactsRequest({
    $core.String? userId,
    $core.String? token,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  SyncContactsRequest._() : super();
  factory SyncContactsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncContactsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncContactsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'token')
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

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);
}

/// 同步联系人响应
class SyncContactsResponse extends $pb.GeneratedMessage {
  factory SyncContactsResponse({
    $core.Iterable<$0.UserProto>? contacts,
  }) {
    final $result = create();
    if (contacts != null) {
      $result.contacts.addAll(contacts);
    }
    return $result;
  }
  SyncContactsResponse._() : super();
  factory SyncContactsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncContactsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncContactsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<$0.UserProto>(1, _omitFieldNames ? '' : 'contacts', $pb.PbFieldType.PM, subBuilder: $0.UserProto.create)
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

  @$pb.TagNumber(1)
  $pb.PbList<$0.UserProto> get contacts => $_getList(0);
}

/// 发送好友请求
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

  @$pb.TagNumber(1)
  $core.String get senderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set senderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSenderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get receiverId => $_getSZ(1);
  @$pb.TagNumber(2)
  set receiverId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReceiverId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReceiverId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

/// 处理好友请求
class ProcessFriendRequestProto extends $pb.GeneratedMessage {
  factory ProcessFriendRequestProto({
    $core.String? requestId,
    FriendRequestStatus? status,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  ProcessFriendRequestProto._() : super();
  factory ProcessFriendRequestProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessFriendRequestProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProcessFriendRequestProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..e<FriendRequestStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FriendRequestStatus.pending, valueOf: FriendRequestStatus.valueOf, enumValues: FriendRequestStatus.values)
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

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  FriendRequestStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(FriendRequestStatus v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
