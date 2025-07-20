//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userStatusEnumDescriptor instead')
const UserStatusEnum$json = {
  '1': 'UserStatusEnum',
  '2': [
    {'1': 'OFFLINE', '2': 0},
    {'1': 'ONLINE', '2': 1},
    {'1': 'AWAY', '2': 2},
  ],
};

/// Descriptor for `UserStatusEnum`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userStatusEnumDescriptor = $convert.base64Decode(
    'Cg5Vc2VyU3RhdHVzRW51bRILCgdPRkZMSU5FEAASCgoGT05MSU5FEAESCAoEQVdBWRAC');

@$core.Deprecated('Use userProtoDescriptor instead')
const UserProto$json = {
  '1': 'UserProto',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'nick_name', '3': 2, '4': 1, '5': 9, '10': 'nickName'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'email', '3': 5, '4': 1, '5': 9, '10': 'email'},
    {'1': 'pinyin', '3': 6, '4': 1, '5': 9, '10': 'pinyin'},
    {'1': 'last_active_time', '3': 7, '4': 1, '5': 3, '10': 'lastActiveTime'},
    {'1': 'status', '3': 8, '4': 1, '5': 9, '10': 'status'},
    {'1': 'is_typing', '3': 12, '4': 1, '5': 8, '10': 'isTyping'},
    {'1': 'typing_in_conversation', '3': 13, '4': 1, '5': 9, '10': 'typingInConversation'},
    {'1': 'custom_nickname', '3': 14, '4': 1, '5': 9, '10': 'customNickname'},
  ],
};

/// Descriptor for `UserProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userProtoDescriptor = $convert.base64Decode(
    'CglVc2VyUHJvdG8SFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCW5pY2tfbmFtZRgCIAEoCV'
    'IIbmlja05hbWUSFgoGYXZhdGFyGAMgASgJUgZhdmF0YXISFAoFcGhvbmUYBCABKAlSBXBob25l'
    'EhQKBWVtYWlsGAUgASgJUgVlbWFpbBIWCgZwaW55aW4YBiABKAlSBnBpbnlpbhIoChBsYXN0X2'
    'FjdGl2ZV90aW1lGAcgASgDUg5sYXN0QWN0aXZlVGltZRIWCgZzdGF0dXMYCCABKAlSBnN0YXR1'
    'cxIbCglpc190eXBpbmcYDCABKAhSCGlzVHlwaW5nEjQKFnR5cGluZ19pbl9jb252ZXJzYXRpb2'
    '4YDSABKAlSFHR5cGluZ0luQ29udmVyc2F0aW9uEicKD2N1c3RvbV9uaWNrbmFtZRgOIAEoCVIO'
    'Y3VzdG9tTmlja25hbWU=');

@$core.Deprecated('Use currentUserProtoDescriptor instead')
const CurrentUserProto$json = {
  '1': 'CurrentUserProto',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'email', '3': 5, '4': 1, '5': 9, '10': 'email'},
    {'1': 'last_login_time', '3': 6, '4': 1, '5': 3, '10': 'lastLoginTime'},
    {'1': 'status', '3': 7, '4': 1, '5': 9, '10': 'status'},
    {'1': 'has_set_password', '3': 8, '4': 1, '5': 8, '10': 'hasSetPassword'},
  ],
};

/// Descriptor for `CurrentUserProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List currentUserProtoDescriptor = $convert.base64Decode(
    'ChBDdXJyZW50VXNlclByb3RvEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBISCgRuYW1lGAIgAS'
    'gJUgRuYW1lEhYKBmF2YXRhchgDIAEoCVIGYXZhdGFyEhQKBXBob25lGAQgASgJUgVwaG9uZRIU'
    'CgVlbWFpbBgFIAEoCVIFZW1haWwSJgoPbGFzdF9sb2dpbl90aW1lGAYgASgDUg1sYXN0TG9naW'
    '5UaW1lEhYKBnN0YXR1cxgHIAEoCVIGc3RhdHVzEigKEGhhc19zZXRfcGFzc3dvcmQYCCABKAhS'
    'Dmhhc1NldFBhc3N3b3Jk');

