//
//  Generated code. Do not modify.
//  source: message.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use messageTypeDescriptor instead')
const MessageType$json = {
  '1': 'MessageType',
  '2': [
    {'1': 'TEXT', '2': 0},
    {'1': 'IMAGE', '2': 1},
    {'1': 'VOICE', '2': 2},
    {'1': 'FILE', '2': 3},
    {'1': 'VIDEO', '2': 4},
    {'1': 'SYSTEM', '2': 6},
    {'1': 'MEMBERSHIP', '2': 7},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRIICgRURVhUEAASCQoFSU1BR0UQARIJCgVWT0lDRRACEggKBEZJTEUQAx'
    'IJCgVWSURFTxAEEgoKBlNZU1RFTRAGEg4KCk1FTUJFUlNISVAQBw==');

@$core.Deprecated('Use messageStatusDescriptor instead')
const MessageStatus$json = {
  '1': 'MessageStatus',
  '2': [
    {'1': 'SENDING', '2': 0},
    {'1': 'SENT', '2': 1},
    {'1': 'DELIVERED', '2': 2},
    {'1': 'READ', '2': 3},
    {'1': 'FAILED', '2': 4},
    {'1': 'DELETED', '2': 5},
    {'1': 'REVOKED', '2': 6},
  ],
};

/// Descriptor for `MessageStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageStatusDescriptor = $convert.base64Decode(
    'Cg1NZXNzYWdlU3RhdHVzEgsKB1NFTkRJTkcQABIICgRTRU5UEAESDQoJREVMSVZFUkVEEAISCA'
    'oEUkVBRBADEgoKBkZBSUxFRBAEEgsKB0RFTEVURUQQBRILCgdSRVZPS0VEEAY=');

@$core.Deprecated('Use systemEventTypeDescriptor instead')
const SystemEventType$json = {
  '1': 'SystemEventType',
  '2': [
    {'1': 'CONVERSATION_CREATED', '2': 0},
    {'1': 'CONVERSATION_DELETED', '2': 1},
    {'1': 'CONVERSATION_ARCHIVED', '2': 2},
    {'1': 'CONVERSATION_UNARCHIVED', '2': 3},
    {'1': 'MEMBER_JOINED', '2': 10},
    {'1': 'MEMBER_LEFT', '2': 11},
    {'1': 'MEMBER_REMOVED', '2': 12},
    {'1': 'MEMBER_PROMOTED', '2': 13},
    {'1': 'MEMBER_DEMOTED', '2': 14},
    {'1': 'MEMBER_ROLE_CHANGED', '2': 15},
    {'1': 'CONVERSATION_NAME_CHANGED', '2': 20},
    {'1': 'CONVERSATION_AVATAR_CHANGED', '2': 21},
    {'1': 'CONVERSATION_DESCRIPTION_CHANGED', '2': 22},
    {'1': 'CONVERSATION_SETTINGS_CHANGED', '2': 23},
    {'1': 'PERMISSIONS_CHANGED', '2': 30},
    {'1': 'MUTE_SETTINGS_CHANGED', '2': 31},
    {'1': 'MESSAGE_PINNED', '2': 40},
    {'1': 'MESSAGE_UNPINNED', '2': 41},
    {'1': 'MESSAGES_CLEARED', '2': 42},
    {'1': 'ENCRYPTION_ENABLED', '2': 50},
    {'1': 'ENCRYPTION_DISABLED', '2': 51},
    {'1': 'CUSTOM_EVENT', '2': 99},
  ],
};

/// Descriptor for `SystemEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List systemEventTypeDescriptor = $convert.base64Decode(
    'Cg9TeXN0ZW1FdmVudFR5cGUSGAoUQ09OVkVSU0FUSU9OX0NSRUFURUQQABIYChRDT05WRVJTQV'
    'RJT05fREVMRVRFRBABEhkKFUNPTlZFUlNBVElPTl9BUkNISVZFRBACEhsKF0NPTlZFUlNBVElP'
    'Tl9VTkFSQ0hJVkVEEAMSEQoNTUVNQkVSX0pPSU5FRBAKEg8KC01FTUJFUl9MRUZUEAsSEgoOTU'
    'VNQkVSX1JFTU9WRUQQDBITCg9NRU1CRVJfUFJPTU9URUQQDRISCg5NRU1CRVJfREVNT1RFRBAO'
    'EhcKE01FTUJFUl9ST0xFX0NIQU5HRUQQDxIdChlDT05WRVJTQVRJT05fTkFNRV9DSEFOR0VEEB'
    'QSHwobQ09OVkVSU0FUSU9OX0FWQVRBUl9DSEFOR0VEEBUSJAogQ09OVkVSU0FUSU9OX0RFU0NS'
    'SVBUSU9OX0NIQU5HRUQQFhIhCh1DT05WRVJTQVRJT05fU0VUVElOR1NfQ0hBTkdFRBAXEhcKE1'
    'BFUk1JU1NJT05TX0NIQU5HRUQQHhIZChVNVVRFX1NFVFRJTkdTX0NIQU5HRUQQHxISCg5NRVNT'
    'QUdFX1BJTk5FRBAoEhQKEE1FU1NBR0VfVU5QSU5ORUQQKRIUChBNRVNTQUdFU19DTEVBUkVEEC'
    'oSFgoSRU5DUllQVElPTl9FTkFCTEVEEDISFwoTRU5DUllQVElPTl9ESVNBQkxFRBAzEhAKDENV'
    'U1RPTV9FVkVOVBBj');

