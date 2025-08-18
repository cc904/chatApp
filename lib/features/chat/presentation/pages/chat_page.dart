import 'dart:async';
import 'dart:math';
import 'dart:io' show File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:image_picker/image_picker.dart' show XFile;

import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:drift/drift.dart' show OrderingTerm;
// Proto imports removed as they're not currently used
import 'package:cc/core/services/log_service.dart';
// import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/core/widgets/connection_status_indicator.dart';
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// Message class is now imported from drift_database.dart
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
// import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:cc/features/chat/presentation/widgets/message_item.dart';
import 'package:cc/features/chat/presentation/widgets/message_separators.dart';
import 'package:cc/features/chat/presentation/utils/message_list_processor.dart';
import 'package:cc/core/services/voice_record_service.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/core/services/media_upload_integration_service.dart';
import 'package:cc/core/services/audio_player_manager.dart';
import 'package:cc/core/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cc/core/services/clipboard_service.dart';
import 'package:cc/features/chat/presentation/widgets/unread_indicator_button.dart';
import 'package:cc/features/chat/presentation/widgets/quick_reply_panel.dart';
import 'package:mime/mime.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/core/utils/user_display_utils.dart';

import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
// import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/constants/app_colors.dart';

/// 聊天页面
///
/// 使用scrollable_positioned_list来实现高性能的消息列表滚动
/// 支持滚动到指定消息位置，适合处理大量历史消息
class ChatPage extends StatefulWidget {
  /// 会话ID
  final String conversationId;

  /// 💢💢💢 初始会话信息（可选）
  /// 从 ChatsPage 传入，避免重复加载
  final Conversation? initialConversation;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.initialConversation,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  static final _logger = LogService.instance;

  // 已不再使用
  // String? _getTextFromMessage(Message message) => null;

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

  Timer? _scrollDebounceTimer;
  Timer? _searchDebounceTimer; // 💢💢💢 新增：搜索防抖Timer
  Timer? _visibilityReadUpdateTimer; // 🆕 可见性已读更新定时器

  /// 滚动控制器 - 用于控制列表滚动位置
  final ItemScrollController _itemScrollController = ItemScrollController();

  /// 位置监听器 - 用于监听当前可见项的位置
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  /// 文本输入控制器
  final TextEditingController _textController = TextEditingController();

  // 🆕 新消息自动滚动期间抑制未读指示器闪烁
  bool _isAutoScrollingToBottom = false;
  Timer? _autoScrollSuppressTimer;

  /// 💢💢💢 新增：搜索输入控制器
  final TextEditingController _searchController = TextEditingController();

  /// 焦点控制器
  final FocusNode _focusNode = FocusNode();

  /// 输入框文本变化通知器
  final ValueNotifier<String> _textNotifier = ValueNotifier<String>('');

  /// 复制提示状态
  final ValueNotifier<String> _copyMessageNotifier = ValueNotifier<String>('');
  Timer? _copyMessageTimer;

  /// 新增：输入模式状态
  bool _isVoiceMode = false;
  bool _showMoreOptions = false;
  bool _showEmojiPanel = false;
  bool _showQuickReplyPanel = false; // 新增：快捷回复面板状态
  bool _isRecording = false;
  bool _isVideoRecording = false;

  /// 录制时间相关
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  /// 💢💢💢 首次渲染检查标志
  bool _hasCheckedInitialPosition = false;

  /// 格式化录制时间
  String _formatRecordingTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 随机数生成器 - 用于随机选择SVG背景图案
  final Random _random = Random();

  /// SVG背景图案列表
  final List<String> _svgPatterns = [
    'assets/images/pattern-19.svg',
    'assets/images/pattern-13.svg',
    'assets/images/pattern-15.svg',
  ];

  /// 当前选择的SVG图案
  late String _selectedSvgPattern;

  /// SVG资源是否可用
  bool _svgAssetsAvailable = true;

  /// 剪贴板服务实例
  final ClipboardService _clipboardService = ClipboardService();

  /// 处理粘贴动作
  Future<void> _handlePasteAction() async {
    try {

      // 检查是否支持图片剪贴板
      if (!_clipboardService.supportsImageClipboard) {
        return;
      }

      // 检查剪贴板是否有图片
      final hasImage = await _clipboardService.hasImage();
      if (!hasImage) {
        return;
      }

      

      // 获取图片数据
      final imageData = await _clipboardService.getImageData();
      if (imageData == null) {
        _showSnackBar('粘贴图片失败');
        return;
      }

      // 保存到临时文件
      final tempFile = await _clipboardService.saveImageToTempFile(imageData);
      if (tempFile == null) {
        _showSnackBar('粘贴图片失败');
        return;
      }

      

      // 隐藏面板
      if (mounted) {
        setState(() {
          _showMoreOptions = false;
          _showEmojiPanel = false;
        });
      }

      // 使用现有的图片预览和发送流程
      await _showImagePreviewAndSend(tempFile);

      _showSnackBar('图片粘贴成功');
    } catch (error) {
      _logger.e('处理剪贴板图片粘贴失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        _showSnackBar('粘贴图片失败');
      }
    }
  }

  /// 显示提示信息
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // 随机选择一个SVG图案
    _selectedSvgPattern = _svgPatterns[_random.nextInt(_svgPatterns.length)];

    // 验证SVG资源是否可用
    _validateSvgAssets();

    // 初始化动画控制器
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(); // 无限循环