@$core.Deprecated('Use setCurrentUserRequestDescriptor instead')
const SetCurrentUserRequest$json = {
  '1': 'SetCurrentUserRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'avatar', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'avatar', '17': true},
    {'1': 'phone', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'phone', '17': true},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'email', '17': true},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '9': 4, '10': 'status', '17': true},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '8': [
    {'1': '_name'},
    {'1': '_avatar'},
    {'1': '_phone'},
    {'1': '_email'},
    {'1': '_status'},
  ],
};

/// Descriptor for `SetCurrentUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCurrentUserRequestDescriptor = $convert.base64Decode(
    'ChVTZXRDdXJyZW50VXNlclJlcXVlc3QSFwoEbmFtZRgBIAEoCUgAUgRuYW1liAEBEhsKBmF2YX'
    'RhchgCIAEoCUgBUgZhdmF0YXKIAQESGQoFcGhvbmUYAyABKAlIAlIFcGhvbmWIAQESGQoFZW1h'
    'aWwYBCABKAlIA1IFZW1haWyIAQESGwoGc3RhdHVzGAUgASgJSARSBnN0YXR1c4gBARIcCgl0aW'
    '1lc3RhbXAYBiABKANSCXRpbWVzdGFtcEIHCgVfbmFtZUIJCgdfYXZhdGFyQggKBl9waG9uZUII'
    'CgZfZW1haWxCCQoHX3N0YXR1cw==');

@$core.Deprecated('Use setCurrentUserResponseDescriptor instead')
const SetCurrentUserResponse$json = {
  '1': 'SetCurrentUserResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.cc.CurrentUserProto', '10': 'user'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `SetCurrentUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCurrentUserResponseDescriptor = $convert.base64Decode(
    'ChZTZXRDdXJyZW50VXNlclJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbW'
    'Vzc2FnZRgCIAEoCVIHbWVzc2FnZRIoCgR1c2VyGAMgASgLMhQuY2MuQ3VycmVudFVzZXJQcm90'
    'b1IEdXNlchIcCgl0aW1lc3RhbXAYBCABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use currentUserUpdateEventDescriptor instead')
const CurrentUserUpdateEvent$json = {
  '1': 'CurrentUserUpdateEvent',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.cc.CurrentUserProto', '10': 'user'},
    {'1': 'updated_fields', '3': 2, '4': 3, '5': 9, '10': 'updatedFields'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'update_source', '3': 4, '4': 1, '5': 9, '10': 'updateSource'},
  ],
};

/// Descriptor for `CurrentUserUpdateEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List currentUserUpdateEventDescriptor = $convert.base64Decode(
    'ChZDdXJyZW50VXNlclVwZGF0ZUV2ZW50EigKBHVzZXIYASABKAsyFC5jYy5DdXJyZW50VXNlcl'
    'Byb3RvUgR1c2VyEiUKDnVwZGF0ZWRfZmllbGRzGAIgAygJUg11cGRhdGVkRmllbGRzEhwKCXRp'
    'bWVzdGFtcBgDIAEoA1IJdGltZXN0YW1wEiMKDXVwZGF0ZV9zb3VyY2UYBCABKAlSDHVwZGF0ZV'
    'NvdXJjZQ==');

@$core.Deprecated('Use userStatusUpdateDescriptor instead')
const UserStatusUpdate$json = {
  '1': 'UserStatusUpdate',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UserStatusUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userStatusUpdateDescriptor = $convert.base64Decode(
    'ChBVc2VyU3RhdHVzVXBkYXRlEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIWCgZzdGF0dXMYAi'
    'ABKAlSBnN0YXR1cxIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use userTypingUpdateDescriptor instead')
const UserTypingUpdate$json = {
  '1': 'UserTypingUpdate',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UserTypingUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userTypingUpdateDescriptor = $convert.base64Decode(
    'ChBVc2VyVHlwaW5nVXBkYXRlEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBInCg9jb252ZXJzYX'
    'Rpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklkEhsKCWlzX3R5cGluZxgDIAEoCFIIaXNUeXBp'
    'bmcSHAoJdGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use userConnectionResponseDescriptor instead')
const UserConnectionResponse$json = {
  '1': 'UserConnectionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'userId', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UserConnectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userConnectionResponseDescriptor = $convert.base64Decode(
    'ChZVc2VyQ29ubmVjdGlvblJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbW'
    'Vzc2FnZRgCIAEoCVIHbWVzc2FnZRIWCgZ1c2VySWQYAyABKAlSBnVzZXJJZBIcCgl0aW1lc3Rh'
    'bXAYBCABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use userResponseDescriptor instead')
const UserResponse$json = {
  '1': 'UserResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.cc.UserProto', '10': 'user'},
  ],
};

/// Descriptor for `UserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userResponseDescriptor = $convert.base64Decode(
    'CgxVc2VyUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdlEiEKBHVzZXIYAyABKAsyDS5jYy5Vc2VyUHJvdG9SBHVzZXI=');

