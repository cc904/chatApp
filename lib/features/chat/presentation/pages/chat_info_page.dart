import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';

class ChatInfoPage extends StatefulWidget {
  const ChatInfoPage({
    super.key,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage>
    with SingleTickerProviderStateMixin {
  final _logger = LogService.instance;
  // 静音按钮动画控制器
  late AnimationController _muteAnimController;
  late Animation<double> _rotateAnimation;

  // 添加编辑模式状态
  bool _isEditMode = false;

  // 添加文本编辑控制器
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // 添加description展开状态管理
  bool _isDescriptionExpanded = false;

  // 添加复制状态管理
  bool _isCopied = false;

  // 添加Tab数据加载标志，避免重复加载
  bool _hasTriedLoadingMedia = false;
  bool _hasTriedLoadingFiles = false;
  bool _hasTriedLoadingVoice = false;
  bool _hasTriedLoadingLinks = false;

  @override
  void initState() {
    super.initState();

    // 初始化静音按钮动画控制器
    _muteAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _muteAnimController,
      curve: Curves.easeInOut,
    ));

    // 获取当前会话，初始化静音状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final chatCubit = context.read<ChatCubit>();
        final conversation = chatCubit.state.conversation;

        // 根据会话的静音状态设置动画
        final currentUserId = chatCubit.state.currentUser.userId;
        if (conversation.isMuted(currentUserId)) {
          _muteAnimController.value = 1.0; // 直接设置到终点
        } else {
          _muteAnimController.value = 0.0;
        }
      }
    });
  }

  @override
  void dispose() {
    _muteAnimController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // 切换静音状态
  void _toggleMuteState() {
    final chatCubit = context.read<ChatCubit>();
    final currentUserId = chatCubit.state.currentUser.userId;

    final currentMuteStatus =
        chatCubit.state.conversation.isMuted(currentUserId);
    final newMuteStatus = !currentMuteStatus;

    // 立即更新动画状态
    if (newMuteStatus) {
      _muteAnimController.forward();
    } else {
      _muteAnimController.reverse();
    }

    UINotificationService().showSuccess(newMuteStatus ? '已开启静音' : '已关闭静音');
    _logger.i('切换静音状态', extra: {'isMuted': newMuteStatus});

    // 通过 ChatCubit 更新静音状态（遵循 DDD 架构）
    chatCubit.updateConversationMuteStatus(newMuteStatus);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 从 ChatCubit 获取当前会话信息
        final conversation = state.conversation;

        // 判断是否为群聊
        final isGroup = conversation.type == ConversationType.group;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7), // 保持iOS风格的浅色背景
          appBar: AppBar(
            backgroundColor: const Color(0xFFF2F2F7), // 与背景颜色一致
            foregroundColor: Colors.black,
            elevation: 0, // 无阴影
            automaticallyImplyLeading: false, // 不显示默认返回按钮
            // 使用自定义的返回/取消按钮区域
            leadingWidth: _isEditMode ? 105 : 80, // 为Cancel模式提供更多空间
            leading: GestureDetector(
              onTap: () {
                if (_isEditMode) {
                  // 取消编辑，恢复原始状态
                  setState(() {
                    _isEditMode = false;
                    // 重新初始化文本控制器
                    if (state.conversation.name != null) {
                      final nameParts = state.conversation.name!.split(' ');
                      if (nameParts.isNotEmpty) {
                        _firstNameController.text = nameParts.first;
                        if (nameParts.length > 1) {
                          _lastNameController.text =
                              nameParts.sublist(1).join(' ');
                        }
                      }
                    }
                  });
                } else {
                  // 返回上一页
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 不同模式显示不同图标
                    _isEditMode
                        ? const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          )
                        : const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.blue,
                            size: 18,
                          ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        _isEditMode ? 'Cancel' : 'Back',
                        style: TextStyle(
                          fontSize: 17,
                          color: _isEditMode ? Colors.red : Colors.blue,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 清除默认标题
            title: const Text(''),
            centerTitle: false,
            titleSpacing: 0,
            actions: [
              TextButton(
                onPressed: () {
                  if (_isEditMode) {
                    // 完成编辑，保存更改
                    final newName =
                        '${_firstNameController.text} ${_lastNameController.text}'
                            .trim();
                    _logger.i('保存用户名称', extra: {'newName': newName});
                    UINotificationService().showSuccess('名称已更新');
                    setState(() {
                      _isEditMode = false;
                    });
                  } else {
                    // 进入编辑模式
                    setState(() {
                      _isEditMode = true;
                    });
                  }
                },
                child: Text(
                  _isEditMode ? 'Done' : 'Edit',
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          body: _isEditMode
              ? _buildEditModeContent(conversation)
              : _buildViewModeContent(conversation, isGroup),
        );
      },
    );
  }

  // 编辑模式下的内容
  Widget _buildEditModeContent(Conversation conversation) {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像和名称区域 - 保持原有布局
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            child: Column(
              children: [
                // 头像
                Hero(
                  tag: 'chat_avatar_${conversation.conversationId}',
                  child: UserAvatar(
                    avatarUrl: conversation.avatar,
                    name: conversation.name ?? '?',
                    radius: 50,
                    backgroundColor: Colors.cyan,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 名字输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: '姓',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE0E0E0),
                    indent: 16,
                  ),
                  TextField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: '名',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 删除联系人按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Center(
                  child: Text(
                    'Delete Contact',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                onTap: () {
                  // 删除联系人
                  _showLeaveConfirmation(context, false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 查看模式下的内容
  Widget _buildViewModeContent(Conversation conversation, bool isGroup) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像和名称区域 - 移除白色背景
          _buildProfileHeader(conversation),

          const SizedBox(height: 20),

          // 操作按钮区域 - 根据会话类型显示不同按钮
          _buildActionButtons(),

          const SizedBox(height: 30),

          // 用户ID/群组ID区域（包含description）
          _buildPhoneSection(),

          // 频道联系人模块（仅频道显示）
          _buildChannelContactsSection(),

          // 群成员列表模块（仅群组显示）
          _buildGroupMembersSection(),

          // 聊天资源分类模块
          _buildChatResourcesSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 头像和名称区域 - 移除白色背景
  Widget _buildProfileHeader(Conversation conversation) {
    final state = context.read<ChatCubit>().state;
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Column(
        children: [
          // 头像
          Hero(
            tag: 'chat_avatar_${state.conversation.conversationId}',
            child: UserAvatar(
              avatarUrl: state.conversation.avatar,
              name: state.conversation.name ?? '?',
              radius: 50,
              backgroundColor: Colors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // 名称
          Hero(
            tag: 'chat_title_${state.conversation.conversationId}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                state.conversation.name ?? '未知联系人',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 状态
          Hero(
            tag: 'chat_subtitle_${state.conversation.conversationId}',
            child: const Material(
              color: Colors.transparent,
              child: Text(
                'last seen a long time ago',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 操作按钮区域 - 根据会话类型显示不同按钮
  Widget _buildActionButtons() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == ConversationType.private;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 私聊显示call和video
          if (isPrivate) ...[
            _buildActionButton(Icons.call, 'call', Colors.blue),
            _buildActionButton(Icons.videocam, 'video', Colors.blue),
            _buildMuteButton(),
            _buildActionButton(Icons.search, 'search', Colors.blue),
            _buildMoreButton(),
          ] else ...[
            // 群聊和频道只显示4个按钮：mute、search、leave、more
            _buildMuteButton(),
            _buildActionButton(Icons.search, 'search', Colors.blue),
            _buildLeaveButton(),
            _buildMoreButton(),
          ],
        ],
      ),
    );
  }

  // Leave按钮（群聊和频道专用）
  Widget _buildLeaveButton() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isGroup = conversation.type == ConversationType.group;

    // 根据按钮数量计算宽度：私聊5个按钮，群聊/频道4个按钮
    final isPrivate = conversation.type == ConversationType.private;
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth =
        (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              _showLeaveConfirmation(context, isGroup);
            },
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app, color: Colors.red, size: 26),
                  SizedBox(height: 6),
                  Text(
                    'leave',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
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

  // 静音按钮 - 带有动画效果
  Widget _buildMuteButton() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == ConversationType.private;
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth =
        (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _toggleMuteState,
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 使用旋转动画包装图标
                  AnimatedBuilder(
                    animation: _rotateAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value * 0.5, // 旋转90度
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 两种图标在同一位置，通过透明度控制显示/隐藏
                            Opacity(
                              opacity: 1 - _rotateAnimation.value,
                              child: const Icon(
                                Icons.notifications_none,
                                color: Colors.blue,
                                size: 26,
                              ),
                            ),
                            Opacity(
                              opacity: _rotateAnimation.value,
                              child: const Icon(
                                Icons.notifications_off_outlined,
                                color: Colors.blue,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  // 文本根据状态变化
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: BlocBuilder<ChatCubit, ChatState>(
                      buildWhen: (previous, current) {
                        final currentUserId = current.currentUser.userId;
                        return previous.conversation.isMuted(currentUserId) !=
                            current.conversation.isMuted(currentUserId);
                      },
                      builder: (context, state) {
                        final currentUserId = state.currentUser.userId;
                        final isMuted =
                            state.conversation.isMuted(currentUserId);
                        return Text(
                          isMuted ? 'unmute' : 'mute',
                          key: ValueKey<bool>(isMuted),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        );
                      },
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

  // 单个操作按钮
  Widget _buildActionButton(IconData icon, String label, Color color) {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == ConversationType.private;
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth =
        (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (label == 'search') {
                // 搜索按钮特殊处理：返回到 ChatPage 并启动搜索模式
                final chatCubit = context.read<ChatCubit>();
                chatCubit.enterSearchMode();
                Navigator.pop(context); // 返回到 ChatPage
              } else if (label == 'leave') {
                final isGroup = conversation.type == ConversationType.group;
                _showLeaveConfirmation(context, isGroup);
              } else {
                _logger.i('点击了操作按钮', extra: {'action': label});
                UINotificationService().showInfo('$label 功能开发中');
              }
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
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == ConversationType.private;
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth =
        (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

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
              child: Container(
                color: Colors.transparent,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.more_horiz, color: Colors.blue, size: 26),
                    SizedBox(height: 6),
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
        )
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
        setState(() {
          _isEditMode = true;
        });
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

  // 显示清空聊天记录确认对话框
  void _showDeleteConfirmation(BuildContext context) {
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
              // TODO 实现清空聊天记录功能
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
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isChannel = conversation.type == ConversationType.channel;

    String title;
    String content;
    String actionText;

    if (isGroup) {
      title = '删除并退出';
      content = '退出后,将不再接收此群聊信息';
      actionText = '退出';
    } else if (isChannel) {
      title = '退出频道';
      content = '退出后,将不再接收此频道信息';
      actionText = '退出';
    } else {
      title = '删除联系人';
      content = '删除后,将不再接收此联系人的消息';
      actionText = '删除';
    }

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
            child: Text(actionText, style: const TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              // TODO 实现删除会话功能
              // 需要在HomeCubit中添加对应方法
              final successMessage = isGroup
                  ? '已退出群聊'
                  : isChannel
                      ? '已退出频道'
                      : '已删除联系人';
              UINotificationService().showSuccess(successMessage);
              // 返回上一级
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 用户ID/群组ID区域
  Widget _buildPhoneSection() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isGroup = conversation.type == ConversationType.group;
    final isChannel = conversation.type == ConversationType.channel;

    // 根据会话类型确定要显示的ID和标签
    String displayId;
    String labelText;
    String successMessage;

    if (isGroup) {
      // 群聊显示群组ID
      displayId = conversation.conversationId;
      labelText = 'group ID';
      successMessage = '已复制群组ID';
    } else if (isChannel) {
      // 频道显示频道ID
      displayId = conversation.conversationId;
      labelText = 'channel ID';
      successMessage = '已复制频道ID';
    } else {
      // 私聊：遍历参与者获取对方用户ID，排除当前用户
      final currentUserId = state.currentUser.userId;
      final peer = conversation.participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => Participant(),
      );
      displayId =
          peer.userId.isNotEmpty ? peer.userId : conversation.conversationId;
      labelText = 'user ID';
      successMessage = '已复制用户ID';
    }

    // 检查是否需要显示描述
    final shouldShowDescription = isGroup || isChannel;
    final description = conversation.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // ID部分
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          labelText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: shouldShowDescription ? 16 : 16,
                            top: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    '@$displayId',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () async {
                                      // 复制ID到剪贴板
                                      Clipboard.setData(
                                          ClipboardData(text: displayId));
                                      _logger.i('复制ID到剪贴板', extra: {
                                        'id': displayId,
                                        'type': isGroup
                                            ? 'group'
                                            : isChannel
                                                ? 'channel'
                                                : 'user'
                                      });
                                      UINotificationService()
                                          .showSuccess(successMessage);

                                      // 设置复制状态
                                      setState(() {
                                        _isCopied = true;
                                      });

                                      // 2秒后恢复原状
                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        if (mounted) {
                                          setState(() {
                                            _isCopied = false;
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: _isCopied
                                            ? Colors.green.withAlpha(26)
                                            : Colors.blue.withAlpha(26),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: _isCopied
                                            ? const Row(
                                                key: ValueKey('copied'),
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '已复制',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Icon(
                                                key: ValueKey('copy'),
                                                Icons.copy,
                                                color: Colors.blue,
                                                size: 16,
                                              ),
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
                      _showQRCodeDialog(context, displayId, isGroup);
                    },
                  ),
                ),
              ],
            ),
            // 描述部分（仅群组和频道）
            if (shouldShowDescription) ...[
              // 分隔线
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 描述标题
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 描述内容
                    if (hasDescription)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: _isDescriptionExpanded ? null : 2,
                            overflow: _isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          // 检查是否需要显示more/less按钮
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // 创建一个测试文本来计算实际行数
                              final span = TextSpan(
                                text: description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              );
                              final tp = TextPainter(
                                text: span,
                                maxLines: 2,
                                textDirection: TextDirection.ltr,
                              );
                              tp.layout(maxWidth: constraints.maxWidth);

                              final needsMoreButton = tp.didExceedMaxLines;

                              if (needsMoreButton) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isDescriptionExpanded =
                                            !_isDescriptionExpanded;
                                      });
                                    },
                                    child: Text(
                                      _isDescriptionExpanded ? 'less' : 'more',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      )
                    else
                      Text(
                        isGroup ? '欢迎加入群组！' : '欢迎关注频道！',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 频道联系人模块（仅频道显示）
  Widget _buildChannelContactsSection() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isChannel = conversation.type == ConversationType.channel;

    if (!isChannel) {
      return const SizedBox.shrink();
    }

    // 获取非普通成员（管理员、所有者等）
    // 💢💢💢 调试提示：为了测试此功能，可以在频道中添加一些具有admin或owner角色的参与者
    // 例如：conversation.participants 中应包含 role != MemberRole.member 的用户
    final nonMemberParticipants = conversation.participants
        .where((p) => p.role != MemberRole.member)
        .toList();

    if (nonMemberParticipants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加成员按钮（可选，仅管理员可见）
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Members',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 52),

            // 非普通成员列表
            ...nonMemberParticipants.asMap().entries.map((entry) {
              final index = entry.key;
              final participant = entry.value;
              final isLast = index == nonMemberParticipants.length - 1;

              return Column(
                children: [
                  _buildContactItem(
                    avatar: participant.avatar,
                    name: participant.name,
                    role: _getRoleDisplayName(participant.role),
                    isOnline: participant.online,
                    lastSeen: participant.online ? null : 'last seen recently',
                  ),
                  if (!isLast) const Divider(height: 1, indent: 68),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // 构建单个联系人项
  Widget _buildContactItem({
    required String? avatar,
    required String name,
    required String role,
    required bool isOnline,
    String? lastSeen,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 头像
          Stack(
            children: [
              UserAvatar(
                avatarUrl: avatar,
                name: name,
                radius: 26,
              ),
              // 在线状态指示器
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 角色标识
                    if (role.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRoleTextColor(role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lastSeen ?? (isOnline ? 'online' : 'offline'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取角色显示名称
  String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return 'CEO';
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.member:
        return '';
    }
  }

  // 获取角色标签颜色
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'ceo':
        return Colors.purple[100]!;
      case 'admin':
        return Colors.blue[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  // 获取角色文字颜色
  Color _getRoleTextColor(String role) {
    switch (role.toLowerCase()) {
      case 'ceo':
        return Colors.purple[700]!;
      case 'admin':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  // 群成员列表模块（仅群组显示）- 已整合到聊天资源分类模块中
  Widget _buildGroupMembersSection() {
    // 此方法已废弃，群成员列表现在是聊天资源分类模块中的一个Tab
    return const SizedBox.shrink();
  }

  // 聊天资源分类模块
  Widget _buildChatResourcesSection() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isGroup = conversation.type == ConversationType.group;

    // 根据会话类型确定Tab列表
    List<String> tabs = [];
    if (isGroup) {
      tabs = ['Members', 'Media', 'Files', 'Music', 'Voice', 'Links'];
    } else {
      tabs = ['Media', 'Files', 'Music', 'Voice', 'Links'];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              // Tab栏
              TabBar(
                isScrollable: true,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabAlignment: TabAlignment.start,
                tabs: tabs.map((tab) => Tab(text: tab)).toList(),
              ),

              // Tab内容区域
              SizedBox(
                height: 400, // 固定高度
                child: TabBarView(
                  children: tabs
                      .map((tab) => _buildTabContent(tab, conversation))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建Tab内容
  Widget _buildTabContent(String tabName, Conversation conversation) {
    switch (tabName) {
      case 'Members':
        return _buildMembersTabContent(conversation);
      case 'Media':
        return _buildMediaTabContent();
      case 'Files':
        return _buildFilesTabContent();
      case 'Music':
        return _buildMusicTabContent();
      case 'Voice':
        return _buildVoiceTabContent();
      case 'Links':
        return _buildLinksTabContent();
      default:
        return _buildEmptyTabContent(tabName);
    }
  }

  // 群成员Tab内容
  Widget _buildMembersTabContent(Conversation conversation) {
    final participants = conversation.participants;

    if (participants.isEmpty) {
      return const Center(
        child: Text(
          '暂无成员',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: participants.length + 1, // +1 for Add Members button
      itemBuilder: (context, index) {
        if (index == 0) {
          // Add Members按钮
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: const Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Add Members',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final participant = participants[index - 1];
        final isLast = index == participants.length;

        return Column(
          children: [
            _buildMemberItem(participant),
            if (!isLast) const Divider(height: 1, indent: 68),
          ],
        );
      },
    );
  }

  // 构建单个成员项
  Widget _buildMemberItem(Participant participant) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // 头像
          Stack(
            children: [
              UserAvatar(
                avatarUrl: participant.avatar,
                name: participant.name,
                radius: 26,
              ),
              // 在线状态指示器
              if (participant.online)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        participant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 角色标识
                    if (participant.role != MemberRole.member)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getMemberRoleColor(participant.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getMemberRoleDisplayName(participant.role),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getMemberRoleTextColor(participant.role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  participant.online ? 'online' : 'last seen recently',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取成员角色显示名称
  String _getMemberRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return 'owner';
      case MemberRole.admin:
        return 'admin';
      case MemberRole.member:
        return '';
    }
  }

  // 获取成员角色标签颜色
  Color _getMemberRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return Colors.orange[100]!;
      case MemberRole.admin:
        return Colors.blue[100]!;
      case MemberRole.member:
        return Colors.grey[200]!;
    }
  }

  // 获取成员角色文字颜色
  Color _getMemberRoleTextColor(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return Colors.orange[700]!;
      case MemberRole.admin:
        return Colors.blue[700]!;
      case MemberRole.member:
        return Colors.grey[700]!;
    }
  }

  // Media Tab内容
  Widget _buildMediaTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingMedia && !state.isLoadingMedia) {
          _hasTriedLoadingMedia = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadMediaMessages();
          });
        }

        if (state.isLoadingMedia && state.mediaMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.mediaMessages.isEmpty) {
          return const Center(
            child: Text(
              '暂无媒体文件',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // 使用自定义的瀑布流GridView显示媒体缩略图
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildStaggeredMediaGrid(state.mediaMessages),
        );
      },
    );
  }

  // Files Tab内容
  Widget _buildFilesTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingFiles && !state.isLoadingFiles) {
          _hasTriedLoadingFiles = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadFileMessages();
          });
        }

        if (state.isLoadingFiles && state.fileMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.fileMessages.isEmpty) {
          return const Center(
            child: Text(
              '暂无文件',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.fileMessages.length,
          itemBuilder: (context, index) {
            final message = state.fileMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // Music Tab内容
  Widget _buildMusicTabContent() {
    // 音乐消息通常归类为文件消息，这里可以过滤文件消息中的音频文件
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingFiles && !state.isLoadingFiles) {
          _hasTriedLoadingFiles = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadFileMessages();
          });
        }

        // 过滤出音频文件
        final musicMessages = state.fileMessages.where((message) {
          final fileName = message.fileName ?? '';
          return fileName.toLowerCase().endsWith('.mp3') ||
              fileName.toLowerCase().endsWith('.m4a') ||
              fileName.toLowerCase().endsWith('.wav') ||
              fileName.toLowerCase().endsWith('.flac');
        }).toList();

        if (state.isLoadingFiles && musicMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (musicMessages.isEmpty) {
          return const Center(
            child: Text(
              '暂无音乐文件',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: musicMessages.length,
          itemBuilder: (context, index) {
            final message = musicMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // Voice Tab内容
  Widget _buildVoiceTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingVoice && !state.isLoadingVoice) {
          _hasTriedLoadingVoice = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadVoiceMessages();
          });
        }

        if (state.isLoadingVoice && state.voiceMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.voiceMessages.isEmpty) {
          return const Center(
            child: Text(
              '暂无语音消息',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.voiceMessages.length,
          itemBuilder: (context, index) {
            final message = state.voiceMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // Links Tab内容
  Widget _buildLinksTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingLinks && !state.isLoadingLinks) {
          _hasTriedLoadingLinks = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadLinkMessages();
          });
        }

        if (state.isLoadingLinks && state.linkMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.linkMessages.isEmpty) {
          return const Center(
            child: Text(
              '暂无链接',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.linkMessages.length,
          itemBuilder: (context, index) {
            final message = state.linkMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // 空Tab内容
  Widget _buildEmptyTabContent(String tabName) {
    return Center(
      child: Text(
        '$tabName content coming soon',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  // 显示二维码对话框
  void _showQRCodeDialog(BuildContext context, String id, bool isGroup) {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isChannel = conversation.type == ConversationType.channel;

    String title;
    String qrData;

    if (isGroup) {
      title = '群组二维码';
      qrData = 'group:$id';
    } else if (isChannel) {
      title = '频道二维码';
      qrData = 'channel:$id';
    } else {
      title = '用户二维码';
      qrData = 'user:$id';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 250,
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 250,
                gapless: false,
              ),
              const SizedBox(height: 16),
              Text(
                qrData,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              // 复制二维码数据到剪贴板
              Clipboard.setData(ClipboardData(text: qrData));
              Navigator.pop(context);
              UINotificationService().showSuccess('二维码数据已复制');
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }

  // 使用自定义的瀑布流GridView显示媒体缩略图
  Widget _buildStaggeredMediaGrid(List<Message> messages) {
    return MasonryGridView.builder(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildVariableHeightMediaThumbnail(message, index);
      },
    );
  }

  /// 构建可变高度的媒体缩略图
  Widget _buildVariableHeightMediaThumbnail(Message message, int index) {
    // 根据图片的实际尺寸或索引来计算高度
    final height = _calculateThumbnailHeight(message, index);

    return SizedBox(
      height: height,
      child: _buildMediaThumbnail(message),
    );
  }

  /// 计算缩略图高度
  double _calculateThumbnailHeight(Message message, int index) {
    // 如果有图片的实际宽高信息，使用真实比例
    if (message.width != null && message.height != null && message.width! > 0) {
      final aspectRatio = message.height! / message.width!;
      // 基础宽度约为屏幕宽度的1/3减去间距
      final baseWidth = (MediaQuery.of(context).size.width - 32 - 8) / 3;
      final calculatedHeight = baseWidth * aspectRatio;
      // 限制高度范围，避免过高或过矮
      return calculatedHeight.clamp(80.0, 300.0);
    }

    // 如果没有尺寸信息，使用预设的随机高度模式来模拟瀑布流效果
    final patterns = [
      120.0,
      160.0,
      100.0,
      140.0,
      180.0,
      110.0,
      150.0,
      130.0,
      170.0,
      200.0,
      90.0,
      190.0,
      135.0,
      175.0,
      125.0,
      155.0,
      185.0,
      105.0
    ];
    return patterns[index % patterns.length];
  }

  /// 构建媒体缩略图组件
  Widget _buildMediaThumbnail(Message message) {
    return GestureDetector(
      onTap: () => _showMediaViewer(message),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 缩略图
              _buildThumbnailImage(message),

              // 视频播放图标覆盖层
              if (message.type == MessageType.video)
                Container(
                  color: Colors.black.withAlpha(77), // 30% 透明度
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

              // 底部信息栏（可选）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withAlpha(128), // 50% 透明度
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    _formatMessageDate(message.createdAt),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示媒体查看器
  void _showMediaViewer(Message message) {
    _logger.i('显示媒体查看器', extra: {
      'messageId': message.messageId,
      'type': message.type.toString(),
    });

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            // 媒体内容
            Center(
              child: InteractiveViewer(
                child: _buildFullSizeMedia(message),
              ),
            ),
            // 关闭按钮
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // 媒体信息
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.fileName != null)
                      Text(
                        message.fileName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _formatMessageDate(message.createdAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (message.fileSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(message.fileSize!.toInt()),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建全尺寸媒体
  Widget _buildFullSizeMedia(Message message) {
    if (message.type == MessageType.video) {
      // 视频播放器
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_filled, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            message.fileName ?? '视频文件',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击播放视频',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      );
    } else {
      // 图片查看
      return _buildThumbnailImage(message);
    }
  }

  /// 构建缩略图图片
  Widget _buildThumbnailImage(Message message) {
    final thumbnailUrl = message.thumbnailUrl;
    final localPath = message.localPath;

    // 优先使用本地缩略图文件
    if (localPath != null && localPath.isNotEmpty) {
      final localFile = File(localPath);
      if (localFile.existsSync()) {
        return Image.file(
          localFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackThumbnail(message);
          },
        );
      }
    }

    // 如果有缩略图URL，使用网络缩略图
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return Image.network(
        thumbnailUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackThumbnail(message);
        },
      );
    }

    // 如果有媒体URL，尝试加载网络图片
    if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) {
      return Image.network(
        message.mediaUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackThumbnail(message);
        },
      );
    }

    // 兜底方案
    return _buildFallbackThumbnail(message);
  }

  /// 构建兜底缩略图
  Widget _buildFallbackThumbnail(Message message) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            message.type == MessageType.image ? Icons.image : Icons.videocam,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            message.type == MessageType.image ? '图片' : '视频',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 💢💢💢 新增：构建消息项组件
  Widget _buildMessageItem(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 根据消息类型显示不同的图标
          _buildMessageIcon(message),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMessageDisplayName(message),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getMessageSubInfo(message),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildMessageAction(message),
        ],
      ),
    );
  }

  /// 构建消息图标
  Widget _buildMessageIcon(Message message) {
    Color iconColor;
    IconData iconData;
    Color backgroundColor;

    switch (message.type) {
      case MessageType.image:
        iconData = Icons.image;
        iconColor = Colors.blue[700]!;
        backgroundColor = Colors.blue[100]!;
        break;
      case MessageType.video:
        iconData = Icons.videocam;
        iconColor = Colors.purple[700]!;
        backgroundColor = Colors.purple[100]!;
        break;
      case MessageType.voice:
        iconData = Icons.mic;
        iconColor = Colors.green[700]!;
        backgroundColor = Colors.green[100]!;
        break;
      case MessageType.file:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.orange[700]!;
        backgroundColor = Colors.orange[100]!;
        break;
      default: // 链接消息（文本类型但包含链接）
        iconData = Icons.link;
        iconColor = Colors.blue[700]!;
        backgroundColor = Colors.blue[100]!;
        break;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  /// 获取消息显示名称
  String _getMessageDisplayName(Message message) {
    switch (message.type) {
      case MessageType.image:
        return message.fileName ?? 'image.jpg';
      case MessageType.video:
        return message.fileName ?? 'video.mp4';
      case MessageType.voice:
        final duration = message.duration ?? 0;
        return '语音消息 ${_formatDuration(duration.toDouble() / 1000)}';
      case MessageType.file:
        return message.fileName ?? 'file';
      default: // 链接消息
        if (message.text != null && message.text!.contains('http')) {
          // 提取第一个链接
          final urlRegex = RegExp(r'https?://[^\s]+');
          final match = urlRegex.firstMatch(message.text!);
          return match?.group(0) ?? message.text!;
        }
        return message.text ?? '链接';
    }
  }

  /// 获取消息附加信息
  String _getMessageSubInfo(Message message) {
    final dateStr = _formatMessageDate(message.createdAt);

    switch (message.type) {
      case MessageType.image:
      case MessageType.video:
      case MessageType.file:
        final sizeStr = message.fileSize != null
            ? _formatFileSize(message.fileSize!.toInt())
            : '';
        return sizeStr.isNotEmpty ? '$sizeStr • $dateStr' : dateStr;
      case MessageType.voice:
        final duration = message.duration ?? 0;
        return '${_formatDuration(duration.toDouble() / 1000)} • $dateStr';
      default: // 链接消息
        return dateStr;
    }
  }

  /// 构建消息操作按钮
  Widget _buildMessageAction(Message message) {
    return Icon(
      _getActionIcon(message.type),
      color: Colors.grey[600],
      size: 20,
    );
  }

  /// 获取操作图标
  IconData _getActionIcon(MessageType type) {
    switch (type) {
      case MessageType.image:
      case MessageType.video:
        return Icons.visibility;
      case MessageType.voice:
        return Icons.play_arrow;
      case MessageType.file:
        return Icons.download;
      default: // 链接
        return Icons.open_in_new;
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// 格式化语音时长
  String _formatDuration(double seconds) {
    final secondsInt = seconds.round();
    final minutes = secondsInt ~/ 60;
    final remainingSeconds = secondsInt % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 格式化消息日期
  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
