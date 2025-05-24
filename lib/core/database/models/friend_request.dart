import 'package:isar/isar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/proto/generated/contacts.pb.dart' as proto;

part 'friend_request.g.dart';

/// 好友请求模型
@collection
class FriendRequest {
  /// 主键ID
  Id id = Isar.autoIncrement;

  /// 请求ID (来自服务器)
  late String requestId;

  /// 发送者ID
  late String senderId;

  /// 发送者名称
  late String senderName;

  /// 发送者头像
  String? senderAvatar;

  /// 接收者ID
  late String receiverId;

  /// 请求消息
  String? message;

  /// 请求状态: pending, accepted, rejected
  @Enumerated(EnumType.name)
  late FriendRequestStatus status;

  /// 请求创建时间
  late DateTime createdAt;

  /// 请求处理时间
  DateTime? processedAt;

  /// 从Protocol Buffer对象创建数据库对象
  ///
  /// 直接从FriendRequestProto对象创建FriendRequest实例
  /// 简化了在仓库中的数据转换逻辑
  ///
  /// [proto] - 原始的Protocol Buffer对象
  /// [senderName] - 发送者名称，由于proto对象中不包含这个字段，需要额外提供
  /// [senderAvatar] - 发送者头像，由于proto对象中不包含这个字段，需要额外提供
  /// 返回：转换后的数据库对象
  static FriendRequest fromProto(
    proto.FriendRequestProto proto, {
    required String senderName,
    String? senderAvatar,
  }) {
    return FriendRequest()
      ..requestId = proto.requestId
      ..senderId = proto.senderId
      ..senderName = senderName
      ..senderAvatar = senderAvatar
      ..receiverId = proto.receiverId
      ..message = proto.hasMessage() ? proto.message : null
      ..status = _protoStatusToDbStatus(proto.status)
      ..createdAt = proto.hasSentAt()
          ? DateTime.fromMillisecondsSinceEpoch(proto.sentAt.toInt())
          : DateTime.now()
      ..processedAt = proto.hasProcessedAt()
          ? DateTime.fromMillisecondsSinceEpoch(proto.processedAt.toInt())
          : null;
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将FriendRequest对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// 返回：转换后的Protocol Buffer对象
  proto.FriendRequestProto toProto() {
    return proto.FriendRequestProto(
      requestId: requestId,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      status: _dbStatusToProtoStatus(status),
      sentAt: Int64(createdAt.millisecondsSinceEpoch),
      processedAt: processedAt != null
          ? Int64(processedAt!.millisecondsSinceEpoch)
          : null,
    );
  }

  /// 将Proto状态转换为数据库状态
  static FriendRequestStatus _protoStatusToDbStatus(
      proto.FriendRequestStatus status) {
    switch (status) {
      case proto.FriendRequestStatus.PENDING:
        return FriendRequestStatus.pending;
      case proto.FriendRequestStatus.ACCEPTED:
        return FriendRequestStatus.accepted;
      case proto.FriendRequestStatus.REJECTED:
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }

  /// 将数据库状态转换为Proto状态
  static proto.FriendRequestStatus _dbStatusToProtoStatus(
      FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return proto.FriendRequestStatus.PENDING;
      case FriendRequestStatus.accepted:
        return proto.FriendRequestStatus.ACCEPTED;
      case FriendRequestStatus.rejected:
        return proto.FriendRequestStatus.REJECTED;
    }
  }
}

/// 好友请求状态
enum FriendRequestStatus {
  pending, // 待处理
  accepted, // 已接受
  rejected, // 已拒绝
}
