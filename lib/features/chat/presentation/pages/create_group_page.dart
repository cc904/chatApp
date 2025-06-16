import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;
import 'package:cc/features/chat/presentation/pages/chat_page.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';

/// 创建群聊页面
/// 设置群聊信息：头像、名称、设置等
class CreateGroupPage extends StatefulWidget {
  /// 选中的群成员
  final List<User> selectedMembers;

  const CreateGroupPage({
    super.key,
    required this.selectedMembers,
  });

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _logger = LogService.instance;
  final TextEditingController _groupNameController = TextEditingController();
  final FocusNode _groupNameFocusNode = FocusNode();
  final CommunicationService _communicationService = CommunicationService();

  bool _autoDeleteMessages = false;
  String? _groupAvatarPath;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // 设置默认群名
    if (widget.selectedMembers.isNotEmpty) {
      final names =
          widget.selectedMembers.take(2).map((m) => m.name).join(', ');
      final remaining = widget.selectedMembers.length - 2;
      if (remaining > 0) {
        _groupNameController.text = '$names and $remaining others';
      } else {
        _groupNameController.text = names;
      }
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupNameFocusNode.dispose();
    super.dispose();
  }

  /// 选择群头像
  void _selectGroupAvatar() {
    // TODO: 实现头像选择功能
    _logger.i('选择群头像');
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 调用相机
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 从相册选择
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 创建群聊
  void _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入群聊名称')),
      );
      return;
    }

    if (_isCreating) return; // 防止重复点击

    setState(() {
      _isCreating = true;
    });

    try {
      _logger.i('创建群聊', extra: {
        'groupName': groupName,
        'memberCount': widget.selectedMembers.length,
        'autoDeleteMessages': _autoDeleteMessages,
        'hasAvatar': _groupAvatarPath != null,
      });

      // 检查通信服务是否可用
      if (!_communicationService.isInitialized ||
          !_communicationService.isConnected) {
        throw Exception('网络连接不可用，请检查网络状态');
      }

      // 构建群聊创建请求
      final createRequest = conversation_proto.ConversationCreateRequest()
        ..name = groupName
        ..type = conversation_proto.ConversationType.GROUP
        ..participantIds.addAll(widget.selectedMembers.map((m) => m.userId));

      // 设置头像（如果有）
      if (_groupAvatarPath != null && _groupAvatarPath!.isNotEmpty) {
        createRequest.avatar = _groupAvatarPath!;
      }

      _logger.d('发送创建群聊请求', extra: {
        'groupName': groupName,
        'participantCount': widget.selectedMembers.length,
        'participantIds': widget.selectedMembers.map((m) => m.userId).toList(),
      });

      // 发送创建请求到服务器
      final success = await _communicationService.emitProto(
          'conversation:create', createRequest);

      if (!success) {
        throw Exception('发送创建群聊请求失败');
      }

      // 等待服务器响应
      final response = await _communicationService
          .onProto<conversation_proto.ConversationCreateResponse>(
              'conversation:create:response')
          .timeout(const Duration(seconds: 10))
          .first;

      if (!response.success) {
        throw Exception('创建群聊失败: ${response.message}');
      }

      if (!response.hasConversation()) {
        throw Exception('服务器响应中缺少会话数据');
      }

      final conversationId = response.conversation.conversationId;
      _logger.i('群聊创建成功', extra: {
        'conversationId': conversationId,
        'groupName': groupName,
      });

      if (mounted) {
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('群聊"$groupName"创建成功'),
            backgroundColor: Colors.green,
          ),
        );

        // 获取必要的依赖
        final chatRepository = context.read<ChatRepository>();
        final chatsRepository = context.read<ChatsRepository>();
        final chatRepositorySend = context.read<ChatRepositorySend>();

        // 获取当前用户
        final navigator = Navigator.of(context);

        try {
          // 构建会话对象
          final conversation = ConversationAdapter.fromProto(
            response.conversation,
            currentUserId: '', // 暂时为空，会在ChatCubit中正确设置
          );

          // 关闭所有相关页面并直接进入群聊会话
          navigator.popUntil((route) => route.isFirst);

          // 进入群聊会话页面，提供必要的依赖
          navigator.push(
            MaterialPageRoute(
              builder: (context) => MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<ChatRepository>.value(
                      value: chatRepository),
                  RepositoryProvider<ChatsRepository>.value(
                      value: chatsRepository),
                  RepositoryProvider<ChatRepositorySend>.value(
                      value: chatRepositorySend),
                ],
                child: BlocProvider<ChatCubit>(
                  create: (context) => ChatCubit(
                    chatRepository: chatRepository,
                    chatRepositorySend: chatRepositorySend,
                    chatsRepository: chatsRepository,
                    currentUser: CurrentUser()
                      ..userId = '', // 这会被ChatCubit正确初始化
                    initialConversation: conversation,
                  ),
                  child: ChatPage(
                    conversationId: conversationId,
                    initialConversation: conversation,
                  ),
                ),
              ),
            ),
          );
        } catch (error) {
          _logger.e('创建ChatCubit失败', error: error);
          // 如果创建失败，至少显示成功消息并返回主页
        }
      }
    } catch (error) {
      _logger.e('创建群聊失败', error: error, stackTrace: StackTrace.current);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建群聊失败: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createGroup,
            child: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : const Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 群头像和名称设置区域
            _buildGroupInfoSection(),

            const SizedBox(height: 24),

            // 自动删除消息设置
            _buildAutoDeleteSection(),

            const SizedBox(height: 24),

            // 群成员列表
            _buildMembersSection(),
          ],
        ),
      ),
    );
  }

  /// 构建群信息设置区域
  Widget _buildGroupInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 群头像
          GestureDetector(
            onTap: _selectGroupAvatar,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: _groupAvatarPath != null
                  ? ClipOval(
                      child: Image.asset(
                        _groupAvatarPath!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: Colors.blue[600],
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // 群名称输入框
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _groupNameController,
                  focusNode: _groupNameFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Group name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLength: 50,
                  buildCounter: (context,
                      {required currentLength, required isFocused, maxLength}) {
                    return Text(
                      '$currentLength${maxLength != null ? '/$maxLength' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),

                // 显示成员数量
                Text(
                  '${widget.selectedMembers.length} members',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 清除按钮
          if (_groupNameController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[600]),
              onPressed: () {
                _groupNameController.clear();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  /// 构建自动删除消息设置区域
  Widget _buildAutoDeleteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto-Delete Messages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automatically delete messages in this group for everyone after a period of time.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoDeleteMessages,
                onChanged: (value) {
                  setState(() {
                    _autoDeleteMessages = value;
                  });
                },
              ),
            ],
          ),

          // 当开启自动删除时显示更多选项
          if (_autoDeleteMessages) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Delete after:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTimeOption('24 hours'),
                _buildTimeOption('7 days'),
                _buildTimeOption('90 days'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 构建时间选项按钮
  Widget _buildTimeOption(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  /// 构建群成员列表区域
  Widget _buildMembersSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Members (${widget.selectedMembers.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Divider(height: 1),

          // 成员列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.selectedMembers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final member = widget.selectedMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: member.avatar?.isNotEmpty == true
                      ? NetworkImage(member.avatar!)
                      : null,
                  child: member.avatar?.isEmpty != false
                      ? Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: member.status?.isNotEmpty == true
                    ? Text(
                        member.status!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      )
                    : Text(
                        'last seen a long time ago',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: () {
                    setState(() {
                      widget.selectedMembers.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
