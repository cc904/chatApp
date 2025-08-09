// This is a generated file - do not edit.
//
// Generated from conversation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use conversationTypeDescriptor instead')
const ConversationType$json = {
  '1': 'ConversationType',
  '2': [
    {'1': 'PRIVATE', '2': 0},
    {'1': 'GROUP', '2': 1},
    {'1': 'CHANNEL', '2': 2},
  ],
};

/// Descriptor for `ConversationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List conversationTypeDescriptor = $convert.base64Decode(
    'ChBDb252ZXJzYXRpb25UeXBlEgsKB1BSSVZBVEUQABIJCgVHUk9VUBABEgsKB0NIQU5ORUwQAg'
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

@$core.Deprecated('Use joinRequestStatusDescriptor instead')
const JoinRequestStatus$json = {
  '1': 'JoinRequestStatus',
  '2': [
    {'1': 'JOIN_PENDING', '2': 0},
    {'1': 'JOIN_APPROVED', '2': 1},
    {'1': 'JOIN_REJECTED', '2': 2},
    {'1': 'JOIN_CANCELLED', '2': 3},
  ],
};

/// Descriptor for `JoinRequestStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List joinRequestStatusDescriptor = $convert.base64Decode(
    'ChFKb2luUmVxdWVzdFN0YXR1cxIQCgxKT0lOX1BFTkRJTkcQABIRCg1KT0lOX0FQUFJPVkVEEA'
    'ESEQoNSk9JTl9SRUpFQ1RFRBACEhIKDkpPSU5fQ0FOQ0VMTEVEEAM=');

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
    {
      '1': 'delivered_message_index',
      '3': 8,
      '4': 1,
      '5': 5,
      '10': 'deliveredMessageIndex'
    },
    {
      '1': 'read_message_index',
      '3': 9,
      '4': 1,
      '5': 5,
      '10': 'readMessageIndex'
    },
    {
      '1': 'role',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.cc.MemberRole',
      '10': 'role'
    },
    {'1': 'added_by', '3': 11, '4': 1, '5': 9, '10': 'addedBy'},
    {'1': 'online', '3': 12, '4': 1, '5': 8, '10': 'online'},
    {'1': 'is_active', '3': 13, '4': 1, '5': 8, '10': 'isActive'},
    {'1': 'role_id', '3': 14, '4': 1, '5': 5, '10': 'roleId'},
  ],
};

/// Descriptor for `ParticipantProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantProtoDescriptor = $convert.base64Decode(
    'ChBQYXJ0aWNpcGFudFByb3RvEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBISCgRuYW1lGAIgAS'
    'gJUgRuYW1lEhYKBmF2YXRhchgDIAEoCVIGYXZhdGFyEiEKDHVucmVhZF9jb3VudBgEIAEoBVIL'
    'dW5yZWFkQ291bnQSFAoFbXV0ZWQYBSABKAhSBW11dGVkEhYKBnBpbm5lZBgGIAEoCFIGcGlubm'
    'VkEhsKCWpvaW5lZF9hdBgHIAEoA1IIam9pbmVkQXQSNgoXZGVsaXZlcmVkX21lc3NhZ2VfaW5k'
    'ZXgYCCABKAVSFWRlbGl2ZXJlZE1lc3NhZ2VJbmRleBIsChJyZWFkX21lc3NhZ2VfaW5kZXgYCS'
    'ABKAVSEHJlYWRNZXNzYWdlSW5kZXgSIgoEcm9sZRgKIAEoDjIOLmNjLk1lbWJlclJvbGVSBHJv'
    'bGUSGQoIYWRkZWRfYnkYCyABKAlSB2FkZGVkQnkSFgoGb25saW5lGAwgASgIUgZvbmxpbmUSGw'
    'oJaXNfYWN0aXZlGA0gASgIUghpc0FjdGl2ZRIXCgdyb2xlX2lkGA4gASgFUgZyb2xlSWQ=');

