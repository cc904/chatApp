// This is a generated file - do not edit.
//
// Generated from version.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use versionCheckRequestDescriptor instead')
const VersionCheckRequest$json = {
  '1': 'VersionCheckRequest',
  '2': [
    {'1': 'current_version', '3': 1, '4': 1, '5': 9, '10': 'currentVersion'},
    {'1': 'platform', '3': 2, '4': 1, '5': 9, '10': 'platform'},
    {
      '1': 'client_info',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.ClientInfo',
      '10': 'clientInfo'
    },
  ],
};

/// Descriptor for `VersionCheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionCheckRequestDescriptor = $convert.base64Decode(
    'ChNWZXJzaW9uQ2hlY2tSZXF1ZXN0EicKD2N1cnJlbnRfdmVyc2lvbhgBIAEoCVIOY3VycmVudF'
    'ZlcnNpb24SGgoIcGxhdGZvcm0YAiABKAlSCHBsYXRmb3JtEi8KC2NsaWVudF9pbmZvGAMgASgL'
    'Mg4uY2MuQ2xpZW50SW5mb1IKY2xpZW50SW5mbw==');

@$core.Deprecated('Use versionCheckResponseDescriptor instead')
const VersionCheckResponse$json = {
  '1': 'VersionCheckResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'has_update', '3': 3, '4': 1, '5': 8, '10': 'hasUpdate'},
    {'1': 'latest_version', '3': 4, '4': 1, '5': 9, '10': 'latestVersion'},
    {'1': 'is_forced', '3': 5, '4': 1, '5': 8, '10': 'isForced'},
    {'1': 'release_notes', '3': 6, '4': 1, '5': 9, '10': 'releaseNotes'},
    {'1': 'download_url', '3': 7, '4': 1, '5': 9, '10': 'downloadUrl'},
    {'1': 'release_date', '3': 8, '4': 1, '5': 3, '10': 'releaseDate'},
  ],
};

/// Descriptor for `VersionCheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionCheckResponseDescriptor = $convert.base64Decode(
    'ChRWZXJzaW9uQ2hlY2tSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiMKDWVycm'
    '9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZRIdCgpoYXNfdXBkYXRlGAMgASgIUgloYXNV'
    'cGRhdGUSJQoObGF0ZXN0X3ZlcnNpb24YBCABKAlSDWxhdGVzdFZlcnNpb24SGwoJaXNfZm9yY2'
    'VkGAUgASgIUghpc0ZvcmNlZBIjCg1yZWxlYXNlX25vdGVzGAYgASgJUgxyZWxlYXNlTm90ZXMS'
    'IQoMZG93bmxvYWRfdXJsGAcgASgJUgtkb3dubG9hZFVybBIhCgxyZWxlYXNlX2RhdGUYCCABKA'
    'NSC3JlbGVhc2VEYXRl');

@$core.Deprecated('Use clientInfoDescriptor instead')
const ClientInfo$json = {
  '1': 'ClientInfo',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'build_number', '3': 2, '4': 1, '5': 9, '10': 'buildNumber'},
    {'1': 'platform', '3': 3, '4': 1, '5': 9, '10': 'platform'},
    {
      '1': 'device_info',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.cc.DeviceInfo',
      '10': 'deviceInfo'
    },
    {
      '1': 'metadata',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.cc.ClientInfo.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [ClientInfo_MetadataEntry$json],
};

@$core.Deprecated('Use clientInfoDescriptor instead')
const ClientInfo_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ClientInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientInfoDescriptor = $convert.base64Decode(
    'CgpDbGllbnRJbmZvEhgKB3ZlcnNpb24YASABKAlSB3ZlcnNpb24SIQoMYnVpbGRfbnVtYmVyGA'
    'IgASgJUgtidWlsZE51bWJlchIaCghwbGF0Zm9ybRgDIAEoCVIIcGxhdGZvcm0SLwoLZGV2aWNl'
    'X2luZm8YBCABKAsyDi5jYy5EZXZpY2VJbmZvUgpkZXZpY2VJbmZvEjgKCG1ldGFkYXRhGAUgAy'
    'gLMhwuY2MuQ2xpZW50SW5mby5NZXRhZGF0YUVudHJ5UghtZXRhZGF0YRo7Cg1NZXRhZGF0YUVu'
    'dHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use versionReleaseDescriptor instead')
