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

/// 系统事件类型枚举
class SystemEventType extends $pb.ProtobufEnum {
  /// 会话管理事件
  static const SystemEventType CONVERSATION_CREATED = SystemEventType._(0, _omitEnumNames ? '' : 'CONVERSATION_CREATED');
  static const SystemEventType CONVERSATION_DELETED = SystemEventType._(1, _omitEnumNames ? '' : 'CONVERSATION_DELETED');
  static const SystemEventType CONVERSATION_ARCHIVED = SystemEventType._(2, _omitEnumNames ? '' : 'CONVERSATION_ARCHIVED');
  static const SystemEventType CONVERSATION_UNARCHIVED = SystemEventType._(3, _omitEnumNames ? '' : 'CONVERSATION_UNARCHIVED');
  /// 成员管理事件
  static const SystemEventType MEMBER_JOINED = SystemEventType._(10, _omitEnumNames ? '' : 'MEMBER_JOINED');
  static const SystemEventType MEMBER_LEFT = SystemEventType._(11, _omitEnumNames ? '' : 'MEMBER_LEFT');
  static const SystemEventType MEMBER_REMOVED = SystemEventType._(12, _omitEnumNames ? '' : 'MEMBER_REMOVED');
  static const SystemEventType MEMBER_PROMOTED = SystemEventType._(13, _omitEnumNames ? '' : 'MEMBER_PROMOTED');
  static const SystemEventType MEMBER_DEMOTED = SystemEventType._(14, _omitEnumNames ? '' : 'MEMBER_DEMOTED');
  static const SystemEventType MEMBER_ROLE_CHANGED = SystemEventType._(15, _omitEnumNames ? '' : 'MEMBER_ROLE_CHANGED');
  /// 会话设置事件
  static const SystemEventType CONVERSATION_NAME_CHANGED = SystemEventType._(20, _omitEnumNames ? '' : 'CONVERSATION_NAME_CHANGED');
  static const SystemEventType CONVERSATION_AVATAR_CHANGED = SystemEventType._(21, _omitEnumNames ? '' : 'CONVERSATION_AVATAR_CHANGED');
  static const SystemEventType CONVERSATION_DESCRIPTION_CHANGED = SystemEventType._(22, _omitEnumNames ? '' : 'CONVERSATION_DESCRIPTION_CHANGED');
  static const SystemEventType CONVERSATION_SETTINGS_CHANGED = SystemEventType._(23, _omitEnumNames ? '' : 'CONVERSATION_SETTINGS_CHANGED');
  /// 权限事件
  static const SystemEventType PERMISSIONS_CHANGED = SystemEventType._(30, _omitEnumNames ? '' : 'PERMISSIONS_CHANGED');
  static const SystemEventType MUTE_SETTINGS_CHANGED = SystemEventType._(31, _omitEnumNames ? '' : 'MUTE_SETTINGS_CHANGED');
  /// 消息管理事件
  static const SystemEventType MESSAGE_PINNED = SystemEventType._(40, _omitEnumNames ? '' : 'MESSAGE_PINNED');
  static const SystemEventType MESSAGE_UNPINNED = SystemEventType._(41, _omitEnumNames ? '' : 'MESSAGE_UNPINNED');
  static const SystemEventType MESSAGES_CLEARED = SystemEventType._(42, _omitEnumNames ? '' : 'MESSAGES_CLEARED');
  /// 安全事件
  static const SystemEventType ENCRYPTION_ENABLED = SystemEventType._(50, _omitEnumNames ? '' : 'ENCRYPTION_ENABLED');
  static const SystemEventType ENCRYPTION_DISABLED = SystemEventType._(51, _omitEnumNames ? '' : 'ENCRYPTION_DISABLED');
  /// 其他事件
  static const SystemEventType CUSTOM_EVENT = SystemEventType._(99, _omitEnumNames ? '' : 'CUSTOM_EVENT');

  static const $core.List<SystemEventType> values = <SystemEventType> [
    CONVERSATION_CREATED,
    CONVERSATION_DELETED,
    CONVERSATION_ARCHIVED,
    CONVERSATION_UNARCHIVED,
    MEMBER_JOINED,
    MEMBER_LEFT,
    MEMBER_REMOVED,
    MEMBER_PROMOTED,
    MEMBER_DEMOTED,
    MEMBER_ROLE_CHANGED,
    CONVERSATION_NAME_CHANGED,
    CONVERSATION_AVATAR_CHANGED,
    CONVERSATION_DESCRIPTION_CHANGED,
    CONVERSATION_SETTINGS_CHANGED,
    PERMISSIONS_CHANGED,
    MUTE_SETTINGS_CHANGED,
    MESSAGE_PINNED,
    MESSAGE_UNPINNED,
    MESSAGES_CLEARED,
    ENCRYPTION_ENABLED,
    ENCRYPTION_DISABLED,
    CUSTOM_EVENT,
  ];

  static final $core.Map<$core.int, SystemEventType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SystemEventType? valueOf($core.int value) => _byValue[value];

  const SystemEventType._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