@$core.Deprecated('Use messageProtoDescriptor instead')
const MessageProto$json = {
  '1': 'MessageProto',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'sender_id', '3': 3, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'sender_name', '3': 4, '4': 1, '5': 9, '10': 'senderName'},
    {'1': 'sender_avatar', '3': 5, '4': 1, '5': 9, '10': 'senderAvatar'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 7, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'index', '3': 8, '4': 1, '5': 5, '10': 'index'},
    {'1': 'temp_id', '3': 11, '4': 1, '5': 9, '9': 1, '10': 'tempId', '17': true},
    {'1': 'type', '3': 9, '4': 1, '5': 14, '6': '.cc.MessageType', '10': 'type'},
    {'1': 'status', '3': 10, '4': 1, '5': 14, '6': '.cc.MessageStatus', '10': 'status'},
    {'1': 'quoted_message_id', '3': 21, '4': 1, '5': 9, '10': 'quotedMessageId'},
    {'1': 'is_edited', '3': 24, '4': 1, '5': 8, '10': 'isEdited'},
    {'1': 'edited_at', '3': 25, '4': 1, '5': 3, '10': 'editedAt'},
    {'1': 'replied_to_message_id', '3': 31, '4': 1, '5': 9, '10': 'repliedToMessageId'},
    {'1': 'forwarded_from_conversation_id', '3': 32, '4': 1, '5': 9, '10': 'forwardedFromConversationId'},
    {'1': 'forwarded_from_message_id', '3': 33, '4': 1, '5': 9, '10': 'forwardedFromMessageId'},
    {'1': 'reactions', '3': 34, '4': 3, '5': 11, '6': '.cc.MessageProto.ReactionsEntry', '10': 'reactions'},
    {'1': 'tags', '3': 36, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'is_pinned', '3': 37, '4': 1, '5': 8, '10': 'isPinned'},
    {'1': 'text_message', '3': 38, '4': 1, '5': 11, '6': '.cc.TextMessage', '9': 0, '10': 'textMessage'},
    {'1': 'media_message', '3': 39, '4': 1, '5': 11, '6': '.cc.MediaMessage', '9': 0, '10': 'mediaMessage'},
    {'1': 'system_message', '3': 41, '4': 1, '5': 11, '6': '.cc.SystemMessage', '9': 0, '10': 'systemMessage'},
    {'1': 'sticker_message', '3': 42, '4': 1, '5': 11, '6': '.cc.StickerMessage', '9': 0, '10': 'stickerMessage'},
    {'1': 'contact_message', '3': 43, '4': 1, '5': 11, '6': '.cc.ContactMessage', '9': 0, '10': 'contactMessage'},
    {'1': 'poll_message', '3': 44, '4': 1, '5': 11, '6': '.cc.PollMessage', '9': 0, '10': 'pollMessage'},
    {'1': 'link_message', '3': 45, '4': 1, '5': 11, '6': '.cc.LinkMessage', '9': 0, '10': 'linkMessage'},
    {'1': 'membership_message', '3': 46, '4': 1, '5': 11, '6': '.cc.MembershipMessage', '9': 0, '10': 'membershipMessage'},
  ],
  '3': [MessageProto_ReactionsEntry$json],
  '8': [
    {'1': 'content'},
    {'1': '_temp_id'},
  ],
};

