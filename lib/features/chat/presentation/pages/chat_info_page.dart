import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/proto/generated/conversation.pbenum.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cc/features/chat/presentation/pages/chat_page.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/contact_service.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/services/media_cache_service.dart';
import 'package:cc/core/services/thumbnail_cache_service.dart';

import 'package:cc/features/chat/presentation/pages/chats_page.dart'; // 导入 routeObserver
import 'package:cc/core/utils/user_display_utils.dart';

class ChatInfoPage extends StatefulWidget {
  const ChatInfoPage({
    super.key,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> with TickerProviderStateMixin, RouteAware {
  final _logger = LogService.instance;
  // 静音按钮动画控制器
  late AnimationController _muteAnimController;
  late Animation<double> _rotateAnimation;

  // 添加编辑模式状态
  bool _isEditMode = false;

  // 添加文本编辑控制器
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  // 添加description展开状态管理
  bool _isDescriptionExpanded = false;

  // 添加复制状态管理
  bool _isCopied = false;

  // 添加Tab数据加载标志，避免重复加载
  bool _hasTriedLoadingMedia = false;
  bool _hasTriedLoadingFiles = false;
  bool _hasTriedLoadingVoice = false;
  bool _hasTriedLoadingLinks = false;

  // 💢💢💢 新增：页面滚动控制器，用于实现Tab点击时自动滚动到顶部
  final ScrollController _scrollController = ScrollController();

  // 💢💢💢 新增：Tab控制器，用于监听Tab点击事件
  TabController? _tabController;

  // 💢💢💢 新增：聊天资源分类模块的GlobalKey，用于精确定位位置
  final GlobalKey _chatResourcesKey = GlobalKey();
  final GlobalKey _chatResourcesKeyEditMode = GlobalKey(); // 💢💢💢 编辑模式专用的Key
  

  /// 获取会话的显示名称（同步版本）
  ///
  /// 私聊时优先使用对方的name字段，群聊和频道使用会话名称
  String _getConversationDisplayName(Conversation conversation, String currentUserId) {
    // 私聊时优先使用对方的name字段
    if (conversation.type == 'PRIVATE') {
      final partnerName = ConversationAdapter.getPrivateChatPartnerName(
        conversation.participants,
        conversation.type,
        currentUserId,
      );
      if (partnerName != null && partnerName.isNotEmpty) {
        return partnerName;
      }
    }

    // 群聊、频道或获取不到对方名称时使用会话名称
    return conversation.name ?? '未命名会话';
  }

  /// 获取会话显示的roleId（仅对私聊有效）
  int? _getConversationDisplayRoleId(Conversation conversation, String currentUserId) {
    return ConversationAdapter.getDisplayRoleId(conversation.participants, conversation.type, currentUserId);
  }
  

  /// 同步获取参与者的显示名称（用于对话框等需要立即显示的场景）
  ///
  /// 注意：这是同步版本，为了避免阻塞UI，暂时使用participant name
  /// 在未来可以考虑使用缓存机制来优化
  ///
  /// [participant] - 参与者信息Map
  /// 返回：应该显示的参与者名称
  String _getParticipantDisplayName(Map<String, dynamic> participant) {
    // 对于对话框等需要立即显示的场景，暂时使用participant name
    // 这样可以避免同步数据库查询阻塞UI
    return participant['name'] ?? 'Unknown';
  }

  /// 加载联系人的完整信息到编辑控制器
  ///
  /// [userId] - 联系人的用户ID
  Future<void> _loadContactInfo(String userId) async {
    try {
      final database = AppDatabase.instance;
      final contact = await (database.select(database.users)..where((u) => u.userId.equals(userId))).getSingleOrNull();

      if (contact != null && mounted) {
        setState(() {
          // 设置昵称：优先使用自定义昵称，其次使用联系人名称
          if (contact.nickname != null && contact.nickname!.isNotEmpty) {
            _nicknameController.text = contact.nickname!;
          } else if (contact.name.isNotEmpty) {
            _nicknameController.text = contact.name;
          } else {
            _nicknameController.text = contact.userId;
          }

          // 设置备注信息
          _remarkController.text = contact.remark ?? '';
        });
        
        _logger.i('已重新加载联系人信息并刷新UI', extra: {
          'userId': userId,
          'nickname': _nicknameController.text,
          'remark': _remarkController.text,
        });
      }
    } catch (e) {
      _logger.e('加载联系人信息失败', error: e);
    }
  }

  /// 异步获取参与者的显示名称，优先使用自定义联系人名称
  ///
  /// 显示优先级：
  /// 1. 自定义联系人名称 (nickname) - 当前用户为此联系人设置的昵称
  /// 2. 会话成员名称 (participant.name) - 会话中存储的成员名称
  /// 3. 用户ID - 如果前两者都没有
  ///
  /// [participant] - 参与者信息Map
  /// 返回：应该显示的参与者名称
  Future<String> _getParticipantDisplayNameAsync(Map<String, dynamic> participant) async {
    final userId = participant['userId'] as String?;
    if (userId == null || userId.isEmpty) {
      return participant['name'] ?? 'Unknown';
    }

    try {
      // 从数据库查询联系人信息，获取自定义名称
      final database = AppDatabase.instance;
      final contact = await (database.select(database.users)..where((u) => u.userId.equals(userId))).getSingleOrNull();

      if (contact != null) {
        // 1. 优先使用自定义联系人名称
        if (contact.nickname != null && contact.nickname!.isNotEmpty) {
          return contact.nickname!;
        }

        // 2. 其次使用联系人的昵称
        if (contact.name.isNotEmpty) {
          return contact.name;
        }

        // 3. 使用用户ID
        return contact.userId;
      } else {
        // 如果数据库中没有联系人信息，使用会话参与者的名称
        return participant['name'] ?? userId;
      }
    } catch (e) {
      _logger.e('获取参与者显示名称失败', error: e);
      // 出错时使用会话参与者的名称作为fallback
      return participant['name'] ?? userId;
    }
  }

  @override
  void initState() {
    super.initState();

    // 初始化静音按钮动画控制器
    _muteAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _muteAnimController,
      curve: Curves.easeInOut,
    ));

    // 获取当前会话，初始化静音状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final chatCubit = context.read<ChatCubit>();
        final conversation = chatCubit.state.conversation;

        // 根据会话的静音状态设置动画
        final currentUserId = chatCubit.state.currentUser.userId;
        if (conversation.muted) {
          _muteAnimController.value = 1.0; // 直接设置到终点
        } else {
          _muteAnimController.value = 0.0;
        }
      }
    });

    // 页面加载后同步当前会话详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatCubit>().syncCurrentConversation();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 💢💢💢 注册 RouteObserver，监听页面返回事件
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  /// 💢💢💢 页面返回时触发 - 用户从其他页面返回到ChatInfoPage
  @override
  void didPopNext() {
    _logger.i('🚀🚀🚀 ChatInfoPage didPopNext 触发 - 用户从其他页面返回');

    // 页面返回时刷新会话数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logger.i('ChatInfoPage 页面返回，刷新会话数据');
        context.read<ChatCubit>().syncCurrentConversation();
      }
    });
  }

  /// 💢💢💢 离开页面时触发
  @override
  void didPushNext() {
    _logger.d('ChatInfoPage didPushNext 触发 - 用户离开当前页面');
  }

  @override
  void dispose() {
    // 💢💢💢 取消 RouteObserver 订阅
    routeObserver.unsubscribe(this);
    _muteAnimController.dispose();
    _nicknameController.dispose();
    _remarkController.dispose();
    _scrollController.dispose(); // 💢💢💢 释放滚动控制器
    _tabController?.dispose(); // 💢💢💢 释放Tab控制器
    super.dispose();
  }

  /// 判断当前用户是否可以编辑会话信息
  ///
  /// 权限规则：
  /// - 私聊：所有用户都可以编辑联系人备注
  /// - 群聊/频道：只有群主(owner)和管理员(admin)可以编辑
  bool _canCurrentUserEdit(Conversation conversation, CurrentUser currentUser) {
    // 私聊会话：所有用户都可以编辑联系人信息
    if (conversation.type == 'PRIVATE') {
      return true;
    }

    // 群聊和频道：从participants JSON中解析用户角色并检查权限
    return _hasEditPermission(conversation, currentUser.userId);
  }

  /// 检查用户是否有编辑权限
  /// 通过解析participants JSON来确定用户角色
  /// 只有群主(OWNER)和管理员(ADMIN)可以编辑会话信息
  bool _hasEditPermission(Conversation conversation, String userId) {
    try {
      // 解析participants JSON
      final participantsData = json.decode(conversation.participants);

      if (participantsData is List) {
        // 查找当前用户的参与者信息
        final userParticipant = participantsData.firstWhere(
          (participant) => participant['userId'] == userId,
          orElse: () => null,
        );

        if (userParticipant == null) {
          _logger.w('用户不在参与者列表中', extra: {
            'userId': userId,
            'conversationId': conversation.conversationId,
          });
          return false;
        }

        // 检查用户角色
        final userRole = userParticipant['role']?.toString().toUpperCase();
        final hasPermission = userRole == 'OWNER' || userRole == 'ADMIN';

        _logger.d('检查编辑权限', extra: {
          'userId': userId,
          'userRole': userRole,
          'hasPermission': hasPermission,
          'conversationId': conversation.conversationId,
        });

        return hasPermission;
      } else {
        // 如果participants不是List格式，可能是旧的逗号分隔格式
        _logger.w('participants格式不是JSON数组，尝试逗号分隔解析', extra: {
          'participants': conversation.participants,
          'conversationId': conversation.conversationId,
        });

        // 回退到简单的参与者检查（旧格式兼容）
        final participantsList = conversation.participants.split(',');
        final isParticipant = participantsList.contains(userId);

        // 对于旧格式，暂时允许所有参与者编辑
        // 实际应用中应该迁移到新的JSON格式
        return isParticipant;
      }
    } catch (e) {
      _logger.w('解析参与者JSON失败', extra: {
        'userId': userId,
        'conversationId': conversation.conversationId,
        'participants': conversation.participants,
        'error': e.toString(),
      });

      // 解析失败时的回退逻辑：尝试简单的逗号分隔检查
      try {
        final participantsList = conversation.participants.split(',');
        return participantsList.contains(userId);
      } catch (fallbackError) {
        _logger.e('回退解析也失败', error: fallbackError);
        return false;
      }
    }
  }

  /// 从participants JSON中获取用户角色
  /// 返回用户在会话中的角色，如果用户不在会话中则返回null
  String? _getUserRole(Conversation conversation, String userId) {
    try {
      final participantsData = json.decode(conversation.participants);

      if (participantsData is List) {
        final userParticipant = participantsData.firstWhere(
          (participant) => participant['userId'] == userId,
          orElse: () => null,
        );

        return userParticipant?['role']?.toString();
      }
    } catch (e) {
      _logger.w('获取用户角色失败', extra: {
        'userId': userId,
        'conversationId': conversation.conversationId,
        'error': e.toString(),
      });
    }

    return null;
  }

  // 切换静音状态
  void _toggleMuteState() {
    final chatCubit = context.read<ChatCubit>();
    final currentUserId = chatCubit.state.currentUser.userId;

    final currentMuteStatus = chatCubit.state.conversation.muted;
    final newMuteStatus = !currentMuteStatus;

    // 立即更新动画状态
    if (newMuteStatus) {
      _muteAnimController.forward();
    } else {
      _muteAnimController.reverse();
    }

    UINotificationService().showSuccess(newMuteStatus ? '已开启静音' : '已关闭静音');
    _logger.i('切换静音状态', extra: {'isMuted': newMuteStatus});

    // 通过 ChatCubit 更新静音状态（遵循 DDD 架构）
    chatCubit.updateConversationMuteStatus(newMuteStatus);
  }

  // 💢💢💢 新增：滚动到聊天资源分类模块顶部的方法
  void _scrollToTop() {
    _logger.d('_scrollToTop方法被调用', extra: {
      'hasClients': _scrollController.hasClients,
      'currentPosition': _scrollController.hasClients ? _scrollController.position.pixels : null,
      'isEditMode': _isEditMode,
    });

    if (_scrollController.hasClients) {
      try {
        _logger.i('开始滚动到聊天资源分类模块');

        // 💢💢💢 根据当前模式选择对应的GlobalKey
        GlobalKey? targetKey;
        if (_isEditMode) {
          targetKey = _chatResourcesKeyEditMode.currentContext != null ? _chatResourcesKeyEditMode : null;
        } else {
          targetKey = _chatResourcesKey.currentContext != null ? _chatResourcesKey : null;
        }

        if (targetKey != null) {
          // 💢💢💢 使用postFrameCallback确保布局完成后再执行滚动
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && targetKey!.currentContext != null) {
              // 💢💢💢 使用Scrollable.ensureVisible方法
              Scrollable.ensureVisible(
                targetKey.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0.0, // 0.0表示滚动到顶部可见
              ).then((_) {
                _logger.i('滚动动画完成');
              }).catchError((error) {
                _logger.w('滚动过程中出现错误', extra: {'error': error.toString()});
                // 💢💢💢 fallback: 滚动到页面顶部附近
                _scrollController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              });
            }
          });
        } else {
          _logger.w('没有找到可用的聊天资源分类模块context，滚动到页面顶部');
          // 💢💢💢 fallback: 滚动到页面顶部
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      } catch (e) {
        _logger.w('滚动过程中出现异常', extra: {'error': e.toString()});
        // 💢💢💢 异常处理：直接滚动到页面顶部
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    } else {
      _logger.w('ScrollController没有clients');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 从 ChatCubit 获取当前会话信息
        final conversation = state.conversation;

        // 判断是否为群聊
        final isGroup = conversation.type == 'GROUP';

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7), // 保持iOS风格的浅色背景
          appBar: AppBar(
            backgroundColor: const Color(0xFFF2F2F7), // 与背景颜色一致
            foregroundColor: Colors.black,
            elevation: 0, // 无阴影
            automaticallyImplyLeading: false, // 不显示默认返回按钮
            // 使用自定义的返回/取消按钮区域
            leadingWidth: _isEditMode ? 105 : 80, // 为Cancel模式提供更多空间
            leading: GestureDetector(
              onTap: () {
                if (_isEditMode) {
                  // 取消编辑，恢复原始状态
                  setState(() {
                    _isEditMode = false;
                  });
                } else {
                  // 返回上一页
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 不同模式显示不同图标
                    _isEditMode
                        ? const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          )
                        : const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primary,
                            size: 18,
                          ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        _isEditMode ? AppLocalizations.of(context).chatCancel : AppLocalizations.of(context).back,
                        style: TextStyle(
                          fontSize: 17,
                          color: _isEditMode ? Colors.red : AppColors.primary,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 清除默认标题
            title: const Text(''),
            centerTitle: false,
            titleSpacing: 0,
            actions: [
              // 只有满足条件的用户才显示编辑按钮
              if (_canCurrentUserEdit(state.conversation, state.currentUser))
                TextButton(
                  onPressed: () async {
                    if (_isEditMode) {
                      // 完成编辑，保存更改
                      final nickname = _nicknameController.text.trim();
                      final remark = _remarkController.text.trim();

                      _logger.i('保存联系人信息', extra: {
                        'nickname': nickname,
                        'remark': remark,
                      });

                      // 根据会话类型采用不同的更新策略
                      final chatCubit = context.read<ChatCubit>();
                      final conversation = chatCubit.state.conversation;

                      if (conversation.type == 'PRIVATE') {
                        // 私聊：修改联系人昵称
                        String? contactId;
                        // 检查是否有参与者信息
                        if (conversation.participants.isNotEmpty) {
                          final currentUserId = chatCubit.state.currentUser.userId;
                          // 从participants JSON中解析联系人ID
                          try {
                            final List<dynamic> participantsList = json.decode(conversation.participants);
                            final participantsMap = participantsList.cast<Map<String, dynamic>>();

                            // 找到对方用户的ID
                            final otherParticipant = participantsMap.firstWhere(
                              (participant) => participant['userId'] != currentUserId,
                              orElse: () => {},
                            );

                            contactId = otherParticipant['userId'] as String?;
                            if (contactId?.isEmpty == true) contactId = null;
                          } catch (e) {
                            contactId = null;
                          }
                        }

                        if (contactId != null) {
                          final success = await ContactService.instance.updateContact(
                            contactId: contactId,
                            nickname: nickname.isNotEmpty ? nickname : null,
                            remark: remark.isNotEmpty ? remark : null,
                          );

                          if (success) {
                            UINotificationService().showSuccess('联系人信息已更新');
                            // 刷新会话数据以显示最新的联系人信息
                            await chatCubit.syncCurrentConversation();
                            
                            // 通知ChatsCubit刷新会话列表，确保会话列表中的显示名称也得到更新
                            if (context.mounted) {
                              final chatsCubit = context.read<ChatsCubit>();
                              await chatsCubit.loadConversations();
                            }
                            
                            // 重新加载当前页面的联系人信息
                            if (context.mounted) {
                              await _loadContactInfo(contactId);
                            }
                          } else {
                            UINotificationService().showError('更新失败，请重试');
                          }
                        } else {
                          UINotificationService().showError('无法获取联系人信息');
                        }
                      } else {
                        // 群聊和频道：修改会话名称
                        final success = await _updateConversationName(
                          conversation.conversationId,
                          nickname.isNotEmpty ? nickname : null,
                        );

                        if (success) {
                          final typeName = conversation.type == 'GROUP' ? '群聊' : '频道';
                          UINotificationService().showSuccess('$typeName名称已更新');
                          // 刷新会话数据以显示最新的会话信息
                          chatCubit.syncCurrentConversation();
                        } else {
                          UINotificationService().showError('更新失败，请重试');
                        }
                      }

                      setState(() {
                        _isEditMode = false;
                      });
                    } else {
                      // 进入编辑模式
                      final chatCubit = context.read<ChatCubit>();
                      final conversation = chatCubit.state.conversation;

                      // 💡 初始化文本控制器
                      // 根据会话类型初始化编辑内容
                      if (conversation.type == 'PRIVATE') {
                        // 私聊：异步获取联系人信息作为初始值
                        final otherUser = UserDisplayUtils.getOtherUserFromConversation(conversation, chatCubit.state.currentUser.userId);
                        if (otherUser != null) {
                          final userId = otherUser['userId'] as String?;
                          if (userId != null) {
                            // 从数据库获取联系人的完整信息
                            _loadContactInfo(userId);
                          }
                        }
                      } else {
                        // 群聊/频道：使用会话名称
                        _nicknameController.text = conversation.name ?? '';
                        _remarkController.text = '';
                      }

                      setState(() {
                        _isEditMode = true;
                      });
                    }
                  },
                  child: Text(
                    _isEditMode ? AppLocalizations.of(context).chatDone : AppLocalizations.of(context).edit,
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppColors.primary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
          body: _isEditMode ? _buildEditModeContent(conversation) : _buildViewModeContent(conversation, isGroup),
        );
      },
    );
  }

  // 编辑模式下的内容
  Widget _buildEditModeContent(Conversation conversation) {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivateChat = conversation.type == 'PRIVATE';
    final isGroup = conversation.type == 'GROUP';
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像和名称区域 - 保持原有布局
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            child: Column(
              children: [
                // 头像
                Hero(
                  tag: 'chat_avatar_${conversation.conversationId}',
                  child: UserAvatar(
                    avatarUrl: conversation.avatar,
                    userId: conversation.type == 'PRIVATE'
                        ? (ConversationAdapter.getParticipantInfo(conversation.participants, state.currentUser.userId)?['userId'] == state.currentUser.userId
                            ? null
                            : ConversationAdapter.getParticipantInfo(conversation.participants, state.currentUser.userId)?['userId'])
                        : conversation.conversationId,
                    name: _getConversationDisplayName(conversation, state.currentUser.userId),
                    radius: 50,
                    backgroundColor: Colors.cyan,
                    roleId: _getConversationDisplayRoleId(conversation, state.currentUser.userId),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 名字输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: isPrivateChat
                          ? AppLocalizations.of(context).nickname
                          : isGroup
                              ? '群聊名称'
                              : '频道名称',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                  // 只有私聊才显示备注输入框
                  if (isPrivateChat) ...[
                    const Divider(
                      height: 1,
                      color: Color(0xFFE0E0E0),
                      indent: 16,
                    ),
                    TextField(
                      controller: _remarkController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).remark,
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 删除联系人/退出群聊/退出频道按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Center(
                  child: Text(
                    isPrivateChat
                        ? AppLocalizations.of(context).deleteContact
                        : isGroup
                            ? '退出群聊'
                            : '退出频道',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                onTap: () {
                  if (isPrivateChat) {
                    // 删除联系人
                    _showLeaveConfirmation(context, false);
                  } else {
                    // 退出群聊或频道
                    _showLeaveConfirmation(context, true);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 查看模式下的内容
  Widget _buildViewModeContent(Conversation conversation, bool isGroup) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 💢💢💢 计算可用的最大高度
        final availableHeight = constraints.maxHeight;

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像和名称区域 - 移除白色背景
              _buildProfileHeader(conversation),

              const SizedBox(height: 20),

              // 操作按钮区域 - 根据会话类型显示不同按钮
              _buildActionButtons(),

              const SizedBox(height: 30),

              // 用户ID/群组ID区域（包含description）
              _buildPhoneSection(),

              // 频道联系人模块（仅频道显示）
              _buildChannelContactsSection(),

              // 群成员列表模块（仅群组显示）
              _buildGroupMembersSection(),

              // 聊天资源分类模块 - 使用最小可用高度
              SizedBox(
                height: availableHeight * 0.9, // 💢💢💢 使用70%的可用高度
                child: _buildChatResourcesSection(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // 头像和名称区域 - 移除白色背景
  Widget _buildProfileHeader(Conversation conversation) {
    final state = context.read<ChatCubit>().state;
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Column(
        children: [
          // 头像
          Hero(
            tag: 'chat_avatar_${state.conversation.conversationId}',
            child: UserAvatar(
              avatarUrl: state.conversation.avatar,
              userId: state.conversation.type == 'PRIVATE'
                  ? (ConversationAdapter.getParticipantInfo(state.conversation.participants, state.currentUser.userId)?['userId'] == state.currentUser.userId
                      ? null
                      : ConversationAdapter.getParticipantInfo(state.conversation.participants, state.currentUser.userId)?['userId'])
                  : state.conversation.conversationId,
              name: _getConversationDisplayName(state.conversation, state.currentUser.userId),
              radius: 50,
              backgroundColor: Colors.cyan,
              roleId: _getConversationDisplayRoleId(state.conversation, state.currentUser.userId),
            ),
          ),
          const SizedBox(height: 16),
          // 名称
          Hero(
            tag: 'chat_title_${state.conversation.conversationId}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                _getConversationDisplayName(state.conversation, state.currentUser.userId),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 状态
          Hero(
            tag: 'chat_subtitle_${state.conversation.conversationId}',
            child: const Material(
              color: Colors.transparent,
              child: Text(
                'last seen a long time ago',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 操作按钮区域 - 根据会话类型显示不同按钮
  Widget _buildActionButtons() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == 'PRIVATE';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 私聊显示call和video
          if (isPrivate) ...[
            _buildActionButton(Icons.call, 'call', AppColors.primary),
            _buildActionButton(Icons.videocam, 'video', AppColors.primary),
            _buildMuteButton(),
            _buildActionButton(Icons.search, 'search', AppColors.primary),
            _buildMoreButton(),
          ] else ...[
            // 群聊和频道只显示4个按钮：mute、search、leave、more
            _buildMuteButton(),
            _buildActionButton(Icons.search, 'search', AppColors.primary),
            _buildLeaveButton(),
            _buildMoreButton(),
          ],
        ],
      ),
    );
  }

  // Leave按钮（群聊和频道专用）
  Widget _buildLeaveButton() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isGroup = conversation.type == 'GROUP';

    // 根据按钮数量计算宽度：私聊5个按钮，群聊/频道4个按钮
    final isPrivate = conversation.type == 'PRIVATE';
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              _showLeaveConfirmation(context, isGroup);
            },
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app, color: Colors.red, size: 26),
                  SizedBox(height: 6),
                  Text(
                    'leave',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 静音按钮 - 带有动画效果
  Widget _buildMuteButton() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == 'PRIVATE';
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _toggleMuteState,
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 使用旋转动画包装图标
                  AnimatedBuilder(
                    animation: _rotateAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value * 0.5, // 旋转90度
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 两种图标在同一位置，通过透明度控制显示/隐藏
                            Opacity(
                              opacity: 1 - _rotateAnimation.value,
                              child: const Icon(
                                Icons.notifications_none,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                            Opacity(
                              opacity: _rotateAnimation.value,
                              child: const Icon(
                                Icons.notifications_off_outlined,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  // 文本根据状态变化
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: BlocBuilder<ChatCubit, ChatState>(
                      buildWhen: (previous, current) {
                        final currentUserId = current.currentUser.userId;
                        return previous.conversation.muted != current.conversation.muted;
                      },
                      builder: (context, state) {
                        final currentUserId = state.currentUser.userId;
                        final isMuted = state.conversation.muted;
                        return Text(
                          isMuted ? AppLocalizations.of(context).unmute : AppLocalizations.of(context).mute,
                          key: ValueKey<bool>(isMuted),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 单个操作按钮
  Widget _buildActionButton(IconData icon, String label, Color color) {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == 'PRIVATE';
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

    // 获取本地化文本
    String localizedLabel;
    switch (label) {
      case 'call':
        localizedLabel = AppLocalizations.of(context).call;
        break;
      case 'video':
        localizedLabel = AppLocalizations.of(context).video;
        break;
      case 'search':
        localizedLabel = AppLocalizations.of(context).search;
        break;
      case 'leave':
        localizedLabel = AppLocalizations.of(context).leave;
        break;
      default:
        localizedLabel = label;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (label == 'search') {
                // 搜索按钮特殊处理：返回到 ChatPage 并启动搜索模式
                final chatCubit = context.read<ChatCubit>();
                chatCubit.enterSearchMode();
                Navigator.pop(context); // 返回到 ChatPage
              } else if (label == 'leave') {
                final isGroup = conversation.type == 'GROUP';
                _showLeaveConfirmation(context, isGroup);
              } else if (label == 'video' || label == 'call') {
                // 视频通话和语音通话按钮特殊处理：显示功能未开放弹窗
                _logger.i('点击了操作按钮', extra: {'action': label});
                _showFeatureNotAvailableDialog(context, localizedLabel);
              } else {
                _logger.i('点击了操作按钮', extra: {'action': label});
                UINotificationService().showInfo('功能暂未开放');
              }
            },
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    localizedLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 更多按钮 - 点击显示弹出菜单
  Widget _buildMoreButton() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isPrivate = conversation.type == 'PRIVATE';
    final buttonCount = isPrivate ? 5 : 4;
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 32) / buttonCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          offset: const Offset(0, 76), // 向下偏移按钮高度(70) + 6像素
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white, // 设置菜单背景色为白色，与按钮一致
          elevation: 4, // 轻微的阴影
          itemBuilder: (context) => [
            _buildPopupMenuItem(Icons.block, AppLocalizations.of(context).block),
            _buildPopupMenuItem(Icons.delete_forever, AppLocalizations.of(context).clearChatHistory, isDestructive: true),
          ],
          onSelected: (value) {
            _handleMenuItemSelected(value);
          },
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: buttonWidth,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.more_horiz, color: AppColors.primary, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context).more,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  // 构建弹出菜单项
  PopupMenuItem<String> _buildPopupMenuItem(IconData icon, String text, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.black87,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 处理菜单项选择
  void _handleMenuItemSelected(String value) {
    final localizations = AppLocalizations.of(context);
    _logger.i('选择了菜单项', extra: {'action': value});

    if (value == localizations.block) {
      _showFeatureNotAvailableDialog(context, localizations.block);
    } else if (value == localizations.clearChatHistory) {
      _showFeatureNotAvailableDialog(context, localizations.clearChatHistory);
    }
  }

  // 根据功能名称获取对应图标
  IconData _getFeatureIcon(String featureName) {
    final localizations = AppLocalizations.of(context);
    if (featureName == localizations.call) {
      return Icons.call;
    } else if (featureName == localizations.video) {
      return Icons.videocam;
    } else if (featureName == localizations.block) {
      return Icons.block;
    } else if (featureName == localizations.clearChatHistory) {
      return Icons.delete_forever;
    } else {
      return Icons.info_outline;
    }
  }

  // 根据功能名称获取对应描述
  String _getFeatureDescription(String featureName) {
    final localizations = AppLocalizations.of(context);
    if (featureName == localizations.call) {
      return localizations.voiceCallInDevelopment;
    } else if (featureName == localizations.video) {
      return localizations.videoCallInDevelopment;
    } else if (featureName == localizations.block) {
      return localizations.blockUserInDevelopment;
    } else if (featureName == localizations.clearChatHistory) {
      return localizations.clearChatInDevelopment;
    } else {
      return localizations.featureNotAvailable;
    }
  }

  // 显示功能未开放底部弹窗
  void _showFeatureNotAvailableDialog(BuildContext context, String featureName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部指示器
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // 功能图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getFeatureIcon(featureName),
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // 标题
              Text(
                featureName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // 描述文本
              Text(
                _getFeatureDescription(featureName),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 确定按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    AppLocalizations.of(context).confirm,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // 底部安全区域
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  // 显示退出确认对话框
  void _showLeaveConfirmation(BuildContext context, bool isGroup) {
    // 💢💢💢 在显示对话框之前获取 ChatCubit，避免上下文问题
    final chatCubit = context.read<ChatCubit>();
    final state = chatCubit.state;
    final conversation = state.conversation;
    final isChannel = conversation.type == 'CHANNEL';

    String title;
    String content;
    String actionText;

    if (isGroup) {
      title = '删除并退出';
      content = '退出后,将不再接收此群聊信息';
      actionText = '退出';
    } else if (isChannel) {
      title = '退出频道';
      content = '退出后,将不再接收此频道信息';
      actionText = '退出';
    } else {
      title = '删除联系人';
      content = '删除后,将不再接收此联系人的消息';
      actionText = '删除';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(actionText, style: const TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);

              // 💢💢💢 使用新的退出会话方法（使用预获取的 ChatCubit）
              final reason = isGroup
                  ? "exit"
                  : isChannel
                      ? "exit"
                      : "delete";

              chatCubit.exitCurrentConversation(reason: reason);

              // 显示处理中提示
              final processingMessage = isGroup
                  ? '正在退出群聊...'
                  : isChannel
                      ? '正在退出频道...'
                      : '正在删除联系人...';
              UINotificationService.instance.showInfo(processingMessage);

              // 返回上一级
              // Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 用户ID/群组ID区域
  Widget _buildPhoneSection() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isGroup = conversation.type == 'GROUP';
    final isChannel = conversation.type == 'CHANNEL';

    // 根据会话类型确定要显示的ID和标签
    String displayId;
    String labelText;
    String successMessage;

    if (isGroup) {
      // 群聊显示群组ID
      displayId = conversation.conversationId;
      labelText = AppLocalizations.of(context).groupId;
      successMessage = AppLocalizations.of(context).groupIdCopied;
    } else if (isChannel) {
      // 频道显示频道ID
      displayId = conversation.conversationId;
      labelText = AppLocalizations.of(context).channelId;
      successMessage = AppLocalizations.of(context).channelIdCopied;
    } else {
      // 私聊：从参与者JSON中获取对方用户ID，排除当前用户
      final currentUserId = state.currentUser.userId;
      try {
        final participantsList = jsonDecode(conversation.participants) as List;
        final participantsMap = participantsList.cast<Map<String, dynamic>>();

        final peer = participantsMap.firstWhere(
          (p) => p['userId'] != currentUserId,
          orElse: () => {},
        );

        displayId = peer.isNotEmpty && peer['userId'] != null ? peer['userId'] as String : conversation.conversationId;
      } catch (e) {
        // JSON解析失败，使用会话ID作为后备
        displayId = conversation.conversationId;
      }
      labelText = AppLocalizations.of(context).userId;
      successMessage = AppLocalizations.of(context).userIdCopied;
    }

    // 检查是否需要显示描述
    final shouldShowDescription = isGroup || isChannel;
    final description = conversation.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // ID部分
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          labelText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: shouldShowDescription ? 16 : 16, top: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    '@$displayId',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () async {
                                      // 复制ID到剪贴板
                                      Clipboard.setData(ClipboardData(text: displayId));
                                      _logger.i('复制ID到剪贴板', extra: {
                                        'id': displayId,
                                        'type': isGroup
                                            ? 'group'
                                            : isChannel
                                                ? 'channel'
                                                : 'user'
                                      });
                                      UINotificationService().showSuccess(successMessage);

                                      // 设置复制状态
                                      setState(() {
                                        _isCopied = true;
                                      });

                                      // 2秒后恢复原状
                                      Future.delayed(const Duration(seconds: 2), () {
                                        if (mounted) {
                                          setState(() {
                                            _isCopied = false;
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: _isCopied ? Colors.green.withAlpha(26) : AppColors.primary.withAlpha(26),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: _isCopied
                                            ? const Row(
                                                key: ValueKey('copied'),
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '已复制',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Icon(
                                                key: ValueKey('copy'),
                                                Icons.copy,
                                                color: AppColors.primary,
                                                size: 16,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.qr_code,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    onPressed: () {
                      _showQRCodeDialog(context, displayId, isGroup);
                    },
                  ),
                ),
              ],
            ),
            // 描述部分（仅群组和频道）
            if (shouldShowDescription) ...[
              // 分隔线
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 描述标题
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context).description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 描述内容
                    if (hasDescription)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: _isDescriptionExpanded ? null : 2,
                            overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                          // 检查是否需要显示more/less按钮
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // 创建一个测试文本来计算实际行数
                              final span = TextSpan(
                                text: description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              );
                              final tp = TextPainter(
                                text: span,
                                maxLines: 2,
                                textDirection: TextDirection.ltr,
                              );
                              tp.layout(maxWidth: constraints.maxWidth);

                              final needsMoreButton = tp.didExceedMaxLines;

                              if (needsMoreButton) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isDescriptionExpanded = !_isDescriptionExpanded;
                                      });
                                    },
                                    child: Text(
                                      _isDescriptionExpanded ? AppLocalizations.of(context).less : AppLocalizations.of(context).more,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      )
                    else
                      Text(
                        isGroup ? '欢迎加入群组！' : '欢迎关注频道！',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 频道联系人模块（仅频道显示）
  Widget _buildChannelContactsSection() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isChannel = conversation.type == 'CHANNEL';

    if (!isChannel) {
      return const SizedBox.shrink();
    }

    // 获取非普通成员（管理员、所有者等）
    List<Map<String, dynamic>> nonMemberParticipants = [];
    try {
      final participantsList = jsonDecode(conversation.participants) as List;
      final participantsMap = participantsList.cast<Map<String, dynamic>>();

      nonMemberParticipants = participantsMap
          .where((p) => p['role'] != 0) // 0 = MEMBER, 1 = ADMIN, 2 = OWNER
          .toList();
    } catch (e) {
      // JSON解析失败，返回空区域
      return const SizedBox.shrink();
    }

    if (nonMemberParticipants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Container(
        key: _chatResourcesKeyEditMode, // 💢💢💢 使用编辑模式专用的GlobalKey
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加成员按钮（可选，仅管理员可见）
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Members',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 52),

            // 非普通成员列表
            ...nonMemberParticipants.asMap().entries.map((entry) {
              final index = entry.key;
              final participant = entry.value;
              final isLast = index == nonMemberParticipants.length - 1;

              return Column(
                children: [
                  _buildContactItem(
                    participant: participant,
                    role: _getRoleDisplayName(participant['role']),
                    isOnline: participant['online'] == true,
                    lastSeen: (participant['online'] == true) ? null : 'last seen recently',
                  ),
                  if (!isLast) const Divider(height: 1, indent: 68),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // 构建单个联系人项
  Widget _buildContactItem({
    required Map<String, dynamic> participant,
    required String role,
    required bool isOnline,
    String? lastSeen,
  }) {
    final avatar = participant['avatar'] as String?;
    final roleId = participant['roleId'] as int?;
    final fallbackName = participant['name'] ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 头像 - 使用FutureBuilder异步获取显示名称
          Stack(
            children: [
              FutureBuilder<String>(
                future: _getParticipantDisplayNameAsync(participant),
                builder: (context, snapshot) {
                  final displayName = snapshot.data ?? fallbackName;
                  return UserAvatar(
                    avatarUrl: avatar,
                    userId: participant['userId'],
                    name: displayName,
                    radius: 26,
                    roleId: roleId,
                  );
                },
              ),
              // 在线状态指示器
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _getParticipantDisplayNameAsync(participant),
                        builder: (context, snapshot) {
                          final displayName = snapshot.data ?? fallbackName;
                          return Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    // 角色标识
                    if (role.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRoleTextColor(role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lastSeen ?? (isOnline ? 'online' : 'offline'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 将角色值转换为字符串（处理 protobuf 枚举值）
  String _convertRoleToString(dynamic role) {
    if (role is int) {
      switch (role) {
        case 0:
          return 'MEMBER';
        case 1:
          return 'ADMIN';
        case 2:
          return 'OWNER';
        default:
          return 'MEMBER';
      }
    }
    return role?.toString() ?? 'MEMBER';
  }

  // 获取角色显示名称
  String _getRoleDisplayName(dynamic role) {
    final localizations = AppLocalizations.of(context);
    final roleString = _convertRoleToString(role);

    switch (roleString) {
      case 'OWNER':
        return localizations.owner;
      case 'ADMIN':
        return localizations.admin;
      case 'MEMBER':
        return '';
      default:
        return '';
    }
  }

  // 获取角色标签颜色
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'ceo':
        return Colors.purple[100]!;
      case 'admin':
        return AppColors.primary.withAlpha(26);
      default:
        return Colors.grey[200]!;
    }
  }

  // 获取角色文字颜色
  Color _getRoleTextColor(String role) {
    switch (role.toLowerCase()) {
      case 'ceo':
        return Colors.purple[700]!;
      case 'admin':
        return AppColors.primary;
      default:
        return Colors.grey[700]!;
    }
  }

  // 群成员列表模块（仅群组显示）- 已整合到聊天资源分类模块中
  Widget _buildGroupMembersSection() {
    // 此方法已废弃，群成员列表现在是聊天资源分类模块中的一个Tab
    return const SizedBox.shrink();
  }

  // 聊天资源分类模块
  Widget _buildChatResourcesSection() {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isGroup = conversation.type == 'GROUP';

    // 根据会话类型确定Tab列表
    List<String> tabs = [];
    if (isGroup) {
      tabs = [
        AppLocalizations.of(context).members,
        AppLocalizations.of(context).media,
        AppLocalizations.of(context).files,
        AppLocalizations.of(context).music,
        AppLocalizations.of(context).chatVoice,
        AppLocalizations.of(context).chatLinks
      ];
    } else {
      tabs = [
        AppLocalizations.of(context).media,
        AppLocalizations.of(context).files,
        AppLocalizations.of(context).music,
        AppLocalizations.of(context).chatVoice,
        AppLocalizations.of(context).chatLinks
      ];
    }

    // 💢💢💢 初始化TabController（如果还没有的话）
    if (_tabController == null || _tabController!.length != tabs.length) {
      _tabController?.dispose();
      _tabController = TabController(
        length: tabs.length,
        vsync: this,
      );

      // 💢💢💢 添加监听器，在Tab切换时自动滚动到顶部
      _tabController!.addListener(() {
        // 添加调试信息
        _logger.d('TabController监听器触发', extra: {
          'indexIsChanging': _tabController!.indexIsChanging,
          'currentIndex': _tabController!.index,
        });

        if (_tabController!.indexIsChanging) {
          _logger.i('开始滚动到顶部');
          _scrollToTop();
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Container(
        key: _chatResourcesKey, // 💢💢💢 添加GlobalKey用于定位
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // Tab栏
            TabBar(
              controller: _tabController, // 💢💢💢 使用手动管理的TabController
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              indicatorSize: TabBarIndicatorSize.label,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabAlignment: TabAlignment.start,
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),

            // Tab内容区域
            Expanded(
              child: TabBarView(
                controller: _tabController, // 💢💢💢 使用手动管理的TabController
                children: tabs.map((tab) => _buildTabContent(tab, conversation)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建Tab内容
  Widget _buildTabContent(String tabName, Conversation conversation) {
    // 🔧 修复：使用本地化字符串进行匹配，而不是硬编码的英文字符串
    final localizations = AppLocalizations.of(context);

    if (tabName == localizations.members) {
      return _buildMembersTabContent(conversation);
    } else if (tabName == localizations.media) {
      return _buildMediaTabContent();
    } else if (tabName == localizations.files) {
      return _buildFilesTabContent();
    } else if (tabName == localizations.music) {
      return _buildMusicTabContent();
    } else if (tabName == localizations.chatVoice) {
      return _buildVoiceTabContent();
    } else if (tabName == localizations.chatLinks) {
      return _buildLinksTabContent();
    } else {
      return _buildEmptyTabContent(tabName);
    }
  }

  // 群成员Tab内容
  Widget _buildMembersTabContent(Conversation conversation) {
    // Parse participants JSON and convert to sorted list
    List<Map<String, dynamic>> participants = [];
    try {
      final participantsList = jsonDecode(conversation.participants) as List;
      participants = participantsList.cast<Map<String, dynamic>>();

      // Sort participants by role and name
      participants.sort((a, b) {
        final roleA = a['role'] ?? 'MEMBER';
        final roleB = b['role'] ?? 'MEMBER';

        // Role priority: OWNER < ADMIN < MEMBER
        final priorityA = roleA == 'OWNER' ? 0 : (roleA == 'ADMIN' ? 1 : 2);
        final priorityB = roleB == 'OWNER' ? 0 : (roleB == 'ADMIN' ? 1 : 2);

        if (priorityA != priorityB) return priorityA - priorityB;

        // Same role, sort by name
        final nameA = a['name'] ?? '';
        final nameB = b['name'] ?? '';
        return nameA.compareTo(nameB);
      });
    } catch (e) {
      // JSON parsing failed, use empty list
    }

    if (participants.isEmpty) {
      return const Center(
        child: Text(
          '暂无成员',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: participants.length + 1, // +1 for Add Members button
        itemBuilder: (context, index) {
          if (index == 0) {
            // Add Members按钮
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Members',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final participant = participants[index - 1];
          final isLast = index == participants.length;

          return Column(
            children: [
              _buildMemberItemWithSwipe(participant),
              if (!isLast) const Divider(height: 1, indent: 68),
            ],
          );
        },
      ),
    );
  }

  // 💢💢💢 构建自适应宽度的操作按钮
  Widget _buildAdaptiveWidthAction({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
    required String label,
    bool isFirst = false,
    bool isLast = false,
    required double width, // 💢💢💢 新增：显式指定按钮宽度
  }) {
    return SizedBox(
      width: width, // 💢💢💢 使用指定宽度，而不是 Expanded 均分
      child: Material(
        color: backgroundColor,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
                bottomLeft: isFirst ? const Radius.circular(8) : Radius.zero,
                topRight: isLast ? const Radius.circular(8) : Radius.zero,
                bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: foregroundColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💢💢💢 新增：带右滑功能的成员项
  Widget _buildMemberItemWithSwipe(Map<String, dynamic> participant) {
    final localizations = AppLocalizations.of(context);
    final currentUserId = context.read<ChatCubit>().state.currentUser.userId;

    // Parse participants JSON to get current user's role
    String currentUserRole = 'MEMBER';
    try {
      final participantsList = jsonDecode(context.read<ChatCubit>().state.conversation.participants) as List;
      final participantsMap = participantsList.cast<Map<String, dynamic>>();
      final currentUserParticipant = participantsMap.firstWhere(
        (p) => p['userId'] == currentUserId,
        orElse: () => {'role': 'MEMBER'},
      );
      currentUserRole = currentUserParticipant['role'] ?? 'MEMBER';
    } catch (e) {
      // JSON parsing failed, use default
    }

    // 只有群主和管理员可以执行管理操作，且不能对自己操作
    final canManage = (currentUserRole == 'OWNER' || currentUserRole == 'ADMIN') && participant['userId'] != currentUserId;

    // 群主可以对所有人操作，管理员只能对普通成员操作
    final canOperate = canManage && (currentUserRole == 'OWNER' || _convertRoleToString(participant['role']) == 'MEMBER');

    // 💢💢💢 只有群主可以管理管理员权限
    final canManageAdminRole = currentUserRole == 'OWNER' && participant['userId'] != currentUserId;

    if (!canOperate) {
      // 没有权限操作的成员，返回普通成员项
      return _buildMemberItem(participant);
    }

    // 💢💢💢 根据权限动态构建操作按钮 - 精确计算内容宽度
    final actions = <Widget>[];
    final buttonLabels = <String>[];

    // 💢💢💢 计算每个按钮的实际宽度需求
    final Map<String, double> buttonWidths = {};

    // 管理员权限按钮（只有群主可以操作）
    if (canManageAdminRole) {
      final participantRole = _convertRoleToString(participant['role']);
      final label = participantRole == 'ADMIN' ? localizations.removeAdminRole : localizations.setAsAdmin;
      buttonLabels.add(label);
      buttonWidths[label] = 80.0; // 管理员按钮宽度
      actions.add(
        _buildAdaptiveWidthAction(
          onPressed: () => _toggleAdminRole(participant),
          backgroundColor: participantRole == 'ADMIN' ? Colors.green : AppColors.primary,
          foregroundColor: Colors.white,
          icon: participantRole == 'ADMIN' ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
          label: label,
          isFirst: true,
          width: buttonWidths[label]!,
        ),
      );
    }

    // 屏蔽按钮
    buttonLabels.add(localizations.block);
    buttonWidths[localizations.block] = 64.0; // 屏蔽按钮宽度
    actions.add(
      _buildAdaptiveWidthAction(
        onPressed: () => _blockMember(participant),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: Icons.block,
        label: localizations.block,
        isFirst: actions.isEmpty,
        width: buttonWidths[localizations.block]!,
      ),
    );

    // 删除按钮
    buttonLabels.add(localizations.remove);
    buttonWidths[localizations.remove] = 64.0; // 删除按钮宽度
    actions.add(
      _buildAdaptiveWidthAction(
        onPressed: () => _showRemoveMemberDialog(participant),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete_outline,
        label: localizations.remove,
        isLast: true,
        width: buttonWidths[localizations.remove]!,
      ),
    );

    // 💢💢💢 直接写死按钮宽度，简单有效
    double totalRequiredWidth = 0;
    for (final label in buttonLabels) {
      if (label == localizations.removeAdminRole || label == localizations.setAsAdmin) {
        totalRequiredWidth += 120.0; // 4个字符 + 图标 + 内边距
      } else if (label == localizations.block) {
        totalRequiredWidth += 64.0; // 2个字符 + 图标 + 内边距
      } else if (label == localizations.remove) {
        totalRequiredWidth += 64.0; // 2个字符 + 图标 + 内边距
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final preciseRatio = totalRequiredWidth / screenWidth;

    // 限制在合理范围内，最大不超过0.8（80%屏幕宽度）
    final finalRatio = math.min(preciseRatio, 0.8);

    return Slidable(
      key: Key('member_${participant['userId']}'),
      // 💢💢💢 设置右滑操作 - 使用精确计算的比例
      endActionPane: ActionPane(
        motion: const BehindMotion(), // 使用Behind动画效果更好
        // 💢💢💢 使用精确计算的比例来完全显示内容
        extentRatio: finalRatio,
        children: actions,
      ),
      child: _buildMemberItem(participant),
    );
  }

  // 💢💢💢 新增：显示移除成员确认对话框
  Future<void> _showRemoveMemberDialog(Map<String, dynamic> participant) async {
    final displayName = _getParticipantDisplayName(participant);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).removeMember),
          content: Text(AppLocalizations.of(context).confirmRemoveMember(displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context).remove),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _removeMember(participant);
    }
  }

  // 💢💢💢 新增：屏蔽成员功能
  Future<void> _blockMember(Map<String, dynamic> participant) async {
    final displayName = _getParticipantDisplayName(participant);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).blockMember),
          content: Text(AppLocalizations.of(context).confirmBlockMember(displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: Text(AppLocalizations.of(context).block),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _executeBlockMember(participant);
    }
  }

  // 💢💢💢 新增：执行屏蔽成员的业务逻辑
  Future<void> _executeBlockMember(Map<String, dynamic> participant) async {
    try {
      _logger.i('开始屏蔽群成员', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
        'conversationId': context.read<ChatCubit>().state.conversation.conversationId,
      });

      // 通过ChatCubit执行屏蔽成员操作（遵循DDD架构）
      final chatCubit = context.read<ChatCubit>();
      await chatCubit.blockMemberInConversation(participant['userId']);

      // 暂时显示成功提示
      final displayName = _getParticipantDisplayName(participant);
      UINotificationService().showSuccess(AppLocalizations.of(context).memberBlocked(displayName));

      _logger.i('屏蔽群成员成功', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
      });
    } catch (e) {
      _logger.e('屏蔽群成员失败', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
        'error': e.toString(),
      });

      UINotificationService().showError(AppLocalizations.of(context).blockMemberFailed(e.toString()));
    }
  }

  // 💢💢💢 新增：切换管理员权限
  Future<void> _toggleAdminRole(Map<String, dynamic> participant) async {
    final isCurrentlyAdmin = _convertRoleToString(participant['role']) == 'ADMIN';
    final localizations = AppLocalizations.of(context);
    final displayName = _getParticipantDisplayName(participant);
    final actionText = isCurrentlyAdmin ? localizations.removeAdminRole : localizations.setAsAdmin;
    final confirmText = isCurrentlyAdmin ? localizations.removeAdminRole : localizations.setAsAdmin;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(actionText),
          content: Text(
            isCurrentlyAdmin ? localizations.confirmRemoveAdminRole(displayName) : localizations.confirmSetAsAdmin(displayName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: isCurrentlyAdmin ? Colors.orange : AppColors.primary,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _executeToggleAdminRole(participant, !isCurrentlyAdmin);
    }
  }

  // 💢💢💢 新增：执行管理员权限切换的业务逻辑
  Future<void> _executeToggleAdminRole(Map<String, dynamic> participant, bool makeAdmin) async {
    try {
      final actionText = makeAdmin ? '设为管理员' : '取消管理员权限';

      _logger.i('开始$actionText', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
        'makeAdmin': makeAdmin,
        'conversationId': context.read<ChatCubit>().state.conversation.conversationId,
      });

      // 通过ChatCubit执行管理员权限切换操作（遵循DDD架构）
      final chatCubit = context.read<ChatCubit>();
      await chatCubit.updateMemberRole(participant['userId'], makeAdmin ? MemberRole.ADMIN : MemberRole.MEMBER);

      // 暂时显示成功提示
      final displayName = _getParticipantDisplayName(participant);
      UINotificationService()
          .showSuccess(makeAdmin ? AppLocalizations.of(context).setAsAdminSuccess(displayName) : AppLocalizations.of(context).removeAdminRoleSuccess(displayName));

      _logger.i('$actionText成功', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
        'newRole': makeAdmin ? 'admin' : 'member',
      });
    } catch (e) {
      final actionText = makeAdmin ? '设为管理员' : '取消管理员权限';

      _logger.e('$actionText失败', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
        'error': e.toString(),
      });

      UINotificationService().showError('$actionText失败：${e.toString()}');
    }
  }

  // 💢💢💢 新增：移除成员的业务逻辑
  Future<void> _removeMember(Map<String, dynamic> participant) async {
    try {
      _logger.i('开始移除群成员', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
        'conversationId': context.read<ChatCubit>().state.conversation.conversationId,
      });

      // 通过ChatCubit执行移除成员操作（遵循DDD架构）
      final chatCubit = context.read<ChatCubit>();
      await chatCubit.removeMemberFromConversation(participant['userId']);

      // 暂时显示成功提示
      final displayName = _getParticipantDisplayName(participant);
      UINotificationService().showSuccess(AppLocalizations.of(context).memberRemoved(displayName));

      _logger.i('移除群成员成功', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
      });
    } catch (e) {
      _logger.e('移除群成员失败', extra: {
        'participantId': participant['userId'],
        'participantName': participant['name'],
        'error': e.toString(),
      });

      UINotificationService().showError('移除成员失败：${e.toString()}');
    }
  }

  // 构建单个成员项
  Widget _buildMemberItem(Map<String, dynamic> participant) {
    // 获取当前用户
    final currentUser = context.read<ChatCubit>().state.currentUser;
    // 不能与自己创建私聊，但可以与其他任何成员私聊
    final canOpenChat = participant['userId'] != currentUser.userId;

    return InkWell(
      onTap: canOpenChat ? () => _openPrivateChat(participant) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
                FutureBuilder<String>(
                  future: _getParticipantDisplayNameAsync(participant),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data ?? _getParticipantDisplayName(participant);
                    return UserAvatar(
                      avatarUrl: participant['avatar'],
                      userId: participant['userId'],
                      name: displayName,
                      radius: 26,
                      roleId: participant['roleId'],
                    );
                  },
                ),
                // 在线状态指示器
                if (participant['online'] == true)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _getParticipantDisplayNameAsync(participant),
                          builder: (context, snapshot) {
                            final displayName = snapshot.data ?? _getParticipantDisplayName(participant);
                            return Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                      // 角色标识
                      if (_convertRoleToString(participant['role']) != 'MEMBER')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getMemberRoleColor(_convertRoleToString(participant['role'])),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getMemberRoleDisplayName(_convertRoleToString(participant['role'])),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getMemberRoleTextColor(_convertRoleToString(participant['role'])),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (participant['online'] == true) ? 'online' : 'last seen recently',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 打开与指定成员的私聊
  Future<void> _openPrivateChat(Map<String, dynamic> participant) async {
    try {
      final chatCubit = context.read<ChatCubit>();
      final currentUser = chatCubit.state.currentUser;
      final l10n = AppLocalizations.of(context);

      // 检查是否尝试与自己创建私聊
      if (participant['userId'] == currentUser.userId) {
        UINotificationService().showWarning(l10n.cannotCreatePrivateChat);
        return;
      }

      final conversationId = await chatCubit.chatsRepository.createOrGetConversation(participant['userId']);
      if (conversationId == null) {
        UINotificationService().showError(l10n.failedToCreateChat);
        return;
      }

      if (!context.mounted) return;

      // 从context获取必要的Repository
      final chatRepository = context.read<ChatRepository>();
      final chatsRepository = chatCubit.chatsRepository;
      final chatRepositorySend = chatCubit.chatRepositorySend;
      final navigator = Navigator.of(context);

      // 获取会话信息
      final conversation = await chatsRepository.getConversationById(conversationId);
      if (conversation == null) {
        UINotificationService().showError(l10n.failedToGetConversation);
        return;
      }

      navigator.push(
        MaterialPageRoute(
          builder: (context) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider<ChatRepository>.value(value: chatRepository),
              RepositoryProvider<ChatsRepository>.value(value: chatsRepository),
              RepositoryProvider<ChatRepositorySend>.value(value: chatRepositorySend),
            ],
            child: BlocProvider<ChatCubit>(
              create: (context) => ChatCubit(
                chatRepository: chatRepository,
                chatRepositorySend: chatRepositorySend,
                chatsRepository: chatsRepository,
                currentUser: currentUser,
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
    } catch (e) {
      UINotificationService().showError(AppLocalizations.of(context).failedToOpenChat);
    }
  }

  // 获取成员角色显示名称
  String _getMemberRoleDisplayName(String role) {
    switch (role) {
      case 'OWNER':
        return 'owner';
      case 'ADMIN':
        return 'admin';
      case 'MEMBER':
        return '';
      default:
        return '';
    }
  }

  // 获取成员角色标签颜色
  Color _getMemberRoleColor(String role) {
    switch (role) {
      case 'OWNER':
        return Colors.orange[100]!;
      case 'ADMIN':
        return AppColors.primary.withAlpha(26);
      case 'MEMBER':
        return Colors.grey[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  // 获取成员角色文字颜色
  Color _getMemberRoleTextColor(String role) {
    switch (role) {
      case 'OWNER':
        return Colors.orange[700]!;
      case 'ADMIN':
        return AppColors.primary;
      case 'MEMBER':
        return Colors.grey[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  // Media Tab内容
  Widget _buildMediaTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingMedia && !state.isLoadingMedia) {
          _hasTriedLoadingMedia = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadMediaMessages();
          });
        }

        if (state.isLoadingMedia && state.mediaMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.mediaMessages.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).noMedia,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // 使用自定义的瀑布流GridView显示媒体缩略图
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildStaggeredMediaGrid(state.mediaMessages),
        );
      },
    );
  }

  // Files Tab内容
  Widget _buildFilesTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingFiles && !state.isLoadingFiles) {
          _hasTriedLoadingFiles = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadFileMessages();
          });
        }

        if (state.isLoadingFiles && state.fileMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.fileMessages.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).noFiles,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.fileMessages.length,
          itemBuilder: (context, index) {
            final message = state.fileMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // Music Tab内容
  Widget _buildMusicTabContent() {
    // 音乐消息通常归类为文件消息，这里可以过滤文件消息中的音频文件
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingFiles && !state.isLoadingFiles) {
          _hasTriedLoadingFiles = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadFileMessages();
          });
        }

        // 过滤出音频文件
        final musicMessages = state.fileMessages.where((message) {
          final fileName = _getFileNameFromMessage(message) ?? '';
          return fileName.toLowerCase().endsWith('.mp3') ||
              fileName.toLowerCase().endsWith('.m4a') ||
              fileName.toLowerCase().endsWith('.wav') ||
              fileName.toLowerCase().endsWith('.flac');
        }).toList();

        if (state.isLoadingFiles && musicMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (musicMessages.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).noMusic,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: musicMessages.length,
          itemBuilder: (context, index) {
            final message = musicMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // Voice Tab内容
  Widget _buildVoiceTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingVoice && !state.isLoadingVoice) {
          _hasTriedLoadingVoice = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadVoiceMessages();
          });
        }

        if (state.isLoadingVoice && state.voiceMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.voiceMessages.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).noVoice,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.voiceMessages.length,
          itemBuilder: (context, index) {
            final message = state.voiceMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // Links Tab内容
  Widget _buildLinksTabContent() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 如果还没有尝试过加载且当前没有正在加载，触发加载
        if (!_hasTriedLoadingLinks && !state.isLoadingLinks) {
          _hasTriedLoadingLinks = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatCubit>().loadLinkMessages();
          });
        }

        if (state.isLoadingLinks && state.linkMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.linkMessages.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).noLinks,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.linkMessages.length,
          itemBuilder: (context, index) {
            final message = state.linkMessages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  // 空Tab内容
  Widget _buildEmptyTabContent(String tabName) {
    String message;

    if (tabName == AppLocalizations.of(context).media) {
      message = AppLocalizations.of(context).noMedia;
    } else if (tabName == AppLocalizations.of(context).files) {
      message = AppLocalizations.of(context).noFiles;
    } else if (tabName == AppLocalizations.of(context).music) {
      message = AppLocalizations.of(context).noMusic;
    } else if (tabName == AppLocalizations.of(context).chatVoice) {
      message = AppLocalizations.of(context).noVoice;
    } else if (tabName == AppLocalizations.of(context).chatLinks) {
      message = AppLocalizations.of(context).noLinks;
    } else {
      message = '$tabName content coming soon';
    }

    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  // 显示二维码对话框
  void _showQRCodeDialog(BuildContext context, String id, bool isGroup) {
    final state = context.read<ChatCubit>().state;
    final conversation = state.conversation;
    final isChannel = conversation.type == 'CHANNEL';

    String title;
    String qrData;

    if (isGroup) {
      title = '群组二维码';
      qrData = 'group:$id';
    } else if (isChannel) {
      title = '频道二维码';
      qrData = 'channel:$id';
    } else {
      title = '用户二维码';
      qrData = 'user:$id';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 250,
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 250,
                gapless: false,
              ),
              const SizedBox(height: 16),
              Text(
                qrData,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              // 复制二维码数据到剪贴板
              Clipboard.setData(ClipboardData(text: qrData));
              Navigator.pop(context);
              UINotificationService().showSuccess(AppLocalizations.of(context).qrCodeCopied);
            },
            child: Text(AppLocalizations.of(context).copy),
          ),
        ],
      ),
    );
  }

  // 使用自定义的瀑布流GridView显示媒体缩略图
  Widget _buildStaggeredMediaGrid(List<Message> messages) {
    return MasonryGridView.builder(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildVariableHeightMediaThumbnail(message, index);
      },
    );
  }

  /// 构建可变高度的媒体缩略图
  Widget _buildVariableHeightMediaThumbnail(Message message, int index) {
    // 根据图片的实际尺寸或索引来计算高度
    final height = _calculateThumbnailHeight(message, index);

    return SizedBox(
      height: height,
      child: _buildMediaThumbnail(message),
    );
  }

  /// 计算缩略图高度
  double _calculateThumbnailHeight(Message message, int index) {
    // 如果有图片的实际宽高信息，使用真实比例
    if (_getWidthFromMessage(message) != null && _getHeightFromMessage(message) != null && _getWidthFromMessage(message)! > 0) {
      final aspectRatio = _getHeightFromMessage(message)! / _getWidthFromMessage(message)!;
      // 基础宽度约为屏幕宽度的1/3减去间距
      final baseWidth = (MediaQuery.of(context).size.width - 32 - 8) / 3;
      final calculatedHeight = baseWidth * aspectRatio;
      // 限制高度范围，避免过高或过矮
      return calculatedHeight.clamp(80.0, 300.0);
    }

    // 如果没有尺寸信息，使用预设的随机高度模式来模拟瀑布流效果
    final patterns = [120.0, 160.0, 100.0, 140.0, 180.0, 110.0, 150.0, 130.0, 170.0, 200.0, 90.0, 190.0, 135.0, 175.0, 125.0, 155.0, 185.0, 105.0];
    return patterns[index % patterns.length];
  }

  /// 构建媒体缩略图组件
  Widget _buildMediaThumbnail(Message message) {
    return GestureDetector(
      onTap: () => _showMediaViewer(message),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 缩略图
            _buildThumbnailImage(message),

            // 视频播放图标覆盖层
            if (message.messageType == 'VIDEO')
              Container(
                color: Colors.black.withAlpha(77), // 30% 透明度
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

            // 底部信息栏（可选）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(128), // 50% 透明度
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  _formatMessageDate(message.createdAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示媒体查看器
  void _showMediaViewer(Message message) {
    _logger.i('显示媒体查看器', extra: {
      'messageId': message.messageId,
      'type': message.messageType.toString(),
    });

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            // 媒体内容
            Center(
              child: InteractiveViewer(
                child: _buildFullSizeMedia(message),
              ),
            ),
            // 关闭按钮
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // 媒体信息
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_getFileNameFromMessage(message) != null)
                      Text(
                        _getFileNameFromMessage(message)!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _formatMessageDate(message.createdAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (_getFileSizeFromMessage(message) != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(_getFileSizeFromMessage(message)!.toInt()),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建全尺寸媒体
  Widget _buildFullSizeMedia(Message message) {
    if (message.messageType == 'VIDEO') {
      // 视频播放器
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_filled, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            _getFileNameFromMessage(message) ?? '视频文件',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击播放视频',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      );
    } else {
      // 图片查看
      return _buildThumbnailImage(message);
    }
  }

  /// 构建缩略图图片
  Widget _buildThumbnailImage(Message message) {
    return FutureBuilder<String?>(
      future: Future.value(_getThumbnailUrlFromMessage(message)),
      builder: (context, snapshot) {
        final thumbnailUrl = snapshot.data;
        final mediaUrl = _getMediaUrlFromMessage(message);
        final localPath = _getLocalPathFromMessage(message);

        // 1. 优先使用缩略图URL
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
          if (thumbnailUrl.startsWith('http://') || thumbnailUrl.startsWith('https://')) {
            return _buildCachedNetworkImage(
              thumbnailUrl,
              'thumbnails',
              () => _buildFallbackThumbnail(message),
            );
          } else if (thumbnailUrl.startsWith('file://')) {
            final filePath = thumbnailUrl.substring(7);
            final file = File(filePath);
            if (file.existsSync()) {
              return Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackThumbnail(message);
                },
              );
            }
          } else {
            // 直接的文件路径
            final file = File(thumbnailUrl);
            if (file.existsSync()) {
              return Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackThumbnail(message);
                },
              );
            }
          }
        }

        // 2. 如果有媒体URL，尝试加载网络图片
        if (mediaUrl != null && mediaUrl.isNotEmpty) {
          if (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://')) {
            return _buildCachedNetworkImage(
              mediaUrl,
              'images',
              () => _buildFallbackThumbnail(message),
            );
          } else if (mediaUrl.startsWith('file://')) {
            final filePath = mediaUrl.substring(7);
            final file = File(filePath);
            if (file.existsSync()) {
              return Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackThumbnail(message);
                },
              );
            }
          } else {
            // 直接的文件路径
            final file = File(mediaUrl);
            if (file.existsSync()) {
              return Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackThumbnail(message);
                },
              );
            }
          }
        }

        // 3. 最后才尝试使用本地路径（仅当其他都失败时）
        if (localPath != null && localPath.isNotEmpty) {
          final localFile = File(localPath);
          if (localFile.existsSync()) {
            return Image.file(
              localFile,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackThumbnail(message);
              },
            );
          }
        }

        // 兜底方案
        return _buildFallbackThumbnail(message);
      },
    );
  }

  /// 构建兜底缩略图
  Widget _buildFallbackThumbnail(Message message) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            message.messageType == 'IMAGE' ? Icons.image : Icons.videocam,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            message.messageType == 'IMAGE' ? '图片' : '视频',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 💢💢💢 新增：构建消息项组件
  Widget _buildMessageItem(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 根据消息类型显示不同的图标
          _buildMessageIcon(message),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMessageDisplayName(message),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getMessageSubInfo(message),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildMessageAction(message),
        ],
      ),
    );
  }

  /// 构建消息图标
  Widget _buildMessageIcon(Message message) {
    Color iconColor;
    IconData iconData;
    Color backgroundColor;

    switch (message.messageType) {
      case 'IMAGE':
        iconData = Icons.image;
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withAlpha(26);
        break;
      case 'VIDEO':
        iconData = Icons.videocam;
        iconColor = Colors.purple[700]!;
        backgroundColor = Colors.purple[100]!;
        break;
      case 'VOICE':
        iconData = Icons.mic;
        iconColor = Colors.green[700]!;
        backgroundColor = Colors.green[100]!;
        break;
      case 'FILE':
        iconData = Icons.insert_drive_file;
        iconColor = Colors.orange[700]!;
        backgroundColor = Colors.orange[100]!;
        break;
      default: // 链接消息（文本类型但包含链接）
        iconData = Icons.link;
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withAlpha(26);
        break;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  /// 获取消息显示名称
  String _getMessageDisplayName(Message message) {
    switch (message.messageType) {
      case 'IMAGE':
        return _getFileNameFromMessage(message) ?? 'image.jpg';
      case 'VIDEO':
        return _getFileNameFromMessage(message) ?? 'video.mp4';
      case 'VOICE':
        final duration = _getDurationFromMessage(message) ?? 0;
        return '语音消息 ${_formatDuration(duration.toDouble() / 1000)}';
      case 'FILE':
        return _getFileNameFromMessage(message) ?? 'file';
      default: // 链接消息
        if (_getTextFromMessage(message) != null && _getTextFromMessage(message)!.contains('http')) {
          // 提取第一个链接
          final urlRegex = RegExp(r'https?://[^\s]+');
          final match = urlRegex.firstMatch(_getTextFromMessage(message)!);
          return match?.group(0) ?? _getTextFromMessage(message)!;
        }
        return _getTextFromMessage(message) ?? '链接';
    }
  }

  /// 获取消息附加信息
  String _getMessageSubInfo(Message message) {
    final dateStr = _formatMessageDate(message.createdAt);

    switch (message.messageType) {
      case 'IMAGE':
      case 'VIDEO':
      case 'FILE':
        // 从消息content中提取fileSize
        String sizeStr = '';
        try {
          if (message.content != null) {
            final content = jsonDecode(message.content!);
            final fileSize = content['fileSize'];
            if (fileSize != null) {
              sizeStr = _formatFileSize(fileSize.toInt());
            }
          }
        } catch (e) {
          // JSON解析失败，使用空字符串
        }
        return sizeStr.isNotEmpty ? '$sizeStr • $dateStr' : dateStr;
      case 'VOICE':
        // 从消息content中提取duration
        int duration = 0;
        try {
          if (message.content != null) {
            final content = jsonDecode(message.content!);
            duration = content['duration'] ?? 0;
          }
        } catch (e) {
          // JSON解析失败，使用默认值0
        }
        return '${_formatDuration(duration.toDouble() / 1000)} • $dateStr';
      default: // 链接消息
        return dateStr;
    }
  }

  /// 构建消息操作按钮
  Widget _buildMessageAction(Message message) {
    return Icon(
      _getActionIcon(message.messageType),
      color: Colors.grey[600],
      size: 20,
    );
  }

  /// 获取操作图标
  IconData _getActionIcon(String type) {
    switch (type) {
      case 'IMAGE':
      case 'VIDEO':
        return Icons.visibility;
      case 'VOICE':
        return Icons.play_arrow;
      case 'FILE':
        return Icons.download;
      default: // 链接
        return Icons.open_in_new;
    }
  }

  /// 从消息content JSON中提取文件名
  String? _getFileNameFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['fileName'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取宽度
  int? _getWidthFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['width'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取高度
  int? _getHeightFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['height'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取文件大小
  double? _getFileSizeFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['fileSize']?.toDouble();
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取时长
  int? _getDurationFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['duration'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取文本
  String? _getTextFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['text'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取缩略图URL
  String? _getThumbnailUrlFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['thumbnailUrl'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取媒体URL
  String? _getMediaUrlFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['mediaUrl'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 从消息content JSON中提取本地路径
  String? _getLocalPathFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['localPath'];
      }
    } catch (e) {
      // JSON解析失败，返回null
    }
    return null;
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// 格式化语音时长
  String _formatDuration(double seconds) {
    final secondsInt = seconds.round();
    final minutes = secondsInt ~/ 60;
    final remainingSeconds = secondsInt % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 格式化消息日期
  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 更新会话名称（群聊和频道）
  Future<bool> _updateConversationName(String conversationId, String? newName) async {
    try {
      _logger.i('开始更新会话名称', extra: {
        'conversationId': conversationId,
        'newName': newName,
      });

      final chatCubit = context.read<ChatCubit>();
      final success = await chatCubit.updateConversationName(conversationId, newName);

      _logger.i('会话名称更新结果', extra: {
        'conversationId': conversationId,
        'success': success,
      });

      return success;
    } catch (e) {
      _logger.e('更新会话名称失败', extra: {
        'conversationId': conversationId,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 构建缓存网络图片
  Widget _buildCachedNetworkImage(
    String url,
    String mediaType,
    Widget Function() fallbackBuilder,
  ) {
    return FutureBuilder<String?>(
      future: _getCachedMedia(url, mediaType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return fallbackBuilder();
        }

        return Image.file(
          File(snapshot.data!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return fallbackBuilder();
          },
        );
      },
    );
  }

  /// 获取缓存媒体文件
  Future<String?> _getCachedMedia(String url, String mediaType) async {
    try {
      if (mediaType == 'thumbnails') {
        return await ThumbnailCacheService().getThumbnail(url);
      } else {
        return await MediaCacheService().getMedia(url, mediaType);
      }
    } catch (e) {
      return null;
    }
  }
}
