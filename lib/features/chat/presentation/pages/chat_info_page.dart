import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/services/ui_notification_service.dart';
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

class _ChatInfoPageState extends State<ChatInfoPage>
    with SingleTickerProviderStateMixin {
  final _logger = LogService.instance;
  // 模拟属性值,实际应该保存在数据库中
  bool _isMuted = false;
  // 静音按钮动画控制器
  late AnimationController _muteAnimController;
  late Animation<double> _rotateAnimation;

  // 添加编辑模式状态
  bool _isEditMode = false;

  // 添加文本编辑控制器
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

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
        final chatsCubit = context.read<ChatsCubit>();
        final conversation = chatsCubit.state.conversations.firstWhere(
          (c) => c.conversationId == widget.conversationId,
          orElse: () => Conversation(),
        );

        setState(() {
          _isMuted = conversation.isMuted;
          if (_isMuted) {
            _muteAnimController.value = 1.0; // 直接设置到终点
          }
        });
      }
    });

    // 初始化文本编辑控制器
    if (widget.contact != null) {
      final nameParts = widget.contact.name.split(' ');
      if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          _lastNameController.text = nameParts.sublist(1).join(' ');
        }
      }
    }
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
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _muteAnimController.forward();
      } else {
        _muteAnimController.reverse();
      }
    });

    UINotificationService().showSuccess(_isMuted ? '已开启静音' : '已关闭静音');
    _logger.i('切换静音状态', extra: {'isMuted': _isMuted});

    // 更新数据库中的静音状态
    final chatsCubit = context.read<ChatsCubit>();
    chatsCubit.updateConversationMuteStatus(widget.conversationId, _isMuted);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        // 获取当前会话
        final conversation = state.conversations.firstWhere(
          (c) => c.conversationId == widget.conversationId,
          orElse: () => Conversation()..name = '未知会话',
        );

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
                    if (widget.contact != null) {
                      final nameParts = widget.contact.name.split(' ');
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
                UserAvatar(
                  avatarUrl: widget.contact?.avatar,
                  name: widget.contact?.name ?? '?',
                  radius: 50,
                  backgroundColor: Colors.cyan,
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

          // 操作按钮区域 - 修改为直接在背景上的按钮
          _buildActionButtons(),

          const SizedBox(height: 30),

          // 手机号码区域 - 修改为显示用户ID
          _buildPhoneSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 头像和名称区域 - 移除白色背景
  Widget _buildProfileHeader(Conversation conversation) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Column(
        children: [
          // 头像
          Hero(
            tag: 'avatar_${widget.conversationId}',
            child: UserAvatar(
              avatarUrl: widget.contact?.avatar,
              name: widget.contact?.name ?? '?',
              radius: 50,
              backgroundColor: Colors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // 名称
          Hero(
            tag: 'name_${widget.conversationId}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.contact?.name ?? conversation.name ?? '未知联系人',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          _buildMuteButton(),
          _buildActionButton(Icons.search, 'search', Colors.blue),
          _buildMoreButton(),
        ],
      ),
    );
  }

  // 静音按钮 - 带有动画效果
  Widget _buildMuteButton() {
    // 计算一个按钮占据的宽度 (总宽度减去4个8px的间隙，再除以5)
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 32) / 5;

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
                    child: Text(
                      _isMuted ? 'unmute' : 'mute',
                      key: ValueKey<bool>(_isMuted),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
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
                                    color: Colors.blue.withAlpha(26),
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
    final conversationId = widget.conversationId;
    final chatsCubit = context.read<ChatsCubit>();
    chatsCubit.state.conversations.firstWhere(
      (c) => c.conversationId == conversationId,
      orElse: () => Conversation(),
    );

    final title = isGroup ? '删除并退出' : '删除联系人';
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
              // TODO 实现删除会话功能
              // 需要在HomeCubit中添加对应方法
              UINotificationService().showSuccess(isGroup ? '已退出群聊' : '已删除联系人');
              // 返回上一级
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 打开聊天记录搜索页面
}
