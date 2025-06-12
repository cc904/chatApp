//
//  Generated code. Do not modify.
//  source: message.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 消息类型枚举
class MessageType extends $pb.ProtobufEnum {
  static const MessageType TEXT = MessageType._(0, _omitEnumNames ? '' : 'TEXT');
  static const MessageType IMAGE = MessageType._(1, _omitEnumNames ? '' : 'IMAGE');
  static const MessageType VOICE = MessageType._(2, _omitEnumNames ? '' : 'VOICE');
  static const MessageType FILE = MessageType._(3, _omitEnumNames ? '' : 'FILE');
  static const MessageType VIDEO = MessageType._(4, _omitEnumNames ? '' : 'VIDEO');
  static const MessageType SYSTEM = MessageType._(6, _omitEnumNames ? '' : 'SYSTEM');

  static const $core.List<MessageType> values = <MessageType> [
    TEXT,
    IMAGE,
    VOICE,
    FILE,
    VIDEO,
    SYSTEM,
  ];

  static final $core.Map<$core.int, MessageType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageType? valueOf($core.int value) => _byValue[value];

  const MessageType._(super.v, super.n);
}

/// 消息状态枚举
class MessageStatus extends $pb.ProtobufEnum {
  static const MessageStatus SENDING = MessageStatus._(0, _omitEnumNames ? '' : 'SENDING');
  static const MessageStatus SENT = MessageStatus._(1, _omitEnumNames ? '' : 'SENT');
  static const MessageStatus DELIVERED = MessageStatus._(2, _omitEnumNames ? '' : 'DELIVERED');
  static const MessageStatus READ = MessageStatus._(3, _omitEnumNames ? '' : 'READ');
  static const MessageStatus FAILED = MessageStatus._(4, _omitEnumNames ? '' : 'FAILED');
  static const MessageStatus DELETED = MessageStatus._(5, _omitEnumNames ? '' : 'DELETED');
  static const MessageStatus REVOKED = MessageStatus._(6, _omitEnumNames ? '' : 'REVOKED');

  static const $core.List<MessageStatus> values = <MessageStatus> [
    SENDING,
    SENT,
    DELIVERED,
    READ,
    FAILED,
    DELETED,
    REVOKED,
  ];

  static final $core.Map<$core.int, MessageStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageStatus? valueOf($core.int value) => _byValue[value];

  const MessageStatus._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
