import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 聊天功能测试页面
/// 用于验证聊天功能是否正常运行
class ChatTestPage extends StatefulWidget {
  const ChatTestPage({super.key});

  @override
  State<ChatTestPage> createState() => _ChatTestPageState();
}

class _ChatTestPageState extends State<ChatTestPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _currentConversationId = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // 加载会话和联系人
    final chatCubit = context.read<ChatCubit>();
    await chatCubit.loadConversations();
    await chatCubit.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天测试'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索消息...',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<ChatCubit>().searchMessages(value, conversationId: _currentConversationId.isEmpty ? null : _currentConversationId);
                  }
                },
              ),
            ),

          // 主体内容
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null) {
                  return Center(child: Text('错误: ${state.error}'));
                }

                // 显示搜索结果
                if (_isSearching && state.searchResults.isNotEmpty) {
                  return _buildSearchResults(state.searchResults);
                }

                // 显示会话或消息
                return Row(
                  children: [
                    // 会话列表
                    Expanded(
                      flex: 1,
                      child: _buildConversationList(state),
                    ),

                    // 会话内容
                    Expanded(
                      flex: 3,
                      child: _currentConversationId.isEmpty ? const Center(child: Text('请选择一个会话')) : _buildMessageList(state),
                    ),
                  ],
                );
              },
            ),
          ),

          // 消息输入框
          if (_currentConversationId.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '输入消息...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        context.read<ChatCubit>().sendTextMessage(_currentConversationId, message);
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 构建会话列表
  Widget _buildConversationList(ChatState state) {
    return ListView.builder(
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return ListTile(
          title: Text(conversation.name ?? '未命名会话'),
          subtitle: Text(conversation.lastMessagePreview ?? '暂无消息'),
          selected: conversation.id.toString() == _currentConversationId,
          trailing: conversation.unreadCount > 0
              ? CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                )
              : null,
          onTap: () {
            setState(() {
              _currentConversationId = conversation.id.toString();
            });
            context.read<ChatCubit>().setCurrentConversation(conversation.id.toString());
          },
        );
      },
    );
  }

  // 构建消息列表
  Widget _buildMessageList(ChatState state) {
    final messages = state.currentMessages;

    return Column(
      children: [
        // 会话标题
        if (state.currentConversation != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              state.currentConversation!.name ?? '未命名会话',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

        Expanded(
          child: ListView.builder(
            reverse: true, // 最新消息显示在底部
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageItem(message);
            },
          ),
        ),
      ],
    );
  }

  // 构建搜索结果
  Widget _buildSearchResults(List<dynamic> results) {
    if (results.isEmpty) {
      return const Center(child: Text('无搜索结果'));
    }

    // 如果是消息搜索结果
    if (results.first is Message) {
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final message = results[index] as Message;
          return ListTile(
            title: Text(message.text ?? ''),
            subtitle: Text('会话: ${message.conversationId} - ${message.createdAt.toString()}'),
            onTap: () {
              setState(() {
                _currentConversationId = message.conversationId;
                _isSearching = false;
                _searchController.clear();
              });
              context.read<ChatCubit>().setCurrentConversation(message.conversationId);
            },
          );
        },
      );
    }

    return const Center(child: Text('不支持的搜索结果类型'));
  }

  // 构建消息项
  Widget _buildMessageItem(Message message) {
    final isFromMe = message.senderId == '1'; // 使用当前用户ID
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFromMe ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isFromMe && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.senderName!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            Text(message.text ?? '[非文本消息]'),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
