import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/chat/presentation/pages/chat_page.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/utils/timezone_utils.dart';

import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/services/log_service.dart';

/// 会话列表项组件
///
/// 用于显示单个会话项，包括头像、名称、最后消息等信息
/// 支持不同类型的会话（私聊、群聊、频道）
class ConversationItem extends StatelessWidget {
  /// 会话信息
  final Conversation conversation;

  /// 当前用户信息
  final CurrentUser currentUser;

  /// 格式化时间的回调函数
  final String Function(DateTime?)? formatTimeCallback;

  /// 格式化未读数量的回调函数
  final String Function(int) formatUnreadCountCallback;

  /// 头像大小
  static const double avatarSize = 60.0;

  /// 构造函数 - 使用 const 构造函数提高性能
  const ConversationItem({
    super.key,
    required this.conversation,
    required this.currentUser,
    this.formatTimeCallback,
    required this.formatUnreadCountCallback,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 RepaintBoundary 隔离重绘区域，提高性能
    return RepaintBoundary(
      child: _buildConversationItem(context),
    );
  }

  /// 构建会话项主体
  Widget _buildConversationItem(BuildContext context) {
    // 判断是否有静音图标

    // 判断会话类型
    final bool isGroup = conversation.type == 'GROUP';
    final bool isChannel = conversation.type == 'CHANNEL';

    // 获取最后一条消息的发送者名称（群聊和频道）
    if (isGroup) {
      // 优先使用lastMessageName，这是服务器直接提供的发送者名称
    }

    // 频道消息发送者处理
    if (isChannel) {
      // 优先使用lastMessageName，这是服务器直接提供的发送者名称
    }
    return Column(
      children: [
        Material(
          color: Colors.transparent, // 使用透明背景
          child: InkWell(
            onTap: () => _openChatDetail(context, conversation, currentUser),
            splashColor: Colors.grey.withAlpha(26), // 添加水波纹效果
            highlightColor: Colors.grey.withAlpha(13), // 按下时的高亮效果
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              width: double.infinity, // 确保宽度占满整行
              // 为置顶会话添加浅色背景
              color: conversation.pinned ? AppColors.primary.withAlpha(15) : Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // 确保垂直居中
                children: [
                  // 头像
                  _buildAvatar(conversation),

                  // 中间内容区域
                  Expanded(
                    child: SizedBox(
                      height: avatarSize + 1, // 与头像高度一致
                      child: _buildContent(conversation),
                    ),
                  ),

                  // 右侧时间和未读数
                  _buildTimeAndUnreadCount(conversation),
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

  /// 构建头像部分
  Widget _buildAvatar(Conversation conversation) {
    final displayRoleId = ConversationAdapter.getDisplayRoleId(
      conversation.participants,
      conversation.type,
      currentUser.userId,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: 60,
        height: 60,
        child: UserAvatar(
          avatarUrl: conversation.avatar,
          userId: conversation.type == 'PRIVATE'
              ? (ConversationAdapter.getParticipantInfo(conversation.participants, currentUser.userId)?['userId'] == currentUser.userId
                  ? null
                  : ConversationAdapter.getParticipantInfo(conversation.participants, currentUser.userId)?['userId'])
              : conversation.conversationId,
          name: _getAvatarDisplayName(conversation),
          radius: 60 / 2,
          backgroundColor: AppColors.primary,
          roleId: displayRoleId,
        ),
      ),
    );
  }

  /// 构建会话内容
  /// 根据会话类型显示不同的内容格式
  Widget _buildContent(Conversation conversation) {
    // 判断会话类型
    final bool isGroup = conversation.type == 'GROUP';
    final bool isChannel = conversation.type == 'CHANNEL';

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
                  if (conversation.pinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),

                  // 根据会话类型显示不同图标
                  if (isGroup)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.group,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    )
                  else if (isChannel)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.campaign,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),

                  // 会话名称 - 直接使用会话名称
                  Flexible(
                    child: Text(
                      _getDisplayName(conversation, isGroup, isChannel),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 静音图标
                  if (conversation.muted)
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Icon(Icons.volume_off, size: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),

        // 第二、三行：消息内容预览
        Container(
          height: 36, // 固定高度，相当于两行文本的高度
          alignment: Alignment.topLeft,
          child: isGroup || isChannel
              ? _buildGroupMessagePreview(conversation, isChannel)
              : Text(
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

  /// 构建群聊或频道的消息预览
  Widget _buildGroupMessagePreview(Conversation conversation, bool isChannel) {
    // 检查是否为系统消息，如果是系统消息则不显示发送者名称
    final bool isSystemMessage = _isSystemMessage(conversation.lastMessagePreview);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (!isSystemMessage && conversation.lastMessageName != null && conversation.lastMessageName!.isNotEmpty)
            TextSpan(
              text: '${conversation.lastMessageName}: ',
              style: TextStyle(
                fontSize: 13,
                color: isChannel ? Colors.purple : AppColors.primary,
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
    );
  }

  /// 检查消息内容是否为系统消息
  bool _isSystemMessage(String? messagePreview) {
    if (messagePreview == null || messagePreview.isEmpty) return false;

    // 检查是否包含系统消息的关键词
    final systemKeywords = [
      'joined',
      'left',
      'created',
      'added',
      'removed',
      '加入了',
      '离开了',
      '创建了',
      '添加了',
      '移除了',
      '被添加',
      '被移除',
    ];

    final lowerPreview = messagePreview.toLowerCase();
    return systemKeywords.any((keyword) => lowerPreview.contains(keyword.toLowerCase()));
  }

  /// 获取会话显示名称，对群聊和频道名称进行长度限制（同步版本）
  String _getDisplayName(Conversation conversation, bool isGroup, bool isChannel) {
    // 私聊时使用对方的名称
    if (conversation.type == 'PRIVATE') {
      final partnerName = ConversationAdapter.getPrivateChatPartnerName(
        conversation.participants,
        conversation.type,
        currentUser.userId,
      );
      if (partnerName != null && partnerName.isNotEmpty) {
        return partnerName;
      }
    }

    String name = conversation.name ?? '未命名会话';

    if ((isGroup || isChannel) && name.length > 24) {
      return name.substring(0, 24);
    }

    return name;
  }

  /// 获取头像显示名称
  /// 私聊时使用对方的名称，群聊时使用会话名称
  String _getAvatarDisplayName(Conversation conversation) {
    // 私聊时使用对方的名称
    if (conversation.type == 'PRIVATE') {
      final partnerName = ConversationAdapter.getPrivateChatPartnerName(
        conversation.participants,
        conversation.type,
        currentUser.userId,
      );
      if (partnerName != null && partnerName.isNotEmpty) {
        return partnerName;
      }
    }

    // 群聊或频道时使用会话名称
    return conversation.name ?? '未命名';
  }

  /// 构建时间和未读数量
  Widget _buildTimeAndUnreadCount(Conversation conversation) {
    // 统一按索引计算未读：未读 = max(0, lastMessageIndex - readMessageIndex)
    final int unread = (conversation.lastMessageIndex - conversation.readMessageIndex).clamp(0, 1 << 30);

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 8.0),
      child: SizedBox(
        height: 60, // 与头像高度一致
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 时间 - 使用FutureBuilder显示时区转换后的时间
            FutureBuilder<String>(
              future: _formatTime(conversation.lastMessageTime),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? '...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            // 未读数
            if (unread > 0) _buildUnreadBadge(conversation, unread) else const SizedBox(height: 20), // 占位符
          ],
        ),
      ),
    );
  }

  /// 格式化时间 - 支持时区转换
  Future<String> _formatTime(DateTime? time) async {
    if (time == null) return '';

    // 🌍 使用时区工具进行智能格式化
    final localTime = await TimezoneUtils.toUserTimezone(time);
    final now = await TimezoneUtils.toUserTimezone(TimezoneUtils.nowUtc());
    final difference = now.difference(localTime);

    // 今天内的消息显示时间
    if (difference.inDays == 0) {
      return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    }
    // 一周内的消息显示星期
    else if (difference.inDays < 7) {
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[(localTime.weekday - 1) % 7];
    }
    // 更早的消息显示日期
    else {
      return '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}';
    }
  }

  /// 构建未读消息徽章
  Widget _buildUnreadBadge(Conversation conversation, int unread) {
    final bool isNewMessage = unread > 0;

    // Access unread count from conversation

    // 获取未读数量（用于Text显示）
    final formattedCount = _formatUnreadCount(unread);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isNewMessage ? AppColors.primary : AppColors.grey500,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Text(
        formattedCount,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 打开聊天详情页
  void _openChatDetail(BuildContext context, Conversation conversation, CurrentUser currentUser) async {
    final logger = LogService.instance;

    // 进入会话前，按索引即时计算当前未读
    final int unread = (conversation.lastMessageIndex - conversation.readMessageIndex).clamp(0, 1 << 30);

    // 💬💬💬 打印会话详细信息
    logger.i('🚀🚀🚀 用户点击打开会话', extra: {
      'conversationId': conversation.conversationId,
      'conversationName': conversation.name,
      'conversationType': conversation.type,
      'lastMessagePreview': conversation.lastMessagePreview,
      'lastMessageTime': conversation.lastMessageTime?.toIso8601String(),
      'lastMessageName': conversation.lastMessageName,
      'unreadCount': unread,
      'pinned': conversation.pinned,
      'muted': conversation.muted,
      'avatar': conversation.avatar,
      'participants': conversation.participants,
      'currentUserId': currentUser.userId,
      'currentUserName': currentUser.name,
    });

    // 在导航前获取Repository和Cubit引用
    final chatRepository = context.read<ChatRepository>();
    final chatsRepository = context.read<ChatsRepository>();
    final chatRepositorySend = context.read<ChatRepositorySend>();
    final chatsCubit = context.read<ChatsCubit>();
    final navigator = Navigator.of(context);

    try {
      // 先清理过期快照
      await chatsRepository.cleanupExpiredSnapshots();

      // 获取状态快照（如果存在）
      final snapshot = await chatsRepository.getStateSnapshot(conversation.conversationId);

      if (context.mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => MultiRepositoryProvider(
              providers: [
                RepositoryProvider<ChatRepository>.value(value: chatRepository),
                RepositoryProvider<ChatsRepository>.value(value: chatsRepository),
                RepositoryProvider<ChatRepositorySend>.value(value: chatRepositorySend),
              ],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ChatCubit>(
                    create: (context) => ChatCubit(
                      chatRepository: context.read<ChatRepository>(),
                      chatRepositorySend: context.read<ChatRepositorySend>(),
                      chatsRepository: context.read<ChatsRepository>(),
                      currentUser: currentUser,
                      initialSnapshot: snapshot, // 传入预获取的快照
                      initialConversation: conversation, // 💢💢💢 传入初始会话信息
                    ),
                  ),
                  BlocProvider<ChatsCubit>.value(value: chatsCubit),
                ],
                child: ChatPage(
                  conversationId: conversation.conversationId,
                  initialConversation: conversation, // 💢💢💢 传入初始会话信息
                ),
              ),
            ),
          ),
        );
      }
    } catch (error) {
      // 如果获取快照失败，仍然正常创建ChatCubit，但不传入快照
      if (context.mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => MultiRepositoryProvider(
              providers: [
                RepositoryProvider<ChatRepository>.value(value: chatRepository),
                RepositoryProvider<ChatsRepository>.value(value: chatsRepository),
                RepositoryProvider<ChatRepositorySend>.value(value: chatRepositorySend),
              ],
              child: BlocProvider<ChatCubit>(
                create: (context) => ChatCubit(
                  chatRepository: context.read<ChatRepository>(),
                  chatRepositorySend: context.read<ChatRepositorySend>(),
                  chatsRepository: context.read<ChatsRepository>(),
                  currentUser: currentUser,
                  initialConversation: conversation, // 💢💢💢 传入初始会话信息
                ),
                child: ChatPage(
                  conversationId: conversation.conversationId,
                  initialConversation: conversation, // 💢💢💢 传入初始会话信息
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  /// 格式化未读数量
  /// 如果超过1000，则以k为单位显示，保留一位小数
  String _formatUnreadCount(int count) {
    if (count >= 1000) {
      final double countInK = count / 1000;
      return '${countInK.toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
