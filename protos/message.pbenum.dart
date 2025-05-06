//
//  Generated code. Do not modify.
//  source: protos/message.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 消息类型枚举 - 与数据库模型完全匹配
class MessageType extends $pb.ProtobufEnum {
  static const MessageType text = MessageType._(0, _omitEnumNames ? '' : 'text');
  static const MessageType image = MessageType._(1, _omitEnumNames ? '' : 'image');
  static const MessageType voice = MessageType._(2, _omitEnumNames ? '' : 'voice');
  static const MessageType file = MessageType._(3, _omitEnumNames ? '' : 'file');
  static const MessageType video = MessageType._(4, _omitEnumNames ? '' : 'video');
  static const MessageType location = MessageType._(5, _omitEnumNames ? '' : 'location');
  static const MessageType system = MessageType._(6, _omitEnumNames ? '' : 'system');

  static const $core.List<MessageType> values = <MessageType> [
    text,
    image,
    voice,
    file,
    video,
    location,
    system,
  ];

  static final $core.Map<$core.int, MessageType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageType? valueOf($core.int value) => _byValue[value];

  const MessageType._($core.int v, $core.String n) : super(v, n);
}

/// 消息状态枚举
class MessageStatus extends $pb.ProtobufEnum {
  static const MessageStatus sending = MessageStatus._(0, _omitEnumNames ? '' : 'sending');
  static const MessageStatus sent = MessageStatus._(1, _omitEnumNames ? '' : 'sent');
  static const MessageStatus delivered = MessageStatus._(2, _omitEnumNames ? '' : 'delivered');
  static const MessageStatus read = MessageStatus._(3, _omitEnumNames ? '' : 'read');
  static const MessageStatus failed = MessageStatus._(4, _omitEnumNames ? '' : 'failed');

  static const $core.List<MessageStatus> values = <MessageStatus> [
    sending,
    sent,
    delivered,
    read,
    failed,
  ];

  static final $core.Map<$core.int, MessageStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageStatus? valueOf($core.int value) => _byValue[value];

  const MessageStatus._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
