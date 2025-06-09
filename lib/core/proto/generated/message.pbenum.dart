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
  static const MessageType LOCATION = MessageType._(5, _omitEnumNames ? '' : 'LOCATION');
  static const MessageType SYSTEM = MessageType._(6, _omitEnumNames ? '' : 'SYSTEM');
  static const MessageType STICKER = MessageType._(7, _omitEnumNames ? '' : 'STICKER');
  static const MessageType GIF = MessageType._(8, _omitEnumNames ? '' : 'GIF');
  static const MessageType CONTACT = MessageType._(9, _omitEnumNames ? '' : 'CONTACT');
  static const MessageType POLL = MessageType._(10, _omitEnumNames ? '' : 'POLL');
  static const MessageType LINK = MessageType._(11, _omitEnumNames ? '' : 'LINK');

  static const $core.List<MessageType> values = <MessageType> [
    TEXT,
    IMAGE,
    VOICE,
    FILE,
    VIDEO,
    LOCATION,
    SYSTEM,
    STICKER,
    GIF,
    CONTACT,
    POLL,
    LINK,
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

  static const $core.List<MessageStatus> values = <MessageStatus> [
    SENDING,
    SENT,
    DELIVERED,
    READ,
    FAILED,
  ];

  static final $core.Map<$core.int, MessageStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageStatus? valueOf($core.int value) => _byValue[value];

  const MessageStatus._(super.v, super.n);
}

/// 消息同步策略枚举 - 新的双向游标同步模式
class MessageSyncType extends $pb.ProtobufEnum {
  static const MessageSyncType CURSOR_FORWARD = MessageSyncType._(0, _omitEnumNames ? '' : 'CURSOR_FORWARD');
  static const MessageSyncType CURSOR_BACKWARD = MessageSyncType._(1, _omitEnumNames ? '' : 'CURSOR_BACKWARD');
  static const MessageSyncType CURSOR_AROUND = MessageSyncType._(2, _omitEnumNames ? '' : 'CURSOR_AROUND');
  static const MessageSyncType INITIAL_LOAD = MessageSyncType._(3, _omitEnumNames ? '' : 'INITIAL_LOAD');
  /// 保留旧的类型以兼容现有代码
  static const MessageSyncType RECENT = MessageSyncType._(4, _omitEnumNames ? '' : 'RECENT');
  static const MessageSyncType UNREAD = MessageSyncType._(5, _omitEnumNames ? '' : 'UNREAD');

  static const $core.List<MessageSyncType> values = <MessageSyncType> [
    CURSOR_FORWARD,
    CURSOR_BACKWARD,
    CURSOR_AROUND,
    INITIAL_LOAD,
    RECENT,
    UNREAD,
  ];

  static final $core.Map<$core.int, MessageSyncType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageSyncType? valueOf($core.int value) => _byValue[value];

  const MessageSyncType._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