@$core.Deprecated('Use userCollectionDescriptor instead')
const UserCollection$json = {
  '1': 'UserCollection',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.cc.UserProto', '10': 'users'},
  ],
};

/// Descriptor for `UserCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userCollectionDescriptor = $convert.base64Decode(
    'Cg5Vc2VyQ29sbGVjdGlvbhIjCgV1c2VycxgBIAMoCzINLmNjLlVzZXJQcm90b1IFdXNlcnM=');

@$core.Deprecated('Use userStatusMessageDescriptor instead')
const UserStatusMessage$json = {
  '1': 'UserStatusMessage',
  '2': [
    {'1': 'is_online', '3': 1, '4': 1, '5': 8, '10': 'isOnline'},
    {'1': 'last_active_at', '3': 2, '4': 1, '5': 3, '10': 'lastActiveAt'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 9, '10': 'deviceType'},
  ],
};

/// Descriptor for `UserStatusMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userStatusMessageDescriptor = $convert.base64Decode(
    'ChFVc2VyU3RhdHVzTWVzc2FnZRIbCglpc19vbmxpbmUYASABKAhSCGlzT25saW5lEiQKDmxhc3'
    'RfYWN0aXZlX2F0GAIgASgDUgxsYXN0QWN0aXZlQXQSHwoLZGV2aWNlX3R5cGUYAyABKAlSCmRl'
    'dmljZVR5cGU=');

@$core.Deprecated('Use userSettingsDescriptor instead')
const UserSettings$json = {
  '1': 'UserSettings',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'notifications', '3': 2, '4': 1, '5': 11, '6': '.cc.NotificationSettings', '10': 'notifications'},
    {'1': 'privacy', '3': 3, '4': 1, '5': 11, '6': '.cc.PrivacySettings', '10': 'privacy'},
    {'1': 'theme', '3': 4, '4': 1, '5': 11, '6': '.cc.ThemeSettings', '10': 'theme'},
    {'1': 'language', '3': 5, '4': 1, '5': 9, '10': 'language'},
    {'1': 'timezone', '3': 6, '4': 1, '5': 9, '10': 'timezone'},
  ],
};

