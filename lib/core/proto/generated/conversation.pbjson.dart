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
    {'1': 'channel', '2': 2},
  ],
};

/// Descriptor for `ConversationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List conversationTypeDescriptor = $convert.base64Decode(
    'ChBDb252ZXJzYXRpb25UeXBlEgsKB3ByaXZhdGUQABIJCgVncm91cBABEgsKB2NoYW5uZWwQAg'
    '==');

@$core.Deprecated('Use memberRoleDescriptor instead')
const MemberRole$json = {
  '1': 'MemberRole',
  '2': [
    {'1': 'MEMBER', '2': 0},
    {'1': 'ADMIN', '2': 1},
    {'1': 'OWNER', '2': 2},
  ],
};

/// Descriptor for `MemberRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List memberRoleDescriptor = $convert.base64Decode(
    'CgpNZW1iZXJSb2xlEgoKBk1FTUJFUhAAEgkKBUFETUlOEAESCQoFT1dORVIQAg==');

@$core.Deprecated('Use participantProtoDescriptor instead')
const ParticipantProto$json = {
  '1': 'ParticipantProto',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'unread_count', '3': 4, '4': 1, '5': 5, '10': 'unreadCount'},
    {'1': 'muted', '3': 5, '4': 1, '5': 8, '10': 'muted'},
    {'1': 'pinned', '3': 6, '4': 1, '5': 8, '10': 'pinned'},
    {'1': 'joined_at', '3': 7, '4': 1, '5': 3, '10': 'joinedAt'},
    {'1': 'last_read_at', '3': 8, '4': 1, '5': 3, '10': 'lastReadAt'},
    {'1': 'last_read_message_id', '3': 9, '4': 1, '5': 9, '10': 'lastReadMessageId'},
    {'1': 'role', '3': 10, '4': 1, '5': 14, '6': '.cc.MemberRole', '10': 'role'},
    {'1': 'added_by', '3': 11, '4': 1, '5': 9, '10': 'addedBy'},
    {'1': 'online', '3': 12, '4': 1, '5': 8, '10': 'online'},
    {'1': 'is_active', '3': 13, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

/// Descriptor for `ParticipantProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantProtoDescriptor = $convert.base64Decode(
    'ChBQYXJ0aWNpcGFudFByb3RvEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBISCgRuYW1lGAIgAS'
    'gJUgRuYW1lEhYKBmF2YXRhchgDIAEoCVIGYXZhdGFyEiEKDHVucmVhZF9jb3VudBgEIAEoBVIL'
    'dW5yZWFkQ291bnQSFAoFbXV0ZWQYBSABKAhSBW11dGVkEhYKBnBpbm5lZBgGIAEoCFIGcGlubm'
    'VkEhsKCWpvaW5lZF9hdBgHIAEoA1IIam9pbmVkQXQSIAoMbGFzdF9yZWFkX2F0GAggASgDUgps'
    'YXN0UmVhZEF0Ei8KFGxhc3RfcmVhZF9tZXNzYWdlX2lkGAkgASgJUhFsYXN0UmVhZE1lc3NhZ2'
    'VJZBIiCgRyb2xlGAogASgOMg4uY2MuTWVtYmVyUm9sZVIEcm9sZRIZCghhZGRlZF9ieRgLIAEo'
    'CVIHYWRkZWRCeRIWCgZvbmxpbmUYDCABKAhSBm9ubGluZRIbCglpc19hY3RpdmUYDSABKAhSCG'
    'lzQWN0aXZl');

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
    {'1': 'last_message_name', '3': 8, '4': 1, '5': 9, '10': 'lastMessageName'},
    {'1': 'unread_count', '3': 9, '4': 1, '5': 5, '10': 'unreadCount'},
    {'1': 'contact_user_id', '3': 10, '4': 1, '5': 9, '10': 'contactUserId'},
    {'1': 'participants', '3': 11, '4': 3, '5': 11, '6': '.cc.ParticipantProto', '10': 'participants'},
    {'1': 'muted', '3': 12, '4': 1, '5': 8, '10': 'muted'},
    {'1': 'pinned', '3': 13, '4': 1, '5': 8, '10': 'pinned'},
    {'1': 'created_by', '3': 14, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'last_read_at', '3': 15, '4': 1, '5': 3, '10': 'lastReadAt'},
    {'1': 'last_read_message_id', '3': 16, '4': 1, '5': 9, '10': 'lastReadMessageId'},
  ],
};

