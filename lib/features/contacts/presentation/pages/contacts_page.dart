import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/app_lifecycle_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_state.dart';
import 'package:cc/features/contacts/presentation/widgets/contact_list_widget.dart';
// import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart'; // 暂时不使用
import 'package:cc/features/contacts/presentation/pages/add_contact_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_page.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/widgets/connection_status_indicator.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/features/chat/presentation/pages/chats_page.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with AutomaticKeepAliveClientMixin, RouteAware, WidgetsBindingObserver {
  final _logger = LogService.instance;
  final ScrollController _scrollController = ScrollController();
  
  /// 页面是否可见状态标记
  bool _isPageVisible = true;

  @override
  void initState() {
    super.initState();
    _logger.d('ContactsPage initState');
    
    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    final contactCubit = context.read<ContactCubit>();
    if (contactCubit.state.contacts.isEmpty && !contactCubit.state.isLoading) {
      _logger.i('加载联系人数据');
      contactCubit.loadContacts();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 注册 RouteObserver
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }

    _logger.d('ContactsPage didChangeDependencies 触发', extra: {
      'isPageVisible': _isPageVisible,
      'mounted': mounted,
    });
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
    // 取消 RouteObserver 订阅
    routeObserver.unsubscribe(this);
    
    // 移除生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    
    _scrollController.dispose();
    super.dispose();
  }

  // RouteAware 生命周期方法
  @override
  void didPopNext() {
    // 当从其他页面返回到当前页面时触发
    _logger.i('🚀🚀🚀 ContactsPage didPopNext 触发 - 用户从其他页面返回');
    _isPageVisible = true;

    // 检查并刷新联系人数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 💢💢💢 重要：检查当前是否是可见的Tab页面
        // ContactsPage是索引1，只有当前Tab索引为1时才执行同步
        try {
          final homeCubit = context.read<HomeCubit>();
          final currentTabIndex = homeCubit.state.currentTabIndex;
          final isCurrentTabVisible = currentTabIndex == 1;
          
          _logger.i('🚀🚀🚀 ContactsPage didPopNext 检查可见性', extra: {
            'currentTabIndex': currentTabIndex,
            'isContactsTabVisible': isCurrentTabVisible,
            'shouldSync': isCurrentTabVisible,
          });

          if (isCurrentTabVisible) {
            _logger.i('🚀🚀🚀 ContactsPage 当前可见，执行同步');
            final contactCubit = context.read<ContactCubit>();
            contactCubit.syncContacts(); // 同步联系人数据
          } else {
            _logger.d('ContactsPage 当前不可见，跳过同步');
          }
        } catch (e) {
          // 如果获取HomeCubit失败，作为fallback还是执行同步
          _logger.w('ContactsPage 无法获取HomeCubit，执行fallback同步', extra: {'error': e.toString()});
          final contactCubit = context.read<ContactCubit>();
          contactCubit.syncContacts();
        }
      }
    });
  }

  @override
  void didPushNext() {
    // 当从当前页面导航到其他页面时触发
    _logger.d('ContactsPage didPushNext 触发 - 用户离开当前页面');
    _isPageVisible = false;
  }

  @override
  void didPush() {
    // 当页面首次被推入路由栈时触发
    _logger.d('ContactsPage didPush 触发 - 页面首次显示');
    _isPageVisible = true;
  }

  @override
  void didPop() {
    // 当页面从路由栈中弹出时触发
    _logger.d('ContactsPage didPop 触发 - 页面被移除');
    _isPageVisible = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 应用从后台恢复时触发同步
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _logger.i('应用从后台恢复，ContactsPage 检查是否需要同步');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 检查当前是否是可见的Tab页面
          try {
            final homeCubit = context.read<HomeCubit>();
            final currentTabIndex = homeCubit.state.currentTabIndex;
            final isCurrentTabVisible = currentTabIndex == 1;
            
            if (isCurrentTabVisible) {
              _logger.i('ContactsPage 当前可见且应用恢复，执行同步');
              final contactCubit = context.read<ContactCubit>();
              contactCubit.syncContacts();
            } else {
              _logger.d('ContactsPage 当前不可见，跳过应用恢复同步');
            }
          } catch (e) {
            _logger.w('ContactsPage 应用恢复同步检查失败', extra: {'error': e.toString()});
          }
        }
      });
    }
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
          body: ContactListWidget(
            mode: ContactListMode.detail,
            scrollController: _scrollController,
            onContactTap: _handleContactTap,
            searchHint: AppLocalizations.of(context).searchContacts,
          ),
        );
      },
    );
  }

}
