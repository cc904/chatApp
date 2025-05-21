import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/presentation/pages/new_chat_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  bool _isSearching = false;
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
      // TODO: 从数据库加载联系人数据
      await Future.delayed(const Duration(seconds: 1)); // 模拟加载
      setState(() {
        _contacts = []; // 替换为实际数据
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
      // TODO: 实现搜索逻辑
      setState(() {
        _contacts = []; // 替换为搜索结果
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

  @override
  Widget build(BuildContext context) {
    _logger.d('ContactsPage build');
    return Scaffold(
      appBar: AppBar(
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
              _logger.d('打开添加联系人页面');
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
                              });
                              _loadData();
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
      final firstChar = contact.name[0].toUpperCase();
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                          contact: contact,
                          conversationId: '', // TODO: 从数据库获取或创建会话ID
                        ),
                      ),
                    );
                  },
                )),
          ],
        );
      },
    );
  }

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
                _logger.d('筛选星标联系人');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('群组'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选群组');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.green),
              title: const Text('已屏蔽'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选已屏蔽联系人');
              },
            ),
          ],
        ),
      ),
    );
  }
}
