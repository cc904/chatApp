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
            child: Column(
              children: [
                _buildTabBar(),
                Expanded(
            child: _buildChatList(state),
                ),
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
    switch (_selectedTabIndex) {
      case 0: // All Chats
        return conversations;
      case 1: // 私密
        return conversations
            .where((c) => c.type == ConversationType.private)
            .toList();
      case 2: // 群组
        return conversations
            .where((c) => c.type == ConversationType.group)
            .toList();
      case 3: // 频道
        return conversations
            .where((c) => c.type == ConversationType.channel)
            .toList();
      case 4: // 未读
        return conversations.where((c) => c.unreadCount > 0).toList();
      default:
        return conversations;
    }
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem('All Chats', 0, null),
          _buildTabItem('私密', 1, null),
          _buildTabItem('群组', 2, 2),
          _buildTabItem('频道', 3, 3),
          _buildTabItem('未读', 4, 5),
        ],
      ),
    );
  }

  /// 构建单个标签项
  Widget _buildTabItem(String title, int index, int? count) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            // 切换标签后更新过滤的会话列表
            _filteredConversations = _filterConversationsByTab(
                context.read<HomeCubit>().state.conversations);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (count != null)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      ),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // 中间标题
      title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
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

              return _buildConversationItem(conversation, contact);
            },
          );
  }

  /// 构建单个会话项
  Widget _buildConversationItem(Conversation conversation, User contact) {
    // _logger.d('创建会话Item: ${contact.name} ${contact.avatar}');
    // 判断是否有静音图标
    final bool isMuted = conversation.isMuted;

    // 判断会话类型
    final bool isGroup = conversation.type == ConversationType.group;

    // 查找最后一条消息的发送者（如果是群聊）
    String? senderName;
    if (isGroup && conversation.lastMessageSenderId != null) {
      // 从contacts中查找发送者
      final sender = context.read<HomeCubit>().state.contacts.firstWhere(
            (c) => c.userId == conversation.lastMessageSenderId,
            orElse: () => User()..name = '未知用户',
          );
      senderName = sender.name;
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
              // homeCubit
              //     .loadMessagesForConversation(conversation.conversationId);

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
                      ),
                    ),
                  ),

                  // 中间内容区域
                  Expanded(
                    child: SizedBox(
                      height: avatarSize + 1, // 与头像高度一致
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // 均匀分布三行内容
                        children: [
                          // 第一行：会话名称和静音图标
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        contact.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isMuted)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4.0),
                                        child: Icon(Icons.volume_off,
                                            size: 16, color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 第二行：
                          // 群聊 - 发送者名称
                          // 私聊/频道 - 消息内容第一部分
                          if (isGroup)
                            Text(
                              senderName ?? '未知用户',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                // color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              conversation.lastMessagePreview ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                          // 第三行：
                          // 群聊 - 消息内容
                          // 私聊/频道 - 消息内容延续或空白
                          Text(
                            isGroup
                                ? (conversation.lastMessagePreview ?? '')
                                : '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
                                color: Colors.blue,
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
