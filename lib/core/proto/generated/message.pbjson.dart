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
    {'1': 'text', '2': 0},
    {'1': 'image', '2': 1},
    {'1': 'voice', '2': 2},
    {'1': 'file', '2': 3},
    {'1': 'video', '2': 4},
    {'1': 'location', '2': 5},
    {'1': 'system', '2': 6},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRIICgR0ZXh0EAASCQoFaW1hZ2UQARIJCgV2b2ljZRACEggKBGZpbGUQAx'
    'IJCgV2aWRlbxAEEgwKCGxvY2F0aW9uEAUSCgoGc3lzdGVtEAY=');

@$core.Deprecated('Use messageStatusDescriptor instead')
const MessageStatus$json = {
  '1': 'MessageStatus',
  '2': [
    {'1': 'sending', '2': 0},
    {'1': 'sent', '2': 1},
    {'1': 'delivered', '2': 2},
    {'1': 'read', '2': 3},
    {'1': 'failed', '2': 4},
  ],
};

/// Descriptor for `MessageStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageStatusDescriptor = $convert.base64Decode(
    'Cg1NZXNzYWdlU3RhdHVzEgsKB3NlbmRpbmcQABIICgRzZW50EAESDQoJZGVsaXZlcmVkEAISCA'
    'oEcmVhZBADEgoKBmZhaWxlZBAE');

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
    {'1': 'text_message', '3': 21, '4': 1, '5': 11, '6': '.cc.TextMessage', '9': 0, '10': 'textMessage'},
    {'1': 'media_message', '3': 22, '4': 1, '5': 11, '6': '.cc.MediaMessage', '9': 0, '10': 'mediaMessage'},
    {'1': 'location_message', '3': 23, '4': 1, '5': 11, '6': '.cc.LocationMessage', '9': 0, '10': 'locationMessage'},
    {'1': 'system_message', '3': 24, '4': 1, '5': 11, '6': '.cc.SystemMessage', '9': 0, '10': 'systemMessage'},
  ],
  '8': [
    {'1': 'content'},
  ],
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
    'F1b3RlZF9tZXNzYWdlX2lkGBQgASgJUg9xdW90ZWRNZXNzYWdlSWQSNAoMdGV4dF9tZXNzYWdl'
    'GBUgASgLMg8uY2MuVGV4dE1lc3NhZ2VIAFILdGV4dE1lc3NhZ2USNwoNbWVkaWFfbWVzc2FnZR'
    'gWIAEoCzIQLmNjLk1lZGlhTWVzc2FnZUgAUgxtZWRpYU1lc3NhZ2USQAoQbG9jYXRpb25fbWVz'
    'c2FnZRgXIAEoCzITLmNjLkxvY2F0aW9uTWVzc2FnZUgAUg9sb2NhdGlvbk1lc3NhZ2USOgoOc3'
    'lzdGVtX21lc3NhZ2UYGCABKAsyES5jYy5TeXN0ZW1NZXNzYWdlSABSDXN5c3RlbU1lc3NhZ2VC'
    'CQoHY29udGVudA==');

@$core.Deprecated('Use textMessageDescriptor instead')
const TextMessage$json = {
  '1': 'TextMessage',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `TextMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageDescriptor = $convert.base64Decode(
    'CgtUZXh0TWVzc2FnZRISCgR0ZXh0GAEgASgJUgR0ZXh0');

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
  ],
};

/// Descriptor for `MediaMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaMessageDescriptor = $convert.base64Decode(
    'CgxNZWRpYU1lc3NhZ2USGwoJbWVkaWFfdXJsGAEgASgJUghtZWRpYVVybBIdCgpsb2NhbF9wYX'
    'RoGAIgASgJUglsb2NhbFBhdGgSGgoIZHVyYXRpb24YAyABKAVSCGR1cmF0aW9uEhsKCWZpbGVf'
    'c2l6ZRgEIAEoAVIIZmlsZVNpemUSGwoJZmlsZV9uYW1lGAUgASgJUghmaWxlTmFtZRIjCg10aH'
    'VtYm5haWxfdXJsGAYgASgJUgx0aHVtYm5haWxVcmwSGwoJbWltZV90eXBlGAcgASgJUghtaW1l'
    'VHlwZQ==');

@$core.Deprecated('Use locationMessageDescriptor instead')
const LocationMessage$json = {
  '1': 'LocationMessage',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'location_address', '3': 3, '4': 1, '5': 9, '10': 'locationAddress'},
  ],
};

/// Descriptor for `LocationMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationMessageDescriptor = $convert.base64Decode(
    'Cg9Mb2NhdGlvbk1lc3NhZ2USGgoIbGF0aXR1ZGUYASABKAFSCGxhdGl0dWRlEhwKCWxvbmdpdH'
    'VkZRgCIAEoAVIJbG9uZ2l0dWRlEikKEGxvY2F0aW9uX2FkZHJlc3MYAyABKAlSD2xvY2F0aW9u'
    'QWRkcmVzcw==');

@$core.Deprecated('Use systemMessageDescriptor instead')
const SystemMessage$json = {
  '1': 'SystemMessage',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'action', '3': 2, '4': 1, '5': 9, '10': 'action'},
  ],
};

/// Descriptor for `SystemMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemMessageDescriptor = $convert.base64Decode(
    'Cg1TeXN0ZW1NZXNzYWdlEhIKBHRleHQYASABKAlSBHRleHQSFgoGYWN0aW9uGAIgASgJUgZhY3'
    'Rpb24=');

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

