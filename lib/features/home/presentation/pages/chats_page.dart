import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'search_page.dart';
import 'scan_code_page.dart';
import 'package:cc/core/database/models/user.dart';

class ChatsPage extends StatefulWidget {
  final List<User> contacts;

  const ChatsPage({
    super.key,
    required this.contacts,
  });

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  bool _isSearching = false;
  // 跟踪当前打开的滑动项的ID
  String? _openedItemId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    await context.read<ChatCubit>().loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('ChatsPage build');
    return Scaffold(
      // AppBar: 自定义导航栏,包含标题、编辑按钮和新建聊天按钮
      // 顶部导航区配置了底部搜索栏作为扩展部分
      appBar: AppBar(
        // 中间标题
        title: const Text('消息', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 禁用默认返回按钮

        // 左侧筛选按钮
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // 显示筛选选项
            _showFilterDialog();
          },
        ),

        // 右侧操作按钮区域 - 添加新聊天按钮
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              // 设置弹出菜单的主题
              popupMenuTheme: const PopupMenuThemeData(
                // 强制控制菜单的宽度
                textStyle: TextStyle(fontSize: 14),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              offset: const Offset(0, 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              // 设置菜单的总宽度
              constraints: const BoxConstraints(maxWidth: 145),
              // 修改菜单位置
              position: PopupMenuPosition.under,
              // 调整项目宽度自适应内容
              onSelected: (value) {
                if (value == 'scan') {
                  // 扫一扫功能
                  _logger.d('打开扫一扫');
                  _openQRScanner(context);
                } else if (value == 'group') {
                  // 发起群聊
                  _logger.d('发起群聊');
                  // 打开搜索页面,默认选择找群标签
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                } else if (value == 'friend') {
                  // 添加朋友
                  _logger.d('添加朋友');
                  // 打开搜索页面,默认选择找人标签
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                _buildMenuItem('friend', Icons.person_add, '添加朋友或群'),
                const PopupMenuDivider(height: 0.5),
                _buildMenuItem('group', Icons.group_add, '发起群聊'),
                const PopupMenuDivider(height: 0.5),
                _buildMenuItem('scan', Icons.qr_code_scanner, '扫一扫'),
              ],
            ),
          ),
        ],
        centerTitle: true, // 标题居中显示

        // 底部搜索区域
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // 设置底部区域高度
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '搜索',
                hintStyle: const TextStyle(color: Colors.grey),
                // 删除搜索图标
                prefixIcon: null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                isDense: true,
                // 因为删除了外层Container,需要添加圆角和背景颜色
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
                // 当有输入内容时显示清除按钮和搜索按钮
                suffixIcon: _isSearching
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isSearching = false;
                              });
                            },
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: Colors.grey[300],
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                // 执行搜索
                                final query = _searchController.text;
                                if (query.isNotEmpty) {
                                  context.read<ChatCubit>().searchConversations(query);
                                }
                                // 隐藏键盘
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '搜索',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                });
                // 搜索内容变化时实时搜索
                if (value.isNotEmpty) {
                  context.read<ChatCubit>().searchConversations(value);
                }
              },
            ),
          ),
        ),
      ),
      // 聊天列表主体
      body: GestureDetector(
        // 点击空白区域时关闭打开的滑动菜单
        onTap: () {
          if (_openedItemId != null) {
            setState(() {
              _openedItemId = null;
            });
          }
        },
        child: _buildChatList(),
      ),
    );
  }

  // 构建聊天列表,添加空状态处理
  Widget _buildChatList() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text('错误: ${state.error}'));
        }

        if (state.conversations.isEmpty) {
          return const Center(child: Text('没有会话'));
        }

        return ListView.builder(
          itemCount: state.conversations.length,
          itemBuilder: (context, index) {
            final conversation = state.conversations[index];
            final contact = widget.contacts.firstWhere(
              (c) => c.userId == conversation.contactUserId,
              orElse: () => User()..name = '未知用户',
            );

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
                child: contact.avatar == null ? Text(contact.name[0]) : null,
              ),
              title: Text(contact.name),
              subtitle: Text(conversation.lastMessagePreview ?? ''),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(conversation.lastMessageTime),
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                final chatCubit = context.read<ChatCubit>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: chatCubit,
                      child: ChatDetailPage(
                        conversationId: conversation.conversationId,
                        contact: contact,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // 格式化消息时间
  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '筛选会话',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('未读消息'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选未读消息');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('群聊'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选群聊');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.green),
              title: const Text('星标会话'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选星标会话');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openQRScanner(BuildContext context) {
    // 导航到二维码扫描页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScanCodePage(),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData iconData, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
