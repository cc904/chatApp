// This is a generated file - do not edit.
//
// Generated from quick_reply.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use quickReplyDescriptor instead')
const QuickReply$json = {
  '1': 'QuickReply',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'category', '3': 3, '4': 1, '5': 9, '10': 'category'},
    {'1': 'order_index', '3': 4, '4': 1, '5': 5, '10': 'orderIndex'},
    {'1': 'is_enabled', '3': 5, '4': 1, '5': 8, '10': 'isEnabled'},
    {'1': 'user_id', '3': 6, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'type', '3': 7, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `QuickReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quickReplyDescriptor = $convert.base64Decode(
    'CgpRdWlja1JlcGx5Eg4KAmlkGAEgASgDUgJpZBIYCgdjb250ZW50GAIgASgJUgdjb250ZW50Eh'
    'oKCGNhdGVnb3J5GAMgASgJUghjYXRlZ29yeRIfCgtvcmRlcl9pbmRleBgEIAEoBVIKb3JkZXJJ'
    'bmRleBIdCgppc19lbmFibGVkGAUgASgIUglpc0VuYWJsZWQSFwoHdXNlcl9pZBgGIAEoCVIGdX'
    'NlcklkEhIKBHR5cGUYByABKAlSBHR5cGU=');

@$core.Deprecated('Use getQuickRepliesRequestDescriptor instead')
const GetQuickRepliesRequest$json = {
  '1': 'GetQuickRepliesRequest',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `GetQuickRepliesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getQuickRepliesRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRRdWlja1JlcGxpZXNSZXF1ZXN0EhwKCXRpbWVzdGFtcBgBIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use getQuickRepliesResponseDescriptor instead')
const GetQuickRepliesResponse$json = {
  '1': 'GetQuickRepliesResponse',
  '2': [
    {
      '1': 'quick_replies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.quick_reply.QuickReply',
      '10': 'quickReplies'
    },
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `GetQuickRepliesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getQuickRepliesResponseDescriptor = $convert.base64Decode(
    'ChdHZXRRdWlja1JlcGxpZXNSZXNwb25zZRI8Cg1xdWlja19yZXBsaWVzGAEgAygLMhcucXVpY2'
    'tfcmVwbHkuUXVpY2tSZXBseVIMcXVpY2tSZXBsaWVzEhwKCXRpbWVzdGFtcBgCIAEoA1IJdGlt'
    'ZXN0YW1w');

@$core.Deprecated('Use createQuickReplyRequestDescriptor instead')
const CreateQuickReplyRequest$json = {
  '1': 'CreateQuickReplyRequest',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 9, '10': 'content'},
    {'1': 'category', '3': 2, '4': 1, '5': 9, '10': 'category'},
    {'1': 'order_index', '3': 3, '4': 1, '5': 5, '10': 'orderIndex'},
    {'1': 'is_enabled', '3': 4, '4': 1, '5': 8, '10': 'isEnabled'},
  ],
};

/// Descriptor for `CreateQuickReplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createQuickReplyRequestDescriptor = $convert.base64Decode(
    'ChdDcmVhdGVRdWlja1JlcGx5UmVxdWVzdBIYCgdjb250ZW50GAEgASgJUgdjb250ZW50EhoKCG'
    'NhdGVnb3J5GAIgASgJUghjYXRlZ29yeRIfCgtvcmRlcl9pbmRleBgDIAEoBVIKb3JkZXJJbmRl'
    'eBIdCgppc19lbmFibGVkGAQgASgIUglpc0VuYWJsZWQ=');

@$core.Deprecated('Use updateQuickReplyRequestDescriptor instead')
const UpdateQuickReplyRequest$json = {
  '1': 'UpdateQuickReplyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'category', '3': 3, '4': 1, '5': 9, '10': 'category'},
    {'1': 'order_index', '3': 4, '4': 1, '5': 5, '10': 'orderIndex'},
    {'1': 'is_enabled', '3': 5, '4': 1, '5': 8, '10': 'isEnabled'},
  ],
};

/// Descriptor for `UpdateQuickReplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateQuickReplyRequestDescriptor = $convert.base64Decode(
    'ChdVcGRhdGVRdWlja1JlcGx5UmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQSGAoHY29udGVudBgCIA'
    'EoCVIHY29udGVudBIaCghjYXRlZ29yeRgDIAEoCVIIY2F0ZWdvcnkSHwoLb3JkZXJfaW5kZXgY'
    'BCABKAVSCm9yZGVySW5kZXgSHQoKaXNfZW5hYmxlZBgFIAEoCFIJaXNFbmFibGVk');

@$core.Deprecated('Use deleteQuickReplyRequestDescriptor instead')
const DeleteQuickReplyRequest$json = {
  '1': 'DeleteQuickReplyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `DeleteQuickReplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteQuickReplyRequestDescriptor = $convert
    .base64Decode('ChdEZWxldGVRdWlja1JlcGx5UmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use quickReplyResponseDescriptor instead')
const QuickReplyResponse$json = {
  '1': 'QuickReplyResponse',
  '2': [
    {
      '1': 'quick_reply',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.quick_reply.QuickReply',
      '10': 'quickReply'
    },
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `QuickReplyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quickReplyResponseDescriptor = $convert.base64Decode(
    'ChJRdWlja1JlcGx5UmVzcG9uc2USOAoLcXVpY2tfcmVwbHkYASABKAsyFy5xdWlja19yZXBseS'
    '5RdWlja1JlcGx5UgpxdWlja1JlcGx5EhwKCXRpbWVzdGFtcBgCIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use deleteQuickReplyResponseDescriptor instead')
const DeleteQuickReplyResponse$json = {
  '1': 'DeleteQuickReplyResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `DeleteQuickReplyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteQuickReplyResponseDescriptor =
    $convert.base64Decode(
        'ChhEZWxldGVRdWlja1JlcGx5UmVzcG9uc2USDgoCaWQYASABKANSAmlkEhwKCXRpbWVzdGFtcB'
        'gCIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use quickReplyErrorResponseDescriptor instead')
const QuickReplyErrorResponse$json = {
  '1': 'QuickReplyErrorResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'error_code', '3': 2, '4': 1, '5': 9, '10': 'errorCode'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `QuickReplyErrorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quickReplyErrorResponseDescriptor = $convert.base64Decode(
    'ChdRdWlja1JlcGx5RXJyb3JSZXNwb25zZRIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdlEh0KCm'
    'Vycm9yX2NvZGUYAiABKAlSCWVycm9yQ29kZRIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFt'
    'cA==');
