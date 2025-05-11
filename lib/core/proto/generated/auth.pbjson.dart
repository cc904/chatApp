//
//  Generated code. Do not modify.
//  source: auth.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use authOperationTypeDescriptor instead')
const AuthOperationType$json = {
  '1': 'AuthOperationType',
  '2': [
    {'1': 'login', '2': 0},
    {'1': 'register', '2': 1},
    {'1': 'reset_password', '2': 2},
    {'1': 'send_code', '2': 3},
  ],
};

/// Descriptor for `AuthOperationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List authOperationTypeDescriptor = $convert.base64Decode(
    'ChFBdXRoT3BlcmF0aW9uVHlwZRIJCgVsb2dpbhAAEgwKCHJlZ2lzdGVyEAESEgoOcmVzZXRfcG'
    'Fzc3dvcmQQAhINCglzZW5kX2NvZGUQAw==');

@$core.Deprecated('Use authRequestDescriptor instead')
const AuthRequest$json = {
  '1': 'AuthRequest',
  '2': [
    {'1': 'operation_type', '3': 1, '4': 1, '5': 14, '6': '.cc.AuthOperationType', '10': 'operationType'},
    {'1': 'phone_number', '3': 2, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'password', '17': true},
    {'1': 'verification_code', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'verificationCode', '17': true},
    {'1': 'nickname', '3': 5, '4': 1, '5': 9, '9': 2, '10': 'nickname', '17': true},
    {'1': 'is_quick_login', '3': 6, '4': 1, '5': 8, '9': 3, '10': 'isQuickLogin', '17': true},
    {'1': 'purpose', '3': 7, '4': 1, '5': 9, '9': 4, '10': 'purpose', '17': true},
  ],
  '8': [
    {'1': '_password'},
    {'1': '_verification_code'},
    {'1': '_nickname'},
    {'1': '_is_quick_login'},
    {'1': '_purpose'},
  ],
};

/// Descriptor for `AuthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authRequestDescriptor = $convert.base64Decode(
    'CgtBdXRoUmVxdWVzdBI8Cg5vcGVyYXRpb25fdHlwZRgBIAEoDjIVLmNjLkF1dGhPcGVyYXRpb2'
    '5UeXBlUg1vcGVyYXRpb25UeXBlEiEKDHBob25lX251bWJlchgCIAEoCVILcGhvbmVOdW1iZXIS'
    'HwoIcGFzc3dvcmQYAyABKAlIAFIIcGFzc3dvcmSIAQESMAoRdmVyaWZpY2F0aW9uX2NvZGUYBC'
    'ABKAlIAVIQdmVyaWZpY2F0aW9uQ29kZYgBARIfCghuaWNrbmFtZRgFIAEoCUgCUghuaWNrbmFt'
    'ZYgBARIpCg5pc19xdWlja19sb2dpbhgGIAEoCEgDUgxpc1F1aWNrTG9naW6IAQESHQoHcHVycG'
    '9zZRgHIAEoCUgEUgdwdXJwb3NliAEBQgsKCV9wYXNzd29yZEIUChJfdmVyaWZpY2F0aW9uX2Nv'
    'ZGVCCwoJX25pY2tuYW1lQhEKD19pc19xdWlja19sb2dpbkIKCghfcHVycG9zZQ==');

@$core.Deprecated('Use authResponseDescriptor instead')
const AuthResponse$json = {
  '1': 'AuthResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'userId', '17': true},
    {'1': 'token', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'token', '17': true},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '8': [
    {'1': '_user_id'},
    {'1': '_token'},
  ],
};

