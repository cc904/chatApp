import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:cc/features/contacts/presentation/pages/contact_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final _logger = LogService.instance;
  bool _isSearching = false;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _calls = [];
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
      // 从HomeCubit获取通话记录
      final homeCubit = context.read<HomeCubit>();
      await homeCubit.loadCallHistory();

      setState(() {
        // 使用正确的字段名称 calls，并进行类型转换
        _calls = List<Map<String, dynamic>>.from(homeCubit.state.calls);
        _isLoading = false;
      });

      _logger.d('加载通话记录成功，共 ${_calls.length} 条记录');
    } catch (e) {
      _logger.e('加载通话记录失败', error: e);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchCalls(String query) async {
    if (query.isEmpty) {
      await _loadData();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 使用HomeCubit搜索通话记录
      final homeCubit = context.read<HomeCubit>();
      final results = homeCubit.state.calls
          .where((call) {
            final contact = call['contact'] as User;
            return contact.name.toLowerCase().contains(query.toLowerCase());
          })
          .map((call) => Map<String, dynamic>.from(call))
          .toList();

      setState(() {
        _calls = results;
        _isLoading = false;
      });

      _logger.d('搜索通话记录成功，共 ${_calls.length} 条结果');
    } catch (e) {
      _logger.e('搜索通话记录失败', error: e);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => previous.contacts != current.contacts,
      builder: (context, state) {
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
                backgroundImage: contact.avatar != null
                    ? NetworkImage(contact.avatar!)
                    : null,
                child: contact.avatar == null ? Text(contact.name[0]) : null,
              ),
              title: Text(contact.name),
              subtitle: Text(
                isMissed
                    ? '未接来电'
                    : isOutgoing
                        ? '已拨出'
                        : '已接听',
                style: TextStyle(
                  color: isMissed ? Colors.red : Colors.grey[600],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCallTime(time),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isOutgoing ? Icons.call_made : Icons.call_received,
                      size: 18,
                      color: isMissed ? Colors.red : Colors.green,
                    ),
                    onPressed: () {
                      _logger.d('回拨通话');
                      _makeCall(contact);
                    },
                  ),
                ],
              ),
              onTap: () {
                _openContactDetail(contact);
              },
              onLongPress: () {
                setState(() {
                  _openedItemId = call['id'] as String;
                });
                _showCallOptions(call);
              },
            );
          },
        );
      },
    );
  }

  String _formatCallTime(DateTime time) {
    // 获取当前时间
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(time.year, time.month, time.day);

    // 格式化时间
    String formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    // 根据日期返回不同格式
    if (callDate == today) {
      return formattedTime; // 今天
    } else if (callDate == yesterday) {
      return '昨天 $formattedTime'; // 昨天
    } else {
      return '${time.month}-${time.day} $formattedTime'; // 其他日期
    }
  }

  void _makeCall(User contact) {
    // TODO: 实现通话功能
    _logger.d('拨打电话', extra: {'contactId': contact.userId});
  }

  void _openContactDetail(User contact) {
    _logger.d('打开联系人详情页: ${contact.name}');
    final homeCubit = context.read<HomeCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: homeCubit,
          child: ContactDetailPage(
            contact: contact,
          ),
        ),
      ),
    );
  }

  void _openChatDetail(User contact) {
    _logger.d('打开与${contact.name}的聊天');
    // 通过HomeCubit创建或获取与联系人的会话
    final homeCubit = context.read<HomeCubit>();
    homeCubit
        .getOrCreatePrivateConversation(contact.userId)
        .then((conversationId) {
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
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('筛选通话记录'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 筛选所有通话
              },
              child: const Text('所有通话'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 筛选未接来电
              },
              child: const Text('未接来电'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 筛选已拨电话
              },
              child: const Text('已拨电话'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 筛选已接来电
              },
              child: const Text('已接来电'),
            ),
          ],
        );
      },
    );
  }

  void _showCallOptions(Map<String, dynamic> call) {
    final contact = call['contact'] as User;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.call),
                title: const Text('语音通话'),
                onTap: () {
                  Navigator.pop(context);
                  _makeCall(contact);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('视频通话'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现视频通话
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('发送消息'),
                onTap: () {
                  Navigator.pop(context);
                  _openChatDetail(contact);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除此记录'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 删除此通话记录
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