@$core.Deprecated('Use conversationProtoDescriptor instead')
const ConversationProto$json = {
  '1': 'ConversationProto',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.cc.ConversationType',
      '10': 'type'
    },
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 4, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'created_by', '3': 6, '4': 1, '5': 9, '10': 'createdBy'},
    {
      '1': 'first_message_index',
      '3': 7,
      '4': 1,
      '5': 5,
      '10': 'firstMessageIndex'
    },
    {
      '1': 'last_message_index',
      '3': 8,
      '4': 1,
      '5': 5,
      '10': 'lastMessageIndex'
    },
    {'1': 'last_message_time', '3': 9, '4': 1, '5': 3, '10': 'lastMessageTime'},
    {
      '1': 'last_message_preview',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'lastMessagePreview'
    },
    {
      '1': 'last_message_name',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'lastMessageName'
    },
    {
      '1': 'participants',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.cc.ParticipantProto',
      '10': 'participants'
    },
    {'1': 'description', '3': 13, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'requires_approval',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'requiresApproval'
    },
  ],
};

/// Descriptor for `ConversationProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationProtoDescriptor = $convert.base64Decode(
    'ChFDb252ZXJzYXRpb25Qcm90bxInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdG'
    'lvbklkEigKBHR5cGUYAiABKA4yFC5jYy5Db252ZXJzYXRpb25UeXBlUgR0eXBlEhIKBG5hbWUY'
    'AyABKAlSBG5hbWUSFgoGYXZhdGFyGAQgASgJUgZhdmF0YXISHQoKY3JlYXRlZF9hdBgFIAEoA1'
    'IJY3JlYXRlZEF0Eh0KCmNyZWF0ZWRfYnkYBiABKAlSCWNyZWF0ZWRCeRIuChNmaXJzdF9tZXNz'
    'YWdlX2luZGV4GAcgASgFUhFmaXJzdE1lc3NhZ2VJbmRleBIsChJsYXN0X21lc3NhZ2VfaW5kZX'
    'gYCCABKAVSEGxhc3RNZXNzYWdlSW5kZXgSKgoRbGFzdF9tZXNzYWdlX3RpbWUYCSABKANSD2xh'
    'c3RNZXNzYWdlVGltZRIwChRsYXN0X21lc3NhZ2VfcHJldmlldxgKIAEoCVISbGFzdE1lc3NhZ2'
    'VQcmV2aWV3EioKEWxhc3RfbWVzc2FnZV9uYW1lGAsgASgJUg9sYXN0TWVzc2FnZU5hbWUSOAoM'
    'cGFydGljaXBhbnRzGAwgAygLMhQuY2MuUGFydGljaXBhbnRQcm90b1IMcGFydGljaXBhbnRzEi'
    'AKC2Rlc2NyaXB0aW9uGA0gASgJUgtkZXNjcmlwdGlvbhIrChFyZXF1aXJlc19hcHByb3ZhbBgO'
    'IAEoCFIQcmVxdWlyZXNBcHByb3ZhbA==');

@$core.Deprecated('Use conversationCollectionDescriptor instead')
const ConversationCollection$json = {
  '1': 'ConversationCollection',
  '2': [
    {
      '1': 'conversations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.cc.ConversationProto',
      '10': 'conversations'
    },
  ],
};

/// Descriptor for `ConversationCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationCollectionDescriptor =
    $convert.base64Decode(
        'ChZDb252ZXJzYXRpb25Db2xsZWN0aW9uEjsKDWNvbnZlcnNhdGlvbnMYASADKAsyFS5jYy5Db2'
        '52ZXJzYXRpb25Qcm90b1INY29udmVyc2F0aW9ucw==');

@$core.Deprecated('Use syncConversationsRequestDescriptor instead')
const SyncConversationsRequest$json = {
  '1': 'SyncConversationsRequest',
  '2': [
    {
      '1': 'last_sync_time',
      '3': 1,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'lastSyncTime',
      '17': true
    },
  ],
  '8': [
    {'1': '_last_sync_time'},
  ],
};

/// Descriptor for `SyncConversationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncConversationsRequestDescriptor =
    $convert.base64Decode(
        'ChhTeW5jQ29udmVyc2F0aW9uc1JlcXVlc3QSKQoObGFzdF9zeW5jX3RpbWUYASABKANIAFIMbG'
        'FzdFN5bmNUaW1liAEBQhEKD19sYXN0X3N5bmNfdGltZQ==');