/// Descriptor for `UserSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSettingsDescriptor = $convert.base64Decode(
    'CgxVc2VyU2V0dGluZ3MSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEj4KDW5vdGlmaWNhdGlvbn'
    'MYAiABKAsyGC5jYy5Ob3RpZmljYXRpb25TZXR0aW5nc1INbm90aWZpY2F0aW9ucxItCgdwcml2'
    'YWN5GAMgASgLMhMuY2MuUHJpdmFjeVNldHRpbmdzUgdwcml2YWN5EicKBXRoZW1lGAQgASgLMh'
    'EuY2MuVGhlbWVTZXR0aW5nc1IFdGhlbWUSGgoIbGFuZ3VhZ2UYBSABKAlSCGxhbmd1YWdlEhoK'
    'CHRpbWV6b25lGAYgASgJUgh0aW1lem9uZQ==');

@$core.Deprecated('Use notificationSettingsDescriptor instead')
const NotificationSettings$json = {
  '1': 'NotificationSettings',
  '2': [
    {'1': 'message_notifications', '3': 1, '4': 1, '5': 8, '10': 'messageNotifications'},
    {'1': 'friend_request_notifications', '3': 2, '4': 1, '5': 8, '10': 'friendRequestNotifications'},
    {'1': 'group_notifications', '3': 3, '4': 1, '5': 8, '10': 'groupNotifications'},
    {'1': 'do_not_disturb', '3': 4, '4': 1, '5': 8, '10': 'doNotDisturb'},
    {'1': 'do_not_disturb_start', '3': 5, '4': 1, '5': 9, '10': 'doNotDisturbStart'},
    {'1': 'do_not_disturb_end', '3': 6, '4': 1, '5': 9, '10': 'doNotDisturbEnd'},
  ],
};

/// Descriptor for `NotificationSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationSettingsDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25TZXR0aW5ncxIzChVtZXNzYWdlX25vdGlmaWNhdGlvbnMYASABKAhSFG'
    '1lc3NhZ2VOb3RpZmljYXRpb25zEkAKHGZyaWVuZF9yZXF1ZXN0X25vdGlmaWNhdGlvbnMYAiAB'
    'KAhSGmZyaWVuZFJlcXVlc3ROb3RpZmljYXRpb25zEi8KE2dyb3VwX25vdGlmaWNhdGlvbnMYAy'
    'ABKAhSEmdyb3VwTm90aWZpY2F0aW9ucxIkCg5kb19ub3RfZGlzdHVyYhgEIAEoCFIMZG9Ob3RE'
    'aXN0dXJiEi8KFGRvX25vdF9kaXN0dXJiX3N0YXJ0GAUgASgJUhFkb05vdERpc3R1cmJTdGFydB'
    'IrChJkb19ub3RfZGlzdHVyYl9lbmQYBiABKAlSD2RvTm90RGlzdHVyYkVuZA==');

@$core.Deprecated('Use privacySettingsDescriptor instead')
const PrivacySettings$json = {
  '1': 'PrivacySettings',
  '2': [
    {'1': 'allow_profile_view', '3': 1, '4': 1, '5': 8, '10': 'allowProfileView'},
    {'1': 'allow_friend_requests', '3': 2, '4': 1, '5': 8, '10': 'allowFriendRequests'},
    {'1': 'show_online_status', '3': 3, '4': 1, '5': 8, '10': 'showOnlineStatus'},
    {'1': 'show_last_active', '3': 4, '4': 1, '5': 8, '10': 'showLastActive'},
    {'1': 'show_read_status', '3': 5, '4': 1, '5': 8, '10': 'showReadStatus'},
  ],
};

/// Descriptor for `PrivacySettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List privacySettingsDescriptor = $convert.base64Decode(
    'Cg9Qcml2YWN5U2V0dGluZ3MSLAoSYWxsb3dfcHJvZmlsZV92aWV3GAEgASgIUhBhbGxvd1Byb2'
    'ZpbGVWaWV3EjIKFWFsbG93X2ZyaWVuZF9yZXF1ZXN0cxgCIAEoCFITYWxsb3dGcmllbmRSZXF1'
    'ZXN0cxIsChJzaG93X29ubGluZV9zdGF0dXMYAyABKAhSEHNob3dPbmxpbmVTdGF0dXMSKAoQc2'
    'hvd19sYXN0X2FjdGl2ZRgEIAEoCFIOc2hvd0xhc3RBY3RpdmUSKAoQc2hvd19yZWFkX3N0YXR1'
    'cxgFIAEoCFIOc2hvd1JlYWRTdGF0dXM=');

