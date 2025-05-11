//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'user.pbenum.dart';

/// 用户信息
class UserProto extends $pb.GeneratedMessage {
  factory UserProto({
    $core.String? userId,
    $core.String? name,
    $core.String? avatar,
    $core.String? phone,
    $core.String? email,
    $core.String? pinyin,
    $fixnum.Int64? lastActiveTime,
    $core.String? status,
    $core.String? username,
    $core.String? displayName,
    $core.bool? isTyping,
    $core.String? typingInConversation,
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
    if (phone != null) {
      $result.phone = phone;
    }
    if (email != null) {
      $result.email = email;
    }
    if (pinyin != null) {
      $result.pinyin = pinyin;
    }
    if (lastActiveTime != null) {
      $result.lastActiveTime = lastActiveTime;
    }
    if (status != null) {
      $result.status = status;
    }
    if (username != null) {
      $result.username = username;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (isTyping != null) {
      $result.isTyping = isTyping;
    }
    if (typingInConversation != null) {
      $result.typingInConversation = typingInConversation;
    }
    return $result;
  }
  UserProto._() : super();
  factory UserProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aOS(5, _omitFieldNames ? '' : 'email')
    ..aOS(6, _omitFieldNames ? '' : 'pinyin')
    ..aInt64(7, _omitFieldNames ? '' : 'lastActiveTime')
    ..aOS(8, _omitFieldNames ? '' : 'status')
    ..aOS(10, _omitFieldNames ? '' : 'username')
    ..aOS(11, _omitFieldNames ? '' : 'displayName')
    ..aOB(12, _omitFieldNames ? '' : 'isTyping')
    ..aOS(13, _omitFieldNames ? '' : 'typingInConversation')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserProto clone() => UserProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserProto copyWith(void Function(UserProto) updates) => super.copyWith((message) => updates(message as UserProto)) as UserProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserProto create() => UserProto._();
  UserProto createEmptyInstance() => create();
  static $pb.PbList<UserProto> createRepeated() => $pb.PbList<UserProto>();
  @$core.pragma('dart2js:noInline')
  static UserProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserProto>(create);
  static UserProto? _defaultInstance;

  /// 主要字段，完全匹配数据库模型
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
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get email => $_getSZ(4);
  @$pb.TagNumber(5)
  set email($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmail() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get pinyin => $_getSZ(5);
  @$pb.TagNumber(6)
  set pinyin($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPinyin() => $_has(5);
  @$pb.TagNumber(6)
  void clearPinyin() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get lastActiveTime => $_getI64(6);
  @$pb.TagNumber(7)
  set lastActiveTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLastActiveTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastActiveTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get status => $_getSZ(7);
  @$pb.TagNumber(8)
  set status($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  /// 扩展字段，用于通信但数据库中没有
  @$pb.TagNumber(10)
  $core.String get username => $_getSZ(8);
  @$pb.TagNumber(10)
  set username($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasUsername() => $_has(8);
  @$pb.TagNumber(10)
  void clearUsername() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get displayName => $_getSZ(9);
  @$pb.TagNumber(11)
  set displayName($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(11)
  $core.bool hasDisplayName() => $_has(9);
  @$pb.TagNumber(11)
  void clearDisplayName() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get isTyping => $_getBF(10);
  @$pb.TagNumber(12)
  set isTyping($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(12)
  $core.bool hasIsTyping() => $_has(10);
  @$pb.TagNumber(12)
  void clearIsTyping() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get typingInConversation => $_getSZ(11);
  @$pb.TagNumber(13)
  set typingInConversation($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(13)
  $core.bool hasTypingInConversation() => $_has(11);
  @$pb.TagNumber(13)
  void clearTypingInConversation() => $_clearField(13);
}

/// 当前登录用户信息
class MyUserProto extends $pb.GeneratedMessage {
  factory MyUserProto({
    $core.String? userId,
    $core.String? token,
    $core.String? name,
    $core.String? avatar,
    $core.String? phone,
    $core.String? email,
    $fixnum.Int64? tokenExpireTime,
    $fixnum.Int64? lastLoginTime,
    $core.String? status,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (token != null) {
      $result.token = token;
    }
    if (name != null) {
      $result.name = name;
    }
    if (avatar != null) {
      $result.avatar = avatar;
    }
    if (phone != null) {
      $result.phone = phone;
    }
    if (email != null) {
      $result.email = email;
    }
    if (tokenExpireTime != null) {
      $result.tokenExpireTime = tokenExpireTime;
    }
    if (lastLoginTime != null) {
      $result.lastLoginTime = lastLoginTime;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  MyUserProto._() : super();
  factory MyUserProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyUserProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUserProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..aOS(5, _omitFieldNames ? '' : 'phone')
    ..aOS(6, _omitFieldNames ? '' : 'email')
    ..aInt64(7, _omitFieldNames ? '' : 'tokenExpireTime')
    ..aInt64(8, _omitFieldNames ? '' : 'lastLoginTime')
    ..aOS(9, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyUserProto clone() => MyUserProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyUserProto copyWith(void Function(MyUserProto) updates) => super.copyWith((message) => updates(message as MyUserProto)) as MyUserProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyUserProto create() => MyUserProto._();
  MyUserProto createEmptyInstance() => create();
  static $pb.PbList<MyUserProto> createRepeated() => $pb.PbList<MyUserProto>();
  @$core.pragma('dart2js:noInline')
  static MyUserProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyUserProto>(create);
  static MyUserProto? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get phone => $_getSZ(4);
  @$pb.TagNumber(5)
  set phone($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPhone() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhone() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get email => $_getSZ(5);
  @$pb.TagNumber(6)
  set email($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasEmail() => $_has(5);
  @$pb.TagNumber(6)
  void clearEmail() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get tokenExpireTime => $_getI64(6);
  @$pb.TagNumber(7)
  set tokenExpireTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTokenExpireTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearTokenExpireTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get lastLoginTime => $_getI64(7);
  @$pb.TagNumber(8)
  set lastLoginTime($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLastLoginTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastLoginTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get status => $_getSZ(8);
  @$pb.TagNumber(9)
  set status($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);
}

/// 用户在线状态更新
class UserStatusUpdate extends $pb.GeneratedMessage {
  factory UserStatusUpdate({
    $core.String? userId,
    $core.String? status,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  UserStatusUpdate._() : super();
  factory UserStatusUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserStatusUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserStatusUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserStatusUpdate clone() => UserStatusUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserStatusUpdate copyWith(void Function(UserStatusUpdate) updates) => super.copyWith((message) => updates(message as UserStatusUpdate)) as UserStatusUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserStatusUpdate create() => UserStatusUpdate._();
  UserStatusUpdate createEmptyInstance() => create();
  static $pb.PbList<UserStatusUpdate> createRepeated() => $pb.PbList<UserStatusUpdate>();
  @$core.pragma('dart2js:noInline')
  static UserStatusUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserStatusUpdate>(create);
  static UserStatusUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

/// 用户打字状态更新
class UserTypingUpdate extends $pb.GeneratedMessage {
  factory UserTypingUpdate({
    $core.String? userId,
    $core.String? conversationId,
    $core.bool? isTyping,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
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
  UserTypingUpdate._() : super();
  factory UserTypingUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserTypingUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserTypingUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserTypingUpdate clone() => UserTypingUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserTypingUpdate copyWith(void Function(UserTypingUpdate) updates) => super.copyWith((message) => updates(message as UserTypingUpdate)) as UserTypingUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserTypingUpdate create() => UserTypingUpdate._();
  UserTypingUpdate createEmptyInstance() => create();
  static $pb.PbList<UserTypingUpdate> createRepeated() => $pb.PbList<UserTypingUpdate>();
  @$core.pragma('dart2js:noInline')
  static UserTypingUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserTypingUpdate>(create);
  static UserTypingUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(2);
  @$pb.TagNumber(3)
  set isTyping($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTyping() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// 用户请求响应
class UserResponse extends $pb.GeneratedMessage {
  factory UserResponse({
    $core.bool? success,
    $core.String? message,
    UserProto? user,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (user != null) {
      $result.user = user;
    }
    return $result;
  }
  UserResponse._() : super();
  factory UserResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<UserProto>(3, _omitFieldNames ? '' : 'user', subBuilder: UserProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserResponse clone() => UserResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserResponse copyWith(void Function(UserResponse) updates) => super.copyWith((message) => updates(message as UserResponse)) as UserResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserResponse create() => UserResponse._();
  UserResponse createEmptyInstance() => create();
  static $pb.PbList<UserResponse> createRepeated() => $pb.PbList<UserResponse>();
  @$core.pragma('dart2js:noInline')
  static UserResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserResponse>(create);
  static UserResponse? _defaultInstance;

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
  UserProto get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(UserProto v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  UserProto ensureUser() => $_ensure(2);
}

/// 用户列表
class UserCollection extends $pb.GeneratedMessage {
  factory UserCollection({
    $core.Iterable<UserProto>? users,
  }) {
    final $result = create();
    if (users != null) {
      $result.users.addAll(users);
    }
    return $result;
  }
  UserCollection._() : super();
  factory UserCollection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserCollection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserCollection', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..pc<UserProto>(1, _omitFieldNames ? '' : 'users', $pb.PbFieldType.PM, subBuilder: UserProto.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserCollection clone() => UserCollection()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserCollection copyWith(void Function(UserCollection) updates) => super.copyWith((message) => updates(message as UserCollection)) as UserCollection;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserCollection create() => UserCollection._();
  UserCollection createEmptyInstance() => create();
  static $pb.PbList<UserCollection> createRepeated() => $pb.PbList<UserCollection>();
  @$core.pragma('dart2js:noInline')
  static UserCollection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserCollection>(create);
  static UserCollection? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UserProto> get users => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
