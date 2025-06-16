import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_state.dart';

/// 联系人列表显示模式
enum ContactListMode {
  /// 普通模式：只显示联系人，点击触发onContactTap
  normal,

  /// 选择模式：显示复选框，支持多选
  selection,

  /// 详情模式：点击进入联系人详情页
  detail,
}

/// 联系人列表组件
/// 通用的联系人列表，支持分组、搜索、字母索引、不同交互模式
class ContactListWidget extends StatefulWidget {
  /// 显示模式
  final ContactListMode mode;

  /// 是否显示搜索框
  final bool showSearchBox;

  /// 是否显示字母索引
  final bool showAlphabetIndex;

  /// 是否可滚动（当作为子组件使用时设为false）
  final bool shrinkWrap;

  /// 滚动控制器
  final ScrollController? scrollController;

  /// 点击联系人回调
  final void Function(User contact)? onContactTap;

  /// 选择状态改变回调（选择模式下使用）
  final void Function(User contact, bool selected)? onSelectionChanged;

  /// 当前选中的联系人列表（选择模式下使用）
  final List<User> selectedContacts;

  /// 搜索框提示文本
  final String searchHint;

  /// 自定义联系人项构建器
  final Widget Function(User contact, {VoidCallback? onTap})?
      contactItemBuilder;

  const ContactListWidget({
    super.key,
    this.mode = ContactListMode.normal,
    this.showSearchBox = true,
    this.showAlphabetIndex = true,
    this.shrinkWrap = false,
    this.scrollController,
    this.onContactTap,
    this.onSelectionChanged,
    this.selectedContacts = const [],
    this.searchHint = 'Search',
    this.contactItemBuilder,
  });

  @override
  State<ContactListWidget> createState() => _ContactListWidgetState();
}