@$core.Deprecated('Use conversationCreateRequestDescriptor instead')
const ConversationCreateRequest$json = {
  '1': 'ConversationCreateRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 2, '4': 1, '5': 9, '10': 'avatar'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.cc.ConversationType',
      '10': 'type'
    },
    {'1': 'participant_ids', '3': 4, '4': 3, '5': 9, '10': 'participantIds'},
    {'1': 'contact_user_id', '3': 5, '4': 1, '5': 9, '10': 'contactUserId'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `ConversationCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationCreateRequestDescriptor = $convert.base64Decode(
    'ChlDb252ZXJzYXRpb25DcmVhdGVSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSFgoGYXZhdG'
    'FyGAIgASgJUgZhdmF0YXISKAoEdHlwZRgDIAEoDjIULmNjLkNvbnZlcnNhdGlvblR5cGVSBHR5'
    'cGUSJwoPcGFydGljaXBhbnRfaWRzGAQgAygJUg5wYXJ0aWNpcGFudElkcxImCg9jb250YWN0X3'
    'VzZXJfaWQYBSABKAlSDWNvbnRhY3RVc2VySWQSIAoLZGVzY3JpcHRpb24YBiABKAlSC2Rlc2Ny'
    'aXB0aW9u');

@$core.Deprecated('Use conversationCreateResponseDescriptor instead')
const ConversationCreateResponse$json = {
  '1': 'ConversationCreateResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'conversation',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.ConversationProto',
      '10': 'conversation'
    },
  ],
};

/// Descriptor for `ConversationCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationCreateResponseDescriptor =
    $convert.base64Decode(
        'ChpDb252ZXJzYXRpb25DcmVhdGVSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEh'
        'gKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USOQoMY29udmVyc2F0aW9uGAMgASgLMhUuY2MuQ29u'
        'dmVyc2F0aW9uUHJvdG9SDGNvbnZlcnNhdGlvbg==');

@$core.Deprecated('Use conversationDetailRequestDescriptor instead')
const ConversationDetailRequest$json = {
  '1': 'ConversationDetailRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `ConversationDetailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDetailRequestDescriptor =
    $convert.base64Decode(
        'ChlDb252ZXJzYXRpb25EZXRhaWxSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY2'
        '9udmVyc2F0aW9uSWQ=');

@$core.Deprecated('Use conversationDetailResponseDescriptor instead')
const ConversationDetailResponse$json = {
  '1': 'ConversationDetailResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'conversation',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.ConversationProto',
      '10': 'conversation'
    },
  ],
};

/// Descriptor for `ConversationDetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDetailResponseDescriptor =
    $convert.base64Decode(
        'ChpDb252ZXJzYXRpb25EZXRhaWxSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEh'
        'gKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USOQoMY29udmVyc2F0aW9uGAMgASgLMhUuY2MuQ29u'
        'dmVyc2F0aW9uUHJvdG9SDGNvbnZlcnNhdGlvbg==');

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
final $typed_data.Uint8List conversationSettingsUpdateRequestDescriptor =
    $convert.base64Decode(
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
final $typed_data.Uint8List conversationSettingsUpdateResponseDescriptor =
    $convert.base64Decode(
        'CiJDb252ZXJzYXRpb25TZXR0aW5nc1VwZGF0ZVJlc3BvbnNlEicKD2NvbnZlcnNhdGlvbl9pZB'
        'gBIAEoCVIOY29udmVyc2F0aW9uSWQSGAoHc3VjY2VzcxgCIAEoCFIHc3VjY2VzcxIZCgVtdXRl'
        'ZBgDIAEoCEgAUgVtdXRlZIgBARIbCgZwaW5uZWQYBCABKAhIAVIGcGlubmVkiAEBEhwKCXRpbW'
        'VzdGFtcBgFIAEoA1IJdGltZXN0YW1wQggKBl9tdXRlZEIJCgdfcGlubmVk');

@$core.Deprecated('Use conversationInfoUpdateRequestDescriptor instead')
const ConversationInfoUpdateRequest$json = {
  '1': 'ConversationInfoUpdateRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'avatar', '17': true},
    {
      '1': 'description',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'description',
      '17': true
    },
    {
      '1': 'requires_approval',
      '3': 5,
      '4': 1,
      '5': 8,
      '9': 3,
      '10': 'requiresApproval',
      '17': true
    },
  ],
  '8': [
    {'1': '_name'},
    {'1': '_avatar'},
    {'1': '_description'},
    {'1': '_requires_approval'},
  ],
};

