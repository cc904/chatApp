// This is a generated file - do not edit.
//
// Generated from quick_reply.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// 快捷回复数据
class QuickReply extends $pb.GeneratedMessage {
  factory QuickReply({
    $fixnum.Int64? id,
    $core.String? content,
    $core.String? category,
    $core.int? orderIndex,
    $core.bool? isEnabled,
    $core.String? userId,
    $core.String? type,
    $core.String? mediaType,
    $core.String? mediaUrl,
    $core.String? mimeType,
    $core.int? width,
    $core.int? height,
    $core.int? duration,
    $core.double? fileSizeKb,
    $core.String? fileName,
    $core.String? fsId,
    $core.String? caption,
    $core.String? thumbUrl,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (content != null) result.content = content;
    if (category != null) result.category = category;
    if (orderIndex != null) result.orderIndex = orderIndex;
    if (isEnabled != null) result.isEnabled = isEnabled;
    if (userId != null) result.userId = userId;
    if (type != null) result.type = type;
    if (mediaType != null) result.mediaType = mediaType;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (mimeType != null) result.mimeType = mimeType;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (duration != null) result.duration = duration;
    if (fileSizeKb != null) result.fileSizeKb = fileSizeKb;
    if (fileName != null) result.fileName = fileName;
    if (fsId != null) result.fsId = fsId;
    if (caption != null) result.caption = caption;
    if (thumbUrl != null) result.thumbUrl = thumbUrl;
    if (name != null) result.name = name;
    return result;
  }

  QuickReply._();

  factory QuickReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuickReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuickReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..aOS(3, _omitFieldNames ? '' : 'category')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'orderIndex', $pb.PbFieldType.O3)
    ..aOB(5, _omitFieldNames ? '' : 'isEnabled')
    ..aOS(6, _omitFieldNames ? '' : 'userId')
    ..aOS(7, _omitFieldNames ? '' : 'type')
    ..aOS(8, _omitFieldNames ? '' : 'mediaType')
    ..aOS(9, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(10, _omitFieldNames ? '' : 'mimeType')
    ..a<$core.int>(11, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..a<$core.double>(
        14, _omitFieldNames ? '' : 'fileSizeKb', $pb.PbFieldType.OD)
    ..aOS(15, _omitFieldNames ? '' : 'fileName')
    ..aOS(16, _omitFieldNames ? '' : 'fsId')
    ..aOS(17, _omitFieldNames ? '' : 'caption')
    ..aOS(18, _omitFieldNames ? '' : 'thumbUrl')
    ..aOS(19, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuickReply clone() => QuickReply()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuickReply copyWith(void Function(QuickReply) updates) =>
      super.copyWith((message) => updates(message as QuickReply)) as QuickReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuickReply create() => QuickReply._();
  @$core.override
  QuickReply createEmptyInstance() => create();
  static $pb.PbList<QuickReply> createRepeated() => $pb.PbList<QuickReply>();
  @$core.pragma('dart2js:noInline')
  static QuickReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuickReply>(create);
  static QuickReply? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get category => $_getSZ(2);
  @$pb.TagNumber(3)
  set category($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get orderIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set orderIndex($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrderIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrderIndex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set isEnabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsEnabled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get userId => $_getSZ(5);
  @$pb.TagNumber(6)
  set userId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUserId() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get type => $_getSZ(6);
  @$pb.TagNumber(7)
  set type($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasType() => $_has(6);
  @$pb.TagNumber(7)
  void clearType() => $_clearField(7);

  /// 可选的媒体扩展字段（用于非文本快捷回复）
  @$pb.TagNumber(8)
  $core.String get mediaType => $_getSZ(7);
  @$pb.TagNumber(8)
  set mediaType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMediaType() => $_has(7);
  @$pb.TagNumber(8)
  void clearMediaType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get mediaUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set mediaUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMediaUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearMediaUrl() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get mimeType => $_getSZ(9);
  @$pb.TagNumber(10)
  set mimeType($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMimeType() => $_has(9);
  @$pb.TagNumber(10)
  void clearMimeType() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get width => $_getIZ(10);
  @$pb.TagNumber(11)
  set width($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasWidth() => $_has(10);
  @$pb.TagNumber(11)
  void clearWidth() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get height => $_getIZ(11);
  @$pb.TagNumber(12)
  set height($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHeight() => $_has(11);
  @$pb.TagNumber(12)
  void clearHeight() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get duration => $_getIZ(12);
  @$pb.TagNumber(13)
  set duration($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDuration() => $_has(12);
  @$pb.TagNumber(13)
  void clearDuration() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get fileSizeKb => $_getN(13);
  @$pb.TagNumber(14)
  set fileSizeKb($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasFileSizeKb() => $_has(13);
  @$pb.TagNumber(14)
  void clearFileSizeKb() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get fileName => $_getSZ(14);
  @$pb.TagNumber(15)
  set fileName($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasFileName() => $_has(14);
  @$pb.TagNumber(15)
  void clearFileName() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get fsId => $_getSZ(15);
  @$pb.TagNumber(16)
  set fsId($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasFsId() => $_has(15);
  @$pb.TagNumber(16)
  void clearFsId() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get caption => $_getSZ(16);
  @$pb.TagNumber(17)
  set caption($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasCaption() => $_has(16);
  @$pb.TagNumber(17)
  void clearCaption() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get thumbUrl => $_getSZ(17);
  @$pb.TagNumber(18)
  set thumbUrl($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasThumbUrl() => $_has(17);
  @$pb.TagNumber(18)
  void clearThumbUrl() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get name => $_getSZ(18);
  @$pb.TagNumber(19)
  set name($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasName() => $_has(18);
  @$pb.TagNumber(19)
  void clearName() => $_clearField(19);
}

/// 获取快捷回复请求
class GetQuickRepliesRequest extends $pb.GeneratedMessage {
  factory GetQuickRepliesRequest({
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  GetQuickRepliesRequest._();

  factory GetQuickRepliesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetQuickRepliesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetQuickRepliesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuickRepliesRequest clone() =>
      GetQuickRepliesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuickRepliesRequest copyWith(
          void Function(GetQuickRepliesRequest) updates) =>
      super.copyWith((message) => updates(message as GetQuickRepliesRequest))
          as GetQuickRepliesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetQuickRepliesRequest create() => GetQuickRepliesRequest._();
  @$core.override
  GetQuickRepliesRequest createEmptyInstance() => create();
  static $pb.PbList<GetQuickRepliesRequest> createRepeated() =>
      $pb.PbList<GetQuickRepliesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetQuickRepliesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetQuickRepliesRequest>(create);
  static GetQuickRepliesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
}

/// 获取快捷回复响应
class GetQuickRepliesResponse extends $pb.GeneratedMessage {
  factory GetQuickRepliesResponse({
    $core.Iterable<QuickReply>? quickReplies,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (quickReplies != null) result.quickReplies.addAll(quickReplies);
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  GetQuickRepliesResponse._();

  factory GetQuickRepliesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetQuickRepliesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetQuickRepliesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..pc<QuickReply>(
        1, _omitFieldNames ? '' : 'quickReplies', $pb.PbFieldType.PM,
        subBuilder: QuickReply.create)
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuickRepliesResponse clone() =>
      GetQuickRepliesResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuickRepliesResponse copyWith(
          void Function(GetQuickRepliesResponse) updates) =>
      super.copyWith((message) => updates(message as GetQuickRepliesResponse))
          as GetQuickRepliesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetQuickRepliesResponse create() => GetQuickRepliesResponse._();
  @$core.override
  GetQuickRepliesResponse createEmptyInstance() => create();
  static $pb.PbList<GetQuickRepliesResponse> createRepeated() =>
      $pb.PbList<GetQuickRepliesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetQuickRepliesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetQuickRepliesResponse>(create);
  static GetQuickRepliesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<QuickReply> get quickReplies => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
}

/// 创建快捷回复请求
class CreateQuickReplyRequest extends $pb.GeneratedMessage {
  factory CreateQuickReplyRequest({
    $core.String? content,
    $core.String? category,
    $core.int? orderIndex,
    $core.bool? isEnabled,
    $core.String? mediaType,
    $core.String? mediaUrl,
    $core.String? mimeType,
    $core.int? width,
    $core.int? height,
    $core.int? duration,
    $core.double? fileSizeKb,
    $core.String? fileName,
    $core.String? fsId,
    $core.String? caption,
    $core.String? thumbUrl,
    $core.String? name,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (category != null) result.category = category;
    if (orderIndex != null) result.orderIndex = orderIndex;
    if (isEnabled != null) result.isEnabled = isEnabled;
    if (mediaType != null) result.mediaType = mediaType;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (mimeType != null) result.mimeType = mimeType;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (duration != null) result.duration = duration;
    if (fileSizeKb != null) result.fileSizeKb = fileSizeKb;
    if (fileName != null) result.fileName = fileName;
    if (fsId != null) result.fsId = fsId;
    if (caption != null) result.caption = caption;
    if (thumbUrl != null) result.thumbUrl = thumbUrl;
    if (name != null) result.name = name;
    return result;
  }

  CreateQuickReplyRequest._();

  factory CreateQuickReplyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateQuickReplyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateQuickReplyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'content')
    ..aOS(2, _omitFieldNames ? '' : 'category')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'orderIndex', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'isEnabled')
    ..aOS(5, _omitFieldNames ? '' : 'mediaType')
    ..aOS(6, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(7, _omitFieldNames ? '' : 'mimeType')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..a<$core.double>(
        11, _omitFieldNames ? '' : 'fileSizeKb', $pb.PbFieldType.OD)
    ..aOS(12, _omitFieldNames ? '' : 'fileName')
    ..aOS(13, _omitFieldNames ? '' : 'fsId')
    ..aOS(14, _omitFieldNames ? '' : 'caption')
    ..aOS(15, _omitFieldNames ? '' : 'thumbUrl')
    ..aOS(16, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateQuickReplyRequest clone() =>
      CreateQuickReplyRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateQuickReplyRequest copyWith(
          void Function(CreateQuickReplyRequest) updates) =>
      super.copyWith((message) => updates(message as CreateQuickReplyRequest))
          as CreateQuickReplyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateQuickReplyRequest create() => CreateQuickReplyRequest._();
  @$core.override
  CreateQuickReplyRequest createEmptyInstance() => create();
  static $pb.PbList<CreateQuickReplyRequest> createRepeated() =>
      $pb.PbList<CreateQuickReplyRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateQuickReplyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateQuickReplyRequest>(create);
  static CreateQuickReplyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get category => $_getSZ(1);
  @$pb.TagNumber(2)
  set category($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCategory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCategory() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get orderIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set orderIndex($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrderIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderIndex() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isEnabled => $_getBF(3);
  @$pb.TagNumber(4)
  set isEnabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsEnabled() => $_clearField(4);

  /// 媒体扩展（可选）
  @$pb.TagNumber(5)
  $core.String get mediaType => $_getSZ(4);
  @$pb.TagNumber(5)
  set mediaType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMediaType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMediaType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mediaUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set mediaUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMediaUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearMediaUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get mimeType => $_getSZ(6);
  @$pb.TagNumber(7)
  set mimeType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMimeType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMimeType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get width => $_getIZ(7);
  @$pb.TagNumber(8)
  set width($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWidth() => $_has(7);
  @$pb.TagNumber(8)
  void clearWidth() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get height => $_getIZ(8);
  @$pb.TagNumber(9)
  set height($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearHeight() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get duration => $_getIZ(9);
  @$pb.TagNumber(10)
  set duration($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDuration() => $_has(9);
  @$pb.TagNumber(10)
  void clearDuration() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get fileSizeKb => $_getN(10);
  @$pb.TagNumber(11)
  set fileSizeKb($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFileSizeKb() => $_has(10);
  @$pb.TagNumber(11)
  void clearFileSizeKb() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get fileName => $_getSZ(11);
  @$pb.TagNumber(12)
  set fileName($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFileName() => $_has(11);
  @$pb.TagNumber(12)
  void clearFileName() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get fsId => $_getSZ(12);
  @$pb.TagNumber(13)
  set fsId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFsId() => $_has(12);
  @$pb.TagNumber(13)
  void clearFsId() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get caption => $_getSZ(13);
  @$pb.TagNumber(14)
  set caption($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCaption() => $_has(13);
  @$pb.TagNumber(14)
  void clearCaption() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get thumbUrl => $_getSZ(14);
  @$pb.TagNumber(15)
  set thumbUrl($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasThumbUrl() => $_has(14);
  @$pb.TagNumber(15)
  void clearThumbUrl() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get name => $_getSZ(15);
  @$pb.TagNumber(16)
  set name($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasName() => $_has(15);
  @$pb.TagNumber(16)
  void clearName() => $_clearField(16);
}

/// 更新快捷回复请求
class UpdateQuickReplyRequest extends $pb.GeneratedMessage {
  factory UpdateQuickReplyRequest({
    $fixnum.Int64? id,
    $core.String? content,
    $core.String? category,
    $core.int? orderIndex,
    $core.bool? isEnabled,
    $core.String? mediaType,
    $core.String? mediaUrl,
    $core.String? mimeType,
    $core.int? width,
    $core.int? height,
    $core.int? duration,
    $core.double? fileSizeKb,
    $core.String? fileName,
    $core.String? fsId,
    $core.String? caption,
    $core.String? thumbUrl,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (content != null) result.content = content;
    if (category != null) result.category = category;
    if (orderIndex != null) result.orderIndex = orderIndex;
    if (isEnabled != null) result.isEnabled = isEnabled;
    if (mediaType != null) result.mediaType = mediaType;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (mimeType != null) result.mimeType = mimeType;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (duration != null) result.duration = duration;
    if (fileSizeKb != null) result.fileSizeKb = fileSizeKb;
    if (fileName != null) result.fileName = fileName;
    if (fsId != null) result.fsId = fsId;
    if (caption != null) result.caption = caption;
    if (thumbUrl != null) result.thumbUrl = thumbUrl;
    if (name != null) result.name = name;
    return result;
  }

  UpdateQuickReplyRequest._();

  factory UpdateQuickReplyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateQuickReplyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateQuickReplyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..aOS(3, _omitFieldNames ? '' : 'category')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'orderIndex', $pb.PbFieldType.O3)
    ..aOB(5, _omitFieldNames ? '' : 'isEnabled')
    ..aOS(6, _omitFieldNames ? '' : 'mediaType')
    ..aOS(7, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(8, _omitFieldNames ? '' : 'mimeType')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..a<$core.double>(
        12, _omitFieldNames ? '' : 'fileSizeKb', $pb.PbFieldType.OD)
    ..aOS(13, _omitFieldNames ? '' : 'fileName')
    ..aOS(14, _omitFieldNames ? '' : 'fsId')
    ..aOS(15, _omitFieldNames ? '' : 'caption')
    ..aOS(16, _omitFieldNames ? '' : 'thumbUrl')
    ..aOS(17, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateQuickReplyRequest clone() =>
      UpdateQuickReplyRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateQuickReplyRequest copyWith(
          void Function(UpdateQuickReplyRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateQuickReplyRequest))
          as UpdateQuickReplyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateQuickReplyRequest create() => UpdateQuickReplyRequest._();
  @$core.override
  UpdateQuickReplyRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateQuickReplyRequest> createRepeated() =>
      $pb.PbList<UpdateQuickReplyRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateQuickReplyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateQuickReplyRequest>(create);
  static UpdateQuickReplyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get category => $_getSZ(2);
  @$pb.TagNumber(3)
  set category($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get orderIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set orderIndex($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrderIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrderIndex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set isEnabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsEnabled() => $_clearField(5);

  /// 媒体扩展（可选）
  @$pb.TagNumber(6)
  $core.String get mediaType => $_getSZ(5);
  @$pb.TagNumber(6)
  set mediaType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMediaType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMediaType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get mediaUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set mediaUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMediaUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearMediaUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get mimeType => $_getSZ(7);
  @$pb.TagNumber(8)
  set mimeType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMimeType() => $_has(7);
  @$pb.TagNumber(8)
  void clearMimeType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get width => $_getIZ(8);
  @$pb.TagNumber(9)
  set width($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWidth() => $_has(8);
  @$pb.TagNumber(9)
  void clearWidth() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get height => $_getIZ(9);
  @$pb.TagNumber(10)
  set height($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHeight() => $_has(9);
  @$pb.TagNumber(10)
  void clearHeight() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get duration => $_getIZ(10);
  @$pb.TagNumber(11)
  set duration($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDuration() => $_has(10);
  @$pb.TagNumber(11)
  void clearDuration() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get fileSizeKb => $_getN(11);
  @$pb.TagNumber(12)
  set fileSizeKb($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFileSizeKb() => $_has(11);
  @$pb.TagNumber(12)
  void clearFileSizeKb() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get fileName => $_getSZ(12);
  @$pb.TagNumber(13)
  set fileName($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFileName() => $_has(12);
  @$pb.TagNumber(13)
  void clearFileName() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get fsId => $_getSZ(13);
  @$pb.TagNumber(14)
  set fsId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasFsId() => $_has(13);
  @$pb.TagNumber(14)
  void clearFsId() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get caption => $_getSZ(14);
  @$pb.TagNumber(15)
  set caption($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCaption() => $_has(14);
  @$pb.TagNumber(15)
  void clearCaption() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get thumbUrl => $_getSZ(15);
  @$pb.TagNumber(16)
  set thumbUrl($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasThumbUrl() => $_has(15);
  @$pb.TagNumber(16)
  void clearThumbUrl() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get name => $_getSZ(16);
  @$pb.TagNumber(17)
  set name($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasName() => $_has(16);
  @$pb.TagNumber(17)
  void clearName() => $_clearField(17);
}

/// 删除快捷回复请求
class DeleteQuickReplyRequest extends $pb.GeneratedMessage {
  factory DeleteQuickReplyRequest({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteQuickReplyRequest._();

  factory DeleteQuickReplyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteQuickReplyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteQuickReplyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteQuickReplyRequest clone() =>
      DeleteQuickReplyRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteQuickReplyRequest copyWith(
          void Function(DeleteQuickReplyRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteQuickReplyRequest))
          as DeleteQuickReplyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteQuickReplyRequest create() => DeleteQuickReplyRequest._();
  @$core.override
  DeleteQuickReplyRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteQuickReplyRequest> createRepeated() =>
      $pb.PbList<DeleteQuickReplyRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteQuickReplyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteQuickReplyRequest>(create);
  static DeleteQuickReplyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// 单个快捷回复响应
class QuickReplyResponse extends $pb.GeneratedMessage {
  factory QuickReplyResponse({
    QuickReply? quickReply,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (quickReply != null) result.quickReply = quickReply;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  QuickReplyResponse._();

  factory QuickReplyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuickReplyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuickReplyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aOM<QuickReply>(1, _omitFieldNames ? '' : 'quickReply',
        subBuilder: QuickReply.create)
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuickReplyResponse clone() => QuickReplyResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuickReplyResponse copyWith(void Function(QuickReplyResponse) updates) =>
      super.copyWith((message) => updates(message as QuickReplyResponse))
          as QuickReplyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuickReplyResponse create() => QuickReplyResponse._();
  @$core.override
  QuickReplyResponse createEmptyInstance() => create();
  static $pb.PbList<QuickReplyResponse> createRepeated() =>
      $pb.PbList<QuickReplyResponse>();
  @$core.pragma('dart2js:noInline')
  static QuickReplyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuickReplyResponse>(create);
  static QuickReplyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  QuickReply get quickReply => $_getN(0);
  @$pb.TagNumber(1)
  set quickReply(QuickReply value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasQuickReply() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuickReply() => $_clearField(1);
  @$pb.TagNumber(1)
  QuickReply ensureQuickReply() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
}

/// 删除响应
class DeleteQuickReplyResponse extends $pb.GeneratedMessage {
  factory DeleteQuickReplyResponse({
    $fixnum.Int64? id,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  DeleteQuickReplyResponse._();

  factory DeleteQuickReplyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteQuickReplyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteQuickReplyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteQuickReplyResponse clone() =>
      DeleteQuickReplyResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteQuickReplyResponse copyWith(
          void Function(DeleteQuickReplyResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteQuickReplyResponse))
          as DeleteQuickReplyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteQuickReplyResponse create() => DeleteQuickReplyResponse._();
  @$core.override
  DeleteQuickReplyResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteQuickReplyResponse> createRepeated() =>
      $pb.PbList<DeleteQuickReplyResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteQuickReplyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteQuickReplyResponse>(create);
  static DeleteQuickReplyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
}

/// 错误响应
class QuickReplyErrorResponse extends $pb.GeneratedMessage {
  factory QuickReplyErrorResponse({
    $core.String? message,
    $core.String? errorCode,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (message != null) result.message = message;
    if (errorCode != null) result.errorCode = errorCode;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  QuickReplyErrorResponse._();

  factory QuickReplyErrorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuickReplyErrorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuickReplyErrorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'quick_reply'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..aOS(2, _omitFieldNames ? '' : 'errorCode')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuickReplyErrorResponse clone() =>
      QuickReplyErrorResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuickReplyErrorResponse copyWith(
          void Function(QuickReplyErrorResponse) updates) =>
      super.copyWith((message) => updates(message as QuickReplyErrorResponse))
          as QuickReplyErrorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuickReplyErrorResponse create() => QuickReplyErrorResponse._();
  @$core.override
  QuickReplyErrorResponse createEmptyInstance() => create();
  static $pb.PbList<QuickReplyErrorResponse> createRepeated() =>
      $pb.PbList<QuickReplyErrorResponse>();
  @$core.pragma('dart2js:noInline')
  static QuickReplyErrorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuickReplyErrorResponse>(create);
  static QuickReplyErrorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorCode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
