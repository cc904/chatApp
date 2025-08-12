// This is a generated file - do not edit.
//
// Generated from user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'conversation.pb.dart' as $0;
import 'user.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'user.pbenum.dart';

/// 用户基本信息消息
/// 包含用户的基本个人信息
/// Socket.io事件: user:profile:updated
class UserProto extends $pb.GeneratedMessage {
  factory UserProto({
    $core.String? userId,
    $core.String? name,
    $core.String? avatar,
    $core.String? phone,
    $core.String? email,
    $core.String? pinyin,
    $fixnum.Int64? lastActiveTime,
    UserStatusEnum? status,
    $core.int? roleId,
    $core.String? nickname,
    $core.String? remark,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (phone != null) result.phone = phone;
    if (email != null) result.email = email;
    if (pinyin != null) result.pinyin = pinyin;
    if (lastActiveTime != null) result.lastActiveTime = lastActiveTime;
    if (status != null) result.status = status;
    if (roleId != null) result.roleId = roleId;
    if (nickname != null) result.nickname = nickname;
    if (remark != null) result.remark = remark;
    return result;
  }

  UserProto._();

  factory UserProto.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserProto.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserProto',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aOS(5, _omitFieldNames ? '' : 'email')
    ..aOS(6, _omitFieldNames ? '' : 'pinyin')
    ..aInt64(7, _omitFieldNames ? '' : 'lastActiveTime')
    ..e<UserStatusEnum>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE,
        defaultOrMaker: UserStatusEnum.OFFLINE,
        valueOf: UserStatusEnum.valueOf,
        enumValues: UserStatusEnum.values)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'roleId', $pb.PbFieldType.O3)
    ..aOS(10, _omitFieldNames ? '' : 'nickname')
    ..aOS(11, _omitFieldNames ? '' : 'remark')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProto clone() => UserProto()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProto copyWith(void Function(UserProto) updates) =>
      super.copyWith((message) => updates(message as UserProto)) as UserProto;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserProto create() => UserProto._();
  @$core.override
  UserProto createEmptyInstance() => create();
  static $pb.PbList<UserProto> createRepeated() => $pb.PbList<UserProto>();
  @$core.pragma('dart2js:noInline')
  static UserProto getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserProto>(create);
  static UserProto? _defaultInstance;

  /// 用户ID
  /// 系统分配的唯一标识
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 用户昵称（用户真实昵称，对应数据库User.name字段）
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 头像
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// 手机号
  @$pb.TagNumber(4)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  /// 邮箱
  @$pb.TagNumber(5)
  $core.String get email => $_getSZ(4);
  @$pb.TagNumber(5)
  set email($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmail() => $_clearField(5);

  /// 拼音
  @$pb.TagNumber(6)
  $core.String get pinyin => $_getSZ(5);
  @$pb.TagNumber(6)
  set pinyin($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPinyin() => $_has(5);
  @$pb.TagNumber(6)
  void clearPinyin() => $_clearField(6);

  /// 最后活跃时间
  @$pb.TagNumber(7)
  $fixnum.Int64 get lastActiveTime => $_getI64(6);
  @$pb.TagNumber(7)
  set lastActiveTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLastActiveTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastActiveTime() => $_clearField(7);

  /// 状态（0=OFFLINE, 1=ONLINE, 2=AWAY）
  @$pb.TagNumber(8)
  UserStatusEnum get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(UserStatusEnum value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  /// 用户角色ID
  @$pb.TagNumber(9)
  $core.int get roleId => $_getIZ(8);
  @$pb.TagNumber(9)
  set roleId($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRoleId() => $_has(8);
  @$pb.TagNumber(9)
  void clearRoleId() => $_clearField(9);

  /// 自定义联系人昵称（当前用户为此联系人设置的昵称，对应数据库Contact.nickname字段）
  @$pb.TagNumber(10)
  $core.String get nickname => $_getSZ(9);
  @$pb.TagNumber(10)
  set nickname($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNickname() => $_has(9);
  @$pb.TagNumber(10)
  void clearNickname() => $_clearField(10);

  /// 联系人备注（当前用户为此联系人设置的备注信息，对应数据库Contact.remark字段）
  @$pb.TagNumber(11)
  $core.String get remark => $_getSZ(10);
  @$pb.TagNumber(11)
  set remark($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasRemark() => $_has(10);
  @$pb.TagNumber(11)
  void clearRemark() => $_clearField(11);
}

/// 当前登录用户信息
class CurrentUserProto extends $pb.GeneratedMessage {
  factory CurrentUserProto({
    $core.String? userId,
    $core.String? name,
    $core.String? avatar,
    $core.String? phone,
    $core.String? email,
    $fixnum.Int64? lastLoginTime,
    UserStatusEnum? status,
    $core.bool? hasSetPassword,
    $core.int? roleId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (phone != null) result.phone = phone;
    if (email != null) result.email = email;
    if (lastLoginTime != null) result.lastLoginTime = lastLoginTime;
    if (status != null) result.status = status;
    if (hasSetPassword != null) result.hasSetPassword = hasSetPassword;
    if (roleId != null) result.roleId = roleId;
    return result;
  }

  CurrentUserProto._();

  factory CurrentUserProto.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CurrentUserProto.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CurrentUserProto',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aOS(5, _omitFieldNames ? '' : 'email')
    ..aInt64(6, _omitFieldNames ? '' : 'lastLoginTime')
    ..e<UserStatusEnum>(7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE,
        defaultOrMaker: UserStatusEnum.OFFLINE,
        valueOf: UserStatusEnum.valueOf,
        enumValues: UserStatusEnum.values)
    ..aOB(8, _omitFieldNames ? '' : 'hasSetPassword')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'roleId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CurrentUserProto clone() => CurrentUserProto()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CurrentUserProto copyWith(void Function(CurrentUserProto) updates) =>
      super.copyWith((message) => updates(message as CurrentUserProto))
          as CurrentUserProto;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CurrentUserProto create() => CurrentUserProto._();
  @$core.override
  CurrentUserProto createEmptyInstance() => create();
  static $pb.PbList<CurrentUserProto> createRepeated() =>
      $pb.PbList<CurrentUserProto>();
  @$core.pragma('dart2js:noInline')
  static CurrentUserProto getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CurrentUserProto>(create);
  static CurrentUserProto? _defaultInstance;

  /// 用户ID
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

  /// 头像URL
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// 手机号
  @$pb.TagNumber(4)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  /// 电子邮箱
  @$pb.TagNumber(5)
  $core.String get email => $_getSZ(4);
  @$pb.TagNumber(5)
  set email($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmail() => $_clearField(5);

  /// 最后登录时间
  @$pb.TagNumber(6)
  $fixnum.Int64 get lastLoginTime => $_getI64(5);
  @$pb.TagNumber(6)
  set lastLoginTime($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLastLoginTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastLoginTime() => $_clearField(6);

  /// 状态（0=OFFLINE, 1=ONLINE, 2=AWAY）
  @$pb.TagNumber(7)
  UserStatusEnum get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(UserStatusEnum value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  /// 是否已设置密码
  @$pb.TagNumber(8)
  $core.bool get hasSetPassword => $_getBF(7);
  @$pb.TagNumber(8)
  set hasSetPassword($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHasSetPassword() => $_has(7);
  @$pb.TagNumber(8)
  void clearHasSetPassword() => $_clearField(8);

  /// 用户角色ID
  @$pb.TagNumber(9)
  $core.int get roleId => $_getIZ(8);
  @$pb.TagNumber(9)
  set roleId($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRoleId() => $_has(8);
  @$pb.TagNumber(9)
  void clearRoleId() => $_clearField(9);
}

/// 设置当前用户信息请求
/// 用于更新当前登录用户的个人信息
/// Socket.io事件: user:set
class SetCurrentUserRequest extends $pb.GeneratedMessage {
  factory SetCurrentUserRequest({
    $core.String? name,
    $core.String? avatar,
    $core.String? phone,
    $core.String? email,
    $core.String? status,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (phone != null) result.phone = phone;
    if (email != null) result.email = email;
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SetCurrentUserRequest._();

  factory SetCurrentUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCurrentUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCurrentUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'avatar')
    ..aOS(3, _omitFieldNames ? '' : 'phone')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCurrentUserRequest clone() =>
      SetCurrentUserRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCurrentUserRequest copyWith(
          void Function(SetCurrentUserRequest) updates) =>
      super.copyWith((message) => updates(message as SetCurrentUserRequest))
          as SetCurrentUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCurrentUserRequest create() => SetCurrentUserRequest._();
  @$core.override
  SetCurrentUserRequest createEmptyInstance() => create();
  static $pb.PbList<SetCurrentUserRequest> createRepeated() =>
      $pb.PbList<SetCurrentUserRequest>();
  @$core.pragma('dart2js:noInline')
  static SetCurrentUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCurrentUserRequest>(create);
  static SetCurrentUserRequest? _defaultInstance;

  /// 用户名称（可选）
  /// 如果为空则不更新此字段
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// 头像URL（可选）
  /// 如果为空则不更新此字段
  @$pb.TagNumber(2)
  $core.String get avatar => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatar($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvatar() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatar() => $_clearField(2);

  /// 手机号（可选）
  /// 如果为空则不更新此字段
  @$pb.TagNumber(3)
  $core.String get phone => $_getSZ(2);
  @$pb.TagNumber(3)
  set phone($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhone() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhone() => $_clearField(3);

  /// 电子邮箱（可选）
  /// 如果为空则不更新此字段
  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  /// 状态（可选）
  /// 如果为空则不更新此字段
  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  /// 时间戳
  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);
}

/// 设置当前用户信息响应
/// Socket.io事件: user:set:response
class SetCurrentUserResponse extends $pb.GeneratedMessage {
  factory SetCurrentUserResponse({
    $core.bool? success,
    $core.String? message,
    CurrentUserProto? user,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (user != null) result.user = user;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SetCurrentUserResponse._();

  factory SetCurrentUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCurrentUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCurrentUserResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<CurrentUserProto>(3, _omitFieldNames ? '' : 'user',
        subBuilder: CurrentUserProto.create)
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCurrentUserResponse clone() =>
      SetCurrentUserResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCurrentUserResponse copyWith(
          void Function(SetCurrentUserResponse) updates) =>
      super.copyWith((message) => updates(message as SetCurrentUserResponse))
          as SetCurrentUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCurrentUserResponse create() => SetCurrentUserResponse._();
  @$core.override
  SetCurrentUserResponse createEmptyInstance() => create();
  static $pb.PbList<SetCurrentUserResponse> createRepeated() =>
      $pb.PbList<SetCurrentUserResponse>();
  @$core.pragma('dart2js:noInline')
  static SetCurrentUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCurrentUserResponse>(create);
  static SetCurrentUserResponse? _defaultInstance;

  /// 操作是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 响应消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 更新后的用户信息
  @$pb.TagNumber(3)
  CurrentUserProto get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(CurrentUserProto value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  CurrentUserProto ensureUser() => $_ensure(2);

  /// 操作时间戳
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// 当前用户信息更新事件
/// 当用户信息发生变化时广播给相关客户端
/// Socket.io事件: user:updated
class CurrentUserUpdateEvent extends $pb.GeneratedMessage {
  factory CurrentUserUpdateEvent({
    CurrentUserProto? user,
    $core.Iterable<$core.String>? updatedFields,
    $fixnum.Int64? timestamp,
    $core.String? updateSource,
  }) {
    final result = create();
    if (user != null) result.user = user;
    if (updatedFields != null) result.updatedFields.addAll(updatedFields);
    if (timestamp != null) result.timestamp = timestamp;
    if (updateSource != null) result.updateSource = updateSource;
    return result;
  }

  CurrentUserUpdateEvent._();

  factory CurrentUserUpdateEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CurrentUserUpdateEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CurrentUserUpdateEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOM<CurrentUserProto>(1, _omitFieldNames ? '' : 'user',
        subBuilder: CurrentUserProto.create)
    ..pPS(2, _omitFieldNames ? '' : 'updatedFields')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..aOS(4, _omitFieldNames ? '' : 'updateSource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CurrentUserUpdateEvent clone() =>
      CurrentUserUpdateEvent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CurrentUserUpdateEvent copyWith(
          void Function(CurrentUserUpdateEvent) updates) =>
      super.copyWith((message) => updates(message as CurrentUserUpdateEvent))
          as CurrentUserUpdateEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CurrentUserUpdateEvent create() => CurrentUserUpdateEvent._();
  @$core.override
  CurrentUserUpdateEvent createEmptyInstance() => create();
  static $pb.PbList<CurrentUserUpdateEvent> createRepeated() =>
      $pb.PbList<CurrentUserUpdateEvent>();
  @$core.pragma('dart2js:noInline')
  static CurrentUserUpdateEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CurrentUserUpdateEvent>(create);
  static CurrentUserUpdateEvent? _defaultInstance;

  /// 更新的用户信息
  @$pb.TagNumber(1)
  CurrentUserProto get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(CurrentUserProto value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  CurrentUserProto ensureUser() => $_ensure(0);

  /// 更新的字段列表
  /// 用于标识哪些字段发生了变化
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get updatedFields => $_getList(1);

  /// 更新时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  /// 更新来源
  /// 如：user_action, admin_action, system_sync等
  @$pb.TagNumber(4)
  $core.String get updateSource => $_getSZ(3);
  @$pb.TagNumber(4)
  set updateSource($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdateSource() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdateSource() => $_clearField(4);
}

/// 用户在线状态更新
/// Socket.io事件: user:online, user:offline
class UserStatusUpdate extends $pb.GeneratedMessage {
  factory UserStatusUpdate({
    $core.String? userId,
    $core.String? status,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UserStatusUpdate._();

  factory UserStatusUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserStatusUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserStatusUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserStatusUpdate clone() => UserStatusUpdate()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserStatusUpdate copyWith(void Function(UserStatusUpdate) updates) =>
      super.copyWith((message) => updates(message as UserStatusUpdate))
          as UserStatusUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserStatusUpdate create() => UserStatusUpdate._();
  @$core.override
  UserStatusUpdate createEmptyInstance() => create();
  static $pb.PbList<UserStatusUpdate> createRepeated() =>
      $pb.PbList<UserStatusUpdate>();
  @$core.pragma('dart2js:noInline')
  static UserStatusUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserStatusUpdate>(create);
  static UserStatusUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 使用字符串保持一致性
  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

/// 用户打字状态更新
/// Socket.io事件: user:typing, user:typing:stop
class UserTypingUpdate extends $pb.GeneratedMessage {
  factory UserTypingUpdate({
    $core.String? userId,
    $core.String? conversationId,
    $core.bool? isTyping,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (conversationId != null) result.conversationId = conversationId;
    if (isTyping != null) result.isTyping = isTyping;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UserTypingUpdate._();

  factory UserTypingUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserTypingUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserTypingUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserTypingUpdate clone() => UserTypingUpdate()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserTypingUpdate copyWith(void Function(UserTypingUpdate) updates) =>
      super.copyWith((message) => updates(message as UserTypingUpdate))
          as UserTypingUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserTypingUpdate create() => UserTypingUpdate._();
  @$core.override
  UserTypingUpdate createEmptyInstance() => create();
  static $pb.PbList<UserTypingUpdate> createRepeated() =>
      $pb.PbList<UserTypingUpdate>();
  @$core.pragma('dart2js:noInline')
  static UserTypingUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserTypingUpdate>(create);
  static UserTypingUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(2);
  @$pb.TagNumber(3)
  set isTyping($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTyping() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// 用户连接响应
/// Socket.io事件: user:connect:response
class UserConnectionResponse extends $pb.GeneratedMessage {
  factory UserConnectionResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? userId,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (userId != null) result.userId = userId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UserConnectionResponse._();

  factory UserConnectionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserConnectionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserConnectionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConnectionResponse clone() =>
      UserConnectionResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConnectionResponse copyWith(
          void Function(UserConnectionResponse) updates) =>
      super.copyWith((message) => updates(message as UserConnectionResponse))
          as UserConnectionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserConnectionResponse create() => UserConnectionResponse._();
  @$core.override
  UserConnectionResponse createEmptyInstance() => create();
  static $pb.PbList<UserConnectionResponse> createRepeated() =>
      $pb.PbList<UserConnectionResponse>();
  @$core.pragma('dart2js:noInline')
  static UserConnectionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserConnectionResponse>(create);
  static UserConnectionResponse? _defaultInstance;

  /// 连接是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 响应消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 用户ID
  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  /// 连接时间戳
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
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
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (user != null) result.user = user;
    return result;
  }

  UserResponse._();

  factory UserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<UserProto>(3, _omitFieldNames ? '' : 'user',
        subBuilder: UserProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserResponse clone() => UserResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserResponse copyWith(void Function(UserResponse) updates) =>
      super.copyWith((message) => updates(message as UserResponse))
          as UserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserResponse create() => UserResponse._();
  @$core.override
  UserResponse createEmptyInstance() => create();
  static $pb.PbList<UserResponse> createRepeated() =>
      $pb.PbList<UserResponse>();
  @$core.pragma('dart2js:noInline')
  static UserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserResponse>(create);
  static UserResponse? _defaultInstance;

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
  UserProto get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(UserProto value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  UserProto ensureUser() => $_ensure(2);
}

/// 用户列表
/// Socket.io事件: contact:synced
class UserCollection extends $pb.GeneratedMessage {
  factory UserCollection({
    $core.Iterable<UserProto>? users,
  }) {
    final result = create();
    if (users != null) result.users.addAll(users);
    return result;
  }

  UserCollection._();

  factory UserCollection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserCollection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserCollection',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..pc<UserProto>(1, _omitFieldNames ? '' : 'users', $pb.PbFieldType.PM,
        subBuilder: UserProto.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserCollection clone() => UserCollection()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserCollection copyWith(void Function(UserCollection) updates) =>
      super.copyWith((message) => updates(message as UserCollection))
          as UserCollection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserCollection create() => UserCollection._();
  @$core.override
  UserCollection createEmptyInstance() => create();
  static $pb.PbList<UserCollection> createRepeated() =>
      $pb.PbList<UserCollection>();
  @$core.pragma('dart2js:noInline')
  static UserCollection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserCollection>(create);
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
    final result = create();
    if (isOnline != null) result.isOnline = isOnline;
    if (lastActiveAt != null) result.lastActiveAt = lastActiveAt;
    if (deviceType != null) result.deviceType = deviceType;
    return result;
  }

  UserStatusMessage._();

  factory UserStatusMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserStatusMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserStatusMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isOnline')
    ..aInt64(2, _omitFieldNames ? '' : 'lastActiveAt')
    ..aOS(3, _omitFieldNames ? '' : 'deviceType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserStatusMessage clone() => UserStatusMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserStatusMessage copyWith(void Function(UserStatusMessage) updates) =>
      super.copyWith((message) => updates(message as UserStatusMessage))
          as UserStatusMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserStatusMessage create() => UserStatusMessage._();
  @$core.override
  UserStatusMessage createEmptyInstance() => create();
  static $pb.PbList<UserStatusMessage> createRepeated() =>
      $pb.PbList<UserStatusMessage>();
  @$core.pragma('dart2js:noInline')
  static UserStatusMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserStatusMessage>(create);
  static UserStatusMessage? _defaultInstance;

  /// 是否在线
  @$pb.TagNumber(1)
  $core.bool get isOnline => $_getBF(0);
  @$pb.TagNumber(1)
  set isOnline($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsOnline() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsOnline() => $_clearField(1);

  /// 最后活跃时间（毫秒时间戳）
  @$pb.TagNumber(2)
  $fixnum.Int64 get lastActiveAt => $_getI64(1);
  @$pb.TagNumber(2)
  set lastActiveAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastActiveAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastActiveAt() => $_clearField(2);

  /// 设备类型
  /// 如：ios, android, web等
  @$pb.TagNumber(3)
  $core.String get deviceType => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceType($core.String value) => $_setString(2, value);
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
    final result = create();
    if (userId != null) result.userId = userId;
    if (notifications != null) result.notifications = notifications;
    if (privacy != null) result.privacy = privacy;
    if (theme != null) result.theme = theme;
    if (language != null) result.language = language;
    if (timezone != null) result.timezone = timezone;
    return result;
  }

  UserSettings._();

  factory UserSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<NotificationSettings>(2, _omitFieldNames ? '' : 'notifications',
        subBuilder: NotificationSettings.create)
    ..aOM<PrivacySettings>(3, _omitFieldNames ? '' : 'privacy',
        subBuilder: PrivacySettings.create)
    ..aOM<ThemeSettings>(4, _omitFieldNames ? '' : 'theme',
        subBuilder: ThemeSettings.create)
    ..aOS(5, _omitFieldNames ? '' : 'language')
    ..aOS(6, _omitFieldNames ? '' : 'timezone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSettings clone() => UserSettings()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSettings copyWith(void Function(UserSettings) updates) =>
      super.copyWith((message) => updates(message as UserSettings))
          as UserSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSettings create() => UserSettings._();
  @$core.override
  UserSettings createEmptyInstance() => create();
  static $pb.PbList<UserSettings> createRepeated() =>
      $pb.PbList<UserSettings>();
  @$core.pragma('dart2js:noInline')
  static UserSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserSettings>(create);
  static UserSettings? _defaultInstance;

  /// 用户ID
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 消息通知设置
  /// 控制是否接收各类消息通知
  @$pb.TagNumber(2)
  NotificationSettings get notifications => $_getN(1);
  @$pb.TagNumber(2)
  set notifications(NotificationSettings value) => $_setField(2, value);
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
  set privacy(PrivacySettings value) => $_setField(3, value);
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
  set theme(ThemeSettings value) => $_setField(4, value);
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
  set language($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLanguage() => $_has(4);
  @$pb.TagNumber(5)
  void clearLanguage() => $_clearField(5);

  /// 时区设置
  /// 控制时间显示和消息时间戳
  @$pb.TagNumber(6)
  $core.String get timezone => $_getSZ(5);
  @$pb.TagNumber(6)
  set timezone($core.String value) => $_setString(5, value);
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
    final result = create();
    if (messageNotifications != null)
      result.messageNotifications = messageNotifications;
    if (friendRequestNotifications != null)
      result.friendRequestNotifications = friendRequestNotifications;
    if (groupNotifications != null)
      result.groupNotifications = groupNotifications;
    if (doNotDisturb != null) result.doNotDisturb = doNotDisturb;
    if (doNotDisturbStart != null) result.doNotDisturbStart = doNotDisturbStart;
    if (doNotDisturbEnd != null) result.doNotDisturbEnd = doNotDisturbEnd;
    return result;
  }

  NotificationSettings._();

  factory NotificationSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'messageNotifications')
    ..aOB(2, _omitFieldNames ? '' : 'friendRequestNotifications')
    ..aOB(3, _omitFieldNames ? '' : 'groupNotifications')
    ..aOB(4, _omitFieldNames ? '' : 'doNotDisturb')
    ..aOS(5, _omitFieldNames ? '' : 'doNotDisturbStart')
    ..aOS(6, _omitFieldNames ? '' : 'doNotDisturbEnd')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings clone() =>
      NotificationSettings()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings copyWith(void Function(NotificationSettings) updates) =>
      super.copyWith((message) => updates(message as NotificationSettings))
          as NotificationSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationSettings create() => NotificationSettings._();
  @$core.override
  NotificationSettings createEmptyInstance() => create();
  static $pb.PbList<NotificationSettings> createRepeated() =>
      $pb.PbList<NotificationSettings>();
  @$core.pragma('dart2js:noInline')
  static NotificationSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationSettings>(create);
  static NotificationSettings? _defaultInstance;

  /// 是否接收新消息通知
  @$pb.TagNumber(1)
  $core.bool get messageNotifications => $_getBF(0);
  @$pb.TagNumber(1)
  set messageNotifications($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageNotifications() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageNotifications() => $_clearField(1);

  /// 是否接收好友请求通知
  @$pb.TagNumber(2)
  $core.bool get friendRequestNotifications => $_getBF(1);
  @$pb.TagNumber(2)
  set friendRequestNotifications($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFriendRequestNotifications() => $_has(1);
  @$pb.TagNumber(2)
  void clearFriendRequestNotifications() => $_clearField(2);

  /// 是否接收群组消息通知
  @$pb.TagNumber(3)
  $core.bool get groupNotifications => $_getBF(2);
  @$pb.TagNumber(3)
  set groupNotifications($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupNotifications() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupNotifications() => $_clearField(3);

  /// 是否在免打扰时段接收通知
  @$pb.TagNumber(4)
  $core.bool get doNotDisturb => $_getBF(3);
  @$pb.TagNumber(4)
  set doNotDisturb($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDoNotDisturb() => $_has(3);
  @$pb.TagNumber(4)
  void clearDoNotDisturb() => $_clearField(4);

  /// 免打扰开始时间（24小时制，如：22:00）
  @$pb.TagNumber(5)
  $core.String get doNotDisturbStart => $_getSZ(4);
  @$pb.TagNumber(5)
  set doNotDisturbStart($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDoNotDisturbStart() => $_has(4);
  @$pb.TagNumber(5)
  void clearDoNotDisturbStart() => $_clearField(5);

  /// 免打扰结束时间（24小时制，如：07:00）
  @$pb.TagNumber(6)
  $core.String get doNotDisturbEnd => $_getSZ(5);
  @$pb.TagNumber(6)
  set doNotDisturbEnd($core.String value) => $_setString(5, value);
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
    final result = create();
    if (allowProfileView != null) result.allowProfileView = allowProfileView;
    if (allowFriendRequests != null)
      result.allowFriendRequests = allowFriendRequests;
    if (showOnlineStatus != null) result.showOnlineStatus = showOnlineStatus;
    if (showLastActive != null) result.showLastActive = showLastActive;
    if (showReadStatus != null) result.showReadStatus = showReadStatus;
    return result;
  }

  PrivacySettings._();

  factory PrivacySettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrivacySettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrivacySettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'allowProfileView')
    ..aOB(2, _omitFieldNames ? '' : 'allowFriendRequests')
    ..aOB(3, _omitFieldNames ? '' : 'showOnlineStatus')
    ..aOB(4, _omitFieldNames ? '' : 'showLastActive')
    ..aOB(5, _omitFieldNames ? '' : 'showReadStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrivacySettings clone() => PrivacySettings()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrivacySettings copyWith(void Function(PrivacySettings) updates) =>
      super.copyWith((message) => updates(message as PrivacySettings))
          as PrivacySettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrivacySettings create() => PrivacySettings._();
  @$core.override
  PrivacySettings createEmptyInstance() => create();
  static $pb.PbList<PrivacySettings> createRepeated() =>
      $pb.PbList<PrivacySettings>();
  @$core.pragma('dart2js:noInline')
  static PrivacySettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrivacySettings>(create);
  static PrivacySettings? _defaultInstance;

  /// 是否允许陌生人查看个人资料
  @$pb.TagNumber(1)
  $core.bool get allowProfileView => $_getBF(0);
  @$pb.TagNumber(1)
  set allowProfileView($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAllowProfileView() => $_has(0);
  @$pb.TagNumber(1)
  void clearAllowProfileView() => $_clearField(1);

  /// 是否允许陌生人发送好友请求
  @$pb.TagNumber(2)
  $core.bool get allowFriendRequests => $_getBF(1);
  @$pb.TagNumber(2)
  set allowFriendRequests($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllowFriendRequests() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowFriendRequests() => $_clearField(2);

  /// 是否显示在线状态
  @$pb.TagNumber(3)
  $core.bool get showOnlineStatus => $_getBF(2);
  @$pb.TagNumber(3)
  set showOnlineStatus($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasShowOnlineStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearShowOnlineStatus() => $_clearField(3);

  /// 是否显示最后活跃时间
  @$pb.TagNumber(4)
  $core.bool get showLastActive => $_getBF(3);
  @$pb.TagNumber(4)
  set showLastActive($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasShowLastActive() => $_has(3);
  @$pb.TagNumber(4)
  void clearShowLastActive() => $_clearField(4);

  /// 是否显示已读状态
  @$pb.TagNumber(5)
  $core.bool get showReadStatus => $_getBF(4);
  @$pb.TagNumber(5)
  set showReadStatus($core.bool value) => $_setBool(4, value);
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
    final result = create();
    if (themeMode != null) result.themeMode = themeMode;
    if (themeColor != null) result.themeColor = themeColor;
    if (fontSize != null) result.fontSize = fontSize;
    return result;
  }

  ThemeSettings._();

  factory ThemeSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ThemeSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ThemeSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeMode')
    ..aOS(2, _omitFieldNames ? '' : 'themeColor')
    ..aOS(3, _omitFieldNames ? '' : 'fontSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThemeSettings clone() => ThemeSettings()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThemeSettings copyWith(void Function(ThemeSettings) updates) =>
      super.copyWith((message) => updates(message as ThemeSettings))
          as ThemeSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThemeSettings create() => ThemeSettings._();
  @$core.override
  ThemeSettings createEmptyInstance() => create();
  static $pb.PbList<ThemeSettings> createRepeated() =>
      $pb.PbList<ThemeSettings>();
  @$core.pragma('dart2js:noInline')
  static ThemeSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ThemeSettings>(create);
  static ThemeSettings? _defaultInstance;

  /// 主题模式
  /// 如：light, dark, system等
  @$pb.TagNumber(1)
  $core.String get themeMode => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeMode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasThemeMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeMode() => $_clearField(1);

  /// 主题颜色
  /// 如：blue, green, purple等
  @$pb.TagNumber(2)
  $core.String get themeColor => $_getSZ(1);
  @$pb.TagNumber(2)
  set themeColor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasThemeColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearThemeColor() => $_clearField(2);

  /// 字体大小
  /// 如：small, medium, large等
  @$pb.TagNumber(3)
  $core.String get fontSize => $_getSZ(2);
  @$pb.TagNumber(3)
  set fontSize($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFontSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearFontSize() => $_clearField(3);
}

/// 搜索用户请求
/// 通过ID或手机号搜索用户
class SearchUserRequest extends $pb.GeneratedMessage {
  factory SearchUserRequest({
    $core.String? query,
    $core.String? searchType,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (searchType != null) result.searchType = searchType;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SearchUserRequest._();

  factory SearchUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'searchType')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserRequest clone() => SearchUserRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserRequest copyWith(void Function(SearchUserRequest) updates) =>
      super.copyWith((message) => updates(message as SearchUserRequest))
          as SearchUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUserRequest create() => SearchUserRequest._();
  @$core.override
  SearchUserRequest createEmptyInstance() => create();
  static $pb.PbList<SearchUserRequest> createRepeated() =>
      $pb.PbList<SearchUserRequest>();
  @$core.pragma('dart2js:noInline')
  static SearchUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUserRequest>(create);
  static SearchUserRequest? _defaultInstance;

  /// 搜索关键字（用户ID或手机号）
  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  /// 搜索类型
  /// "user_id" - 按用户ID搜索
  /// "phone" - 按手机号搜索
  /// "auto" - 自动判断类型
  @$pb.TagNumber(2)
  $core.String get searchType => $_getSZ(1);
  @$pb.TagNumber(2)
  set searchType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSearchType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearchType() => $_clearField(2);

  /// 时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

/// 搜索用户响应
class SearchUserResponse extends $pb.GeneratedMessage {
  factory SearchUserResponse({
    $core.bool? success,
    $core.String? message,
    UserProto? user,
    $core.String? query,
    $core.bool? isFriend,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (user != null) result.user = user;
    if (query != null) result.query = query;
    if (isFriend != null) result.isFriend = isFriend;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SearchUserResponse._();

  factory SearchUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUserResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<UserProto>(3, _omitFieldNames ? '' : 'user',
        subBuilder: UserProto.create)
    ..aOS(4, _omitFieldNames ? '' : 'query')
    ..aOB(5, _omitFieldNames ? '' : 'isFriend')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserResponse clone() => SearchUserResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserResponse copyWith(void Function(SearchUserResponse) updates) =>
      super.copyWith((message) => updates(message as SearchUserResponse))
          as SearchUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUserResponse create() => SearchUserResponse._();
  @$core.override
  SearchUserResponse createEmptyInstance() => create();
  static $pb.PbList<SearchUserResponse> createRepeated() =>
      $pb.PbList<SearchUserResponse>();
  @$core.pragma('dart2js:noInline')
  static SearchUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUserResponse>(create);
  static SearchUserResponse? _defaultInstance;

  /// 操作是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 响应消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 找到的用户信息（如果成功找到）
  @$pb.TagNumber(3)
  UserProto get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(UserProto value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  UserProto ensureUser() => $_ensure(2);

  /// 搜索关键字
  @$pb.TagNumber(4)
  $core.String get query => $_getSZ(3);
  @$pb.TagNumber(4)
  set query($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuery() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuery() => $_clearField(4);

  /// 是否已经是好友
  @$pb.TagNumber(5)
  $core.bool get isFriend => $_getBF(4);
  @$pb.TagNumber(5)
  set isFriend($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsFriend() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsFriend() => $_clearField(5);

  /// 时间戳
  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);
}

/// 统一搜索请求
/// 支持搜索用户、群聊、频道的综合搜索接口
/// Socket.io事件: search:universal
class UniversalSearchRequest extends $pb.GeneratedMessage {
  factory UniversalSearchRequest({
    $core.String? query,
    $core.Iterable<$core.String>? searchTypes,
    $core.int? limit,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (searchTypes != null) result.searchTypes.addAll(searchTypes);
    if (limit != null) result.limit = limit;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UniversalSearchRequest._();

  factory UniversalSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UniversalSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UniversalSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..pPS(2, _omitFieldNames ? '' : 'searchTypes')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UniversalSearchRequest clone() =>
      UniversalSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UniversalSearchRequest copyWith(
          void Function(UniversalSearchRequest) updates) =>
      super.copyWith((message) => updates(message as UniversalSearchRequest))
          as UniversalSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UniversalSearchRequest create() => UniversalSearchRequest._();
  @$core.override
  UniversalSearchRequest createEmptyInstance() => create();
  static $pb.PbList<UniversalSearchRequest> createRepeated() =>
      $pb.PbList<UniversalSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static UniversalSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UniversalSearchRequest>(create);
  static UniversalSearchRequest? _defaultInstance;

  /// 搜索关键字（用户ID/群聊ID/频道ID）
  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  /// 搜索类型列表
  /// "user" - 搜索用户
  /// "group" - 搜索群聊
  /// "channel" - 搜索频道
  /// "all" - 搜索所有类型
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get searchTypes => $_getList(1);

  /// 结果数量限制（每种类型的最大结果数）
  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);

  /// 时间戳
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// 统一搜索响应
/// Socket.io事件: search:universal:response
class UniversalSearchResponse extends $pb.GeneratedMessage {
  factory UniversalSearchResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<UserProto>? users,
    $core.Iterable<$0.ConversationProto>? conversations,
    $core.String? query,
    $core.Iterable<$core.String>? searchedTypes,
    $core.int? userCount,
    $core.int? conversationCount,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (users != null) result.users.addAll(users);
    if (conversations != null) result.conversations.addAll(conversations);
    if (query != null) result.query = query;
    if (searchedTypes != null) result.searchedTypes.addAll(searchedTypes);
    if (userCount != null) result.userCount = userCount;
    if (conversationCount != null) result.conversationCount = conversationCount;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UniversalSearchResponse._();

  factory UniversalSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UniversalSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UniversalSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pc<UserProto>(3, _omitFieldNames ? '' : 'users', $pb.PbFieldType.PM,
        subBuilder: UserProto.create)
    ..pc<$0.ConversationProto>(
        4, _omitFieldNames ? '' : 'conversations', $pb.PbFieldType.PM,
        subBuilder: $0.ConversationProto.create)
    ..aOS(5, _omitFieldNames ? '' : 'query')
    ..pPS(6, _omitFieldNames ? '' : 'searchedTypes')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'userCount', $pb.PbFieldType.O3)
    ..a<$core.int>(
        8, _omitFieldNames ? '' : 'conversationCount', $pb.PbFieldType.O3)
    ..aInt64(9, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UniversalSearchResponse clone() =>
      UniversalSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UniversalSearchResponse copyWith(
          void Function(UniversalSearchResponse) updates) =>
      super.copyWith((message) => updates(message as UniversalSearchResponse))
          as UniversalSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UniversalSearchResponse create() => UniversalSearchResponse._();
  @$core.override
  UniversalSearchResponse createEmptyInstance() => create();
  static $pb.PbList<UniversalSearchResponse> createRepeated() =>
      $pb.PbList<UniversalSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static UniversalSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UniversalSearchResponse>(create);
  static UniversalSearchResponse? _defaultInstance;

  /// 操作是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 响应消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 用户搜索结果
  @$pb.TagNumber(3)
  $pb.PbList<UserProto> get users => $_getList(2);

  /// 会话搜索结果（群聊和频道）- 使用完整的会话信息
  @$pb.TagNumber(4)
  $pb.PbList<$0.ConversationProto> get conversations => $_getList(3);

  /// 搜索关键字
  @$pb.TagNumber(5)
  $core.String get query => $_getSZ(4);
  @$pb.TagNumber(5)
  set query($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQuery() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuery() => $_clearField(5);

  /// 搜索的类型
  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get searchedTypes => $_getList(5);

  /// 各类型的结果数量
  @$pb.TagNumber(7)
  $core.int get userCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set userCount($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUserCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearUserCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get conversationCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set conversationCount($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConversationCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearConversationCount() => $_clearField(8);

  /// 时间戳
  @$pb.TagNumber(9)
  $fixnum.Int64 get timestamp => $_getI64(8);
  @$pb.TagNumber(9)
  set timestamp($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTimestamp() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimestamp() => $_clearField(9);
}

/// 修改密码请求
/// 用于用户在设置中修改密码
/// Socket.io事件: user:change_password
class ChangePasswordRequest extends $pb.GeneratedMessage {
  factory ChangePasswordRequest({
    $core.String? currentPassword,
    $core.String? newPassword,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (currentPassword != null) result.currentPassword = currentPassword;
    if (newPassword != null) result.newPassword = newPassword;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ChangePasswordRequest._();

  factory ChangePasswordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangePasswordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangePasswordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'currentPassword')
    ..aOS(2, _omitFieldNames ? '' : 'newPassword')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest clone() =>
      ChangePasswordRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest copyWith(
          void Function(ChangePasswordRequest) updates) =>
      super.copyWith((message) => updates(message as ChangePasswordRequest))
          as ChangePasswordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest create() => ChangePasswordRequest._();
  @$core.override
  ChangePasswordRequest createEmptyInstance() => create();
  static $pb.PbList<ChangePasswordRequest> createRepeated() =>
      $pb.PbList<ChangePasswordRequest>();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangePasswordRequest>(create);
  static ChangePasswordRequest? _defaultInstance;

  /// 当前密码（用于验证用户身份）
  @$pb.TagNumber(1)
  $core.String get currentPassword => $_getSZ(0);
  @$pb.TagNumber(1)
  set currentPassword($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrentPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentPassword() => $_clearField(1);

  /// 新密码
  @$pb.TagNumber(2)
  $core.String get newPassword => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPassword($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPassword() => $_clearField(2);

  /// 时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

/// 修改密码响应
/// Socket.io事件: user:change_password:response
class ChangePasswordResponse extends $pb.GeneratedMessage {
  factory ChangePasswordResponse({
    $core.bool? success,
    $core.String? message,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ChangePasswordResponse._();

  factory ChangePasswordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangePasswordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangePasswordResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse clone() =>
      ChangePasswordResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse copyWith(
          void Function(ChangePasswordResponse) updates) =>
      super.copyWith((message) => updates(message as ChangePasswordResponse))
          as ChangePasswordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse create() => ChangePasswordResponse._();
  @$core.override
  ChangePasswordResponse createEmptyInstance() => create();
  static $pb.PbList<ChangePasswordResponse> createRepeated() =>
      $pb.PbList<ChangePasswordResponse>();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangePasswordResponse>(create);
  static ChangePasswordResponse? _defaultInstance;

  /// 操作是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 响应消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 操作时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

/// 获取当前用户信息请求
/// 用于获取当前登录用户的完整信息
/// Socket.io事件: user:getCurrentUser
class GetCurrentUserRequest extends $pb.GeneratedMessage {
  factory GetCurrentUserRequest({
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  GetCurrentUserRequest._();

  factory GetCurrentUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCurrentUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCurrentUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCurrentUserRequest clone() =>
      GetCurrentUserRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCurrentUserRequest copyWith(
          void Function(GetCurrentUserRequest) updates) =>
      super.copyWith((message) => updates(message as GetCurrentUserRequest))
          as GetCurrentUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCurrentUserRequest create() => GetCurrentUserRequest._();
  @$core.override
  GetCurrentUserRequest createEmptyInstance() => create();
  static $pb.PbList<GetCurrentUserRequest> createRepeated() =>
      $pb.PbList<GetCurrentUserRequest>();
  @$core.pragma('dart2js:noInline')
  static GetCurrentUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCurrentUserRequest>(create);
  static GetCurrentUserRequest? _defaultInstance;

  /// 时间戳
  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
}

/// 首次设置密码请求
/// 用于验证码注册的用户首次设置密码
/// Socket.io事件: user:set_password
class SetPasswordRequest extends $pb.GeneratedMessage {
  factory SetPasswordRequest({
    $core.String? newPassword,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (newPassword != null) result.newPassword = newPassword;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SetPasswordRequest._();

  factory SetPasswordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPasswordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPasswordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'newPassword')
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPasswordRequest clone() => SetPasswordRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPasswordRequest copyWith(void Function(SetPasswordRequest) updates) =>
      super.copyWith((message) => updates(message as SetPasswordRequest))
          as SetPasswordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPasswordRequest create() => SetPasswordRequest._();
  @$core.override
  SetPasswordRequest createEmptyInstance() => create();
  static $pb.PbList<SetPasswordRequest> createRepeated() =>
      $pb.PbList<SetPasswordRequest>();
  @$core.pragma('dart2js:noInline')
  static SetPasswordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPasswordRequest>(create);
  static SetPasswordRequest? _defaultInstance;

  /// 新密码
  @$pb.TagNumber(1)
  $core.String get newPassword => $_getSZ(0);
  @$pb.TagNumber(1)
  set newPassword($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewPassword() => $_clearField(1);

  /// 时间戳
  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
}

/// 首次设置密码响应
/// Socket.io事件: user:set_password:response
class SetPasswordResponse extends $pb.GeneratedMessage {
  factory SetPasswordResponse({
    $core.bool? success,
    $core.String? message,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SetPasswordResponse._();

  factory SetPasswordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPasswordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPasswordResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPasswordResponse clone() => SetPasswordResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPasswordResponse copyWith(void Function(SetPasswordResponse) updates) =>
      super.copyWith((message) => updates(message as SetPasswordResponse))
          as SetPasswordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPasswordResponse create() => SetPasswordResponse._();
  @$core.override
  SetPasswordResponse createEmptyInstance() => create();
  static $pb.PbList<SetPasswordResponse> createRepeated() =>
      $pb.PbList<SetPasswordResponse>();
  @$core.pragma('dart2js:noInline')
  static SetPasswordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPasswordResponse>(create);
  static SetPasswordResponse? _defaultInstance;

  /// 操作是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 响应消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 操作时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