/// Descriptor for `ConversationProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationProtoDescriptor = $convert.base64Decode(
    'ChFDb252ZXJzYXRpb25Qcm90bxInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdG'
    'lvbklkEhIKBG5hbWUYAiABKAlSBG5hbWUSFgoGYXZhdGFyGAMgASgJUgZhdmF0YXISKAoEdHlw'
    'ZRgEIAEoDjIULmNjLkNvbnZlcnNhdGlvblR5cGVSBHR5cGUSHQoKY3JlYXRlZF9hdBgFIAEoA1'
    'IJY3JlYXRlZEF0EioKEWxhc3RfbWVzc2FnZV90aW1lGAYgASgDUg9sYXN0TWVzc2FnZVRpbWUS'
    'MAoUbGFzdF9tZXNzYWdlX3ByZXZpZXcYByABKAlSEmxhc3RNZXNzYWdlUHJldmlldxIqChFsYX'
    'N0X21lc3NhZ2VfbmFtZRgIIAEoCVIPbGFzdE1lc3NhZ2VOYW1lEiEKDHVucmVhZF9jb3VudBgJ'
    'IAEoBVILdW5yZWFkQ291bnQSJgoPY29udGFjdF91c2VyX2lkGAogASgJUg1jb250YWN0VXNlck'
    'lkEjgKDHBhcnRpY2lwYW50cxgLIAMoCzIULmNjLlBhcnRpY2lwYW50UHJvdG9SDHBhcnRpY2lw'
    'YW50cxIUCgVtdXRlZBgMIAEoCFIFbXV0ZWQSFgoGcGlubmVkGA0gASgIUgZwaW5uZWQSHQoKY3'
    'JlYXRlZF9ieRgOIAEoCVIJY3JlYXRlZEJ5EiAKDGxhc3RfcmVhZF9hdBgPIAEoA1IKbGFzdFJl'
    'YWRBdBIvChRsYXN0X3JlYWRfbWVzc2FnZV9pZBgQIAEoCVIRbGFzdFJlYWRNZXNzYWdlSWQ=');

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
    {'1': 'last_sync_time', '3': 1, '4': 1, '5': 3, '10': 'lastSyncTime'},
  ],
};

/// Descriptor for `SyncConversationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncConversationsRequestDescriptor = $convert.base64Decode(
    'ChhTeW5jQ29udmVyc2F0aW9uc1JlcXVlc3QSJAoObGFzdF9zeW5jX3RpbWUYASABKANSDGxhc3'
    'RTeW5jVGltZQ==');

@$core.Deprecated('Use conversationUpdateNotificationDescriptor instead')
const ConversationUpdateNotification$json = {
  '1': 'ConversationUpdateNotification',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'last_message_preview', '3': 2, '4': 1, '5': 9, '10': 'lastMessagePreview'},
    {'1': 'last_message_time', '3': 3, '4': 1, '5': 3, '10': 'lastMessageTime'},
    {'1': 'unread_count', '3': 4, '4': 1, '5': 5, '10': 'unreadCount'},
    {'1': 'sender_id', '3': 5, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'sender_name', '3': 6, '4': 1, '5': 9, '10': 'senderName'},
    {'1': 'message_type', '3': 7, '4': 1, '5': 9, '10': 'messageType'},
  ],
};

