//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userStatusDescriptor instead')
const UserStatus$json = {
  '1': 'UserStatus',
  '2': [
    {'1': 'offline', '2': 0},
    {'1': 'online', '2': 1},
    {'1': 'away', '2': 2},
  ],
};

/// Descriptor for `UserStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userStatusDescriptor = $convert.base64Decode(
    'CgpVc2VyU3RhdHVzEgsKB29mZmxpbmUQABIKCgZvbmxpbmUQARIICgRhd2F5EAI=');

@$core.Deprecated('Use userProtoDescriptor instead')
const UserProto$json = {
  '1': 'UserProto',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'email', '3': 5, '4': 1, '5': 9, '10': 'email'},
    {'1': 'pinyin', '3': 6, '4': 1, '5': 9, '10': 'pinyin'},
    {'1': 'last_active_time', '3': 7, '4': 1, '5': 3, '10': 'lastActiveTime'},
    {'1': 'is_friend', '3': 8, '4': 1, '5': 8, '10': 'isFriend'},
    {'1': 'status', '3': 9, '4': 1, '5': 9, '10': 'status'},
    {'1': 'username', '3': 10, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 11, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'is_typing', '3': 12, '4': 1, '5': 8, '10': 'isTyping'},
    {'1': 'typing_in_conversation', '3': 13, '4': 1, '5': 9, '10': 'typingInConversation'},
  ],
};

/// Descriptor for `UserProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userProtoDescriptor = $convert.base64Decode(
    'CglVc2VyUHJvdG8SFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhIKBG5hbWUYAiABKAlSBG5hbW'
    'USFgoGYXZhdGFyGAMgASgJUgZhdmF0YXISFAoFcGhvbmUYBCABKAlSBXBob25lEhQKBWVtYWls'
    'GAUgASgJUgVlbWFpbBIWCgZwaW55aW4YBiABKAlSBnBpbnlpbhIoChBsYXN0X2FjdGl2ZV90aW'
    '1lGAcgASgDUg5sYXN0QWN0aXZlVGltZRIbCglpc19mcmllbmQYCCABKAhSCGlzRnJpZW5kEhYK'
    'BnN0YXR1cxgJIAEoCVIGc3RhdHVzEhoKCHVzZXJuYW1lGAogASgJUgh1c2VybmFtZRIhCgxkaX'
    'NwbGF5X25hbWUYCyABKAlSC2Rpc3BsYXlOYW1lEhsKCWlzX3R5cGluZxgMIAEoCFIIaXNUeXBp'
    'bmcSNAoWdHlwaW5nX2luX2NvbnZlcnNhdGlvbhgNIAEoCVIUdHlwaW5nSW5Db252ZXJzYXRpb2'
    '4=');

@$core.Deprecated('Use userStatusUpdateDescriptor instead')
const UserStatusUpdate$json = {
  '1': 'UserStatusUpdate',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UserStatusUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userStatusUpdateDescriptor = $convert.base64Decode(
    'ChBVc2VyU3RhdHVzVXBkYXRlEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIWCgZzdGF0dXMYAi'
    'ABKAlSBnN0YXR1cxIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use userTypingUpdateDescriptor instead')
const UserTypingUpdate$json = {
  '1': 'UserTypingUpdate',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UserTypingUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userTypingUpdateDescriptor = $convert.base64Decode(
    'ChBVc2VyVHlwaW5nVXBkYXRlEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBInCg9jb252ZXJzYX'
    'Rpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklkEhsKCWlzX3R5cGluZxgDIAEoCFIIaXNUeXBp'
    'bmcSHAoJdGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use userResponseDescriptor instead')
const UserResponse$json = {
  '1': 'UserResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.cc.UserProto', '10': 'user'},
  ],
};

/// Descriptor for `UserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userResponseDescriptor = $convert.base64Decode(
    'CgxVc2VyUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdlEiEKBHVzZXIYAyABKAsyDS5jYy5Vc2VyUHJvdG9SBHVzZXI=');

@$core.Deprecated('Use userCollectionDescriptor instead')
const UserCollection$json = {
  '1': 'UserCollection',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.cc.UserProto', '10': 'users'},
  ],
};

/// Descriptor for `UserCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userCollectionDescriptor = $convert.base64Decode(
    'Cg5Vc2VyQ29sbGVjdGlvbhIjCgV1c2VycxgBIAMoCzINLmNjLlVzZXJQcm90b1IFdXNlcnM=');

