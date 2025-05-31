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
    {'1': 'LOCATION', '2': 5},
    {'1': 'SYSTEM', '2': 6},
    {'1': 'STICKER', '2': 7},
    {'1': 'GIF', '2': 8},
    {'1': 'CONTACT', '2': 9},
    {'1': 'POLL', '2': 10},
    {'1': 'LINK', '2': 11},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRIICgRURVhUEAASCQoFSU1BR0UQARIJCgVWT0lDRRACEggKBEZJTEUQAx'
    'IJCgVWSURFTxAEEgwKCExPQ0FUSU9OEAUSCgoGU1lTVEVNEAYSCwoHU1RJQ0tFUhAHEgcKA0dJ'
    'RhAIEgsKB0NPTlRBQ1QQCRIICgRQT0xMEAoSCAoETElOSxAL');

@$core.Deprecated('Use messageStatusDescriptor instead')
const MessageStatus$json = {
  '1': 'MessageStatus',
  '2': [
    {'1': 'SENDING', '2': 0},
    {'1': 'SENT', '2': 1},
    {'1': 'DELIVERED', '2': 2},
    {'1': 'READ', '2': 3},
    {'1': 'FAILED', '2': 4},
  ],
};

/// Descriptor for `MessageStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageStatusDescriptor = $convert.base64Decode(
    'Cg1NZXNzYWdlU3RhdHVzEgsKB1NFTkRJTkcQABIICgRTRU5UEAESDQoJREVMSVZFUkVEEAISCA'
    'oEUkVBRBADEgoKBkZBSUxFRBAE');

@$core.Deprecated('Use messageSyncTypeDescriptor instead')
const MessageSyncType$json = {
  '1': 'MessageSyncType',
  '2': [
    {'1': 'RECENT', '2': 0},
    {'1': 'UNREAD', '2': 1},
  ],
};

