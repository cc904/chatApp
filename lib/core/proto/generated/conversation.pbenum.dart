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
  static const ConversationType private = ConversationType._(0, _omitEnumNames ? '' : 'private');
  static const ConversationType group = ConversationType._(1, _omitEnumNames ? '' : 'group');
  static const ConversationType channel = ConversationType._(2, _omitEnumNames ? '' : 'channel');

  static const $core.List<ConversationType> values = <ConversationType> [
    private,
    group,
    channel,
  ];

  static final $core.Map<$core.int, ConversationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ConversationType? valueOf($core.int value) => _byValue[value];

  const ConversationType._(super.v, super.n);
}

/// 新增：会话成员角色
class MemberRole extends $pb.ProtobufEnum {
  static const MemberRole member = MemberRole._(0, _omitEnumNames ? '' : 'member');
  static const MemberRole admin = MemberRole._(1, _omitEnumNames ? '' : 'admin');
  static const MemberRole owner = MemberRole._(2, _omitEnumNames ? '' : 'owner');

  static const $core.List<MemberRole> values = <MemberRole> [
    member,
    admin,
    owner,
  ];

  static final $core.Map<$core.int, MemberRole> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MemberRole? valueOf($core.int value) => _byValue[value];

  const MemberRole._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