@$core.Deprecated('Use messageProtoDescriptor instead')
const MessageProto_ReactionsEntry$json = {
  '1': 'ReactionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MessageProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageProtoDescriptor = $convert.base64Decode(
    'CgxNZXNzYWdlUHJvdG8SHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEicKD2NvbnZlcn'
    'NhdGlvbl9pZBgCIAEoCVIOY29udmVyc2F0aW9uSWQSGwoJc2VuZGVyX2lkGAMgASgJUghzZW5k'
    'ZXJJZBIfCgtzZW5kZXJfbmFtZRgEIAEoCVIKc2VuZGVyTmFtZRIjCg1zZW5kZXJfYXZhdGFyGA'
    'UgASgJUgxzZW5kZXJBdmF0YXISHQoKY3JlYXRlZF9hdBgGIAEoA1IJY3JlYXRlZEF0Eh0KCnVw'
    'ZGF0ZWRfYXQYByABKANSCXVwZGF0ZWRBdBIUCgVpbmRleBgIIAEoBVIFaW5kZXgSHAoHdGVtcF'
    '9pZBgLIAEoCUgBUgZ0ZW1wSWSIAQESIwoEdHlwZRgJIAEoDjIPLmNjLk1lc3NhZ2VUeXBlUgR0'
    'eXBlEikKBnN0YXR1cxgKIAEoDjIRLmNjLk1lc3NhZ2VTdGF0dXNSBnN0YXR1cxIqChFxdW90ZW'
    'RfbWVzc2FnZV9pZBgVIAEoCVIPcXVvdGVkTWVzc2FnZUlkEhsKCWlzX2VkaXRlZBgYIAEoCFII'
    'aXNFZGl0ZWQSGwoJZWRpdGVkX2F0GBkgASgDUghlZGl0ZWRBdBIxChVyZXBsaWVkX3RvX21lc3'
    'NhZ2VfaWQYHyABKAlSEnJlcGxpZWRUb01lc3NhZ2VJZBJDCh5mb3J3YXJkZWRfZnJvbV9jb252'
    'ZXJzYXRpb25faWQYICABKAlSG2ZvcndhcmRlZEZyb21Db252ZXJzYXRpb25JZBI5Chlmb3J3YX'
    'JkZWRfZnJvbV9tZXNzYWdlX2lkGCEgASgJUhZmb3J3YXJkZWRGcm9tTWVzc2FnZUlkEj0KCXJl'
    'YWN0aW9ucxgiIAMoCzIfLmNjLk1lc3NhZ2VQcm90by5SZWFjdGlvbnNFbnRyeVIJcmVhY3Rpb2'
    '5zEhIKBHRhZ3MYJCADKAlSBHRhZ3MSGwoJaXNfcGlubmVkGCUgASgIUghpc1Bpbm5lZBI0Cgx0'
    'ZXh0X21lc3NhZ2UYJiABKAsyDy5jYy5UZXh0TWVzc2FnZUgAUgt0ZXh0TWVzc2FnZRI3Cg1tZW'
    'RpYV9tZXNzYWdlGCcgASgLMhAuY2MuTWVkaWFNZXNzYWdlSABSDG1lZGlhTWVzc2FnZRI6Cg5z'
    'eXN0ZW1fbWVzc2FnZRgpIAEoCzIRLmNjLlN5c3RlbU1lc3NhZ2VIAFINc3lzdGVtTWVzc2FnZR'
    'I9Cg9zdGlja2VyX21lc3NhZ2UYKiABKAsyEi5jYy5TdGlja2VyTWVzc2FnZUgAUg5zdGlja2Vy'
    'TWVzc2FnZRI9Cg9jb250YWN0X21lc3NhZ2UYKyABKAsyEi5jYy5Db250YWN0TWVzc2FnZUgAUg'
    '5jb250YWN0TWVzc2FnZRI0Cgxwb2xsX21lc3NhZ2UYLCABKAsyDy5jYy5Qb2xsTWVzc2FnZUgA'
    'Ugtwb2xsTWVzc2FnZRI0CgxsaW5rX21lc3NhZ2UYLSABKAsyDy5jYy5MaW5rTWVzc2FnZUgAUg'
    'tsaW5rTWVzc2FnZRJGChJtZW1iZXJzaGlwX21lc3NhZ2UYLiABKAsyFS5jYy5NZW1iZXJzaGlw'
    'TWVzc2FnZUgAUhFtZW1iZXJzaGlwTWVzc2FnZRo8Cg5SZWFjdGlvbnNFbnRyeRIQCgNrZXkYAS'
    'ABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBQgkKB2NvbnRlbnRCCgoIX3RlbXBf'
    'aWQ=');

@$core.Deprecated('Use textMessageDescriptor instead')
const TextMessage$json = {
  '1': 'TextMessage',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'mentions', '3': 2, '4': 3, '5': 9, '10': 'mentions'},
    {'1': 'hashtags', '3': 3, '4': 3, '5': 9, '10': 'hashtags'},
    {'1': 'links', '3': 4, '4': 3, '5': 11, '6': '.cc.LinkPreview', '10': 'links'},
  ],
};

/// Descriptor for `TextMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageDescriptor = $convert.base64Decode(
    'CgtUZXh0TWVzc2FnZRISCgR0ZXh0GAEgASgJUgR0ZXh0EhoKCG1lbnRpb25zGAIgAygJUghtZW'
    '50aW9ucxIaCghoYXNodGFncxgDIAMoCVIIaGFzaHRhZ3MSJQoFbGlua3MYBCADKAsyDy5jYy5M'
    'aW5rUHJldmlld1IFbGlua3M=');

