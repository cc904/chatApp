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
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/home/presentation/widgets/network_status_indicator.dart';

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

  /// 动画列表的key
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// 当前选中的标签索引
  int _selectedTabIndex = 0;

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
            leading: UserAvatar(
              avatarUrl: contact.avatar,
              name: contact.name,
              radius: 20,
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
          _filteredConversations =
              _filterConversationsByTab(state.conversations);
        }

        return Scaffold(
          // AppBar: 自定义导航栏,包含标题、编辑按钮和新建聊天按钮
          appBar: _buildAppBar(),
          // 使用CustomScrollView实现滚动列表
          body: GestureDetector(
            // 点击空白区域可以关闭键盘等
            onTap: () {
              // 关闭键盘
              FocusScope.of(context).unfocus();
            },
            child: CustomScrollView(
              slivers: [
                // 可折叠的搜索栏
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.grey[200],
                  title: _buildSearchBox(),
                  titleSpacing: 0,
                ),

                // 固定的标签栏
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    child: _buildTabBar(),
                  ),
                  pinned: true,
                ),

                // 使用SliverList替代ListView
                _buildChatListSliver(state),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 根据选中的标签过滤会话
  List<Conversation> _filterConversationsByTab(
      List<Conversation> conversations) {
    // 根据标签类型过滤会话
    List<Conversation> filteredList;

    switch (_selectedTabIndex) {
      case 0: // All Chats
        filteredList = conversations;
      case 1: // 私密
        filteredList = conversations
            .where((c) => c.type == ConversationType.private)
            .toList();
      case 2: // 群组
        filteredList = conversations
            .where((c) => c.type == ConversationType.group)
            .toList();
      case 3: // 频道
        filteredList = conversations
            .where((c) => c.type == ConversationType.channel)
            .toList();
      case 4: // 未读
        filteredList = conversations.where((c) => c.unreadCount > 0).toList();
      default:
        filteredList = conversations;
    }

    // 分离置顶会话和非置顶会话
    final pinnedConversations = filteredList.where((c) => c.isPinned).toList();
    final unpinnedConversations =
        filteredList.where((c) => !c.isPinned).toList();

    // 置顶会话按最后消息时间排序，没有lastMessageTime的放在最后
    pinnedConversations.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt); // 都没有lastMessageTime，按创建时间排序
      } else if (a.lastMessageTime == null) {
        return 1; // a没有lastMessageTime，排在后面
      } else if (b.lastMessageTime == null) {
        return -1; // b没有lastMessageTime，a排在前面
      }
      return b.lastMessageTime!
          .compareTo(a.lastMessageTime!); // 都有lastMessageTime，按时间降序
    });

    // 非置顶会话按最后消息时间排序，没有lastMessageTime的放在最后
    unpinnedConversations.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt); // 都没有lastMessageTime，按创建时间排序
      } else if (a.lastMessageTime == null) {
        return 1; // a没有lastMessageTime，排在后面
      } else if (b.lastMessageTime == null) {
        return -1; // b没有lastMessageTime，a排在前面
      }
      return b.lastMessageTime!
          .compareTo(a.lastMessageTime!); // 都有lastMessageTime，按时间降序
    });

    // 合并两个列表，置顶会话在前面
    return [...pinnedConversations, ...unpinnedConversations];
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabItem('All Chats', 0, null),
            _buildTabItem('私密', 1, null),
            _buildTabItem('群组', 2, 2),
            _buildTabItem('频道', 3, 3),
            _buildTabItem('未读', 4, 5),
          ],
        ),
      ),
    );
  }

  /// 构建单个标签项
  Widget _buildTabItem(String title, int index, int? count) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          // 切换标签后更新过滤的会话列表
          _filteredConversations = _filterConversationsByTab(
              context.read<HomeCubit>().state.conversations);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 使用 DefaultTextStyle.merge 确保文本在选中和非选中状态下保持相同宽度
            DefaultTextStyle.merge(
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold, // 始终使用粗体，但通过不同的透明度区分选中状态
                fontSize: 14,
              ),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.8, // 非选中时稍微降低透明度
                child: Text(title),
              ),
            ),
            if (count != null)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // 中间标题
      title: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) =>
            previous.networkStatus != current.networkStatus ||
            previous.isLoadingMessages != current.isLoadingMessages,
        builder: (context, state) {
          return AppBarTitleWithNetworkStatus(
            title: 'Chats',
            networkStatus: state.networkStatus,
            isLoading: state.isLoadingMessages,
            onRetry: () => context.read<HomeCubit>().reconnect(),
          );
        },
      ),
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false, // 禁用默认返回按钮

      // 左侧编辑按钮
      leading: TextButton(
        onPressed: () {
          // 处理编辑操作
          _logger.d('编辑按钮点击');
        },
        child: const Text(
          'Edit',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 右侧操作按钮区域
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: () {
            _logger.d('添加会话按钮点击');
            // 打开创建新会话选项
            _showNewChatOptions();
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit_square, color: Colors.blue),
          onPressed: () {
            _logger.d('编辑会话按钮点击');
            // 处理编辑操作
          },
        ),
      ],
      centerTitle: true,
    );
  }

  /// 显示新建会话选项
  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新建会话',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('添加好友'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add, color: Colors.blue),
              title: const Text('创建群组'),
              onTap: () {
                Navigator.pop(context);
                // 导航到创建群组页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              title: const Text('扫一扫'),
              onTap: () {
                Navigator.pop(context);
                _openQRScanner(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchBox() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
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
          // 当输入内容后显示搜索按钮
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  final query = _searchController.text;
                  if (query.isNotEmpty) {
                    _searchConversations(query);
                  }
                  // 收起键盘但保持焦点
                  FocusScope.of(context).unfocus();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      _searchFocusNode.requestFocus();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

  /// 构建聊天列表（SliverList版本）
  ///
  /// 根据当前状态(加载中/错误/空数据)构建不同的界面
  /// 正常状态下显示会话列表，每个项目显示联系人头像、名称、最后消息和时间
  ///
  /// 返回值:
  ///   - Widget: 构建的SliverList或其他Sliver组件
  Widget _buildChatListSliver(HomeState state) {
    if (state.isLoadingMessages) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '加载失败: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeCubit>().loadConversations();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredConversations.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '没有会话',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showNewChatOptions();
                },
                child: const Text('新建会话'),
              ),
            ],
          ),
        ),
      );
    }

    // 分离置顶和非置顶会话
    final pinnedConversations =
        _filteredConversations.where((c) => c.isPinned).toList();
    final unpinnedConversations =
        _filteredConversations.where((c) => !c.isPinned).toList();

    // 重新排序会话列表，置顶会话在前
    _filteredConversations = [...pinnedConversations, ...unpinnedConversations];

    // 准备列表项
    final List<Widget> items = [];

    // 如果有置顶会话，添加一个置顶标签
    if (pinnedConversations.isNotEmpty) {
      items.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey[200],
          child: Row(
            children: [
              const Icon(Icons.push_pin, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('置顶会话',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
              const Spacer(),
              Text('${pinnedConversations.length} 个',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // 添加所有会话项
    for (int i = 0; i < _filteredConversations.length; i++) {
      final conversation = _filteredConversations[i];

      // 查找对应的联系人
      final contact = state.contacts.firstWhere(
        (c) => c.userId == conversation.contactUserId,
        orElse: () => User()
          ..name = conversation.name ?? '未知联系人'
          ..avatar = conversation.avatar,
      );

      items.add(_buildConversationItem(conversation, contact));
    }

    // 返回SliverList
    return SliverList(
      delegate: SliverChildListDelegate(items),
    );
  }

  /// 构建单个会话项
  Widget _buildConversationItem(Conversation conversation, User contact) {
    // _logger.d('创建会话Item: ${contact.name} ${contact.avatar}');
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

    // 头像大小 - 与三行内容高度匹配
    const double avatarSize = 60.0;

    return Column(
      children: [
        Material(
          color: Colors.transparent, // 使用透明背景
          child: InkWell(
            onTap: () {
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
            },
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
                  Padding(
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
                  ),

                  // 中间内容区域
                  Expanded(
                    child: SizedBox(
                      height: avatarSize + 1, // 与头像高度一致
                      child: Builder(builder: (context) {
                        // 根据会话类型选择不同的内容布局
                        switch (conversation.type) {
                          case ConversationType.private:
                            // 私聊布局
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
                                              padding:
                                                  EdgeInsets.only(right: 4.0),
                                              child: Icon(
                                                Icons.push_pin,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          Flexible(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Text(
                                                contact.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          if (isMuted)
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 4.0),
                                              child: Icon(Icons.volume_off,
                                                  size: 16, color: Colors.grey),
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
                          // 群聊布局
                          case ConversationType.group:
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
                                              padding:
                                                  EdgeInsets.only(right: 4.0),
                                              child: Icon(
                                                Icons.push_pin,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          Flexible(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Text(
                                                conversation.name ?? '名称错误',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          if (isMuted)
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 4.0),
                                              child: Icon(Icons.volume_off,
                                                  size: 16, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // 第二行：发送者名称
                                Text(
                                  senderName ?? '未知用户',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // 第三行：消息内容
                                Text(
                                  conversation.lastMessagePreview ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          // 频道布局
                          case ConversationType.channel:
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
                                              padding:
                                                  EdgeInsets.only(right: 4.0),
                                              child: Icon(
                                                Icons.push_pin,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          Flexible(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Text(
                                                conversation.name ?? '名称错误',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          if (isMuted)
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 4.0),
                                              child: Icon(Icons.volume_off,
                                                  size: 16, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // 第二行：发送者名称带图标
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.campaign,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        channelSenderInfo ?? '频道管理员',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                // 第三行：消息内容
                                Text(
                                  conversation.lastMessagePreview ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          // 所有的会话类型都已经处理过了，不需要默认情况
                        }
                      }),
                    ),
                  ),

                  // 右侧时间和未读数
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                    child: SizedBox(
                      height: avatarSize, // 与头像高度一致
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // 均匀分布
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 时间
                          Text(
                            _formatTime(conversation.lastMessageTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          // 未读数
                          if (conversation.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                // 根据 lastReadAt 和 lastMessageTime 比较决定颜色
                                // 如果 lastReadAt < lastMessageTime 或 lastReadAt 为空，保持蓝色
                                // 如果 lastReadAt > lastMessageTime，则使用灰色
                                color: (conversation.lastReadAt == null ||
                                        (conversation.lastMessageTime != null &&
                                            conversation.lastReadAt!.isBefore(
                                                conversation.lastMessageTime!)))
                                    ? Colors.blue
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                _formatUnreadCount(conversation.unreadCount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // 如果没有未读消息，添加一个空占位符以保持布局平衡
                          if (conversation.unreadCount <= 0)
                            const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 分割线 - 从头像右侧开始延伸
        Padding(
          padding: const EdgeInsets.only(left: 92.0),
          child: Container(
            height: 0.5,
            color: Colors.grey.withAlpha(77),
          ),
        ),
      ],
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

  /// 格式化未读消息数量
  /// 如果超过1000，则以k为单位显示，保留一位小数
  String _formatUnreadCount(int count) {
    if (count >= 1000) {
      final double countInK = count / 1000;
      return '${countInK.toStringAsFixed(1)}k';
    }
    return count.toString();
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
}

// 修改_SliverTabBarDelegate类
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[200],
      height: 44.0,
      child: child,
    );
  }

  @override
  double get maxExtent => 44.0;

  @override
  double get minExtent => 44.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
