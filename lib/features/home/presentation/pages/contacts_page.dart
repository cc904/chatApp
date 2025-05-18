import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_state.dart' as states;
import 'package:cc/features/contacts/presentation/cubit/contacts_state_adapter.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // 加载联系人数据
    // _loadContacts();
    _logger.d('-------> initState');
    _syncContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncContacts() {
    _logger.d('-------> _syncContacts');
    final contactsCubit = context.read<ContactsCubit>();
    contactsCubit.syncContacts();
  }

  // 加载本地联系人数据
  void _loadContacts() {
    final contactsCubit = context.read<ContactsCubit>();
    contactsCubit.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('ContactsPage build');
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索联系人',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  // 搜索联系人
                  _performSearch(value);
                },
              )
            : const Text('通讯录', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  // 清除搜索,显示全部联系人
                  context.read<ContactsCubit>().loadContacts();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // 扫描二维码
              _logger.d('扫描二维码');
            },
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsCubitState>(
        builder: (context, cubitState) {
          // 使用适配器转换状态
          final state = ContactsStateAdapter.adapt(cubitState);

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('错误: ${state.error}'));
          }

          // 显示搜索结果
          if (state.isSearching) {
            if (state.searchResults.isEmpty) {
              return const Center(child: Text('没有找到匹配的联系人'));
            }

            return ListView.separated(
              itemCount: state.searchResults.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final contact = state.searchResults[index];
                return _buildContactItem(
                  contact: contact,
                );
              },
            );
          }

          // 如果没有联系人数据,显示空状态
          if (state.contacts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无联系人', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('点击右上角+添加联系人', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }

          // 显示分组列表
          return ListView.builder(
            itemCount: _getTotalItemCount(state),
            itemBuilder: (context, index) {
              // 构建最终的索引到UI映射
              return _buildListItem(context, index, state);
            },
          );
        },
      ),
    );
  }

  // 计算列表总项目数（字母标题+联系人）
  int _getTotalItemCount(states.ContactsState state) {
    // 每个字母分组 + 该分组下的联系人数量
    int count = 0;
    for (var letter in state.sectionLetters) {
      // 加1是因为有一个字母分组标题
      count += 1 + (state.groupedContacts[letter]?.length ?? 0).toInt();
    }
    return count;
  }

  // 根据索引构建相应的列表项（字母标题或联系人）
  Widget _buildListItem(BuildContext context, int index, states.ContactsState state) {
    // 跟踪当前索引和偏移
    int currentIndex = 0;

    // 遍历所有字母分组
    for (var letter in state.sectionLetters) {
      // 如果当前索引就是我们要找的索引,返回字母标题
      if (currentIndex == index) {
        return _buildSectionHeader(letter);
      }
      currentIndex++;

      // 获取该字母下的联系人
      final contacts = state.groupedContacts[letter] ?? [];

      // 检查联系人项是否在这个字母组内
      if (index < currentIndex + contacts.length) {
        // 计算联系人在当前字母组内的索引
        final contactIndex = index - currentIndex;
        return _buildContactItem(
          contact: contacts[contactIndex],
        );
      }

      // 更新当前索引为下一个字母组的起始索引
      currentIndex += contacts.length.toInt();
    }

    // 如果索引超出范围（不应该发生）
    return const SizedBox();
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildContactItem({required User contact}) {
    // 决定子标题显示电话还是状态
    final phone = contact.phone ?? '';
    final subtitle = phone.isNotEmpty ? '+86 $phone' : '状态: ${contact.status ?? '离线'}';

    // 获取头像值
    final avatar = contact.avatar;
    final hasAvatar = avatar != null && avatar.isNotEmpty;

    // 判断是否为颜色值
    final isColorAvatar = hasAvatar && avatar.startsWith('#');

    // 解析颜色
    Color? avatarColor;
    if (isColorAvatar) {
      try {
        final hexCode = avatar.replaceFirst('#', '');
        avatarColor = Color(int.parse('FF$hexCode', radix: 16));
      } catch (error) {
        avatarColor = Colors.green[100];
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (hasAvatar && !isColorAvatar) ? NetworkImage(avatar) : null,
        backgroundColor: isColorAvatar ? avatarColor : Colors.green[100],
        radius: 24,
        child: (!hasAvatar || isColorAvatar)
            ? Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isColorAvatar ? Colors.white : Colors.green,
                ),
              )
            : null,
      ),
      title: Text(
        contact.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      onTap: () {
        // 打开联系人详情
        _logger.d('打开联系人', extra: {'name': contact.name});
      },
    );
  }

  void _performSearch(String value) async {
    final contactsCubit = context.read<ContactsCubit>();
    // 如果搜索为空,显示所有联系人
    if (value.isEmpty) {
      ContactsStateAdapter.clearSearch();
      contactsCubit.loadContacts();
      return;
    }
    // 执行搜索
    final searchResults = await contactsCubit.searchContacts(value);
    _logger.d('搜索结果', extra: {'query': value, 'count': searchResults.length});

    // 更新适配器存储的搜索结果
    ContactsStateAdapter.setSearchResults(value, searchResults);

    // 强制UI刷新
    setState(() {});
  }
}
