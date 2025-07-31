// This is a generated file - do not edit.
//
// Generated from contacts.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 好友请求状态枚举
/// 定义好友请求的不同状态
class FriendRequestStatus extends $pb.ProtobufEnum {
  /// 待处理
  /// 好友请求已发送，等待对方处理
  static const FriendRequestStatus PENDING =
      FriendRequestStatus._(0, _omitEnumNames ? '' : 'PENDING');

  /// 已接受
  /// 好友请求已被接受
  static const FriendRequestStatus ACCEPTED =
      FriendRequestStatus._(1, _omitEnumNames ? '' : 'ACCEPTED');

  /// 已拒绝
  /// 好友请求已被拒绝
  static const FriendRequestStatus REJECTED =
      FriendRequestStatus._(2, _omitEnumNames ? '' : 'REJECTED');

  static const $core.List<FriendRequestStatus> values = <FriendRequestStatus>[
    PENDING,
    ACCEPTED,
    REJECTED,
  ];

  static final $core.List<FriendRequestStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static FriendRequestStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FriendRequestStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