const VersionRelease$json = {
  '1': 'VersionRelease',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'platform', '3': 2, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'release_notes', '3': 3, '4': 1, '5': 9, '10': 'releaseNotes'},
    {'1': 'download_url', '3': 4, '4': 1, '5': 9, '10': 'downloadUrl'},
    {'1': 'is_forced', '3': 5, '4': 1, '5': 8, '10': 'isForced'},
    {
      '1': 'min_supported_version',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'minSupportedVersion'
    },
    {'1': 'release_date', '3': 7, '4': 1, '5': 3, '10': 'releaseDate'},
    {'1': 'is_active', '3': 8, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

/// Descriptor for `VersionRelease`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionReleaseDescriptor = $convert.base64Decode(
    'Cg5WZXJzaW9uUmVsZWFzZRIYCgd2ZXJzaW9uGAEgASgJUgd2ZXJzaW9uEhoKCHBsYXRmb3JtGA'
    'IgASgJUghwbGF0Zm9ybRIjCg1yZWxlYXNlX25vdGVzGAMgASgJUgxyZWxlYXNlTm90ZXMSIQoM'
    'ZG93bmxvYWRfdXJsGAQgASgJUgtkb3dubG9hZFVybBIbCglpc19mb3JjZWQYBSABKAhSCGlzRm'
    '9yY2VkEjIKFW1pbl9zdXBwb3J0ZWRfdmVyc2lvbhgGIAEoCVITbWluU3VwcG9ydGVkVmVyc2lv'
    'bhIhCgxyZWxlYXNlX2RhdGUYByABKANSC3JlbGVhc2VEYXRlEhsKCWlzX2FjdGl2ZRgIIAEoCF'
    'IIaXNBY3RpdmU=');

@$core.Deprecated('Use versionStatsRequestDescriptor instead')
const VersionStatsRequest$json = {
  '1': 'VersionStatsRequest',
  '2': [
    {'1': 'days', '3': 1, '4': 1, '5': 5, '10': 'days'},
    {'1': 'platform', '3': 2, '4': 1, '5': 9, '10': 'platform'},
  ],
};

/// Descriptor for `VersionStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionStatsRequestDescriptor = $convert.base64Decode(
    'ChNWZXJzaW9uU3RhdHNSZXF1ZXN0EhIKBGRheXMYASABKAVSBGRheXMSGgoIcGxhdGZvcm0YAi'
    'ABKAlSCHBsYXRmb3Jt');

@$core.Deprecated('Use versionStatsResponseDescriptor instead')
const VersionStatsResponse$json = {
  '1': 'VersionStatsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'version_distribution',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.cc.VersionDistribution',
      '10': 'versionDistribution'
    },
    {
      '1': 'platform_distribution',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.cc.PlatformDistribution',
      '10': 'platformDistribution'
    },
  ],
};

/// Descriptor for `VersionStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionStatsResponseDescriptor = $convert.base64Decode(
    'ChRWZXJzaW9uU3RhdHNSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiMKDWVycm'
    '9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZRJKChR2ZXJzaW9uX2Rpc3RyaWJ1dGlvbhgD'
    'IAMoCzIXLmNjLlZlcnNpb25EaXN0cmlidXRpb25SE3ZlcnNpb25EaXN0cmlidXRpb24STQoVcG'
    'xhdGZvcm1fZGlzdHJpYnV0aW9uGAQgAygLMhguY2MuUGxhdGZvcm1EaXN0cmlidXRpb25SFHBs'
    'YXRmb3JtRGlzdHJpYnV0aW9u');