class _ContactListWidgetState extends State<ContactListWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late ScrollController _scrollController;

  // 分组联系人数据结构
  final Map<String, List<User>> _groupedContacts = {};
  List<String> _sortedKeys = [];

  // 用于搜索结果
  List<User> _filteredContacts = [];
  bool _isFiltering = false;
  String? _currentLetter;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();

    // 确保联系人数据已加载
    _ensureContactsLoaded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// 确保联系人数据已加载
  void _ensureContactsLoaded() {
    final contactCubit = context.read<ContactCubit>();
    if (contactCubit.state.contacts.isEmpty && !contactCubit.state.isLoading) {
      contactCubit.loadContacts();
    } else {
      _updateGroupedContacts(contactCubit.state.contacts);
    }
  }

  /// 更新分组联系人数据
  void _updateGroupedContacts(List<User> contacts) {
    _groupedContacts.clear();

    for (var contact in contacts) {
      if (contact.name.isEmpty) continue;

      final firstChar = contact.name[0];
      String groupKey;

      if (RegExp(r'[A-Za-z]').hasMatch(firstChar)) {
        groupKey = firstChar.toUpperCase();
      } else if (RegExp(r'[0-9]').hasMatch(firstChar)) {
        groupKey = '#';
      } else {
        if (contact.pinyin != null && contact.pinyin!.isNotEmpty) {
          final firstPinyinChar = contact.pinyin![0].toUpperCase();
          if (RegExp(r'[A-Z]').hasMatch(firstPinyinChar)) {
            groupKey = firstPinyinChar;
          } else {
            groupKey = '#';
          }
        } else {
          groupKey = '#';
        }
      }

      if (!_groupedContacts.containsKey(groupKey)) {
        _groupedContacts[groupKey] = [];
      }
      _groupedContacts[groupKey]!.add(contact);
    }

    // 对每个分组内的联系人排序
    for (var key in _groupedContacts.keys) {
      _groupedContacts[key]!.sort((a, b) {
        if (a.pinyin != null && b.pinyin != null) {
          return a.pinyin!.compareTo(b.pinyin!);
        }
        return a.name.compareTo(b.name);
      });
    }

    _sortedKeys = _groupedContacts.keys.toList()..sort();
  }

  /// 搜索联系人
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
              (contact.pinyin?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    });
  }

  /// 滚动到指定字母
  void _scrollToLetter(String letter) {
    setState(() {
      _currentLetter = letter;
    });

    if (letter == '🔍') {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _searchFocusNode.requestFocus();
    } else {
      final index = _sortedKeys.indexOf(letter);
      if (index != -1) {
        double offset = widget.showSearchBox ? 60 : 0;

        for (int i = 0; i < index; i++) {
          final key = _sortedKeys[i];
          final contactsCount = _groupedContacts[key]?.length ?? 0;
          offset += 36 + contactsCount * 72; // 分组标题 + 联系人项高度
        }

        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentLetter = null;
        });
      }
    });
  }

  /// 处理联系人点击
  void _handleContactTap(User contact) {
    if (widget.mode == ContactListMode.selection) {
      // 选择模式：切换选择状态
      final isSelected = widget.selectedContacts.contains(contact);
      widget.onSelectionChanged?.call(contact, !isSelected);
    } else {
      // 普通模式或详情模式：调用回调
      widget.onContactTap?.call(contact);
    }
  }

  /// 计算总项目数量
  int _calculateTotalItems() {
    int count = 0;
    for (var key in _sortedKeys) {
      count += 1; // 分组标题
      count += _groupedContacts[key]?.length ?? 0; // 联系人项
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactCubit, ContactState>(
      listener: (context, state) {
        if (!state.isLoading && state.contacts.isNotEmpty) {
          _updateGroupedContacts(state.contacts);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Column(
              children: [
                // 搜索框
                if (widget.showSearchBox) _buildSearchBox(),

                // 联系人列表
                Expanded(
                  child: _buildContactsList(state),
                ),
              ],
            ),

            // 字母索引
            if (widget.showAlphabetIndex && !_isFiltering)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: _buildAlphabetIndex(),
              ),

            // 当前字母指示器
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
        );
      },
    );
  }

  /// 构建搜索框
  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 16),
        onChanged: _searchContacts,
      ),
    );
  }

  /// 构建联系人列表
  Widget _buildContactsList(ContactState state) {
    if (state.isLoading && state.contacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('加载联系人失败', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<ContactCubit>().loadContacts(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final contactsToShow = _isFiltering ? _filteredContacts : state.contacts;

    if (contactsToShow.isEmpty) {
      return Center(
        child: Text(
          _isFiltering ? '没有找到匹配的联系人' : '暂无联系人',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    if (_isFiltering) {
      return ListView.builder(
        controller: widget.shrinkWrap ? null : _scrollController,
        shrinkWrap: widget.shrinkWrap,
        physics:
            widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
        itemCount: contactsToShow.length,
        itemBuilder: (context, index) {
          return _buildContactItem(contactsToShow[index]);
        },
      );
    }

    return ListView.builder(
      controller: widget.shrinkWrap ? null : _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: _calculateTotalItems(),
      itemBuilder: (context, index) {
        return _buildGroupedContactItem(index);
      },
    );
  }

  /// 构建分组联系人项
  Widget _buildGroupedContactItem(int index) {
    int currentIndex = 0;

    for (final key in _sortedKeys) {
      if (currentIndex == index) {
        return _buildGroupHeader(key);
      }
      currentIndex++;

      final contacts = _groupedContacts[key] ?? [];
      for (int i = 0; i < contacts.length; i++) {
        if (currentIndex == index) {
          return _buildContactItem(contacts[i]);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  /// 构建分组标题
  Widget _buildGroupHeader(String key) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          key,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  /// 构建联系人项
  Widget _buildContactItem(User contact) {
    if (widget.contactItemBuilder != null) {
      return widget.contactItemBuilder!(
        contact,
        onTap: () => _handleContactTap(contact),
      );
    }

    if (widget.mode == ContactListMode.selection) {
      return _buildSelectionContactItem(contact);
    }

    return _buildNormalContactItem(contact);
  }

  /// 构建普通联系人项
  Widget _buildNormalContactItem(User contact) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildContactAvatar(contact),
      title: Text(
        contact.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: _buildContactSubtitle(contact),
      onTap: () => _handleContactTap(contact),
    );
  }

  /// 构建带选择功能的联系人项
  Widget _buildSelectionContactItem(User contact) {
    final isSelected = widget.selectedContacts.contains(contact);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          _buildContactAvatar(contact),
        ],
      ),
      title: Text(
        contact.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: _buildContactSubtitle(contact),
      onTap: () => _handleContactTap(contact),
    );
  }

  /// 构建联系人头像
  Widget _buildContactAvatar(User contact) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          backgroundImage: contact.avatar?.isNotEmpty == true
              ? NetworkImage(contact.avatar!)
              : null,
          child: contact.avatar?.isEmpty != false
              ? Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        // 在线状态指示器
        if (_isContactOnline(contact))
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建联系人副标题
  Widget _buildContactSubtitle(User contact) {
    if (contact.status?.isNotEmpty == true) {
      return Text(
        contact.status!,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (contact.lastActiveTime != null) {
      final now = DateTime.now();
      final diff = now.difference(contact.lastActiveTime!);

      String timeText;
      if (diff.inMinutes < 5) {
        timeText = 'last seen recently';
      } else if (diff.inHours < 1) {
        timeText = 'last seen ${diff.inMinutes} minutes ago';
      } else if (diff.inDays < 1) {
        timeText = 'last seen ${diff.inHours} hours ago';
      } else if (diff.inDays < 30) {
        timeText = 'last seen ${diff.inDays} days ago';
      } else {
        timeText = 'last seen a long time ago';
      }

      return Text(
        timeText,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      );
    }

    return Text(
      'last seen a long time ago',
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }

  /// 判断联系人是否在线
  bool _isContactOnline(User contact) {
    if (contact.lastActiveTime == null) return false;
    final now = DateTime.now();
    final diff = now.difference(contact.lastActiveTime!);
    return diff.inMinutes < 5; // 5分钟内认为在线
  }

  /// 构建字母索引
  Widget _buildAlphabetIndex() {
    final allIndexes = ['🔍', ..._sortedKeys];

    return Container(
      width: 24,
      margin: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: allIndexes.map((index) {
          return GestureDetector(
            onTap: () => _scrollToLetter(index),
            child: Container(
              height: 20,
              alignment: Alignment.center,
              child: Text(
                index,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      _currentLetter == index ? Colors.blue : Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
