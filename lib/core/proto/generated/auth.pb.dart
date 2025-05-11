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
    ..e<AuthOperationType>(1, _omitFieldNames ? '' : 'operationType', $pb.PbFieldType.OE, defaultOrMaker: AuthOperationType.login, valueOf: AuthOperationType.valueOf, enumValues: AuthOperationType.values)
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

  @$pb.TagNumber(1)
  AuthOperationType get operationType => $_getN(0);
  @$pb.TagNumber(1)
  set operationType(AuthOperationType v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOperationType() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperationType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get phoneNumber => $_getSZ(1);
  @$pb.TagNumber(2)
  set phoneNumber($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPhoneNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhoneNumber() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get verificationCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set verificationCode($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVerificationCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearVerificationCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get nickname => $_getSZ(4);
  @$pb.TagNumber(5)
  set nickname($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNickname() => $_has(4);
  @$pb.TagNumber(5)
  void clearNickname() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isQuickLogin => $_getBF(5);
  @$pb.TagNumber(6)
  set isQuickLogin($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsQuickLogin() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsQuickLogin() => $_clearField(6);

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
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get token => $_getSZ(3);
  @$pb.TagNumber(4)
  set token($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearToken() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

enum LoginRequest_AuthMethod {
  password, 
  verificationCode, 
  notSet
}

/// 登录请求
class LoginRequest extends $pb.GeneratedMessage {
  factory LoginRequest({
    $core.String? phoneNumber,
    $core.String? password,
    $core.String? verificationCode,
    $core.bool? isQuickLogin,
  }) {
    final $result = create();
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    if (password != null) {
      $result.password = password;
    }
    if (verificationCode != null) {
      $result.verificationCode = verificationCode;
    }
    if (isQuickLogin != null) {
      $result.isQuickLogin = isQuickLogin;
    }
    return $result;
  }
  LoginRequest._() : super();
  factory LoginRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, LoginRequest_AuthMethod> _LoginRequest_AuthMethodByTag = {
    2 : LoginRequest_AuthMethod.password,
    3 : LoginRequest_AuthMethod.verificationCode,
    0 : LoginRequest_AuthMethod.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..oo(0, [2, 3])
    ..aOS(1, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(3, _omitFieldNames ? '' : 'verificationCode')
    ..aOB(4, _omitFieldNames ? '' : 'isQuickLogin')
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

  LoginRequest_AuthMethod whichAuthMethod() => _LoginRequest_AuthMethodByTag[$_whichOneof(0)]!;
  void clearAuthMethod() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get phoneNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneNumber($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPhoneNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get verificationCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set verificationCode($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVerificationCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerificationCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isQuickLogin => $_getBF(3);
  @$pb.TagNumber(4)
  set isQuickLogin($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsQuickLogin() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsQuickLogin() => $_clearField(4);
}

/// 注册请求
class RegisterRequest extends $pb.GeneratedMessage {
  factory RegisterRequest({
    $core.String? phoneNumber,
    $core.String? verificationCode,
    $core.String? password,
    $core.String? nickname,
  }) {
    final $result = create();
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    if (verificationCode != null) {
      $result.verificationCode = verificationCode;
    }
    if (password != null) {
      $result.password = password;
    }
    if (nickname != null) {
      $result.nickname = nickname;
    }
    return $result;
  }
  RegisterRequest._() : super();
  factory RegisterRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegisterRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(2, _omitFieldNames ? '' : 'verificationCode')
    ..aOS(3, _omitFieldNames ? '' : 'password')
    ..aOS(4, _omitFieldNames ? '' : 'nickname')
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

  @$pb.TagNumber(1)
  $core.String get phoneNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneNumber($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPhoneNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get verificationCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set verificationCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVerificationCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerificationCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get nickname => $_getSZ(3);
  @$pb.TagNumber(4)
  set nickname($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNickname() => $_has(3);
  @$pb.TagNumber(4)
  void clearNickname() => $_clearField(4);
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

  @$pb.TagNumber(1)
  $core.String get phoneNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneNumber($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPhoneNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get verificationCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set verificationCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVerificationCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerificationCode() => $_clearField(2);

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

  @$pb.TagNumber(1)
  $core.String get phoneNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneNumber($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPhoneNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneNumber() => $_clearField(1);

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
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get cooldown => $_getIZ(3);
  @$pb.TagNumber(4)
  set cooldown($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCooldown() => $_has(3);
  @$pb.TagNumber(4)
  void clearCooldown() => $_clearField(4);
}

/// 用户会话信息
class UserSession extends $pb.GeneratedMessage {
  factory UserSession({
    $core.String? userId,
    $core.String? token,
    $fixnum.Int64? expireTime,
    $core.String? phoneNumber,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (token != null) {
      $result.token = token;
    }
    if (expireTime != null) {
      $result.expireTime = expireTime;
    }
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    return $result;
  }
  UserSession._() : super();
  factory UserSession.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserSession.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserSession', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aInt64(3, _omitFieldNames ? '' : 'expireTime')
    ..aOS(4, _omitFieldNames ? '' : 'phoneNumber')
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
  $fixnum.Int64 get expireTime => $_getI64(2);
  @$pb.TagNumber(3)
  set expireTime($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasExpireTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpireTime() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get phoneNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set phoneNumber($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPhoneNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhoneNumber() => $_clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