@$core.Deprecated('Use themeSettingsDescriptor instead')
const ThemeSettings$json = {
  '1': 'ThemeSettings',
  '2': [
    {'1': 'theme_mode', '3': 1, '4': 1, '5': 9, '10': 'themeMode'},
    {'1': 'theme_color', '3': 2, '4': 1, '5': 9, '10': 'themeColor'},
    {'1': 'font_size', '3': 3, '4': 1, '5': 9, '10': 'fontSize'},
  ],
};

/// Descriptor for `ThemeSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List themeSettingsDescriptor = $convert.base64Decode(
    'Cg1UaGVtZVNldHRpbmdzEh0KCnRoZW1lX21vZGUYASABKAlSCXRoZW1lTW9kZRIfCgt0aGVtZV'
    '9jb2xvchgCIAEoCVIKdGhlbWVDb2xvchIbCglmb250X3NpemUYAyABKAlSCGZvbnRTaXpl');

@$core.Deprecated('Use searchUserRequestDescriptor instead')
const SearchUserRequest$json = {
  '1': 'SearchUserRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'search_type', '3': 2, '4': 1, '5': 9, '10': 'searchType'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `SearchUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUserRequestDescriptor = $convert.base64Decode(
    'ChFTZWFyY2hVc2VyUmVxdWVzdBIUCgVxdWVyeRgBIAEoCVIFcXVlcnkSHwoLc2VhcmNoX3R5cG'
    'UYAiABKAlSCnNlYXJjaFR5cGUSHAoJdGltZXN0YW1wGAMgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use searchUserResponseDescriptor instead')
