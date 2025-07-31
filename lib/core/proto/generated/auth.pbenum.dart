// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 认证操作类型
class AuthOperationType extends $pb.ProtobufEnum {
  /// 登录
  static const AuthOperationType LOGIN =
      AuthOperationType._(0, _omitEnumNames ? '' : 'LOGIN');

  /// 注册
  static const AuthOperationType REGISTER =
      AuthOperationType._(1, _omitEnumNames ? '' : 'REGISTER');

  /// 重置密码
  static const AuthOperationType RESET_PASSWORD =
      AuthOperationType._(2, _omitEnumNames ? '' : 'RESET_PASSWORD');

  /// 发送验证码
  static const AuthOperationType SEND_CODE =
      AuthOperationType._(3, _omitEnumNames ? '' : 'SEND_CODE');

  static const $core.List<AuthOperationType> values = <AuthOperationType>[
    LOGIN,
    REGISTER,
    RESET_PASSWORD,
    SEND_CODE,
  ];

  static final $core.List<AuthOperationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AuthOperationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AuthOperationType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
