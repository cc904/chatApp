import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/presentation/pages/new_chat_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  bool _isSearching = false;
  String? _openedItemId;

  // 分组联系人数据结构
  Map<String, List<User>> _groupedContacts = {};
  List<String> _sortedKeys = [];

  // 用于搜索结果
  List<User> _filteredContacts = [];
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    // 确保HomeCubit已加载联系人数据
    _ensureContactsLoaded();
  }

  /// 确保联系人数据已加载
  /// 如果HomeCubit中没有联系人数据且未在加载中，则触发加载操作
  /// 否则使用现有数据更新分组联系人
  void _ensureContactsLoaded() {
    final homeCubit = context.read<HomeCubit>();
    if (homeCubit.state.contacts.isEmpty &&
        !homeCubit.state.isLoadingContacts) {
      _logger.x('加载联系人数据');
      homeCubit.loadContacts();
    } else {
      _updateGroupedContacts(homeCubit.state.contacts);
    }
  }

  /// 更新分组联系人数据
  /// 将联系人按名称首字母分组并排序
  /// [contacts] - 要分组的联系人列表
  void _updateGroupedContacts(List<User> contacts) {
    _groupedContacts.clear();

    // 按首字母分组
    for (var contact in contacts) {
      if (contact.name.isEmpty) continue;

      final firstChar = contact.name[0].toUpperCase();
      if (!_groupedContacts.containsKey(firstChar)) {
        _groupedContacts[firstChar] = [];
      }
      _groupedContacts[firstChar]!.add(contact);
    }

    // 获取所有首字母并排序
    _sortedKeys = _groupedContacts.keys.toList()..sort();
  }

  /// 搜索联系人
  /// 根据查询词过滤联系人列表
  /// [query] - 搜索关键词
  Future<void> _searchContacts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isFiltering = false;
      });
      return;
    }

    final homeCubit = context.read<HomeCubit>();
    final allContacts = homeCubit.state.contacts;

    setState(() {
      _isFiltering = true;
      _filteredContacts = allContacts
          .where((contact) =>
              contact.name.toLowerCase().contains(query.toLowerCase()) ||
              (contact.status?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.x('构建ContactsPage');
    return Scaffold(
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () {
          if (_openedItemId != null) {
            setState(() {
              _openedItemId = null;
            });
          }
        },
        child: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {
            if (!state.isLoadingContacts && !_isFiltering) {
              _updateGroupedContacts(state.contacts);
            }
          },
          builder: (context, state) {
            if (state.isLoadingContacts && state.contacts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError) {
              return Center(child: Text('错误: ${state.errorMessage}'));
            }

            if (_isFiltering) {
              return _buildFilteredList();
            }

            if (_sortedKeys.isEmpty) {
              return const Center(child: Text('没有联系人'));
            }

            return _buildGroupedAnimatedList();
          },
        ),
      ),
    );
  }

  /// 构建应用栏
  /// 包含标题、过滤按钮、添加联系人按钮和搜索框
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('联系人', style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: _showFilterDialog,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: () {
            _logger.x('打开添加联系人页面');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NewChatPage(),
              ),
            );
          },
        ),
      ],
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '搜索',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              isDense: true,
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
              suffixIcon: _isSearching
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.grey, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _isSearching = false;
                              _isFiltering = false;
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
                              final query = _searchController.text;
                              if (query.isNotEmpty) {
                                _searchContacts(query);
                              }
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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
              if (value.isNotEmpty) {
                _searchContacts(value);
              } else {
                setState(() {
                  _isFiltering = false;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  /// 构建分组联系人列表
  /// 使用AnimatedList显示按首字母分组的联系人
  Widget _buildGroupedAnimatedList() {
    return ListView.builder(
      itemCount: _sortedKeys.length,
      itemBuilder: (context, index) {
        final key = _sortedKeys[index];
        final contacts = _groupedContacts[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(key),
            AnimatedList(
              key: ValueKey('group_$key'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: contacts.length,
              itemBuilder: (context, itemIndex, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: _buildContactItem(contacts[itemIndex]),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// 构建过滤后的联系人列表
  /// 显示搜索结果中的联系人
  Widget _buildFilteredList() {
    if (_filteredContacts.isEmpty) {
      return const Center(child: Text('没有找到匹配的联系人'));
    }

    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        return _buildContactItem(_filteredContacts[index]);
      },
    );
  }

  /// 构建分组标题
  /// 显示联系人分组的首字母标题
  /// [key] - 分组的首字母
  Widget _buildGroupHeader(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Text(
        key,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// 构建联系人列表项
  /// 显示单个联系人的信息，点击后导航到聊天详情页
  /// [contact] - 要显示的联系人对象
  Widget _buildContactItem(User contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            contact.avatar != null ? NetworkImage(contact.avatar!) : null,
        child: contact.avatar == null ? Text(contact.name[0]) : null,
      ),
      title: Text(contact.name),
      subtitle: Text(contact.status ?? ''),
      onTap: () async {
        final homeCubit = context.read<HomeCubit>();
        final conversationId =
            await homeCubit.getOrCreatePrivateConversation(contact.userId);

        if (conversationId != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(
                contact: contact,
                conversationId: conversationId,
              ),
            ),
          );
        }
      },
    );
  }

  /// 显示筛选对话框
  /// 弹出底部菜单，提供联系人筛选选项
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
              '筛选联系人',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.green),
              title: const Text('星标联系人'),
              onTap: () {
                Navigator.pop(context);
                _logger.x('筛选星标联系人');
                // 实现星标联系人筛选逻辑
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('群组'),
              onTap: () {
                Navigator.pop(context);
                _logger.x('筛选群组');
                // 实现群组筛选逻辑
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.green),
              title: const Text('已屏蔽'),
              onTap: () {
                Navigator.pop(context);
                _logger.x('筛选已屏蔽联系人');
                // 实现已屏蔽联系人筛选逻辑
              },
            ),
          ],
        ),
      ),
    );
  }
}