@$core.Deprecated('Use mediaMessageDescriptor instead')
const MediaMessage$json = {
  '1': 'MediaMessage',
  '2': [
    {'1': 'media_url', '3': 1, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'local_path', '3': 2, '4': 1, '5': 9, '10': 'localPath'},
    {'1': 'duration', '3': 3, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'file_size', '3': 4, '4': 1, '5': 1, '10': 'fileSize'},
    {'1': 'file_name', '3': 5, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'thumbnail_url', '3': 6, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'mime_type', '3': 7, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'width', '3': 8, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 9, '4': 1, '5': 5, '10': 'height'},
    {'1': 'caption', '3': 10, '4': 1, '5': 9, '10': 'caption'},
  ],
};

/// Descriptor for `MediaMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaMessageDescriptor = $convert.base64Decode(
    'CgxNZWRpYU1lc3NhZ2USGwoJbWVkaWFfdXJsGAEgASgJUghtZWRpYVVybBIdCgpsb2NhbF9wYX'
    'RoGAIgASgJUglsb2NhbFBhdGgSGgoIZHVyYXRpb24YAyABKAVSCGR1cmF0aW9uEhsKCWZpbGVf'
    'c2l6ZRgEIAEoAVIIZmlsZVNpemUSGwoJZmlsZV9uYW1lGAUgASgJUghmaWxlTmFtZRIjCg10aH'
    'VtYm5haWxfdXJsGAYgASgJUgx0aHVtYm5haWxVcmwSGwoJbWltZV90eXBlGAcgASgJUghtaW1l'
    'VHlwZRIUCgV3aWR0aBgIIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAkgASgFUgZoZWlnaHQSGAoHY2'
    'FwdGlvbhgKIAEoCVIHY2FwdGlvbg==');

@$core.Deprecated('Use systemMessageDescriptor instead')
const SystemMessage$json = {
  '1': 'SystemMessage',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'event_type', '3': 2, '4': 1, '5': 14, '6': '.cc.SystemEventType', '10': 'eventType'},
    {'1': 'params', '3': 3, '4': 3, '5': 11, '6': '.cc.SystemMessage.ParamsEntry', '10': 'params'},
    {'1': 'affected_user_ids', '3': 4, '4': 3, '5': 9, '10': 'affectedUserIds'},
    {'1': 'actor_user_id', '3': 5, '4': 1, '5': 9, '10': 'actorUserId'},
    {'1': 'event_timestamp', '3': 6, '4': 1, '5': 3, '10': 'eventTimestamp'},
    {'1': 'metadata', '3': 7, '4': 3, '5': 11, '6': '.cc.SystemMessage.MetadataEntry', '10': 'metadata'},
  ],
  '3': [SystemMessage_ParamsEntry$json, SystemMessage_MetadataEntry$json],
};

@$core.Deprecated('Use systemMessageDescriptor instead')
const SystemMessage_ParamsEntry$json = {
  '1': 'ParamsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use systemMessageDescriptor instead')
const SystemMessage_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SystemMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemMessageDescriptor = $convert.base64Decode(
    'Cg1TeXN0ZW1NZXNzYWdlEhIKBHRleHQYASABKAlSBHRleHQSMgoKZXZlbnRfdHlwZRgCIAEoDj'
    'ITLmNjLlN5c3RlbUV2ZW50VHlwZVIJZXZlbnRUeXBlEjUKBnBhcmFtcxgDIAMoCzIdLmNjLlN5'
    'c3RlbU1lc3NhZ2UuUGFyYW1zRW50cnlSBnBhcmFtcxIqChFhZmZlY3RlZF91c2VyX2lkcxgEIA'
    'MoCVIPYWZmZWN0ZWRVc2VySWRzEiIKDWFjdG9yX3VzZXJfaWQYBSABKAlSC2FjdG9yVXNlcklk'
    'EicKD2V2ZW50X3RpbWVzdGFtcBgGIAEoA1IOZXZlbnRUaW1lc3RhbXASOwoIbWV0YWRhdGEYBy'
    'ADKAsyHy5jYy5TeXN0ZW1NZXNzYWdlLk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjkKC1BhcmFt'
    'c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAEaOwoNTW'
    'V0YWRhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use stickerMessageDescriptor instead')
const StickerMessage$json = {
  '1': 'StickerMessage',
  '2': [
    {'1': 'sticker_id', '3': 1, '4': 1, '5': 9, '10': 'stickerId'},
    {'1': 'sticker_url', '3': 2, '4': 1, '5': 9, '10': 'stickerUrl'},
    {'1': 'sticker_pack_id', '3': 3, '4': 1, '5': 9, '10': 'stickerPackId'},
    {'1': 'sticker_pack_name', '3': 4, '4': 1, '5': 9, '10': 'stickerPackName'},
  ],
};

/// Descriptor for `StickerMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stickerMessageDescriptor = $convert.base64Decode(
    'Cg5TdGlja2VyTWVzc2FnZRIdCgpzdGlja2VyX2lkGAEgASgJUglzdGlja2VySWQSHwoLc3RpY2'
    'tlcl91cmwYAiABKAlSCnN0aWNrZXJVcmwSJgoPc3RpY2tlcl9wYWNrX2lkGAMgASgJUg1zdGlj'
    'a2VyUGFja0lkEioKEXN0aWNrZXJfcGFja19uYW1lGAQgASgJUg9zdGlja2VyUGFja05hbWU=');

