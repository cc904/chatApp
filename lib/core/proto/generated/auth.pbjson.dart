// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use authOperationTypeDescriptor instead')
const AuthOperationType$json = {
  '1': 'AuthOperationType',
  '2': [
    {'1': 'LOGIN', '2': 0},
    {'1': 'REGISTER', '2': 1},
    {'1': 'RESET_PASSWORD', '2': 2},
    {'1': 'SEND_CODE', '2': 3},
  ],
};

/// Descriptor for `AuthOperationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List authOperationTypeDescriptor = $convert.base64Decode(
    'ChFBdXRoT3BlcmF0aW9uVHlwZRIJCgVMT0dJThAAEgwKCFJFR0lTVEVSEAESEgoOUkVTRVRfUE'
    'FTU1dPUkQQAhINCglTRU5EX0NPREUQAw==');

@$core.Deprecated('Use authRequestDescriptor instead')
const AuthRequest$json = {
  '1': 'AuthRequest',
  '2': [
    {
      '1': 'operation_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.cc.AuthOperationType',
      '10': 'operationType'
    },
    {'1': 'phone_number', '3': 2, '4': 1, '5': 9, '10': 'phoneNumber'},
    {
      '1': 'password',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'password',
      '17': true
    },
    {
      '1': 'verification_code',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'verificationCode',
      '17': true
    },
    {
      '1': 'nickname',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'nickname',
      '17': true
    },
    {
      '1': 'is_quick_login',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 3,
      '10': 'isQuickLogin',
      '17': true
    },
    {
      '1': 'purpose',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'purpose',
      '17': true
    },
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
    {
      '1': 'user_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'userId',
      '17': true
    },
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
    {'1': 'identifier', '3': 1, '4': 1, '5': 9, '10': 'identifier'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {
      '1': 'device',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.DeviceInfo',
      '10': 'device'
    },
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSHgoKaWRlbnRpZmllchgBIAEoCVIKaWRlbnRpZmllchIaCghwYXNzd2'
    '9yZBgCIAEoCVIIcGFzc3dvcmQSJgoGZGV2aWNlGAMgASgLMg4uY2MuRGV2aWNlSW5mb1IGZGV2'
    'aWNl');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.cc.UserInfo', '10': 'user'},
    {
      '1': 'tokens',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.cc.TokenPair',
      '10': 'tokens'
    },
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZXJyb3JfbWVzc2'
    'FnZRgCIAEoCVIMZXJyb3JNZXNzYWdlEiAKBHVzZXIYAyABKAsyDC5jYy5Vc2VySW5mb1IEdXNl'
    'chIlCgZ0b2tlbnMYBCABKAsyDS5jYy5Ub2tlblBhaXJSBnRva2Vucw==');

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'phone', '3': 3, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '10': 'email'},
    {
      '1': 'device',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.cc.DeviceInfo',
      '10': 'device'
    },
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3'
    'JkGAIgASgJUghwYXNzd29yZBIUCgVwaG9uZRgDIAEoCVIFcGhvbmUSFAoFZW1haWwYBCABKAlS'
    'BWVtYWlsEiYKBmRldmljZRgFIAEoCzIOLmNjLkRldmljZUluZm9SBmRldmljZQ==');

@$core.Deprecated('Use registerResponseDescriptor instead')
const RegisterResponse$json = {
  '1': 'RegisterResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.cc.UserInfo', '10': 'user'},
    {
      '1': 'tokens',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.cc.TokenPair',
      '10': 'tokens'
    },
  ],
};

/// Descriptor for `RegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerResponseDescriptor = $convert.base64Decode(
    'ChBSZWdpc3RlclJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZXJyb3JfbW'
    'Vzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdlEiAKBHVzZXIYAyABKAsyDC5jYy5Vc2VySW5mb1IE'
    'dXNlchIlCgZ0b2tlbnMYBCABKAsyDS5jYy5Ub2tlblBhaXJSBnRva2Vucw==');

@$core.Deprecated('Use resetPasswordRequestDescriptor instead')
const ResetPasswordRequest$json = {
  '1': 'ResetPasswordRequest',
  '2': [
    {'1': 'phone_number', '3': 1, '4': 1, '5': 9, '10': 'phoneNumber'},
    {
      '1': 'verification_code',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'verificationCode'
    },
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

@$core.Deprecated('Use verifyTokenRequestDescriptor instead')
const VerifyTokenRequest$json = {
  '1': 'VerifyTokenRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `VerifyTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyTokenRequestDescriptor = $convert
    .base64Decode('ChJWZXJpZnlUb2tlblJlcXVlc3QSFAoFdG9rZW4YASABKAlSBXRva2Vu');

@$core.Deprecated('Use verifyTokenResponseDescriptor instead')
const VerifyTokenResponse$json = {
  '1': 'VerifyTokenResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.cc.UserInfo', '10': 'user'},
    {'1': 'new_token', '3': 4, '4': 1, '5': 9, '10': 'newToken'},
    {
      '1': 'new_token_expires_at',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'newTokenExpiresAt'
    },
  ],
};

/// Descriptor for `VerifyTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyTokenResponseDescriptor = $convert.base64Decode(
    'ChNWZXJpZnlUb2tlblJlc3BvbnNlEhQKBXZhbGlkGAEgASgIUgV2YWxpZBIjCg1lcnJvcl9tZX'
    'NzYWdlGAIgASgJUgxlcnJvck1lc3NhZ2USIAoEdXNlchgDIAEoCzIMLmNjLlVzZXJJbmZvUgR1'
    'c2VyEhsKCW5ld190b2tlbhgEIAEoCVIIbmV3VG9rZW4SLwoUbmV3X3Rva2VuX2V4cGlyZXNfYX'
    'QYBSABKANSEW5ld1Rva2VuRXhwaXJlc0F0');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'device_type', '3': 2, '4': 1, '5': 9, '10': 'deviceType'},
    {'1': 'device_model', '3': 3, '4': 1, '5': 9, '10': 'deviceModel'},
    {'1': 'os_version', '3': 4, '4': 1, '5': 9, '10': 'osVersion'},
    {'1': 'app_version', '3': 5, '4': 1, '5': 9, '10': 'appVersion'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSHwoLZGV2aWNlX3R5cG'
    'UYAiABKAlSCmRldmljZVR5cGUSIQoMZGV2aWNlX21vZGVsGAMgASgJUgtkZXZpY2VNb2RlbBId'
    'Cgpvc192ZXJzaW9uGAQgASgJUglvc1ZlcnNpb24SHwoLYXBwX3ZlcnNpb24YBSABKAlSCmFwcF'
    'ZlcnNpb24=');

