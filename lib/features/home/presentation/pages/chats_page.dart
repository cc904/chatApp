import 'search_page.dart';
import 'scan_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';

/// 消息页面
///
/// 显示所有聊天会话列表，是应用程序的主要入口页面之一
/// 包含搜索、筛选和新建聊天等核心功能
class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage>
    with AutomaticKeepAliveClientMixin {
  /// 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  /// 搜索框焦点节点
  final FocusNode _searchFocusNode = FocusNode();

  /// 日志服务实例
  final _logger = LogService.instance;

  /// 是否处于搜索状态
  bool _isSearching = false;

  /// 过滤后的会话列表数据
  List<Conversation> _filteredConversations = [];

  /// 当前打开的滑动菜单项ID
  String? _openedItemId;

  /// 动画列表的key
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
  }

  /// 搜索会话
  ///
  /// 根据输入的查询文本搜索匹配的会话
  /// 如果查询为空，则显示所有会话
  ///
  /// 参数:
  ///   - query: 搜索关键词
  void _searchConversations(String query) {
    final homeCubit = context.read<HomeCubit>();
    final allConversations = homeCubit.state.conversations;
    final allContacts = homeCubit.state.contacts;

    if (query.isEmpty) {
      setState(() {
        _filteredConversations = allConversations;
      });
      return;
    }

    try {
      // 搜索会话和联系人数据
      final lowercaseQuery = query.toLowerCase();

      // 根据联系人名称或会话内容搜索
      final filteredList = allConversations.where((conversation) {
        // 查找会话对应的联系人
        final contact = allContacts.firstWhere(
          (c) => c.userId == conversation.contactUserId,
          orElse: () => User()..name = '',
        );

        // 检查联系人名称、拼音和会话最后消息是否包含搜索关键词
        return contact.name.toLowerCase().contains(lowercaseQuery) ||
            (contact.pinyin?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (conversation.lastMessagePreview
                    ?.toLowerCase()
                    .contains(lowercaseQuery) ??
                false);
      }).toList();

      setState(() {
        _filteredConversations = filteredList;
      });

      _logger.i('搜索结果: ${filteredList.length} 个会话');
    } catch (e) {
      _logger.e('搜索会话出错', error: e);
      setState(() {
        _filteredConversations = allConversations;
      });
    }
  }

  /// 添加新会话时调用此方法
  void _insertItem(int index) {
    _listKey.currentState?.insertItem(index);
  }

  /// 删除会话时调用此方法
  void _removeItem(int index, Conversation conversation, User contact) {
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  contact.avatar != null ? NetworkImage(contact.avatar!) : null,
              child: contact.avatar == null ? Text(contact.name[0]) : null,
            ),
            title: Text(contact.name),
            subtitle: Text(conversation.lastMessagePreview ?? ''),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is required by AutomaticKeepAliveClientMixin
    _logger.d('ChatsPage build');
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.conversations != current.conversations ||
          previous.contacts != current.contacts,
      builder: (context, state) {
        // 更新过滤后的会话列表
        if (!_isSearching) {
          _filteredConversations = state.conversations;
        }

        return Scaffold(
          // AppBar: 自定义导航栏,包含标题、编辑按钮和新建聊天按钮
          appBar: _buildAppBar(),
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
            child: _buildChatList(state),
          ),
        );
      },
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // 中间标题
      title: const Text('消息', style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // 禁用默认返回按钮

      // 左侧筛选按钮
      leading: IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: _showFilterDialog,
      ),

      // 右侧操作按钮区域
      actions: [
        Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: const PopupMenuThemeData(
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
            constraints: const BoxConstraints(maxWidth: 145),
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 'scan') {
                _logger.d('打开扫一扫');
                _openQRScanner(context);
              } else if (value == 'group') {
                _logger.d('发起群聊');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              } else if (value == 'friend') {
                _logger.d('添加朋友');
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
      centerTitle: true,
    );
  }

  /// 构建搜索框
  Widget _buildSearchBox() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: '搜索',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                isDense: true,
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _isSearching = false;
                          });
                          // 清除后重新聚焦到搜索框
                          _searchFocusNode.requestFocus();
                        },
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                });
              },
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchConversations(value);
                }
                // 提交后重新聚焦到搜索框
                _searchFocusNode.requestFocus();
              },
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  final query = _searchController.text;
                  if (query.isNotEmpty) {
                    _searchConversations(query);
                  }
                  // 点击搜索后收起键盘但保持焦点
                  FocusScope.of(context).unfocus();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      _searchFocusNode.requestFocus();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text(
                  '搜索',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建聊天列表
  ///
  /// 根据当前状态(加载中/错误/空数据)构建不同的界面
  /// 正常状态下显示会话列表，每个项目显示联系人头像、名称、最后消息和时间
  ///
  /// 返回值:
  ///   - Widget: 构建的列表视图或状态提示视图
  Widget _buildChatList(HomeState state) {
    // 检查是否在初始化
    if (state.isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    // 检查是否有错误
    if (state.hasError) {
      return Center(child: Text('错误: ${state.errorMessage}'));
    }

    // 检查是否有会话
    if (_filteredConversations.isEmpty && !_isSearching) {
      return const Center(child: Text('没有会话'));
    }

    // 显示会话列表 - 使用AnimatedList替换ListView.builder
    return _isSearching && _filteredConversations.isEmpty
        ? Column(
            children: [
              _buildSearchBox(),
              const Expanded(
                child: Center(child: Text('没有找到匹配的会话')),
              ),
            ],
          )
        : ListView.builder(
            itemCount: _filteredConversations.length + 1, // +1 for search box
            itemBuilder: (context, index) {
              _logger.d('index: $index');
              // 第一个项目是搜索框
              if (index == 0) {
                return _buildSearchBox();
              }

              // 调整索引以获取正确的会话
              final conversationIndex = index - 1;
              if (conversationIndex >= _filteredConversations.length) {
                return null; // 防止越界
              }

              final conversation = _filteredConversations[conversationIndex];
              final contact = state.contacts.firstWhere(
                (c) => c.userId == conversation.contactUserId,
                orElse: () => User()..name = '未知用户',
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: contact.avatar != null
                      ? NetworkImage(contact.avatar!)
                      : null,
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
                  // 使用HomeCubit加载会话消息
                  final homeCubit = context.read<HomeCubit>();
                  homeCubit
                      .loadMessagesForConversation(conversation.conversationId);

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
                },
              );
            },
          );
  }

  /// 格式化消息时间
  ///
  /// 将时间戳转换为用户友好的显示格式:
  /// - 今天的消息显示时:分
  /// - 昨天的消息显示"昨天"
  /// - 一周内的消息显示"x天前"
  /// - 更早的消息显示月/日
  ///
  /// 参数:
  ///   - time: 需要格式化的时间
  ///
  /// 返回值:
  ///   - String: 格式化后的时间字符串
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

  /// 显示筛选对话框
  ///
  /// 弹出底部模态对话框，提供会话筛选选项:
  /// - 筛选未读消息
  /// - 筛选群聊
  /// - 筛选星标会话
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

  /// 打开二维码扫描页面
  ///
  /// 导航到扫码页面，用于扫描二维码添加好友或加入群聊
  ///
  /// 参数:
  ///   - context: 当前构建上下文
  void _openQRScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScanCodePage(),
      ),
    );
  }

  /// 构建弹出菜单项
  ///
  /// 创建自定义样式的PopupMenuItem，用于添加功能菜单
  ///
  /// 参数:
  ///   - value: 菜单项的值，用于标识被选中的项
  ///   - iconData: 菜单项的图标
  ///   - label: 菜单项的文本标签
  ///
  /// 返回值:
  ///   - PopupMenuItem<String>: 构建的菜单项
  PopupMenuItem<String> _buildMenuItem(
      String value, IconData iconData, String label) {
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