@$core.Deprecated('Use contactMessageDescriptor instead')
const ContactMessage$json = {
  '1': 'ContactMessage',
  '2': [
    {'1': 'contact_id', '3': 1, '4': 1, '5': 9, '10': 'contactId'},
    {'1': 'contact_name', '3': 2, '4': 1, '5': 9, '10': 'contactName'},
    {'1': 'contact_phone', '3': 3, '4': 1, '5': 9, '10': 'contactPhone'},
    {'1': 'contact_avatar', '3': 4, '4': 1, '5': 9, '10': 'contactAvatar'},
    {'1': 'contact_email', '3': 5, '4': 1, '5': 9, '10': 'contactEmail'},
  ],
};

/// Descriptor for `ContactMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactMessageDescriptor = $convert.base64Decode(
    'Cg5Db250YWN0TWVzc2FnZRIdCgpjb250YWN0X2lkGAEgASgJUgljb250YWN0SWQSIQoMY29udG'
    'FjdF9uYW1lGAIgASgJUgtjb250YWN0TmFtZRIjCg1jb250YWN0X3Bob25lGAMgASgJUgxjb250'
    'YWN0UGhvbmUSJQoOY29udGFjdF9hdmF0YXIYBCABKAlSDWNvbnRhY3RBdmF0YXISIwoNY29udG'
    'FjdF9lbWFpbBgFIAEoCVIMY29udGFjdEVtYWls');

@$core.Deprecated('Use pollMessageDescriptor instead')
const PollMessage$json = {
  '1': 'PollMessage',
  '2': [
    {'1': 'poll_id', '3': 1, '4': 1, '5': 9, '10': 'pollId'},
    {'1': 'question', '3': 2, '4': 1, '5': 9, '10': 'question'},
    {'1': 'options', '3': 3, '4': 3, '5': 11, '6': '.cc.PollOption', '10': 'options'},
    {'1': 'is_multiple_choice', '3': 4, '4': 1, '5': 8, '10': 'isMultipleChoice'},
    {'1': 'expires_at', '3': 5, '4': 1, '5': 3, '10': 'expiresAt'},
    {'1': 'is_anonymous', '3': 6, '4': 1, '5': 8, '10': 'isAnonymous'},
  ],
};

/// Descriptor for `PollMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollMessageDescriptor = $convert.base64Decode(
    'CgtQb2xsTWVzc2FnZRIXCgdwb2xsX2lkGAEgASgJUgZwb2xsSWQSGgoIcXVlc3Rpb24YAiABKA'
    'lSCHF1ZXN0aW9uEigKB29wdGlvbnMYAyADKAsyDi5jYy5Qb2xsT3B0aW9uUgdvcHRpb25zEiwK'
    'EmlzX211bHRpcGxlX2Nob2ljZRgEIAEoCFIQaXNNdWx0aXBsZUNob2ljZRIdCgpleHBpcmVzX2'
    'F0GAUgASgDUglleHBpcmVzQXQSIQoMaXNfYW5vbnltb3VzGAYgASgIUgtpc0Fub255bW91cw==');

@$core.Deprecated('Use pollOptionDescriptor instead')
const PollOption$json = {
  '1': 'PollOption',
  '2': [
    {'1': 'option_id', '3': 1, '4': 1, '5': 9, '10': 'optionId'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'vote_count', '3': 3, '4': 1, '5': 5, '10': 'voteCount'},
    {'1': 'voter_ids', '3': 4, '4': 3, '5': 9, '10': 'voterIds'},
  ],
};

/// Descriptor for `PollOption`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollOptionDescriptor = $convert.base64Decode(
    'CgpQb2xsT3B0aW9uEhsKCW9wdGlvbl9pZBgBIAEoCVIIb3B0aW9uSWQSEgoEdGV4dBgCIAEoCV'
    'IEdGV4dBIdCgp2b3RlX2NvdW50GAMgASgFUgl2b3RlQ291bnQSGwoJdm90ZXJfaWRzGAQgAygJ'
    'Ugh2b3Rlcklkcw==');

@$core.Deprecated('Use linkMessageDescriptor instead')
const LinkMessage$json = {
  '1': 'LinkMessage',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'preview', '3': 2, '4': 1, '5': 11, '6': '.cc.LinkPreview', '10': 'preview'},
  ],
};

/// Descriptor for `LinkMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkMessageDescriptor = $convert.base64Decode(
    'CgtMaW5rTWVzc2FnZRIQCgN1cmwYASABKAlSA3VybBIpCgdwcmV2aWV3GAIgASgLMg8uY2MuTG'
    'lua1ByZXZpZXdSB3ByZXZpZXc=');