@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = {
  '1': 'UserInfo',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'phone', '3': 3, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '10': 'email'},
    {'1': 'avatar', '3': 5, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'last_login_at', '3': 7, '4': 1, '5': 3, '10': 'lastLoginAt'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor = $convert.base64Decode(
    'CghVc2VySW5mbxIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKAlSCH'
    'VzZXJuYW1lEhQKBXBob25lGAMgASgJUgVwaG9uZRIUCgVlbWFpbBgEIAEoCVIFZW1haWwSFgoG'
    'YXZhdGFyGAUgASgJUgZhdmF0YXISHQoKY3JlYXRlZF9hdBgGIAEoA1IJY3JlYXRlZEF0EiIKDW'
    'xhc3RfbG9naW5fYXQYByABKANSC2xhc3RMb2dpbkF0');

@$core.Deprecated('Use tokenPairDescriptor instead')
const TokenPair$json = {
  '1': 'TokenPair',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
    {
      '1': 'refresh_token_expires_at',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'refreshTokenExpiresAt'
    },
    {'1': 'socket_token', '3': 3, '4': 1, '5': 9, '10': 'socketToken'},
    {
      '1': 'socket_token_expires_at',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'socketTokenExpiresAt'
    },
  ],
};

/// Descriptor for `TokenPair`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenPairDescriptor = $convert.base64Decode(
    'CglUb2tlblBhaXISIwoNcmVmcmVzaF90b2tlbhgBIAEoCVIMcmVmcmVzaFRva2VuEjcKGHJlZn'
    'Jlc2hfdG9rZW5fZXhwaXJlc19hdBgCIAEoA1IVcmVmcmVzaFRva2VuRXhwaXJlc0F0EiEKDHNv'
    'Y2tldF90b2tlbhgDIAEoCVILc29ja2V0VG9rZW4SNQoXc29ja2V0X3Rva2VuX2V4cGlyZXNfYX'
    'QYBCABKANSFHNvY2tldFRva2VuRXhwaXJlc0F0');

@$core.Deprecated('Use refreshSocketTokenRequestDescriptor instead')
const RefreshSocketTokenRequest$json = {
  '1': 'RefreshSocketTokenRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
    {
      '1': 'device',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.DeviceInfo',
      '9': 0,
      '10': 'device',
      '17': true
    },
  ],
  '8': [
    {'1': '_device'},
  ],
};

/// Descriptor for `RefreshSocketTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshSocketTokenRequestDescriptor = $convert.base64Decode(
    'ChlSZWZyZXNoU29ja2V0VG9rZW5SZXF1ZXN0EiMKDXJlZnJlc2hfdG9rZW4YASABKAlSDHJlZn'
    'Jlc2hUb2tlbhIcCgl0aW1lc3RhbXAYAiABKANSCXRpbWVzdGFtcBIrCgZkZXZpY2UYAyABKAsy'
    'Di5jYy5EZXZpY2VJbmZvSABSBmRldmljZYgBAUIJCgdfZGV2aWNl');

@$core.Deprecated('Use refreshSocketTokenResponseDescriptor instead')
const RefreshSocketTokenResponse$json = {
  '1': 'RefreshSocketTokenResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'tokens',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.TokenPair',
      '9': 0,
      '10': 'tokens',
      '17': true
    },
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '8': [
    {'1': '_tokens'},
  ],
};

/// Descriptor for `RefreshSocketTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshSocketTokenResponseDescriptor = $convert.base64Decode(
    'ChpSZWZyZXNoU29ja2V0VG9rZW5SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEi'
    'MKDWVycm9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZRIqCgZ0b2tlbnMYAyABKAsyDS5j'
    'Yy5Ub2tlblBhaXJIAFIGdG9rZW5ziAEBEhwKCXRpbWVzdGFtcBgEIAEoA1IJdGltZXN0YW1wQg'
    'kKB190b2tlbnM=');

@$core.Deprecated('Use userSessionDescriptor instead')
const UserSession$json = {
  '1': 'UserSession',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'tokens',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.cc.TokenPair',
      '10': 'tokens'
    },
    {'1': 'phone_number', '3': 3, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'last_active_at', '3': 5, '4': 1, '5': 3, '10': 'lastActiveAt'},
  ],
};

/// Descriptor for `UserSession`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSessionDescriptor = $convert.base64Decode(
    'CgtVc2VyU2Vzc2lvbhIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSJQoGdG9rZW5zGAIgASgLMg'
    '0uY2MuVG9rZW5QYWlyUgZ0b2tlbnMSIQoMcGhvbmVfbnVtYmVyGAMgASgJUgtwaG9uZU51bWJl'
    'chIdCgpjcmVhdGVkX2F0GAQgASgDUgljcmVhdGVkQXQSJAoObGFzdF9hY3RpdmVfYXQYBSABKA'
    'NSDGxhc3RBY3RpdmVBdA==');
