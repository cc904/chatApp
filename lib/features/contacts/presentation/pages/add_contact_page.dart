import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/chat/presentation/widgets/new_conversation_bottom_sheet.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/universal_search_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/core/database/models/current_user.dart';

/// 添加联系人页面 - 仿微信风格
class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  final _universalSearch = UniversalSearchService.instance;

  // 搜索状态
  bool _isSearching = false;
  UniversalSearchResponse? _searchResults;
  String _lastSearchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 执行搜索
  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _lastSearchQuery = '';
      });
      return;
    }

    if (query == _lastSearchQuery) {
      return; // 避免重复搜索
    }

    setState(() {
      _isSearching = true;
      _lastSearchQuery = query;
    });

    try {
      _logger.i('执行搜索', extra: {'query': query});

      final results = await _universalSearch.smartSearch(
        query: query,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        if (results != null && results.success) {
          final summary = UniversalSearchService.formatSearchSummary(results);
          _logger.i('搜索完成: $summary');
        } else {
          _logger.w('搜索失败: ${results?.message ?? '未知错误'}');
        }
      }
    } catch (error) {
      _logger.e('搜索异常', error: error);
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: ${error.toString()}')),
        );
      }
    }
  }

  /// 显示新建会话底部弹窗（群聊/频道）
  void _showNewConversationBottomSheet() {
    _logger.i('打开新建会话页面');

    // 获取所有需要的Provider引用
    final chatsRepository = context.read<ChatsRepository>();
    final chatRepository = context.read<ChatRepository>();
    final chatRepositorySend = context.read<ChatRepositorySend>();
    final contactCubit = context.read<ContactCubit>();

    final DraggableScrollableController scrollController =
        DraggableScrollableController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          child: DraggableScrollableSheet(
            controller: scrollController,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => GestureDetector(
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: MultiRepositoryProvider(
                  providers: [
                    RepositoryProvider<ChatsRepository>.value(
                        value: chatsRepository),
                    RepositoryProvider<ChatRepository>.value(
                        value: chatRepository),
                    RepositoryProvider<ChatRepositorySend>.value(
                        value: chatRepositorySend),
                  ],
                  child: BlocProvider<ContactCubit>.value(
                    value: contactCubit,
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

  /// 处理用户结果点击
  void _handleUserTap(UserProto user) {
    _logger.i('点击用户结果', extra: {'userId': user.userId, 'name': user.nickName});

    // 显示添加好友对话框
    _showAddFriendDialog(user);
  }

  /// 显示添加好友对话框
  void _showAddFriendDialog(UserProto user) {
    final TextEditingController messageController = TextEditingController();
    final currentUser = context.read<CurrentUser>();
    messageController.text = '我是${currentUser.name}'; // 默认消息

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '添加好友',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息展示
            Row(
              children: [
                UserAvatar(
                  avatarUrl: user.avatar.isNotEmpty ? user.avatar : null,
                  name: user.nickName,
                  radius: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickName.isNotEmpty ? user.nickName : '未命名用户',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF191919),
                        ),
                      ),
                      Text(
                        'ID: ${user.userId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 申请消息输入框
            const Text(
              '申请理由',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLength: 100,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '请输入申请理由...',
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF07C160),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('请输入申请理由'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.of(context).pop(); // 关闭对话框

              // 发送好友申请
              await _sendFriendRequest(user.userId, message, user.nickName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07C160),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            child: const Text(
              '发送',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 发送好友申请
  Future<void> _sendFriendRequest(
      String targetUserId, String message, String targetUserName) async {
    try {
      _logger.i('发送好友申请', extra: {
        'targetUserId': targetUserId,
        'message': message,
        'targetUserName': targetUserName,
      });

      // 显示加载状态
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF07C160),
          ),
        ),
      );

      final contactCubit = context.read<ContactCubit>();
      final success =
          await contactCubit.sendFriendRequest(targetUserId, message);

      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // 显示成功消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('好友申请已发送给 $targetUserName'),
              backgroundColor: const Color(0xFF07C160),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        _logger.i('好友申请发送成功', extra: {
          'event': 'friend:request:send',
          'targetUserId': targetUserId,
          'targetUserName': targetUserName,
        });
      } else {
        // 显示失败消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('好友申请发送失败，请稍后重试'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

        _logger.w('好友申请发送失败', extra: {
          'event': 'friend:request:send',
          'targetUserId': targetUserId,
          'targetUserName': targetUserName,
        });
      }
    } catch (error) {
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }

      _logger.e('发送好友申请异常', error: error, extra: {
        'event': 'friend:request:send',
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送好友申请时出现错误: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 处理会话结果点击
  void _handleConversationTap(SearchConversationResult conversation) {
    _logger.i('点击会话结果', extra: {
      'conversationId': conversation.conversationId,
      'name': conversation.name,
      'type': conversation.type,
    });

    // TODO: 实现加入群聊/频道逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '点击了${conversation.type == 'group' ? '群聊' : '频道'}: ${conversation.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('添加朋友'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索框区域
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '联系人ID / 群聊ID / 频道ID',
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 16,
                  ),
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF999999)),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.search,
                          color: Color(0xFF999999),
                          size: 20,
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: _performSearch,
              ),
            ),
          ),

          // 内容区域
          Expanded(
            child: _searchResults != null
                ? _buildSearchResults()
                : _buildDefaultOptions(),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    if (_searchResults == null || !_searchResults!.success) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 16),
            Text(
              _searchResults?.message ?? '搜索失败',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    final results = _searchResults!;
    final hasResults = results.userCount > 0 || results.conversationCount > 0;

    if (!hasResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 64,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 16),
            const Text(
              '未找到相关结果',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '尝试搜索用户ID、群聊ID或频道ID',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        const SizedBox(height: 10),

        // 搜索结果摘要
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0F2FE)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF0EA5E9),
              ),
              const SizedBox(width: 8),
              Text(
                UniversalSearchService.formatSearchSummary(results),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0EA5E9),
                ),
              ),
            ],
          ),
        ),

        // 用户结果
        if (results.users.isNotEmpty) ...[
          _buildSectionHeader('用户 (${results.users.length})'),
          ...results.users.map((user) => _buildUserItem(user)),
        ],

        // 会话结果
        if (results.conversations.isNotEmpty) ...[
          _buildSectionHeader('群聊和频道 (${results.conversations.length})'),
          ...results.conversations
              .map((conversation) => _buildConversationItem(conversation)),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  /// 构建分节标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建用户条目
  Widget _buildUserItem(UserProto user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0.5),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => _handleUserTap(user),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // 用户头像
                UserAvatar(
                  avatarUrl: user.avatar.isNotEmpty ? user.avatar : null,
                  name: user.nickName,
                  radius: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickName.isNotEmpty ? user.nickName : '未命名用户',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF191919),
                        ),
                      ),
                      if (user.userId.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${user.userId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A8A8A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCCCCCC),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建会话条目
  Widget _buildConversationItem(SearchConversationResult conversation) {
    final isGroup = conversation.type == 'group';
    final typeLabel =
        UniversalSearchService.getSearchResultTypeLabel(conversation.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 0.5),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => _handleConversationTap(conversation),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // 会话头像
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isGroup
                        ? const Color(0xFF07C160)
                        : const Color(0xFF576B95),
                    shape: BoxShape.circle,
                  ),
                  child: conversation.avatar.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            conversation.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                isGroup ? Icons.group : Icons.campaign,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : Icon(
                          isGroup ? Icons.group : Icons.campaign,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name.isNotEmpty
                            ? conversation.name
                            : '未命名$typeLabel',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            typeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                          if (conversation.participantCount > 0) ...[
                            const Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                            Text(
                              '${conversation.participantCount}人',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                          ],
                          if (conversation.isJoined) ...[
                            const Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                            const Text(
                              '已加入',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF07C160),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCCCCCC),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建默认功能选项
  Widget _buildDefaultOptions() {
    return ListView(
      children: [
        const SizedBox(height: 10),

        // 扫一扫
        _buildOptionItem(
          icon: Icons.qr_code_scanner,
          iconColor: const Color(0xFF07C160),
          title: '扫一扫',
          subtitle: '扫描二维码名片',
          onTap: () {
            // TODO: 实现扫码功能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('扫码功能开发中...')),
            );
          },
        ),

        // 联系人
        _buildOptionItem(
          icon: Icons.person_add,
          iconColor: const Color(0xFF07C160),
          title: '联系人',
          subtitle: '通过ID添加联系人',
          onTap: () {
            // TODO: 实现添加联系人功能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('添加联系人功能开发中...')),
            );
          },
        ),

        // 群聊 - 复用NewConversationBottomSheet
        _buildOptionItem(
          icon: Icons.group_add,
          iconColor: const Color(0xFF07C160),
          title: '群聊',
          subtitle: '创建或加入群聊',
          onTap: _showNewConversationBottomSheet,
        ),

        // 频道 - 复用NewConversationBottomSheet
        _buildOptionItem(
          icon: Icons.campaign,
          iconColor: const Color(0xFF576B95),
          title: '频道',
          subtitle: '搜索并加入频道',
          onTap: _showNewConversationBottomSheet,
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0.5),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A8A8A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCCCCCC),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