/// Descriptor for `MessageSyncType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageSyncTypeDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlU3luY1R5cGUSCgoGUkVDRU5UEAASCgoGVU5SRUFEEAE=');

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
    {'1': 'is_read', '3': 8, '4': 1, '5': 8, '10': 'isRead'},
    {'1': 'type', '3': 9, '4': 1, '5': 14, '6': '.cc.MessageType', '10': 'type'},
    {'1': 'status', '3': 10, '4': 1, '5': 14, '6': '.cc.MessageStatus', '10': 'status'},
    {'1': 'text', '3': 11, '4': 1, '5': 9, '10': 'text'},
    {'1': 'media_url', '3': 12, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'local_path', '3': 13, '4': 1, '5': 9, '10': 'localPath'},
    {'1': 'duration', '3': 14, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'file_size', '3': 15, '4': 1, '5': 1, '10': 'fileSize'},
    {'1': 'file_name', '3': 16, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'thumbnail_url', '3': 17, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'latitude', '3': 18, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 19, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'location_address', '3': 20, '4': 1, '5': 9, '10': 'locationAddress'},
    {'1': 'quoted_message_id', '3': 21, '4': 1, '5': 9, '10': 'quotedMessageId'},
    {'1': 'is_deleted', '3': 22, '4': 1, '5': 8, '10': 'isDeleted'},
    {'1': 'is_revoked', '3': 23, '4': 1, '5': 8, '10': 'isRevoked'},
    {'1': 'is_edited', '3': 24, '4': 1, '5': 8, '10': 'isEdited'},
    {'1': 'edited_at', '3': 25, '4': 1, '5': 3, '10': 'editedAt'},
    {'1': 'revoked_at', '3': 26, '4': 1, '5': 3, '10': 'revokedAt'},
    {'1': 'original_text', '3': 27, '4': 1, '5': 9, '10': 'originalText'},
    {'1': 'quoted_message_text', '3': 28, '4': 1, '5': 9, '10': 'quotedMessageText'},
    {'1': 'quoted_message_sender_name', '3': 29, '4': 1, '5': 9, '10': 'quotedMessageSenderName'},
    {'1': 'quoted_message_type', '3': 30, '4': 1, '5': 9, '10': 'quotedMessageType'},
    {'1': 'replied_to_message_id', '3': 31, '4': 1, '5': 9, '10': 'repliedToMessageId'},
    {'1': 'forwarded_from_conversation_id', '3': 32, '4': 1, '5': 9, '10': 'forwardedFromConversationId'},
    {'1': 'forwarded_from_message_id', '3': 33, '4': 1, '5': 9, '10': 'forwardedFromMessageId'},
    {'1': 'reactions', '3': 34, '4': 3, '5': 11, '6': '.cc.MessageProto.ReactionsEntry', '10': 'reactions'},
    {'1': 'priority', '3': 35, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'tags', '3': 36, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'is_pinned', '3': 37, '4': 1, '5': 8, '10': 'isPinned'},
    {'1': 'text_message', '3': 38, '4': 1, '5': 11, '6': '.cc.TextMessage', '9': 0, '10': 'textMessage'},
    {'1': 'media_message', '3': 39, '4': 1, '5': 11, '6': '.cc.MediaMessage', '9': 0, '10': 'mediaMessage'},
    {'1': 'location_message', '3': 40, '4': 1, '5': 11, '6': '.cc.LocationMessage', '9': 0, '10': 'locationMessage'},
    {'1': 'system_message', '3': 41, '4': 1, '5': 11, '6': '.cc.SystemMessage', '9': 0, '10': 'systemMessage'},
    {'1': 'sticker_message', '3': 42, '4': 1, '5': 11, '6': '.cc.StickerMessage', '9': 0, '10': 'stickerMessage'},
    {'1': 'contact_message', '3': 43, '4': 1, '5': 11, '6': '.cc.ContactMessage', '9': 0, '10': 'contactMessage'},
    {'1': 'poll_message', '3': 44, '4': 1, '5': 11, '6': '.cc.PollMessage', '9': 0, '10': 'pollMessage'},
    {'1': 'link_message', '3': 45, '4': 1, '5': 11, '6': '.cc.LinkMessage', '9': 0, '10': 'linkMessage'},
  ],
  '3': [MessageProto_ReactionsEntry$json],
  '8': [
    {'1': 'content'},
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
    'ZGF0ZWRfYXQYByABKANSCXVwZGF0ZWRBdBIXCgdpc19yZWFkGAggASgIUgZpc1JlYWQSIwoEdH'
    'lwZRgJIAEoDjIPLmNjLk1lc3NhZ2VUeXBlUgR0eXBlEikKBnN0YXR1cxgKIAEoDjIRLmNjLk1l'
    'c3NhZ2VTdGF0dXNSBnN0YXR1cxISCgR0ZXh0GAsgASgJUgR0ZXh0EhsKCW1lZGlhX3VybBgMIA'
    'EoCVIIbWVkaWFVcmwSHQoKbG9jYWxfcGF0aBgNIAEoCVIJbG9jYWxQYXRoEhoKCGR1cmF0aW9u'
    'GA4gASgFUghkdXJhdGlvbhIbCglmaWxlX3NpemUYDyABKAFSCGZpbGVTaXplEhsKCWZpbGVfbm'
    'FtZRgQIAEoCVIIZmlsZU5hbWUSIwoNdGh1bWJuYWlsX3VybBgRIAEoCVIMdGh1bWJuYWlsVXJs'
    'EhoKCGxhdGl0dWRlGBIgASgBUghsYXRpdHVkZRIcCglsb25naXR1ZGUYEyABKAFSCWxvbmdpdH'
    'VkZRIpChBsb2NhdGlvbl9hZGRyZXNzGBQgASgJUg9sb2NhdGlvbkFkZHJlc3MSKgoRcXVvdGVk'
    'X21lc3NhZ2VfaWQYFSABKAlSD3F1b3RlZE1lc3NhZ2VJZBIdCgppc19kZWxldGVkGBYgASgIUg'
    'lpc0RlbGV0ZWQSHQoKaXNfcmV2b2tlZBgXIAEoCFIJaXNSZXZva2VkEhsKCWlzX2VkaXRlZBgY'
    'IAEoCFIIaXNFZGl0ZWQSGwoJZWRpdGVkX2F0GBkgASgDUghlZGl0ZWRBdBIdCgpyZXZva2VkX2'
    'F0GBogASgDUglyZXZva2VkQXQSIwoNb3JpZ2luYWxfdGV4dBgbIAEoCVIMb3JpZ2luYWxUZXh0'
    'Ei4KE3F1b3RlZF9tZXNzYWdlX3RleHQYHCABKAlSEXF1b3RlZE1lc3NhZ2VUZXh0EjsKGnF1b3'
    'RlZF9tZXNzYWdlX3NlbmRlcl9uYW1lGB0gASgJUhdxdW90ZWRNZXNzYWdlU2VuZGVyTmFtZRIu'
    'ChNxdW90ZWRfbWVzc2FnZV90eXBlGB4gASgJUhFxdW90ZWRNZXNzYWdlVHlwZRIxChVyZXBsaW'
    'VkX3RvX21lc3NhZ2VfaWQYHyABKAlSEnJlcGxpZWRUb01lc3NhZ2VJZBJDCh5mb3J3YXJkZWRf'
    'ZnJvbV9jb252ZXJzYXRpb25faWQYICABKAlSG2ZvcndhcmRlZEZyb21Db252ZXJzYXRpb25JZB'
    'I5Chlmb3J3YXJkZWRfZnJvbV9tZXNzYWdlX2lkGCEgASgJUhZmb3J3YXJkZWRGcm9tTWVzc2Fn'
    'ZUlkEj0KCXJlYWN0aW9ucxgiIAMoCzIfLmNjLk1lc3NhZ2VQcm90by5SZWFjdGlvbnNFbnRyeV'
    'IJcmVhY3Rpb25zEhoKCHByaW9yaXR5GCMgASgJUghwcmlvcml0eRISCgR0YWdzGCQgAygJUgR0'
    'YWdzEhsKCWlzX3Bpbm5lZBglIAEoCFIIaXNQaW5uZWQSNAoMdGV4dF9tZXNzYWdlGCYgASgLMg'
    '8uY2MuVGV4dE1lc3NhZ2VIAFILdGV4dE1lc3NhZ2USNwoNbWVkaWFfbWVzc2FnZRgnIAEoCzIQ'
    'LmNjLk1lZGlhTWVzc2FnZUgAUgxtZWRpYU1lc3NhZ2USQAoQbG9jYXRpb25fbWVzc2FnZRgoIA'
    'EoCzITLmNjLkxvY2F0aW9uTWVzc2FnZUgAUg9sb2NhdGlvbk1lc3NhZ2USOgoOc3lzdGVtX21l'
    'c3NhZ2UYKSABKAsyES5jYy5TeXN0ZW1NZXNzYWdlSABSDXN5c3RlbU1lc3NhZ2USPQoPc3RpY2'
    'tlcl9tZXNzYWdlGCogASgLMhIuY2MuU3RpY2tlck1lc3NhZ2VIAFIOc3RpY2tlck1lc3NhZ2US'
    'PQoPY29udGFjdF9tZXNzYWdlGCsgASgLMhIuY2MuQ29udGFjdE1lc3NhZ2VIAFIOY29udGFjdE'
    '1lc3NhZ2USNAoMcG9sbF9tZXNzYWdlGCwgASgLMg8uY2MuUG9sbE1lc3NhZ2VIAFILcG9sbE1l'
    'c3NhZ2USNAoMbGlua19tZXNzYWdlGC0gASgLMg8uY2MuTGlua01lc3NhZ2VIAFILbGlua01lc3'
    'NhZ2UaPAoOUmVhY3Rpb25zRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAVS'
    'BXZhbHVlOgI4AUIJCgdjb250ZW50');

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

