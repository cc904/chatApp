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
    {'1': 'PENDING', '2': 0},
    {'1': 'ACCEPTED', '2': 1},
    {'1': 'REJECTED', '2': 2},
  ],
};

/// Descriptor for `FriendRequestStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List friendRequestStatusDescriptor = $convert.base64Decode(
    'ChNGcmllbmRSZXF1ZXN0U3RhdHVzEgsKB1BFTkRJTkcQABIMCghBQ0NFUFRFRBABEgwKCFJFSk'
    'VDVEVEEAI=');

@$core.Deprecated('Use friendRequestProtoDescriptor instead')
const FriendRequestProto$json = {
  '1': 'FriendRequestProto',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'sender_id', '3': 2, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'receiver_id', '3': 3, '4': 1, '5': 9, '10': 'receiverId'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.cc.FriendRequestStatus', '10': 'status'},
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
    {'1': 'sent_at', '3': 6, '4': 1, '5': 3, '10': 'sentAt'},
    {'1': 'processed_at', '3': 7, '4': 1, '5': 3, '10': 'processedAt'},
  ],
};

/// Descriptor for `FriendRequestProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestProtoDescriptor = $convert.base64Decode(
    'ChJGcmllbmRSZXF1ZXN0UHJvdG8SHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEhsKCX'
    'NlbmRlcl9pZBgCIAEoCVIIc2VuZGVySWQSHwoLcmVjZWl2ZXJfaWQYAyABKAlSCnJlY2VpdmVy'
    'SWQSLwoGc3RhdHVzGAQgASgOMhcuY2MuRnJpZW5kUmVxdWVzdFN0YXR1c1IGc3RhdHVzEhgKB2'
    '1lc3NhZ2UYBSABKAlSB21lc3NhZ2USFwoHc2VudF9hdBgGIAEoA1IGc2VudEF0EiEKDHByb2Nl'
    'c3NlZF9hdBgHIAEoA1ILcHJvY2Vzc2VkQXQ=');

@$core.Deprecated('Use syncContactsRequestDescriptor instead')
const SyncContactsRequest$json = {
  '1': 'SyncContactsRequest',
};

/// Descriptor for `SyncContactsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncContactsRequestDescriptor = $convert.base64Decode(
    'ChNTeW5jQ29udGFjdHNSZXF1ZXN0');

@$core.Deprecated('Use syncContactsResponseDescriptor instead')
const SyncContactsResponse$json = {
  '1': 'SyncContactsResponse',
  '2': [
    {'1': 'contacts', '3': 1, '4': 3, '5': 11, '6': '.cc.UserProto', '10': 'contacts'},
    {'1': 'sync_time', '3': 2, '4': 1, '5': 3, '10': 'syncTime'},
  ],
};

/// Descriptor for `SyncContactsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncContactsResponseDescriptor = $convert.base64Decode(
    'ChRTeW5jQ29udGFjdHNSZXNwb25zZRIpCghjb250YWN0cxgBIAMoCzINLmNjLlVzZXJQcm90b1'
    'IIY29udGFjdHMSGwoJc3luY190aW1lGAIgASgDUghzeW5jVGltZQ==');

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
    {'1': 'reject_reason', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'rejectReason', '17': true},
  ],
  '8': [
    {'1': '_reject_reason'},
  ],
};

/// Descriptor for `ProcessFriendRequestProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processFriendRequestProtoDescriptor = $convert.base64Decode(
    'ChlQcm9jZXNzRnJpZW5kUmVxdWVzdFByb3RvEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3'
    'RJZBIvCgZzdGF0dXMYAiABKA4yFy5jYy5GcmllbmRSZXF1ZXN0U3RhdHVzUgZzdGF0dXMSKAoN'
    'cmVqZWN0X3JlYXNvbhgDIAEoCUgAUgxyZWplY3RSZWFzb26IAQFCEAoOX3JlamVjdF9yZWFzb2'
    '4=');

@$core.Deprecated('Use getFriendsRequestDescriptor instead')
const GetFriendsRequest$json = {
  '1': 'GetFriendsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetFriendsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFriendsRequestDescriptor = $convert.base64Decode(
    'ChFHZXRGcmllbmRzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQ=');

@$core.Deprecated('Use getFriendsResponseDescriptor instead')
const GetFriendsResponse$json = {
  '1': 'GetFriendsResponse',
  '2': [
    {'1': 'friends', '3': 1, '4': 3, '5': 11, '6': '.cc.UserProto', '10': 'friends'},
  ],
};

/// Descriptor for `GetFriendsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFriendsResponseDescriptor = $convert.base64Decode(
    'ChJHZXRGcmllbmRzUmVzcG9uc2USJwoHZnJpZW5kcxgBIAMoCzINLmNjLlVzZXJQcm90b1IHZn'
    'JpZW5kcw==');

@$core.Deprecated('Use getFriendRequestsRequestDescriptor instead')
const GetFriendRequestsRequest$json = {
  '1': 'GetFriendRequestsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'status', '3': 2, '4': 1, '5': 14, '6': '.cc.FriendRequestStatus', '9': 0, '10': 'status', '17': true},
  ],
  '8': [
    {'1': '_status'},
  ],
};

/// Descriptor for `GetFriendRequestsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFriendRequestsRequestDescriptor = $convert.base64Decode(
    'ChhHZXRGcmllbmRSZXF1ZXN0c1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEjQKBn'
    'N0YXR1cxgCIAEoDjIXLmNjLkZyaWVuZFJlcXVlc3RTdGF0dXNIAFIGc3RhdHVziAEBQgkKB19z'
    'dGF0dXM=');