/// Descriptor for `ConversationInfoUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationInfoUpdateRequestDescriptor = $convert.base64Decode(
    'Ch1Db252ZXJzYXRpb25JbmZvVXBkYXRlUmVxdWVzdBInCg9jb252ZXJzYXRpb25faWQYASABKA'
    'lSDmNvbnZlcnNhdGlvbklkEhcKBG5hbWUYAiABKAlIAFIEbmFtZYgBARIbCgZhdmF0YXIYAyAB'
    'KAlIAVIGYXZhdGFyiAEBEiUKC2Rlc2NyaXB0aW9uGAQgASgJSAJSC2Rlc2NyaXB0aW9uiAEBEj'
    'AKEXJlcXVpcmVzX2FwcHJvdmFsGAUgASgISANSEHJlcXVpcmVzQXBwcm92YWyIAQFCBwoFX25h'
    'bWVCCQoHX2F2YXRhckIOCgxfZGVzY3JpcHRpb25CFAoSX3JlcXVpcmVzX2FwcHJvdmFs');

@$core.Deprecated('Use conversationInfoUpdateResponseDescriptor instead')
const ConversationInfoUpdateResponse$json = {
  '1': 'ConversationInfoUpdateResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ConversationInfoUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationInfoUpdateResponseDescriptor =
    $convert.base64Decode(
        'Ch5Db252ZXJzYXRpb25JbmZvVXBkYXRlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2'
        'VzcxIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use conversationInfoUpdatedDescriptor instead')
const ConversationInfoUpdated$json = {
  '1': 'ConversationInfoUpdated',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'requires_approval',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'requiresApproval'
    },
    {'1': 'updated_by', '3': 6, '4': 1, '5': 9, '10': 'updatedBy'},
    {'1': 'updated_at', '3': 7, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `ConversationInfoUpdated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationInfoUpdatedDescriptor = $convert.base64Decode(
    'ChdDb252ZXJzYXRpb25JbmZvVXBkYXRlZBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbn'
    'ZlcnNhdGlvbklkEhIKBG5hbWUYAiABKAlSBG5hbWUSFgoGYXZhdGFyGAMgASgJUgZhdmF0YXIS'
    'IAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEisKEXJlcXVpcmVzX2FwcHJvdmFsGA'
    'UgASgIUhByZXF1aXJlc0FwcHJvdmFsEh0KCnVwZGF0ZWRfYnkYBiABKAlSCXVwZGF0ZWRCeRId'
    'Cgp1cGRhdGVkX2F0GAcgASgDUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use conversationResponseDescriptor instead')
const ConversationResponse$json = {
  '1': 'ConversationResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'conversation',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.ConversationProto',
      '10': 'conversation'
    },
  ],
};

/// Descriptor for `ConversationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationResponseDescriptor = $convert.base64Decode(
    'ChRDb252ZXJzYXRpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3'
    'NhZ2UYAiABKAlSB21lc3NhZ2USOQoMY29udmVyc2F0aW9uGAMgASgLMhUuY2MuQ29udmVyc2F0'
    'aW9uUHJvdG9SDGNvbnZlcnNhdGlvbg==');

@$core.Deprecated('Use conversationJoinLeaveRequestDescriptor instead')
const ConversationJoinLeaveRequest$json = {
  '1': 'ConversationJoinLeaveRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ConversationJoinLeaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationJoinLeaveRequestDescriptor =
    $convert.base64Decode(
        'ChxDb252ZXJzYXRpb25Kb2luTGVhdmVSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCV'
        'IOY29udmVyc2F0aW9uSWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use conversationJoinLeaveResponseDescriptor instead')
const ConversationJoinLeaveResponse$json = {
  '1': 'ConversationJoinLeaveResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `ConversationJoinLeaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationJoinLeaveResponseDescriptor =
    $convert.base64Decode(
        'Ch1Db252ZXJzYXRpb25Kb2luTGVhdmVSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZX'
        'NzEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USJwoPY29udmVyc2F0aW9uX2lkGAMgASgJUg5j'
        'b252ZXJzYXRpb25JZA==');

@$core.Deprecated('Use participantStatusUpdateRequestDescriptor instead')
const ParticipantStatusUpdateRequest$json = {
  '1': 'ParticipantStatusUpdateRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'read_message_index',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'readMessageIndex',
      '17': true
    },
    {'1': 'muted', '3': 4, '4': 1, '5': 8, '9': 1, '10': 'muted', '17': true},
    {'1': 'pinned', '3': 5, '4': 1, '5': 8, '9': 2, '10': 'pinned', '17': true},
  ],
  '8': [
    {'1': '_read_message_index'},
    {'1': '_muted'},
    {'1': '_pinned'},
  ],
};

/// Descriptor for `ParticipantStatusUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantStatusUpdateRequestDescriptor = $convert.base64Decode(
    'Ch5QYXJ0aWNpcGFudFN0YXR1c1VwZGF0ZVJlcXVlc3QSJwoPY29udmVyc2F0aW9uX2lkGAEgAS'
    'gJUg5jb252ZXJzYXRpb25JZBIxChJyZWFkX21lc3NhZ2VfaW5kZXgYAyABKAVIAFIQcmVhZE1l'
    'c3NhZ2VJbmRleIgBARIZCgVtdXRlZBgEIAEoCEgBUgVtdXRlZIgBARIbCgZwaW5uZWQYBSABKA'
    'hIAlIGcGlubmVkiAEBQhUKE19yZWFkX21lc3NhZ2VfaW5kZXhCCAoGX211dGVkQgkKB19waW5u'
    'ZWQ=');

@$core.Deprecated('Use participantStatusUpdateResponseDescriptor instead')
const ParticipantStatusUpdateResponse$json = {
  '1': 'ParticipantStatusUpdateResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'participant',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.ParticipantProto',
      '10': 'participant'
    },
  ],
};