@$core.Deprecated('Use locationMessageDescriptor instead')
const LocationMessage$json = {
  '1': 'LocationMessage',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'location_address', '3': 3, '4': 1, '5': 9, '10': 'locationAddress'},
    {'1': 'location_name', '3': 4, '4': 1, '5': 9, '10': 'locationName'},
    {'1': 'accuracy', '3': 5, '4': 1, '5': 1, '10': 'accuracy'},
  ],
};

/// Descriptor for `LocationMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationMessageDescriptor = $convert.base64Decode(
    'Cg9Mb2NhdGlvbk1lc3NhZ2USGgoIbGF0aXR1ZGUYASABKAFSCGxhdGl0dWRlEhwKCWxvbmdpdH'
    'VkZRgCIAEoAVIJbG9uZ2l0dWRlEikKEGxvY2F0aW9uX2FkZHJlc3MYAyABKAlSD2xvY2F0aW9u'
    'QWRkcmVzcxIjCg1sb2NhdGlvbl9uYW1lGAQgASgJUgxsb2NhdGlvbk5hbWUSGgoIYWNjdXJhY3'
    'kYBSABKAFSCGFjY3VyYWN5');

@$core.Deprecated('Use systemMessageDescriptor instead')
const SystemMessage$json = {
  '1': 'SystemMessage',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'action', '3': 2, '4': 1, '5': 9, '10': 'action'},
    {'1': 'params', '3': 3, '4': 3, '5': 11, '6': '.cc.SystemMessage.ParamsEntry', '10': 'params'},
  ],
  '3': [SystemMessage_ParamsEntry$json],
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

