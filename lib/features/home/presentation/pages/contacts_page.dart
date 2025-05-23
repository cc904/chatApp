import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/presentation/pages/new_chat_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:lpinyin/lpinyin.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  String? _openedItemId;
  String? _currentLetter;

  // 分组联系人数据结构
  Map<String, List<User>> _groupedContacts = {};
  List<String> _sortedKeys = [];

  // 用于搜索结果
  List<User> _filteredContacts = [];
  bool _isFiltering = false;

  // 字母索引位置映射
  Map<String, double> _letterPositions = {};

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
      _logger.i('加载联系人数据');
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

      // 获取首字符
      final firstChar = contact.name[0];

      // 确定分组键
      String groupKey;

      // 判断首字符是否为英文字母
      if (RegExp(r'[A-Za-z]').hasMatch(firstChar)) {
        // 如果是英文字母，直接使用大写形式
        groupKey = firstChar.toUpperCase();
      } else if (RegExp(r'[0-9]').hasMatch(firstChar)) {
        // 如果是数字，归类到 '#'
        groupKey = '#';
      } else {
        // 如果是其他字符（如中文），获取拼音首字母
        try {
          // 使用lpinyin库获取拼音首字母
          String pinyinFirst = PinyinHelper.getFirstWordPinyin(firstChar);
          if (pinyinFirst.isNotEmpty) {
            groupKey = pinyinFirst[0].toUpperCase();
            // 确保是英文字母
            if (!RegExp(r'[A-Z]').hasMatch(groupKey)) {
              groupKey = '#';
            }
          } else {
            groupKey = '#';
          }
        } catch (e) {
          // 转换失败时使用 '#'
          _logger.e('拼音转换失败', error: e);
          groupKey = '#';
        }
      }

      // 添加到对应分组
      if (!_groupedContacts.containsKey(groupKey)) {
        _groupedContacts[groupKey] = [];
      }
      _groupedContacts[groupKey]!.add(contact);
    }

    // 获取所有首字母并排序
    _sortedKeys = _groupedContacts.keys.toList()..sort();

    // 计算字母位置需要在布局完成后进行，使用postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateLetterPositions();
    });
  }

  /// 计算各个字母索引的位置
  void _calculateLetterPositions() {
    _letterPositions = {};
    for (var key in _sortedKeys) {
      final RenderBox? renderBox = _getGroupRenderBox(key);
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        _letterPositions[key] = position.dy;
      }
    }
  }

  /// 获取分组标题的RenderBox
  RenderBox? _getGroupRenderBox(String key) {
    final keyContext = _getKeyContext(key);
    if (keyContext != null) {
      return keyContext.findRenderObject() as RenderBox?;
    }
    return null;
  }

  /// 获取分组标题的BuildContext
  BuildContext? _getKeyContext(String key) {
    final GlobalKey groupKey = GlobalKey(debugLabel: 'group_$key');
    final context = groupKey.currentContext;
    return context;
  }

  /// 滚动到指定字母分组
  void _scrollToLetter(String letter) {
    setState(() {
      _currentLetter = letter;
    });

    // 查找字母对应的位置
    final index = _sortedKeys.indexOf(letter);
    if (index != -1) {
      double offset = 0;

      // 计算滚动位置
      for (int i = 0; i < index; i++) {
        final key = _sortedKeys[i];
        final contactsCount = _groupedContacts[key]?.length ?? 0;
        // 每个分组标题高度 + 每个联系人项目高度
        offset += 36 + contactsCount * 56;
      }

      // 滚动到指定位置
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // 短暂显示当前字母指示器，然后隐藏
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentLetter = null;
        });
      }
    });
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

  /// 同步联系人
  Future<void> _syncContacts() async {
    final homeCubit = context.read<HomeCubit>();
    await homeCubit.syncContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _logger.d('ContactsPage build');
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_openedItemId != null) {
                setState(() {
                  _openedItemId = null;
                });
              }
            },
            child: Column(
              children: [
                // 同步状态指示器
                _buildSyncStatusIndicator(),

                // 联系人列表
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _syncContacts,
                    child: BlocConsumer<HomeCubit, HomeState>(
                      listener: (context, state) {
                        if (!state.isLoadingContacts && !_isFiltering) {
                          _updateGroupedContacts(state.contacts);
                        }
                      },
                      buildWhen: (previous, current) =>
                          previous.contacts != current.contacts ||
                          previous.isLoadingContacts !=
                              current.isLoadingContacts ||
                          previous.contactsSyncStatus !=
                              current.contactsSyncStatus,
                      builder: (context, state) {
                        if (state.isLoadingContacts && state.contacts.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state.hasError) {
                          return Center(
                              child: Text('错误: ${state.errorMessage}'));
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
                ),
              ],
            ),
          ),

          // 右侧字母索引栏
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildLetterIndex(),
            ),
          ),

          // 中间显示当前选中的字母
          if (_currentLetter != null)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _currentLetter!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.person_add),
        onPressed: () {
          _logger.i('打开添加联系人页面');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewChatPage(),
            ),
          );
        },
      ),
    );
  }

  /// 构建字母索引栏
  Widget _buildLetterIndex() {
    // 计算字母索引栏的总高度
    // 每个字母高度为20，不改变这个值
    // 添加额外的顶部和底部空间，确保圆角不会遮挡字母
    final double totalLettersHeight =
        _sortedKeys.length * 20.0 + 16; // 增加16像素以适应圆角

    return Container(
      width: 24,
      height: totalLettersHeight,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8), // 增加垂直内边距
      margin: const EdgeInsets.only(right: 8),
      child: ScrollConfiguration(
        // 隐藏滚动条
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // 禁用滚动
          itemCount: _sortedKeys.length,
          itemBuilder: (context, index) {
            final letter = _sortedKeys[index];
            return GestureDetector(
              onTap: () => _scrollToLetter(letter),
              child: Container(
                height: 20,
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _currentLetter == letter
                        ? Colors.green
                        : Colors.black54,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建同步状态指示器
  Widget _buildSyncStatusIndicator() {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.contactsSyncStatus != current.contactsSyncStatus ||
          previous.hasContactsError != current.hasContactsError,
      builder: (context, state) {
        if (state.contactsSyncStatus == ContactsSyncStatus.syncing) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          );
        } else if (state.hasContactsError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.red.shade100,
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.contactsErrorMessage ?? '同步联系人失败',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _syncContacts,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
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
          icon: const Icon(Icons.refresh),
          onPressed: _syncContacts,
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
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
                if (!_isSearching) {
                  _isFiltering = false;
                }
              });
            },
            onSubmitted: (value) {
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
      controller: _scrollController,
      itemCount: _sortedKeys.length,
      physics: const BouncingScrollPhysics(),
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
      key: GlobalKey(debugLabel: 'group_$key'),
      width: double.infinity,
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

        if (conversationId != null && mounted) {
          // 在异步操作后重新获取homeCubit，确保它仍然有效
          final currentHomeCubit = context.read<HomeCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: currentHomeCubit,
                child: ChatDetailPage(
                  contact: contact,
                  conversationId: conversationId,
                ),
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
                _logger.i('筛选星标联系人');
                // 实现星标联系人筛选逻辑
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('群组'),
              onTap: () {
                Navigator.pop(context);
                _logger.i('筛选群组');
                // 实现群组筛选逻辑
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.green),
              title: const Text('已屏蔽'),
              onTap: () {
                Navigator.pop(context);
                _logger.i('筛选已屏蔽联系人');
                // 实现已屏蔽联系人筛选逻辑
              },
            ),
          ],
        ),
      ),
    );
  }
}
