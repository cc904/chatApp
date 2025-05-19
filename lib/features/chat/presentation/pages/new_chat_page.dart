import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';

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
    _logger.d('NewChatPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建聊天', style: TextStyle(fontWeight: FontWeight.w600)),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
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
                    backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
                    child: contact.avatar == null ? Text(contact.name[0]) : null,
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.status ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                          contact: contact,
                          conversationId: '', // TODO: 创建新会话
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
}
