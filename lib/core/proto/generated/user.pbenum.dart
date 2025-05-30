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

import 'package:protobuf/protobuf.dart' as $pb;

/// 用户在线状态枚举
class UserStatusEnum extends $pb.ProtobufEnum {
  static const UserStatusEnum OFFLINE = UserStatusEnum._(0, _omitEnumNames ? '' : 'OFFLINE');
  static const UserStatusEnum ONLINE = UserStatusEnum._(1, _omitEnumNames ? '' : 'ONLINE');
  static const UserStatusEnum AWAY = UserStatusEnum._(2, _omitEnumNames ? '' : 'AWAY');

  static const $core.List<UserStatusEnum> values = <UserStatusEnum> [
    OFFLINE,
    ONLINE,
    AWAY,
  ];

  static final $core.Map<$core.int, UserStatusEnum> _byValue = $pb.ProtobufEnum.initByValue(values);
  static UserStatusEnum? valueOf($core.int value) => _byValue[value];

  const UserStatusEnum._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