/// Descriptor for `ConversationUpdateNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationUpdateNotificationDescriptor = $convert.base64Decode(
    'Ch5Db252ZXJzYXRpb25VcGRhdGVOb3RpZmljYXRpb24SJwoPY29udmVyc2F0aW9uX2lkGAEgAS'
    'gJUg5jb252ZXJzYXRpb25JZBIwChRsYXN0X21lc3NhZ2VfcHJldmlldxgCIAEoCVISbGFzdE1l'
    'c3NhZ2VQcmV2aWV3EioKEWxhc3RfbWVzc2FnZV90aW1lGAMgASgDUg9sYXN0TWVzc2FnZVRpbW'
    'USIQoMdW5yZWFkX2NvdW50GAQgASgFUgt1bnJlYWRDb3VudBIbCglzZW5kZXJfaWQYBSABKAlS'
    'CHNlbmRlcklkEh8KC3NlbmRlcl9uYW1lGAYgASgJUgpzZW5kZXJOYW1lEiEKDG1lc3NhZ2VfdH'
    'lwZRgHIAEoCVILbWVzc2FnZVR5cGU=');

@$core.Deprecated('Use conversationSettingsUpdateRequestDescriptor instead')
const ConversationSettingsUpdateRequest$json = {
  '1': 'ConversationSettingsUpdateRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'muted', '3': 2, '4': 1, '5': 8, '9': 0, '10': 'muted', '17': true},
    {'1': 'pinned', '3': 3, '4': 1, '5': 8, '9': 1, '10': 'pinned', '17': true},
  ],
  '8': [
    {'1': '_muted'},
    {'1': '_pinned'},
  ],
};

/// Descriptor for `ConversationSettingsUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationSettingsUpdateRequestDescriptor = $convert.base64Decode(
    'CiFDb252ZXJzYXRpb25TZXR0aW5nc1VwZGF0ZVJlcXVlc3QSJwoPY29udmVyc2F0aW9uX2lkGA'
    'EgASgJUg5jb252ZXJzYXRpb25JZBIZCgVtdXRlZBgCIAEoCEgAUgVtdXRlZIgBARIbCgZwaW5u'
    'ZWQYAyABKAhIAVIGcGlubmVkiAEBQggKBl9tdXRlZEIJCgdfcGlubmVk');

@$core.Deprecated('Use conversationSettingsUpdateResponseDescriptor instead')
const ConversationSettingsUpdateResponse$json = {
  '1': 'ConversationSettingsUpdateResponse',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {'1': 'muted', '3': 3, '4': 1, '5': 8, '9': 0, '10': 'muted', '17': true},
    {'1': 'pinned', '3': 4, '4': 1, '5': 8, '9': 1, '10': 'pinned', '17': true},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '8': [
    {'1': '_muted'},
    {'1': '_pinned'},
  ],
};

/// Descriptor for `ConversationSettingsUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationSettingsUpdateResponseDescriptor = $convert.base64Decode(
    'CiJDb252ZXJzYXRpb25TZXR0aW5nc1VwZGF0ZVJlc3BvbnNlEicKD2NvbnZlcnNhdGlvbl9pZB'
    'gBIAEoCVIOY29udmVyc2F0aW9uSWQSGAoHc3VjY2VzcxgCIAEoCFIHc3VjY2VzcxIZCgVtdXRl'
    'ZBgDIAEoCEgAUgVtdXRlZIgBARIbCgZwaW5uZWQYBCABKAhIAVIGcGlubmVkiAEBEhwKCXRpbW'
    'VzdGFtcBgFIAEoA1IJdGltZXN0YW1wQggKBl9tdXRlZEIJCgdfcGlubmVk');

@$core.Deprecated('Use conversationJoinLeaveRequestDescriptor instead')
const ConversationJoinLeaveRequest$json = {
  '1': 'ConversationJoinLeaveRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ConversationJoinLeaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationJoinLeaveRequestDescriptor = $convert.base64Decode(
    'ChxDb252ZXJzYXRpb25Kb2luTGVhdmVSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCV'
    'IOY29udmVyc2F0aW9uSWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use conversationCreateRequestDescriptor instead')
const ConversationCreateRequest$json = {
  '1': 'ConversationCreateRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 2, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'type', '3': 3, '4': 1, '5': 14, '6': '.cc.ConversationType', '10': 'type'},
    {'1': 'participant_ids', '3': 4, '4': 3, '5': 9, '10': 'participantIds'},
    {'1': 'contact_user_id', '3': 5, '4': 1, '5': 9, '10': 'contactUserId'},
  ],
};