/// Descriptor for `AuthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authResponseDescriptor = $convert.base64Decode(
    'CgxBdXRoUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdlEhwKB3VzZXJfaWQYAyABKAlIAFIGdXNlcklkiAEBEhkKBXRva2VuGAQgASgJ'
    'SAFSBXRva2VuiAEBEhwKCXRpbWVzdGFtcBgFIAEoA1IJdGltZXN0YW1wQgoKCF91c2VyX2lkQg'
    'gKBl90b2tlbg==');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'phone_number', '3': 1, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'password'},
    {'1': 'verification_code', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'verificationCode'},
    {'1': 'is_quick_login', '3': 4, '4': 1, '5': 8, '10': 'isQuickLogin'},
  ],
  '8': [
    {'1': 'auth_method'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSIQoMcGhvbmVfbnVtYmVyGAEgASgJUgtwaG9uZU51bWJlchIcCghwYX'
    'Nzd29yZBgCIAEoCUgAUghwYXNzd29yZBItChF2ZXJpZmljYXRpb25fY29kZRgDIAEoCUgAUhB2'
    'ZXJpZmljYXRpb25Db2RlEiQKDmlzX3F1aWNrX2xvZ2luGAQgASgIUgxpc1F1aWNrTG9naW5CDQ'
    'oLYXV0aF9tZXRob2Q=');

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'phone_number', '3': 1, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'verification_code', '3': 2, '4': 1, '5': 9, '10': 'verificationCode'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
    {'1': 'nickname', '3': 4, '4': 1, '5': 9, '10': 'nickname'},
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSIQoMcGhvbmVfbnVtYmVyGAEgASgJUgtwaG9uZU51bWJlchIrCh'
    'F2ZXJpZmljYXRpb25fY29kZRgCIAEoCVIQdmVyaWZpY2F0aW9uQ29kZRIaCghwYXNzd29yZBgD'
    'IAEoCVIIcGFzc3dvcmQSGgoIbmlja25hbWUYBCABKAlSCG5pY2tuYW1l');

@$core.Deprecated('Use resetPasswordRequestDescriptor instead')
const ResetPasswordRequest$json = {
  '1': 'ResetPasswordRequest',
  '2': [
    {'1': 'phone_number', '3': 1, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'verification_code', '3': 2, '4': 1, '5': 9, '10': 'verificationCode'},
    {'1': 'new_password', '3': 3, '4': 1, '5': 9, '10': 'newPassword'},
  ],
};

/// Descriptor for `ResetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resetPasswordRequestDescriptor = $convert.base64Decode(
    'ChRSZXNldFBhc3N3b3JkUmVxdWVzdBIhCgxwaG9uZV9udW1iZXIYASABKAlSC3Bob25lTnVtYm'
    'VyEisKEXZlcmlmaWNhdGlvbl9jb2RlGAIgASgJUhB2ZXJpZmljYXRpb25Db2RlEiEKDG5ld19w'
    'YXNzd29yZBgDIAEoCVILbmV3UGFzc3dvcmQ=');

@$core.Deprecated('Use sendCodeRequestDescriptor instead')
const SendCodeRequest$json = {
  '1': 'SendCodeRequest',
  '2': [
    {'1': 'phone_number', '3': 1, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'purpose', '3': 2, '4': 1, '5': 9, '10': 'purpose'},
  ],
};

/// Descriptor for `SendCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendCodeRequestDescriptor = $convert.base64Decode(
    'Cg9TZW5kQ29kZVJlcXVlc3QSIQoMcGhvbmVfbnVtYmVyGAEgASgJUgtwaG9uZU51bWJlchIYCg'
    'dwdXJwb3NlGAIgASgJUgdwdXJwb3Nl');

@$core.Deprecated('Use sendCodeResponseDescriptor instead')
const SendCodeResponse$json = {
  '1': 'SendCodeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'cooldown', '3': 4, '4': 1, '5': 5, '10': 'cooldown'},
  ],
};

/// Descriptor for `SendCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendCodeResponseDescriptor = $convert.base64Decode(
    'ChBTZW5kQ29kZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZR'
    'gCIAEoCVIHbWVzc2FnZRIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcBIaCghjb29sZG93'
    'bhgEIAEoBVIIY29vbGRvd24=');

@$core.Deprecated('Use userSessionDescriptor instead')
const UserSession$json = {
  '1': 'UserSession',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {'1': 'expire_time', '3': 3, '4': 1, '5': 3, '10': 'expireTime'},
    {'1': 'phone_number', '3': 4, '4': 1, '5': 9, '10': 'phoneNumber'},
  ],
};

/// Descriptor for `UserSession`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSessionDescriptor = $convert.base64Decode(
    'CgtVc2VyU2Vzc2lvbhIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSFAoFdG9rZW4YAiABKAlSBX'
    'Rva2VuEh8KC2V4cGlyZV90aW1lGAMgASgDUgpleHBpcmVUaW1lEiEKDHBob25lX251bWJlchgE'
    'IAEoCVILcGhvbmVOdW1iZXI=');

