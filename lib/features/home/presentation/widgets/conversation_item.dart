import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';

/// 会话列表项组件
///
/// 用于显示单个会话项，包括头像、名称、最后消息等信息
/// 支持不同类型的会话（私聊、群聊、频道）
class ConversationItem extends StatelessWidget {
  /// 会话信息
  final Conversation conversation;

  /// 联系人信息
  final User contact;

  /// 格式化时间的回调函数
  final String Function(DateTime?) formatTimeCallback;

  /// 格式化未读数量的回调函数
  final String Function(int) formatUnreadCountCallback;

  /// 头像大小
  static const double avatarSize = 60.0;

  /// 构造函数
  const ConversationItem({
    super.key,
    required this.conversation,
    required this.contact,
    required this.formatTimeCallback,
    required this.formatUnreadCountCallback,
  });

  @override
  Widget build(BuildContext context) {
    // 判断是否有静音图标
    final bool isMuted = conversation.isMuted;

    // 判断会话类型
    final bool isGroup = conversation.type == ConversationType.group;
    final bool isChannel = conversation.type == ConversationType.channel;

    // 获取最后一条消息的发送者名称（群聊和频道）
    String? senderName;
    if (isGroup) {
      // 优先使用lastMessageName，这是服务器直接提供的发送者名称
      senderName = conversation.lastMessageName ?? '未知用户';
    }

    // 频道消息发送者处理
    String? channelSenderInfo;
    if (isChannel) {
      // 优先使用lastMessageName，这是服务器直接提供的发送者名称
      channelSenderInfo = conversation.lastMessageName ?? '频道管理员';
    }

    // 使用 RepaintBoundary 隔离重绘区域，提高性能
    return RepaintBoundary(
      child: _buildConversationItem(
          context, isMuted, isGroup, isChannel, senderName, channelSenderInfo),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    bool isMuted,
    bool isGroup,
    bool isChannel,
    String? senderName,
    String? channelSenderInfo,
  ) {
    return Column(
      children: [
        Material(
          color: Colors.transparent, // 使用透明背景
          child: InkWell(
            onTap: () => _openChatDetail(context),
            splashColor: Colors.grey.withAlpha(26), // 添加水波纹效果
            highlightColor: Colors.grey.withAlpha(13), // 按下时的高亮效果
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              width: double.infinity, // 确保宽度占满整行
              // 为置顶会话添加浅色背景
              color: conversation.isPinned
                  ? Colors.blue.withAlpha(15)
                  : Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // 确保垂直居中
                children: [
                  // 头像
                  _buildAvatar(),

                  // 中间内容区域
                  Expanded(
                    child: SizedBox(
                      height: avatarSize + 1, // 与头像高度一致
                      child: _buildContentByType(isMuted, isGroup, isChannel,
                          senderName, channelSenderInfo),
                    ),
                  ),

                  // 右侧时间和未读数
                  _buildTimeAndUnreadCount(),
                ],
              ),
            ),
          ),
        ),
        // 分割线 - 从头像右侧开始延伸
        const Padding(
          padding: EdgeInsets.only(left: 92.0),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: Color.fromRGBO(128, 128, 128, 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: UserAvatar(
          avatarUrl: contact.avatar,
          name: contact.name,
          radius: avatarSize / 2,
          backgroundColor: Colors.cyan,
        ),
      ),
    );
  }

  Widget _buildContentByType(
    bool isMuted,
    bool isGroup,
    bool isChannel,
    String? senderName,
    String? channelSenderInfo,
  ) {
    switch (conversation.type) {
      case ConversationType.private:
        return _buildPrivateContent(isMuted);
      case ConversationType.group:
        return _buildGroupContent(isMuted, senderName);
      case ConversationType.channel:
        return _buildChannelContent(isMuted, channelSenderInfo);
    }
  }

  Widget _buildPrivateContent(bool isMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 第一行：会话名称和静音图标
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  // 置顶图标
                  if (conversation.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isMuted)
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child:
                          Icon(Icons.volume_off, size: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),

        // 第二、三行：消息内容预览（始终保持两行高度）
        Container(
          height: 36, // 固定高度，相当于两行文本的高度
          alignment: Alignment.topLeft,
          child: Text(
            conversation.lastMessagePreview ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGroupContent(bool isMuted, String? senderName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 第一行：群组名称和静音图标
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  // 置顶图标
                  if (conversation.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  // 群组图标
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.group,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      conversation.name ?? '群聊',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isMuted)
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child:
                          Icon(Icons.volume_off, size: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),

        // 第二、三行：发送者名称和消息内容预览
        Container(
          height: 36, // 固定高度，相当于两行文本的高度
          alignment: Alignment.topLeft,
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                if (senderName != null && senderName.isNotEmpty)
                  TextSpan(
                    text: '$senderName: ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                TextSpan(
                  text: conversation.lastMessagePreview ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildChannelContent(bool isMuted, String? channelSenderInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 第一行：频道名称和静音图标
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  // 置顶图标
                  if (conversation.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  // 频道图标
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.campaign,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      conversation.name ?? '频道',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isMuted)
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child:
                          Icon(Icons.volume_off, size: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),

        // 第二、三行：频道信息和消息内容预览
        Container(
          height: 36, // 固定高度，相当于两行文本的高度
          alignment: Alignment.topLeft,
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                if (channelSenderInfo != null && channelSenderInfo.isNotEmpty)
                  TextSpan(
                    text: '$channelSenderInfo ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                TextSpan(
                  text: conversation.lastMessagePreview ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAndUnreadCount() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 8.0),
      child: SizedBox(
        height: avatarSize, // 与头像高度一致
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 时间
            Text(
              formatTimeCallback(conversation.lastMessageTime),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            // 未读数
            if (conversation.unreadCount > 0)
              _buildUnreadBadge()
            else
              const SizedBox(height: 20), // 占位符
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    final bool isNewMessage = conversation.lastReadAt == null ||
        (conversation.lastMessageTime != null &&
            conversation.lastReadAt!.isBefore(conversation.lastMessageTime!));

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isNewMessage ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Text(
        formatUnreadCountCallback(conversation.unreadCount),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _openChatDetail(BuildContext context) {
    // 使用HomeCubit加载会话消息
    final homeCubit = context.read<HomeCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: homeCubit,
          child: ChatDetailPage(
            conversationId: conversation.conversationId,
            contact: contact,
          ),
        ),
      ),
    );
  }
}
