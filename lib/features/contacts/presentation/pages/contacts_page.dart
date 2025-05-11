import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final LogService _logger = LogService.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    await context.read<ContactsCubit>().loadContacts();
  }

  void _startChat(BuildContext context, User contact) {
    _logger.i('开始聊天', extra: {'contactId': contact.userId, 'contactName': contact.name});

    // 创建或获取与联系人的会话
    context.read<ChatCubit>().startConversationWithUser(
          userId: contact.userId,
          name: contact.name,
          avatar: contact.avatar,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系人'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // 好友请求图标
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: '好友请求',
            onPressed: () {
              Navigator.pushNamed(context, '/contacts/friend_requests');
            },
          ),
          // 搜索图标
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索联系人',
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(context: context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsCubitState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = state.contacts;

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('暂无联系人', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadContacts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('刷新'),
                  ),
                ],
              ),
            );
          }

          // 分组联系人列表
          final Map<String, List<User>> groupedContacts = _groupContactsByFirstLetter(contacts);
          final sortedKeys = groupedContacts.keys.toList()..sort();

          return RefreshIndicator(
            onRefresh: _loadContacts,
            color: Colors.green,
            child: ListView.builder(
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final contactsInGroup = groupedContacts[key]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contactsInGroup.length,
                      itemBuilder: (context, i) {
                        final contact = contactsInGroup[i];
                        return _buildContactItem(context, contact);
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 打开添加联系人页面
          _showAddContactDialog(context);
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, User contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
        child: contact.avatar == null
            ? Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(contact.name),
      subtitle: Text(contact.phone ?? '无电话'),
      onTap: () => _startChat(context, contact),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加联系人'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: '手机号码',
            hintText: '请输入对方手机号码',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 发送好友请求
              final phone = phoneController.text.trim();
              if (phone.isEmpty) return;

              Navigator.pop(context);
              _showSendRequestDialog(context, phone);
            },
            child: const Text('查找'),
          ),
        ],
      ),
    );
  }

  void _showSendRequestDialog(BuildContext context, String phone) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送好友请求'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('向 $phone 发送好友请求'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: '验证信息',
                hintText: '请输入验证信息',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 实际发送好友请求
              final message = messageController.text.trim();

              // 这里需要先根据手机号查找用户,然后发送请求
              // 由于这是模拟,我们直接使用一个模拟ID
              final mockUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';

              context.read<ContactsCubit>().sendFriendRequest(
                    mockUserId,
                    message.isEmpty ? '我是你的好友,请求添加' : message,
                  );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('好友请求已发送')),
              );
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  // 按首字母分组联系人
  Map<String, List<User>> _groupContactsByFirstLetter(List<User> contacts) {
    final Map<String, List<User>> groupedContacts = {};

    for (final contact in contacts) {
      String firstLetter = '#';

      if (contact.name.isNotEmpty) {
        // 获取拼音首字母,如果有的话
        if (contact.pinyin != null && contact.pinyin!.isNotEmpty) {
          firstLetter = contact.pinyin![0].toUpperCase();
        } else {
          // 否则使用名称首字母
          firstLetter = contact.name[0].toUpperCase();
        }
      }

      // 确保分组键是字母或#
      if (!RegExp(r'[A-Z]').hasMatch(firstLetter)) {
        firstLetter = '#';
      }

      // 添加到相应分组
      groupedContacts.putIfAbsent(firstLetter, () => []).add(contact);
    }

    // 对每个分组内的联系人按姓名排序
    groupedContacts.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    return groupedContacts;
  }
}

class ContactSearchDelegate extends SearchDelegate<String> {
  final BuildContext context;

  ContactSearchDelegate({required this.context});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('请输入搜索关键词'),
      );
    }

    return FutureBuilder<List<User>>(
      future: context.read<ContactsCubit>().searchContacts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text('未找到 "$query" 相关联系人', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        final contacts = snapshot.data!;
        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
                child: contact.avatar == null
                    ? Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(contact.name),
              subtitle: Text(contact.phone ?? '无电话'),
              onTap: () {
                close(context, contact.userId);
                // 打开聊天
                context.read<ChatCubit>().startConversationWithUser(
                      userId: contact.userId,
                      name: contact.name,
                      avatar: contact.avatar,
                    );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('输入名称、拼音或手机号码进行搜索'),
    );
  }
}