/// Descriptor for `SystemMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemMessageDescriptor = $convert.base64Decode(
    'Cg1TeXN0ZW1NZXNzYWdlEhIKBHRleHQYASABKAlSBHRleHQSFgoGYWN0aW9uGAIgASgJUgZhY3'
    'Rpb24SNQoGcGFyYW1zGAMgAygLMh0uY2MuU3lzdGVtTWVzc2FnZS5QYXJhbXNFbnRyeVIGcGFy'
    'YW1zGjkKC1BhcmFtc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YW'
    'x1ZToCOAE=');

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

@$core.Deprecated('Use messageCollectionDescriptor instead')
const MessageCollection$json = {
  '1': 'MessageCollection',
  '2': [
    {'1': 'messages', '3': 1, '4': 3, '5': 11, '6': '.cc.MessageProto', '10': 'messages'},
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'has_more', '3': 3, '4': 1, '5': 8, '10': 'hasMore'},
    {'1': 'next_cursor', '3': 4, '4': 1, '5': 9, '10': 'nextCursor'},
  ],
};

/// Descriptor for `MessageCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageCollectionDescriptor = $convert.base64Decode(
    'ChFNZXNzYWdlQ29sbGVjdGlvbhIsCghtZXNzYWdlcxgBIAMoCzIQLmNjLk1lc3NhZ2VQcm90b1'
    'IIbWVzc2FnZXMSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291bnQSGQoIaGFzX21vcmUY'
    'AyABKAhSB2hhc01vcmUSHwoLbmV4dF9jdXJzb3IYBCABKAlSCm5leHRDdXJzb3I=');

@$core.Deprecated('Use messageResponseDescriptor instead')
const MessageResponse$json = {
  '1': 'MessageResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `MessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageResponseDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGA'
    'IgASgJUgdtZXNzYWdlEh0KCm1lc3NhZ2VfaWQYAyABKAlSCW1lc3NhZ2VJZBIcCgl0aW1lc3Rh'
    'bXAYBCABKANSCXRpbWVzdGFtcA==');

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

@$core.Deprecated('Use dailyMessageCountDescriptor instead')
const DailyMessageCount$json = {
  '1': 'DailyMessageCount',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `DailyMessageCount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dailyMessageCountDescriptor = $convert.base64Decode(
    'ChFEYWlseU1lc3NhZ2VDb3VudBISCgRkYXRlGAEgASgJUgRkYXRlEhQKBWNvdW50GAIgASgFUg'
    'Vjb3VudA==');

@$core.Deprecated('Use messageSyncRequestDescriptor instead')
const MessageSyncRequest$json = {
  '1': 'MessageSyncRequest',
  '2': [
    {'1': 'sync_type', '3': 1, '4': 1, '5': 14, '6': '.cc.MessageSyncType', '10': 'syncType'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'anchor_message_id', '3': 3, '4': 1, '5': 9, '10': 'anchorMessageId'},
    {'1': 'local_oldest_message_id', '3': 4, '4': 1, '5': 9, '10': 'localOldestMessageId'},
    {'1': 'local_newest_message_id', '3': 5, '4': 1, '5': 9, '10': 'localNewestMessageId'},
    {'1': 'messages_before_anchor', '3': 6, '4': 1, '5': 5, '10': 'messagesBeforeAnchor'},
    {'1': 'messages_after_anchor', '3': 7, '4': 1, '5': 5, '10': 'messagesAfterAnchor'},
    {'1': 'daily_counts', '3': 8, '4': 3, '5': 11, '6': '.cc.DailyMessageCount', '10': 'dailyCounts'},
  ],
};

/// Descriptor for `MessageSyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSyncRequestDescriptor = $convert.base64Decode(
    'ChJNZXNzYWdlU3luY1JlcXVlc3QSMAoJc3luY190eXBlGAEgASgOMhMuY2MuTWVzc2FnZVN5bm'
    'NUeXBlUghzeW5jVHlwZRInCg9jb252ZXJzYXRpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklk'
    'EioKEWFuY2hvcl9tZXNzYWdlX2lkGAMgASgJUg9hbmNob3JNZXNzYWdlSWQSNQoXbG9jYWxfb2'
    'xkZXN0X21lc3NhZ2VfaWQYBCABKAlSFGxvY2FsT2xkZXN0TWVzc2FnZUlkEjUKF2xvY2FsX25l'
    'd2VzdF9tZXNzYWdlX2lkGAUgASgJUhRsb2NhbE5ld2VzdE1lc3NhZ2VJZBI0ChZtZXNzYWdlc1'
    '9iZWZvcmVfYW5jaG9yGAYgASgFUhRtZXNzYWdlc0JlZm9yZUFuY2hvchIyChVtZXNzYWdlc19h'
    'ZnRlcl9hbmNob3IYByABKAVSE21lc3NhZ2VzQWZ0ZXJBbmNob3ISOAoMZGFpbHlfY291bnRzGA'
    'ggAygLMhUuY2MuRGFpbHlNZXNzYWdlQ291bnRSC2RhaWx5Q291bnRz');

@$core.Deprecated('Use messageSyncResponseDescriptor instead')
const MessageSyncResponse$json = {
  '1': 'MessageSyncResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'messages', '3': 3, '4': 1, '5': 11, '6': '.cc.MessageCollection', '10': 'messages'},
  ],
};