@$core.Deprecated('Use linkPreviewDescriptor instead')
const LinkPreview$json = {
  '1': 'LinkPreview',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 4, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'site_name', '3': 5, '4': 1, '5': 9, '10': 'siteName'},
    {'1': 'favicon_url', '3': 6, '4': 1, '5': 9, '10': 'faviconUrl'},
  ],
};

/// Descriptor for `LinkPreview`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkPreviewDescriptor = $convert.base64Decode(
    'CgtMaW5rUHJldmlldxIQCgN1cmwYASABKAlSA3VybBIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSIA'
    'oLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhsKCWltYWdlX3VybBgEIAEoCVIIaW1h'
    'Z2VVcmwSGwoJc2l0ZV9uYW1lGAUgASgJUghzaXRlTmFtZRIfCgtmYXZpY29uX3VybBgGIAEoCV'
    'IKZmF2aWNvblVybA==');

@$core.Deprecated('Use messageSendResponseDescriptor instead')
const MessageSendResponse$json = {
  '1': 'MessageSendResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'temp_id', '3': 4, '4': 1, '5': 9, '10': 'tempId'},
    {'1': 'message_id', '3': 5, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'message_index', '3': 6, '4': 1, '5': 5, '10': 'messageIndex'},
  ],
};

/// Descriptor for `MessageSendResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSendResponseDescriptor = $convert.base64Decode(
    'ChNNZXNzYWdlU2VuZFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSEAoDbXNnGA'
    'IgASgJUgNtc2cSJwoPY29udmVyc2F0aW9uX2lkGAMgASgJUg5jb252ZXJzYXRpb25JZBIXCgd0'
    'ZW1wX2lkGAQgASgJUgZ0ZW1wSWQSHQoKbWVzc2FnZV9pZBgFIAEoCVIJbWVzc2FnZUlkEiMKDW'
    '1lc3NhZ2VfaW5kZXgYBiABKAVSDG1lc3NhZ2VJbmRleA==');

@$core.Deprecated('Use typingProtoDescriptor instead')
const TypingProto$json = {
  '1': 'TypingProto',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `TypingProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingProtoDescriptor = $convert.base64Decode(
    'CgtUeXBpbmdQcm90bxInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdGlvbklkEh'
    'sKCWlzX3R5cGluZxgDIAEoCFIIaXNUeXBpbmcSHAoJdGltZXN0YW1wGAQgASgDUgl0aW1lc3Rh'
    'bXA=');

@$core.Deprecated('Use messageReadProtoDescriptor instead')
const MessageReadProto$json = {
  '1': 'MessageReadProto',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'read_at', '3': 4, '4': 1, '5': 3, '10': 'readAt'},
  ],
};

/// Descriptor for `MessageReadProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReadProtoDescriptor = $convert.base64Decode(
    'ChBNZXNzYWdlUmVhZFByb3RvEh0KCm1lc3NhZ2VfaWQYASABKAlSCW1lc3NhZ2VJZBInCg9jb2'
    '52ZXJzYXRpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklkEhcKB3VzZXJfaWQYAyABKAlSBnVz'
    'ZXJJZBIXCgdyZWFkX2F0GAQgASgDUgZyZWFkQXQ=');

@$core.Deprecated('Use messagesFetchRequestDescriptor instead')
const MessagesFetchRequest$json = {
  '1': 'MessagesFetchRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'index_a', '3': 2, '4': 1, '5': 5, '10': 'indexA'},
    {'1': 'index_b', '3': 3, '4': 1, '5': 5, '10': 'indexB'},
    {'1': 'jump_index', '3': 4, '4': 1, '5': 5, '9': 0, '10': 'jumpIndex', '17': true},
    {'1': 'anchor_message_index', '3': 5, '4': 1, '5': 5, '9': 1, '10': 'anchorMessageIndex', '17': true},
  ],
  '8': [
    {'1': '_jump_index'},
    {'1': '_anchor_message_index'},
  ],
};

/// Descriptor for `MessagesFetchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messagesFetchRequestDescriptor = $convert.base64Decode(
    'ChRNZXNzYWdlc0ZldGNoUmVxdWVzdBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcn'
    'NhdGlvbklkEhcKB2luZGV4X2EYAiABKAVSBmluZGV4QRIXCgdpbmRleF9iGAMgASgFUgZpbmRl'
    'eEISIgoKanVtcF9pbmRleBgEIAEoBUgAUglqdW1wSW5kZXiIAQESNQoUYW5jaG9yX21lc3NhZ2'
    'VfaW5kZXgYBSABKAVIAVISYW5jaG9yTWVzc2FnZUluZGV4iAEBQg0KC19qdW1wX2luZGV4QhcK'
    'FV9hbmNob3JfbWVzc2FnZV9pbmRleA==');