/// Descriptor for `ParticipantStatusUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantStatusUpdateResponseDescriptor =
    $convert.base64Decode(
        'Ch9QYXJ0aWNpcGFudFN0YXR1c1VwZGF0ZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2'
        'Nlc3MSJwoPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBI2CgtwYXJ0aWNp'
        'cGFudBgDIAEoCzIULmNjLlBhcnRpY2lwYW50UHJvdG9SC3BhcnRpY2lwYW50');

@$core.Deprecated('Use participantIndexUpdatedNotificationDescriptor instead')
const ParticipantIndexUpdatedNotification$json = {
  '1': 'ParticipantIndexUpdatedNotification',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'read_message_index',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'readMessageIndex',
      '17': true
    },
    {
      '1': 'delivered_message_index',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'deliveredMessageIndex',
      '17': true
    },
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '8': [
    {'1': '_read_message_index'},
    {'1': '_delivered_message_index'},
  ],
};

/// Descriptor for `ParticipantIndexUpdatedNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantIndexUpdatedNotificationDescriptor = $convert.base64Decode(
    'CiNQYXJ0aWNpcGFudEluZGV4VXBkYXRlZE5vdGlmaWNhdGlvbhInCg9jb252ZXJzYXRpb25faW'
    'QYASABKAlSDmNvbnZlcnNhdGlvbklkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIxChJyZWFk'
    'X21lc3NhZ2VfaW5kZXgYAyABKAVIAFIQcmVhZE1lc3NhZ2VJbmRleIgBARI7ChdkZWxpdmVyZW'
    'RfbWVzc2FnZV9pbmRleBgEIAEoBUgBUhVkZWxpdmVyZWRNZXNzYWdlSW5kZXiIAQESHAoJdGlt'
    'ZXN0YW1wGAUgASgDUgl0aW1lc3RhbXBCFQoTX3JlYWRfbWVzc2FnZV9pbmRleEIaChhfZGVsaX'
    'ZlcmVkX21lc3NhZ2VfaW5kZXg=');

@$core.Deprecated('Use conversationMembersRequestDescriptor instead')
const ConversationMembersRequest$json = {
  '1': 'ConversationMembersRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `ConversationMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMembersRequestDescriptor =
    $convert.base64Decode(
        'ChpDb252ZXJzYXRpb25NZW1iZXJzUmVxdWVzdBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDm'
        'NvbnZlcnNhdGlvbklk');

@$core.Deprecated('Use conversationMembersResponseDescriptor instead')
const ConversationMembersResponse$json = {
  '1': 'ConversationMembersResponse',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'members',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.cc.ParticipantProto',
      '10': 'members'
    },
  ],
};

/// Descriptor for `ConversationMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMembersResponseDescriptor =
    $convert.base64Decode(
        'ChtDb252ZXJzYXRpb25NZW1iZXJzUmVzcG9uc2USJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg'
        '5jb252ZXJzYXRpb25JZBIuCgdtZW1iZXJzGAIgAygLMhQuY2MuUGFydGljaXBhbnRQcm90b1IH'
        'bWVtYmVycw==');

@$core.Deprecated('Use conversationMemberChangeRequestDescriptor instead')
const ConversationMemberChangeRequest$json = {
  '1': 'ConversationMemberChangeRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
  ],
};