/// Descriptor for `ConversationCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationCreateRequestDescriptor = $convert.base64Decode(
    'ChlDb252ZXJzYXRpb25DcmVhdGVSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSFgoGYXZhdG'
    'FyGAIgASgJUgZhdmF0YXISKAoEdHlwZRgDIAEoDjIULmNjLkNvbnZlcnNhdGlvblR5cGVSBHR5'
    'cGUSJwoPcGFydGljaXBhbnRfaWRzGAQgAygJUg5wYXJ0aWNpcGFudElkcxImCg9jb250YWN0X3'
    'VzZXJfaWQYBSABKAlSDWNvbnRhY3RVc2VySWQ=');

@$core.Deprecated('Use userJoinedNotificationDescriptor instead')
const UserJoinedNotification$json = {
  '1': 'UserJoinedNotification',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'user_name', '3': 3, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'user_avatar', '3': 4, '4': 1, '5': 9, '10': 'userAvatar'},
    {'1': 'joined_at', '3': 5, '4': 1, '5': 3, '10': 'joinedAt'},
    {'1': 'joined_by', '3': 6, '4': 1, '5': 9, '10': 'joinedBy'},
  ],
};

/// Descriptor for `UserJoinedNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userJoinedNotificationDescriptor = $convert.base64Decode(
    'ChZVc2VySm9pbmVkTm90aWZpY2F0aW9uEicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udm'
    'Vyc2F0aW9uSWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklkEhsKCXVzZXJfbmFtZRgDIAEoCVII'
    'dXNlck5hbWUSHwoLdXNlcl9hdmF0YXIYBCABKAlSCnVzZXJBdmF0YXISGwoJam9pbmVkX2F0GA'
    'UgASgDUghqb2luZWRBdBIbCglqb2luZWRfYnkYBiABKAlSCGpvaW5lZEJ5');

@$core.Deprecated('Use userLeftNotificationDescriptor instead')
const UserLeftNotification$json = {
  '1': 'UserLeftNotification',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'user_name', '3': 3, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'left_at', '3': 4, '4': 1, '5': 3, '10': 'leftAt'},
    {'1': 'reason', '3': 5, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `UserLeftNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userLeftNotificationDescriptor = $convert.base64Decode(
    'ChRVc2VyTGVmdE5vdGlmaWNhdGlvbhInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcn'
    'NhdGlvbklkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIbCgl1c2VyX25hbWUYAyABKAlSCHVz'
    'ZXJOYW1lEhcKB2xlZnRfYXQYBCABKANSBmxlZnRBdBIWCgZyZWFzb24YBSABKAlSBnJlYXNvbg'
    '==');

@$core.Deprecated('Use conversationCreateResponseDescriptor instead')
const ConversationCreateResponse$json = {
  '1': 'ConversationCreateResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'conversation', '3': 3, '4': 1, '5': 11, '6': '.cc.ConversationProto', '10': 'conversation'},
  ],
};

/// Descriptor for `ConversationCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationCreateResponseDescriptor = $convert.base64Decode(
    'ChpDb252ZXJzYXRpb25DcmVhdGVSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEh'
    'gKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USOQoMY29udmVyc2F0aW9uGAMgASgLMhUuY2MuQ29u'
    'dmVyc2F0aW9uUHJvdG9SDGNvbnZlcnNhdGlvbg==');

@$core.Deprecated('Use conversationMarkReadRequestDescriptor instead')
const ConversationMarkReadRequest$json = {
  '1': 'ConversationMarkReadRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'read_at', '3': 3, '4': 1, '5': 3, '10': 'readAt'},
    {'1': 'message_id', '3': 4, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `ConversationMarkReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMarkReadRequestDescriptor = $convert.base64Decode(
    'ChtDb252ZXJzYXRpb25NYXJrUmVhZFJlcXVlc3QSJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg'
    '5jb252ZXJzYXRpb25JZBIXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSFwoHcmVhZF9hdBgDIAEo'
    'A1IGcmVhZEF0Eh0KCm1lc3NhZ2VfaWQYBCABKAlSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use conversationMarkReadResponseDescriptor instead')
const ConversationMarkReadResponse$json = {
  '1': 'ConversationMarkReadResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'remaining_unread', '3': 3, '4': 1, '5': 5, '10': 'remainingUnread'},
    {'1': 'read_at', '3': 4, '4': 1, '5': 3, '10': 'readAt'},
  ],
};

/// Descriptor for `ConversationMarkReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMarkReadResponseDescriptor = $convert.base64Decode(
    'ChxDb252ZXJzYXRpb25NYXJrUmVhZFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3'
    'MSJwoPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIpChByZW1haW5pbmdf'
    'dW5yZWFkGAMgASgFUg9yZW1haW5pbmdVbnJlYWQSFwoHcmVhZF9hdBgEIAEoA1IGcmVhZEF0');

@$core.Deprecated('Use conversationUpdateRequestDescriptor instead')
const ConversationUpdateRequest$json = {
  '1': 'ConversationUpdateRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'avatar', '17': true},
  ],
  '8': [
    {'1': '_name'},
    {'1': '_avatar'},
  ],
};

/// Descriptor for `ConversationUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationUpdateRequestDescriptor = $convert.base64Decode(
    'ChlDb252ZXJzYXRpb25VcGRhdGVSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY2'
    '9udmVyc2F0aW9uSWQSFwoEbmFtZRgCIAEoCUgAUgRuYW1liAEBEhsKBmF2YXRhchgDIAEoCUgB'
    'UgZhdmF0YXKIAQFCBwoFX25hbWVCCQoHX2F2YXRhcg==');

@$core.Deprecated('Use conversationMemberRequestDescriptor instead')
const ConversationMemberRequest$json = {
  '1': 'ConversationMemberRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
  ],
};

