//
//  Generated code. Do not modify.
//  source: auth.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'auth.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'auth.pbenum.dart';

/// 认证请求结构
class AuthRequest extends $pb.GeneratedMessage {
  factory AuthRequest({
    AuthOperationType? operationType,
    $core.String? phoneNumber,
    $core.String? password,
    $core.String? verificationCode,
    $core.String? nickname,
    $core.bool? isQuickLogin,
    $core.String? purpose,
  }) {
    final $result = create();
    if (operationType != null) {
      $result.operationType = operationType;
    }
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    if (password != null) {
      $result.password = password;
    }
    if (verificationCode != null) {
      $result.verificationCode = verificationCode;
    }
    if (nickname != null) {
      $result.nickname = nickname;
    }
    if (isQuickLogin != null) {
      $result.isQuickLogin = isQuickLogin;
    }
    if (purpose != null) {
      $result.purpose = purpose;
    }
    return $result;
  }
  AuthRequest._() : super();
  factory AuthRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuthRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..e<AuthOperationType>(1, _omitFieldNames ? '' : 'operationType', $pb.PbFieldType.OE, defaultOrMaker: AuthOperationType.LOGIN, valueOf: AuthOperationType.valueOf, enumValues: AuthOperationType.values)
    ..aOS(2, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(3, _omitFieldNames ? '' : 'password')
    ..aOS(4, _omitFieldNames ? '' : 'verificationCode')
    ..aOS(5, _omitFieldNames ? '' : 'nickname')
    ..aOB(6, _omitFieldNames ? '' : 'isQuickLogin')
    ..aOS(7, _omitFieldNames ? '' : 'purpose')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuthRequest clone() => AuthRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuthRequest copyWith(void Function(AuthRequest) updates) => super.copyWith((message) => updates(message as AuthRequest)) as AuthRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthRequest create() => AuthRequest._();
  AuthRequest createEmptyInstance() => create();
  static $pb.PbList<AuthRequest> createRepeated() => $pb.PbList<AuthRequest>();
  @$core.pragma('dart2js:noInline')
  static AuthRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthRequest>(create);
  static AuthRequest? _defaultInstance;

  /// 操作类型
  @$pb.TagNumber(1)
  AuthOperationType get operationType => $_getN(0);
  @$pb.TagNumber(1)
  set operationType(AuthOperationType v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOperationType() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperationType() => $_clearField(1);

  /// 手机号
  @$pb.TagNumber(2)
  $core.String get phoneNumber => $_getSZ(1);
  @$pb.TagNumber(2)
  set phoneNumber($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPhoneNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhoneNumber() => $_clearField(2);

  /// 密码
  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => $_clearField(3);

  /// 验证码
  @$pb.TagNumber(4)
  $core.String get verificationCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set verificationCode($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVerificationCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearVerificationCode() => $_clearField(4);

  /// 昵称
  @$pb.TagNumber(5)
  $core.String get nickname => $_getSZ(4);
  @$pb.TagNumber(5)
  set nickname($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNickname() => $_has(4);
  @$pb.TagNumber(5)
  void clearNickname() => $_clearField(5);

  /// 是否快速登录
  @$pb.TagNumber(6)
  $core.bool get isQuickLogin => $_getBF(5);
  @$pb.TagNumber(6)
  set isQuickLogin($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsQuickLogin() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsQuickLogin() => $_clearField(6);

  /// 验证码用途
  @$pb.TagNumber(7)
  $core.String get purpose => $_getSZ(6);
  @$pb.TagNumber(7)
  set purpose($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPurpose() => $_has(6);
  @$pb.TagNumber(7)
  void clearPurpose() => $_clearField(7);
}

/// 认证响应结构
class AuthResponse extends $pb.GeneratedMessage {
  factory AuthResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? userId,
    $core.String? token,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (token != null) {
      $result.token = token;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  AuthResponse._() : super();
  factory AuthResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuthResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'token')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuthResponse clone() => AuthResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuthResponse copyWith(void Function(AuthResponse) updates) => super.copyWith((message) => updates(message as AuthResponse)) as AuthResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthResponse create() => AuthResponse._();
  AuthResponse createEmptyInstance() => create();
  static $pb.PbList<AuthResponse> createRepeated() => $pb.PbList<AuthResponse>();
  @$core.pragma('dart2js:noInline')
  static AuthResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthResponse>(create);
  static AuthResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示信息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 用户ID
  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  /// 认证令牌
  @$pb.TagNumber(4)
  $core.String get token => $_getSZ(3);
  @$pb.TagNumber(4)
  set token($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearToken() => $_clearField(4);

  /// 时间戳
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

/// 登录请求消息
/// 客户端发送登录请求时使用
class LoginRequest extends $pb.GeneratedMessage {
  factory LoginRequest({
    $core.String? identifier,
    $core.String? password,
    DeviceInfo? device,
  }) {
    final $result = create();
    if (identifier != null) {
      $result.identifier = identifier;
    }
    if (password != null) {
      $result.password = password;
    }
    if (device != null) {
      $result.device = device;
    }
    return $result;
  }
  LoginRequest._() : super();
  factory LoginRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identifier')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOM<DeviceInfo>(3, _omitFieldNames ? '' : 'device', subBuilder: DeviceInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoginRequest clone() => LoginRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoginRequest copyWith(void Function(LoginRequest) updates) => super.copyWith((message) => updates(message as LoginRequest)) as LoginRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginRequest create() => LoginRequest._();
  LoginRequest createEmptyInstance() => create();
  static $pb.PbList<LoginRequest> createRepeated() => $pb.PbList<LoginRequest>();
  @$core.pragma('dart2js:noInline')
  static LoginRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginRequest>(create);
  static LoginRequest? _defaultInstance;

  /// 用户登录方式
  /// 可以是手机号、邮箱或用户名
  @$pb.TagNumber(1)
  $core.String get identifier => $_getSZ(0);
  @$pb.TagNumber(1)
  set identifier($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentifier() => $_clearField(1);

  /// 用户密码
  /// 密码应该在前端进行加密后再传输
  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  /// 设备信息
  /// 用于记录登录设备，支持多设备登录
  @$pb.TagNumber(3)
  DeviceInfo get device => $_getN(2);
  @$pb.TagNumber(3)
  set device(DeviceInfo v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDevice() => $_has(2);
  @$pb.TagNumber(3)
  void clearDevice() => $_clearField(3);
  @$pb.TagNumber(3)
  DeviceInfo ensureDevice() => $_ensure(2);
}

/// 登录响应消息
/// 服务器返回登录结果
class LoginResponse extends $pb.GeneratedMessage {
  factory LoginResponse({
    $core.bool? success,
    $core.String? errorMessage,
    UserInfo? user,
    TokenPair? tokens,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (user != null) {
      $result.user = user;
    }
    if (tokens != null) {
      $result.tokens = tokens;
    }
    return $result;
  }
  LoginResponse._() : super();
  factory LoginResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<UserInfo>(3, _omitFieldNames ? '' : 'user', subBuilder: UserInfo.create)
    ..aOM<TokenPair>(4, _omitFieldNames ? '' : 'tokens', subBuilder: TokenPair.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoginResponse clone() => LoginResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoginResponse copyWith(void Function(LoginResponse) updates) => super.copyWith((message) => updates(message as LoginResponse)) as LoginResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginResponse create() => LoginResponse._();
  LoginResponse createEmptyInstance() => create();
  static $pb.PbList<LoginResponse> createRepeated() => $pb.PbList<LoginResponse>();
  @$core.pragma('dart2js:noInline')
  static LoginResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginResponse>(create);
  static LoginResponse? _defaultInstance;

  /// 登录是否成功
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

  /// 用户信息
  /// 登录成功时返回用户的基本信息
  @$pb.TagNumber(3)
  UserInfo get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(UserInfo v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  UserInfo ensureUser() => $_ensure(2);

  /// Token信息
  /// 包含Refresh Token和Socket Token
  @$pb.TagNumber(4)
  TokenPair get tokens => $_getN(3);
  @$pb.TagNumber(4)
  set tokens(TokenPair v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTokens() => $_has(3);
  @$pb.TagNumber(4)
  void clearTokens() => $_clearField(4);
  @$pb.TagNumber(4)
  TokenPair ensureTokens() => $_ensure(3);
}

/// 注册请求消息
/// 客户端发送注册请求时使用
class RegisterRequest extends $pb.GeneratedMessage {
  factory RegisterRequest({
    $core.String? username,
    $core.String? password,
    $core.String? phone,
    $core.String? email,
    DeviceInfo? device,
  }) {
    final $result = create();
    if (username != null) {
      $result.username = username;
    }
    if (password != null) {
      $result.password = password;
    }
    if (phone != null) {
      $result.phone = phone;
    }
    if (email != null) {
      $result.email = email;
    }
    if (device != null) {
      $result.device = device;
    }
    return $result;
  }
  RegisterRequest._() : super();
  factory RegisterRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegisterRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(3, _omitFieldNames ? '' : 'phone')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOM<DeviceInfo>(5, _omitFieldNames ? '' : 'device', subBuilder: DeviceInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegisterRequest clone() => RegisterRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegisterRequest copyWith(void Function(RegisterRequest) updates) => super.copyWith((message) => updates(message as RegisterRequest)) as RegisterRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterRequest create() => RegisterRequest._();
  RegisterRequest createEmptyInstance() => create();
  static $pb.PbList<RegisterRequest> createRepeated() => $pb.PbList<RegisterRequest>();
  @$core.pragma('dart2js:noInline')
  static RegisterRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterRequest>(create);
  static RegisterRequest? _defaultInstance;

  /// 用户名
  /// 用于登录和显示
  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  /// 密码
  /// 密码应该在前端进行加密后再传输
  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  /// 手机号
  /// 用于验证和找回密码
  @$pb.TagNumber(3)
  $core.String get phone => $_getSZ(2);
  @$pb.TagNumber(3)
  set phone($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPhone() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhone() => $_clearField(3);

  /// 邮箱
  /// 用于验证和找回密码
  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  /// 设备信息
  /// 用于记录注册设备
  @$pb.TagNumber(5)
  DeviceInfo get device => $_getN(4);
  @$pb.TagNumber(5)
  set device(DeviceInfo v) { $_setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasDevice() => $_has(4);
  @$pb.TagNumber(5)
  void clearDevice() => $_clearField(5);
  @$pb.TagNumber(5)
  DeviceInfo ensureDevice() => $_ensure(4);
}

/// 注册响应消息
/// 服务器返回注册结果
class RegisterResponse extends $pb.GeneratedMessage {
  factory RegisterResponse({
    $core.bool? success,
    $core.String? errorMessage,
    UserInfo? user,
    TokenPair? tokens,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (user != null) {
      $result.user = user;
    }
    if (tokens != null) {
      $result.tokens = tokens;
    }
    return $result;
  }
  RegisterResponse._() : super();
  factory RegisterResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegisterResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<UserInfo>(3, _omitFieldNames ? '' : 'user', subBuilder: UserInfo.create)
    ..aOM<TokenPair>(4, _omitFieldNames ? '' : 'tokens', subBuilder: TokenPair.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegisterResponse clone() => RegisterResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegisterResponse copyWith(void Function(RegisterResponse) updates) => super.copyWith((message) => updates(message as RegisterResponse)) as RegisterResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterResponse create() => RegisterResponse._();
  RegisterResponse createEmptyInstance() => create();
  static $pb.PbList<RegisterResponse> createRepeated() => $pb.PbList<RegisterResponse>();
  @$core.pragma('dart2js:noInline')
  static RegisterResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterResponse>(create);
  static RegisterResponse? _defaultInstance;

  /// 注册是否成功
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

  /// 用户信息
  /// 注册成功时返回用户的基本信息
  @$pb.TagNumber(3)
  UserInfo get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(UserInfo v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  UserInfo ensureUser() => $_ensure(2);

  /// Token信息
  /// 包含Refresh Token和Socket Token
  @$pb.TagNumber(4)
  TokenPair get tokens => $_getN(3);
  @$pb.TagNumber(4)
  set tokens(TokenPair v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTokens() => $_has(3);
  @$pb.TagNumber(4)
  void clearTokens() => $_clearField(4);
  @$pb.TagNumber(4)
  TokenPair ensureTokens() => $_ensure(3);
}

/// 密码重置请求
class ResetPasswordRequest extends $pb.GeneratedMessage {
  factory ResetPasswordRequest({
    $core.String? phoneNumber,
    $core.String? verificationCode,
    $core.String? newPassword,
  }) {
    final $result = create();
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    if (verificationCode != null) {
      $result.verificationCode = verificationCode;
    }
    if (newPassword != null) {
      $result.newPassword = newPassword;
    }
    return $result;
  }
  ResetPasswordRequest._() : super();
  factory ResetPasswordRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResetPasswordRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResetPasswordRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(2, _omitFieldNames ? '' : 'verificationCode')
    ..aOS(3, _omitFieldNames ? '' : 'newPassword')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResetPasswordRequest clone() => ResetPasswordRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResetPasswordRequest copyWith(void Function(ResetPasswordRequest) updates) => super.copyWith((message) => updates(message as ResetPasswordRequest)) as ResetPasswordRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResetPasswordRequest create() => ResetPasswordRequest._();
  ResetPasswordRequest createEmptyInstance() => create();
  static $pb.PbList<ResetPasswordRequest> createRepeated() => $pb.PbList<ResetPasswordRequest>();
  @$core.pragma('dart2js:noInline')
  static ResetPasswordRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResetPasswordRequest>(create);
  static ResetPasswordRequest? _defaultInstance;

  /// 手机号
  @$pb.TagNumber(1)
  $core.String get phoneNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneNumber($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPhoneNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneNumber() => $_clearField(1);

  /// 验证码
  @$pb.TagNumber(2)
  $core.String get verificationCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set verificationCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVerificationCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerificationCode() => $_clearField(2);

  /// 新密码
  @$pb.TagNumber(3)
  $core.String get newPassword => $_getSZ(2);
  @$pb.TagNumber(3)
  set newPassword($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNewPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewPassword() => $_clearField(3);
}

/// 验证码发送请求
class SendCodeRequest extends $pb.GeneratedMessage {
  factory SendCodeRequest({
    $core.String? phoneNumber,
    $core.String? purpose,
  }) {
    final $result = create();
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    if (purpose != null) {
      $result.purpose = purpose;
    }
    return $result;
  }
  SendCodeRequest._() : super();
  factory SendCodeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendCodeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendCodeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(2, _omitFieldNames ? '' : 'purpose')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendCodeRequest clone() => SendCodeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendCodeRequest copyWith(void Function(SendCodeRequest) updates) => super.copyWith((message) => updates(message as SendCodeRequest)) as SendCodeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendCodeRequest create() => SendCodeRequest._();
  SendCodeRequest createEmptyInstance() => create();
  static $pb.PbList<SendCodeRequest> createRepeated() => $pb.PbList<SendCodeRequest>();
  @$core.pragma('dart2js:noInline')
  static SendCodeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendCodeRequest>(create);
  static SendCodeRequest? _defaultInstance;

  /// 手机号
  @$pb.TagNumber(1)
  $core.String get phoneNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneNumber($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPhoneNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneNumber() => $_clearField(1);

  /// 用途 (login/register/reset)
  @$pb.TagNumber(2)
  $core.String get purpose => $_getSZ(1);
  @$pb.TagNumber(2)
  set purpose($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPurpose() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurpose() => $_clearField(2);
}

/// 验证码发送响应
class SendCodeResponse extends $pb.GeneratedMessage {
  factory SendCodeResponse({
    $core.bool? success,
    $core.String? message,
    $fixnum.Int64? timestamp,
    $core.int? cooldown,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (cooldown != null) {
      $result.cooldown = cooldown;
    }
    return $result;
  }
  SendCodeResponse._() : super();
  factory SendCodeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendCodeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendCodeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'cooldown', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendCodeResponse clone() => SendCodeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendCodeResponse copyWith(void Function(SendCodeResponse) updates) => super.copyWith((message) => updates(message as SendCodeResponse)) as SendCodeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendCodeResponse create() => SendCodeResponse._();
  SendCodeResponse createEmptyInstance() => create();
  static $pb.PbList<SendCodeResponse> createRepeated() => $pb.PbList<SendCodeResponse>();
  @$core.pragma('dart2js:noInline')
  static SendCodeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendCodeResponse>(create);
  static SendCodeResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 提示信息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// 时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  /// 冷却时间（秒）
  @$pb.TagNumber(4)
  $core.int get cooldown => $_getIZ(3);
  @$pb.TagNumber(4)
  set cooldown($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCooldown() => $_has(3);
  @$pb.TagNumber(4)
  void clearCooldown() => $_clearField(4);
}

/// 验证令牌请求消息
/// 客户端发送验证令牌请求时使用
class VerifyTokenRequest extends $pb.GeneratedMessage {
  factory VerifyTokenRequest({
    $core.String? token,
  }) {
    final $result = create();
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  VerifyTokenRequest._() : super();
  factory VerifyTokenRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifyTokenRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifyTokenRequest clone() => VerifyTokenRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifyTokenRequest copyWith(void Function(VerifyTokenRequest) updates) => super.copyWith((message) => updates(message as VerifyTokenRequest)) as VerifyTokenRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyTokenRequest create() => VerifyTokenRequest._();
  VerifyTokenRequest createEmptyInstance() => create();
  static $pb.PbList<VerifyTokenRequest> createRepeated() => $pb.PbList<VerifyTokenRequest>();
  @$core.pragma('dart2js:noInline')
  static VerifyTokenRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyTokenRequest>(create);
  static VerifyTokenRequest? _defaultInstance;

  /// 要验证的令牌
  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
}

/// 验证令牌响应消息
/// 服务器返回令牌验证结果
class VerifyTokenResponse extends $pb.GeneratedMessage {
  factory VerifyTokenResponse({
    $core.bool? valid,
    $core.String? errorMessage,
    UserInfo? user,
    $core.String? newToken,
    $fixnum.Int64? newTokenExpiresAt,
  }) {
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (user != null) {
      $result.user = user;
    }
    if (newToken != null) {
      $result.newToken = newToken;
    }
    if (newTokenExpiresAt != null) {
      $result.newTokenExpiresAt = newTokenExpiresAt;
    }
    return $result;
  }
  VerifyTokenResponse._() : super();
  factory VerifyTokenResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifyTokenResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyTokenResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<UserInfo>(3, _omitFieldNames ? '' : 'user', subBuilder: UserInfo.create)
    ..aOS(4, _omitFieldNames ? '' : 'newToken')
    ..aInt64(5, _omitFieldNames ? '' : 'newTokenExpiresAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifyTokenResponse clone() => VerifyTokenResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifyTokenResponse copyWith(void Function(VerifyTokenResponse) updates) => super.copyWith((message) => updates(message as VerifyTokenResponse)) as VerifyTokenResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyTokenResponse create() => VerifyTokenResponse._();
  VerifyTokenResponse createEmptyInstance() => create();
  static $pb.PbList<VerifyTokenResponse> createRepeated() => $pb.PbList<VerifyTokenResponse>();
  @$core.pragma('dart2js:noInline')
  static VerifyTokenResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyTokenResponse>(create);
  static VerifyTokenResponse? _defaultInstance;

  /// 验证是否成功
  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);

  /// 错误信息
  /// 当valid为false时，说明具体的错误原因
  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  /// 用户信息
  /// 验证成功时返回用户的基本信息
  @$pb.TagNumber(3)
  UserInfo get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(UserInfo v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  UserInfo ensureUser() => $_ensure(2);

  /// 新的认证令牌
  /// 如果原令牌即将过期，返回新的令牌
  @$pb.TagNumber(4)
  $core.String get newToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set newToken($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNewToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewToken() => $_clearField(4);

  /// 新令牌过期时间（毫秒时间戳）
  @$pb.TagNumber(5)
  $fixnum.Int64 get newTokenExpiresAt => $_getI64(4);
  @$pb.TagNumber(5)
  set newTokenExpiresAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNewTokenExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearNewTokenExpiresAt() => $_clearField(5);
}

/// 设备信息消息
/// 用于记录用户登录或注册时的设备信息
class DeviceInfo extends $pb.GeneratedMessage {
  factory DeviceInfo({
    $core.String? deviceId,
    $core.String? deviceType,
    $core.String? deviceModel,
    $core.String? osVersion,
    $core.String? appVersion,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (deviceType != null) {
      $result.deviceType = deviceType;
    }
    if (deviceModel != null) {
      $result.deviceModel = deviceModel;
    }
    if (osVersion != null) {
      $result.osVersion = osVersion;
    }
    if (appVersion != null) {
      $result.appVersion = appVersion;
    }
    return $result;
  }
  DeviceInfo._() : super();
  factory DeviceInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeviceInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeviceInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceType')
    ..aOS(3, _omitFieldNames ? '' : 'deviceModel')
    ..aOS(4, _omitFieldNames ? '' : 'osVersion')
    ..aOS(5, _omitFieldNames ? '' : 'appVersion')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeviceInfo clone() => DeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) => super.copyWith((message) => updates(message as DeviceInfo)) as DeviceInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceInfo create() => DeviceInfo._();
  DeviceInfo createEmptyInstance() => create();
  static $pb.PbList<DeviceInfo> createRepeated() => $pb.PbList<DeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static DeviceInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceInfo>(create);
  static DeviceInfo? _defaultInstance;

  /// 设备ID
  /// 用于唯一标识一个设备
  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  /// 设备类型
  /// 如：ios, android, web等
  @$pb.TagNumber(2)
  $core.String get deviceType => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceType() => $_clearField(2);

  /// 设备型号
  /// 如：iPhone 12, Samsung Galaxy S21等
  @$pb.TagNumber(3)
  $core.String get deviceModel => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceModel($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceModel() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceModel() => $_clearField(3);

  /// 操作系统版本
  /// 如：iOS 15.0, Android 12等
  @$pb.TagNumber(4)
  $core.String get osVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set osVersion($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOsVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearOsVersion() => $_clearField(4);

  /// 应用版本
  /// 当前应用的版本号
  @$pb.TagNumber(5)
  $core.String get appVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set appVersion($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAppVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearAppVersion() => $_clearField(5);
}

/// 用户信息消息
/// 包含用户的基本信息
class UserInfo extends $pb.GeneratedMessage {
  factory UserInfo({
    $core.String? userId,
    $core.String? username,
    $core.String? phone,
    $core.String? email,
    $core.String? avatar,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? lastLoginAt,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (username != null) {
      $result.username = username;
    }
    if (phone != null) {
      $result.phone = phone;
    }
    if (email != null) {
      $result.email = email;
    }
    if (avatar != null) {
      $result.avatar = avatar;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (lastLoginAt != null) {
      $result.lastLoginAt = lastLoginAt;
    }
    return $result;
  }
  UserInfo._() : super();
  factory UserInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'phone')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'avatar')
    ..aInt64(6, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(7, _omitFieldNames ? '' : 'lastLoginAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserInfo clone() => UserInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserInfo copyWith(void Function(UserInfo) updates) => super.copyWith((message) => updates(message as UserInfo)) as UserInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserInfo create() => UserInfo._();
  UserInfo createEmptyInstance() => create();
  static $pb.PbList<UserInfo> createRepeated() => $pb.PbList<UserInfo>();
  @$core.pragma('dart2js:noInline')
  static UserInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserInfo>(create);
  static UserInfo? _defaultInstance;

  /// 用户ID
  /// 系统分配的唯一标识
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 用户名
  /// 用于登录和显示
  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  /// 手机号
  /// 用于验证和找回密码
  @$pb.TagNumber(3)
  $core.String get phone => $_getSZ(2);
  @$pb.TagNumber(3)
  set phone($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPhone() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhone() => $_clearField(3);

  /// 邮箱
  /// 用于验证和找回密码
  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  /// 头像URL
  /// 用户头像的访问地址
  @$pb.TagNumber(5)
  $core.String get avatar => $_getSZ(4);
  @$pb.TagNumber(5)
  set avatar($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatar() => $_clearField(5);

  /// 注册时间（毫秒时间戳）
  @$pb.TagNumber(6)
  $fixnum.Int64 get createdAt => $_getI64(5);
  @$pb.TagNumber(6)
  set createdAt($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  /// 最后登录时间（毫秒时间戳）
  @$pb.TagNumber(7)
  $fixnum.Int64 get lastLoginAt => $_getI64(6);
  @$pb.TagNumber(7)
  set lastLoginAt($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLastLoginAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastLoginAt() => $_clearField(7);
}

/// Token对消息
/// 包含Refresh Token和Socket Token的完整信息
class TokenPair extends $pb.GeneratedMessage {
  factory TokenPair({
    $core.String? refreshToken,
    $fixnum.Int64? refreshTokenExpiresAt,
    $core.String? socketToken,
    $fixnum.Int64? socketTokenExpiresAt,
  }) {
    final $result = create();
    if (refreshToken != null) {
      $result.refreshToken = refreshToken;
    }
    if (refreshTokenExpiresAt != null) {
      $result.refreshTokenExpiresAt = refreshTokenExpiresAt;
    }
    if (socketToken != null) {
      $result.socketToken = socketToken;
    }
    if (socketTokenExpiresAt != null) {
      $result.socketTokenExpiresAt = socketTokenExpiresAt;
    }
    return $result;
  }
  TokenPair._() : super();
  factory TokenPair.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenPair.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TokenPair', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..aInt64(2, _omitFieldNames ? '' : 'refreshTokenExpiresAt')
    ..aOS(3, _omitFieldNames ? '' : 'socketToken')
    ..aInt64(4, _omitFieldNames ? '' : 'socketTokenExpiresAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TokenPair clone() => TokenPair()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TokenPair copyWith(void Function(TokenPair) updates) => super.copyWith((message) => updates(message as TokenPair)) as TokenPair;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenPair create() => TokenPair._();
  TokenPair createEmptyInstance() => create();
  static $pb.PbList<TokenPair> createRepeated() => $pb.PbList<TokenPair>();
  @$core.pragma('dart2js:noInline')
  static TokenPair getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenPair>(create);
  static TokenPair? _defaultInstance;

  /// Refresh Token
  /// 用于刷新Socket Token，有效期30天
  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);

  /// Refresh Token过期时间（毫秒时间戳）
  @$pb.TagNumber(2)
  $fixnum.Int64 get refreshTokenExpiresAt => $_getI64(1);
  @$pb.TagNumber(2)
  set refreshTokenExpiresAt($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRefreshTokenExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearRefreshTokenExpiresAt() => $_clearField(2);

  /// Socket Token
  /// 用于Socket.IO连接和所有需要认证的业务操作，有效期7天
  @$pb.TagNumber(3)
  $core.String get socketToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set socketToken($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSocketToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearSocketToken() => $_clearField(3);

  /// Socket Token过期时间（毫秒时间戳）
  @$pb.TagNumber(4)
  $fixnum.Int64 get socketTokenExpiresAt => $_getI64(3);
  @$pb.TagNumber(4)
  set socketTokenExpiresAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSocketTokenExpiresAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearSocketTokenExpiresAt() => $_clearField(4);
}

/// Socket Token刷新请求消息
/// 客户端通过Socket.io发送刷新请求时使用
class RefreshSocketTokenRequest extends $pb.GeneratedMessage {
  factory RefreshSocketTokenRequest({
    $core.String? refreshToken,
    $fixnum.Int64? timestamp,
    DeviceInfo? device,
  }) {
    final $result = create();
    if (refreshToken != null) {
      $result.refreshToken = refreshToken;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (device != null) {
      $result.device = device;
    }
    return $result;
  }
  RefreshSocketTokenRequest._() : super();
  factory RefreshSocketTokenRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RefreshSocketTokenRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshSocketTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..aOM<DeviceInfo>(3, _omitFieldNames ? '' : 'device', subBuilder: DeviceInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RefreshSocketTokenRequest clone() => RefreshSocketTokenRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RefreshSocketTokenRequest copyWith(void Function(RefreshSocketTokenRequest) updates) => super.copyWith((message) => updates(message as RefreshSocketTokenRequest)) as RefreshSocketTokenRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshSocketTokenRequest create() => RefreshSocketTokenRequest._();
  RefreshSocketTokenRequest createEmptyInstance() => create();
  static $pb.PbList<RefreshSocketTokenRequest> createRepeated() => $pb.PbList<RefreshSocketTokenRequest>();
  @$core.pragma('dart2js:noInline')
  static RefreshSocketTokenRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshSocketTokenRequest>(create);
  static RefreshSocketTokenRequest? _defaultInstance;

  /// Refresh Token
  /// 用于验证身份并获取新的Socket Token
  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);

  /// 请求时间戳
  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);

  /// 设备信息（可选）
  /// 用于记录刷新操作的设备
  @$pb.TagNumber(3)
  DeviceInfo get device => $_getN(2);
  @$pb.TagNumber(3)
  set device(DeviceInfo v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDevice() => $_has(2);
  @$pb.TagNumber(3)
  void clearDevice() => $_clearField(3);
  @$pb.TagNumber(3)
  DeviceInfo ensureDevice() => $_ensure(2);
}

/// Socket Token刷新响应消息
/// 服务器通过Socket.io返回刷新结果
class RefreshSocketTokenResponse extends $pb.GeneratedMessage {
  factory RefreshSocketTokenResponse({
    $core.bool? success,
    $core.String? errorMessage,
    TokenPair? tokens,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (tokens != null) {
      $result.tokens = tokens;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  RefreshSocketTokenResponse._() : super();
  factory RefreshSocketTokenResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RefreshSocketTokenResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshSocketTokenResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<TokenPair>(3, _omitFieldNames ? '' : 'tokens', subBuilder: TokenPair.create)
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RefreshSocketTokenResponse clone() => RefreshSocketTokenResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RefreshSocketTokenResponse copyWith(void Function(RefreshSocketTokenResponse) updates) => super.copyWith((message) => updates(message as RefreshSocketTokenResponse)) as RefreshSocketTokenResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshSocketTokenResponse create() => RefreshSocketTokenResponse._();
  RefreshSocketTokenResponse createEmptyInstance() => create();
  static $pb.PbList<RefreshSocketTokenResponse> createRepeated() => $pb.PbList<RefreshSocketTokenResponse>();
  @$core.pragma('dart2js:noInline')
  static RefreshSocketTokenResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshSocketTokenResponse>(create);
  static RefreshSocketTokenResponse? _defaultInstance;

  /// 刷新是否成功
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

  /// 新的Token信息
  /// 刷新成功时返回新的Token对
  @$pb.TagNumber(3)
  TokenPair get tokens => $_getN(2);
  @$pb.TagNumber(3)
  set tokens(TokenPair v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTokens() => $_has(2);
  @$pb.TagNumber(3)
  void clearTokens() => $_clearField(3);
  @$pb.TagNumber(3)
  TokenPair ensureTokens() => $_ensure(2);

  /// 响应时间戳
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// 用户会话信息
/// 已更新为使用新的Token机制
class UserSession extends $pb.GeneratedMessage {
  factory UserSession({
    $core.String? userId,
    TokenPair? tokens,
    $core.String? phoneNumber,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? lastActiveAt,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (tokens != null) {
      $result.tokens = tokens;
    }
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (lastActiveAt != null) {
      $result.lastActiveAt = lastActiveAt;
    }
    return $result;
  }
  UserSession._() : super();
  factory UserSession.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserSession.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserSession', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<TokenPair>(2, _omitFieldNames ? '' : 'tokens', subBuilder: TokenPair.create)
    ..aOS(3, _omitFieldNames ? '' : 'phoneNumber')
    ..aInt64(4, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(5, _omitFieldNames ? '' : 'lastActiveAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserSession clone() => UserSession()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserSession copyWith(void Function(UserSession) updates) => super.copyWith((message) => updates(message as UserSession)) as UserSession;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSession create() => UserSession._();
  UserSession createEmptyInstance() => create();
  static $pb.PbList<UserSession> createRepeated() => $pb.PbList<UserSession>();
  @$core.pragma('dart2js:noInline')
  static UserSession getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserSession>(create);
  static UserSession? _defaultInstance;

  /// 用户ID
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// Token信息
  /// 包含Refresh Token和Socket Token
  @$pb.TagNumber(2)
  TokenPair get tokens => $_getN(1);
  @$pb.TagNumber(2)
  set tokens(TokenPair v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTokens() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokens() => $_clearField(2);
  @$pb.TagNumber(2)
  TokenPair ensureTokens() => $_ensure(1);

  /// 手机号
  @$pb.TagNumber(3)
  $core.String get phoneNumber => $_getSZ(2);
  @$pb.TagNumber(3)
  set phoneNumber($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPhoneNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhoneNumber() => $_clearField(3);

  /// 会话创建时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get createdAt => $_getI64(3);
  @$pb.TagNumber(4)
  set createdAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);

  /// 最后活跃时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get lastActiveAt => $_getI64(4);
  @$pb.TagNumber(5)
  set lastActiveAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastActiveAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastActiveAt() => $_clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
