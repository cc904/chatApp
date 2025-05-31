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
    {'1': 'is_read', '3': 7, '4': 1, '5': 8, '10': 'isRead'},
    {'1': 'status', '3': 8, '4': 1, '5': 9, '10': 'status'},
    {'1': 'type', '3': 9, '4': 1, '5': 14, '6': '.cc.MessageType', '10': 'type'},
    {'1': 'text', '3': 10, '4': 1, '5': 9, '10': 'text'},
    {'1': 'media_url', '3': 11, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'local_path', '3': 12, '4': 1, '5': 9, '10': 'localPath'},
    {'1': 'duration', '3': 13, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'file_size', '3': 14, '4': 1, '5': 1, '10': 'fileSize'},
    {'1': 'file_name', '3': 15, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'thumbnail_url', '3': 16, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'latitude', '3': 17, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 18, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'location_address', '3': 19, '4': 1, '5': 9, '10': 'locationAddress'},
    {'1': 'quoted_message_id', '3': 20, '4': 1, '5': 9, '10': 'quotedMessageId'},
    {'1': 'is_deleted', '3': 21, '4': 1, '5': 8, '10': 'isDeleted'},
    {'1': 'is_revoked', '3': 22, '4': 1, '5': 8, '10': 'isRevoked'},
    {'1': 'is_edited', '3': 23, '4': 1, '5': 8, '10': 'isEdited'},
    {'1': 'edited_at', '3': 24, '4': 1, '5': 3, '10': 'editedAt'},
    {'1': 'revoked_at', '3': 25, '4': 1, '5': 3, '10': 'revokedAt'},
    {'1': 'original_text', '3': 26, '4': 1, '5': 9, '10': 'originalText'},
    {'1': 'quoted_message_text', '3': 27, '4': 1, '5': 9, '10': 'quotedMessageText'},
    {'1': 'quoted_message_sender_name', '3': 28, '4': 1, '5': 9, '10': 'quotedMessageSenderName'},
    {'1': 'quoted_message_type', '3': 29, '4': 1, '5': 9, '10': 'quotedMessageType'},
    {'1': 'replied_to_message_id', '3': 30, '4': 1, '5': 9, '10': 'repliedToMessageId'},
    {'1': 'forwarded_from_conversation_id', '3': 31, '4': 1, '5': 9, '10': 'forwardedFromConversationId'},
    {'1': 'forwarded_from_message_id', '3': 32, '4': 1, '5': 9, '10': 'forwardedFromMessageId'},
    {'1': 'reactions', '3': 33, '4': 3, '5': 11, '6': '.cc.MessageProto.ReactionsEntry', '10': 'reactions'},
    {'1': 'priority', '3': 34, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'tags', '3': 35, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'is_pinned', '3': 36, '4': 1, '5': 8, '10': 'isPinned'},
    {'1': 'text_message', '3': 37, '4': 1, '5': 11, '6': '.cc.TextMessage', '9': 0, '10': 'textMessage'},
    {'1': 'media_message', '3': 38, '4': 1, '5': 11, '6': '.cc.MediaMessage', '9': 0, '10': 'mediaMessage'},
    {'1': 'location_message', '3': 39, '4': 1, '5': 11, '6': '.cc.LocationMessage', '9': 0, '10': 'locationMessage'},
    {'1': 'system_message', '3': 40, '4': 1, '5': 11, '6': '.cc.SystemMessage', '9': 0, '10': 'systemMessage'},
    {'1': 'sticker_message', '3': 41, '4': 1, '5': 11, '6': '.cc.StickerMessage', '9': 0, '10': 'stickerMessage'},
    {'1': 'contact_message', '3': 42, '4': 1, '5': 11, '6': '.cc.ContactMessage', '9': 0, '10': 'contactMessage'},
    {'1': 'poll_message', '3': 43, '4': 1, '5': 11, '6': '.cc.PollMessage', '9': 0, '10': 'pollMessage'},
    {'1': 'link_message', '3': 44, '4': 1, '5': 11, '6': '.cc.LinkMessage', '9': 0, '10': 'linkMessage'},
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
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MessageProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageProtoDescriptor = $convert.base64Decode(
    'CgxNZXNzYWdlUHJvdG8SHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEicKD2NvbnZlcn'
    'NhdGlvbl9pZBgCIAEoCVIOY29udmVyc2F0aW9uSWQSGwoJc2VuZGVyX2lkGAMgASgJUghzZW5k'
    'ZXJJZBIfCgtzZW5kZXJfbmFtZRgEIAEoCVIKc2VuZGVyTmFtZRIjCg1zZW5kZXJfYXZhdGFyGA'
    'UgASgJUgxzZW5kZXJBdmF0YXISHQoKY3JlYXRlZF9hdBgGIAEoA1IJY3JlYXRlZEF0EhcKB2lz'
    'X3JlYWQYByABKAhSBmlzUmVhZBIWCgZzdGF0dXMYCCABKAlSBnN0YXR1cxIjCgR0eXBlGAkgAS'
    'gOMg8uY2MuTWVzc2FnZVR5cGVSBHR5cGUSEgoEdGV4dBgKIAEoCVIEdGV4dBIbCgltZWRpYV91'
    'cmwYCyABKAlSCG1lZGlhVXJsEh0KCmxvY2FsX3BhdGgYDCABKAlSCWxvY2FsUGF0aBIaCghkdX'
    'JhdGlvbhgNIAEoBVIIZHVyYXRpb24SGwoJZmlsZV9zaXplGA4gASgBUghmaWxlU2l6ZRIbCglm'
    'aWxlX25hbWUYDyABKAlSCGZpbGVOYW1lEiMKDXRodW1ibmFpbF91cmwYECABKAlSDHRodW1ibm'
    'FpbFVybBIaCghsYXRpdHVkZRgRIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGBIgASgBUgls'
    'b25naXR1ZGUSKQoQbG9jYXRpb25fYWRkcmVzcxgTIAEoCVIPbG9jYXRpb25BZGRyZXNzEioKEX'
    'F1b3RlZF9tZXNzYWdlX2lkGBQgASgJUg9xdW90ZWRNZXNzYWdlSWQSHQoKaXNfZGVsZXRlZBgV'
    'IAEoCFIJaXNEZWxldGVkEh0KCmlzX3Jldm9rZWQYFiABKAhSCWlzUmV2b2tlZBIbCglpc19lZG'
    'l0ZWQYFyABKAhSCGlzRWRpdGVkEhsKCWVkaXRlZF9hdBgYIAEoA1IIZWRpdGVkQXQSHQoKcmV2'
    'b2tlZF9hdBgZIAEoA1IJcmV2b2tlZEF0EiMKDW9yaWdpbmFsX3RleHQYGiABKAlSDG9yaWdpbm'
    'FsVGV4dBIuChNxdW90ZWRfbWVzc2FnZV90ZXh0GBsgASgJUhFxdW90ZWRNZXNzYWdlVGV4dBI7'
    'ChpxdW90ZWRfbWVzc2FnZV9zZW5kZXJfbmFtZRgcIAEoCVIXcXVvdGVkTWVzc2FnZVNlbmRlck'
    '5hbWUSLgoTcXVvdGVkX21lc3NhZ2VfdHlwZRgdIAEoCVIRcXVvdGVkTWVzc2FnZVR5cGUSMQoV'
    'cmVwbGllZF90b19tZXNzYWdlX2lkGB4gASgJUhJyZXBsaWVkVG9NZXNzYWdlSWQSQwoeZm9yd2'
    'FyZGVkX2Zyb21fY29udmVyc2F0aW9uX2lkGB8gASgJUhtmb3J3YXJkZWRGcm9tQ29udmVyc2F0'
    'aW9uSWQSOQoZZm9yd2FyZGVkX2Zyb21fbWVzc2FnZV9pZBggIAEoCVIWZm9yd2FyZGVkRnJvbU'
    '1lc3NhZ2VJZBI9CglyZWFjdGlvbnMYISADKAsyHy5jYy5NZXNzYWdlUHJvdG8uUmVhY3Rpb25z'
    'RW50cnlSCXJlYWN0aW9ucxIaCghwcmlvcml0eRgiIAEoCVIIcHJpb3JpdHkSEgoEdGFncxgjIA'
    'MoCVIEdGFncxIbCglpc19waW5uZWQYJCABKAhSCGlzUGlubmVkEjQKDHRleHRfbWVzc2FnZRgl'
    'IAEoCzIPLmNjLlRleHRNZXNzYWdlSABSC3RleHRNZXNzYWdlEjcKDW1lZGlhX21lc3NhZ2UYJi'
    'ABKAsyEC5jYy5NZWRpYU1lc3NhZ2VIAFIMbWVkaWFNZXNzYWdlEkAKEGxvY2F0aW9uX21lc3Nh'
    'Z2UYJyABKAsyEy5jYy5Mb2NhdGlvbk1lc3NhZ2VIAFIPbG9jYXRpb25NZXNzYWdlEjoKDnN5c3'
    'RlbV9tZXNzYWdlGCggASgLMhEuY2MuU3lzdGVtTWVzc2FnZUgAUg1zeXN0ZW1NZXNzYWdlEj0K'
    'D3N0aWNrZXJfbWVzc2FnZRgpIAEoCzISLmNjLlN0aWNrZXJNZXNzYWdlSABSDnN0aWNrZXJNZX'
    'NzYWdlEj0KD2NvbnRhY3RfbWVzc2FnZRgqIAEoCzISLmNjLkNvbnRhY3RNZXNzYWdlSABSDmNv'
    'bnRhY3RNZXNzYWdlEjQKDHBvbGxfbWVzc2FnZRgrIAEoCzIPLmNjLlBvbGxNZXNzYWdlSABSC3'
    'BvbGxNZXNzYWdlEjQKDGxpbmtfbWVzc2FnZRgsIAEoCzIPLmNjLkxpbmtNZXNzYWdlSABSC2xp'
    'bmtNZXNzYWdlGjwKDlJlYWN0aW9uc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGA'
    'IgASgJUgV2YWx1ZToCOAFCCQoHY29udGVudA==');

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
  ],
};

/// Descriptor for `MessageCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageCollectionDescriptor = $convert.base64Decode(
    'ChFNZXNzYWdlQ29sbGVjdGlvbhIsCghtZXNzYWdlcxgBIAMoCzIQLmNjLk1lc3NhZ2VQcm90b1'
    'IIbWVzc2FnZXM=');

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
    {'1': 'is_typing', '3': 2, '4': 1, '5': 8, '10': 'isTyping'},
  ],
};

/// Descriptor for `TypingProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingProtoDescriptor = $convert.base64Decode(
    'CgtUeXBpbmdQcm90bxInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdGlvbklkEh'
    'sKCWlzX3R5cGluZxgCIAEoCFIIaXNUeXBpbmc=');

@$core.Deprecated('Use messageReadProtoDescriptor instead')
const MessageReadProto$json = {
  '1': 'MessageReadProto',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `MessageReadProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReadProtoDescriptor = $convert.base64Decode(
    'ChBNZXNzYWdlUmVhZFByb3RvEh0KCm1lc3NhZ2VfaWQYASABKAlSCW1lc3NhZ2VJZBInCg9jb2'
    '52ZXJzYXRpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklk');

