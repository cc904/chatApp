import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/app_lifecycle_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_state.dart';
import 'package:cc/features/contacts/presentation/widgets/contact_list_widget.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/features/contacts/presentation/pages/add_contact_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_page.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/widgets/connection_status_indicator.dart';
import 'package:cc/core/l10n/app_localizations.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with AutomaticKeepAliveClientMixin {
  final _logger = LogService.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _logger.d('ContactsPage initState');
    final contactCubit = context.read<ContactCubit>();
    if (contactCubit.state.contacts.isEmpty && !contactCubit.state.isLoading) {
      _logger.i('加载联系人数据');
      contactCubit.loadContacts();
    }
  }

  /// 处理联系人点击 - 进入聊天页面
  Future<void> _handleContactTap(User contact) async {
    try {
      _logger.i('点击联系人，创建或查找会话', extra: {'contactName': contact.name});

      // 获取必要的依赖
      final chatsRepository = context.read<ChatsRepository>();
      final chatRepository = context.read<ChatRepository>();
      final chatRepositorySend = context.read<ChatRepositorySend>();
      final currentUser = context.read<CurrentUser>();

      // 显示加载状态
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // 获取或创建私聊会话
        final conversation = await chatsRepository
            .getOrCreatePrivateConversation(contact.userId);

        // 隐藏加载对话框
        if (mounted) {
          Navigator.of(context).pop();
        }

        // 先清理过期快照
        await chatsRepository.cleanupExpiredSnapshots();

        // 获取状态快照（如果存在）
        final snapshot =
            await chatsRepository.getStateSnapshot(conversation.conversationId);

        if (mounted) {
          // 进入聊天页面
          Navigator.push(
            context,
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
                    chatRepository: context.read<ChatRepository>(),
                    chatRepositorySend: context.read<ChatRepositorySend>(),
                    chatsRepository: context.read<ChatsRepository>(),
                    currentUser: currentUser,
                    initialSnapshot: snapshot, // 传入预获取的快照
                    initialConversation: conversation, // 传入初始会话信息
                  ),
                  child: ChatPage(
                    conversationId: conversation.conversationId,
                    initialConversation: conversation,
                  ),
                ),
              ),
            ),
          );
        }
      } catch (error) {
        // 隐藏加载对话框
        if (mounted) {
          Navigator.of(context).pop();
        }

        _logger.e('创建或获取会话失败', error: error);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .cannotOpenChatWith(contact.name)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('处理联系人点击失败', error: error);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _logger.d('ContactsPage build');

    return BlocConsumer<ContactCubit, ContactState>(
      buildWhen: (previous, current) {
        // 只在以下情况才重建页面
        final contactsCountChanged =
            previous.contacts.length != current.contacts.length;
        final loadingStateChanged = previous.isLoading != current.isLoading;
        final syncStatusChanged = previous.syncStatus != current.syncStatus;
        final errorChanged = previous.errorMessage != current.errorMessage;

        final shouldRebuild = contactsCountChanged ||
            loadingStateChanged ||
            syncStatusChanged ||
            errorChanged;

        if (shouldRebuild) {
          _logger.d('ContactsPage 需要重建', extra: {
            'contactsCountChanged': contactsCountChanged,
            'loadingStateChanged': loadingStateChanged,
            'syncStatusChanged': syncStatusChanged,
            'errorChanged': errorChanged,
          });
        }

        return shouldRebuild;
      },
      listener: (context, state) {
        // 🔄 智能错误处理：只在应用活跃时显示错误消息
        if (state.errorMessage != null) {
          final appLifecycleService = AppLifecycleService.instance;

          // 只在应用活跃时显示错误通知
          if (appLifecycleService.isAppActive) {
            // 过滤同步相关的错误，避免频繁弹出
            final isTokenError = state.errorMessage!.contains('Token') ||
                state.errorMessage!.contains('认证') ||
                state.errorMessage!.contains('同步');

            if (!isTokenError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red.shade400,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              // Token/同步错误只在调试模式下显示
              _logger.w('联系人同步错误（已过滤UI通知）', extra: {
                'error': state.errorMessage,
                'appState': appLifecycleService.currentState.toString(),
              });
            }
          } else {
            _logger.d('应用在后台，跳过错误通知显示', extra: {
              'error': state.errorMessage,
              'appState': appLifecycleService.currentState.toString(),
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ConnectionStatusIndicator(size: 14),
                const SizedBox(width: 4),
                Text(AppLocalizations.of(context).contacts),
              ],
            ),
            actions: [
              // 添加联系人按钮
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  _logger.i('打开添加联系人页面');

                  // 获取必要的Repository依赖
                  final chatsRepository = context.read<ChatsRepository>();
                  final chatRepository = context.read<ChatRepository>();
                  final chatRepositorySend = context.read<ChatRepositorySend>();
                  final contactCubit = context.read<ContactCubit>();
                  final currentUser = context.read<CurrentUser>();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiRepositoryProvider(
                        providers: [
                          RepositoryProvider<ChatsRepository>.value(
                              value: chatsRepository),
                          RepositoryProvider<ChatRepository>.value(
                              value: chatRepository),
                          RepositoryProvider<ChatRepositorySend>.value(
                              value: chatRepositorySend),
                          RepositoryProvider<CurrentUser>.value(
                              value: currentUser),
                        ],
                        child: BlocProvider<ContactCubit>.value(
                          value: contactCubit,
                          child: const AddContactPage(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // 同步状态指示器
              _buildSyncStatusIndicator(),

              // 联系人列表
              Expanded(
                child: ContactListWidget(
                  mode: ContactListMode.detail,
                  scrollController: _scrollController,
                  onContactTap: _handleContactTap,
                  searchHint: AppLocalizations.of(context).searchContacts,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建同步状态指示器
  Widget _buildSyncStatusIndicator() {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ContactCubit, ContactState>(
      buildWhen: (previous, current) =>
          previous.syncStatus != current.syncStatus ||
          previous.errorMessage != current.errorMessage ||
          previous.contacts.length != current.contacts.length,
      builder: (context, state) {
        if (state.syncStatus == ContactsSyncStatus.syncing) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          );
        } else if (state.errorMessage != null && state.contacts.isEmpty) {
          // 只在没有本地数据时显示错误
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.red.shade100,
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.serverConnectionError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<ContactCubit>().syncContacts(),
                  child: Text(l10n.retry,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
