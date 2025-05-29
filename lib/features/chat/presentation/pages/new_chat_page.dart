import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  bool _isLoading = false;
  String? _error;
  List<User> _contacts = [];
  String? _openedItemId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 从HomeCubit中加载联系人数据
      final chatsCubit = context.read<ChatsCubit>();
      await chatsCubit.loadContacts();
      setState(() {
        _contacts = chatsCubit.state.contacts;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchContacts(String query) async {
    if (query.isEmpty) {
      await _loadData();
      return;
    }

    try {
      // 在已加载的联系人中搜索
      final homeCubit = context.read<HomeCubit>();
      final allContacts = homeCubit.state.contacts;

      // 通过名称搜索联系人
      final searchResults = allContacts
          .where((contact) =>
              contact.name.toLowerCase().contains(query.toLowerCase()) ||
              (contact.pinyin?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();

      setState(() {
        _contacts = searchResults;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 导航到聊天详情页的方法
  void _navigateToChat(
      User contact, String conversationId, HomeCubit homeCubit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: homeCubit,
          child: ChatDetailPage(
            contact: contact,
            conversationId: conversationId,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('NewChatPage build');
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('新建聊天', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '搜索联系人',
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                          _loadData();
                        },
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchContacts(value);
                }
              },
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_openedItemId != null) {
            setState(() {
              _openedItemId = null;
            });
          }
        },
        child: _buildContactList(),
      ),
    );
  }

  Widget _buildContactList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('错误: $_error'));
    }

    if (_contacts.isEmpty) {
      return const Center(child: Text('没有联系人'));
    }

    // 按首字母分组
    final Map<String, List<User>> groupedContacts = {};
    for (var contact in _contacts) {
      final firstChar =
          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '#';
      if (!groupedContacts.containsKey(firstChar)) {
        groupedContacts[firstChar] = [];
      }
      groupedContacts[firstChar]!.add(contact);
    }

    // 获取所有首字母并排序
    final sortedKeys = groupedContacts.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final contacts = groupedContacts[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
            ),
            ...contacts.map((contact) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: contact.avatar != null
                        ? NetworkImage(contact.avatar!)
                        : null,
                    child:
                        contact.avatar == null ? Text(contact.name[0]) : null,
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.status ?? ''),
                  onTap: () async {
                    final homeCubit = context.read<HomeCubit>();

                    // 创建或获取与该联系人的会话
                    final conversationId = await homeCubit
                        .getOrCreatePrivateConversation(contact.userId);

                    if (conversationId != null) {
                      if (!mounted) return;

                      // 调用类方法进行导航
                      _navigateToChat(contact, conversationId, homeCubit);
                    }
                  },
                )),
          ],
        );
      },
    );
  }
}
