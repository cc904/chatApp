//
//  Generated code. Do not modify.
//  source: conversation.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 会话类型枚举，匹配数据库模型
class ConversationType extends $pb.ProtobufEnum {
  static const ConversationType PRIVATE = ConversationType._(0, _omitEnumNames ? '' : 'PRIVATE');
  static const ConversationType GROUP = ConversationType._(1, _omitEnumNames ? '' : 'GROUP');
  static const ConversationType CHANNEL = ConversationType._(2, _omitEnumNames ? '' : 'CHANNEL');

  static const $core.List<ConversationType> values = <ConversationType> [
    PRIVATE,
    GROUP,
    CHANNEL,
  ];

  static final $core.Map<$core.int, ConversationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ConversationType? valueOf($core.int value) => _byValue[value];

  const ConversationType._(super.v, super.n);
}

/// 成员角色枚举，匹配数据库模型中的 MemberRole
class MemberRole extends $pb.ProtobufEnum {
  /// 普通成员
  static const MemberRole MEMBER = MemberRole._(0, _omitEnumNames ? '' : 'MEMBER');
  /// 管理员
  static const MemberRole ADMIN = MemberRole._(1, _omitEnumNames ? '' : 'ADMIN');
  /// 所有者
  static const MemberRole OWNER = MemberRole._(2, _omitEnumNames ? '' : 'OWNER');

  static const $core.List<MemberRole> values = <MemberRole> [
    MEMBER,
    ADMIN,
    OWNER,
  ];

  static final $core.Map<$core.int, MemberRole> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MemberRole? valueOf($core.int value) => _byValue[value];

  const MemberRole._(super.v, super.n);
}

/// 加入请求状态枚举
class JoinRequestStatus extends $pb.ProtobufEnum {
  static const JoinRequestStatus JOIN_PENDING = JoinRequestStatus._(0, _omitEnumNames ? '' : 'JOIN_PENDING');
  static const JoinRequestStatus JOIN_APPROVED = JoinRequestStatus._(1, _omitEnumNames ? '' : 'JOIN_APPROVED');
  static const JoinRequestStatus JOIN_REJECTED = JoinRequestStatus._(2, _omitEnumNames ? '' : 'JOIN_REJECTED');
  static const JoinRequestStatus JOIN_CANCELLED = JoinRequestStatus._(3, _omitEnumNames ? '' : 'JOIN_CANCELLED');

  static const $core.List<JoinRequestStatus> values = <JoinRequestStatus> [
    JOIN_PENDING,
    JOIN_APPROVED,
    JOIN_REJECTED,
    JOIN_CANCELLED,
  ];

  static final $core.Map<$core.int, JoinRequestStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static JoinRequestStatus? valueOf($core.int value) => _byValue[value];

  const JoinRequestStatus._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
