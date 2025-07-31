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

import 'package:protobuf/protobuf.dart' as $pb;

/// 用户在线状态枚举
class UserStatusEnum extends $pb.ProtobufEnum {
  static const UserStatusEnum OFFLINE =
      UserStatusEnum._(0, _omitEnumNames ? '' : 'OFFLINE');
  static const UserStatusEnum ONLINE =
      UserStatusEnum._(1, _omitEnumNames ? '' : 'ONLINE');
  static const UserStatusEnum AWAY =
      UserStatusEnum._(2, _omitEnumNames ? '' : 'AWAY');

  static const $core.List<UserStatusEnum> values = <UserStatusEnum>[
    OFFLINE,
    ONLINE,
    AWAY,
  ];

  static final $core.List<UserStatusEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static UserStatusEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserStatusEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