@$core.Deprecated('Use versionDistributionDescriptor instead')
const VersionDistribution$json = {
  '1': 'VersionDistribution',
  '2': [
    {'1': 'platform', '3': 1, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'app_version', '3': 2, '4': 1, '5': 9, '10': 'appVersion'},
    {'1': 'user_count', '3': 3, '4': 1, '5': 5, '10': 'userCount'},
    {'1': 'unique_users', '3': 4, '4': 1, '5': 5, '10': 'uniqueUsers'},
  ],
};

/// Descriptor for `VersionDistribution`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionDistributionDescriptor = $convert.base64Decode(
    'ChNWZXJzaW9uRGlzdHJpYnV0aW9uEhoKCHBsYXRmb3JtGAEgASgJUghwbGF0Zm9ybRIfCgthcH'
    'BfdmVyc2lvbhgCIAEoCVIKYXBwVmVyc2lvbhIdCgp1c2VyX2NvdW50GAMgASgFUgl1c2VyQ291'
    'bnQSIQoMdW5pcXVlX3VzZXJzGAQgASgFUgt1bmlxdWVVc2Vycw==');

@$core.Deprecated('Use platformDistributionDescriptor instead')
const PlatformDistribution$json = {
  '1': 'PlatformDistribution',
  '2': [
    {'1': 'platform', '3': 1, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'user_count', '3': 2, '4': 1, '5': 5, '10': 'userCount'},
    {'1': 'device_count', '3': 3, '4': 1, '5': 5, '10': 'deviceCount'},
  ],
};

/// Descriptor for `PlatformDistribution`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List platformDistributionDescriptor = $convert.base64Decode(
    'ChRQbGF0Zm9ybURpc3RyaWJ1dGlvbhIaCghwbGF0Zm9ybRgBIAEoCVIIcGxhdGZvcm0SHQoKdX'
    'Nlcl9jb3VudBgCIAEoBVIJdXNlckNvdW50EiEKDGRldmljZV9jb3VudBgDIAEoBVILZGV2aWNl'
    'Q291bnQ=');

@$core.Deprecated('Use versionReleaseRequestDescriptor instead')
const VersionReleaseRequest$json = {
  '1': 'VersionReleaseRequest',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'platform', '3': 2, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'release_notes', '3': 3, '4': 1, '5': 9, '10': 'releaseNotes'},
    {'1': 'download_url', '3': 4, '4': 1, '5': 9, '10': 'downloadUrl'},
    {'1': 'is_forced', '3': 5, '4': 1, '5': 8, '10': 'isForced'},
    {
      '1': 'min_supported_version',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'minSupportedVersion'
    },
  ],
};

/// Descriptor for `VersionReleaseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionReleaseRequestDescriptor = $convert.base64Decode(
    'ChVWZXJzaW9uUmVsZWFzZVJlcXVlc3QSGAoHdmVyc2lvbhgBIAEoCVIHdmVyc2lvbhIaCghwbG'
    'F0Zm9ybRgCIAEoCVIIcGxhdGZvcm0SIwoNcmVsZWFzZV9ub3RlcxgDIAEoCVIMcmVsZWFzZU5v'
    'dGVzEiEKDGRvd25sb2FkX3VybBgEIAEoCVILZG93bmxvYWRVcmwSGwoJaXNfZm9yY2VkGAUgAS'
    'gIUghpc0ZvcmNlZBIyChVtaW5fc3VwcG9ydGVkX3ZlcnNpb24YBiABKAlSE21pblN1cHBvcnRl'
    'ZFZlcnNpb24=');

@$core.Deprecated('Use versionReleaseResponseDescriptor instead')
const VersionReleaseResponse$json = {
  '1': 'VersionReleaseResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'release',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.cc.VersionRelease',
      '10': 'release'
    },
  ],
};

/// Descriptor for `VersionReleaseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionReleaseResponseDescriptor = $convert.base64Decode(
    'ChZWZXJzaW9uUmVsZWFzZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZX'
    'Jyb3JfbWVzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdlEiwKB3JlbGVhc2UYAyABKAsyEi5jYy5W'
    'ZXJzaW9uUmVsZWFzZVIHcmVsZWFzZQ==');
