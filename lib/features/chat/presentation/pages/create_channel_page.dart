import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/constants/app_colors.dart';

/// 创建频道页面
/// 设置频道信息：名称、描述、头像等
class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final _logger = LogService.instance;
  final TextEditingController _channelNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _channelNameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final CommunicationService _communicationService = CommunicationService();
  final SecureStorageService _secureStorage = SecureStorageService();

  String? _channelAvatarPath;
  bool _isCreating = false;
  CurrentUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeUserAndChannelName();
  }

  /// 初始化当前用户信息并设置默认频道名
  Future<void> _initializeUserAndChannelName() async {
    try {
      // 获取当前用户信息
      _currentUser = await _secureStorage.readUserCredentials();

      // 设置默认频道名：XXX(创建者)的频道
      if (_currentUser != null) {
        final creatorName = _truncateText(_currentUser!.name, 4); // 创建者名称限制4个字符
        _channelNameController.text = '$creatorName的频道';
      } else {
        // 如果无法获取当前用户信息，使用备用方案
        _channelNameController.text = '新频道';
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _logger.e('初始化用户信息失败', error: e);
      // 使用备用频道名
      _channelNameController.text = '新频道';
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 截断文本到指定长度
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength);
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    _descriptionController.dispose();
    _channelNameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  /// 选择频道头像
  void _selectChannelAvatar() {
    _logger.i('选择频道头像');
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context).camera),
              onTap: () {
                Navigator.pop(context);
                // TODO: 调用相机
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context).gallery),
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

  /// 创建频道
  void _createChannel() async {
    final channelName = _channelNameController.text.trim();
    if (channelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorOccurred)),
      );
      return;
    }

    if (channelName.length > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('频道名称不能超过24个字符')),
      );
      return;
    }

    if (_isCreating) return; // 防止重复点击

    setState(() {
      _isCreating = true;
    });

    try {
      _logger.i('创建频道', extra: {
        'channelName': channelName,
        'description': _descriptionController.text.trim(),
        'hasAvatar': _channelAvatarPath != null,
      });

      // 检查通信服务是否可用
      if (!_communicationService.isInitialized ||
          !_communicationService.isConnected) {
        throw Exception(AppLocalizations.of(context).networkError);
      }

      // 构建频道创建请求
      final createRequest = conversation_proto.ConversationCreateRequest()
        ..name = channelName
        ..type = conversation_proto.ConversationType.CHANNEL;

      // 设置头像（如果有）
      if (_channelAvatarPath != null && _channelAvatarPath!.isNotEmpty) {
        createRequest.avatar = _channelAvatarPath!;
      }

      _logger.d('发送创建频道请求', extra: {
        'channelName': channelName,
        'description': _descriptionController.text.trim(),
      });

      // 发送创建请求到服务器
      final success = await _communicationService.emitProto(
          'conversation:create', createRequest);

      if (!success) {
        throw Exception(AppLocalizations.of(context).errorOccurred);
      }

      // 等待服务器响应
      final response = await _communicationService
          .onProto<conversation_proto.ConversationCreateResponse>(
              'conversation:create:response')
          .timeout(const Duration(seconds: 10))
          .first;

      if (!response.success) {
        throw Exception(
            '${AppLocalizations.of(context).errorOccurred}: ${response.message}');
      }

      if (!response.hasConversation()) {
        throw Exception(AppLocalizations.of(context).errorOccurred);
      }

      final conversationId = response.conversation.conversationId;
      _logger.i('频道创建成功', extra: {
        'conversationId': conversationId,
        'channelName': channelName,
      });

      if (mounted) {
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('频道"$channelName"创建成功'),
            backgroundColor: Colors.green,
          ),
        );

        // 获取必要的依赖
        final chatRepository = context.read<ChatRepository>();
        final chatsRepository = context.read<ChatsRepository>();
        final chatRepositorySend = context.read<ChatRepositorySend>();

        // 获取当前用户
        final navigator = Navigator.of(context);
        final secureStorageService = SecureStorageService();

        try {
          // 获取当前用户信息
          final currentUser = await secureStorageService.readUserCredentials();
          final currentUserId = currentUser?.userId ?? '';

          // 构建会话对象
          final conversation = ConversationAdapter.fromProto(
            response.conversation,
            currentUserId: currentUserId,
          );

          // 🆕 重要：保存会话到本地数据库
          _logger.i('保存新创建的频道到本地数据库', extra: {
            'conversationId': conversationId,
            'channelName': channelName,
          });

          // 直接保存服务器返回的会话数据到本地数据库
          try {
            await chatsRepository.saveConversation(conversation);
            _logger.i('频道已保存到本地数据库');
          } catch (e) {
            _logger.w('保存频道到本地数据库失败，但创建成功: $e');
            // 即使保存失败，我们也继续进入聊天页面，因为服务器端已经创建成功
          }

          // 关闭所有相关页面并直接进入频道会话
          navigator.popUntil((route) => route.isFirst);

          // 进入频道会话页面，提供必要的依赖
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
                    currentUser: currentUser ?? (CurrentUser()..userId = ''),
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
      _logger.e('创建频道失败', error: error, stackTrace: StackTrace.current);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context).errorOccurred}: ${error.toString()}'),
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
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.createChannel,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createChannel,
            child: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    localizations.next,
                    style: const TextStyle(
                      color: AppColors.primary,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 频道信息设置区域
            _buildChannelInfoSection(),

            const SizedBox(height: 20),

            // 频道描述设置区域
            _buildDescriptionSection(),
          ],
        ),
      ),
    );
  }

  /// 构建频道信息设置区域
  Widget _buildChannelInfoSection() {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 频道头像
          GestureDetector(
            onTap: _selectChannelAvatar,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: _channelAvatarPath != null
                  ? ClipOval(
                      child: Image.asset(
                        _channelAvatarPath!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: AppColors.primary,
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // 频道名称输入框
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _channelNameController,
                  focusNode: _channelNameFocusNode,
                  decoration: InputDecoration(
                    hintText: localizations.channelTitle,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLength: 24, // 限制频道名称长度为24个字符
                  onChanged: (value) {
                    setState(() {}); // 更新清除按钮的显示状态
                  },
                  buildCounter: (context,
                      {required currentLength, required isFocused, maxLength}) {
                    return Text(
                      '$currentLength${maxLength != null ? '/$maxLength' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentLength > 6
                            ? Colors.orange
                            : Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 清除按钮
          if (_channelNameController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[600]),
              onPressed: () {
                _channelNameController.clear();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  /// 构建频道描述设置区域
  Widget _buildDescriptionSection() {
    final localizations = AppLocalizations.of(context);

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
          Text(
            localizations.whatIsChannel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            decoration: InputDecoration(
              hintText: localizations.channelDescription,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }
}