@$core.Deprecated('Use messagesFetchResponseDescriptor instead')
const MessagesFetchResponse$json = {
  '1': 'MessagesFetchResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'messages', '3': 4, '4': 3, '5': 11, '6': '.cc.MessageProto', '10': 'messages'},
    {'1': 'jump_index', '3': 5, '4': 1, '5': 5, '9': 0, '10': 'jumpIndex', '17': true},
    {'1': 'anchor_message_index', '3': 6, '4': 1, '5': 5, '9': 1, '10': 'anchorMessageIndex', '17': true},
  ],
  '8': [
    {'1': '_jump_index'},
    {'1': '_anchor_message_index'},
  ],
};

/// Descriptor for `MessagesFetchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messagesFetchResponseDescriptor = $convert.base64Decode(
    'ChVNZXNzYWdlc0ZldGNoUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIQCgNtc2'
    'cYAiABKAlSA21zZxInCg9jb252ZXJzYXRpb25faWQYAyABKAlSDmNvbnZlcnNhdGlvbklkEiwK'
    'CG1lc3NhZ2VzGAQgAygLMhAuY2MuTWVzc2FnZVByb3RvUghtZXNzYWdlcxIiCgpqdW1wX2luZG'
    'V4GAUgASgFSABSCWp1bXBJbmRleIgBARI1ChRhbmNob3JfbWVzc2FnZV9pbmRleBgGIAEoBUgB'
    'UhJhbmNob3JNZXNzYWdlSW5kZXiIAQFCDQoLX2p1bXBfaW5kZXhCFwoVX2FuY2hvcl9tZXNzYW'
    'dlX2luZGV4');

@$core.Deprecated('Use membershipMessageDescriptor instead')
const MembershipMessage$json = {
  '1': 'MembershipMessage',
  '2': [
    {'1': 'event_type', '3': 1, '4': 1, '5': 14, '6': '.cc.SystemEventType', '10': 'eventType'},
    {'1': 'actor', '3': 2, '4': 1, '5': 11, '6': '.cc.MemberInfo', '10': 'actor'},
    {'1': 'affected_members', '3': 3, '4': 3, '5': 11, '6': '.cc.MemberInfo', '10': 'affectedMembers'},
    {'1': 'event_timestamp', '3': 4, '4': 1, '5': 3, '10': 'eventTimestamp'},
    {'1': 'previous_role', '3': 5, '4': 1, '5': 5, '10': 'previousRole'},
    {'1': 'new_role', '3': 6, '4': 1, '5': 5, '10': 'newRole'},
    {'1': 'removal_reason', '3': 7, '4': 1, '5': 9, '10': 'removalReason'},
    {'1': 'invite_link', '3': 8, '4': 1, '5': 9, '10': 'inviteLink'},
    {'1': 'metadata', '3': 9, '4': 3, '5': 11, '6': '.cc.MembershipMessage.MetadataEntry', '10': 'metadata'},
  ],
  '3': [MembershipMessage_MetadataEntry$json],
};

@$core.Deprecated('Use membershipMessageDescriptor instead')
const MembershipMessage_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MembershipMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipMessageDescriptor = $convert.base64Decode(
    'ChFNZW1iZXJzaGlwTWVzc2FnZRIyCgpldmVudF90eXBlGAEgASgOMhMuY2MuU3lzdGVtRXZlbn'
    'RUeXBlUglldmVudFR5cGUSJAoFYWN0b3IYAiABKAsyDi5jYy5NZW1iZXJJbmZvUgVhY3RvchI5'
    'ChBhZmZlY3RlZF9tZW1iZXJzGAMgAygLMg4uY2MuTWVtYmVySW5mb1IPYWZmZWN0ZWRNZW1iZX'
    'JzEicKD2V2ZW50X3RpbWVzdGFtcBgEIAEoA1IOZXZlbnRUaW1lc3RhbXASIwoNcHJldmlvdXNf'
    'cm9sZRgFIAEoBVIMcHJldmlvdXNSb2xlEhkKCG5ld19yb2xlGAYgASgFUgduZXdSb2xlEiUKDn'
    'JlbW92YWxfcmVhc29uGAcgASgJUg1yZW1vdmFsUmVhc29uEh8KC2ludml0ZV9saW5rGAggASgJ'
    'UgppbnZpdGVMaW5rEj8KCG1ldGFkYXRhGAkgAygLMiMuY2MuTWVtYmVyc2hpcE1lc3NhZ2UuTW'
    'V0YWRhdGFFbnRyeVIIbWV0YWRhdGEaOwoNTWV0YWRhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tl'
    'eRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use memberInfoDescriptor instead')
const MemberInfo$json = {
  '1': 'MemberInfo',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'user_name', '3': 2, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'user_avatar', '3': 3, '4': 1, '5': 9, '10': 'userAvatar'},
    {'1': 'role', '3': 4, '4': 1, '5': 5, '10': 'role'},
    {'1': 'joined_at', '3': 5, '4': 1, '5': 3, '10': 'joinedAt'},
  ],
};

