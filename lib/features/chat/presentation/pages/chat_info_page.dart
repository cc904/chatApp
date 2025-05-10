import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/features/chat/presentation/pages/chat_search_page.dart';
import 'package:cc/core/services/log_service.dart';

class ChatInfoPage extends StatefulWidget {
  final String conversationId;

  const ChatInfoPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  final _logger = LogService('chat_info_page.dart');
  // 模拟属性值,实际应该保存在数据库中
  bool _isMuted = false;
  bool _isPinned = false;

  @override
  Widget build(BuildContext context) {
    // 获取主题颜色
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 获取当前会话
        final conversation = state.conversations.firstWhere(
          (c) => c.id.toString() == widget.conversationId,
          orElse: () => Conversation()..name = '未知会话',
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              '聊天信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 聊天信息卡片
                _buildChatInfoCard(conversation),

                // 聊天设置选项列表
                _buildSettingsList(conversation, primaryColor),

                // 媒体文件、文件等内容
                if (conversation.type == ConversationType.group) _buildGroupMembersSection(primaryColor),

                // 底部按钮区域
                _buildBottomButtons(conversation),
              ],
            ),
          ),
        );
      },
    );
  }

  // 聊天信息卡片 - 显示头像、名称等
  Widget _buildChatInfoCard(Conversation conversation) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // 头像区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // 头像
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: conversation.avatar != null && conversation.avatar!.isNotEmpty
                        ? Image.network(
                            conversation.avatar!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              conversation.name != null && conversation.name!.isNotEmpty ? conversation.name![0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // 会话名称
                Text(
                  conversation.name ?? '未知会话',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (conversation.type == ConversationType.private)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '微信号: wxid_example',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 设置选项列表 - 简化版
  Widget _buildSettingsList(Conversation conversation, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        children: [
          // 消息免打扰
          ListTile(
            leading: Icon(Icons.notifications_off_outlined, color: Colors.grey[700]),
            title: const Text('消息免打扰', style: TextStyle(fontSize: 15)),
            trailing: Switch(
              value: _isMuted,
              activeColor: primaryColor,
              onChanged: (value) {
                setState(() {
                  _isMuted = value;
                });
                // 实现消息免打扰功能
                _logger.i('设置消息免打扰', extra: {'value': value});
              },
            ),
          ),
          const Divider(height: 1),

          // 置顶聊天
          ListTile(
            leading: Icon(Icons.push_pin_outlined, color: Colors.grey[700]),
            title: const Text('置顶聊天', style: TextStyle(fontSize: 15)),
            trailing: Switch(
              value: _isPinned,
              activeColor: primaryColor,
              onChanged: (value) {
                setState(() {
                  _isPinned = value;
                });
                // 实现置顶聊天功能
                _logger.i('设置置顶聊天', extra: {'value': value});
              },
            ),
          ),
          const Divider(height: 1),

          // 查找聊天记录
          ListTile(
            leading: Icon(Icons.search, color: Colors.grey[700]),
            title: const Text('查找聊天记录', style: TextStyle(fontSize: 15)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // 打开聊天记录搜索页面
              _openChatSearch(context, conversation);
            },
          ),
        ],
      ),
    );
  }

  // 群成员区域 (仅群聊显示) - 简化版
  Widget _buildGroupMembersSection(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '群成员 (12)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          // 显示群成员网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: 12, // 假设12个成员
            itemBuilder: (context, index) {
              if (index < 10) {
                return _buildMemberItem('成员${index + 1}');
              } else if (index == 10) {
                return _buildActionItem(Icons.add, '添加', primaryColor);
              } else {
                return _buildActionItem(Icons.remove, '移除', Colors.grey);
              }
            },
          ),
        ],
      ),
    );
  }

  // 构建群成员项
  Widget _buildMemberItem(String name) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 构建操作项（添加/移除）
  Widget _buildActionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  // 底部按钮区域
  Widget _buildBottomButtons(Conversation conversation) {
    final isGroup = conversation.type == ConversationType.group;

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      color: Colors.white,
      child: Column(
        children: [
          // 清空聊天记录
          ListTile(
            title: Center(
              child: Text(
                '清空聊天记录',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            onTap: () {
              _showDeleteConfirmation(context);
            },
          ),
          const Divider(height: 1),

          // 删除并退出 (群聊) 或 删除聊天 (私聊)
          ListTile(
            title: Center(
              child: Text(
                isGroup ? '删除并退出' : '删除聊天',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
            onTap: () {
              _showLeaveConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  // 显示清空聊天记录确认对话框
  void _showDeleteConfirmation(BuildContext context) {
    final conversationId = widget.conversationId;
    final chatCubit = context.read<ChatCubit>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空聊天记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('清空', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              // 实现清空聊天记录功能
              chatCubit.clearConversationMessages(conversationId);
              UINotificationService().showSuccess('聊天记录已清空');
            },
          ),
        ],
      ),
    );
  }

  // 显示退出确认对话框
  void _showLeaveConfirmation(BuildContext context) {
    final conversationId = widget.conversationId;
    final chatCubit = context.read<ChatCubit>();
    final conversation = chatCubit.state.conversations.firstWhere(
      (c) => c.id.toString() == conversationId,
      orElse: () => Conversation(),
    );

    final isGroup = conversation.type == ConversationType.group;
    final title = isGroup ? '删除并退出' : '删除聊天';
    final content = isGroup ? '退出后,将不再接收此群聊信息' : '删除后,将不再接收此联系人的消息';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(isGroup ? '退出' : '删除', style: const TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              // 实现删除会话功能
              chatCubit.deleteConversation(conversationId);
              UINotificationService().showSuccess(isGroup ? '已退出群聊' : '已删除聊天');
              // 返回上一级
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 打开聊天记录搜索页面
  void _openChatSearch(BuildContext context, Conversation conversation) {
    // 使用局部变量
    final conversationId = widget.conversationId;
    final conversationName = conversation.name ?? '未知会话';

    // 使用延迟调用来避免直接使用BuildContext
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final navigator = Navigator.of(context);
      navigator.push<dynamic>(
        MaterialPageRoute(
          builder: (context) => ChatSearchPage(
            conversationId: conversationId,
            conversationName: conversationName,
          ),
        ),
      );
    });
  }
}