/// Descriptor for `MessageSyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSyncResponseDescriptor = $convert.base64Decode(
    'ChNNZXNzYWdlU3luY1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSJwoPY29udm'
    'Vyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIxCghtZXNzYWdlcxgDIAEoCzIVLmNj'
    'Lk1lc3NhZ2VDb2xsZWN0aW9uUghtZXNzYWdlcw==');

@$core.Deprecated('Use batchMessageSyncRequestDescriptor instead')
const BatchMessageSyncRequest$json = {
  '1': 'BatchMessageSyncRequest',
  '2': [
    {'1': 'sync_requests', '3': 1, '4': 3, '5': 11, '6': '.cc.MessageSyncRequest', '10': 'syncRequests'},
    {'1': 'max_concurrent', '3': 2, '4': 1, '5': 5, '10': 'maxConcurrent'},
  ],
};

/// Descriptor for `BatchMessageSyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchMessageSyncRequestDescriptor = $convert.base64Decode(
    'ChdCYXRjaE1lc3NhZ2VTeW5jUmVxdWVzdBI7Cg1zeW5jX3JlcXVlc3RzGAEgAygLMhYuY2MuTW'
    'Vzc2FnZVN5bmNSZXF1ZXN0UgxzeW5jUmVxdWVzdHMSJQoObWF4X2NvbmN1cnJlbnQYAiABKAVS'
    'DW1heENvbmN1cnJlbnQ=');

@$core.Deprecated('Use batchMessageSyncResponseDescriptor instead')
const BatchMessageSyncResponse$json = {
  '1': 'BatchMessageSyncResponse',
  '2': [
    {'1': 'sync_responses', '3': 1, '4': 3, '5': 11, '6': '.cc.MessageSyncResponse', '10': 'syncResponses'},
    {'1': 'success_count', '3': 2, '4': 1, '5': 5, '10': 'successCount'},
    {'1': 'failure_count', '3': 3, '4': 1, '5': 5, '10': 'failureCount'},
  ],
};

/// Descriptor for `BatchMessageSyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchMessageSyncResponseDescriptor = $convert.base64Decode(
    'ChhCYXRjaE1lc3NhZ2VTeW5jUmVzcG9uc2USPgoOc3luY19yZXNwb25zZXMYASADKAsyFy5jYy'
    '5NZXNzYWdlU3luY1Jlc3BvbnNlUg1zeW5jUmVzcG9uc2VzEiMKDXN1Y2Nlc3NfY291bnQYAiAB'
    'KAVSDHN1Y2Nlc3NDb3VudBIjCg1mYWlsdXJlX2NvdW50GAMgASgFUgxmYWlsdXJlQ291bnQ=');

