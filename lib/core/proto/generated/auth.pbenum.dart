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

import 'package:protobuf/protobuf.dart' as $pb;

/// 认证操作类型
class AuthOperationType extends $pb.ProtobufEnum {
  static const AuthOperationType LOGIN = AuthOperationType._(0, _omitEnumNames ? '' : 'LOGIN');
  static const AuthOperationType REGISTER = AuthOperationType._(1, _omitEnumNames ? '' : 'REGISTER');
  static const AuthOperationType RESET_PASSWORD = AuthOperationType._(2, _omitEnumNames ? '' : 'RESET_PASSWORD');
  static const AuthOperationType SEND_CODE = AuthOperationType._(3, _omitEnumNames ? '' : 'SEND_CODE');

  static const $core.List<AuthOperationType> values = <AuthOperationType> [
    LOGIN,
    REGISTER,
    RESET_PASSWORD,
    SEND_CODE,
  ];

  static final $core.Map<$core.int, AuthOperationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AuthOperationType? valueOf($core.int value) => _byValue[value];

  const AuthOperationType._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