@$core.Deprecated('Use getFriendRequestsResponseDescriptor instead')
const GetFriendRequestsResponse$json = {
  '1': 'GetFriendRequestsResponse',
  '2': [
    {'1': 'requests', '3': 1, '4': 3, '5': 11, '6': '.cc.FriendRequestProto', '10': 'requests'},
  ],
};

/// Descriptor for `GetFriendRequestsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFriendRequestsResponseDescriptor = $convert.base64Decode(
    'ChlHZXRGcmllbmRSZXF1ZXN0c1Jlc3BvbnNlEjIKCHJlcXVlc3RzGAEgAygLMhYuY2MuRnJpZW'
    '5kUmVxdWVzdFByb3RvUghyZXF1ZXN0cw==');

@$core.Deprecated('Use deleteFriendRequestDescriptor instead')
const DeleteFriendRequest$json = {
  '1': 'DeleteFriendRequest',
  '2': [
    {'1': 'friend_id', '3': 1, '4': 1, '5': 9, '10': 'friendId'},
  ],
};

/// Descriptor for `DeleteFriendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFriendRequestDescriptor = $convert.base64Decode(
    'ChNEZWxldGVGcmllbmRSZXF1ZXN0EhsKCWZyaWVuZF9pZBgBIAEoCVIIZnJpZW5kSWQ=');

@$core.Deprecated('Use deleteFriendResponseDescriptor instead')
const DeleteFriendResponse$json = {
  '1': 'DeleteFriendResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `DeleteFriendResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFriendResponseDescriptor = $convert.base64Decode(
    'ChREZWxldGVGcmllbmRSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiMKDWVycm'
    '9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZQ==');

@$core.Deprecated('Use updateContactRequestDescriptor instead')
const UpdateContactRequest$json = {
  '1': 'UpdateContactRequest',
  '2': [
    {'1': 'contact_id', '3': 1, '4': 1, '5': 9, '10': 'contactId'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'nickname', '17': true},
    {'1': 'remark', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'remark', '17': true},
    {'1': 'blocked', '3': 4, '4': 1, '5': 8, '9': 2, '10': 'blocked', '17': true},
    {'1': 'is_favorite', '3': 5, '4': 1, '5': 8, '9': 3, '10': 'isFavorite', '17': true},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '8': [
    {'1': '_nickname'},
    {'1': '_remark'},
    {'1': '_blocked'},
    {'1': '_is_favorite'},
  ],
};

/// Descriptor for `UpdateContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateContactRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVDb250YWN0UmVxdWVzdBIdCgpjb250YWN0X2lkGAEgASgJUgljb250YWN0SWQSHw'
    'oIbmlja25hbWUYAiABKAlIAFIIbmlja25hbWWIAQESGwoGcmVtYXJrGAMgASgJSAFSBnJlbWFy'
    'a4gBARIdCgdibG9ja2VkGAQgASgISAJSB2Jsb2NrZWSIAQESJAoLaXNfZmF2b3JpdGUYBSABKA'
    'hIA1IKaXNGYXZvcml0ZYgBARIcCgl0aW1lc3RhbXAYBiABKANSCXRpbWVzdGFtcEILCglfbmlj'
    'a25hbWVCCQoHX3JlbWFya0IKCghfYmxvY2tlZEIOCgxfaXNfZmF2b3JpdGU=');

@$core.Deprecated('Use updateContactResponseDescriptor instead')
const UpdateContactResponse$json = {
  '1': 'UpdateContactResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'contact', '3': 3, '4': 1, '5': 11, '6': '.cc.UserProto', '10': 'contact'},
    {'1': 'updated_fields', '3': 4, '4': 3, '5': 9, '10': 'updatedFields'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UpdateContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateContactResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVDb250YWN0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZX'
    'NzYWdlGAIgASgJUgdtZXNzYWdlEicKB2NvbnRhY3QYAyABKAsyDS5jYy5Vc2VyUHJvdG9SB2Nv'
    'bnRhY3QSJQoOdXBkYXRlZF9maWVsZHMYBCADKAlSDXVwZGF0ZWRGaWVsZHMSHAoJdGltZXN0YW'
    '1wGAUgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use contactUpdateEventDescriptor instead')
const ContactUpdateEvent$json = {
  '1': 'ContactUpdateEvent',
  '2': [
    {'1': 'contact', '3': 1, '4': 1, '5': 11, '6': '.cc.UserProto', '10': 'contact'},
    {'1': 'updated_fields', '3': 2, '4': 3, '5': 9, '10': 'updatedFields'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'update_source', '3': 4, '4': 1, '5': 9, '10': 'updateSource'},
  ],
};

/// Descriptor for `ContactUpdateEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactUpdateEventDescriptor = $convert.base64Decode(
    'ChJDb250YWN0VXBkYXRlRXZlbnQSJwoHY29udGFjdBgBIAEoCzINLmNjLlVzZXJQcm90b1IHY2'
    '9udGFjdBIlCg51cGRhdGVkX2ZpZWxkcxgCIAMoCVINdXBkYXRlZEZpZWxkcxIcCgl0aW1lc3Rh'
    'bXAYAyABKANSCXRpbWVzdGFtcBIjCg11cGRhdGVfc291cmNlGAQgASgJUgx1cGRhdGVTb3VyY2'
    'U=');

