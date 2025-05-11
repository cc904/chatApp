//
//  Generated code. Do not modify.
//  source: conversation.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use conversationTypeDescriptor instead')
const ConversationType$json = {
  '1': 'ConversationType',
  '2': [
    {'1': 'private', '2': 0},
    {'1': 'group', '2': 1},
  ],
};

/// Descriptor for `ConversationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List conversationTypeDescriptor = $convert.base64Decode(
    'ChBDb252ZXJzYXRpb25UeXBlEgsKB3ByaXZhdGUQABIJCgVncm91cBAB');

@$core.Deprecated('Use conversationProtoDescriptor instead')
const ConversationProto$json = {
  '1': 'ConversationProto',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'type', '3': 4, '4': 1, '5': 14, '6': '.cc.ConversationType', '10': 'type'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'last_message_time', '3': 6, '4': 1, '5': 3, '10': 'lastMessageTime'},
    {'1': 'last_message_preview', '3': 7, '4': 1, '5': 9, '10': 'lastMessagePreview'},
    {'1': 'unread_count', '3': 8, '4': 1, '5': 5, '10': 'unreadCount'},
    {'1': 'contact_user_id', '3': 9, '4': 1, '5': 9, '10': 'contactUserId'},
    {'1': 'participant_ids', '3': 10, '4': 3, '5': 9, '10': 'participantIds'},
    {'1': 'updated_at', '3': 11, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'last_message_id', '3': 12, '4': 1, '5': 9, '10': 'lastMessageId'},
    {'1': 'muted', '3': 13, '4': 1, '5': 8, '10': 'muted'},
    {'1': 'pinned', '3': 14, '4': 1, '5': 8, '10': 'pinned'},
    {'1': 'created_by', '3': 15, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'last_message', '3': 16, '4': 1, '5': 11, '6': '.cc.MessageProto', '10': 'lastMessage'},
  ],
};

/// Descriptor for `ConversationProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationProtoDescriptor = $convert.base64Decode(
    'ChFDb252ZXJzYXRpb25Qcm90bxInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdG'
    'lvbklkEhIKBG5hbWUYAiABKAlSBG5hbWUSFgoGYXZhdGFyGAMgASgJUgZhdmF0YXISKAoEdHlw'
    'ZRgEIAEoDjIULmNjLkNvbnZlcnNhdGlvblR5cGVSBHR5cGUSHQoKY3JlYXRlZF9hdBgFIAEoA1'
    'IJY3JlYXRlZEF0EioKEWxhc3RfbWVzc2FnZV90aW1lGAYgASgDUg9sYXN0TWVzc2FnZVRpbWUS'
    'MAoUbGFzdF9tZXNzYWdlX3ByZXZpZXcYByABKAlSEmxhc3RNZXNzYWdlUHJldmlldxIhCgx1bn'
    'JlYWRfY291bnQYCCABKAVSC3VucmVhZENvdW50EiYKD2NvbnRhY3RfdXNlcl9pZBgJIAEoCVIN'
    'Y29udGFjdFVzZXJJZBInCg9wYXJ0aWNpcGFudF9pZHMYCiADKAlSDnBhcnRpY2lwYW50SWRzEh'
    '0KCnVwZGF0ZWRfYXQYCyABKANSCXVwZGF0ZWRBdBImCg9sYXN0X21lc3NhZ2VfaWQYDCABKAlS'
    'DWxhc3RNZXNzYWdlSWQSFAoFbXV0ZWQYDSABKAhSBW11dGVkEhYKBnBpbm5lZBgOIAEoCFIGcG'
    'lubmVkEh0KCmNyZWF0ZWRfYnkYDyABKAlSCWNyZWF0ZWRCeRIzCgxsYXN0X21lc3NhZ2UYECAB'
    'KAsyEC5jYy5NZXNzYWdlUHJvdG9SC2xhc3RNZXNzYWdl');

@$core.Deprecated('Use conversationUpdateDescriptor instead')
const ConversationUpdate$json = {
  '1': 'ConversationUpdate',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'participant_ids', '3': 4, '4': 3, '5': 9, '10': 'participantIds'},
    {'1': 'updated_at', '3': 5, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'updated_by', '3': 6, '4': 1, '5': 9, '10': 'updatedBy'},
    {'1': 'action', '3': 7, '4': 1, '5': 9, '10': 'action'},
  ],
};

/// Descriptor for `ConversationUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationUpdateDescriptor = $convert.base64Decode(
    'ChJDb252ZXJzYXRpb25VcGRhdGUSJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb252ZXJzYX'
    'Rpb25JZBISCgRuYW1lGAIgASgJUgRuYW1lEhYKBmF2YXRhchgDIAEoCVIGYXZhdGFyEicKD3Bh'
    'cnRpY2lwYW50X2lkcxgEIAMoCVIOcGFydGljaXBhbnRJZHMSHQoKdXBkYXRlZF9hdBgFIAEoA1'
    'IJdXBkYXRlZEF0Eh0KCnVwZGF0ZWRfYnkYBiABKAlSCXVwZGF0ZWRCeRIWCgZhY3Rpb24YByAB'
    'KAlSBmFjdGlvbg==');

@$core.Deprecated('Use conversationResponseDescriptor instead')
const ConversationResponse$json = {
  '1': 'ConversationResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'conversation', '3': 3, '4': 1, '5': 11, '6': '.cc.ConversationProto', '10': 'conversation'},
  ],
};

/// Descriptor for `ConversationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationResponseDescriptor = $convert.base64Decode(
    'ChRDb252ZXJzYXRpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3'
    'NhZ2UYAiABKAlSB21lc3NhZ2USOQoMY29udmVyc2F0aW9uGAMgASgLMhUuY2MuQ29udmVyc2F0'
    'aW9uUHJvdG9SDGNvbnZlcnNhdGlvbg==');

@$core.Deprecated('Use conversationCollectionDescriptor instead')
const ConversationCollection$json = {
  '1': 'ConversationCollection',
  '2': [
    {'1': 'conversations', '3': 1, '4': 3, '5': 11, '6': '.cc.ConversationProto', '10': 'conversations'},
  ],
};

/// Descriptor for `ConversationCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationCollectionDescriptor = $convert.base64Decode(
    'ChZDb252ZXJzYXRpb25Db2xsZWN0aW9uEjsKDWNvbnZlcnNhdGlvbnMYASADKAsyFS5jYy5Db2'
    '52ZXJzYXRpb25Qcm90b1INY29udmVyc2F0aW9ucw==');

@$core.Deprecated('Use syncConversationsRequestDescriptor instead')
const SyncConversationsRequest$json = {
  '1': 'SyncConversationsRequest',
  '2': [
    {'1': 'local_conversation_ids', '3': 1, '4': 3, '5': 9, '10': 'localConversationIds'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `SyncConversationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncConversationsRequestDescriptor = $convert.base64Decode(
    'ChhTeW5jQ29udmVyc2F0aW9uc1JlcXVlc3QSNAoWbG9jYWxfY29udmVyc2F0aW9uX2lkcxgBIA'
    'MoCVIUbG9jYWxDb252ZXJzYXRpb25JZHMSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklk');

