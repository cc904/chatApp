import 'package:isar/isar.dart';

part 'friend_request.g.dart';

/// 好友请求模型
@Collection(accessor: 'friendRequests')
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
  @enumerated
  late FriendRequestStatus status;

  /// 请求创建时间
  late DateTime createdAt;

  /// 请求处理时间
  DateTime? processedAt;
}

/// 好友请求状态
enum FriendRequestStatus {
  pending, // 待处理
  accepted, // 已接受
  rejected, // 已拒绝
}
