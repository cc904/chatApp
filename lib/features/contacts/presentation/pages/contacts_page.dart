import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/features/contacts/presentation/pages/contact_detail_page.dart';
import 'package:cc/features/home/presentation/widgets/network_status_indicator.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'dart:async';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // 搜索防抖计时器
  Timer? _debounceTimer;

  bool _isSearching = false;
  String? _openedItemId;
  String? _currentLetter;

  // 分组联系人数据结构
  final Map<String, List<User>> _groupedContacts = {};
  List<String> _sortedKeys = [];

  // 所有可用的索引，包括搜索图标
  List<String> get _allIndexes => ['🔍', ..._sortedKeys];

  // 用于搜索结果
  List<User> _filteredContacts = [];
  bool _isFiltering = false;

  // 字母索引位置映射
  Map<String, double> _letterPositions = {};

  @override
  void initState() {
    super.initState();
    // 确保ContactCubit已加载联系人数据
    _ensureContactsLoaded();
  }

  /// 确保联系人数据已加载
  /// 如果ContactCubit中没有联系人数据且未在加载中，则触发加载操作
  /// 否则使用现有数据更新分组联系人
  void _ensureContactsLoaded() {
    final contactCubit = context.read<ContactCubit>();
    if (contactCubit.state.contacts.isEmpty && !contactCubit.state.isLoading) {
      _logger.i('加载联系人数据');
      contactCubit.loadContacts();
    } else {
      _updateGroupedContacts(contactCubit.state.contacts);
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
        // 如果是中文或其他字符，使用联系人的pinyin字段
        if (contact.pinyin != null && contact.pinyin!.isNotEmpty) {
          // 使用pinyin字段的第一个字符作为分组键
          final firstPinyinChar = contact.pinyin![0].toUpperCase();
          // 确保是英文字母
          if (RegExp(r'[A-Z]').hasMatch(firstPinyinChar)) {
            groupKey = firstPinyinChar;
          } else {
            groupKey = '#';
          }
        } else {
          // 如果pinyin字段为空，归类到 '#'
          groupKey = '#';
          _logger.w('联系人没有拼音字段', extra: {'name': contact.name});
        }
      }

      // 添加到对应分组
      if (!_groupedContacts.containsKey(groupKey)) {
        _groupedContacts[groupKey] = [];
      }
      _groupedContacts[groupKey]!.add(contact);
    }

    // 对每个分组内的联系人按名称排序
    for (var key in _groupedContacts.keys) {
      _groupedContacts[key]!.sort((a, b) {
        // 首先尝试按拼音排序（如果有）
        if (a.pinyin != null && b.pinyin != null) {
          return a.pinyin!.compareTo(b.pinyin!);
        }
        // 否则按名称字符串排序
        return a.name.compareTo(b.name);
      });
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

  /// 滚动到指定字母分组或搜索框
  void _scrollToLetter(String letter) {
    setState(() {
      _currentLetter = letter;
    });

    if (letter == '🔍') {
      // 滚动到顶部（搜索框位置）
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // 聚焦到搜索框
      _searchFocusNode.requestFocus();
    } else {
      // 查找字母对应的位置
      final index = _sortedKeys.indexOf(letter);
      if (index != -1) {
        double offset = 60; // 搜索框的高度

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
  void _searchContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _isFiltering = false;
      });
      return;
    }

    final contactCubit = context.read<ContactCubit>();
    final allContacts = contactCubit.state.contacts;

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
    final contactCubit = context.read<ContactCubit>();
    await contactCubit.syncContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _logger.d('ContactsPage build');
    return BlocConsumer<ContactCubit, ContactState>(
      buildWhen: (previous, current) {
        // 只在以下情况才重建页面

        // 1. 联系人列表数量变化
        final contactsCountChanged =
            previous.contacts.length != current.contacts.length;

        // 2. 加载状态变化
        final loadingStateChanged = previous.isLoading != current.isLoading;

        // 3. 同步状态变化
        final syncStatusChanged = previous.syncStatus != current.syncStatus;

        // 4. 错误信息变化
        final errorChanged = previous.errorMessage != current.errorMessage;

        final shouldRebuild = contactsCountChanged ||
            loadingStateChanged ||
            syncStatusChanged ||
            errorChanged;

        if (shouldRebuild) {
          _logger.d('ContactsPage 需要重建', extra: {
            'contactsCountChanged': contactsCountChanged,
            'loadingStateChanged': loadingStateChanged,
            'syncStatusChanged': syncStatusChanged,
            'errorChanged': errorChanged,
          });
        }

        return shouldRebuild;
      },
      listener: (context, state) {
        // 当联系人数据加载完成时，更新分组联系人
        if (!state.isLoading && state.contacts.isNotEmpty) {
          _updateGroupedContacts(state.contacts);
        }

        // 处理错误消息
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: _buildSearchBar(),
            actions: [
              // 同步按钮
              IconButton(
                icon: Icon(
                  Icons.sync,
                  color: state.syncStatus == ContactsSyncStatus.syncing
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: state.syncStatus == ContactsSyncStatus.syncing
                    ? null
                    : _syncContacts,
              ),
              // 添加联系人按钮
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  // TODO 实现添加联系人功能
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, homeState) {
                  return NetworkStatusIndicator(
                    networkStatus: homeState.networkStatus,
                    onRetry: () {
                      // 💢💢💢 修改：通过HomeCubit调用重连
                      context.read<HomeCubit>().reconnect();
                    },
                  );
                },
              ),
            ),
          ),
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 同步状态指示器
                  SliverToBoxAdapter(
                    child: _buildSyncStatusIndicator(),
                  ),

                  // 可折叠的搜索栏
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    floating: true,
                    snap: true,
                    backgroundColor: Colors.grey[200],
                    title: _buildSearchBox(),
                    titleSpacing: 0,
                  ),

                  // 联系人列表
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () {
                        if (_openedItemId != null) {
                          setState(() {
                            _openedItemId = null;
                          });
                        }
                      },
                      child: state.isLoading
                          ? const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : state.errorMessage != null
                              ? SizedBox(
                                  height: 200,
                                  child: Center(
                                      child: Text('错误: ${state.errorMessage}')),
                                )
                              : _isFiltering
                                  ? _buildFilteredList()
                                  : _sortedKeys.isEmpty
                                      ? const SizedBox(
                                          height: 200,
                                          child: Center(child: Text('没有联系人')),
                                        )
                                      : _buildGroupedAnimatedList(),
                    ),
                  ),
                ],
              ),

              // 右侧字母索引栏 - 只在非搜索状态下显示
              if (!_isFiltering)
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
                        color: Colors.black.withAlpha(128),
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
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => const NewChatPage(),
              //   ),
              // );
            },
          ),
        );
      },
    );
  }

  /// 构建字母索引栏
  Widget _buildLetterIndex() {
    // 计算字母索引栏的总高度
    // 每个字母高度为20，不改变这个值
    // 添加额外的顶部和底部空间，确保圆角不会遮挡字母
    final double totalLettersHeight =
        _allIndexes.length * 20.0 + 16; // 增加16像素以适应圆角

    return Container(
      width: 24,
      height: totalLettersHeight,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(51),
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
          itemCount: _allIndexes.length,
          itemBuilder: (context, index) {
            final letter = _allIndexes[index];
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
    return BlocBuilder<ContactCubit, ContactState>(
      buildWhen: (previous, current) =>
          previous.syncStatus != current.syncStatus ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (state.syncStatus == ContactsSyncStatus.syncing) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          );
        } else if (state.errorMessage != null) {
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
                    state.errorMessage ?? '同步联系人失败',
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

  /// 构建搜索框
  Widget _buildSearchBox() {
    return Container(
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
                            _isFiltering = false;
                          });
                          // 清除后重新聚焦到搜索框
                          _searchFocusNode.requestFocus();
                        },
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                // 只更新搜索状态，不执行搜索
                setState(() {
                  _isSearching = value.isNotEmpty;
                  if (!_isSearching) {
                    _isFiltering = false;
                  }
                });
              },
              // 确保输入法完成时不会失去焦点
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                // 提交时执行搜索
                if (value.isNotEmpty) {
                  _searchContacts(value);
                }
                // 提交后重新聚焦到搜索框
                _searchFocusNode.requestFocus();
              },
            ),
          ),
          // 添加搜索按钮
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  final query = _searchController.text;
                  if (query.isNotEmpty) {
                    _searchContacts(query);
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

  /// 构建分组联系人列表
  /// 使用AnimatedList显示按首字母分组的联系人
  Widget _buildGroupedAnimatedList() {
    return ListView.builder(
      // 禁用ListView的滚动功能，因为它已经在CustomScrollView中
      physics: const NeverScrollableScrollPhysics(),
      // 计算总高度，使ListView能够正确显示
      shrinkWrap: true,
      itemCount: _sortedKeys.length,
      itemBuilder: (context, index) {
        final key = _sortedKeys[index];
        final contacts = _groupedContacts[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(key),
            // 使用AnimatedList为每个分组中的联系人项目添加动画效果
            AnimatedList(
              key: ValueKey('group_$key'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: contacts.length,
              itemBuilder: (context, itemIndex, animation) {
                // 这里使用了两种动画效果：
                // 1. SizeTransition - 使项目从小到大展开
                return SizeTransition(
                  sizeFactor: animation,
                  // 2. SlideTransition - 使项目从右侧滑入
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0), // 从右侧开始
                      end: Offset.zero, // 滑动到原位置
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
    return _filteredContacts.isEmpty
        ? const SizedBox(
            height: 200,
            child: Center(child: Text('没有找到匹配的联系人')),
          )
        : ListView.builder(
            // 禁用ListView的滚动功能，因为它已经在CustomScrollView中
            physics: const NeverScrollableScrollPhysics(),
            // 计算总高度，使ListView能够正确显示
            shrinkWrap: true,
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
  /// 显示单个联系人的信息，点击后导航到联系人详情页
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
      onTap: () {
        _logger.i('打开联系人详情页：${contact.name}');
        final contactCubit = context.read<ContactCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: contactCubit,
              child: ContactDetailPage(
                contact: contact,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '搜索联系人',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterContacts('');
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
        onChanged: (value) {
          // 防抖处理，避免频繁搜索
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 300), () {
            _filterContacts(value);
          });
        },
      ),
    );
  }

  /// 过滤联系人
  /// 根据搜索关键词过滤联系人列表
  /// [query] - 搜索关键词
  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _isFiltering = false;
        _filteredContacts = [];
      });
      return;
    }

    final contactCubit = context.read<ContactCubit>();
    final allContacts = contactCubit.state.contacts;

    // 过滤联系人
    final filtered = allContacts.where((contact) {
      final nameMatch =
          contact.name.toLowerCase().contains(query.toLowerCase());
      final pinyinMatch = contact.pinyin != null
          ? contact.pinyin!.toLowerCase().contains(query.toLowerCase())
          : false;
      return nameMatch || pinyinMatch;
    }).toList();

    setState(() {
      _isFiltering = true;
      _filteredContacts = filtered;
    });

    _logger.i('过滤联系人', extra: {
      'query': query,
      'results': filtered.length,
    });
  }
}