/// Descriptor for `ConversationMemberChangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMemberChangeRequestDescriptor =
    $convert.base64Decode(
        'Ch9Db252ZXJzYXRpb25NZW1iZXJDaGFuZ2VSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIA'
        'EoCVIOY29udmVyc2F0aW9uSWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklkEhYKBmFjdGlvbhgD'
        'IAEoCVIGYWN0aW9u');

@$core.Deprecated('Use conversationMemberChangeResponseDescriptor instead')
const ConversationMemberChangeResponse$json = {
  '1': 'ConversationMemberChangeResponse',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'member',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.cc.ParticipantProto',
      '10': 'member'
    },
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
    {'1': 'action_by', '3': 4, '4': 1, '5': 9, '10': 'actionBy'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `ConversationMemberChangeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMemberChangeResponseDescriptor =
    $convert.base64Decode(
        'CiBDb252ZXJzYXRpb25NZW1iZXJDaGFuZ2VSZXNwb25zZRInCg9jb252ZXJzYXRpb25faWQYAS'
        'ABKAlSDmNvbnZlcnNhdGlvbklkEiwKBm1lbWJlchgCIAEoCzIULmNjLlBhcnRpY2lwYW50UHJv'
        'dG9SBm1lbWJlchIWCgZhY3Rpb24YAyABKAlSBmFjdGlvbhIbCglhY3Rpb25fYnkYBCABKAlSCG'
        'FjdGlvbkJ5EhwKCXRpbWVzdGFtcBgFIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use conversationPreviewUpdatedDescriptor instead')
const ConversationPreviewUpdated$json = {
  '1': 'ConversationPreviewUpdated',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'last_message_index',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'lastMessageIndex'
    },
    {
      '1': 'last_message_preview',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'lastMessagePreview'
    },
    {'1': 'last_message_name', '3': 4, '4': 1, '5': 9, '10': 'lastMessageName'},
    {'1': 'last_message_time', '3': 5, '4': 1, '5': 3, '10': 'lastMessageTime'},
  ],
};

/// Descriptor for `ConversationPreviewUpdated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationPreviewUpdatedDescriptor = $convert.base64Decode(
    'ChpDb252ZXJzYXRpb25QcmV2aWV3VXBkYXRlZBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDm'
    'NvbnZlcnNhdGlvbklkEiwKEmxhc3RfbWVzc2FnZV9pbmRleBgCIAEoBVIQbGFzdE1lc3NhZ2VJ'
    'bmRleBIwChRsYXN0X21lc3NhZ2VfcHJldmlldxgDIAEoCVISbGFzdE1lc3NhZ2VQcmV2aWV3Ei'
    'oKEWxhc3RfbWVzc2FnZV9uYW1lGAQgASgJUg9sYXN0TWVzc2FnZU5hbWUSKgoRbGFzdF9tZXNz'
    'YWdlX3RpbWUYBSABKANSD2xhc3RNZXNzYWdlVGltZQ==');

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

@$core.Deprecated('Use conversationExitRequestDescriptor instead')
const ConversationExitRequest$json = {
  '1': 'ConversationExitRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'reason', '17': true},
  ],
  '8': [
    {'1': '_reason'},
  ],
};

/// Descriptor for `ConversationExitRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationExitRequestDescriptor = $convert.base64Decode(
    'ChdDb252ZXJzYXRpb25FeGl0UmVxdWVzdBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbn'
    'ZlcnNhdGlvbklkEhsKBnJlYXNvbhgCIAEoCUgAUgZyZWFzb26IAQFCCQoHX3JlYXNvbg==');

@$core.Deprecated('Use conversationExitResponseDescriptor instead')
const ConversationExitResponse$json = {
  '1': 'ConversationExitResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `ConversationExitResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationExitResponseDescriptor = $convert.base64Decode(
    'ChhDb252ZXJzYXRpb25FeGl0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCg'
    'dtZXNzYWdlGAIgASgJUgdtZXNzYWdlEicKD2NvbnZlcnNhdGlvbl9pZBgDIAEoCVIOY29udmVy'
    'c2F0aW9uSWQ=');

