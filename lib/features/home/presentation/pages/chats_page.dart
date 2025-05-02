import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'search_page.dart';
import 'scan_code_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  // 跟踪当前打开的滑动项的ID
  String? _openedItemId;

  @override
  void initState() {
    super.initState();
    // 加载会话数据
    _loadConversations();
  }

  void _loadConversations() async {
    // 使用ChatCubit加载会话
    final chatCubit = context.read<ChatCubit>();
    await chatCubit.loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('ChatsPage build');
    return Scaffold(
      // AppBar: 自定义导航栏，包含标题、编辑按钮和新建聊天按钮
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
                  dev.log('打开扫一扫');
                  _openQRScanner(context);
                } else if (value == 'group') {
                  // 发起群聊
                  dev.log('发起群聊');
                  // 打开搜索页面，默认选择找群标签
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                } else if (value == 'friend') {
                  // 添加朋友
                  dev.log('添加朋友');
                  // 打开搜索页面，默认选择找人标签
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
                // 因为删除了外层Container，需要添加圆角和背景颜色
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

  // 构建聊天列表，添加空状态处理
  Widget _buildChatList() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text('错误: ${state.error}'));
        }

        // 获取要显示的会话列表 - 搜索结果或所有会话
        final List<Conversation> conversations = _isSearching && state.searchQuery != null ? (state.searchResults.whereType<Conversation>().toList()) : state.conversations;

        // 如果会话列表为空，显示空状态视图
        if (conversations.isEmpty) {
          return _buildEmptyState();
        }

        // 显示会话列表
        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 72,
          ),
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final itemId = conversation.id.toString();

            return _buildSwipeableItem(
              id: itemId,
              conversation: conversation,
              isOpen: _openedItemId == itemId,
            );
          },
        );
      },
    );
  }

  // 构建空状态视图
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无聊天消息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角按钮开始新的聊天',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // 构建可滑动的聊天项
  Widget _buildSwipeableItem({
    required String id,
    required Conversation conversation,
    required bool isOpen,
  }) {
    // 获取会话信息
    final String name = conversation.name ?? '未命名会话';
    final String message = conversation.lastMessagePreview ?? '暂无消息';
    final String time = _formatMessageTime(conversation.lastMessageTime);
    final int unreadCount = conversation.unreadCount;
    final String avatarUrl = conversation.avatar ?? 'https://picsum.photos/200?random=${conversation.id}';

    // 菜单宽度
    const double menuWidth = 180; // 三个按钮的总宽度

    return Stack(
      children: [
        // 1. 操作菜单背景
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Container(
            width: menuWidth,
            color: Colors.grey[100],
            child: Row(
              children: [
                // 已读/未读按钮
                GestureDetector(
                  onTap: () {
                    dev.log(unreadCount > 0 ? '将$name标为已读' : '将$name标为未读');
                    if (unreadCount > 0) {
                      context.read<ChatCubit>().markConversationAsRead(id);
                    }
                    setState(() {
                      _openedItemId = null; // 操作后关闭菜单
                    });
                  },
                  child: Container(
                    width: 60,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 0 ? '已读' : '未读',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                // 不显示按钮
                GestureDetector(
                  onTap: () {
                    dev.log('不显示聊天: $name');
                    setState(() {
                      _openedItemId = null; // 操作后关闭菜单
                    });
                  },
                  child: Container(
                    width: 60,
                    color: Colors.orange,
                    alignment: Alignment.center,
                    child: const Text(
                      '不显示',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                // 删除按钮
                GestureDetector(
                  onTap: () {
                    dev.log('删除聊天: $name');
                    context.read<ChatCubit>().deleteConversation(id);
                    setState(() {
                      _openedItemId = null; // 操作后关闭菜单
                    });
                  },
                  child: Container(
                    width: 60,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: const Text(
                      '删除',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. 可滑动的前景内容
        AnimatedContainer(
          duration: const Duration(milliseconds: 250), // 添加动画效果
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            isOpen ? -menuWidth : 0, // 如果打开则向左移动菜单宽度
            0,
            0,
          ),
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              // 开始拖动时，如果有其他项目已打开，先关闭它
              if (_openedItemId != null && _openedItemId != id) {
                setState(() {
                  _openedItemId = null;
                });
              }
            },
            onHorizontalDragUpdate: (details) {
              // 跟踪水平拖动，仅允许向左拖动（负增量）
              if (details.delta.dx < 0) {
                setState(() {
                  _openedItemId = id; // 向左拖动时打开当前项
                });
              } else if (details.delta.dx > 0 && _openedItemId == id) {
                // 向右拖动时关闭当前项
                setState(() {
                  _openedItemId = null;
                });
              }
            },
            onHorizontalDragEnd: (details) {
              // 拖动结束时，根据速度决定是否打开或关闭
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -500) {
                  // 快速向左滑动，打开菜单
                  setState(() {
                    _openedItemId = id;
                  });
                } else if (details.primaryVelocity! > 500) {
                  // 快速向右滑动，关闭菜单
                  setState(() {
                    _openedItemId = null;
                  });
                }
              }
            },
            child: Container(
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: _getAvatarImage(avatarUrl),
                  backgroundColor: Colors.green[100],
                  radius: 24,
                  child: avatarUrl.isEmpty || avatarUrl.startsWith('https://picsum.photos')
                      ? Text(
                          conversation.avatarText,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: unreadCount > 0 ? Colors.green : Colors.grey,
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 16),
                  ],
                ),
                onTap: () {
                  // 如果菜单是打开的，则先关闭菜单
                  if (_openedItemId == id) {
                    setState(() {
                      _openedItemId = null;
                    });
                  } else {
                    // 打开聊天详情页
                    dev.log('打开聊天: $name (ID: $id)');
                    context.read<ChatCubit>().setCurrentConversation(id);

                    // 导航到聊天详情页
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatDetailPage(conversationId: id),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 获取头像图片
  ImageProvider _getAvatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }

    return NetworkImage(avatarUrl);
  }

  // 格式化消息时间
  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // 今天的消息显示时间
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      // 昨天的消息
      return '昨天';
    } else if (now.difference(dateTime).inDays < 7) {
      // 本周内的消息显示星期
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[dateTime.weekday - 1];
    } else {
      // 超过一周的消息显示日期
      return '${dateTime.month}-${dateTime.day}';
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
                dev.log('筛选未读消息');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('群聊'),
              onTap: () {
                Navigator.pop(context);
                dev.log('筛选群聊');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.green),
              title: const Text('星标会话'),
              onTap: () {
                Navigator.pop(context);
                dev.log('筛选星标会话');
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
