import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/chat/presentation/pages/chat_page.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';

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
    final bool isGroup = conversation.type == ConversationType.group;
    final bool isChannel = conversation.type == ConversationType.channel;

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
              color: conversation.isPinned(currentUser.userId)
                  ? Colors.blue.withAlpha(15)
                  : Colors.transparent,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: 60,
        height: 60,
        child: UserAvatar(
          avatarUrl: conversation.avatar,
          name: conversation.displayName(currentUser.userId),
          radius: 60 / 2,
          backgroundColor: Colors.cyan,
        ),
      ),
    );
  }

  /// 构建会话内容
  /// 根据会话类型显示不同的内容格式
  Widget _buildContent(Conversation conversation) {
    // 判断会话类型
    final bool isGroup = conversation.type == ConversationType.group;
    final bool isChannel = conversation.type == ConversationType.channel;

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
                  if (conversation.isPinned(currentUser.userId))
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),

                  // 根据会话类型显示不同图标
                  if (isGroup)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.group,
                        size: 16,
                        color: Colors.blue,
                      ),
                    )
                  else if (isChannel)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.campaign,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),

                  // 会话名称
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
                  if (conversation.isMuted(currentUser.userId))
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
    final bool isSystemMessage =
        _isSystemMessage(conversation.lastMessagePreview);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (!isSystemMessage &&
              conversation.lastMessageName != null &&
              conversation.lastMessageName!.isNotEmpty)
            TextSpan(
              text: '${conversation.lastMessageName}: ',
              style: TextStyle(
                fontSize: 13,
                color: isChannel ? Colors.purple : Colors.blue,
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
    return systemKeywords
        .any((keyword) => lowerPreview.contains(keyword.toLowerCase()));
  }

  /// 获取会话显示名称，对群聊和频道名称进行长度限制
  String _getDisplayName(
      Conversation conversation, bool isGroup, bool isChannel) {
    String name = conversation.displayName(currentUser.userId);

    if ((isGroup || isChannel) && name.length > 24) {
      return name.substring(0, 24);
    }

    return name;
  }

  /// 构建时间和未读数量
  Widget _buildTimeAndUnreadCount(Conversation conversation) {
    conversation.unreadCount(currentUser.userId);

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 8.0),
      child: SizedBox(
        height: 60, // 与头像高度一致
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 时间
            Text(
              _defaultFormatTime(conversation.lastMessageTime),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            // 未读数
            if (conversation.unreadCount(currentUser.userId) > 0)
              _buildUnreadBadge(conversation)
            else
              const SizedBox(height: 20), // 占位符
          ],
        ),
      ),
    );
  }

  /// 构建未读消息徽章
  Widget _buildUnreadBadge(Conversation conversation) {
    final bool isNewMessage =
        conversation.hasNewMessagesSinceLastRead(currentUser.userId);

    conversation.unreadCount(currentUser.userId);

    // 获取未读数量（用于Text显示）
    final displayUnreadCount = conversation.unreadCount(currentUser.userId);
    final formattedCount = _formatUnreadCount(displayUnreadCount);

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
  void _openChatDetail(BuildContext context, Conversation conversation,
      CurrentUser currentUser) async {
    // 在导航前获取Repository和Cubit引用
    final chatRepository = context.read<ChatRepository>();
    final chatsRepository = context.read<ChatsRepository>();
    final chatRepositorySend = context.read<ChatRepositorySend>();
    final navigator = Navigator.of(context);

    try {
      // 先清理过期快照
      await chatsRepository.cleanupExpiredSnapshots();

      // 获取状态快照（如果存在）
      final snapshot =
          await chatsRepository.getStateSnapshot(conversation.conversationId);

      if (context.mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => MultiRepositoryProvider(
              providers: [
                RepositoryProvider<ChatRepository>.value(value: chatRepository),
                RepositoryProvider<ChatsRepository>.value(
                    value: chatsRepository),
                RepositoryProvider<ChatRepositorySend>.value(
                    value: chatRepositorySend),
              ],
              child: BlocProvider<ChatCubit>(
                create: (context) => ChatCubit(
                  chatRepository: context.read<ChatRepository>(),
                  chatRepositorySend: context.read<ChatRepositorySend>(),
                  chatsRepository: context.read<ChatsRepository>(),
                  currentUser: currentUser,
                  initialSnapshot: snapshot, // 传入预获取的快照
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
    } catch (error) {
      // 如果获取快照失败，仍然正常创建ChatCubit，但不传入快照
      if (context.mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => MultiRepositoryProvider(
              providers: [
                RepositoryProvider<ChatRepository>.value(value: chatRepository),
                RepositoryProvider<ChatsRepository>.value(
                    value: chatsRepository),
                RepositoryProvider<ChatRepositorySend>.value(
                    value: chatRepositorySend),
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

  /// 默认的时间格式化函数
  String _defaultFormatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    // 今天内的消息显示时间
    if (difference.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    // 一周内的消息显示星期
    else if (difference.inDays < 7) {
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[(time.weekday - 1) % 7];
    }
    // 更早的消息显示日期
    else {
      return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
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