/// Descriptor for `ConversationMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMemberRequestDescriptor = $convert.base64Decode(
    'ChlDb252ZXJzYXRpb25NZW1iZXJSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY2'
    '9udmVyc2F0aW9uSWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklkEhYKBmFjdGlvbhgDIAEoCVIG'
    'YWN0aW9u');

@$core.Deprecated('Use conversationMembersResponseDescriptor instead')
const ConversationMembersResponse$json = {
  '1': 'ConversationMembersResponse',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'members', '3': 2, '4': 3, '5': 11, '6': '.cc.ParticipantProto', '10': 'members'},
  ],
};

/// Descriptor for `ConversationMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMembersResponseDescriptor = $convert.base64Decode(
    'ChtDb252ZXJzYXRpb25NZW1iZXJzUmVzcG9uc2USJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg'
    '5jb252ZXJzYXRpb25JZBIuCgdtZW1iZXJzGAIgAygLMhQuY2MuUGFydGljaXBhbnRQcm90b1IH'
    'bWVtYmVycw==');

@$core.Deprecated('Use conversationMemberChangeNotificationDescriptor instead')
const ConversationMemberChangeNotification$json = {
  '1': 'ConversationMemberChangeNotification',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'member', '3': 2, '4': 1, '5': 11, '6': '.cc.ParticipantProto', '10': 'member'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
    {'1': 'action_by', '3': 4, '4': 1, '5': 9, '10': 'actionBy'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `ConversationMemberChangeNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMemberChangeNotificationDescriptor = $convert.base64Decode(
    'CiRDb252ZXJzYXRpb25NZW1iZXJDaGFuZ2VOb3RpZmljYXRpb24SJwoPY29udmVyc2F0aW9uX2'
    'lkGAEgASgJUg5jb252ZXJzYXRpb25JZBIsCgZtZW1iZXIYAiABKAsyFC5jYy5QYXJ0aWNpcGFu'
    'dFByb3RvUgZtZW1iZXISFgoGYWN0aW9uGAMgASgJUgZhY3Rpb24SGwoJYWN0aW9uX2J5GAQgAS'
    'gJUghhY3Rpb25CeRIcCgl0aW1lc3RhbXAYBSABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use conversationMembersRequestDescriptor instead')
const ConversationMembersRequest$json = {
  '1': 'ConversationMembersRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `ConversationMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMembersRequestDescriptor = $convert.base64Decode(
    'ChpDb252ZXJzYXRpb25NZW1iZXJzUmVxdWVzdBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDm'
    'NvbnZlcnNhdGlvbklk');

