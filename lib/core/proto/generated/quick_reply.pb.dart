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
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (content != null) result.content = content;
    if (category != null) result.category = category;
    if (orderIndex != null) result.orderIndex = orderIndex;
    if (isEnabled != null) result.isEnabled = isEnabled;
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
