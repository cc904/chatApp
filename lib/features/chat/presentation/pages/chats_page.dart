import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chats_state.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/core/widgets/connection_status_indicator.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/constants/app_colors.dart';

import 'package:cc/features/chat/presentation/widgets/new_conversation_bottom_sheet.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/core/database/database_initializer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/presentation/widgets/conversation_item.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'dart:async';

/// 消息页面
///
/// 显示所有聊天会话列表，是应用程序的主要入口页面之一
/// 包含搜索、筛选和新建聊天等核心功能
class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

/// 💢💢💢 全局的 RouteObserver，用于监听路由变化
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _ChatsPageState extends State<ChatsPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, RouteAware {
  @override
  bool get wantKeepAlive => true;

  /// 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  /// 搜索框焦点节点
  final FocusNode _searchFocusNode = FocusNode();

  /// 日志服务实例
  final _logger = LogService.instance;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 💢💢💢 页面是否可见状态标记
  bool _isPageVisible = true;

  /// 💢💢💢 最后一次同步时间
  DateTime? _lastSyncTime;

  /// 搜索会话
  ///
  /// 根据输入的查询文本搜索匹配的会话
  /// 如果查询为空，则显示所有会话
  ///
  /// 参数:
  ///   - query: 搜索关键词
  void _searchConversations(String query) {
    // 使用 ChatsCubit 中的搜索方法
    final chatsCubit = context.read<ChatsCubit>();
    chatsCubit.searchConversations(query);
    _logger.i('执行搜索: $query');
  }

  /// 当搜索框焦点变化时调用
  void _onSearchFocusChanged() {
    final chatsCubit = context.read<ChatsCubit>();
    if (_searchFocusNode.hasFocus) {
      // 获得焦点时开始搜索模式
      chatsCubit.startSearch();
    } else if (_searchController.text.isEmpty) {
      // 失去焦点且搜索框为空时结束搜索模式
      chatsCubit.endSearch();
    }
  }

  /// 当搜索框内容变化时调用
  void _onSearchChanged() {
    final query = _searchController.text;
    _searchConversations(query);
  }

  /// 初始化
  Future<void> _init() async {
    final chatsCubit = context.read<ChatsCubit>();
    await chatsCubit.loadConversations();
    await chatsCubit.requestSyncConversations();
    _lastSyncTime = DateTime.now();
  }

  /// 💢💢💢 页面重新显示时的同步检查
  ///
  /// 这是一个被动检查机制，只在页面重新显示或应用恢复前台时触发
  /// 检查规则：
  /// 1. 强制同步 (force = true)
  /// 2. 首次同步 (_lastSyncTime == null)
  /// 3. 距离上次同步超过30秒 (防止频繁同步)
  ///
  /// 注意：没有定时器后台运行，只在特定事件触发时才检查
  Future<void> _checkAndSync({bool force = false}) async {
    try {
      final now = DateTime.now();
      final shouldSync = force ||
          _lastSyncTime == null ||
          now.difference(_lastSyncTime!).inSeconds > 30;

      if (shouldSync) {
        _logger.i('ChatsPage 触发会话同步', extra: {
          'trigger': force
              ? 'force'
              : _lastSyncTime == null
                  ? 'first_time'
                  : 'time_interval',
          'force': force,
          'lastSyncTime': _lastSyncTime?.toIso8601String(),
          'timeSinceLastSync': _lastSyncTime != null
              ? now.difference(_lastSyncTime!).inSeconds
              : null,
        });

        final chatsCubit = context.read<ChatsCubit>();
        await chatsCubit.requestSyncConversations();
        _lastSyncTime = now;
      } else {
        _logger.d('ChatsPage 跳过同步，距离上次同步时间较短');
      }
    } catch (e) {
      _logger.e('ChatsPage 同步检查失败', error: e);
    }
  }

  @override
  void initState() {
    super.initState();

    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);

    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 💢💢💢 注册 RouteObserver
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }

    _logger.d('ChatsPage didChangeDependencies 触发', extra: {
      'isPageVisible': _isPageVisible,
      'mounted': mounted,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
    });

    // 移除强制同步，专注于诊断真正的触发机制
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 💢💢💢 应用从后台恢复时触发同步
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _logger.i('应用从后台恢复，ChatsPage 检查是否需要同步');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 💢💢💢 重要：检查当前是否是可见的Tab页面
          // ChatsPage是索引0，只有当前Tab索引为0时才执行同步
          try {
            final homeCubit = context.read<HomeCubit>();
            final currentTabIndex = homeCubit.state.currentTabIndex;
            final isCurrentTabVisible = currentTabIndex == 0;
            
            _logger.i('ChatsPage 应用恢复检查可见性', extra: {
              'currentTabIndex': currentTabIndex,
              'isChatsTabVisible': isCurrentTabVisible,
              'shouldSync': isCurrentTabVisible,
            });

            if (isCurrentTabVisible) {
              _logger.i('ChatsPage 当前可见且应用恢复，执行同步');
              _checkAndSync(force: true);
            } else {
              _logger.d('ChatsPage 当前不可见，跳过应用恢复同步');
            }
          } catch (e) {
            // 如果获取HomeCubit失败，作为fallback还是执行同步
            _logger.w('ChatsPage 无法获取HomeCubit，执行fallback同步', extra: {'error': e.toString()});
            _checkAndSync(force: true);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // 💢💢💢 取消 RouteObserver 订阅
    routeObserver.unsubscribe(this);

    // 移除生命周期监听
    WidgetsBinding.instance.removeObserver(this);

    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 💢💢💢 RouteAware 生命周期方法
  @override
  void didPopNext() {
    // 💢💢💢 当从其他页面返回到当前页面时触发
    _logger.i('🚀🚀🚀 ChatsPage didPopNext 触发 - 用户从其他页面返回');
    _isPageVisible = true;

    // 检查并执行同步
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 💢💢💢 重要：检查当前是否是可见的Tab页面
        // ChatsPage是索引0，只有当前Tab索引为0时才执行同步
        try {
          final homeCubit = context.read<HomeCubit>();
          final currentTabIndex = homeCubit.state.currentTabIndex;
          final isCurrentTabVisible = currentTabIndex == 0;
          
          _logger.i('🚀🚀🚀 ChatsPage didPopNext 检查可见性', extra: {
            'currentTabIndex': currentTabIndex,
            'isChatsTabVisible': isCurrentTabVisible,
            'shouldSync': isCurrentTabVisible,
          });

          if (isCurrentTabVisible) {
            _logger.i('🚀🚀🚀 ChatsPage 当前可见，执行同步');
            _checkAndSync(force: true); // 强制同步确保触发
          } else {
            _logger.d('ChatsPage 当前不可见，跳过同步');
          }
        } catch (e) {
          // 如果获取HomeCubit失败，作为fallback还是执行同步
          _logger.w('ChatsPage 无法获取HomeCubit，执行fallback同步', extra: {'error': e.toString()});
          _checkAndSync(force: true);
        }
      }
    });
  }

  @override
  void didPushNext() {
    // 💢💢💢 当从当前页面导航到其他页面时触发
    _logger.d('ChatsPage didPushNext 触发 - 用户离开当前页面');
    _isPageVisible = false;
  }

  @override
  void didPush() {
    // 💢💢💢 当页面首次被推入路由栈时触发
    _logger.d('ChatsPage didPush 触发 - 页面首次显示');
    _isPageVisible = true;
  }

  @override
  void didPop() {
    // 💢💢💢 当页面从路由栈中弹出时触发
    _logger.d('ChatsPage didPop 触发 - 页面被移除');
    _isPageVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is required by AutomaticKeepAliveClientMixin
    _logger.d('ChatsPage build');
    return BlocBuilder<ChatsCubit, ChatsState>(
      buildWhen: (previous, current) {
        // 只在以下情况才重建页面

        // 1. 会话列表数量变化
        final conversationsCountChanged =
            previous.conversations.length != current.conversations.length;

        // 2. 过滤后的会话列表数量变化
        final filteredConversationsCountChanged =
            previous.filteredConversations.length !=
                current.filteredConversations.length;

        // 3. 会话列表引用变化（当会话内容更新时，_updateConversationsWithFilter会创建新的列表）
        final conversationsListChanged =
            !identical(previous.conversations, current.conversations);

        // 4. 过滤后会话列表引用变化
        final filteredConversationsListChanged = !identical(
            previous.filteredConversations, current.filteredConversations);

        // 5. 搜索状态变化
        final searchStateChanged =
            previous.isSearching != current.isSearching ||
                previous.searchQuery != current.searchQuery;

        // 6. 选中标签变化
        final tabChanged =
            previous.selectedTabIndex != current.selectedTabIndex;

        // 7. 同步状态变化（影响AppBar显示）
        final syncStatusChanged =
            previous.conversationSyncStatus != current.conversationSyncStatus;

        // 8. 错误信息变化
        final errorChanged = previous.errorMessage != current.errorMessage;

        // 9. 网络状态变化
        final networkStatusChanged =
            previous.isConnected != current.isConnected ||
                previous.networkStatus != current.networkStatus;

        final shouldRebuild = conversationsCountChanged ||
            filteredConversationsCountChanged ||
            conversationsListChanged ||
            filteredConversationsListChanged ||
            searchStateChanged ||
            tabChanged ||
            syncStatusChanged ||
            errorChanged ||
            networkStatusChanged;

        // if (shouldRebuild) {
        //   _logger.d('ChatsPage 需要重建', extra: {
        //     'conversationsCountChanged': conversationsCountChanged,
        //     'filteredConversationsCountChanged':
        //         filteredConversationsCountChanged,
        //     'conversationsListChanged': conversationsListChanged,
        //     'filteredConversationsListChanged':
        //         filteredConversationsListChanged,
        //     'searchStateChanged': searchStateChanged,
        //     'tabChanged': tabChanged,
        //     'syncStatusChanged': syncStatusChanged,
        //     'errorChanged': errorChanged,
        //     'networkStatusChanged': networkStatusChanged,
        //   });
        // }

        return shouldRebuild;
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
                  backgroundColor: AppColors.surfaceVariant,
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

  /// 构建标签栏
  Widget _buildTabBar() {
    return BlocBuilder<ChatsCubit, ChatsState>(
      buildWhen: (previous, current) =>
          previous.conversations != current.conversations,
      builder: (context, state) {
        final currentUserId = state.currentUser?.userId;
        if (currentUserId == null) {
          return const SizedBox.shrink(); // 如果没有当前用户信息，不显示标签栏
        }

        // 检查各分类下是否有新消息 - 基于hasNewMessagesSinceLastRead
        final hasNewPrivateMessages = state.conversations
            .where((c) => c.type == ConversationType.private)
            .any((c) => c.hasNewMessagesSinceLastRead(currentUserId));

        final hasNewGroupMessages = state.conversations
            .where((c) => c.type == ConversationType.group)
            .any((c) => c.hasNewMessagesSinceLastRead(currentUserId));

        final hasNewChannelMessages = state.conversations
            .where((c) => c.type == ConversationType.channel)
            .any((c) => c.hasNewMessagesSinceLastRead(currentUserId));

        // 计算未读会话数量（除了All Chats）- 基于hasNewMessagesSinceLastRead
        final privateUnreadCount = state.conversations
            .where((c) =>
                c.type == ConversationType.private &&
                c.hasNewMessagesSinceLastRead(currentUserId))
            .length;

        final groupUnreadCount = state.conversations
            .where((c) =>
                c.type == ConversationType.group &&
                c.hasNewMessagesSinceLastRead(currentUserId))
            .length;

        final channelUnreadCount = state.conversations
            .where((c) =>
                c.type == ConversationType.channel &&
                c.hasNewMessagesSinceLastRead(currentUserId))
            .length;

        final unreadConversationsCount = state.conversations
            .where((c) => c.hasNewMessagesSinceLastRead(currentUserId))
            .length;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabItem(AppLocalizations.of(context).allChats, 0, 0,
                    false), // All Chats不显示数量
                _buildTabItem(AppLocalizations.of(context).privateChats, 1,
                    privateUnreadCount, hasNewPrivateMessages),
                _buildTabItem(AppLocalizations.of(context).groupChats, 2,
                    groupUnreadCount, hasNewGroupMessages),
                _buildTabItem(AppLocalizations.of(context).channelChats, 3,
                    channelUnreadCount, hasNewChannelMessages),
                _buildTabItem(AppLocalizations.of(context).unreadChats, 4,
                    unreadConversationsCount, unreadConversationsCount > 0),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建单个标签项
  Widget _buildTabItem(
      String title, int index, int unreadCount, bool hasNewMessages) {
    final chatsCubit = context.read<ChatsCubit>();
    final isSelected = chatsCubit.state.selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        // 使用 ChatsCubit 中的方法切换标签
        chatsCubit.setSelectedTabIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
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
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: FontWeight.bold, // 始终使用粗体，但通过不同的透明度区分选中状态
                fontSize: 14,
              ),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.8, // 非选中时稍微降低透明度
                child: Text(title),
              ),
            ),

            // 未读数量徽章 - 只有当未读数量大于0时才显示
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hasNewMessages
                      ? AppColors.primary
                      : AppColors.grey500, // 根据是否有新消息决定颜色
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  _formatUnreadCount(unreadCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
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
      title: BlocBuilder<ChatsCubit, ChatsState>(
        buildWhen: (previous, current) =>
            previous.conversationSyncStatus != current.conversationSyncStatus,
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ConnectionStatusIndicator(size: 14),
              const SizedBox(width: 4),
              Text(AppLocalizations.of(context).chats),
            ],
          );
          // AppBarTitleWithNetworkStatus(
          //   title: 'Chats',
          //   networkStatus: state.conversationSyncStatus,
          //   isLoading: state.isLoadingMessages,
          //   onRetry: () => context.read<ChatsCubit>().syncConversations(),
          // );
        },
      ),
      backgroundColor: AppColors.surfaceVariant,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      automaticallyImplyLeading: false, // 禁用默认返回按钮

      // 左侧编辑按钮
      leading: TextButton(
        onPressed: () {
          // 处理编辑操作
          _logger.d('编辑按钮点击');
          // TODO: 处理编辑操作
        },
        child: Text(
          AppLocalizations.of(context).edit,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 右侧操作按钮区域
      actions: [
        // 💢💢💢 手动同步按钮（调试用）
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.primary),
          onPressed: () {
            _logger.i('🔄🔄🔄 手动触发同步');
            _checkAndSync(force: true);
          },
        ),
        // 新建会话按钮
        IconButton(
          icon: const Icon(Icons.edit_square, color: AppColors.primary),
          onPressed: () {
            _logger.d('新建会话按钮点击');
            _showNewConversationBottomSheet();
          },
        ),
      ],
      centerTitle: true,
    );
  }

  /// 显示新建会话底部弹窗
  void _showNewConversationBottomSheet() {
    // 💢💢💢 先获取所有需要的Provider引用
    final chatsRepository = context.read<ChatsRepository>();
    final chatRepository = context.read<ChatRepository>();
    final chatRepositorySend = context.read<ChatRepositorySend>();
    final contactCubit = context.read<ContactCubit>();
    final chatsCubit = context.read<ChatsCubit>();

    final DraggableScrollableController scrollController =
        DraggableScrollableController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // 明确允许点击背景关闭
      enableDrag: true, // 允许拖拽关闭
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(), // 点击背景关闭
        child: Container(
          color: Colors.transparent, // 必须有颜色才能接收点击事件
          child: DraggableScrollableSheet(
            controller: scrollController,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => GestureDetector(
              onTap: () {}, // 阻止点击事件冒泡到背景
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: MultiRepositoryProvider(
                  providers: [
                    // 💢💢💢 使用预先获取的Provider引用
                    RepositoryProvider<ChatsRepository>.value(
                        value: chatsRepository),
                    RepositoryProvider<ChatRepository>.value(
                        value: chatRepository),
                    RepositoryProvider<ChatRepositorySend>.value(
                        value: chatRepositorySend),
                  ],
                  child: MultiBlocProvider(
                    providers: [
                      // 💢💢💢 使用预先获取的Cubit引用
                      BlocProvider<ContactCubit>.value(value: contactCubit),
                      BlocProvider<ChatsCubit>.value(value: chatsCubit),
                    ],
                    child: NewConversationBottomSheet(
                      scrollController: scrollController,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                hintText: AppLocalizations.of(context).search,
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
                suffixIcon: BlocBuilder<ChatsCubit, ChatsState>(
                  buildWhen: (previous, current) =>
                      previous.isSearching != current.isSearching ||
                      previous.searchQuery != current.searchQuery,
                  builder: (context, state) {
                    if (state.isSearching) {
                      return IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // 清除搜索框并重置搜索状态
                          _searchController.clear();
                          // 结束搜索模式
                          context.read<ChatsCubit>().endSearch();
                          // 清除后重新聚焦到搜索框
                          _searchFocusNode.requestFocus();
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
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
          BlocBuilder<ChatsCubit, ChatsState>(
            buildWhen: (previous, current) =>
                previous.isSearching != current.isSearching,
            builder: (context, state) {
              return state.isSearching
                  ? Padding(
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
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 36),
                        ),
                        child: Text(
                          AppLocalizations.of(context).searchButton,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ))
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  /// 构建聊天列表的 Sliver 组件
  /// 返回多个 Sliver 组件组成的列表
  List<Widget> _buildChatListSlivers(ChatsState state) {
    final currentUserId = state.currentUser?.userId;
    if (currentUserId == null) {
      return [
        const SliverFillRemaining(
          child: Center(
            child: Text('用户信息未加载', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      _logger.e('加载失败: ${state.errorMessage}');
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
                    context.read<ChatsCubit>().loadConversations();
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
      _logger.d('没有会话');
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
                  state.searchQuery.isNotEmpty
                      ? AppLocalizations.of(context).noMatchingChats
                      : AppLocalizations.of(context).noChats,
                  style: const TextStyle(color: Colors.grey),
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
      if (conversation.isPinned(currentUserId)) {
        pinnedConversations.add(conversation);
      } else {
        unpinnedConversations.add(conversation);
      }
    }

    // 按时间排序：置顶会话和非置顶会话分别排序
    // 最新消息时间在前，null值排在最后
    pinnedConversations.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt); // 都没有消息时按创建时间排序
      } else if (a.lastMessageTime == null) {
        return 1; // a 没有消息，排在后面
      } else if (b.lastMessageTime == null) {
        return -1; // b 没有消息，排在后面
      }
      return b.lastMessageTime!.compareTo(a.lastMessageTime!); // 按最后消息时间倒序
    });

    unpinnedConversations.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt); // 都没有消息时按创建时间排序
      } else if (a.lastMessageTime == null) {
        return 1; // a 没有消息，排在后面
      } else if (b.lastMessageTime == null) {
        return -1; // b 没有消息，排在后面
      }
      return b.lastMessageTime!.compareTo(a.lastMessageTime!); // 按最后消息时间倒序
    });

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

              return ConversationItem(
                key: ValueKey('pinned_${conversation.conversationId}'),
                conversation: conversation,
                currentUser: state.currentUser!,
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

              return ConversationItem(
                key: ValueKey(conversation.conversationId),
                conversation: conversation,
                currentUser: state.currentUser!,
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
}

// 固定 SliverTabBar 宽度
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
