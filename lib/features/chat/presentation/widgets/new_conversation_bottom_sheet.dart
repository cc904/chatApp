import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/contacts/presentation/widgets/contact_list_widget.dart';
import 'package:cc/features/chat/presentation/pages/chat_page.dart';
import 'package:cc/features/chat/presentation/pages/create_group_page.dart';
import 'package:cc/features/chat/presentation/pages/channel_info_page.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/constants/app_colors.dart';

/// 新建对话底部弹窗
class NewConversationBottomSheet extends StatefulWidget {
  final ScrollController scrollController;

  const NewConversationBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  State<NewConversationBottomSheet> createState() =>
      _NewConversationBottomSheetState();
}

class _NewConversationBottomSheetState
    extends State<NewConversationBottomSheet> {
  final _logger = LogService.instance;
  final PageController _pageController = PageController();

  // 当前页面索引：0=主页面，1=新建群聊页面
  int _currentPageIndex = 0;

  // 群聊相关状态
  final List<User> _selectedContacts = [];

  @override
  void initState() {
    super.initState();

    // 确保联系人数据已加载
    final contactCubit = context.read<ContactCubit>();
    if (contactCubit.state.contacts.isEmpty && !contactCubit.state.isLoading) {
      contactCubit.loadContacts();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 处理主页面联系人点击
  void _handleMainPageContactTap(User contact) {
    _logger.i('选择联系人开始对话', extra: {'contactName': contact.name});

    // 获取必要的Provider依赖
    final chatsRepository = context.read<ChatsRepository>();
    final chatRepository = context.read<ChatRepository>();
    final chatRepositorySend = context.read<ChatRepositorySend>();

    // 调用repository创建会话
    chatsRepository
        .getOrCreatePrivateConversation(contact.userId)
        .then((conversation) {
      if (mounted) {
        // 关闭底部弹窗
        Navigator.pop(context);

        // 跳转到聊天页面，提供必要的Provider和Cubit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultiRepositoryProvider(
              providers: [
                RepositoryProvider<ChatRepository>.value(value: chatRepository),
                RepositoryProvider<ChatsRepository>.value(
                    value: chatsRepository),
                RepositoryProvider<ChatRepositorySend>.value(
                    value: chatRepositorySend),
              ],
              child: BlocProvider<ChatCubit>(
                create: (context) => ChatCubit(
                  chatRepository: chatRepository,
                  chatRepositorySend: chatRepositorySend,
                  chatsRepository: chatsRepository,
                  currentUser: CurrentUser()..userId = '', // 这会被ChatCubit正确初始化
                  initialConversation: conversation,
                ),
                child: ChatPage(
                  conversationId: conversation.conversationId,
                  initialConversation: conversation,
                ),
              ),
            ),
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建对话失败: $error')),
        );
      }
    });
  }

  /// 处理群聊页面联系人选择
  void _handleGroupPageSelectionChanged(User contact, bool selected) {
    setState(() {
      if (selected) {
        _selectedContacts.add(contact);
      } else {
        _selectedContacts.remove(contact);
      }
    });
  }

  /// 切换到新建群聊页面
  void _switchToGroupPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 返回主页面
  void _backToMainPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 创建群聊
  void _createGroup() {
    if (_selectedContacts.isEmpty) return;

    _logger.i('进入群聊设置页面', extra: {
      'selectedContacts': _selectedContacts.length,
      'contactNames': _selectedContacts.map((c) => c.name).toList(),
    });

    // 获取必要的Provider依赖
    final chatsRepository = context.read<ChatsRepository>();
    final chatRepository = context.read<ChatRepository>();
    final chatRepositorySend = context.read<ChatRepositorySend>();

    // 关闭当前底部面板
    Navigator.pop(context);

    // 导航到创建群聊页面，传递必要的Provider
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ChatsRepository>.value(value: chatsRepository),
            RepositoryProvider<ChatRepository>.value(value: chatRepository),
            RepositoryProvider<ChatRepositorySend>.value(
                value: chatRepositorySend),
          ],
          child: CreateGroupPage(
            selectedMembers: List.from(_selectedContacts),
          ),
        ),
      ),
    );
  }

  /// 导航到频道信息页面
  void _navigateToChannelInfo() {
    _logger.i('进入频道信息页面');

    // 获取必要的Provider依赖
    final chatsRepository = context.read<ChatsRepository>();
    final chatRepository = context.read<ChatRepository>();
    final chatRepositorySend = context.read<ChatRepositorySend>();

    // 关闭当前底部面板
    Navigator.pop(context);

    // 导航到频道信息页面，传递必要的Provider
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ChatsRepository>.value(value: chatsRepository),
            RepositoryProvider<ChatRepository>.value(value: chatRepository),
            RepositoryProvider<ChatRepositorySend>.value(
                value: chatRepositorySend),
          ],
          child: const ChannelInfoPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          _buildTitleBar(),

          // 页面内容
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                _buildMainPage(),
                _buildNewGroupPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildTitleBar() {
    final l10n = AppLocalizations.of(context);

    if (_currentPageIndex == 0) {
      // 主页面标题栏
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.newMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 群聊页面标题栏
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _backToMainPage,
              child: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.newGroup,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${_selectedContacts.length}/200000',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _selectedContacts.isNotEmpty ? _createGroup : null,
              child: Text(
                l10n.next,
                style: TextStyle(
                  color: _selectedContacts.isNotEmpty
                      ? AppColors.primary
                      : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 构建主页面
  Widget _buildMainPage() {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // 新建群聊按钮
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.group_add, color: AppColors.primary),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _switchToGroupPage,
                child: Text(
                  l10n.newGroup,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 分隔线
        Divider(color: Colors.grey[300], height: 1),

        // 新建频道按钮
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.campaign, color: AppColors.primary),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _navigateToChannelInfo,
                child: Text(
                  l10n.newChannel,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 分隔线
        Divider(color: Colors.grey[300], height: 1),

        // 联系人列表
        Expanded(
          child: ContactListWidget(
            mode: ContactListMode.normal,
            shrinkWrap: false,
            scrollController: widget.scrollController,
            onContactTap: _handleMainPageContactTap,
            searchHint: l10n.searchContacts,
          ),
        ),
      ],
    );
  }

  /// 构建新建群聊页面
  Widget _buildNewGroupPage() {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Who would you like to add? 提示文字
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.whoToAdd,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),

        // 已选联系人显示区域
        if (_selectedContacts.isNotEmpty) _buildSelectedContactsArea(),

        // 联系人列表
        Expanded(
          child: ContactListWidget(
            mode: ContactListMode.selection,
            selectedContacts: _selectedContacts,
            onSelectionChanged: _handleGroupPageSelectionChanged,
            searchHint: '#',
            shrinkWrap: false,
          ),
        ),
      ],
    );
  }

  /// 构建已选联系人显示区域
  Widget _buildSelectedContactsArea() {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.selected} (${_selectedContacts.length})',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedContacts.map((contact) {
              return Chip(
                avatar: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    contact.name.isNotEmpty
                        ? contact.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: Text(
                  contact.name,
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedContacts.remove(contact);
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
