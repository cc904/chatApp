//
//  Generated code. Do not modify.
//  source: auth.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 认证操作类型
class AuthOperationType extends $pb.ProtobufEnum {
  static const AuthOperationType login = AuthOperationType._(0, _omitEnumNames ? '' : 'login');
  static const AuthOperationType register = AuthOperationType._(1, _omitEnumNames ? '' : 'register');
  static const AuthOperationType reset_password = AuthOperationType._(2, _omitEnumNames ? '' : 'reset_password');
  static const AuthOperationType send_code = AuthOperationType._(3, _omitEnumNames ? '' : 'send_code');

  static const $core.List<AuthOperationType> values = <AuthOperationType> [
    login,
    register,
    reset_password,
    send_code,
  ];

  static final $core.Map<$core.int, AuthOperationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AuthOperationType? valueOf($core.int value) => _byValue[value];

  const AuthOperationType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
