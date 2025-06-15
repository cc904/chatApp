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

/// 用户基本信息消息
/// 包含用户的基本个人信息
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

  /// 用户ID
  /// 系统分配的唯一标识
  /// userId
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// name
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// avatar
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// phone
  @$pb.TagNumber(4)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  /// email
  @$pb.TagNumber(5)
  $core.String get email => $_getSZ(4);
  @$pb.TagNumber(5)
  set email($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmail() => $_clearField(5);

  /// pinyin
  @$pb.TagNumber(6)
  $core.String get pinyin => $_getSZ(5);
  @$pb.TagNumber(6)
  set pinyin($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPinyin() => $_has(5);
  @$pb.TagNumber(6)
  void clearPinyin() => $_clearField(6);

  /// lastActiveTime
  @$pb.TagNumber(7)
  $fixnum.Int64 get lastActiveTime => $_getI64(6);
  @$pb.TagNumber(7)
  set lastActiveTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLastActiveTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastActiveTime() => $_clearField(7);

  /// status, 已将字段号8保留给status
  @$pb.TagNumber(8)
  $core.String get status => $_getSZ(7);
  @$pb.TagNumber(8)
  set status($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  /// 扩展字段，用于通信但数据库中没有
  /// 用户名，可能和name相同
  @$pb.TagNumber(10)
  $core.String get username => $_getSZ(8);
  @$pb.TagNumber(10)
  set username($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasUsername() => $_has(8);
  @$pb.TagNumber(10)
  void clearUsername() => $_clearField(10);

  /// 显示名称，可能和name相同
  @$pb.TagNumber(11)
  $core.String get displayName => $_getSZ(9);
  @$pb.TagNumber(11)
  set displayName($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(11)
  $core.bool hasDisplayName() => $_has(9);
  @$pb.TagNumber(11)
  void clearDisplayName() => $_clearField(11);

  /// 是否正在输入
  @$pb.TagNumber(12)
  $core.bool get isTyping => $_getBF(10);
  @$pb.TagNumber(12)
  set isTyping($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(12)
  $core.bool hasIsTyping() => $_has(10);
  @$pb.TagNumber(12)
  void clearIsTyping() => $_clearField(12);

  /// 在哪个会话中输入
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
class CurrentUserProto extends $pb.GeneratedMessage {
  factory CurrentUserProto({
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
  CurrentUserProto._() : super();
  factory CurrentUserProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CurrentUserProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CurrentUserProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
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
  CurrentUserProto clone() => CurrentUserProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CurrentUserProto copyWith(void Function(CurrentUserProto) updates) => super.copyWith((message) => updates(message as CurrentUserProto)) as CurrentUserProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CurrentUserProto create() => CurrentUserProto._();
  CurrentUserProto createEmptyInstance() => create();
  static $pb.PbList<CurrentUserProto> createRepeated() => $pb.PbList<CurrentUserProto>();
  @$core.pragma('dart2js:noInline')
  static CurrentUserProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CurrentUserProto>(create);
  static CurrentUserProto? _defaultInstance;

  /// 用户ID
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 认证令牌
  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  /// 用户名称
  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  /// 头像URL
  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  /// 手机号
  @$pb.TagNumber(5)
  $core.String get phone => $_getSZ(4);
  @$pb.TagNumber(5)
  set phone($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPhone() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhone() => $_clearField(5);

  /// 电子邮箱
  @$pb.TagNumber(6)
  $core.String get email => $_getSZ(5);
  @$pb.TagNumber(6)
  set email($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasEmail() => $_has(5);
  @$pb.TagNumber(6)
  void clearEmail() => $_clearField(6);

  /// 令牌过期时间
  @$pb.TagNumber(7)
  $fixnum.Int64 get tokenExpireTime => $_getI64(6);
  @$pb.TagNumber(7)
  set tokenExpireTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTokenExpireTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearTokenExpireTime() => $_clearField(7);

  /// 最后登录时间
  @$pb.TagNumber(8)
  $fixnum.Int64 get lastLoginTime => $_getI64(7);
  @$pb.TagNumber(8)
  set lastLoginTime($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLastLoginTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastLoginTime() => $_clearField(8);

  /// 状态
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

  /// 使用字符串保持一致性
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

/// 用户状态消息
/// 用于表示用户的在线状态和最后活跃时间
class UserStatusMessage extends $pb.GeneratedMessage {
  factory UserStatusMessage({
    $core.bool? isOnline,
    $fixnum.Int64? lastActiveAt,
    $core.String? deviceType,
  }) {
    final $result = create();
    if (isOnline != null) {
      $result.isOnline = isOnline;
    }
    if (lastActiveAt != null) {
      $result.lastActiveAt = lastActiveAt;
    }
    if (deviceType != null) {
      $result.deviceType = deviceType;
    }
    return $result;
  }
  UserStatusMessage._() : super();
  factory UserStatusMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserStatusMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserStatusMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isOnline')
    ..aInt64(2, _omitFieldNames ? '' : 'lastActiveAt')
    ..aOS(3, _omitFieldNames ? '' : 'deviceType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserStatusMessage clone() => UserStatusMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserStatusMessage copyWith(void Function(UserStatusMessage) updates) => super.copyWith((message) => updates(message as UserStatusMessage)) as UserStatusMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserStatusMessage create() => UserStatusMessage._();
  UserStatusMessage createEmptyInstance() => create();
  static $pb.PbList<UserStatusMessage> createRepeated() => $pb.PbList<UserStatusMessage>();
  @$core.pragma('dart2js:noInline')
  static UserStatusMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserStatusMessage>(create);
  static UserStatusMessage? _defaultInstance;

  /// 是否在线
  @$pb.TagNumber(1)
  $core.bool get isOnline => $_getBF(0);
  @$pb.TagNumber(1)
  set isOnline($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsOnline() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsOnline() => $_clearField(1);

  /// 最后活跃时间（毫秒时间戳）
  @$pb.TagNumber(2)
  $fixnum.Int64 get lastActiveAt => $_getI64(1);
  @$pb.TagNumber(2)
  set lastActiveAt($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastActiveAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastActiveAt() => $_clearField(2);

  /// 设备类型
  /// 如：ios, android, web等
  @$pb.TagNumber(3)
  $core.String get deviceType => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);
}

/// 用户设置消息
/// 包含用户的个性化设置
class UserSettings extends $pb.GeneratedMessage {
  factory UserSettings({
    $core.String? userId,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    ThemeSettings? theme,
    $core.String? language,
    $core.String? timezone,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (notifications != null) {
      $result.notifications = notifications;
    }
    if (privacy != null) {
      $result.privacy = privacy;
    }
    if (theme != null) {
      $result.theme = theme;
    }
    if (language != null) {
      $result.language = language;
    }
    if (timezone != null) {
      $result.timezone = timezone;
    }
    return $result;
  }
  UserSettings._() : super();
  factory UserSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<NotificationSettings>(2, _omitFieldNames ? '' : 'notifications', subBuilder: NotificationSettings.create)
    ..aOM<PrivacySettings>(3, _omitFieldNames ? '' : 'privacy', subBuilder: PrivacySettings.create)
    ..aOM<ThemeSettings>(4, _omitFieldNames ? '' : 'theme', subBuilder: ThemeSettings.create)
    ..aOS(5, _omitFieldNames ? '' : 'language')
    ..aOS(6, _omitFieldNames ? '' : 'timezone')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserSettings clone() => UserSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserSettings copyWith(void Function(UserSettings) updates) => super.copyWith((message) => updates(message as UserSettings)) as UserSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSettings create() => UserSettings._();
  UserSettings createEmptyInstance() => create();
  static $pb.PbList<UserSettings> createRepeated() => $pb.PbList<UserSettings>();
  @$core.pragma('dart2js:noInline')
  static UserSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserSettings>(create);
  static UserSettings? _defaultInstance;

  /// 用户ID
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 消息通知设置
  /// 控制是否接收各类消息通知
  @$pb.TagNumber(2)
  NotificationSettings get notifications => $_getN(1);
  @$pb.TagNumber(2)
  set notifications(NotificationSettings v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasNotifications() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotifications() => $_clearField(2);
  @$pb.TagNumber(2)
  NotificationSettings ensureNotifications() => $_ensure(1);

  /// 隐私设置
  /// 控制个人信息的可见性
  @$pb.TagNumber(3)
  PrivacySettings get privacy => $_getN(2);
  @$pb.TagNumber(3)
  set privacy(PrivacySettings v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrivacy() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrivacy() => $_clearField(3);
  @$pb.TagNumber(3)
  PrivacySettings ensurePrivacy() => $_ensure(2);

  /// 主题设置
  /// 控制应用的显示主题
  @$pb.TagNumber(4)
  ThemeSettings get theme => $_getN(3);
  @$pb.TagNumber(4)
  set theme(ThemeSettings v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTheme() => $_has(3);
  @$pb.TagNumber(4)
  void clearTheme() => $_clearField(4);
  @$pb.TagNumber(4)
  ThemeSettings ensureTheme() => $_ensure(3);

  /// 语言设置
  /// 控制应用的显示语言
  @$pb.TagNumber(5)
  $core.String get language => $_getSZ(4);
  @$pb.TagNumber(5)
  set language($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLanguage() => $_has(4);
  @$pb.TagNumber(5)
  void clearLanguage() => $_clearField(5);

  /// 时区设置
  /// 控制时间显示和消息时间戳
  @$pb.TagNumber(6)
  $core.String get timezone => $_getSZ(5);
  @$pb.TagNumber(6)
  set timezone($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTimezone() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimezone() => $_clearField(6);
}

/// 通知设置消息
/// 控制各类消息的通知方式
class NotificationSettings extends $pb.GeneratedMessage {
  factory NotificationSettings({
    $core.bool? messageNotifications,
    $core.bool? friendRequestNotifications,
    $core.bool? groupNotifications,
    $core.bool? doNotDisturb,
    $core.String? doNotDisturbStart,
    $core.String? doNotDisturbEnd,
  }) {
    final $result = create();
    if (messageNotifications != null) {
      $result.messageNotifications = messageNotifications;
    }
    if (friendRequestNotifications != null) {
      $result.friendRequestNotifications = friendRequestNotifications;
    }
    if (groupNotifications != null) {
      $result.groupNotifications = groupNotifications;
    }
    if (doNotDisturb != null) {
      $result.doNotDisturb = doNotDisturb;
    }
    if (doNotDisturbStart != null) {
      $result.doNotDisturbStart = doNotDisturbStart;
    }
    if (doNotDisturbEnd != null) {
      $result.doNotDisturbEnd = doNotDisturbEnd;
    }
    return $result;
  }
  NotificationSettings._() : super();
  factory NotificationSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NotificationSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NotificationSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'messageNotifications')
    ..aOB(2, _omitFieldNames ? '' : 'friendRequestNotifications')
    ..aOB(3, _omitFieldNames ? '' : 'groupNotifications')
    ..aOB(4, _omitFieldNames ? '' : 'doNotDisturb')
    ..aOS(5, _omitFieldNames ? '' : 'doNotDisturbStart')
    ..aOS(6, _omitFieldNames ? '' : 'doNotDisturbEnd')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NotificationSettings clone() => NotificationSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NotificationSettings copyWith(void Function(NotificationSettings) updates) => super.copyWith((message) => updates(message as NotificationSettings)) as NotificationSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationSettings create() => NotificationSettings._();
  NotificationSettings createEmptyInstance() => create();
  static $pb.PbList<NotificationSettings> createRepeated() => $pb.PbList<NotificationSettings>();
  @$core.pragma('dart2js:noInline')
  static NotificationSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NotificationSettings>(create);
  static NotificationSettings? _defaultInstance;

  /// 是否接收新消息通知
  @$pb.TagNumber(1)
  $core.bool get messageNotifications => $_getBF(0);
  @$pb.TagNumber(1)
  set messageNotifications($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessageNotifications() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageNotifications() => $_clearField(1);

  /// 是否接收好友请求通知
  @$pb.TagNumber(2)
  $core.bool get friendRequestNotifications => $_getBF(1);
  @$pb.TagNumber(2)
  set friendRequestNotifications($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFriendRequestNotifications() => $_has(1);
  @$pb.TagNumber(2)
  void clearFriendRequestNotifications() => $_clearField(2);

  /// 是否接收群组消息通知
  @$pb.TagNumber(3)
  $core.bool get groupNotifications => $_getBF(2);
  @$pb.TagNumber(3)
  set groupNotifications($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGroupNotifications() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupNotifications() => $_clearField(3);

  /// 是否在免打扰时段接收通知
  @$pb.TagNumber(4)
  $core.bool get doNotDisturb => $_getBF(3);
  @$pb.TagNumber(4)
  set doNotDisturb($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDoNotDisturb() => $_has(3);
  @$pb.TagNumber(4)
  void clearDoNotDisturb() => $_clearField(4);

  /// 免打扰开始时间（24小时制，如：22:00）
  @$pb.TagNumber(5)
  $core.String get doNotDisturbStart => $_getSZ(4);
  @$pb.TagNumber(5)
  set doNotDisturbStart($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDoNotDisturbStart() => $_has(4);
  @$pb.TagNumber(5)
  void clearDoNotDisturbStart() => $_clearField(5);

  /// 免打扰结束时间（24小时制，如：07:00）
  @$pb.TagNumber(6)
  $core.String get doNotDisturbEnd => $_getSZ(5);
  @$pb.TagNumber(6)
  set doNotDisturbEnd($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDoNotDisturbEnd() => $_has(5);
  @$pb.TagNumber(6)
  void clearDoNotDisturbEnd() => $_clearField(6);
}

/// 隐私设置消息
/// 控制个人信息的可见性
class PrivacySettings extends $pb.GeneratedMessage {
  factory PrivacySettings({
    $core.bool? allowProfileView,
    $core.bool? allowFriendRequests,
    $core.bool? showOnlineStatus,
    $core.bool? showLastActive,
    $core.bool? showReadStatus,
  }) {
    final $result = create();
    if (allowProfileView != null) {
      $result.allowProfileView = allowProfileView;
    }
    if (allowFriendRequests != null) {
      $result.allowFriendRequests = allowFriendRequests;
    }
    if (showOnlineStatus != null) {
      $result.showOnlineStatus = showOnlineStatus;
    }
    if (showLastActive != null) {
      $result.showLastActive = showLastActive;
    }
    if (showReadStatus != null) {
      $result.showReadStatus = showReadStatus;
    }
    return $result;
  }
  PrivacySettings._() : super();
  factory PrivacySettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PrivacySettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrivacySettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'allowProfileView')
    ..aOB(2, _omitFieldNames ? '' : 'allowFriendRequests')
    ..aOB(3, _omitFieldNames ? '' : 'showOnlineStatus')
    ..aOB(4, _omitFieldNames ? '' : 'showLastActive')
    ..aOB(5, _omitFieldNames ? '' : 'showReadStatus')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PrivacySettings clone() => PrivacySettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PrivacySettings copyWith(void Function(PrivacySettings) updates) => super.copyWith((message) => updates(message as PrivacySettings)) as PrivacySettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrivacySettings create() => PrivacySettings._();
  PrivacySettings createEmptyInstance() => create();
  static $pb.PbList<PrivacySettings> createRepeated() => $pb.PbList<PrivacySettings>();
  @$core.pragma('dart2js:noInline')
  static PrivacySettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrivacySettings>(create);
  static PrivacySettings? _defaultInstance;

  /// 是否允许陌生人查看个人资料
  @$pb.TagNumber(1)
  $core.bool get allowProfileView => $_getBF(0);
  @$pb.TagNumber(1)
  set allowProfileView($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAllowProfileView() => $_has(0);
  @$pb.TagNumber(1)
  void clearAllowProfileView() => $_clearField(1);

  /// 是否允许陌生人发送好友请求
  @$pb.TagNumber(2)
  $core.bool get allowFriendRequests => $_getBF(1);
  @$pb.TagNumber(2)
  set allowFriendRequests($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAllowFriendRequests() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowFriendRequests() => $_clearField(2);

  /// 是否显示在线状态
  @$pb.TagNumber(3)
  $core.bool get showOnlineStatus => $_getBF(2);
  @$pb.TagNumber(3)
  set showOnlineStatus($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasShowOnlineStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearShowOnlineStatus() => $_clearField(3);

  /// 是否显示最后活跃时间
  @$pb.TagNumber(4)
  $core.bool get showLastActive => $_getBF(3);
  @$pb.TagNumber(4)
  set showLastActive($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasShowLastActive() => $_has(3);
  @$pb.TagNumber(4)
  void clearShowLastActive() => $_clearField(4);

  /// 是否显示已读状态
  @$pb.TagNumber(5)
  $core.bool get showReadStatus => $_getBF(4);
  @$pb.TagNumber(5)
  set showReadStatus($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasShowReadStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearShowReadStatus() => $_clearField(5);
}

/// 主题设置消息
/// 控制应用的显示主题
class ThemeSettings extends $pb.GeneratedMessage {
  factory ThemeSettings({
    $core.String? themeMode,
    $core.String? themeColor,
    $core.String? fontSize,
  }) {
    final $result = create();
    if (themeMode != null) {
      $result.themeMode = themeMode;
    }
    if (themeColor != null) {
      $result.themeColor = themeColor;
    }
    if (fontSize != null) {
      $result.fontSize = fontSize;
    }
    return $result;
  }
  ThemeSettings._() : super();
  factory ThemeSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ThemeSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ThemeSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeMode')
    ..aOS(2, _omitFieldNames ? '' : 'themeColor')
    ..aOS(3, _omitFieldNames ? '' : 'fontSize')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ThemeSettings clone() => ThemeSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ThemeSettings copyWith(void Function(ThemeSettings) updates) => super.copyWith((message) => updates(message as ThemeSettings)) as ThemeSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThemeSettings create() => ThemeSettings._();
  ThemeSettings createEmptyInstance() => create();
  static $pb.PbList<ThemeSettings> createRepeated() => $pb.PbList<ThemeSettings>();
  @$core.pragma('dart2js:noInline')
  static ThemeSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ThemeSettings>(create);
  static ThemeSettings? _defaultInstance;

  /// 主题模式
  /// 如：light, dark, system等
  @$pb.TagNumber(1)
  $core.String get themeMode => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeMode($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeMode() => $_clearField(1);

  /// 主题颜色
  /// 如：blue, green, purple等
  @$pb.TagNumber(2)
  $core.String get themeColor => $_getSZ(1);
  @$pb.TagNumber(2)
  set themeColor($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasThemeColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearThemeColor() => $_clearField(2);

  /// 字体大小
  /// 如：small, medium, large等
  @$pb.TagNumber(3)
  $core.String get fontSize => $_getSZ(2);
  @$pb.TagNumber(3)
  set fontSize($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFontSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearFontSize() => $_clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