@$core.Deprecated('Use memberExitedNotificationDescriptor instead')
const MemberExitedNotification$json = {
  '1': 'MemberExitedNotification',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'user_name', '3': 3, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'exited_at', '3': 4, '4': 1, '5': 3, '10': 'exitedAt'},
    {'1': 'reason', '3': 5, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `MemberExitedNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberExitedNotificationDescriptor = $convert.base64Decode(
    'ChhNZW1iZXJFeGl0ZWROb3RpZmljYXRpb24SJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb2'
    '52ZXJzYXRpb25JZBIXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSGwoJdXNlcl9uYW1lGAMgASgJ'
    'Ugh1c2VyTmFtZRIbCglleGl0ZWRfYXQYBCABKANSCGV4aXRlZEF0EhYKBnJlYXNvbhgFIAEoCV'
    'IGcmVhc29u');

@$core.Deprecated('Use conversationRemovedNotificationDescriptor instead')
const ConversationRemovedNotification$json = {
  '1': 'ConversationRemovedNotification',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'conversation_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'conversationName'
    },
    {'1': 'removed_at', '3': 3, '4': 1, '5': 3, '10': 'removedAt'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ConversationRemovedNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationRemovedNotificationDescriptor =
    $convert.base64Decode(
        'Ch9Db252ZXJzYXRpb25SZW1vdmVkTm90aWZpY2F0aW9uEicKD2NvbnZlcnNhdGlvbl9pZBgBIA'
        'EoCVIOY29udmVyc2F0aW9uSWQSKwoRY29udmVyc2F0aW9uX25hbWUYAiABKAlSEGNvbnZlcnNh'
        'dGlvbk5hbWUSHQoKcmVtb3ZlZF9hdBgDIAEoA1IJcmVtb3ZlZEF0EhYKBnJlYXNvbhgEIAEoCV'
        'IGcmVhc29u');

@$core.Deprecated('Use joinRequestProtoDescriptor instead')
const JoinRequestProto$json = {
  '1': 'JoinRequestProto',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'user_name', '3': 4, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'user_avatar', '3': 5, '4': 1, '5': 9, '10': 'userAvatar'},
    {'1': 'message', '3': 6, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.cc.JoinRequestStatus',
      '10': 'status'
    },
    {'1': 'created_at', '3': 8, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'processed_at', '3': 9, '4': 1, '5': 3, '10': 'processedAt'},
    {'1': 'processed_by', '3': 10, '4': 1, '5': 9, '10': 'processedBy'},
    {
      '1': 'processed_by_name',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'processedByName'
    },
  ],
};

/// Descriptor for `JoinRequestProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestProtoDescriptor = $convert.base64Decode(
    'ChBKb2luUmVxdWVzdFByb3RvEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZBInCg9jb2'
    '52ZXJzYXRpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklkEhcKB3VzZXJfaWQYAyABKAlSBnVz'
    'ZXJJZBIbCgl1c2VyX25hbWUYBCABKAlSCHVzZXJOYW1lEh8KC3VzZXJfYXZhdGFyGAUgASgJUg'
    'p1c2VyQXZhdGFyEhgKB21lc3NhZ2UYBiABKAlSB21lc3NhZ2USLQoGc3RhdHVzGAcgASgOMhUu'
    'Y2MuSm9pblJlcXVlc3RTdGF0dXNSBnN0YXR1cxIdCgpjcmVhdGVkX2F0GAggASgDUgljcmVhdG'
    'VkQXQSIQoMcHJvY2Vzc2VkX2F0GAkgASgDUgtwcm9jZXNzZWRBdBIhCgxwcm9jZXNzZWRfYnkY'
    'CiABKAlSC3Byb2Nlc3NlZEJ5EioKEXByb2Nlc3NlZF9ieV9uYW1lGAsgASgJUg9wcm9jZXNzZW'
    'RCeU5hbWU=');

@$core.Deprecated('Use sendJoinRequestMessageDescriptor instead')
const SendJoinRequestMessage$json = {
  '1': 'SendJoinRequestMessage',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SendJoinRequestMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendJoinRequestMessageDescriptor =
    $convert.base64Decode(
        'ChZTZW5kSm9pblJlcXVlc3RNZXNzYWdlEicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udm'
        'Vyc2F0aW9uSWQSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use sendJoinRequestResponseDescriptor instead')
const SendJoinRequestResponse$json = {
  '1': 'SendJoinRequestResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'request',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.JoinRequestProto',
      '9': 0,
      '10': 'request',
      '17': true
    },
  ],
  '8': [
    {'1': '_request'},
  ],
};

