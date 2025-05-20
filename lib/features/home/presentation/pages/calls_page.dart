import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  bool _isSearching = false;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _calls = [];
  final List<Map<String, dynamic>> _filteredCalls = [];
  String? _openedItemId;

  // 添加ChatCubit实例
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    // 初始化ChatCubit实例
    final chatRepository = ChatRepositoryImpl();
    _chatCubit = ChatCubit(repository: chatRepository);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: 从数据库加载通话记录
      await Future.delayed(const Duration(seconds: 1)); // 模拟加载
      setState(() {
        _calls = []; // 替换为实际数据
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

  Future<void> _searchCalls(String query) async {
    if (query.isEmpty) {
      await _loadData();
      return;
    }

    try {
      // TODO: 实现搜索逻辑
      setState(() {
        _calls = []; // 替换为搜索结果
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
    _chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('CallsPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('通话', style: TextStyle(fontWeight: FontWeight.w600)),
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
            icon: const Icon(Icons.call),
            onPressed: () {
              _logger.d('发起新通话');
              // TODO: 实现发起新通话
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
                                  _searchCalls(query);
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
                  _searchCalls(value);
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
        child: _buildCallList(),
      ),
    );
  }

  Widget _buildCallList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('错误: $_error'));
    }

    if (_calls.isEmpty) {
      return const Center(child: Text('没有通话记录'));
    }

    return ListView.builder(
      itemCount: _calls.length,
      itemBuilder: (context, index) {
        final call = _calls[index];
        final contact = call['contact'] as User;
        final isOutgoing = call['isOutgoing'] as bool;
        final isMissed = call['isMissed'] as bool;
        final time = call['time'] as DateTime;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                contact.avatar != null ? NetworkImage(contact.avatar!) : null,
            child: contact.avatar == null ? Text(contact.name[0]) : null,
          ),
          title: Text(contact.name),
          subtitle: Text(
            isMissed
                ? '未接来电'
                : isOutgoing
                    ? '已拨出'
                    : '已接听',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(time),
                style: const TextStyle(fontSize: 12),
              ),
              Icon(
                isOutgoing ? Icons.call_made : Icons.call_received,
                color: isMissed ? Colors.red : Colors.green,
                size: 16,
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: _chatCubit,
                  child: ChatDetailPage(
                    contact: contact,
                    conversationId: '', // TODO: 从数据库获取或创建会话ID
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}/${time.day}';
    }
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
              '筛选通话',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.call_made, color: Colors.green),
              title: const Text('已拨出'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选已拨出通话');
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_received, color: Colors.green),
              title: const Text('已接听'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选已接听通话');
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_missed, color: Colors.red),
              title: const Text('未接来电'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选未接来电');
              },
            ),
          ],
        ),
      ),
    );
  }
}
