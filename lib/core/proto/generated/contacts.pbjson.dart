//
//  Generated code. Do not modify.
//  source: contacts.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use friendRequestStatusDescriptor instead')
const FriendRequestStatus$json = {
  '1': 'FriendRequestStatus',
  '2': [
    {'1': 'pending', '2': 0},
    {'1': 'accepted', '2': 1},
    {'1': 'rejected', '2': 2},
  ],
};

/// Descriptor for `FriendRequestStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List friendRequestStatusDescriptor = $convert.base64Decode(
    'ChNGcmllbmRSZXF1ZXN0U3RhdHVzEgsKB3BlbmRpbmcQABIMCghhY2NlcHRlZBABEgwKCHJlam'
    'VjdGVkEAI=');

@$core.Deprecated('Use friendRequestProtoDescriptor instead')
const FriendRequestProto$json = {
  '1': 'FriendRequestProto',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'sender_id', '3': 2, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'sender_name', '3': 3, '4': 1, '5': 9, '10': 'senderName'},
    {'1': 'sender_avatar', '3': 4, '4': 1, '5': 9, '10': 'senderAvatar'},
    {'1': 'receiver_id', '3': 5, '4': 1, '5': 9, '10': 'receiverId'},
    {'1': 'message', '3': 6, '4': 1, '5': 9, '10': 'message'},
    {'1': 'status', '3': 7, '4': 1, '5': 14, '6': '.cc.FriendRequestStatus', '10': 'status'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'processed_at', '3': 9, '4': 1, '5': 3, '10': 'processedAt'},
  ],
};

/// Descriptor for `FriendRequestProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestProtoDescriptor = $convert.base64Decode(
    'ChJGcmllbmRSZXF1ZXN0UHJvdG8SHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEhsKCX'
    'NlbmRlcl9pZBgCIAEoCVIIc2VuZGVySWQSHwoLc2VuZGVyX25hbWUYAyABKAlSCnNlbmRlck5h'
    'bWUSIwoNc2VuZGVyX2F2YXRhchgEIAEoCVIMc2VuZGVyQXZhdGFyEh8KC3JlY2VpdmVyX2lkGA'
    'UgASgJUgpyZWNlaXZlcklkEhgKB21lc3NhZ2UYBiABKAlSB21lc3NhZ2USLwoGc3RhdHVzGAcg'
    'ASgOMhcuY2MuRnJpZW5kUmVxdWVzdFN0YXR1c1IGc3RhdHVzEh0KCmNyZWF0ZWRfYXQYCCABKA'
    'NSCWNyZWF0ZWRBdBIhCgxwcm9jZXNzZWRfYXQYCSABKANSC3Byb2Nlc3NlZEF0');

@$core.Deprecated('Use friendRequestCollectionDescriptor instead')
const FriendRequestCollection$json = {
  '1': 'FriendRequestCollection',
  '2': [
    {'1': 'requests', '3': 1, '4': 3, '5': 11, '6': '.cc.FriendRequestProto', '10': 'requests'},
  ],
};

/// Descriptor for `FriendRequestCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestCollectionDescriptor = $convert.base64Decode(
    'ChdGcmllbmRSZXF1ZXN0Q29sbGVjdGlvbhIyCghyZXF1ZXN0cxgBIAMoCzIWLmNjLkZyaWVuZF'
    'JlcXVlc3RQcm90b1IIcmVxdWVzdHM=');

@$core.Deprecated('Use syncContactsRequestDescriptor instead')
const SyncContactsRequest$json = {
  '1': 'SyncContactsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `SyncContactsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncContactsRequestDescriptor = $convert.base64Decode(
    'ChNTeW5jQ29udGFjdHNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIUCgV0b2tlbh'
    'gCIAEoCVIFdG9rZW4=');

@$core.Deprecated('Use syncContactsResponseDescriptor instead')
const SyncContactsResponse$json = {
  '1': 'SyncContactsResponse',
  '2': [
    {'1': 'contacts', '3': 1, '4': 3, '5': 11, '6': '.cc.UserProto', '10': 'contacts'},
  ],
};

/// Descriptor for `SyncContactsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncContactsResponseDescriptor = $convert.base64Decode(
    'ChRTeW5jQ29udGFjdHNSZXNwb25zZRIpCghjb250YWN0cxgBIAMoCzINLmNjLlVzZXJQcm90b1'
    'IIY29udGFjdHM=');

@$core.Deprecated('Use sendFriendRequestProtoDescriptor instead')
const SendFriendRequestProto$json = {
  '1': 'SendFriendRequestProto',
  '2': [
    {'1': 'sender_id', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'receiver_id', '3': 2, '4': 1, '5': 9, '10': 'receiverId'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SendFriendRequestProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendFriendRequestProtoDescriptor = $convert.base64Decode(
    'ChZTZW5kRnJpZW5kUmVxdWVzdFByb3RvEhsKCXNlbmRlcl9pZBgBIAEoCVIIc2VuZGVySWQSHw'
    'oLcmVjZWl2ZXJfaWQYAiABKAlSCnJlY2VpdmVySWQSGAoHbWVzc2FnZRgDIAEoCVIHbWVzc2Fn'
    'ZQ==');

@$core.Deprecated('Use processFriendRequestProtoDescriptor instead')
const ProcessFriendRequestProto$json = {
  '1': 'ProcessFriendRequestProto',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'status', '3': 2, '4': 1, '5': 14, '6': '.cc.FriendRequestStatus', '10': 'status'},
  ],
};

/// Descriptor for `ProcessFriendRequestProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processFriendRequestProtoDescriptor = $convert.base64Decode(
    'ChlQcm9jZXNzRnJpZW5kUmVxdWVzdFByb3RvEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3'
    'RJZBIvCgZzdGF0dXMYAiABKA4yFy5jYy5GcmllbmRSZXF1ZXN0U3RhdHVzUgZzdGF0dXM=');