/// Descriptor for `SendJoinRequestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendJoinRequestResponseDescriptor = $convert.base64Decode(
    'ChdTZW5kSm9pblJlcXVlc3RSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB2'
    '1lc3NhZ2UYAiABKAlSB21lc3NhZ2USMwoHcmVxdWVzdBgDIAEoCzIULmNjLkpvaW5SZXF1ZXN0'
    'UHJvdG9IAFIHcmVxdWVzdIgBAUIKCghfcmVxdWVzdA==');

@$core.Deprecated('Use processJoinRequestMessageDescriptor instead')
const ProcessJoinRequestMessage$json = {
  '1': 'ProcessJoinRequestMessage',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'action', '3': 2, '4': 1, '5': 9, '10': 'action'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'reason', '17': true},
  ],
  '8': [
    {'1': '_reason'},
  ],
};

/// Descriptor for `ProcessJoinRequestMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processJoinRequestMessageDescriptor = $convert.base64Decode(
    'ChlQcm9jZXNzSm9pblJlcXVlc3RNZXNzYWdlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3'
    'RJZBIWCgZhY3Rpb24YAiABKAlSBmFjdGlvbhIbCgZyZWFzb24YAyABKAlIAFIGcmVhc29uiAEB'
    'QgkKB19yZWFzb24=');

@$core.Deprecated('Use processJoinRequestResponseDescriptor instead')
const ProcessJoinRequestResponse$json = {
  '1': 'ProcessJoinRequestResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'request',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.JoinRequestProto',
      '9': 0,
      '10': 'request',
      '17': true
    },
  ],
  '8': [
    {'1': '_request'},
  ],
};

/// Descriptor for `ProcessJoinRequestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processJoinRequestResponseDescriptor =
    $convert.base64Decode(
        'ChpQcm9jZXNzSm9pblJlcXVlc3RSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEh'
        'gKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USMwoHcmVxdWVzdBgDIAEoCzIULmNjLkpvaW5SZXF1'
        'ZXN0UHJvdG9IAFIHcmVxdWVzdIgBAUIKCghfcmVxdWVzdA==');

@$core.Deprecated('Use getJoinRequestsMessageDescriptor instead')
const GetJoinRequestsMessage$json = {
  '1': 'GetJoinRequestsMessage',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.cc.JoinRequestStatus',
      '9': 0,
      '10': 'status',
      '17': true
    },
  ],
  '8': [
    {'1': '_status'},
  ],
};

/// Descriptor for `GetJoinRequestsMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJoinRequestsMessageDescriptor = $convert.base64Decode(
    'ChZHZXRKb2luUmVxdWVzdHNNZXNzYWdlEicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udm'
    'Vyc2F0aW9uSWQSMgoGc3RhdHVzGAIgASgOMhUuY2MuSm9pblJlcXVlc3RTdGF0dXNIAFIGc3Rh'
    'dHVziAEBQgkKB19zdGF0dXM=');

@$core.Deprecated('Use getJoinRequestsResponseDescriptor instead')
const GetJoinRequestsResponse$json = {
  '1': 'GetJoinRequestsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'requests',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.cc.JoinRequestProto',
      '10': 'requests'
    },
  ],
};

/// Descriptor for `GetJoinRequestsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJoinRequestsResponseDescriptor = $convert.base64Decode(
    'ChdHZXRKb2luUmVxdWVzdHNSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB2'
    '1lc3NhZ2UYAiABKAlSB21lc3NhZ2USMAoIcmVxdWVzdHMYAyADKAsyFC5jYy5Kb2luUmVxdWVz'
    'dFByb3RvUghyZXF1ZXN0cw==');

@$core.Deprecated('Use joinRequestUpdatedNotificationDescriptor instead')
const JoinRequestUpdatedNotification$json = {
  '1': 'JoinRequestUpdatedNotification',
  '2': [
    {
      '1': 'request',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.cc.JoinRequestProto',
      '10': 'request'
    },
    {
      '1': 'notification_type',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'notificationType'
    },
  ],
};

/// Descriptor for `JoinRequestUpdatedNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestUpdatedNotificationDescriptor =
    $convert.base64Decode(
        'Ch5Kb2luUmVxdWVzdFVwZGF0ZWROb3RpZmljYXRpb24SLgoHcmVxdWVzdBgBIAEoCzIULmNjLk'
        'pvaW5SZXF1ZXN0UHJvdG9SB3JlcXVlc3QSKwoRbm90aWZpY2F0aW9uX3R5cGUYAiABKAlSEG5v'
        'dGlmaWNhdGlvblR5cGU=');
