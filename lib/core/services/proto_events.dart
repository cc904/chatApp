import 'package:protobuf/protobuf.dart';
import '../proto/generated/user.pb.dart' as user;
import '../proto/generated/message.pb.dart' as message;
import '../proto/generated/contacts.pb.dart' as contacts;
import '../proto/generated/conversation.pb.dart' as conversation;

/// 事件到Protobuf消息类型的映射
/// 定义了服务器和客户端之间通信的事件和对应的Protobuf消息类型
class ProtoEvents {
  /// 消息事件映射表
  /// 格式：'事件名称': () => 消息类型()
  static final Map<String, GeneratedMessage Function()> _eventTypeMap = {
    // ================================
    // 用户相关事件 (User Events)
    // ================================

    /// 设置当前用户信息请求 → SetCurrentUserRequest
    'user:set': () => user.SetCurrentUserRequest(),

    /// 设置当前用户信息响应 → SetCurrentUserResponse
    'user:set:response': () => user.SetCurrentUserResponse(),

    /// 用户信息更新事件 → CurrentUserUpdateEvent
    'user:updated': () => user.CurrentUserUpdateEvent(),

    /// 用户上线状态通知 → UserStatusUpdate
    'user:online': () => user.UserStatusUpdate(),

    /// 用户下线状态通知 → UserStatusUpdate
    'user:offline': () => user.UserStatusUpdate(),

    /// 用户正在输入通知 → UserTypingUpdate
    'user:typing': () => user.UserTypingUpdate(),

    /// 用户停止输入通知 → UserTypingUpdate
    'user:typing:stop': () => user.UserTypingUpdate(),

    /// 用户资料更新通知 → UserProto
    'user:profile:updated': () => user.UserProto(),

    /// 首次设置密码请求 → SetPasswordRequest
    'user:set_password': () => user.SetPasswordRequest(),

    /// 首次设置密码响应 → SetPasswordResponse
    'user:set_password:response': () => user.SetPasswordResponse(),

    /// 修改密码请求 → ChangePasswordRequest
    'user:change_password': () => user.ChangePasswordRequest(),

    /// 修改密码响应 → ChangePasswordResponse
    'user:change_password:response': () => user.ChangePasswordResponse(),

    /// 用户信息同步请求 → SetCurrentUserRequest
    'user:sync': () => user.SetCurrentUserRequest(),

    /// 获取当前用户信息请求 → GetCurrentUserRequest
    'user:getCurrentUser': () => user.GetCurrentUserRequest(),

    /// 获取当前用户信息响应 → SetCurrentUserResponse
    'user:getCurrentUser:response': () => user.SetCurrentUserResponse(),

    // ================================
    // 搜索相关事件 (Search Events)
    // ================================

    /// 全局搜索请求 → UniversalSearchRequest
    'search:universal': () => user.UniversalSearchRequest(),

    /// 全局搜索响应 → UniversalSearchResponse
    'search:universal:response': () => user.UniversalSearchResponse(),

    // ================================
    // 消息相关事件 (Message Events)
    // ================================

    /// 新消息通知 → MessageProto
    'message:new': () => message.MessageProto(),

    /// 消息送达通知 → MessageProto
    'message:delivered': () => message.MessageProto(),

    /// 消息已读通知 → MessageProto
    'message:read': () => message.MessageProto(),

    /// 发送消息请求 → MessageProto
    'message:send': () => message.MessageProto(),

    /// 发送消息响应 → MessageSendResponse
    'message:send:response': () => message.MessageSendResponse(),

    /// 消息状态更新广播 → MessageProto
    'message:updated': () => message.MessageProto(),

    /// 批量获取消息请求 → MessagesFetchRequest
    'messages:fetch': () => message.MessagesFetchRequest(),

    /// 批量获取消息响应 → MessagesFetchResponse
    'messages:fetch:response': () => message.MessagesFetchResponse(),

    // ================================
    // 消息操作事件 (Message Actions)
    // ================================

    /// 编辑消息请求 → MessageEditRequest
    'message:edit': () => message.MessageEditRequest(),

    /// 编辑消息响应 → MessageEditResponse
    'message:edit:response': () => message.MessageEditResponse(),

    /// 撤回消息请求 → MessageRevokeRequest
    'message:revoke': () => message.MessageRevokeRequest(),

    /// 撤回消息响应 → MessageRevokeResponse
    'message:revoke:response': () => message.MessageRevokeResponse(),

    /// 删除消息请求 → MessageDeleteRequest
    'message:delete': () => message.MessageDeleteRequest(),

    /// 删除消息响应 → MessageDeleteResponse
    'message:delete:response': () => message.MessageDeleteResponse(),

    // ================================
    // 会话相关事件 (Conversation Events)
    // ================================

    /// 会话更新响应 → ConversationResponse
    'conversation:update:response': () => conversation.ConversationResponse(),

    /// 会话创建通知 → ConversationProto
    'conversation:created': () => conversation.ConversationProto(),

    /// 会话添加通知 → ConversationCreateResponse
    'conversation:added': () => conversation.ConversationCreateResponse(),

    /// 会话删除通知 → ConversationProto
    'conversation:deleted': () => conversation.ConversationProto(),

    /// 同步会话请求 → SyncConversationsRequest
    'conversation:sync': () => conversation.SyncConversationsRequest(),

    /// 同步会话响应 → ConversationCollection
    'conversation:sync:response': () => conversation.ConversationCollection(),

    /// 会话预览更新通知 → ConversationPreviewUpdated
    'conversation:preview:updated': () =>
        conversation.ConversationPreviewUpdated(),

    // ================================
    // 会话设置事件 (Conversation Settings)
    // ================================

    /// 会话设置更新请求 → ConversationSettingsUpdateRequest
    'conversation:settings:update': () =>
        conversation.ConversationSettingsUpdateRequest(),

    /// 会话设置更新响应 → ConversationSettingsUpdateResponse
    'conversation:settings:updated': () =>
        conversation.ConversationSettingsUpdateResponse(),

    // ================================
    // 会话信息管理 (Conversation Info)
    // ================================

    /// 会话信息更新请求 → ConversationInfoUpdateRequest
    'conversation:info:update': () =>
        conversation.ConversationInfoUpdateRequest(),

    /// 会话信息更新响应 → ConversationInfoUpdateResponse
    'conversation:info:update:response': () =>
        conversation.ConversationInfoUpdateResponse(),

    /// 会话信息更新通知 → ConversationInfoUpdated
    'conversation:info:updated': () => conversation.ConversationInfoUpdated(),

    // ================================
    // 会话房间管理 (Room Management)
    // ================================

    /// 加入会话房间请求 → ConversationJoinLeaveRequest
    'conversation:join': () => conversation.ConversationJoinLeaveRequest(),

    /// 离开会话房间请求 → ConversationJoinLeaveRequest
    'conversation:leave': () => conversation.ConversationJoinLeaveRequest(),

    /// 离开会话房间响应 → ConversationJoinLeaveResponse
    'conversation:leave:response': () =>
        conversation.ConversationJoinLeaveResponse(),

    // ================================
    // 会话创建管理 (Conversation Creation)
    // ================================

    /// 创建会话请求 → ConversationCreateRequest
    'conversation:create': () => conversation.ConversationCreateRequest(),

    /// 创建会话响应 → ConversationCreateResponse
    'conversation:create:response': () =>
        conversation.ConversationCreateResponse(),

    /// 获取会话详情响应 → ConversationDetailResponse
    'conversation:detail:response': () =>
        conversation.ConversationDetailResponse(),

    // ================================
    // 参与者状态管理 (Participant Status)
    // ================================

    /// 参与者状态更新请求 → ParticipantStatusUpdateRequest
    'participant:status:update': () =>
        conversation.ParticipantStatusUpdateRequest(),

    /// 参与者状态更新响应 → ParticipantStatusUpdateResponse
    'participant:status:update:response': () =>
        conversation.ParticipantStatusUpdateResponse(),

    // ================================
    // 会话成员管理 (Member Management)
    // ================================

    /// 添加会话成员请求 → ConversationMemberChangeRequest
    'conversation:member:add': () =>
        conversation.ConversationMemberChangeRequest(),

    /// 会话成员管理请求（添加/移除/角色变更/屏蔽） → ConversationMemberChangeRequest
    'conversation:member:change': () =>
        conversation.ConversationMemberChangeRequest(),

    /// 获取会话成员列表响应 → ConversationMembersResponse
    'conversation:members': () => conversation.ConversationMembersResponse(),

    /// 会话成员变更通知（服务器广播） → ConversationMemberChangeResponse
    'conversation:member:changed': () =>
        conversation.ConversationMemberChangeResponse(),

    /// 用户加入会话通知 → UserJoinedNotification
    'conversation:user:joined': () => conversation.UserJoinedNotification(),

    /// 用户离开会话通知 → UserLeftNotification
    'conversation:user:left': () => conversation.UserLeftNotification(),

    // ================================
    // 退出会话管理 (Exit Management)
    // ================================

    /// 退出会话请求 → ConversationExitRequest
    'conversation:exit': () => conversation.ConversationExitRequest(),

    /// 退出会话响应 → ConversationExitResponse
    'conversation:exit:response': () => conversation.ConversationExitResponse(),

    /// 成员退出通知 → MemberExitedNotification
    'conversation:member:exited': () => conversation.MemberExitedNotification(),

    /// 会话移除通知 → ConversationRemovedNotification
    'conversation:removed': () =>
        conversation.ConversationRemovedNotification(),

    // ================================
    // 联系人相关事件 (Contact Events)
    // ================================

    /// 联系人同步通知 → UserCollection
    'contact:synced': () => user.UserCollection(),

    /// 联系人同步请求 → SyncContactsRequest
    'contact:sync': () => contacts.SyncContactsRequest(),

    /// 联系人同步响应 → SyncContactsResponse
    'contact:sync:response': () => contacts.SyncContactsResponse(),

    /// 更新联系人信息请求 → UpdateContactRequest
    'contact:update': () => contacts.UpdateContactRequest(),

    /// 更新联系人信息响应 → UpdateContactResponse
    'contact:update:response': () => contacts.UpdateContactResponse(),

    /// 联系人信息更新事件 → ContactUpdateEvent
    'contact:updated': () => contacts.ContactUpdateEvent(),

    // ================================
    // 好友请求相关事件 (Friend Request Events)
    // ================================

    /// 发送好友请求 → SendFriendRequestProto
    'friend:request:send': () => contacts.SendFriendRequestProto(),

    /// 发送好友请求响应 → FriendRequestProto
    'friend:request:send:response': () => contacts.FriendRequestProto(),

    /// 处理好友请求（接受/拒绝） → ProcessFriendRequestProto
    'friend:request:process': () => contacts.ProcessFriendRequestProto(),

    /// 处理好友请求响应 → FriendRequestProto
    'friend:request:process:response': () => contacts.FriendRequestProto(),

    /// 获取好友请求列表请求 → GetFriendRequestsRequest
    'friend:requests:get': () => contacts.GetFriendRequestsRequest(),

    /// 获取好友请求列表响应 → GetFriendRequestsResponse
    'friend:requests:get:response': () => contacts.GetFriendRequestsResponse(),

    /// 收到好友请求通知 → FriendRequestProto
    'friend:request:received': () => contacts.FriendRequestProto(),

    /// 好友请求处理结果通知 → FriendRequestProto
    'friend:request:processed': () => contacts.FriendRequestProto(),

    // ================================
    // 系统相关事件 (System Events)
    // ================================

    /// 系统消息通知 → SystemMessage
    'system:message': () => message.SystemMessage(),
  };

  /// 获取事件的Protobuf消息创建函数
  /// [eventName] - 事件名称
  /// 返回创建对应Protobuf消息的函数，如果事件不存在则返回null
  static GeneratedMessage Function()? getEventCreator(String eventName) {
    return _eventTypeMap[eventName];
  }

  /// 检查事件是否已注册
  /// [eventName] - 事件名称
  static bool isEventRegistered(String eventName) {
    return _eventTypeMap.containsKey(eventName);
  }

  /// 注册自定义事件和对应的Protobuf消息类型
  /// [eventName] - 事件名称
  /// [creator] - 创建对应Protobuf消息的函数
  static void registerEvent(
      String eventName, GeneratedMessage Function() creator) {
    _eventTypeMap[eventName] = creator;
  }

  /// 获取所有已注册的事件名称
  static Set<String> get allEvents => _eventTypeMap.keys.toSet();
}