const SearchUserResponse$json = {
  '1': 'SearchUserResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.cc.UserProto', '10': 'user'},
    {'1': 'query', '3': 4, '4': 1, '5': 9, '10': 'query'},
    {'1': 'is_friend', '3': 5, '4': 1, '5': 8, '10': 'isFriend'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `SearchUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUserResponseDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hVc2VyUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYW'
    'dlGAIgASgJUgdtZXNzYWdlEiEKBHVzZXIYAyABKAsyDS5jYy5Vc2VyUHJvdG9SBHVzZXISFAoF'
    'cXVlcnkYBCABKAlSBXF1ZXJ5EhsKCWlzX2ZyaWVuZBgFIAEoCFIIaXNGcmllbmQSHAoJdGltZX'
    'N0YW1wGAYgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use universalSearchRequestDescriptor instead')
const UniversalSearchRequest$json = {
  '1': 'UniversalSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'search_types', '3': 2, '4': 3, '5': 9, '10': 'searchTypes'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UniversalSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List universalSearchRequestDescriptor = $convert.base64Decode(
    'ChZVbml2ZXJzYWxTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIhCgxzZWFyY2'
    'hfdHlwZXMYAiADKAlSC3NlYXJjaFR5cGVzEhQKBWxpbWl0GAMgASgFUgVsaW1pdBIcCgl0aW1l'
    'c3RhbXAYBCABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use universalSearchResponseDescriptor instead')
const UniversalSearchResponse$json = {
  '1': 'UniversalSearchResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'users', '3': 3, '4': 3, '5': 11, '6': '.cc.UserProto', '10': 'users'},
    {'1': 'conversations', '3': 4, '4': 3, '5': 11, '6': '.cc.ConversationProto', '10': 'conversations'},
    {'1': 'query', '3': 5, '4': 1, '5': 9, '10': 'query'},
    {'1': 'searched_types', '3': 6, '4': 3, '5': 9, '10': 'searchedTypes'},
    {'1': 'user_count', '3': 7, '4': 1, '5': 5, '10': 'userCount'},
    {'1': 'conversation_count', '3': 8, '4': 1, '5': 5, '10': 'conversationCount'},
    {'1': 'timestamp', '3': 9, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `UniversalSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List universalSearchResponseDescriptor = $convert.base64Decode(
    'ChdVbml2ZXJzYWxTZWFyY2hSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB2'
    '1lc3NhZ2UYAiABKAlSB21lc3NhZ2USIwoFdXNlcnMYAyADKAsyDS5jYy5Vc2VyUHJvdG9SBXVz'
    'ZXJzEjsKDWNvbnZlcnNhdGlvbnMYBCADKAsyFS5jYy5Db252ZXJzYXRpb25Qcm90b1INY29udm'
    'Vyc2F0aW9ucxIUCgVxdWVyeRgFIAEoCVIFcXVlcnkSJQoOc2VhcmNoZWRfdHlwZXMYBiADKAlS'
    'DXNlYXJjaGVkVHlwZXMSHQoKdXNlcl9jb3VudBgHIAEoBVIJdXNlckNvdW50Ei0KEmNvbnZlcn'
    'NhdGlvbl9jb3VudBgIIAEoBVIRY29udmVyc2F0aW9uQ291bnQSHAoJdGltZXN0YW1wGAkgASgD'
    'Ugl0aW1lc3RhbXA=');

@$core.Deprecated('Use changePasswordRequestDescriptor instead')
const ChangePasswordRequest$json = {
  '1': 'ChangePasswordRequest',
  '2': [
    {'1': 'current_password', '3': 1, '4': 1, '5': 9, '10': 'currentPassword'},
    {'1': 'new_password', '3': 2, '4': 1, '5': 9, '10': 'newPassword'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `ChangePasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordRequestDescriptor = $convert.base64Decode(
    'ChVDaGFuZ2VQYXNzd29yZFJlcXVlc3QSKQoQY3VycmVudF9wYXNzd29yZBgBIAEoCVIPY3Vycm'
    'VudFBhc3N3b3JkEiEKDG5ld19wYXNzd29yZBgCIAEoCVILbmV3UGFzc3dvcmQSHAoJdGltZXN0'
    'YW1wGAMgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use changePasswordResponseDescriptor instead')
const ChangePasswordResponse$json = {
  '1': 'ChangePasswordResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `ChangePasswordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordResponseDescriptor = $convert.base64Decode(
    'ChZDaGFuZ2VQYXNzd29yZFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbW'
    'Vzc2FnZRgCIAEoCVIHbWVzc2FnZRIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use getCurrentUserRequestDescriptor instead')
const GetCurrentUserRequest$json = {
  '1': 'GetCurrentUserRequest',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `GetCurrentUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCurrentUserRequestDescriptor = $convert.base64Decode(
    'ChVHZXRDdXJyZW50VXNlclJlcXVlc3QSHAoJdGltZXN0YW1wGAEgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use setPasswordRequestDescriptor instead')
const SetPasswordRequest$json = {
  '1': 'SetPasswordRequest',
  '2': [
    {'1': 'new_password', '3': 1, '4': 1, '5': 9, '10': 'newPassword'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `SetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPasswordRequestDescriptor = $convert.base64Decode(
    'ChJTZXRQYXNzd29yZFJlcXVlc3QSIQoMbmV3X3Bhc3N3b3JkGAEgASgJUgtuZXdQYXNzd29yZB'
    'IcCgl0aW1lc3RhbXAYAiABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use setPasswordResponseDescriptor instead')
const SetPasswordResponse$json = {
  '1': 'SetPasswordResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `SetPasswordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPasswordResponseDescriptor = $convert.base64Decode(
    'ChNTZXRQYXNzd29yZFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2'
    'FnZRgCIAEoCVIHbWVzc2FnZRIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcA==');

