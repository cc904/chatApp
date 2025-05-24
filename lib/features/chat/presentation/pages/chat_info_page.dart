import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/features/chat/presentation/pages/chat_search_page.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/widgets/user_avatar.dart';

class ChatInfoPage extends StatefulWidget {
  final String conversationId;
  final dynamic contact;

  const ChatInfoPage({
    super.key,
    required this.conversationId,
    this.contact,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  final _logger = LogService.instance;
  // 模拟属性值,实际应该保存在数据库中
  bool _isMuted = false;
  bool _isPinned = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // 获取当前会话
        final conversation = state.conversations.firstWhere(
          (c) => c.conversationId == widget.conversationId,
          orElse: () => Conversation()..name = '未知会话',
        );

        // 判断是否为群聊
        final isGroup = conversation.type == ConversationType.group;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7), // iOS风格的背景色
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Back',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
            ),
            centerTitle: false,
            titleSpacing: 0,
            actions: [
              TextButton(
                onPressed: () {
                  // 编辑功能
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 头像和名称区域 - 移除白色背景
                _buildProfileHeader(conversation),

                const SizedBox(height: 20),

                // 操作按钮区域 - 修改为直接在背景上的按钮
                _buildActionButtons(),

                const SizedBox(height: 30),

                // 手机号码区域 - 修改为显示用户ID
                _buildPhoneSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // 头像和名称区域 - 移除白色背景
  Widget _buildProfileHeader(Conversation conversation) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Column(
        children: [
          // 头像
          UserAvatar(
            avatarUrl: widget.contact?.avatar,
            name: widget.contact?.name ?? '?',
            radius: 50,
            backgroundColor: Colors.cyan,
          ),
          const SizedBox(height: 16),
          // 名称
          Text(
            widget.contact?.name ?? conversation.name ?? '未知联系人',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // 状态
          const Text(
            'last seen a long time ago',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 操作按钮区域 - 修改为直接在背景上的按钮
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(Icons.call, 'call', Colors.blue),
          _buildActionButton(Icons.videocam, 'video', Colors.blue),
          _buildActionButton(
              Icons.notifications_off_outlined, 'mute', Colors.blue),
          _buildActionButton(Icons.search, 'search', Colors.blue),
          _buildMoreButton(),
        ],
      ),
    );
  }

  // 单个操作按钮
  Widget _buildActionButton(IconData icon, String label, Color color) {
    // 计算一个按钮占据的宽度 (总宽度减去4个8px的间隙，再除以5)
    // 减小了按钮间距从16px到8px
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 32) / 5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              _logger.i('点击了操作按钮', extra: {'action': label});
              UINotificationService().showInfo('$label 功能开发中');
            },
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 更多按钮 - 点击显示弹出菜单
  Widget _buildMoreButton() {
    // 计算一个按钮占据的宽度 (总宽度减去4个8px的间隙，再除以5)
    // 减小了按钮间距从16px到8px
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 32) / 5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          offset: const Offset(0, 76), // 向下偏移按钮高度(70) + 6像素
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white, // 设置菜单背景色为白色，与按钮一致
          elevation: 4, // 轻微的阴影
          itemBuilder: (context) => [
            _buildPopupMenuItem(Icons.edit, '编辑联系人'),
            _buildPopupMenuItem(Icons.block, '屏蔽用户'),
            _buildPopupMenuItem(Icons.report, '举报'),
            _buildPopupMenuItem(Icons.delete_forever, '清空聊天记录',
                isDestructive: true),
          ],
          onSelected: (value) {
            _handleMenuItemSelected(value);
          },
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.more_horiz, color: Colors.blue, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    'more',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建弹出菜单项
  PopupMenuItem<String> _buildPopupMenuItem(IconData icon, String text,
      {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.black87,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 处理菜单项选择
  void _handleMenuItemSelected(String value) {
    _logger.i('选择了菜单项', extra: {'action': value});

    switch (value) {
      case '编辑联系人':
        UINotificationService().showInfo('编辑联系人功能开发中');
        break;
      case '屏蔽用户':
        UINotificationService().showInfo('屏蔽用户功能开发中');
        break;
      case '举报':
        UINotificationService().showInfo('举报功能开发中');
        break;
      case '清空聊天记录':
        _showDeleteConfirmation(context);
        break;
    }
  }

  // 手机号码区域 - 修改为显示用户ID
  Widget _buildPhoneSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 3),
                    child: Text(
                      'user ID',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '@${widget.conversationId}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  // 复制用户ID到剪贴板
                                  final idToCopy = widget.conversationId;
                                  Clipboard.setData(
                                      ClipboardData(text: idToCopy));
                                  _logger
                                      .i('复制用户ID到剪贴板', extra: {'id': idToCopy});
                                  UINotificationService()
                                      .showSuccess('已复制用户ID');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.copy,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Color(0xFFEEEEEE),
                    width: 1,
                  ),
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.qr_code,
                  color: Colors.blue,
                  size: 28,
                ),
                onPressed: () {
                  _logger.i('显示用户二维码');
                  UINotificationService().showInfo('显示用户二维码功能开发中');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示清空聊天记录确认对话框
  void _showDeleteConfirmation(BuildContext context) {
    final conversationId = widget.conversationId;

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
              // TODO: 实现清空聊天记录功能
              // 需要在HomeCubit中添加对应方法
              UINotificationService().showSuccess('聊天记录已清空');
            },
          ),
        ],
      ),
    );
  }

  // 显示退出确认对话框
  void _showLeaveConfirmation(BuildContext context, bool isGroup) {
    final conversationId = widget.conversationId;
    final homeCubit = context.read<HomeCubit>();
    final conversation = homeCubit.state.conversations.firstWhere(
      (c) => c.conversationId == conversationId,
      orElse: () => Conversation(),
    );

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
            child: Text(isGroup ? '退出' : '删除',
                style: const TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现删除会话功能
              // 需要在HomeCubit中添加对应方法
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
    final conversationName =
        widget.contact?.name ?? conversation.name ?? '未知会话';

    // 使用延迟调用来避免直接使用BuildContext
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final homeCubit = context.read<HomeCubit>();

      navigator.push<dynamic>(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: homeCubit,
            child: ChatSearchPage(
              conversationId: conversationId,
              conversationName: conversationName,
            ),
          ),
        ),
      );
    });
  }
}
