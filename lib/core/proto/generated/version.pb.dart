//
//  Generated code. Do not modify.
//  source: version.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'auth.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// 版本检查请求消息
class VersionCheckRequest extends $pb.GeneratedMessage {
  factory VersionCheckRequest({
    $core.String? currentVersion,
    $core.String? platform,
    ClientInfo? clientInfo,
  }) {
    final $result = create();
    if (currentVersion != null) {
      $result.currentVersion = currentVersion;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (clientInfo != null) {
      $result.clientInfo = clientInfo;
    }
    return $result;
  }
  VersionCheckRequest._() : super();
  factory VersionCheckRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionCheckRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionCheckRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'currentVersion')
    ..aOS(2, _omitFieldNames ? '' : 'platform')
    ..aOM<ClientInfo>(3, _omitFieldNames ? '' : 'clientInfo', subBuilder: ClientInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionCheckRequest clone() => VersionCheckRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionCheckRequest copyWith(void Function(VersionCheckRequest) updates) => super.copyWith((message) => updates(message as VersionCheckRequest)) as VersionCheckRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionCheckRequest create() => VersionCheckRequest._();
  VersionCheckRequest createEmptyInstance() => create();
  static $pb.PbList<VersionCheckRequest> createRepeated() => $pb.PbList<VersionCheckRequest>();
  @$core.pragma('dart2js:noInline')
  static VersionCheckRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionCheckRequest>(create);
  static VersionCheckRequest? _defaultInstance;

  /// 当前客户端版本
  @$pb.TagNumber(1)
  $core.String get currentVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set currentVersion($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCurrentVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentVersion() => $_clearField(1);

  /// 平台类型
  @$pb.TagNumber(2)
  $core.String get platform => $_getSZ(1);
  @$pb.TagNumber(2)
  set platform($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPlatform() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlatform() => $_clearField(2);

  /// 客户端详细信息
  @$pb.TagNumber(3)
  ClientInfo get clientInfo => $_getN(2);
  @$pb.TagNumber(3)
  set clientInfo(ClientInfo v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasClientInfo() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientInfo() => $_clearField(3);
  @$pb.TagNumber(3)
  ClientInfo ensureClientInfo() => $_ensure(2);
}

/// 版本检查响应消息
class VersionCheckResponse extends $pb.GeneratedMessage {
  factory VersionCheckResponse({
    $core.bool? success,
    $core.String? errorMessage,
    $core.bool? hasUpdate,
    $core.String? latestVersion,
    $core.bool? isForced,
    $core.String? releaseNotes,
    $core.String? downloadUrl,
    $fixnum.Int64? releaseDate,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (hasUpdate != null) {
      $result.hasUpdate = hasUpdate;
    }
    if (latestVersion != null) {
      $result.latestVersion = latestVersion;
    }
    if (isForced != null) {
      $result.isForced = isForced;
    }
    if (releaseNotes != null) {
      $result.releaseNotes = releaseNotes;
    }
    if (downloadUrl != null) {
      $result.downloadUrl = downloadUrl;
    }
    if (releaseDate != null) {
      $result.releaseDate = releaseDate;
    }
    return $result;
  }
  VersionCheckResponse._() : super();
  factory VersionCheckResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionCheckResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionCheckResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOB(3, _omitFieldNames ? '' : 'hasUpdate')
    ..aOS(4, _omitFieldNames ? '' : 'latestVersion')
    ..aOB(5, _omitFieldNames ? '' : 'isForced')
    ..aOS(6, _omitFieldNames ? '' : 'releaseNotes')
    ..aOS(7, _omitFieldNames ? '' : 'downloadUrl')
    ..aInt64(8, _omitFieldNames ? '' : 'releaseDate')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionCheckResponse clone() => VersionCheckResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionCheckResponse copyWith(void Function(VersionCheckResponse) updates) => super.copyWith((message) => updates(message as VersionCheckResponse)) as VersionCheckResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionCheckResponse create() => VersionCheckResponse._();
  VersionCheckResponse createEmptyInstance() => create();
  static $pb.PbList<VersionCheckResponse> createRepeated() => $pb.PbList<VersionCheckResponse>();
  @$core.pragma('dart2js:noInline')
  static VersionCheckResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionCheckResponse>(create);
  static VersionCheckResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 错误信息
  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  /// 是否有更新
  @$pb.TagNumber(3)
  $core.bool get hasUpdate => $_getBF(2);
  @$pb.TagNumber(3)
  set hasUpdate($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHasUpdate() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasUpdate() => $_clearField(3);

  /// 最新版本号
  @$pb.TagNumber(4)
  $core.String get latestVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set latestVersion($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLatestVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearLatestVersion() => $_clearField(4);

  /// 是否强制更新
  @$pb.TagNumber(5)
  $core.bool get isForced => $_getBF(4);
  @$pb.TagNumber(5)
  set isForced($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsForced() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsForced() => $_clearField(5);

  /// 发布说明
  @$pb.TagNumber(6)
  $core.String get releaseNotes => $_getSZ(5);
  @$pb.TagNumber(6)
  set releaseNotes($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReleaseNotes() => $_has(5);
  @$pb.TagNumber(6)
  void clearReleaseNotes() => $_clearField(6);

  /// 下载链接
  @$pb.TagNumber(7)
  $core.String get downloadUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set downloadUrl($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDownloadUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearDownloadUrl() => $_clearField(7);

  /// 发布时间（毫秒时间戳）
  @$pb.TagNumber(8)
  $fixnum.Int64 get releaseDate => $_getI64(7);
  @$pb.TagNumber(8)
  set releaseDate($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasReleaseDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearReleaseDate() => $_clearField(8);
}

/// 客户端详细信息
class ClientInfo extends $pb.GeneratedMessage {
  factory ClientInfo({
    $core.String? version,
    $core.String? buildNumber,
    $core.String? platform,
    $2.DeviceInfo? deviceInfo,
    $pb.PbMap<$core.String, $core.String>? metadata,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (buildNumber != null) {
      $result.buildNumber = buildNumber;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (deviceInfo != null) {
      $result.deviceInfo = deviceInfo;
    }
    if (metadata != null) {
      $result.metadata.addAll(metadata);
    }
    return $result;
  }
  ClientInfo._() : super();
  factory ClientInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'buildNumber')
    ..aOS(3, _omitFieldNames ? '' : 'platform')
    ..aOM<$2.DeviceInfo>(4, _omitFieldNames ? '' : 'deviceInfo', subBuilder: $2.DeviceInfo.create)
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'metadata', entryClassName: 'ClientInfo.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('cc'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientInfo clone() => ClientInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientInfo copyWith(void Function(ClientInfo) updates) => super.copyWith((message) => updates(message as ClientInfo)) as ClientInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientInfo create() => ClientInfo._();
  ClientInfo createEmptyInstance() => create();
  static $pb.PbList<ClientInfo> createRepeated() => $pb.PbList<ClientInfo>();
  @$core.pragma('dart2js:noInline')
  static ClientInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientInfo>(create);
  static ClientInfo? _defaultInstance;

  /// 应用版本
  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  /// 构建号
  @$pb.TagNumber(2)
  $core.String get buildNumber => $_getSZ(1);
  @$pb.TagNumber(2)
  set buildNumber($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBuildNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuildNumber() => $_clearField(2);

  /// 平台类型
  @$pb.TagNumber(3)
  $core.String get platform => $_getSZ(2);
  @$pb.TagNumber(3)
  set platform($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPlatform() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlatform() => $_clearField(3);

  /// 设备信息
  @$pb.TagNumber(4)
  $2.DeviceInfo get deviceInfo => $_getN(3);
  @$pb.TagNumber(4)
  set deviceInfo($2.DeviceInfo v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDeviceInfo() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceInfo() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.DeviceInfo ensureDeviceInfo() => $_ensure(3);

  /// 其他客户端信息
  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(4);
}

/// 版本发布信息
class VersionRelease extends $pb.GeneratedMessage {
  factory VersionRelease({
    $core.String? version,
    $core.String? platform,
    $core.String? releaseNotes,
    $core.String? downloadUrl,
    $core.bool? isForced,
    $core.String? minSupportedVersion,
    $fixnum.Int64? releaseDate,
    $core.bool? isActive,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (releaseNotes != null) {
      $result.releaseNotes = releaseNotes;
    }
    if (downloadUrl != null) {
      $result.downloadUrl = downloadUrl;
    }
    if (isForced != null) {
      $result.isForced = isForced;
    }
    if (minSupportedVersion != null) {
      $result.minSupportedVersion = minSupportedVersion;
    }
    if (releaseDate != null) {
      $result.releaseDate = releaseDate;
    }
    if (isActive != null) {
      $result.isActive = isActive;
    }
    return $result;
  }
  VersionRelease._() : super();
  factory VersionRelease.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionRelease.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionRelease', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'platform')
    ..aOS(3, _omitFieldNames ? '' : 'releaseNotes')
    ..aOS(4, _omitFieldNames ? '' : 'downloadUrl')
    ..aOB(5, _omitFieldNames ? '' : 'isForced')
    ..aOS(6, _omitFieldNames ? '' : 'minSupportedVersion')
    ..aInt64(7, _omitFieldNames ? '' : 'releaseDate')
    ..aOB(8, _omitFieldNames ? '' : 'isActive')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionRelease clone() => VersionRelease()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionRelease copyWith(void Function(VersionRelease) updates) => super.copyWith((message) => updates(message as VersionRelease)) as VersionRelease;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionRelease create() => VersionRelease._();
  VersionRelease createEmptyInstance() => create();
  static $pb.PbList<VersionRelease> createRepeated() => $pb.PbList<VersionRelease>();
  @$core.pragma('dart2js:noInline')
  static VersionRelease getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionRelease>(create);
  static VersionRelease? _defaultInstance;

  /// 版本号
  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  /// 平台类型
  @$pb.TagNumber(2)
  $core.String get platform => $_getSZ(1);
  @$pb.TagNumber(2)
  set platform($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPlatform() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlatform() => $_clearField(2);

  /// 发布说明
  @$pb.TagNumber(3)
  $core.String get releaseNotes => $_getSZ(2);
  @$pb.TagNumber(3)
  set releaseNotes($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReleaseNotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearReleaseNotes() => $_clearField(3);

  /// 下载链接
  @$pb.TagNumber(4)
  $core.String get downloadUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set downloadUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDownloadUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearDownloadUrl() => $_clearField(4);

  /// 是否强制更新
  @$pb.TagNumber(5)
  $core.bool get isForced => $_getBF(4);
  @$pb.TagNumber(5)
  set isForced($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsForced() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsForced() => $_clearField(5);

  /// 最低支持版本
  @$pb.TagNumber(6)
  $core.String get minSupportedVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set minSupportedVersion($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMinSupportedVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinSupportedVersion() => $_clearField(6);

  /// 发布时间（毫秒时间戳）
  @$pb.TagNumber(7)
  $fixnum.Int64 get releaseDate => $_getI64(6);
  @$pb.TagNumber(7)
  set releaseDate($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasReleaseDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearReleaseDate() => $_clearField(7);

  /// 是否激活
  @$pb.TagNumber(8)
  $core.bool get isActive => $_getBF(7);
  @$pb.TagNumber(8)
  set isActive($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsActive() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsActive() => $_clearField(8);
}

/// 版本统计请求
class VersionStatsRequest extends $pb.GeneratedMessage {
  factory VersionStatsRequest({
    $core.int? days,
    $core.String? platform,
  }) {
    final $result = create();
    if (days != null) {
      $result.days = days;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    return $result;
  }
  VersionStatsRequest._() : super();
  factory VersionStatsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionStatsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionStatsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'days', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'platform')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionStatsRequest clone() => VersionStatsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionStatsRequest copyWith(void Function(VersionStatsRequest) updates) => super.copyWith((message) => updates(message as VersionStatsRequest)) as VersionStatsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionStatsRequest create() => VersionStatsRequest._();
  VersionStatsRequest createEmptyInstance() => create();
  static $pb.PbList<VersionStatsRequest> createRepeated() => $pb.PbList<VersionStatsRequest>();
  @$core.pragma('dart2js:noInline')
  static VersionStatsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionStatsRequest>(create);
  static VersionStatsRequest? _defaultInstance;

  /// 查询的天数，默认30天
  @$pb.TagNumber(1)
  $core.int get days => $_getIZ(0);
  @$pb.TagNumber(1)
  set days($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDays() => $_has(0);
  @$pb.TagNumber(1)
  void clearDays() => $_clearField(1);

  /// 平台过滤
  @$pb.TagNumber(2)
  $core.String get platform => $_getSZ(1);
  @$pb.TagNumber(2)
  set platform($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPlatform() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlatform() => $_clearField(2);
}

/// 版本统计响应
class VersionStatsResponse extends $pb.GeneratedMessage {
  factory VersionStatsResponse({
    $core.bool? success,
    $core.String? errorMessage,
    $core.Iterable<VersionDistribution>? versionDistribution,
    $core.Iterable<PlatformDistribution>? platformDistribution,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (versionDistribution != null) {
      $result.versionDistribution.addAll(versionDistribution);
    }
    if (platformDistribution != null) {
      $result.platformDistribution.addAll(platformDistribution);
    }
    return $result;
  }
  VersionStatsResponse._() : super();
  factory VersionStatsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionStatsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionStatsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..pc<VersionDistribution>(3, _omitFieldNames ? '' : 'versionDistribution', $pb.PbFieldType.PM, subBuilder: VersionDistribution.create)
    ..pc<PlatformDistribution>(4, _omitFieldNames ? '' : 'platformDistribution', $pb.PbFieldType.PM, subBuilder: PlatformDistribution.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionStatsResponse clone() => VersionStatsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionStatsResponse copyWith(void Function(VersionStatsResponse) updates) => super.copyWith((message) => updates(message as VersionStatsResponse)) as VersionStatsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionStatsResponse create() => VersionStatsResponse._();
  VersionStatsResponse createEmptyInstance() => create();
  static $pb.PbList<VersionStatsResponse> createRepeated() => $pb.PbList<VersionStatsResponse>();
  @$core.pragma('dart2js:noInline')
  static VersionStatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionStatsResponse>(create);
  static VersionStatsResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 错误信息
  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  /// 版本分布统计
  @$pb.TagNumber(3)
  $pb.PbList<VersionDistribution> get versionDistribution => $_getList(2);

  /// 平台分布统计
  @$pb.TagNumber(4)
  $pb.PbList<PlatformDistribution> get platformDistribution => $_getList(3);
}

/// 版本分布统计
class VersionDistribution extends $pb.GeneratedMessage {
  factory VersionDistribution({
    $core.String? platform,
    $core.String? appVersion,
    $core.int? userCount,
    $core.int? uniqueUsers,
  }) {
    final $result = create();
    if (platform != null) {
      $result.platform = platform;
    }
    if (appVersion != null) {
      $result.appVersion = appVersion;
    }
    if (userCount != null) {
      $result.userCount = userCount;
    }
    if (uniqueUsers != null) {
      $result.uniqueUsers = uniqueUsers;
    }
    return $result;
  }
  VersionDistribution._() : super();
  factory VersionDistribution.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionDistribution.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionDistribution', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'platform')
    ..aOS(2, _omitFieldNames ? '' : 'appVersion')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'userCount', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'uniqueUsers', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionDistribution clone() => VersionDistribution()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionDistribution copyWith(void Function(VersionDistribution) updates) => super.copyWith((message) => updates(message as VersionDistribution)) as VersionDistribution;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionDistribution create() => VersionDistribution._();
  VersionDistribution createEmptyInstance() => create();
  static $pb.PbList<VersionDistribution> createRepeated() => $pb.PbList<VersionDistribution>();
  @$core.pragma('dart2js:noInline')
  static VersionDistribution getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionDistribution>(create);
  static VersionDistribution? _defaultInstance;

  /// 平台
  @$pb.TagNumber(1)
  $core.String get platform => $_getSZ(0);
  @$pb.TagNumber(1)
  set platform($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlatform() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlatform() => $_clearField(1);

  /// 应用版本
  @$pb.TagNumber(2)
  $core.String get appVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set appVersion($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAppVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearAppVersion() => $_clearField(2);

  /// 用户数量
  @$pb.TagNumber(3)
  $core.int get userCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set userCount($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserCount() => $_clearField(3);

  /// 唯一用户数
  @$pb.TagNumber(4)
  $core.int get uniqueUsers => $_getIZ(3);
  @$pb.TagNumber(4)
  set uniqueUsers($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUniqueUsers() => $_has(3);
  @$pb.TagNumber(4)
  void clearUniqueUsers() => $_clearField(4);
}

/// 平台分布统计
class PlatformDistribution extends $pb.GeneratedMessage {
  factory PlatformDistribution({
    $core.String? platform,
    $core.int? userCount,
    $core.int? deviceCount,
  }) {
    final $result = create();
    if (platform != null) {
      $result.platform = platform;
    }
    if (userCount != null) {
      $result.userCount = userCount;
    }
    if (deviceCount != null) {
      $result.deviceCount = deviceCount;
    }
    return $result;
  }
  PlatformDistribution._() : super();
  factory PlatformDistribution.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlatformDistribution.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlatformDistribution', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'platform')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'userCount', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'deviceCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlatformDistribution clone() => PlatformDistribution()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlatformDistribution copyWith(void Function(PlatformDistribution) updates) => super.copyWith((message) => updates(message as PlatformDistribution)) as PlatformDistribution;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlatformDistribution create() => PlatformDistribution._();
  PlatformDistribution createEmptyInstance() => create();
  static $pb.PbList<PlatformDistribution> createRepeated() => $pb.PbList<PlatformDistribution>();
  @$core.pragma('dart2js:noInline')
  static PlatformDistribution getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlatformDistribution>(create);
  static PlatformDistribution? _defaultInstance;

  /// 平台
  @$pb.TagNumber(1)
  $core.String get platform => $_getSZ(0);
  @$pb.TagNumber(1)
  set platform($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlatform() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlatform() => $_clearField(1);

  /// 用户数量
  @$pb.TagNumber(2)
  $core.int get userCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set userCount($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserCount() => $_clearField(2);

  /// 设备数量
  @$pb.TagNumber(3)
  $core.int get deviceCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set deviceCount($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceCount() => $_clearField(3);
}

/// 版本发布请求
class VersionReleaseRequest extends $pb.GeneratedMessage {
  factory VersionReleaseRequest({
    $core.String? version,
    $core.String? platform,
    $core.String? releaseNotes,
    $core.String? downloadUrl,
    $core.bool? isForced,
    $core.String? minSupportedVersion,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (releaseNotes != null) {
      $result.releaseNotes = releaseNotes;
    }
    if (downloadUrl != null) {
      $result.downloadUrl = downloadUrl;
    }
    if (isForced != null) {
      $result.isForced = isForced;
    }
    if (minSupportedVersion != null) {
      $result.minSupportedVersion = minSupportedVersion;
    }
    return $result;
  }
  VersionReleaseRequest._() : super();
  factory VersionReleaseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionReleaseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionReleaseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'platform')
    ..aOS(3, _omitFieldNames ? '' : 'releaseNotes')
    ..aOS(4, _omitFieldNames ? '' : 'downloadUrl')
    ..aOB(5, _omitFieldNames ? '' : 'isForced')
    ..aOS(6, _omitFieldNames ? '' : 'minSupportedVersion')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionReleaseRequest clone() => VersionReleaseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionReleaseRequest copyWith(void Function(VersionReleaseRequest) updates) => super.copyWith((message) => updates(message as VersionReleaseRequest)) as VersionReleaseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionReleaseRequest create() => VersionReleaseRequest._();
  VersionReleaseRequest createEmptyInstance() => create();
  static $pb.PbList<VersionReleaseRequest> createRepeated() => $pb.PbList<VersionReleaseRequest>();
  @$core.pragma('dart2js:noInline')
  static VersionReleaseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionReleaseRequest>(create);
  static VersionReleaseRequest? _defaultInstance;

  /// 版本号
  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  /// 平台类型
  @$pb.TagNumber(2)
  $core.String get platform => $_getSZ(1);
  @$pb.TagNumber(2)
  set platform($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPlatform() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlatform() => $_clearField(2);

  /// 发布说明
  @$pb.TagNumber(3)
  $core.String get releaseNotes => $_getSZ(2);
  @$pb.TagNumber(3)
  set releaseNotes($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReleaseNotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearReleaseNotes() => $_clearField(3);

  /// 下载链接
  @$pb.TagNumber(4)
  $core.String get downloadUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set downloadUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDownloadUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearDownloadUrl() => $_clearField(4);

  /// 是否强制更新
  @$pb.TagNumber(5)
  $core.bool get isForced => $_getBF(4);
  @$pb.TagNumber(5)
  set isForced($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsForced() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsForced() => $_clearField(5);

  /// 最低支持版本
  @$pb.TagNumber(6)
  $core.String get minSupportedVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set minSupportedVersion($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMinSupportedVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinSupportedVersion() => $_clearField(6);
}

/// 版本发布响应
class VersionReleaseResponse extends $pb.GeneratedMessage {
  factory VersionReleaseResponse({
    $core.bool? success,
    $core.String? errorMessage,
    VersionRelease? release,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (release != null) {
      $result.release = release;
    }
    return $result;
  }
  VersionReleaseResponse._() : super();
  factory VersionReleaseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionReleaseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionReleaseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<VersionRelease>(3, _omitFieldNames ? '' : 'release', subBuilder: VersionRelease.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionReleaseResponse clone() => VersionReleaseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionReleaseResponse copyWith(void Function(VersionReleaseResponse) updates) => super.copyWith((message) => updates(message as VersionReleaseResponse)) as VersionReleaseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionReleaseResponse create() => VersionReleaseResponse._();
  VersionReleaseResponse createEmptyInstance() => create();
  static $pb.PbList<VersionReleaseResponse> createRepeated() => $pb.PbList<VersionReleaseResponse>();
  @$core.pragma('dart2js:noInline')
  static VersionReleaseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionReleaseResponse>(create);
  static VersionReleaseResponse? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// 错误信息
  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  /// 发布的版本信息
  @$pb.TagNumber(3)
  VersionRelease get release => $_getN(2);
  @$pb.TagNumber(3)
  set release(VersionRelease v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRelease() => $_has(2);
  @$pb.TagNumber(3)
  void clearRelease() => $_clearField(3);
  @$pb.TagNumber(3)
  VersionRelease ensureRelease() => $_ensure(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
