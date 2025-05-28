import 'search_page.dart';
import 'scan_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:cc/features/home/presentation/widgets/network_status_indicator.dart';
import 'package:cc/features/home/presentation/widgets/conversation_item.dart';
import 'package:cc/core/database/models/conversation.dart';

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

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 搜索会话
  ///
  /// 根据输入的查询文本搜索匹配的会话
  /// 如果查询为空，则显示所有会话
  ///
  /// 参数:
  ///   - query: 搜索关键词
  void _searchConversations(String query) {
    // 使用 HomeCubit 中的搜索方法
    final homeCubit = context.read<HomeCubit>();
    homeCubit.searchConversations(query);
    _logger.i('执行搜索: $query');
  }

  // 已移除 _handleRemovedConversations 方法，因为在使用 Cubit 后不再需要手动处理删除操作

  // 已移除 _handleUpdatedConversations 方法，因为在使用 Cubit 后不再需要手动处理更新操作

  // 移除了 _sortConversations 方法，因为这个逻辑已经移到 HomeCubit 中

  // 已移除 _insertItem 和 _removeItem 方法，因为在使用 SliverList 后不再需要这些方法

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is required by AutomaticKeepAliveClientMixin
    _logger.d('ChatsPage build');
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        // 优化buildWhen条件，减少不必要的重建
        // 1. 会话数量变化
        final conversationsChanged = previous.filteredConversations.length !=
            current.filteredConversations.length;

        // 2. 有更新的会话ID
        final hasUpdates = current.updatedConversationIds.isNotEmpty;

        // 3. 有删除的会话ID
        final hasRemovals = current.removedConversationIds.isNotEmpty;

        // 4. 联系人列表变化
        final contactsChanged = previous.contacts != current.contacts;

        // 5. 选中的标签变化
        final tabChanged =
            previous.selectedTabIndex != current.selectedTabIndex;

        // 6. 搜索查询变化
        final searchChanged = previous.searchQuery != current.searchQuery;

        return conversationsChanged ||
            hasUpdates ||
            hasRemovals ||
            contactsChanged ||
            tabChanged ||
            searchChanged;
      },
      builder: (context, state) {
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
              controller: _scrollController,
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

                // 使用多个 Sliver 组件
                ..._buildChatListSlivers(state),
              ],
            ),
          ),
        );
      },
    );
  }

  // 移除了 _filterConversationsByTab 方法，因为这个逻辑已经移到 HomeCubit 中

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
    final homeCubit = context.read<HomeCubit>();
    final isSelected = homeCubit.state.selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        // 使用 HomeCubit 中的方法切换标签
        homeCubit.switchTab(index);
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
                          // 清除搜索框并重置搜索状态
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                          });
                          // 清除搜索并重置过滤器
                          context.read<HomeCubit>().searchConversations('');
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
                // 实时搜索
                _searchConversations(value);
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
                  // 收起键盘但保持聚焦
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

  /// 构建聊天列表的 Sliver 组件
  /// 返回多个 Sliver 组件组成的列表
  List<Widget> _buildChatListSlivers(HomeState state) {
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return [
        SliverFillRemaining(
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
                    // TODO: context.read<HomeCubit>().loadConversations();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (state.filteredConversations.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  state.searchQuery.isNotEmpty ? '没有找到匹配的会话' : '没有会话',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                if (state.searchQuery.isEmpty)
                  ElevatedButton(
                    onPressed: () {
                      _showNewChatOptions();
                    },
                    child: const Text('新建会话'),
                  ),
              ],
            ),
          ),
        ),
      ];
    }

    // 分离置顶和非置顶会话
    final pinnedConversations = <Conversation>[];
    final unpinnedConversations = <Conversation>[];

    for (final conversation in state.filteredConversations) {
      if (conversation.isPinned) {
        pinnedConversations.add(conversation);
      } else {
        unpinnedConversations.add(conversation);
      }
    }

    // 构建多个 Sliver 组件
    final List<Widget> slivers = [];

    // 置顶会话部分
    if (pinnedConversations.isNotEmpty) {
      // 置顶会话列表
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final conversation = pinnedConversations[index];

              // 查找对应的联系人
              final contact = _findContactForConversation(state, conversation);

              return ConversationItem(
                key: ValueKey('pinned_${conversation.conversationId}'),
                conversation: conversation,
                contact: contact,
                formatTimeCallback: _formatTime,
                formatUnreadCountCallback: _formatUnreadCount,
              );
            },
            childCount: pinnedConversations.length,
          ),
        ),
      );
    }

    // 非置顶会话列表
    if (unpinnedConversations.isNotEmpty) {
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final conversation = unpinnedConversations[index];

              // 查找对应的联系人
              final contact = _findContactForConversation(state, conversation);

              return ConversationItem(
                key: ValueKey(conversation.conversationId),
                conversation: conversation,
                contact: contact,
                formatTimeCallback: _formatTime,
                formatUnreadCountCallback: _formatUnreadCount,
              );
            },
            childCount: unpinnedConversations.length,
          ),
        ),
      );
    }

    // 直接返回 sliver 数组
    return slivers;
  }

  /// 为会话查找对应的联系人
  User _findContactForConversation(HomeState state, Conversation conversation) {
    return state.contacts.firstWhere(
      (c) => c.userId == conversation.contactUserId,
      orElse: () => User()
        ..name = conversation.name ?? '未知联系人'
        ..avatar = conversation.avatar,
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
