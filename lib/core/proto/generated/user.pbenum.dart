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
  static const UserStatusEnum offline = UserStatusEnum._(0, _omitEnumNames ? '' : 'offline');
  static const UserStatusEnum online = UserStatusEnum._(1, _omitEnumNames ? '' : 'online');
  static const UserStatusEnum away = UserStatusEnum._(2, _omitEnumNames ? '' : 'away');

  static const $core.List<UserStatusEnum> values = <UserStatusEnum> [
    offline,
    online,
    away,
  ];

  static final $core.Map<$core.int, UserStatusEnum> _byValue = $pb.ProtobufEnum.initByValue(values);
  static UserStatusEnum? valueOf($core.int value) => _byValue[value];

  const UserStatusEnum._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