/// Descriptor for `MemberInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberInfoDescriptor = $convert.base64Decode(
    'CgpNZW1iZXJJbmZvEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCgl1c2VyX25hbWUYAiABKA'
    'lSCHVzZXJOYW1lEh8KC3VzZXJfYXZhdGFyGAMgASgJUgp1c2VyQXZhdGFyEhIKBHJvbGUYBCAB'
    'KAVSBHJvbGUSGwoJam9pbmVkX2F0GAUgASgDUghqb2luZWRBdA==');

@$core.Deprecated('Use messageEditRequestDescriptor instead')
const MessageEditRequest$json = {
  '1': 'MessageEditRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'new_text', '3': 3, '4': 1, '5': 9, '10': 'newText'},
  ],
};

/// Descriptor for `MessageEditRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageEditRequestDescriptor = $convert.base64Decode(
    'ChJNZXNzYWdlRWRpdFJlcXVlc3QSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEicKD2'
    'NvbnZlcnNhdGlvbl9pZBgCIAEoCVIOY29udmVyc2F0aW9uSWQSGQoIbmV3X3RleHQYAyABKAlS'
    'B25ld1RleHQ=');

@$core.Deprecated('Use messageEditResponseDescriptor instead')
const MessageEditResponse$json = {
  '1': 'MessageEditResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 4, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'edited_at', '3': 5, '4': 1, '5': 3, '10': 'editedAt'},
    {'1': 'new_text', '3': 6, '4': 1, '5': 9, '10': 'newText'},
  ],
};

/// Descriptor for `MessageEditResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageEditResponseDescriptor = $convert.base64Decode(
    'ChNNZXNzYWdlRWRpdFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSEAoDbXNnGA'
    'IgASgJUgNtc2cSHQoKbWVzc2FnZV9pZBgDIAEoCVIJbWVzc2FnZUlkEicKD2NvbnZlcnNhdGlv'
    'bl9pZBgEIAEoCVIOY29udmVyc2F0aW9uSWQSGwoJZWRpdGVkX2F0GAUgASgDUghlZGl0ZWRBdB'
    'IZCghuZXdfdGV4dBgGIAEoCVIHbmV3VGV4dA==');

@$core.Deprecated('Use messageRevokeRequestDescriptor instead')
const MessageRevokeRequest$json = {
  '1': 'MessageRevokeRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'temp_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'tempId', '17': true},
  ],
  '8': [
    {'1': '_temp_id'},
  ],
};

/// Descriptor for `MessageRevokeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageRevokeRequestDescriptor = $convert.base64Decode(
    'ChRNZXNzYWdlUmV2b2tlUmVxdWVzdBIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSJw'
    'oPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIcCgd0ZW1wX2lkGAMgASgJ'
    'SABSBnRlbXBJZIgBAUIKCghfdGVtcF9pZA==');

@$core.Deprecated('Use messageRevokeResponseDescriptor instead')
const MessageRevokeResponse$json = {
  '1': 'MessageRevokeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 4, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'revoked_at', '3': 5, '4': 1, '5': 3, '10': 'revokedAt'},
  ],
};

/// Descriptor for `MessageRevokeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageRevokeResponseDescriptor = $convert.base64Decode(
    'ChVNZXNzYWdlUmV2b2tlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIQCgNtc2'
    'cYAiABKAlSA21zZxIdCgptZXNzYWdlX2lkGAMgASgJUgltZXNzYWdlSWQSJwoPY29udmVyc2F0'
    'aW9uX2lkGAQgASgJUg5jb252ZXJzYXRpb25JZBIdCgpyZXZva2VkX2F0GAUgASgDUglyZXZva2'
    'VkQXQ=');

@$core.Deprecated('Use messageDeleteRequestDescriptor instead')
const MessageDeleteRequest$json = {
  '1': 'MessageDeleteRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'temp_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'tempId', '17': true},
  ],
  '8': [
    {'1': '_temp_id'},
  ],
};

/// Descriptor for `MessageDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDeleteRequestDescriptor = $convert.base64Decode(
    'ChRNZXNzYWdlRGVsZXRlUmVxdWVzdBIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSJw'
    'oPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIcCgd0ZW1wX2lkGAMgASgJ'
    'SABSBnRlbXBJZIgBAUIKCghfdGVtcF9pZA==');

@$core.Deprecated('Use messageDeleteResponseDescriptor instead')
const MessageDeleteResponse$json = {
  '1': 'MessageDeleteResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 4, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'deleted_at', '3': 5, '4': 1, '5': 3, '10': 'deletedAt'},
  ],
};

/// Descriptor for `MessageDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDeleteResponseDescriptor = $convert.base64Decode(
    'ChVNZXNzYWdlRGVsZXRlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIQCgNtc2'
    'cYAiABKAlSA21zZxIdCgptZXNzYWdlX2lkGAMgASgJUgltZXNzYWdlSWQSJwoPY29udmVyc2F0'
    'aW9uX2lkGAQgASgJUg5jb252ZXJzYXRpb25JZBIdCgpkZWxldGVkX2F0GAUgASgDUglkZWxldG'
    'VkQXQ=');

