import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_state.dart';
import 'package:cc/features/contacts/presentation/widgets/contact_list_widget.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/features/contacts/presentation/pages/contact_detail_page.dart';
import 'package:cc/features/home/presentation/widgets/network_status_indicator.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';

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
    // 确保ContactCubit已加载联系人数据
    _ensureContactsLoaded();
  }

  /// 确保联系人数据已加载
  void _ensureContactsLoaded() {
    final contactCubit = context.read<ContactCubit>();
    if (contactCubit.state.contacts.isEmpty && !contactCubit.state.isLoading) {
      _logger.i('加载联系人数据');
      contactCubit.loadContacts();
    }
  }

  /// 同步联系人
  Future<void> _syncContacts() async {
    final contactCubit = context.read<ContactCubit>();
    await contactCubit.syncContacts();
  }

  /// 处理联系人点击 - 进入联系人详情页
  void _handleContactTap(User contact) {
    _logger.i('打开联系人详情页：${contact.name}');
    final contactCubit = context.read<ContactCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: contactCubit,
          child: ContactDetailPage(
            contact: contact,
          ),
        ),
      ),
    );
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
        // 处理错误消息
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('联系人'),
            actions: [
              // 同步按钮
              IconButton(
                icon: Icon(
                  Icons.sync,
                  color: state.syncStatus == ContactsSyncStatus.syncing
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: state.syncStatus == ContactsSyncStatus.syncing
                    ? null
                    : _syncContacts,
              ),
              // 添加联系人按钮
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  // TODO 实现添加联系人功能
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, homeState) {
                  return NetworkStatusIndicator(
                    networkStatus: homeState.networkStatus,
                    onRetry: () {
                      context.read<HomeCubit>().reconnect();
                    },
                  );
                },
              ),
            ),
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
                  searchHint: 'Search',
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.person_add),
            onPressed: () {
              _logger.i('打开添加联系人页面');
              // TODO: 实现添加联系人功能
            },
          ),
        );
      },
    );
  }

  /// 构建同步状态指示器
  Widget _buildSyncStatusIndicator() {
    return BlocBuilder<ContactCubit, ContactState>(
      buildWhen: (previous, current) =>
          previous.syncStatus != current.syncStatus ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (state.syncStatus == ContactsSyncStatus.syncing) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          );
        } else if (state.errorMessage != null) {
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
                    state.errorMessage ?? '同步联系人失败',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _syncContacts,
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