    // 监听滚动位置变化
    _itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);

    // 监听文本控制器变化
    _textController.addListener(() {
      _textNotifier.value = _textController.text;
    });

    // 初始化媒体上传服务
    _initializeMediaServices();

    // 页面初始化后，同步当前会话详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 🔥🔥🔥 检查ChatCubit的初始状态
        final chatCubit = context.read<ChatCubit>();
        final state = chatCubit.state;
        final roleId = state.currentUser.roleId;

        

        // 解析参与者，忽略调试输出
        try {
          ConversationAdapter.parseParticipants(state.conversation.participants);
        } catch (_) {}

        // 记录权限状态（移除冗余日志）

        // 🔥🔥🔥 额外的权限测试
        _testQuickReplyPermissions(roleId);

        // 🔧 初始化快捷回复交由 ChatCubit 内部流程触发，避免重复调用导致重复响应

        context.read<ChatCubit>().syncCurrentConversation();
      }
    });
  }

  /// 初始化媒体服务
  void _initializeMediaServices() {
    // 在Widget构建完成后初始化媒体上传服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatCubit = context.read<ChatCubit>();

      // 获取ChatRepositorySend实例
      final chatRepositorySend = chatCubit.chatRepositorySend;

      // 初始化文件上传服务
      // FileUploadService 为单例且无需显式初始化

      // 初始化媒体上传集成服务
      // UploadApiService使用独立文件服务器，无需认证token
      _mediaUploadIntegrationService.initialize(chatRepositorySend);

      
    });
  }

  @override
  void dispose() {
    _autoScrollSuppressTimer?.cancel();
    _textController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _textNotifier.dispose();
    _copyMessageNotifier.dispose();
    _waveAnimationController.dispose();
    _scrollDebounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _recordingTimer?.cancel();
    _copyMessageTimer?.cancel();
    _visibilityReadUpdateTimer?.cancel();
    // 释放媒体录制服务
    _voiceRecordService.dispose();
    // 🆕 停止音频播放
    AudioPlayerManager().stopAll();
    super.dispose();
  }

  /// 调试：显示当前会话的本地消息索引与文本
  Future<void> _showConversationLocalDump() async {
    try {
      final chatCubit = context.read<ChatCubit>();
      final conversationId = chatCubit.state.conversation.conversationId;
      final db = DatabaseInitializer.database;

      // 查询该会话所有消息，按 messageIndex 升序
      final rows = await (db.select(db.messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.asc(m.messageIndex)]))
          .get();

      // 生成展示用字符串（index + 文本内容预览）
      final lines = <String>[];
      for (final m in rows) {
        String preview = '';
        try {
          if (m.content != null && m.content!.isNotEmpty) {
            final map = jsonDecode(m.content!);
            if (map is Map && map.containsKey('text_message')) {
              final tm = map['text_message'];
              if (tm is Map && tm['text'] is String) {
                preview = (tm['text'] as String).trim();
              }
            }
          }
        } catch (_) {}
        if (preview.length > 120) preview = preview.substring(0, 120) + '…';
        lines.add('[${m.messageIndex}] ${preview.isEmpty ? '(非文本/无文本)' : preview}');
      }

      final body = lines.isEmpty
          ? '无本地消息'
          : lines.join('\n');

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('当前会话本地消息（index + 文本）'),
          content: SingleChildScrollView(
            child: SelectableText(body),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      _logger.e('本地消息调试弹窗失败', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('调试失败: $e')),
      );
    }
  }

  /// 调试：显示当前状态中的消息（index + mm:ss + 文本）
  Future<void> _showStateMessagesDump() async {
    try {
      final chatCubit = context.read<ChatCubit>();
      final messages = chatCubit.state.messages;

      final lines = <String>[];
      for (final m in messages) {
        final created = m.createdAt.toLocal();
        final mm = created.minute.toString().padLeft(2, '0');
        final ss = created.second.toString().padLeft(2, '0');
        String preview = '';
        try {
          if (m.content != null && m.content!.isNotEmpty) {
            final map = jsonDecode(m.content!);
            if (map is Map && map.containsKey('text_message')) {
              final tm = map['text_message'];
              if (tm is Map && tm['text'] is String) {
                preview = (tm['text'] as String).trim();
              }
            }
          }
        } catch (_) {}
        if (preview.length > 120) preview = preview.substring(0, 120) + '…';
        lines.add('[${m.messageIndex}] $mm:$ss ${preview.isEmpty ? '(非文本/无文本)' : preview}');
      }

      final body = lines.isEmpty ? '无state消息' : lines.join('\n');

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('状态消息（index + mm:ss + 文本）'),
          content: SingleChildScrollView(child: SelectableText(body)),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('关闭')),
          ],
        ),
      );
    } catch (e) {
      _logger.e('状态消息调试弹窗失败', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('调试失败: $e')),
      );
    }
  }

  /// 💢💢💢 滚动位置变化监听
  void _onScrollPositionChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      // 💢💢💢 首次渲染后检查位置
      _checkInitialPositionAfterRender();

      // 💢💢💢 保留基本防抖，ChatCubit层的去重逻辑已足够防止不必要的重绘
      _scrollDebounceTimer?.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 200), () {
        context.read<ChatCubit>().updateCurrentScrollPosition(positions);
      });
    }
  }

  /// 💢💢💢 检查初始渲染后的滚动位置
  void _checkInitialPositionAfterRender() {
    if (_hasCheckedInitialPosition) return;

    final state = context.read<ChatCubit>().state;
    final currentScrollPosition = state.currentScrollPosition;

    // 只在 relativePosition == 1.0 时进行检查
    if (currentScrollPosition.relativePosition != 1.0) {
      _hasCheckedInitialPosition = true;
      return;
    }

    // 延迟检查，确保列表已完全渲染
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialPositionCheck();
    });
  }

  /// 💢💢💢 执行初始位置检查
  void _performInitialPositionCheck() {
    if (_hasCheckedInitialPosition || !_itemScrollController.isAttached) {
      return;
    }

    try {
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      // 查找最新消息（索引为0的项目）
      final newestItemPosition = positions.cast<ItemPosition?>().firstWhere(
            (pos) => pos?.index == 0,
            orElse: () => null,
          );

      if (newestItemPosition == null) return;

      // 检查最新消息是否贴底
      // 在 reverse: true 中，itemLeadingEdge 接近 0.0 表示消息在屏幕底部
      final isAtBottom = newestItemPosition.itemLeadingEdge <= 0.02;

      _logger.d('💢 初始位置检查', extra: {
        'newestItemIndex': newestItemPosition.index,
        'itemLeadingEdge': newestItemPosition.itemLeadingEdge,
        'itemTrailingEdge': newestItemPosition.itemTrailingEdge,
        'isAtBottom': isAtBottom,
      });

      if (!isAtBottom) {
        // 最新消息没有贴底，需要重新滚动到底部
        _logger.i('检测到消息列表未贴底，执行底部对齐');

        _itemScrollController.jumpTo(
          index: 0,
          alignment: 0.0, // 消息顶部对齐屏幕底部
        );
      }

      _hasCheckedInitialPosition = true;
    } catch (e) {
      _logger.w('初始位置检查失败', extra: {'error': e.toString()});
      _hasCheckedInitialPosition = true;
    }
  }

  /// 💢💢💢 完善的滚动到指定消息方法
  Future<void> _scrollToMessage(
    int targetMessageIndex, {
    Duration? duration,
    Curve? curve,
    double? alignment,
    bool showHighlight = false,
    bool jumpImmediately = false, // 💢💢💢 新增：立即跳转参数
  }) async {
    try {
      final state = context.read<ChatCubit>().state;

      _logger.i('开始滚动到消息', extra: {
        'targetMessageIndex': targetMessageIndex,
        'totalMessages': state.messages.length,
        'showHighlight': showHighlight,
        'jumpImmediately': jumpImmediately,
      });

      // 查找消息在当前列表中的索引
      final messageListIndex = state.messages.indexWhere(
        (message) => message.messageIndex == targetMessageIndex,
      );

      if (messageListIndex == -1) {
        _logger.w('消息未在当前列表中找到', extra: {
          'targetMessageIndex': targetMessageIndex,
          'searchInDatabase': true,
        });

        // 💢💢💢 如果消息不在当前列表中，尝试从数据库加载
        await _loadMessageAndScroll(targetMessageIndex);
        return;
      }

      // 💢💢💢 处理消息列表，添加分隔符，以获取正确的processedItems索引
      final currentUserId = state.currentUser.userId;
      final isNotGroupChat = state.conversation.type != 'GROUP';
      final processedItems = MessageListProcessor.processMessages(
        messages: state.messages,
        currentUserId: currentUserId,
        isNotGroupChat: isNotGroupChat,
      );

      // Get the actual message for further operations
      final targetMessage = state.messages[messageListIndex];

      // 💢💢💢 在processedItems中查找对应的索引
      final processedIndex = processedItems.indexWhere((item) {
        return item is MessageListItemData && item.message.messageIndex == targetMessageIndex;
      });

      if (processedIndex == -1) {
        _logger.w('消息在processedItems中未找到', extra: {
          'messageId': targetMessage.messageId,
          'targetMessageIndex': targetMessageIndex,
        });
        return;
      }

      // 💢💢💢 检查滚动控制器是否可用
      if (!_itemScrollController.isAttached) {
        _logger.w('滚动控制器未附加，延迟执行滚动');

        // 等待下一帧再尝试滚动
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMessage(
            targetMessageIndex,
            duration: duration,
            curve: curve,
            alignment: alignment,
            showHighlight: showHighlight,
            jumpImmediately: jumpImmediately,
          );
        });
        return;
      }

      // 💢💢💢 根据参数选择立即跳转或动画滚动
      if (jumpImmediately) {
        // 立即跳转，无动画
        _itemScrollController.jumpTo(
          index: processedIndex,
          alignment: alignment ?? 0.5,
        );

        _logger.i('立即跳转完成', extra: {
          'messageId': targetMessage.messageId,
          'targetMessageIndex': targetMessageIndex,
          'processedIndex': processedIndex,
          'alignment': alignment ?? 0.5,
        });
      } else {
        // 动画滚动
        await _itemScrollController.scrollTo(
          index: processedIndex,
          duration: duration ?? const Duration(milliseconds: 300),
          curve: curve ?? Curves.easeInOut,
          alignment: alignment ?? 0.5,
        );

        _logger.i('动画滚动完成', extra: {
          'messageId': targetMessage.messageId,
          'targetMessageIndex': targetMessageIndex,
          'processedIndex': processedIndex,
          'alignment': alignment ?? 0.5,
        });
      }

      // 💢💢💢 可选的高亮效果
      if (showHighlight) {
        _highlightMessage(targetMessage.messageId);
      }
    } catch (error) {
      _logger.e('滚动到消息失败', error: error, extra: {
        'targetMessageIndex': targetMessageIndex,
      });
    }
  }

  /// 💢💢💢 新增：加载消息并滚动（当消息不在当前列表中时）
  Future<void> _loadMessageAndScroll(int messageIndex) async {
    try {
      _logger.i('消息不在当前列表，尝试加载消息', extra: {
        'messageIndex': messageIndex,
      });

      // 💢💢💢 重置首次位置检查标志，因为要加载新的消息列表
      _hasCheckedInitialPosition = false;

      final chatCubit = context.read<ChatCubit>();

      // 💢💢💢 尝试加载包含目标消息的消息段
      final success = await chatCubit.loadMessagesAroundMessage(messageIndex);

      if (success) {
        // 加载成功后，等待UI更新，然后再次尝试滚动
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMessage(messageIndex, showHighlight: true);
        });
      } else {
        _logger.w('无法加载包含目标消息的消息段', extra: {
          'messageIndex': messageIndex,
        });

        // 显示提示信息
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text(localizations.cannotLocateMessage),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('加载消息并滚动失败', error: error, extra: {
        'messageIndex': messageIndex,
      });
    }
  }

  /// 💢💢💢 新增：高亮显示消息（可选功能）
  void _highlightMessage(String messageId) {
    try {
      _logger.d('触发消息高亮效果', extra: {
        'messageId': messageId,
      });

      // 通过ChatCubit实现消息高亮
      final chatCubit = context.read<ChatCubit>();
      chatCubit.highlightMessage(messageId);
    } catch (error) {
      _logger.e('消息高亮失败', error: error, extra: {
        'messageId': messageId,
      });
    }
  }

  /// 🆕 检查用户是否在聊天底部
  /// 返回true表示用户在底部，应该在发送新消息时自动滚动
  bool _isUserAtBottom() {
    // 如果滚动控制器没有附加，认为在底部（初始状态）
    if (!_itemScrollController.isAttached) {
      _logger.d('滚动控制器未附加，认为在底部');
      return true;
    }

    try {
      final state = context.read<ChatCubit>().state;
      final positions = _itemPositionsListener.itemPositions.value;

      if (positions.isEmpty || state.messages.isEmpty) {
        _logger.d('没有位置信息或消息为空，认为在底部');
        return true;
      }

      // 处理消息列表，获取processedItems
      final currentUserId = state.currentUser.userId;
      final isNotGroupChat = state.conversation.type != 'GROUP';
      final processedItems = MessageListProcessor.processMessages(
        messages: state.messages,
        currentUserId: currentUserId,
        isNotGroupChat: isNotGroupChat,
      );

      if (processedItems.isEmpty) {
        _logger.d('processedItems为空，认为在底部');
        return true;
      }

      // 检查第一个item（最新消息）是否可见
      // 在reverse列表中，index 0 是最新的消息
      final firstItemPosition = positions.where((pos) => pos.index == 0).firstOrNull;

      if (firstItemPosition != null) {
        // 如果最新消息可见且其trailing edge >= 0.8，认为用户在底部
        final isAtBottom = firstItemPosition.itemTrailingEdge >= 0.8;

        _logger.d('检查底部位置', extra: {
          'firstItemIndex': firstItemPosition.index,
          'itemTrailingEdge': firstItemPosition.itemTrailingEdge,
          'isAtBottom': isAtBottom,
          'threshold': 0.8,
        });

        return isAtBottom;
      }

      // 如果第一个item不可见，检查是否有其他靠近顶部的item
      final topPositions = positions.where((pos) => pos.index <= 2).toList();
      if (topPositions.isNotEmpty) {
        // 如果前几个item可见，认为接近底部
        final isNearBottom = topPositions.any((pos) => pos.itemTrailingEdge >= 0.5);

        _logger.d('检查是否接近底部', extra: {
          'topPositions': topPositions
              .map((p) => {
                    'index': p.index,
                    'trailingEdge': p.itemTrailingEdge,
                  })
              .toList(),
          'isNearBottom': isNearBottom,
        });

        return isNearBottom;
      }

      _logger.d('无法确定位置，认为不在底部');
      return false;
    } catch (error) {
      _logger.e('检查底部位置失败', error: error);
      // 出错时保守地认为不在底部，避免不必要的滚动
      return false;
    }
  }

  /// 🆕 滚动到最新消息（发送消息后使用）
  Future<void> _scrollToBottom({bool animated = true}) async {
    try {
      final state = context.read<ChatCubit>().state;

      if (state.messages.isEmpty) {
        _logger.d('没有消息，无需滚动');
        return;
      }

      // 获取最新消息
      final latestMessage = state.messages.first; // messages是按时间降序排列的

      if (animated) {
        await _scrollToMessage(
          latestMessage.messageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 1.0, // 💢💢💢 修正：在reverse列表中，1.0表示滚动到物理屏幕顶部
        );
      } else {
        await _scrollToMessage(
          latestMessage.messageIndex,
          alignment: 1.0, // 💢💢💢 修正：在reverse列表中，1.0表示滚动到物理屏幕顶部
          jumpImmediately: true,
        );
      }

      _logger.i('滚动到最新消息完成', extra: {
        'messageId': latestMessage.messageId,
        'animated': animated,
      });
    } catch (error) {
      _logger.e('滚动到最新消息失败', error: error);
    }
  }

  /// 发送消息
  void _sendMessage() {
    final text = _textController.text.trim();

    // 验证输入
    if (text.isEmpty) {
      return;
    }

    // 验证文本长度
    if (text.length > 4000) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.messageTooLongDetails),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 🆕 在发送消息前检查用户是否在底部
    final wasAtBottom = _isUserAtBottom();

    _logger.i('发送消息前检查位置', extra: {
      'wasAtBottom': wasAtBottom,
      'textLength': text.length,
    });

    // 发送消息
    try {
      final chatCubit = context.read<ChatCubit>();
      final state = chatCubit.state;

      // 根据是否有回复消息选择发送方法
      if (state.replyingToMessage != null) {
        chatCubit.sendReplyTextMessage(text);
      } else {
        chatCubit.sendTextMessage(text);
      }

      _textController.clear();

      // 🆕 如果用户在底部，发送成功后自动滚动到新消息
      if (wasAtBottom) {
        // 延迟一点时间，确保新消息已经添加到列表中
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 再次检查确保消息已添加
          Timer(const Duration(milliseconds: 100), () {
            if (mounted) {
              _scrollToBottom(animated: true);
            }
          });
        });
      }

      // 🔧 优化后的焦点管理：由于BlocBuilder不再因isSending变化重建，焦点自然保持

      // 轻微震动反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('发送消息失败', error: error);

      // 显示错误提示
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.sendFailed}: ${error.toString()}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () {
                _textController.text = text;
                _sendMessage();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) {
        // 💢💢💢 监听导航状态变化
        return previous.shouldNavigateBack != current.shouldNavigateBack;
      },
      listener: (context, state) {
        // 💢💢💢 处理导航回上一页
        if (state.shouldNavigateBack) {
          // 导航回上一页
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            try {
              Navigator.popUntil(context, (route) => route.isFirst);
            } catch (e) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
                (route) => false,
              );
            }
          }

          // 重置导航状态（避免重复导航）
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<ChatCubit>().resetNavigationState();
            }
          });
        }
      },
      child: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) {
          return previous.isSearchMode != current.isSearchMode ||
              previous.searchQuery != current.searchQuery ||
              previous.conversation.muted != current.conversation.muted ||
              previous.conversation.name != current.conversation.name ||
              previous.conversation.participants != current.conversation.participants ||
              // 未读指示器依赖滚动位置与最新消息索引
              previous.currentScrollPosition != current.currentScrollPosition ||
              previous.conversation.lastMessageIndex != current.conversation.lastMessageIndex ||
              // 🆕 未读相关：当未读数或已读索引变化时触发重建
              previous.conversation.unreadCount != current.conversation.unreadCount ||
              previous.networkStatus != current.networkStatus;
        },
        builder: (context, state) {
          return Scaffold(
            appBar: state.isSearchMode ? _buildSearchAppBar() : _buildAppBar(state),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: _buildMessagesList(),
                    ),
                    state.isSearchMode ? _buildSearchBottomBar() : _buildInputArea(),
                  ],
                ),
                // 录制动画覆盖层
                if (_isRecording) _buildRecordingOverlay(),
                // 🆕 未读消息指示器
                _buildUnreadIndicator(state),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(ChatState state) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主标题行：连接状态 + 会话名称 + 静音图标
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ConnectionStatusIndicator(size: 14),
              const SizedBox(width: 4),
              Hero(
                tag: 'chat_title_${state.conversation.conversationId}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    _getConversationDisplayName(state.conversation, state.currentUser.userId),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // 静音图标（只在静音时显示）
              if (state.conversation.muted)
                const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.volume_off,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          // 副标题：在线状态 / 正在输入
          Hero(
            tag: 'chat_subtitle_${state.conversation.conversationId}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                (state.conversation.type == 'PRIVATE' && state.isOtherUserTyping)
                    ? AppLocalizations.of(context).typing
                    : _getLastSeenText(state),
                style: TextStyle(
                  fontSize: 12,
                  color: (state.conversation.type == 'PRIVATE' && state.isOtherUserTyping)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // 调试按钮
        if (kDebugMode) ...[
          IconButton(
            icon: const Icon(Icons.bug_report, size: 20),
            onPressed: _showConversationLocalDump,
            tooltip: '本地会话消息(index+文本)',
          ),
          IconButton(
            icon: const Icon(Icons.list_alt, size: 20),
            onPressed: _showStateMessagesDump,
            tooltip: '状态消息(index+时间+文本)',
          ),
        ],
        // 会话头像
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
            onTap: () {
              final chatCubit = context.read<ChatCubit>();
              final chatRepository = context.read<ChatRepository>();
              final chatsRepository = context.read<ChatsRepository>();
              final chatRepositorySend = context.read<ChatRepositorySend>();
              // ChatsCubit / ContactCubit / ContactsRepository 均不在此强制依赖

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider<ChatRepository>.value(value: chatRepository),
                      RepositoryProvider<ChatsRepository>.value(value: chatsRepository),
                      RepositoryProvider<ChatRepositorySend>.value(value: chatRepositorySend),
                    ],
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider<ChatCubit>.value(value: chatCubit),
                      ],
                      child: const ChatInfoPage(),
                    ),
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'chat_avatar_${state.conversation.conversationId}',
              child: UserAvatar(
                avatarUrl: (() {
                  if (state.conversation.type == 'PRIVATE') {
                    final other = UserDisplayUtils.getOtherUserFromConversation(state.conversation, state.currentUser.userId);
                    return other != null ? other['avatar'] as String? : null;
                  }
                  return state.conversation.avatar;
                })(),
                userId: state.conversation.type == 'PRIVATE' ?
                  (() {
                    final other = UserDisplayUtils.getOtherUserFromConversation(state.conversation, state.currentUser.userId);
                    // LogService.instance.i('🧭 ChatPage AppBar 头像参数', extra: {
                    //   'conversationId': state.conversation.conversationId,
                    //   'conversationAvatar': state.conversation.avatar,
                    //   'currentUserId': state.currentUser.userId,
                    //   'otherUserId': other != null ? other['userId'] : null,
                    //   'otherAvatar': other != null ? other['avatar'] : null,
                    // });
                    return other != null ? other['userId'] as String? : null;
                  })()
                  : state.conversation.conversationId,
                name: state.conversation.name ?? '未命名会话',
                radius: 18.0,
                roleId: _getConversationDisplayRoleId(state.conversation, state.currentUser.userId),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建SVG背景图案
  Widget _buildSvgBackground() {
    // 如果SVG资源不可用，直接返回透明容器
    if (!_svgAssetsAvailable) {
      return Container(color: Colors.transparent);
    }

    return SvgPicture.asset(
      _selectedSvgPattern,
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.white.withAlpha(26), // 非常淡的白色，让图案不那么明显
        BlendMode.modulate,
      ),
      placeholderBuilder: (BuildContext context) => Container(
        color: Colors.transparent,
        child: const Center(
          child: Text(
            '',
            style: TextStyle(color: Colors.transparent),
          ),
        ),
      ),
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        // 资源加载失败时返回透明容器，不影响UI
        _logger.w('SVG背景加载失败，使用透明背景', extra: {'pattern': _selectedSvgPattern, 'error': error.toString()});
        return Container(color: Colors.transparent);
      },
    );
  }

  /// 验证SVG资源是否可用
  Future<void> _validateSvgAssets() async {
    try {
      await rootBundle.load(_selectedSvgPattern);
    } catch (e) {
      _logger.w('SVG资源文件不可用，将使用简单背景', extra: {'selectedPattern': _selectedSvgPattern, 'error': e.toString()});
      if (mounted) {
        setState(() {
          _svgAssetsAvailable = false;
        });
      }
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   构建消息列表   💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  Widget _buildMessagesList() {
    return Stack(
      children: [
        // 独立的背景图，不受消息状态变化影响
        _buildBackground(),
        // 消息列表内容
        BlocListener<ChatCubit, ChatState>(
          listenWhen: (previous, current) {
            // 💢💢💢 监听搜索结果索引变化，触发自动滚动
            final searchResultChanged = previous.currentSearchResultIndex != current.currentSearchResultIndex ||
                (previous.searchResultMessageIndexes.length != current.searchResultMessageIndexes.length && current.searchResultMessageIndexes.isNotEmpty);

            // 💢💢💢 监听滚动位置变化（初始化时自动滚动到最新消息）
            final scrollPositionChanged = previous.currentScrollPosition.messageId != current.currentScrollPosition.messageId &&
                previous.messages.isNotEmpty && // 首次加载不触发该分支，避免初始抖动
                current.currentScrollPosition.messageId != null &&
                !current.isSearchMode; // 非搜索模式下才响应滚动位置变化

            // 💢💢💢 新增：监听消息列表更新，以恢复滚动位置
            final messageListUpdated = previous.messages.isNotEmpty &&
                previous.messages.length != current.messages.length &&
                current.currentScrollPosition.messageId != null &&
                !current.isSearchMode &&
                !current.isCleaningMessages; // 清理消息时不触发

    // 🆕 监听新消息到达（用于自动滚动）
    // 排除首次加载（previous.messages 为空），仅在已有列表基础上新增时触发
    final newMessageArrived = !current.isSearchMode &&
        !current.isCleaningMessages &&
        previous.messages.isNotEmpty &&
        current.messages.length > previous.messages.length &&
        current.messages.isNotEmpty;

            final shouldListen = searchResultChanged || scrollPositionChanged || messageListUpdated || newMessageArrived;

            return shouldListen;
          },
          listener: (context, state) {
            // 💢💢💢 自动滚动到当前搜索结果
            if (state.isSearchMode && state.searchResultMessageIndexes.isNotEmpty && state.currentSearchResultIndex < state.searchResultMessageIndexes.length) {
              final currentResultMessageIndex = state.searchResultMessageIndexes[state.currentSearchResultIndex];

              _logger.d('💢 BlocListener 搜索模式滚动', extra: {
                'targetMessageIndex': currentResultMessageIndex,
                'currentIndex': state.currentSearchResultIndex,
              });

              // 延迟执行滚动，等待UI更新完成
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _logger.d('💢 BlocListener 执行搜索滚动回调');
                _scrollToMessage(currentResultMessageIndex);
              });
            }
            // 🆕 新消息自动滚动逻辑
            else if (!state.isSearchMode && !state.isCleaningMessages && state.messages.isNotEmpty) {
              // 仅当用户位于底部时才自动滚动，避免打断用户浏览历史消息
              final atBottom = _isUserAtBottom();
              if (atBottom) {
                // 等 UI 完成渲染后再滚动，确保新消息已经加入列表
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  // 稍作延迟以等待列表布局稳定
                  Timer(const Duration(milliseconds: 80), () {
                    if (mounted) {
                      // 在自动滚动期间抑制未读指示器显示，避免闪烁
                      _isAutoScrollingToBottom = true;
                      _autoScrollSuppressTimer?.cancel();
                      _autoScrollSuppressTimer = Timer(const Duration(milliseconds: 600), () {
                        _isAutoScrollingToBottom = false;
                      });
                      _scrollToBottom(animated: true);

                      // 处理图片消息异步加载导致的高度变化，追加一次无动画对齐
                      Timer(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          _scrollToBottom(animated: false);
                        }
                      });
                    }
                  });
                });
              }
            }
          },
          child: BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) {
              // 💢💢💢 合并后的BlocBuilder：统一处理所有相关状态变化

              // 1. 消息列表数量变化（真正影响UI结构的变化）
              if (previous.messages.length != current.messages.length) {
                _logger.i('🔥 消息数量变化', extra: {
                  'from': previous.messages.length,
                  'to': current.messages.length,
                });
                return true;
              }

              // 2. 消息列表内容变化（但数量相同时，检查是否有新消息替换）
              if (previous.messages.length == current.messages.length && previous.messages.isNotEmpty && current.messages.isNotEmpty) {
                // 检查第一条消息ID是否变化（有新消息加入并可能有旧消息被移除）
                final prevFirstId = previous.messages.first.messageId;
                final currFirstId = current.messages.first.messageId;
                if (prevFirstId != currFirstId) {
                  _logger.i('🔥 消息结构变化');
                  return true;
                }

                // 🔥🔥🔥 新增：检查消息内容变化（状态更新等）
                // 当消息数量相同时，检查是否有消息的状态或内容发生了变化
                for (int i = 0; i < previous.messages.length; i++) {
                  final prevMessage = previous.messages[i];
                  final currMessage = current.messages[i];

                  // 检查消息状态变化
                  if (prevMessage.messageStatus != currMessage.messageStatus) {
                    _logger.i('🔥 消息状态变化', extra: {
                      'messageId': prevMessage.messageId,
                      'from': prevMessage.messageStatus,
                      'to': currMessage.messageStatus,
                    });
                    return true;
                  }

                  // 检查消息内容变化
                  if (prevMessage.content != currMessage.content) {
                    _logger.i('🔥 消息内容变化', extra: {
                      'messageId': prevMessage.messageId,
                    });
                    return true;
                  }

                  // 检查消息更新时间变化
                  if (prevMessage.updatedAt != currMessage.updatedAt) {
                    _logger.i('🔥 消息更新时间变化', extra: {
                      'messageId': prevMessage.messageId,
                      'from': prevMessage.updatedAt,
                      'to': currMessage.updatedAt,
                    });
                    return true;
                  }
                }
              }

              // 3. 搜索状态变化（影响消息高亮和显示）
              if (previous.isSearchMode != current.isSearchMode ||
                  previous.searchQuery != current.searchQuery ||
                  previous.currentSearchResultIndex != current.currentSearchResultIndex ||
                  !identical(previous.searchResultMessageIndexes, current.searchResultMessageIndexes)) {
                _logger.i('🔥 搜索状态变化');
                return true;
              }

              // 4. 会话信息变化（影响消息显示状态和类型判断）
              if (previous.conversation.conversationId != current.conversation.conversationId || previous.conversation.type != current.conversation.type) {
                _logger.i('🔥 会话信息变化');
                return true;
              }

              // 5. 高亮消息变化（用户跳转到特定消息时）
              if (previous.highlightedMessageId != current.highlightedMessageId) {
                _logger.i('🔥 高亮消息变化');
                return true;
              }

              // 🔧 最后检查：如果只是滚动位置变化，不重建消息列表
              if (previous.currentScrollPosition != current.currentScrollPosition) {
                return false;
              }

              return false;
            },
            builder: (context, state) {
              _logger.i('🚀 BlocBuilder 重绘消息列表', extra: {
                'messageCount': state.messages.length,
              });

              // 💢💢💢 每次重建时重置首次位置检查标志
              _hasCheckedInitialPosition = false;

              // 处理消息列表，添加分隔符
              final currentUserId = state.currentUser.userId;
              final isNotGroupChat = state.conversation.type != 'GROUP';
              // 统一排序：先按index降序（最新在前）；若相同（哨兵），按createdAt降序；最后用messageId稳定
              final displayMessages = List<Message>.from(state.messages)
                ..sort((a, b) {
                  const int sentinel = 1 << 30;
                  final bool aSentinel = a.messageIndex == sentinel;
                  final bool bSentinel = b.messageIndex == sentinel;
                  if (aSentinel && !bSentinel) return -1; // 哨兵视为最大，最新在前
                  if (!aSentinel && bSentinel) return 1;
                  final int c = b.messageIndex.compareTo(a.messageIndex); // index降序
                  if (c != 0) return c;
                  final int t = b.createdAt.compareTo(a.createdAt); // 时间降序
                  if (t != 0) return t;
                  return b.messageId.compareTo(a.messageId);
                });

              final processedItems = MessageListProcessor.processMessages(
                messages: displayMessages,
                currentUserId: currentUserId,
                isNotGroupChat: isNotGroupChat,
              );

              return Column(
                children: [
                  // 消息列表 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢
                  Expanded(
                    child: ScrollablePositionedList.builder(
                      key: ValueKey('message_list_${state.messages.length}_${state.currentScrollPosition.messageId ?? "empty"}'),
                      itemCount: processedItems.length,
                      itemBuilder: (context, index) {
                        final item = processedItems[index];

                        // 根据类型渲染不同的组件
                        if (item is MessageListItemData) {
                          final message = item.message;

                          // 💢💢💢 检查消息是否为搜索结果和高亮状态
                          final chatCubit = context.read<ChatCubit>();
                          final isSearchResult = chatCubit.isSearchResult(message.messageIndex);
                          final isCurrentSearchResult = chatCubit.isCurrentSearchResult(message.messageIndex);
                          final isHighlighted = chatCubit.isMessageHighlighted(message.messageId);
                          final searchQuery = state.isSearchMode ? state.searchQuery : null;

                          // 💢💢💢 计算消息显示状态（仅当前用户消息需要显示状态）
                          MessageDisplayStatus? displayStatus;
                          if (item.isCurrentUser) {
                            displayStatus = _calculateMessageDisplayStatus(
                              message,
                              state.conversation,
                              state.currentUser,
                              item.isNotGroupChat,
                            );
                          }

                          return MessageItem(
                            key: ValueKey(message.messageId),
                            message: message,
                            isCurrentUser: item.isCurrentUser,
                            showAvatar: item.showAvatar,
                            showTail: item.showTail,
                            isNotGroupChat: item.isNotGroupChat,
                            onTap: () => _onMessageTap(message),
                            onResend: message.messageStatus == 'FAILED' && item.isCurrentUser ? () => _onResendMessage(message.messageId) : null, // 💢💢💢 新增：重发回调
                            // 💢💢💢 新增搜索相关参数
                            isSearchResult: isSearchResult,
                            isCurrentSearchResult: isCurrentSearchResult,
                            // 💢💢💢 新增高亮相关参数
                            isHighlighted: isHighlighted,
                            // 🔥 新增：长按菜单回调
                            onReply: () => _onReplyMessage(message),
                            onForward: () => _onForwardMessage(message),
                            onCopy: () => _onCopyMessage(message),
                            onRevoke: () => _onRevokeMessage(message),
                            onDelete: () => _onDeleteMessage(message),
                            searchQuery: searchQuery,
                            displayStatus: displayStatus, // 💢💢💢 新增：预计算的显示状态
                            getQuotedMessage: (messageId) => _getQuotedMessage(messageId), // 🔥 新增：获取被回复消息的回调
                          );
                        } else if (item is MessageListItemDateSeparator) {
                          return DateSeparator(
                            key: ValueKey('date_${item.date.millisecondsSinceEpoch}'),
                            date: item.date,
                          );
                        } else {
                          // 未知类型，返回空容器
                          return const SizedBox.shrink();
                        }
                      },
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      // 💢💢💢 动态计算初始滚动索引，确保不返回-1
                      initialScrollIndex: (() {
                        final anchorId = state.currentScrollPosition.messageId;
                        if (anchorId != null) {
                          // 在 processedItems 中查找锚点消息对应的索引
                          final anchorIndex = processedItems.indexWhere((item) {
                            if (item is MessageListItemData) {
                              return item.message.messageId == anchorId;
                            }
                            return false;
                          });

                          if (anchorIndex >= 0) {
                            return anchorIndex;
                          }
                        }
                        // 默认返回0（reverse: true 时代表最新消息），避免-1导致RangeError
                        return 0;
                      })(),

                      // 💢💢💢 计算初始对齐：有锚点使用精确位置；否则让消息贴底（避免"先居中再滚到底部"的闪动）
                      initialAlignment: (() {
                        final anchorId = state.currentScrollPosition.messageId;
                        if (anchorId == null) {
                          // 首次进入或无锚点：直接贴底
                          return 0.0;
                        }
                        // 有锚点：按照保存的位置恢复
                        final itemLeadingEdge = state.currentScrollPosition.relativePosition ?? 0.0;
                        return itemLeadingEdge;
                      })(),
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // 自定义复制提示组件 - 从消息列表底部弹出
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<String>(
            valueListenable: _copyMessageNotifier,
            builder: (context, message, child) {
              if (message.isEmpty) {
                return const SizedBox.shrink();
              }

              return AnimatedSlide(
                offset: message.isNotEmpty ? const Offset(0, 0) : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: message.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建背景
  Widget _buildBackground() {
    return Stack(
      children: [
        // 绿色渐变背景
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade300,
                Colors.green.shade100,
              ],
            ),
          ),
        ),
        // SVG图案背景
        Positioned.fill(
          child: _buildSvgBackground(),
        ),
      ],
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        // 优化：避免仅因isSending状态变化而重建输入区域（修复焦点丢失问题）
        // 只在网络状态或会话变化时重建，isSending变化不影响输入区域UI
        return previous.networkStatus != current.networkStatus ||
            previous.conversation.conversationId != current.conversation.conversationId ||
            previous.conversation.type != current.conversation.type ||
            previous.conversation.participants != current.conversation.participants ||
            previous.currentUser.roleId != current.currentUser.roleId || // 角色ID变化时重建，影响快捷回复显示
            previous.replyingToMessage != current.replyingToMessage; // 回复消息状态变化时重建
      },
      builder: (context, state) {
        final isEnabled = state.networkStatus == ChatState.kNetworkStatusConnected && !state.isSending;
        final conversation = state.conversation;
        final currentUserId = state.currentUser.userId;

        // 🔥🔥🔥 详细记录用户roleId和快捷回复权限状态
        // final currentRoleId = state.currentUser.roleId;

        // _logger.i('💬💬💬 ChatPage输入区域构建', extra: {
        //   'currentUserId': currentUserId,
        //   'currentUserRoleId': currentRoleId,
        //   'conversationType': conversation.type,
        //   'isEnabled': isEnabled,
        //   'hasQuickReplyPermission': hasQuickReplyPermission,
        // });

        // // 记录输入区域权限状态
        // _logger.d('🔥🔥🔥 INPUT_AREA_BUILD: userId=$currentUserId, roleId=$currentRoleId, hasPermission=$hasQuickReplyPermission');

        // 检查是否为频道
        if (conversation.type == 'CHANNEL') {
          // 如果用户未加入频道，显示加入按钮
          if (!ConversationAdapter.isUserInConversation(conversation.participants, currentUserId)) {
            return _buildJoinChannelButton(state, isEnabled);
          }

          // 如果用户是普通成员，显示静音/取消静音按钮
          final userRole = ConversationAdapter.getUserRole(conversation.participants, currentUserId);
          if (userRole != null && userRole == 0) {
            // 0 = MEMBER role
            return _buildChannelMemberControls(state, isEnabled);
          }
        }

        // 对于非频道或频道管理员/所有者，显示正常输入区域
        return Column(
          children: [
            // 正在输入提示已移动到 AppBar 副标题，不在底部显示
            // 快捷回复面板 - 仅对有权限的用户显示
            ...() {
              final hasPermission = _hasQuickReplyPermission(state.currentUser.roleId);
              // _logger.i('🔥🔥🔥 快捷回复面板条件判断', extra: {
              //   'currentUserRoleId': state.currentUser.roleId,
              //   'hasPermission': hasPermission,
              //   'willShowPanel': hasPermission,
              //   'panelVisible': _showQuickReplyPanel,
              //   'currentUserId': state.currentUser.userId,
              // });

              if (hasPermission) {
                return [
                  QuickReplyPanel(
                    isVisible: _showQuickReplyPanel,
                    onRequestClose: () {
                      setState(() {
                        _showQuickReplyPanel = false;
                      });
                    },
                    onQuickReply: (content) {
                      _logger.i('🔥🔥🔥 快捷回复被选择', extra: {'content': content});
                      // 将快捷回复内容填入输入框，不直接发送
                      _textController.text = content;
                      _textNotifier.value = content;
                      setState(() {
                        _showQuickReplyPanel = false;
                      });
                      // 自动获取焦点，方便用户编辑或直接发送
                      _focusNode.requestFocus();
                      // 将光标移动到文本末尾
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _textController.text.length),
                      );
                    },
                  )
                ];
              } else {
                _logger.w('🔥🔥🔥 快捷回复面板被隐藏 - 用户没有权限');
                return <Widget>[];
              }
            }(),
            // 回复消息显示
            if (state.replyingToMessage != null) _buildReplyingToMessage(state.replyingToMessage!),
            // 主输入栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withAlpha(51),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // 语音/键盘切换按钮
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVoiceMode = !_isVoiceMode;
                          if (_isVoiceMode) {
                            _focusNode.unfocus();
                            _showMoreOptions = false;
                            _showQuickReplyPanel = false;
                          } else {
                            _focusNode.requestFocus();
                          }
                        });
                      },
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          _isVoiceMode ? Icons.keyboard : Icons.mic,
                          size: 32,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 输入框或语音按钮
                    Expanded(
                      child: _isVoiceMode ? _buildVoiceButton(isEnabled) : _buildTextInput(isEnabled),
                    ),

                    const SizedBox(width: 8),

                    // 表情按钮
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showEmojiPanel = !_showEmojiPanel;
                          if (_showEmojiPanel) {
                            _showMoreOptions = false;
                            _showQuickReplyPanel = false;
                            _focusNode.unfocus();
                          }
                        });
                      },
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        // decoration: BoxDecoration(
                        //   color: Colors.grey.shade100,
                        //   borderRadius: BorderRadius.circular(18),
                        // ),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          size: 32,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 快捷回复按钮 - 仅对有权限的用户显示
                    ...() {
                      final hasPermission = _hasQuickReplyPermission(state.currentUser.roleId);
                      // _logger.i('🚨🚨🚨 快捷回复按钮条件判断', extra: {
                      //   'currentUserRoleId': state.currentUser.roleId,
                      //   'hasPermission': hasPermission,
                      //   'willShowButton': hasPermission,
                      //   'currentUserId': state.currentUser.userId,
                      //   'currentUserName': state.currentUser.name,
                      // });

                      if (hasPermission) {
                        return [
                          GestureDetector(
                            onTap: () {
                              _logger.i('🚨🚨🚨 快捷回复按钮被点击');
                              setState(() {
                                _showQuickReplyPanel = !_showQuickReplyPanel;
                                if (_showQuickReplyPanel) {
                                  _showMoreOptions = false;
                                  _showEmojiPanel = false;
                                  _focusNode.unfocus();
                                }
                              });
                            },
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.flash_on,
                                size: 32,
                                color: _showQuickReplyPanel ? Theme.of(context).primaryColor : Colors.grey.shade600,
                              ),
                            ),
                          )
                        ];
                      } else {
                        // _logger.w('🚨🚨🚨 快捷回复按钮被隐藏 - 用户没有权限');
                        return <Widget>[];
                      }
                    }(),

                    const SizedBox(width: 8),

                    // 发送按钮或添加按钮
                    ValueListenableBuilder<String>(
                      valueListenable: _textNotifier,
                      builder: (context, text, child) {
                        return text.isNotEmpty && !_isVoiceMode ? _buildSendButton(state, isEnabled) : _buildAddButton();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 功能面板或表情面板
            if (_showMoreOptions) _buildMoreOptionsPanel() else if (_showEmojiPanel) _buildEmojiPanel(),
          ],
        );
      },
    );
  }

  /// 构建频道加入按钮
  Widget _buildJoinChannelButton(ChatState state, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withAlpha(51),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isEnabled ? () => _joinChannel(state) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).joinChannel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建频道普通成员控制区域
  Widget _buildChannelMemberControls(ChatState state, bool isEnabled) {
    final conversation = state.conversation;
    final isMuted = conversation.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withAlpha(51),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context).channelMemberCannotSend,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 静音/取消静音按钮
            GestureDetector(
              onTap: isEnabled ? () => _toggleMute(state) : null,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMuted ? Colors.red.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: isMuted ? Colors.red : Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 加入频道
  void _joinChannel(ChatState state) {
    // TODO: 实现加入频道逻辑
    // 这里需要调用 ChatCubit 的加入频道方法
    // final chatCubit = context.read<ChatCubit>();
    // chatCubit.joinChannel();
    _logger.i('用户尝试加入频道: ${state.conversation.conversationId}');
  }

  /// 切换静音状态
  void _toggleMute(ChatState state) {
    final chatCubit = context.read<ChatCubit>();
    final isMuted = state.conversation.muted;

    _logger.i('用户尝试${isMuted ? '取消静音' : '静音'}会话: ${state.conversation.conversationId}');

    // 调用 ChatCubit 的切换静音方法
    chatCubit.toggleMute();
  }

  /// 构建文本输入框
  Widget _buildTextInput(bool isEnabled) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            final isCtrlPressed = event.logicalKey == LogicalKeyboardKey.controlLeft || event.logicalKey == LogicalKeyboardKey.controlRight;

            // 检测 Ctrl+V 组合键
            if ((isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyV) ||
                (event.physicalKey == PhysicalKeyboardKey.controlLeft && event.logicalKey == LogicalKeyboardKey.keyV) ||
                (HardwareKeyboard.instance.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyV)) {
              _handlePasteAction();
            }
          }
        },
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: isEnabled,
          maxLines: 5,
          minLines: 1,
          decoration: InputDecoration(
            hintText: isEnabled ? AppLocalizations.of(context).inputMessage : AppLocalizations.of(context).connecting,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87,
            height: 1.4, // 调整行高以适应更大的表情
          ),
          textInputAction: TextInputAction.send,
          onSubmitted: isEnabled
              ? (text) {
                  _sendMessage();
                  // 🔧 修复：onSubmitted后主动恢复焦点
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _focusNode.canRequestFocus) {
                      _focusNode.requestFocus();
                    }
                  });
                }
              : null,
          onChanged: (text) {
            // 更新本地输入文本
            _textNotifier.value = text;
            // 通知 Cubit 打字状态（节流/保活 由 Cubit 处理）
            context.read<ChatCubit>().onInputTextChanged(text);
            // 若快捷回复面板展开，用户开始输入则自动隐藏
            if (_showQuickReplyPanel) {
              setState(() {
                _showQuickReplyPanel = false;
              });
            }
          },
          onTap: () {
            // 🔧 优化：只在真正需要时才调用setState，避免不必要的重建
            if (_showMoreOptions || _showEmojiPanel) {
              setState(() {
                _showMoreOptions = false;
                _showEmojiPanel = false;
                // 同步隐藏快捷回复面板
                _showQuickReplyPanel = false;
              });
            }
          },
        ),
      ),
    );
  }

  /// 构建语音按钮
  Widget _buildVoiceButton(bool isEnabled) {
    return GestureDetector(
      onLongPressStart: (_) async {
        if (isEnabled) {
          await _handleRecordingStart();
        }
      },
      onLongPressMoveUpdate: (details) {
        // 保持录制状态，可以在这里添加其他手势逻辑
      },
      onLongPressEnd: (_) async {
        if (_isRecording) {
          await _stopRecording();
        }
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.green.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isRecording ? Colors.green.shade300 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            _isRecording ? AppLocalizations.of(context).releaseToFinish : AppLocalizations.of(context).holdToSpeakButtonText,
            style: TextStyle(
              fontSize: 16,
              color: _isRecording ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  /// 处理录音开始 - 先检查权限
  Future<void> _handleRecordingStart() async {
    try {
      _logger.i('用户尝试开始录音，先检查权限');

      // 首先检查当前权限状态
      final currentStatus = await _permissionService.checkMicrophonePermission();

      // 如果已有权限，直接开始录音
      if (currentStatus.isGranted) {
        _logger.i('麦克风权限已存在，直接开始录音');
        await _startRecording();
        return;
      }

      // 如果没有权限，尝试申请权限
      _logger.i('需要申请麦克风权限');
      final hasPermission = await _permissionService.ensureMicrophonePermission();

      if (!hasPermission) {
        _logger.w('麦克风权限未授予，无法开始录音');
        if (mounted) {
          final localizations = AppLocalizations.of(context);

          // 检查是否被永久拒绝
          final status = await _permissionService.checkMicrophonePermission();
          if (status.isPermanentlyDenied) {
            // 权限被永久拒绝，提示用户到设置中开启
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(localizations.permissionRequired),
                  content: Text(localizations.microphonePermissionMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localizations.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _permissionService.openDeviceAppSettings();
                      },
                      child: Text(localizations.goToSettings),
                    ),
                  ],
                ),
              );
            }
          } else {
            // 权限被拒绝，显示简单提示
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.recordingFailedPermission),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
        return;
      }

      // 权限已获得，提示用户重新长按录音
      _logger.i('麦克风权限已获得，提示用户重新长按开始录音');
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.permissionGrantedRetry),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('处理录音开始异常', error: e, stackTrace: stackTrace);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.recordingFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 开始录制（语音）
  Future<void> _startRecording() async {
    try {
      _logger.i('用户开始录音');

      final success = await _voiceRecordService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        // 启动录制计时器，最大60秒
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordingSeconds++;
            });

            // 🔧 录音时长限制：最大60秒
            if (_recordingSeconds >= VoiceRecordService.maxRecordingDuration) {
              _logger.i('录音达到最大时长${VoiceRecordService.maxRecordingDuration}秒，自动停止');
              timer.cancel();
              _stopRecording();

              // 显示提示
              final localizations = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${localizations.recordingAutoSend}(${VoiceRecordService.maxRecordingDuration}秒)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        });

        HapticFeedback.lightImpact();
        _logger.i('录音开始成功');
      } else {
        _logger.w('录音开始失败');
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.recordingFailedPermission),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('录音开始异常', error: e);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.recordingFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 开始视频录制
  Future<void> _startVideoRecording() async {
    try {
      _logger.i('用户开始录制视频');

      setState(() {
        _isVideoRecording = true;
        _recordingSeconds = 0;
      });

      // 启动录制计时器，最大60秒
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingSeconds++;
          });

          // 录制时长限制：最大60秒
          if (_recordingSeconds >= 60) {
            _logger.i('视频录制达到最大时长60秒，自动停止');
            timer.cancel();
            _stopVideoRecording();

            // 显示提示
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${localizations.recordingAutoSend}(60秒)'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      });

      HapticFeedback.lightImpact();
      _logger.i('视频录制开始成功');
    } catch (e) {
      _logger.e('视频录制开始异常', error: e);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.recordingFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 停止视频录制
  Future<void> _stopVideoRecording() async {
    try {
      _logger.i('用户停止录制视频');

      // 停止计时器
      _recordingTimer?.cancel();
      _recordingTimer = null;

      setState(() {
        _isVideoRecording = false;
      });

      // 使用MediaService录制视频
      final videoFile = await _mediaService.pickVideo(fromCamera: true);

      if (videoFile != null) {
        _logger.i('视频录制成功', extra: {
          'filePath': videoFile.path,
          'fileSize': await videoFile.length(),
          'duration': _recordingSeconds,
        });

        await _showVideoPreviewAndSend(videoFile);
      } else {
        _logger.i('用户取消了视频录制');
      }

      HapticFeedback.lightImpact();
      _logger.i('视频录制停止成功');
    } catch (e) {
      _logger.e('视频录制停止异常', error: e);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.recordingFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // 确保状态被重置
      if (mounted) {
        setState(() {
          _isVideoRecording = false;
          _recordingSeconds = 0;
        });
      }
    }
  }

  /// 显示视频预览并发送
  Future<void> _showVideoPreviewAndSend(File videoFile) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _VideoPreviewDialog(videoFile: videoFile),
    );

    if (result != null && result['confirmed'] == true) {
      final caption = result['caption'] as String?;
      await _uploadAndSendVideo(videoFile, caption: caption);
    }
  }

  /// 上传并发送视频消息
  Future<void> _uploadAndSendVideo(File videoFile, {String? caption}) async {
    try {
      _logger.i('开始上传视频', extra: {
        'filePath': videoFile.path,
        'caption': caption,
      });

      // 显示上传进度
      _showUploadProgress('发送视频中...');

      // 使用MediaUploadIntegrationService发送视频消息
      await _mediaUploadIntegrationService.sendVideoMessage(
        videoFile: videoFile,
        conversationId: widget.conversationId,
        caption: caption,
        onUploadProgress: (progress) {
          _updateUploadProgress('上传视频中 $progress%');
        },
        onStatusUpdate: (status) {
          _updateUploadProgress(status);
        },
      );

      _logger.i('视频消息发送成功');

      // 清除进度提示
      _hideUploadProgress();

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('视频消息发送失败', error: error, stackTrace: StackTrace.current);

      _hideUploadProgress();

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('视频发送失败: $error'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () => _uploadAndSendVideo(videoFile, caption: caption),
            ),
          ),
        );
      }
    }
  }



  /// 从相册选择图片
  /// 
  /// 完全依赖 ImagePicker 的内置权限处理机制：
  /// - iOS/Android: ImagePicker 会自动请求和处理权限
  /// - macOS: 系统会在首次访问时弹出权限对话框
  /// - Web: 浏览器会处理文件访问权限
  Future<void> _pickImageFromGallery() async {
    try {
      _logger.i('开始从相册选择图片');

      final pickedFile = await _mediaService.pickImage(fromCamera: false);
      if (pickedFile != null) {
        _logger.i('图片选择成功', extra: {
          'filePath': pickedFile.path,
          'fileSize': await pickedFile.length(),
        });

        await _showImagePreviewAndSend(pickedFile);
      } else {
        _logger.i('用户取消了图片选择');
      }
    } catch (error) {
      _logger.e('选择图片失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.imageSendFailed}: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 拍照功能
  /// 
  /// 完全依赖 MediaService 和 ImagePicker 的内置处理：
  /// - 移动平台: 调用相机拍照
  /// - 桌面平台: MediaService 会自动切换到相册选择
  /// - Web平台: 根据浏览器支持情况处理
  Future<void> _takePicture() async {
    try {
      _logger.i('开始拍照');

      final pickedFile = await _mediaService.pickImage(fromCamera: true);
      if (pickedFile != null) {
        _logger.i('图片选择成功', extra: {
          'filePath': pickedFile.path,
          'fileSize': await pickedFile.length(),
        });

        await _showImagePreviewAndSend(pickedFile);
      } else {
        _logger.i('用户取消了图片选择');
      }
    } catch (error) {
      _logger.e('图片选择失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.imageSelectionFailed}: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示图片预览并发送
  Future<void> _showImagePreviewAndSend(dynamic imageFile) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ImagePreviewDialog(imageFile: imageFile),
    );

    if (result != null && result['confirmed'] == true) {
      final caption = result['caption'] as String?;
      await _uploadAndSendImage(imageFile, caption: caption);
    }
  }

  /// 上传并发送图片消息
  Future<void> _uploadAndSendImage(dynamic imageFile, {String? caption}) async {
    try {
      _logger.i('开始上传图片', extra: {
        'filePath': imageFile.path,
        'caption': caption,
      });

      // 显示上传进度
      final localizations = AppLocalizations.of(context);
      _showUploadProgress(localizations.sendingImage);

      // 使用MediaUploadIntegrationService发送图片消息
      // 直接传递动态类型，让服务层处理平台差异
      await _mediaUploadIntegrationService.sendImageMessage(
        imageFile: imageFile,
        conversationId: widget.conversationId,
        caption: caption,
        onUploadProgress: (progress) {
          _updateUploadProgress('${localizations.uploadingImage} $progress%');
        },
        onStatusUpdate: (status) {
          _updateUploadProgress(status);
        },
      );

      _logger.i('图片消息发送成功');

      // 清除进度提示
      _hideUploadProgress();

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('图片消息发送失败', error: error, stackTrace: StackTrace.current);

      _hideUploadProgress();

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.imageSendFailed}: $error'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () => _uploadAndSendImage(imageFile, caption: caption),
            ),
          ),
        );
      }
    }
  }

  /// 显示上传进度
  void _showUploadProgress(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(minutes: 5), // 长时间显示
        ),
      );
    }
  }

  /// 更新上传进度
  void _updateUploadProgress(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      _showUploadProgress(message);
    }
  }

  /// 隐藏上传进度
  void _hideUploadProgress() {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  /// 停止录音并发送
  Future<void> _stopRecording() async {
    try {
      _logger.i('用户停止录音');

      setState(() {
        _isRecording = false;
      });

      // 停止录制计时器
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final result = await _voiceRecordService.stopRecording();
      if (result != null) {
        _logger.i('录音结束', extra: {
          'duration': result.duration,
          'fileSize': result.fileSize,
          'filePath': result.filePath,
        });

        // 检查录音时长
        if (result.duration < 1) {
          _logger.w('录音时间太短，删除录音文件');
          // 删除录音文件
          final file = File(result.filePath);
          if (await file.exists()) {
            await file.delete();
          }

          if (mounted) {
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.recordingTooShort),
                duration: const Duration(seconds: 1),
              ),
            );
          }
          return;
        }

        // 上传并发送语音消息
        await _uploadAndSendVoice(result);
      } else {
        _logger.w('录音结果为空');
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.recordingFailed),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('录音停止异常', error: e);
      setState(() {
        _isRecording = false;
      });

      // 停止录制计时器
      _recordingTimer?.cancel();
      _recordingTimer = null;

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.recordingFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 上传并发送语音消息
  Future<void> _uploadAndSendVoice(VoiceRecordResult recordResult) async {
    try {
      _logger.i('开始上传语音文件', extra: {
        'filePath': recordResult.filePath,
        'duration': recordResult.duration,
        'fileSize': recordResult.fileSize,
      });

      // 在异步操作前获取ChatCubit引用
      context.read<ChatCubit>();

      // 显示上传中提示
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(localizations.sendingVoice),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 使用MediaUploadIntegrationService发送语音消息（统一流程）
      await _mediaUploadIntegrationService.sendVoiceMessage(
        voiceFile: File(recordResult.filePath),
        conversationId: widget.conversationId,
        duration: recordResult.duration * 1000, // 转换为毫秒
        onUploadProgress: (progress) {
          // 可以在这里更新进度
        },
        onStatusUpdate: (status) {
          // 可以在这里更新状态
        },
      );

      _logger.i('语音消息发送成功');

      // 清除上传提示
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (e) {
      _logger.e('语音消息发送失败', error: e);

      // 删除录音文件
      try {
        final file = File(recordResult.filePath);
        if (await file.exists()) {
          await file.delete();
          _logger.i('已删除失败的录音文件');
        }
      } catch (deleteError) {
        _logger.w('删除录音文件失败', extra: {
          'error': deleteError,
        });
      }

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.voiceSendFailed}: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () => _uploadAndSendVoice(recordResult),
            ),
          ),
        );
      }
    }
  }

  /// 选择并发送文件
  ///
  /// 处理文件选择流程，包括：
  /// 1. 调用媒体服务选择文件
  /// 2. 显示文件预览并确认发送
  /// 3. 处理各种错误情况（用户取消、系统错误、权限问题）
  Future<void> _pickAndSendFile() async {
    try {
      _logger.i('开始选择文件');

      final pickedFile = await _mediaService.pickFile();
      if (pickedFile != null) {
        // 获取文件MIME类型用于调试
        final mimeType = lookupMimeType(pickedFile.path);
        _logger.i('文件选择成功', extra: {
          'filePath': pickedFile.path,
          'fileSize': await pickedFile.length(),
          'mimeType': mimeType,
          'fileName': pickedFile.path.split('/').last,
        });

        await _showFilePreviewAndSend(pickedFile);
      } else {
        // 不记录为用户取消，因为可能是系统错误导致的
        _logger.d('文件选择流程结束，未选择文件');
      }
    } catch (error) {
      _logger.e('文件选择失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        String errorMessage;

        // 针对macOS系统错误提供友好的错误提示
        if (error.toString().contains('NSXPCSharedListener') || error.toString().contains('Connection interrupted')) {
          errorMessage = '系统文件选择器暂时不可用，请稍后重试';
        } else if (error.toString().contains('permission') || error.toString().contains('权限')) {
          errorMessage = '文件访问权限被拒绝，请在系统设置中授予权限';
        } else {
          errorMessage = '${localizations.fileSelectionFailed}: ${error.toString().split('\n').first}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '重试',
              onPressed: () => _pickAndSendFile(),
            ),
          ),
        );
      }
    }
  }

  /// 显示文件预览并发送
  Future<void> _showFilePreviewAndSend(File file) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FilePreviewDialog(file: file),
    );

    if (result != null && result['confirmed'] == true) {
      final caption = result['caption'] as String?;
      await _uploadAndSendFile(file, caption: caption);
    }
  }

  /// 上传并发送文件消息
  Future<void> _uploadAndSendFile(File file, {String? caption}) async {
    try {
      _logger.i('开始上传文件', extra: {
        'filePath': file.path,
        'caption': caption,
      });

      // 显示上传进度
      final localizations = AppLocalizations.of(context);
      _showUploadProgress(localizations.sendingFile);

      // 使用MediaUploadIntegrationService发送文件消息
      await _mediaUploadIntegrationService.sendDocumentMessage(
        documentFile: file,
        conversationId: widget.conversationId,
        caption: caption,
        onUploadProgress: (progress) {
          _updateUploadProgress('${localizations.uploadingFile} $progress%');
        },
        onStatusUpdate: (status) {
          _updateUploadProgress(status);
        },
      );

      _logger.i('文件消息发送成功');

      // 清除进度提示
      _hideUploadProgress();

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('文件消息发送失败', error: error, stackTrace: StackTrace.current);

      _hideUploadProgress();

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.fileSendFailed}: $error'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () => _uploadAndSendFile(file, caption: caption),
            ),
          ),
        );
      }
    }
  }

  /// 构建发送按钮
  Widget _buildSendButton(ChatState state, bool isEnabled) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isEnabled ? _sendMessage : null,
          child: state.isSending
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : const Icon(
                  Icons.send,
                  color: Colors.grey,
                  size: 32,
                ),
        ),
      ),
    );
  }

  /// 构建添加按钮
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMoreOptions = !_showMoreOptions;
          if (_showMoreOptions) {
            _focusNode.unfocus();
            _showEmojiPanel = false;
            _showQuickReplyPanel = false;
          }
        });
      },
      child: Icon(
        _showMoreOptions ? Icons.close : Icons.add,
        size: 40,
        color: Colors.grey.shade600,
      ),
    );
  }

  /// 构建功能面板
  Widget _buildMoreOptionsPanel() {
    final localizations = AppLocalizations.of(context);
    final options = [
      {'icon': Icons.photo_library, 'label': localizations.picture},
      {'icon': Icons.camera_alt, 'label': localizations.shoot},
      {'icon': Icons.insert_drive_file, 'label': localizations.fileOption},
      {'icon': Icons.person, 'label': localizations.contactOption},
    ];

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7), // 使用ChatInfoPage相同的背景色
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: options.map((option) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: (option['icon'] as IconData) == Icons.camera_alt
                    ? _buildCameraButton(option)
                    : InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          _handleMoreOptionTap(option['label'] as String);
                        },
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                option['icon'] as IconData,
                                color: AppColors.primary,
                                size: 26,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                option['label'] as String,
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
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建相机按钮（支持短按拍照、长按录制视频）
  Widget _buildCameraButton(Map<String, dynamic> option) {
    return GestureDetector(
      // 短按拍照
      onTap: () async {
        setState(() {
          _showMoreOptions = false;
        });
        await _takePicture();
      },
      // 长按录制视频
      onLongPressStart: (details) async {
        setState(() {
          _showMoreOptions = false;
          _isVideoRecording = true;
        });
        HapticFeedback.mediumImpact();
        await _startVideoRecording();
      },
      onLongPressEnd: (details) async {
        if (_isVideoRecording) {
          setState(() {
            _isVideoRecording = false;
          });
          await _stopVideoRecording();
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _isVideoRecording ? Colors.red.withAlpha(25) : Colors.transparent,
          border: _isVideoRecording ? Border.all(color: Colors.red, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  option['icon'] as IconData,
                  color: _isVideoRecording ? Colors.red : AppColors.primary,
                  size: 26,
                ),
                if (_isVideoRecording)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _isVideoRecording ? '录制中...' : option['label'] as String,
              style: TextStyle(
                fontSize: 12,
                color: _isVideoRecording ? Colors.red : AppColors.primary,
                fontWeight: _isVideoRecording ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建表情面板
  Widget _buildEmojiPanel() {
    // 基础表情列表
    final emojis = [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '😂',
      '🤣',
      '🥲',
      '☺️',
      '😊',
      '😇',
      '🙂',
      '🙃',
      '😉',
      '😌',
      '😍',
      '🥰',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😛',
      '😝',
      '😜',
      '🤪',
      '🤨',
      '🧐',
      '🤓',
      '😎',
      '🥸',
      '🤩',
      '🥳',
      '😏',
      '😒',
      '😞',
      '😔',
      '😟',
      '😕',
      '🙁',
      '☹️',
      '😣',
      '😖',
      '😫',
      '😩',
      '🥺',
      '😢',
      '😭',
      '😤',
      '😠',
      '😡',
      '🤬',
      '🤯',
      '😳',
      '🥵',
      '🥶',
      '😶',
      '😐',
      '😑',
      '😬',
      '🙄',
      '😯',
      '😦',
      '😧',
      '😮',
      '😲',
      '🥱',
      '😴',
      '🤤',
      '😪',
      '😵',
      '🤐',
      '🥴',
      '🤢',
      '🤮',
      '🤧',
      '😷',
      '🤒',
      '🤕',
    ];

    return Container(
      height: 240,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // 表情标题和关闭按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).allEmojis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showEmojiPanel = false;
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 表情网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                return GestureDetector(
                  onTap: () {
                    _insertEmoji(emoji);
                  },
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建录制覆盖层
  Widget _buildRecordingOverlay() {
    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 音频示波器动画
              _buildAudioWaveAnimation(),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).recording,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatRecordingTime(_recordingSeconds),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        ' / ${_formatRecordingTime(VoiceRecordService.maxRecordingDuration)}',
                        style: TextStyle(
                          color: Colors.green.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 动画控制器
  late AnimationController _waveAnimationController;

  /// 语音录制服务
  final VoiceRecordService _voiceRecordService = VoiceRecordService();

  /// 权限服务
  final PermissionService _permissionService = PermissionService();


  /// 媒体服务
  final MediaService _mediaService = MediaService();

  /// 媒体上传集成服务
  final MediaUploadIntegrationService _mediaUploadIntegrationService = MediaUploadIntegrationService();

  /// 音频示波器动画效果
  Widget _buildAudioWaveAnimation() {
    return Container(
      width: 90,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.green.shade100.withAlpha(100),
        border: Border.all(
          color: Colors.green.shade200,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: _waveAnimationController,
          builder: (context, child) {
            return CustomPaint(
              painter: AudioWavePainter(progress: _waveAnimationController.value),
            );
          },
        ),
      ),
    );
  }

  /// 插入表情到输入框
  void _insertEmoji(String emoji) {
    final currentText = _textController.text;
    final currentPosition = _textController.selection.baseOffset;

    if (currentPosition == -1) {
      // 如果没有光标位置，就添加到末尾
      _textController.text = currentText + emoji;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    } else {
      // 在光标位置插入表情
      final newText = currentText.substring(0, currentPosition) + emoji + currentText.substring(currentPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentPosition + emoji.length),
      );
    }

    // 更新UI状态
    setState(() {});
  }

  /// 处理功能选项点击
  void _handleMoreOptionTap(String label) {
    setState(() {
      _showMoreOptions = false;
    });

    final localizations = AppLocalizations.of(context);

    if (label == localizations.picture) {
      _pickImageFromGallery();
    } else if (label == localizations.shoot) {
      _showMediaCaptureOptions();
    } else if (label == localizations.fileOption) {
      _pickAndSendFile();
    } else if (label == localizations.contactOption) {
      // TODO: 分享联系人
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.contactFeatureComingSoon)),
      );
    }
  }

  /// 显示媒体拍摄选项
  void _showMediaCaptureOptions() {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(localizations.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: Text(localizations.recordVideo),
              onTap: () {
                Navigator.pop(context);
                _showVideoRecordingDialog();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 显示视频录制对话框
  void _showVideoRecordingDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.recordVideo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.longPressToRecord),
            const SizedBox(height: 20),
            GestureDetector(
              onLongPressStart: (_) => _startVideoRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isRecording ? localizations.recordingInProgress : localizations.longPressRecord,
              style: TextStyle(
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // TODO: 实现撤回功能
                // context.read<ChatCubit>().revokeMessage(message.messageId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.revokeFeatureComingSoon)),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.messageRevoked)),
                  );
                }
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${localizations.revokeFailed}: $error")),
                  );
                }
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }

  /// 消息点击事件
  void _onMessageTap(Message message) {
    // TODO 实现消息点击逻辑，如显示消息详情、复制等
  }

  /// 回复消息
  void _onReplyMessage(Message message) {
    _logger.d('回复消息', extra: {'messageId': message.messageId});

    // 设置回复的消息
    context.read<ChatCubit>().setReplyingToMessage(message);

    // 聚焦到输入框
    _focusNode.requestFocus();
  }

  /// 转发消息
  void _onForwardMessage(Message message) {
    _logger.d('转发消息', extra: {'messageId': message.messageId});
    // TODO: 实现转发功能
  }

  /// 复制消息文本到剪贴板
  ///
  /// 根据消息类型提取相应的文本内容：
  /// - 文本消息：提取 text_message.text
  /// - 媒体消息：提取 media_message.caption（如果有）
  /// - 系统消息：提取 system_message.text
  ///
  /// [message] - 要复制的消息对象
  void _onCopyMessage(Message message) {
    String? messageText;

    _logger.d('开始复制消息', extra: {
      'messageId': message.messageId,
      'messageType': message.messageType,
      'hasContent': message.content != null,
      'contentLength': message.content?.length ?? 0,
    });

    try {
      // 使用MessageAdapter提取文本内容（推荐方式）
      messageText = MessageAdapter.extractTextFromContent(message.content);

      _logger.d('MessageAdapter提取结果', extra: {
        'messageId': message.messageId,
        'extractedText': messageText,
        'textLength': messageText?.length ?? 0,
      });

      // 如果MessageAdapter没有提取到内容，尝试手动解析
      if (messageText == null || messageText.isEmpty) {
        if (message.content != null && message.content!.isNotEmpty) {
          try {
            final contentMap = jsonDecode(message.content!) as Map<String, dynamic>;

            // 根据消息类型提取文本
            switch (message.messageType) {
              case 'TEXT':
                // 文本消息：提取 text_message.text
                if (contentMap.containsKey('text_message')) {
                  final textData = contentMap['text_message'] as Map<String, dynamic>;
                  messageText = textData['text'] as String?;
                }
                break;

              case 'IMAGE':
              case 'VOICE':
              case 'VIDEO':
              case 'FILE':
                // 媒体消息：提取 media_message.caption
                if (contentMap.containsKey('media_message')) {
                  final mediaData = contentMap['media_message'] as Map<String, dynamic>;
                  messageText = mediaData['caption'] as String?;
                }
                break;

              case 'SYSTEM':
                // 系统消息：提取 system_message.text
                if (contentMap.containsKey('system_message')) {
                  final systemData = contentMap['system_message'] as Map<String, dynamic>;
                  messageText = systemData['text'] as String?;
                }
                break;

              default:
                // 其他类型，尝试通用字段
                messageText = contentMap['text'] as String? ?? contentMap['caption'] as String? ?? contentMap['message'] as String?;
            }

            _logger.d('手动解析结果', extra: {
              'messageId': message.messageId,
              'messageType': message.messageType,
              'extractedText': messageText,
              'contentStructure': contentMap.keys.toList(),
            });
          } catch (e) {
            _logger.w('JSON解析失败，尝试直接使用content', extra: {
              'messageId': message.messageId,
              'content': message.content,
              'error': e.toString(),
            });
            // 如果JSON解析失败，直接使用content作为文本（兜底方案）
            messageText = message.content;
          }
        }
      }
    } catch (e) {
      _logger.e('提取消息文本时出错', error: e, extra: {
        'messageId': message.messageId,
        'messageType': message.messageType,
      });
    }

    // 执行复制操作
    if (messageText?.isNotEmpty == true) {
      Clipboard.setData(ClipboardData(text: messageText!));
      final localizations = AppLocalizations.of(context);
      _showCopyMessage(localizations.copiedToClipboard, 1500);
      _logger.i('消息复制成功', extra: {
        'messageId': message.messageId,
        'messageType': message.messageType,
        'textLength': messageText.length,
        'copiedText': messageText.length <= 100 ? messageText : '${messageText.substring(0, 100)}...',
      });
    } else {
      _logger.w('没有可复制的文本内容', extra: {
        'messageId': message.messageId,
        'messageType': message.messageType,
        'contentPreview': message.content != null && message.content!.length > 200 ? '${message.content!.substring(0, 200)}...' : message.content,
      });

      // 根据消息类型显示不同的提示
      String noContentMessage;
      switch (message.messageType) {
        case 'TEXT':
          noContentMessage = '文本消息内容为空';
          break;
        case 'IMAGE':
        case 'VOICE':
        case 'VIDEO':
        case 'FILE':
          noContentMessage = '媒体消息没有说明文字';
          break;
        case 'SYSTEM':
          noContentMessage = '系统消息内容为空';
          break;
        default:
          noContentMessage = '没有可复制的内容';
      }

      _showCopyMessage(noContentMessage, 1200);
    }
  }

  /// 显示复制消息提示
  void _showCopyMessage(String message, int durationMs) {
    _copyMessageTimer?.cancel();
    _copyMessageNotifier.value = message;

    _copyMessageTimer = Timer(Duration(milliseconds: durationMs), () {
      _copyMessageNotifier.value = '';
    });
  }

  /// 撤回消息
  void _onRevokeMessage(Message message) {
    _logger.d('撤回消息', extra: {'messageId': message.messageId});

    // 💢💢💢 检查撤回时间限制（2分钟内可撤回）
    const revokeTimeLimit = Duration(minutes: 2);
    final timeSinceMessage = DateTime.now().difference(message.createdAt);

    if (timeSinceMessage > revokeTimeLimit) {
      // 超过时间限制，显示提示
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.messageExpiredCannotRevoke),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 💢💢💢 检查网络连接状态
    final chatCubit = context.read<ChatCubit>();
    final state = chatCubit.state;

    // 💢💢💢 预先获取messenger引用，避免Provider上下文问题
    final messenger = ScaffoldMessenger.of(context);

    if (state.networkStatus != ChatState.kNetworkStatusConnected) {
      final localizations = AppLocalizations.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(localizations.networkErrorCannotRevoke),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 💢💢💢 计算剩余撤回时间
    final remainingTime = revokeTimeLimit - timeSinceMessage;
    final remainingMinutes = remainingTime.inMinutes;
    final remainingSeconds = remainingTime.inSeconds % 60;

    String timeText;
    if (remainingMinutes > 0) {
      timeText = '$remainingMinutes分$remainingSeconds秒';
    } else {
      timeText = '$remainingSeconds秒';
    }

    // 显示确认对话框
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.revokeMessage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.confirmRevokeMessage),
            const SizedBox(height: 8),
            Text(
              "${localizations.revokeTimeRemaining}：$timeText",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizations.revokeInstructions,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              // 💢💢💢 显示撤回中状态
              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(localizations.revokingMessage),
                    ],
                  ),
                  duration: const Duration(seconds: 10), // 给撤回操作足够时间
                ),
              );

              try {
                // 调用ChatCubit的撤回方法（使用UUID作为messageId）
                await chatCubit.revokeMessage(message.messageId);

                // 💢💢💢 撤回成功
                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(localizations.messageRevoked),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // 💢💢💢 触觉反馈
                HapticFeedback.lightImpact();

                _logger.i('消息撤回成功', extra: {
                  'messageId': message.messageId,
                });
              } catch (error) {
                _logger.e('撤回消息失败', error: error, extra: {
                  'messageId': message.messageId,
                });

                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${localizations.revokeFailed}: ${error.toString()}'),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: localizations.retry,
                        textColor: Colors.white,
                        onPressed: () => _onRevokeMessage(message),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }

  /// 删除消息
  void _onDeleteMessage(Message message) {
    _logger.d('删除消息', extra: {'messageId': message.messageId});

    // 💢💢💢 在对话框外部获取ChatCubit引用，避免Provider上下文问题
    final chatCubit = context.read<ChatCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context);

    // 显示确认对话框
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.deleteMessage),
        content: Text(localizations.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              // 💢💢💢 显示删除中状态
              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(localizations.deletingMessage),
                    ],
                  ),
                  duration: const Duration(seconds: 10),
                ),
              );

              try {
                // 使用预先获取的ChatCubit引用（使用UUID作为messageId）
                await chatCubit.deleteMessage(message.messageId);

                // 💢💢💢 删除成功
                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(localizations.messageDeleted),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // 💢💢💢 触觉反馈
                HapticFeedback.lightImpact();

                _logger.i('消息删除成功', extra: {
                  'messageId': message.messageId,
                });
              } catch (error) {
                _logger.e('删除消息失败', error: error, extra: {
                  'messageId': message.messageId,
                });

                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${localizations.deleteFailed}: ${error.toString()}'),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: localizations.retry,
                        textColor: Colors.white,
                        onPressed: () => _onDeleteMessage(message),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }

  /// 获取最后在线时间文本
  String _getLastSeenText(ChatState state) {
    final localizations = AppLocalizations.of(context);
    if (state.networkStatus == ChatState.kNetworkStatusConnected) {
      return localizations.onlineStatus;
    } else if (state.networkStatus == ChatState.kNetworkStatusConnecting) {
      return localizations.connecting;
    } else {
      return localizations.offlineStatus;
    }
  }

  /// 构建搜索模式的应用栏
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      title: Row(
        children: [
          const ConnectionStatusIndicator(size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _searchController, // 💢💢💢 使用专用的搜索控制器
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchMessages,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onChanged: (query) {
                // 💢💢💢 实现搜索防抖（1秒）
                _searchDebounceTimer?.cancel();
                _searchDebounceTimer = Timer(
                  const Duration(milliseconds: 1000),
                  () {
                    context.read<ChatCubit>().performSearch(query);
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 💢💢💢 退出搜索时清空搜索框和取消防抖Timer
            _searchController.clear();
            _searchDebounceTimer?.cancel();
            context.read<ChatCubit>().exitSearchMode();
          },
          child: Text(
            AppLocalizations.of(context).cancel,
            style: const TextStyle(color: AppColors.primary, fontSize: 16),
          ),
        ),
      ],
    );
  }

  /// 构建搜索模式的底部栏
  Widget _buildSearchBottomBar() {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        // 💢💢💢 确保在搜索相关状态变化时重建UI
        return previous.searchDateFilter != current.searchDateFilter ||
            previous.searchResultTotalCount != current.searchResultTotalCount ||
            previous.currentSearchResultIndex != current.currentSearchResultIndex ||
            previous.isSearching != current.isSearching ||
            previous.searchQuery != current.searchQuery;
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withAlpha(51),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                offset: const Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 💢💢💢 搜索选项工具栏（合并了导航功能）
              _buildSearchOptionsBar(state),
            ],
          ),
        );
      },
    );
  }

  /// 💢💢💢 新增：搜索选项工具栏（合并了导航功能）
  Widget _buildSearchOptionsBar(ChatState state) {
    // 获取搜索结果信息
    final hasResults = state.searchResultTotalCount > 0;
    final currentIndex = state.currentSearchResultIndex;
    final totalCount = state.searchResultTotalCount;

    // 计算导航按钮的启用状态
    final canGoPrev = hasResults && currentIndex > 1;
    final canGoNext = hasResults && currentIndex < totalCount;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 💢💢💢 左侧：日期跳转按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showDateFilterPicker(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).jumpToDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 💢💢💢 中间：搜索状态指示器
          const SizedBox(width: 12),
          if (state.isSearching)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).searching,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            )
          else if (state.searchQuery.trim().isNotEmpty && !hasResults)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).noMatchFound,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

          const Spacer(),

          // 💢💢💢 右侧：搜索结果导航
          if (hasResults) ...[
            // 搜索结果计数器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '$currentIndex / $totalCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 导航按钮组
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 上一个结果按钮（因为列表反向，这里是下一个搜索结果）
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      onTap: canGoNext ? () => context.read<ChatCubit>().goToNextSearchResult() : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 20,
                          color: canGoNext ? Colors.grey.shade700 : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),

                  // 分隔线
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                  ),

                  // 下一个结果按钮（因为列表反向，这里是上一个搜索结果）
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      onTap: canGoPrev ? () => context.read<ChatCubit>().goToPrevSearchResult() : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: canGoPrev ? Colors.grey.shade700 : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 显示日期选择器
  Future<void> _showDateFilterPicker(BuildContext context) async {
    final chatCubit = context.read<ChatCubit>();
    final availableDates = chatCubit.getAvailableDates();

    if (availableDates.isEmpty) {
      // 如果没有可用日期，显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).noMessagesInChat)),
        );
      }
      return;
    }

    // 使用自定义日期选择器
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => _CustomDatePickerDialog(
        availableDates: availableDates,
        initialDate: DateTime.now(),
      ),
    );

    if (selectedDate != null && mounted) {
      // 💢💢💢 修改逻辑：跳转到指定日期的第一条消息，而不是过滤
      // ignore: use_build_context_synchronously
      await _jumpToDateFirstMessage(context, selectedDate);
    }
  }

  /// 💢💢💢 新增：跳转到指定日期的第一条消息
  Future<void> _jumpToDateFirstMessage(BuildContext context, DateTime selectedDate) async {
    final chatCubit = context.read<ChatCubit>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 查找指定日期的第一条消息
      final firstMessageOfDate = await chatCubit.findFirstMessageOfDate(selectedDate);

      if (firstMessageOfDate != null) {
        // 如果找到消息，滚动到该消息
        _scrollToMessage(firstMessageOfDate.messageIndex);

        // 显示成功提示
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).jumpedToFirstMessage),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // 如果没有找到消息，显示提示
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text('${selectedDate.month}/${selectedDate.day} ${localizations.noMessagesFoundOnDate}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('跳转到日期消息失败', error: error);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(localizations.jumpFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 💢💢💢 新增：重发消息
  void _onResendMessage(String messageId) {
    _logger.d('重发消息', extra: {
      'messageId': messageId,
    });

    // 调用ChatCubit的重发方法
    context.read<ChatCubit>().resendMessage(messageId);

    // 提供用户反馈
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.resendingMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 💢💢💢 新增：计算消息显示状态
  MessageDisplayStatus _calculateMessageDisplayStatus(
    Message message,
    Conversation conversation,
    CurrentUser? currentUser,
    bool isNotGroupChat,
  ) {
    // 私聊中，当前用户发送的消息：根据对方的 delivered/read 索引来决定双勾/已读
    if (isNotGroupChat && currentUser != null) {
      final isCurrentUserMessage = message.senderId == currentUser.userId;
      if (isCurrentUserMessage) {
        try {
          // 解析对方参与者（强类型）
          final list = ConversationAdapter.parseParticipants(conversation.participants);
          final other = list.isNotEmpty
              ? list.firstWhere((p) => p.userId != currentUser.userId, orElse: () => list.first)
              : null;

          if (other != null) {
            final int deliveredIdx = other.deliveredMessageIndex;
            final int readIdx = other.readMessageIndex;
            final bool isDelivered = deliveredIdx >= message.messageIndex || readIdx >= message.messageIndex;
            final bool isRead = readIdx >= message.messageIndex;

            // 调试日志
            // _logger.d('消息送达/已读计算', extra: {
            //   'conversationId': conversation.conversationId,
            //   'messageId': message.messageId,
            //   'messageIndex': message.messageIndex,
            //   'other.deliveredMessageIndex': deliveredIdx,
            //   'other.readMessageIndex': readIdx,
            //   'computed.isDelivered': isDelivered,
            //   'computed.isRead': isRead,
            //   'fallback.messageStatus': message.messageStatus,
            // });

            return MessageDisplayStatus(
              isRead: isRead,
              isDelivered: isDelivered,
              messageStatus: message.messageStatus,
            );
          }
        } catch (e) {
          _logger.w('解析对方参与者以计算送达/已读失败', extra: {
            'error': e.toString(),
            'conversationId': conversation.conversationId,
            'messageId': message.messageId,
          });
        }
      }
    }

    // 回退到消息本身的状态（群聊、对方消息、或解析失败）
    return MessageDisplayStatus(
      isRead: message.messageStatus == 'READ',
      isDelivered: message.messageStatus == 'DELIVERED' || message.messageStatus == 'READ',
      messageStatus: message.messageStatus,
    );
  }

  /// 🆕 构建未读消息指示器
  Widget _buildUnreadIndicator(ChatState state) {
    // 在搜索模式下不显示未读指示器
    if (state.isSearchMode) {
      return const SizedBox.shrink();
    }

    // 🆕 自动滚动期间抑制未读浮标，避免出现-消失的闪烁体验
    if (_isAutoScrollingToBottom) {
      return const SizedBox.shrink();
    }

    // 计算未读消息信息
    final unreadInfo = _calculateUnreadIndicatorInfo(state);

    // 如果没有未读消息，不显示指示器
    if (!unreadInfo.hasUnread) {
      return const SizedBox.shrink();
    }

    // 获取输入框区域的高度估算
    // 基础输入框高度：padding(16) + 内容(52) + padding(16) = 84
    // 如果有表情面板或功能面板，还需要加上面板高度
    double inputAreaHeight = 84;
    if (_showMoreOptions || _showEmojiPanel) {
      inputAreaHeight += 120; // 面板高度估算
    }

    return Positioned(
      bottom: inputAreaHeight + 50, // 相对于输入框顶部向上16像素
      right: 0,
      child: UnreadIndicatorButton(
        unreadCount: unreadInfo.unreadCount,
        text: unreadInfo.indicatorText,
        isVisible: true,
        onTap: () => _scrollToLastUnreadMessage(state), // 🔄 修改：点击跳转到最新未读消息
      ),
    );
  }

  /// 🆕 计算未读指示器信息
  _UnreadIndicatorInfo _calculateUnreadIndicatorInfo(ChatState state) {
    // 在底部视口时：不显示浮标，并触发一次已读更新（避免闪烁）
    if (_isUserAtBottom()) {
      _scheduleReadUpdateForVisibleMessages(state);
      return const _UnreadIndicatorInfo(
        hasUnread: false,
        unreadCount: 0,
        direction: _UnreadDirection.none,
        indicatorText: '',
      );
    }

    // 设计（简化版）：直接使用参与者的 read_message_index 作为基线
    // 未读 = lastMessageIndex - participantReadIndex
    // 与会话列表/标签页口径完全一致，且不随滚动变化
    // 1) 若所有消息可见，触发已读并隐藏
    if (_areAllMessagesVisible(state)) {
      _scheduleReadUpdateForVisibleMessages(state);
      return const _UnreadIndicatorInfo(
        hasUnread: false,
        unreadCount: 0,
        direction: _UnreadDirection.none,
        indicatorText: '',
      );
    }

    // 2) 获取参与者的 read index
    final pi = ConversationAdapter.getParticipantInfo(state.conversation.participants, state.currentUser.userId);
    final int? participantReadIndex = pi?.readMessageIndex;

    // 若缺少 read_message_index，视为无从计算未读，不显示浮标
    if (participantReadIndex == null) {
      return const _UnreadIndicatorInfo(
        hasUnread: false,
        unreadCount: 0,
        direction: _UnreadDirection.none,
        indicatorText: '',
      );
    }

    // 3) 计算"向下未读条数" = lastMessageIndex - participantReadIndex
    final lastMessageIndex = state.conversation.lastMessageIndex;
    final unreadBelow = (lastMessageIndex - participantReadIndex).clamp(0, 1 << 30);
    if (unreadBelow <= 0) {
      return const _UnreadIndicatorInfo(
        hasUnread: false,
        unreadCount: 0,
        direction: _UnreadDirection.none,
        indicatorText: '',
      );
    }

    // 固定向下方向显示
    final indicatorText = _generateUnreadIndicatorText(unreadBelow, _UnreadDirection.down);

    return _UnreadIndicatorInfo(
      hasUnread: true,
      unreadCount: unreadBelow,
      direction: _UnreadDirection.down,
      indicatorText: indicatorText,
      firstUnreadIndex: participantReadIndex + 1,
    );
  }

  // 未使用：判断未读方向
  // _UnreadDirection _determineUnreadDirection(ChatState state, int firstUnreadIndex) => _UnreadDirection.none;

  /// 🆕 生成未读指示器文本
  String _generateUnreadIndicatorText(int unreadCount, _UnreadDirection direction) {
    final countText = unreadCount.toString();

    switch (direction) {
      case _UnreadDirection.up:
        return '$countText ↑';
      case _UnreadDirection.down:
        return '$countText ↓';
      case _UnreadDirection.none:
        return countText;
    }
  }

  /// 🆕 检查是否所有消息都在可视范围内（未满一页的情况）
  bool _areAllMessagesVisible(ChatState state) {
    if (state.messages.isEmpty) return true;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return false;

    // 获取可见的处理后索引
    final visibleProcessedIndices = positions.map((p) => p.index).toSet();

    // 优化：一次性获取processedItems，避免重复计算
    final processedItems = MessageListProcessor.processMessages(
      messages: state.messages,
      currentUserId: state.currentUser.userId,
      isNotGroupChat: state.conversation.type != 'GROUP',
    );

    // 查找第一条和最后一条消息在processedItems中的索引
    final firstMessage = state.messages[0];
    final lastMessage = state.messages[state.messages.length - 1];

    int? firstMessageProcessedIndex;
    int? lastMessageProcessedIndex;

    for (int i = 0; i < processedItems.length; i++) {
      final item = processedItems[i];
      if (item is MessageListItemData) {
        if (item.message.messageId == firstMessage.messageId) {
          firstMessageProcessedIndex = i;
        }
        if (item.message.messageId == lastMessage.messageId) {
          lastMessageProcessedIndex = i;
        }
      }
    }

    // 如果第一条和最后一条消息都可见，则认为所有消息都可见
    final allVisible = firstMessageProcessedIndex != null &&
        lastMessageProcessedIndex != null &&
        visibleProcessedIndices.contains(firstMessageProcessedIndex) &&
        visibleProcessedIndices.contains(lastMessageProcessedIndex);

    return allVisible;
  }

  // 未使用：计算可视底部消息索引
  // int? _getLatestVisibleMessageIndex(ChatState state) => null;

  /// 🆕 为可见消息安排已读更新
  void _scheduleReadUpdateForVisibleMessages(ChatState state) {
    if (state.messages.isEmpty) return;

    // 获取最后一条消息的索引作为已读标记
    final latestMessageIndex = state.messages.last.messageIndex;

    // 使用定时器延迟触发，避免频繁调用
    _visibilityReadUpdateTimer?.cancel();
    _visibilityReadUpdateTimer = Timer(const Duration(milliseconds: 1000), () {
      context.read<ChatCubit>().updateReadStatusManually(latestMessageIndex);
    });
  }

  /// 🆕 滚动到最新的未读消息（会话中的最后一条消息）
  Future<void> _scrollToLastUnreadMessage(ChatState state) async {
    try {
      final conversation = state.conversation;

      // 计算第一条未读消息的索引（基于参与者的 readMessageIndex）
      final pi = ConversationAdapter.getParticipantInfo(conversation.participants, state.currentUser.userId);
      final readIdx = pi?.readMessageIndex ?? conversation.lastMessageIndex;
      final firstUnreadIndex = readIdx + 1;

      // 获取会话中的最后一条消息索引（最新未读消息）
      final lastMessageIndex = conversation.lastMessageIndex;

      // 如果没有未读消息，直接返回
      if (firstUnreadIndex > lastMessageIndex) {
        _logger.i('没有未读消息', extra: {
          'computedReadMessageIndex': readIdx,
          'lastMessageIndex': lastMessageIndex,
        });
        return;
      }

      // 优先跳转到最新的消息（最后一条消息）
      final targetIndex = lastMessageIndex;

      // 在当前消息列表中查找对应的消息
      final targetMessage = state.messages.where((msg) => msg.messageIndex == targetIndex).firstOrNull;

      if (targetMessage != null) {
        // 如果消息在当前列表中，直接滚动到该消息
        await _scrollToMessage(
          targetMessage.messageIndex,
          alignment: 0.5, // 在屏幕中央显示
          showHighlight: true,
        );

        _logger.i('滚动到最新消息成功', extra: {
          'messageId': targetMessage.messageId,
          'messageIndex': targetIndex,
          'unreadCount': lastMessageIndex - readIdx,
        });
      } else {
        _logger.w('最新消息不在当前列表中，使用jumpToMessageIndex加载', extra: {
          'targetIndex': targetIndex,
          'currentListSize': state.messages.length,
          'listRange': state.messages.isEmpty ? 'empty' : '${state.messages.first.messageIndex}-${state.messages.last.messageIndex}',
        });

        // 使用jumpToMessageIndex来加载并跳转到最新消息
        await context.read<ChatCubit>().jumpToMessageIndex(targetIndex);
      }

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('滚动到最新未读消息失败', error: error);

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.jumpToLatestFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 🆕 滚动到第一条未读消息（备用方法，暂时保留以备将来双重跳转功能使用）
  // ignore: unused_element
  Future<void> _scrollToFirstUnreadMessage(ChatState state) async {
    try {
      final currentUserId = state.currentUser.userId;
      final conversation = state.conversation;

      // 获取第一条未读消息的索引
      final firstUnreadIndex = conversation.getFirstUnreadMessageIndex(currentUserId);
      if (firstUnreadIndex == null) {
        _logger.w('没有找到第一条未读消息的索引');
        return;
      }

      // 在当前消息列表中查找对应的消息
      final firstUnreadMessage = state.messages.where((msg) => msg.messageIndex == firstUnreadIndex).firstOrNull;

      if (firstUnreadMessage != null) {
        // 如果消息在当前列表中，直接滚动到该消息
        await _scrollToMessage(
          firstUnreadMessage.messageIndex,
          alignment: 0.5, // 在屏幕中央显示
          showHighlight: true,
        );

        _logger.i('滚动到第一条未读消息成功', extra: {
          'messageId': firstUnreadMessage.messageId,
          'messageIndex': firstUnreadIndex,
        });
      } else {
        _logger.w('第一条未读消息不在当前列表中', extra: {
          'firstUnreadIndex': firstUnreadIndex,
          'messageRange': state.messages.isEmpty ? 'empty' : '${state.messages.last.messageIndex}-${state.messages.first.messageIndex}',
        });

        // 显示提示
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.unreadNotInList),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('滚动到第一条未读消息失败', error: error);

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.jumpToUnreadFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 测试快捷回复权限逻辑
  void _testQuickReplyPermissions(int currentRoleId) {
    print('🧪🧪🧪 PERMISSION_TEST_START: currentRoleId=$currentRoleId');

    // 测试所有可能的roleId值
    for (int testRoleId = 0; testRoleId <= 5; testRoleId++) {
      final isCustomerService = testRoleId == 3;
      final isVip = testRoleId == 4;
      final hasPermission = isCustomerService || isVip;
      final isCurrent = testRoleId == currentRoleId;

      print('🧪 TEST roleId=$testRoleId: isCS=$isCustomerService, isVip=$isVip, hasPermission=$hasPermission ${isCurrent ? '← CURRENT' : ''}');
    }

    print('🧪🧪🧪 PERMISSION_TEST_END');
  }

  /// 检查用户是否有快捷回复权限
  /// 只有 roleId 为 3 或 4 的用户才能使用快捷回复功能
  bool _hasQuickReplyPermission(int roleId) {
    final isCustomerService = roleId == 3;
    final isVip = roleId == 4;
    final hasPermission = isCustomerService || isVip;

    // _logger.i('⚡⚡⚡ 快捷回复权限检查详细信息', extra: {
    //   'originalRoleId': roleId,
    //   'roleIdType': roleId.runtimeType.toString(),
    //   'isCustomerService_3': isCustomerService,
    //   'isVip_4': isVip,
    //   'hasPermission': hasPermission,
    //   'calculation': '$roleId == 3 || $roleId == 4 = $hasPermission',
    // });


    return hasPermission;
  }

  /// 根据消息ID获取消息（用于显示被回复的消息）
  Message? _getQuotedMessage(String messageId) {
    final chatCubit = context.read<ChatCubit>();
    final state = chatCubit.state;

    // 在当前消息列表中查找
    try {
      return state.messages.firstWhere(
        (message) => message.messageId == messageId,
      );
    } catch (e) {
      // 消息不在当前列表中，可能已被删除或不在当前加载范围内
      _logger.w('无法找到被回复的消息', extra: {
        'quotedMessageId': messageId,
        'currentMessagesCount': state.messages.length,
      });
      return null;
    }
  }
}

/// 自定义日期选择器对话框
class _CustomDatePickerDialog extends StatefulWidget {
  final Set<DateTime> availableDates;
  final DateTime initialDate;

  const _CustomDatePickerDialog({
    required this.availableDates,
    required this.initialDate,
  });

  @override
  State<_CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  late DateTime _currentDate;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();

    // 如果有可用日期，选择最新的日期；否则使用初始日期
    if (widget.availableDates.isNotEmpty) {
      final sortedDates = widget.availableDates.toList()..sort((a, b) => b.compareTo(a)); // 按日期降序排列
      _currentDate = sortedDates.first; // 选择最新的日期
    } else {
      _currentDate = widget.initialDate;
    }

    _displayMonth = DateTime(_currentDate.year, _currentDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).selectDate),
      content: SizedBox(
        width: 300,
        height: 450,
        child: Column(
          children: [
            // 提示文本
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '蓝色标记的日期有消息，选择日期可跳转到当天第一条消息',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 月份导航
            _buildMonthNavigation(),
            const SizedBox(height: 16),
            // 日历网格
            Expanded(child: _buildCalendarGrid()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _currentDate),
          child: Text(AppLocalizations.of(context).confirm),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    // 💢💢💢 允许导航到所有月份，不限制只有消息的月份
    final prevMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    final nextMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    final now = DateTime.now();

    // 设置合理的时间范围：过去5年到未来1年
    final minDate = DateTime(now.year - 5, 1, 1);
    final maxDate = DateTime(now.year + 1, 12, 31);

    final canGoPrev = prevMonth.isAfter(minDate) || prevMonth.isAtSameMomentAs(DateTime(minDate.year, minDate.month));
    final canGoNext = nextMonth.isBefore(maxDate) || nextMonth.isAtSameMomentAs(DateTime(maxDate.year, maxDate.month));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: canGoPrev
              ? () {
                  setState(() {
                    _displayMonth = prevMonth;
                  });
                }
              : null,
          icon: Icon(
            Icons.chevron_left,
            color: canGoPrev ? null : Colors.grey.shade400,
          ),
        ),
        Text(
          '${_displayMonth.year}年${_displayMonth.month}月',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: canGoNext
              ? () {
                  setState(() {
                    _displayMonth = nextMonth;
                  });
                }
              : null,
          icon: Icon(
            Icons.chevron_right,
            color: canGoNext ? null : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    return Column(
      children: [
        // 星期标题
        SizedBox(
          height: 30,
          child: Row(
            children: ['日', '一', '二', '三', '四', '五', '六']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // 日历网格
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: daysInMonth + weekdayOfFirstDay,
            itemBuilder: (context, index) {
              if (index < weekdayOfFirstDay) {
                return const SizedBox(); // 空白位置
              }

              final day = index - weekdayOfFirstDay + 1;
              final date = DateTime(_displayMonth.year, _displayMonth.month, day);
              final hasMessages = widget.availableDates.contains(date);
              final isSelected = date.isAtSameMomentAs(DateTime(_currentDate.year, _currentDate.month, _currentDate.day));
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  // 💢💢💢 允许选择任何日期，不限制只有消息的日期
                  setState(() {
                    _currentDate = date;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : (hasMessages ? AppColors.primary.withAlpha(13) : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                        : (hasMessages ? Border.all(color: AppColors.primary.withAlpha(51)) : Border.all(color: Colors.grey.shade200)),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (hasMessages ? (isToday ? Theme.of(context).primaryColor : AppColors.primary) : (isToday ? Theme.of(context).primaryColor : Colors.grey.shade600)),
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 检查两个日期是否是同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

/// 音频波形绘制器
class AudioWavePainter extends CustomPainter {
  final double progress;

  AudioWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 1.5;

    const barCount = 12;
    const barWidth = 2.0;
    final spacing = (size.width - (barCount * barWidth)) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);

      // 创建动态高度效果
      final baseHeight = size.height * 0.3;
      final animatedHeight = size.height * 0.7 * (0.5 + 0.5 * sin((progress * 2 * pi) + (i * 0.5)));

      final height = baseHeight + animatedHeight;
      final y = (size.height - height) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 图片预览对话框
class _ImagePreviewDialog extends StatefulWidget {
  final dynamic imageFile;

  const _ImagePreviewDialog({required this.imageFile});

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// 根据平台构建图片Widget
  Widget _buildImageWidget(
    dynamic imageFile, {
    BoxFit? fit,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    if (kIsWeb && imageFile is XFile) {
      // Web平台使用XFile
      return Image.network(
        imageFile.path, // Web平台上XFile.path是blob URL
        fit: fit,
        errorBuilder: errorBuilder,
      );
    } else if (imageFile is File) {
      // 原生平台使用File
      return Image.file(
        imageFile,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    } else {
      // fallback：尝试使用XFile
      return Image.network(
        imageFile.path,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '发送图片',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 图片预览
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(
                    widget.imageFile,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(AppLocalizations.of(context).imageLoadFailed, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 图片说明输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).addImageCaption,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                maxLength: 200,
              ),
            ),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendImage,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context).send),
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

  void _sendImage() {
    setState(() {
      _isLoading = true;
    });

    // 返回确认结果和图片说明
    Navigator.of(context).pop({
      'confirmed': true,
      'caption': _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
    });
  }
}

/// 文件预览对话框
class _FilePreviewDialog extends StatefulWidget {
  final File file;

  const _FilePreviewDialog({required this.file});

  @override
  State<_FilePreviewDialog> createState() => _FilePreviewDialogState();
}

class _FilePreviewDialogState extends State<_FilePreviewDialog> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;
  late String _fileName;
  late String _fileSize;
  late String _fileExtension;
  IconData _fileIcon = Icons.insert_drive_file;

  @override
  void initState() {
    super.initState();
    _initFileInfo();
  }

  void _initFileInfo() {
    _fileName = widget.file.path.split('/').last;

    final fileSizeBytes = widget.file.lengthSync();
    _fileSize = _formatFileSize(fileSizeBytes);

    // 文件模式：统一使用通用文件图标
    _fileIcon = Icons.insert_drive_file;
    _fileExtension = 'FILE'; // 统一显示为FILE类型
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Color _getFileIconColor(String extension) {
    // 文件模式：统一使用灰色
    return Colors.grey;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).sendFile,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 文件信息预览
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 文件图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getFileIconColor(_fileExtension).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _fileIcon,
                        size: 40,
                        color: _getFileIconColor(_fileExtension),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 文件名
                    Text(
                      _fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // 文件大小
                    Text(
                      _fileSize,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 文件类型
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getFileIconColor(_fileExtension).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _fileExtension.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getFileIconColor(_fileExtension),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 文件说明输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).addFileCaption,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                maxLength: 200,
              ),
            ),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendFile,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context).send),
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

  void _sendFile() {
    setState(() {
      _isLoading = true;
    });

    // 返回确认结果和文件说明
    Navigator.of(context).pop({
      'confirmed': true,
      'caption': _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
    });
  }
}

/// 🆕 未读指示器信息
class _UnreadIndicatorInfo {
  final bool hasUnread;
  final int unreadCount;
  final _UnreadDirection direction;
  final String indicatorText;
  final int? firstUnreadIndex; // 💡 注意：现在实际存储的是最新未读消息索引，保持向后兼容

  const _UnreadIndicatorInfo({
    required this.hasUnread,
    required this.unreadCount,
    required this.direction,
    required this.indicatorText,
    this.firstUnreadIndex,
  });
}

/// 🆕 未读消息方向
enum _UnreadDirection {
  up, // 未读消息在当前位置上方（历史消息方向）
  down, // 未读消息在当前位置下方（新消息方向）
  none, // 无方向或无法确定
}

/// 视频预览对话框
class _VideoPreviewDialog extends StatefulWidget {
  final File videoFile;

  const _VideoPreviewDialog({required this.videoFile});

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.videocam, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    '发送视频',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 视频预览区域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 视频缩略图或播放器占位符
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '视频预览',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 视频文件信息
                    FutureBuilder<int>(
                      future: widget.videoFile.length(),
                      builder: (context, snapshot) {
                        final fileSize = snapshot.data ?? 0;
                        final fileSizeText = fileSize > 1024 * 1024 ? '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB' : '${(fileSize / 1024).toStringAsFixed(1)}KB';

                        return Text(
                          '文件大小: $fileSizeText',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 说明文字输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: '添加视频说明...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                maxLength: 200,
              ),
            ),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendVideo,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context).send),
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

  void _sendVideo() {
    setState(() {
      _isLoading = true;
    });

    // 返回确认结果和视频说明
    Navigator.of(context).pop({
      'confirmed': true,
      'caption': _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
    });
  }
}

extension _ChatPageReplyExtension on _ChatPageState {
  /// 构建回复消息显示组件
  Widget _buildReplyingToMessage(Message replyingToMessage) {
    // 计算自适应宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.8; // 最大宽度为屏幕宽度的80%
    final minWidth = screenWidth * 0.4; // 最小宽度为屏幕宽度的40%

    final senderName = replyingToMessage.senderName ?? '未知用户';
    final messagePreview = _getReplyMessagePreview(replyingToMessage);

    // 根据内容长度估算宽度
    final contentLength = senderName.length + messagePreview.length;
    double estimatedWidth = (contentLength * 8.0) + 80.0; // 每个字符约8像素 + 图标和内边距

    // 限制在最小和最大宽度之间
    final containerWidth = estimatedWidth.clamp(minWidth, maxWidth);

    // 判断是否是当前用户发送的消息
    final isCurrentUserMessage = replyingToMessage.senderId == context.read<ChatCubit>().state.currentUser.userId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0), // 增加上下2px间距
      child: Row(
        children: [
          // 根据发送人决定对齐方式，如果是当前用户消息，在左侧添加空白
          if (isCurrentUserMessage) const Spacer(),

          // 回复消息内容容器
          IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth,
                maxWidth: containerWidth,
              ),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 回复图标
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),

                    // 回复内容
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 被回复用户名
                          Text(
                            senderName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // 被回复消息内容
                          Text(
                            messagePreview,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 关闭按钮 - 独立放置在最右边
          GestureDetector(
            onTap: () {
              context.read<ChatCubit>().clearReplyingToMessage();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // 如果不是当前用户消息，在右侧添加空白
          if (!isCurrentUserMessage) const Spacer(),
        ],
      ),
    );
  }

  /// 获取回复消息的预览文本
  String _getReplyMessagePreview(Message message) {
    try {
      // 使用MessageAdapter提取文本内容
      final text = MessageAdapter.extractTextFromContent(message.content);
      if (text != null && text.isNotEmpty) {
        return text;
      }

      // 根据消息类型返回不同的预览文本
      switch (message.messageType) {
        case 'IMAGE':
          return '[图片]';
        case 'VOICE':
          return '[语音]';
        case 'VIDEO':
          return '[视频]';
        case 'FILE':
          return '[文件]';
        case 'SYSTEM':
          return '[系统消息]';
        default:
          return '[消息]';
      }
    } catch (e) {
      _ChatPageState._logger.w('获取回复消息预览失败', extra: {
        'messageId': message.messageId,
        'messageType': message.messageType,
        'error': e.toString(),
      });
      return '[消息]';
    }
  }
}
