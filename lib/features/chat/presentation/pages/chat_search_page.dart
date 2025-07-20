import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
// 添加导入Isar数据库
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/presentation/utils/date_picker_utility.dart';
import 'package:cc/features/chat/presentation/cubit/search_cubit.dart';
// 导入本地化支持
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/services/media_cache_service.dart';
import 'package:cc/core/services/thumbnail_cache_service.dart';
import 'dart:io';

class ChatSearchPage extends StatefulWidget {
  final String conversationId;
  final String conversationName;

  const ChatSearchPage({
    super.key,
    required this.conversationId,
    required this.conversationName,
  });

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  final _logger = LogService.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Message> _allMessages = []; // 所有消息的缓存

  // 添加SearchCubit实例变量
  late final SearchCubit _searchCubit;

  // 日期选择器工具类
  late DatePickerUtility _datePicker;

  @override
  void initState() {
    super.initState();
    // 初始化SearchCubit
    _searchCubit = SearchCubit();

    // 初始化日期选择器工具类
    _datePicker = DatePickerUtility(conversationId: widget.conversationId);

    // 自动聚焦到搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FocusScope.of(context).requestFocus(_searchFocusNode);
      // 预加载当前消息
      _loadAllMessages();
      // 预加载最近3个月的消息日期
      await _datePicker.preloadRecentMessageDates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchCubit.close(); // 关闭cubit
    super.dispose();
  }

  // 加载所有消息
  void _loadAllMessages() {
    context.read<HomeCubit>();
    _allMessages = [];
  }

  // 执行搜索
  void _performSearch(String query) {
    // 获取会话中的所有消息（如果未预加载）
    if (_allMessages.isEmpty) {
      _loadAllMessages();
    }

    // 使用SearchCubit执行搜索
    _searchCubit.performSearch(query, _allMessages);
  }

  // 日期选择
  Future<void> _selectDate(BuildContext context) async {
    try {
      _logger.i('打开日期选择器');
      final selectedDate = await _datePicker.selectDate(context);

      // 如果选中了日期,则跳转到对应日期的聊天记录
      if (selectedDate != null) {
        // 更新SearchCubit中的日期和过滤器
        _searchCubit.setSelectedDate(selectedDate);

        _jumpToChatAtDate(selectedDate);
      }
    } catch (error) {
      // 通知Cubit日期选择失败
      _searchCubit.dateSelectionFailed(error.toString());
      _logger.e('日期选择失败', error: error, stackTrace: StackTrace.current);

      // 使用全局UINotificationService代替直接使用ScaffoldMessenger
      UINotificationHelper.showError(
          AppLocalizations.of(context).errorOccurred);
    }
  }

  // 查找所选日期的消息并跳转到聊天界面
  void _jumpToChatAtDate(DateTime date) {
    try {
      _logger.i('开始跳转到日期',
          extra: {'date': date.toString(), 'dataType': date.runtimeType});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            // TODO 需要在HomeCubit中实现跳转到指定日期的功能
            // 目前暂时不实现这个功能
            UINotificationHelper.showWarning(
                AppLocalizations.of(context).errorOccurred);

            // 直接返回
            Navigator.of(context).pop();
            _logger.i('返回到聊天界面');
          } catch (error) {
            _logger.e('跳转到聊天界面失败',
                error: error, stackTrace: StackTrace.current);

            // 使用UINotificationHelper
            UINotificationHelper.showError(
                AppLocalizations.of(context).errorOccurred);
          }
        } else {
          _logger.w('组件已卸载,无法执行导航');
        }
      });
    } catch (error) {
      _logger.e('跳转到日期消息失败', error: error, stackTrace: StackTrace.current);

      // 使用UINotificationHelper
      UINotificationHelper.showError(
          AppLocalizations.of(context).errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取主题颜色
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final localizations = AppLocalizations.of(context);

    // 使用BlocProvider提供已创建的SearchCubit实例
    return BlocProvider.value(
      value: _searchCubit,
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: localizations.search,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  if (value.isEmpty && state.currentFilter == FilterType.all) {
                    // 清空结果
                    _searchCubit.performSearch('', _allMessages);
                  }
                },
                onSubmitted: _performSearch,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: primaryColor),
                  onPressed: () => _performSearch(_searchController.text),
                ),
              ],
            ),
            body: Column(
              children: [
                // 快速过滤器栏
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 筛选按钮组
                        _buildFilterChip(FilterType.all, primaryColor, state),
                        _buildFilterChip(FilterType.date, primaryColor, state),
                        _buildFilterChip(FilterType.media, primaryColor, state),
                        _buildFilterChip(FilterType.file, primaryColor, state),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // 搜索中指示器
                if (state.isSearching) const LinearProgressIndicator(),

                // 搜索结果
                Expanded(
                  child: state.searchResults.isEmpty
                      ? _buildEmptyResults(state)
                      : state.currentFilter == FilterType.media
                          ? _buildMediaGrid(state.searchResults)
                          : ListView.builder(
                              itemCount: state.searchResults.length,
                              itemBuilder: (context, index) {
                                return _buildSearchResultItem(
                                    state.searchResults[index]);
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建过滤器Chip
  Widget _buildFilterChip(
      FilterType type, Color primaryColor, SearchState state) {
    final isSelected = state.currentFilter == type;
    final localizations = AppLocalizations.of(context);

    // 日期筛选器需要特殊处理
    if (type == FilterType.date) {
      return GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                state.selectedDate != null
                    ? '${state.selectedDate!.month}/${state.selectedDate!.day}'
                    : localizations.today,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 其他过滤器
    String label;
    IconData icon;

    switch (type) {
      case FilterType.all:
        label = localizations.allChats;
        icon = Icons.list;
        break;
      case FilterType.media:
        label = localizations.media;
        icon = Icons.image;
        break;
      case FilterType.file:
        label = localizations.files;
        icon = Icons.insert_drive_file;
        break;
      default:
        label = localizations.allChats;
        icon = Icons.list;
    }

    return GestureDetector(
      onTap: () {
        _searchCubit.setFilter(type);
        if (_allMessages.isEmpty) {
          _loadAllMessages();
        }
        _performSearch(_searchController.text);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建空结果视图
  Widget _buildEmptyResults(SearchState state) {
    final localizations = AppLocalizations.of(context);

    if (state.searchQuery == null || state.searchQuery!.isEmpty) {
      return Center(child: Text(localizations.search));
    }

    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(child: Text(localizations.noMatchingChats));
  }

  // 构建搜索结果项
  Widget _buildSearchResultItem(Message message) {
    return ListTile(
      leading: _getMessageTypeIcon(message),
      title: message.text != null && message.text!.isNotEmpty
          ? Text(message.text!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : const Text('[非文本消息]',
              style: TextStyle(fontStyle: FontStyle.italic)),
      subtitle: Text(_formatMessageTime(message.createdAt)),
      onTap: () {
        // 返回并定位到这条消息
        Navigator.pop(context);

        // TODO 需要在HomeCubit中实现跳转到指定消息的功能
        UINotificationHelper.showWarning(
            AppLocalizations.of(context).errorOccurred);
      },
    );
  }

  // 构建媒体网格
  Widget _buildMediaGrid(List<Message> messages) {
    final localizations = AppLocalizations.of(context);

    // 过滤出媒体消息
    final mediaMessages = messages
        .where((msg) =>
            msg.type == MessageType.image || msg.type == MessageType.video)
        .toList();

    if (mediaMessages.isEmpty) {
      return Center(child: Text(localizations.noMedia));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaMessages.length,
      itemBuilder: (context, index) {
        final message = mediaMessages[index];
        return GestureDetector(
          onTap: () {
            // 查看大图或视频
            // TODO 实现媒体查看功能
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: message.type == MessageType.video
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      FutureBuilder<String?>(
                        future: message.thumbnailUrl,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _CachedNetworkImage(
                                url: snapshot.data!,
                                mediaType: 'thumbnails',
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: message.mediaUrl != null
                        ? _CachedNetworkImage(
                            url: message.mediaUrl!,
                            mediaType: 'images',
                          )
                        : const Center(child: Icon(Icons.broken_image)),
                  ),
          ),
        );
      },
    );
  }

  // 获取消息类型对应的图标
  Widget _getMessageTypeIcon(Message message) {
    switch (message.type) {
      case MessageType.image:
        return CircleAvatar(
          backgroundColor: AppColors.primary.withAlpha(26),
          child: const Icon(Icons.image, color: AppColors.primary),
        );
      case MessageType.video:
        return CircleAvatar(
          backgroundColor: Colors.red[100],
          child: const Icon(Icons.videocam, color: Colors.red),
        );
      case MessageType.file:
        return CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: const Icon(Icons.insert_drive_file, color: Colors.orange),
        );
      case MessageType.voice:
        return CircleAvatar(
          backgroundColor: Colors.green[100],
          child: const Icon(Icons.mic, color: Colors.green),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.message, color: Colors.grey),
        );
    }
  }

  // 格式化消息时间
  String _formatMessageTime(DateTime time) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${localizations.today} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return '${localizations.yesterday} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// 缓存网络图片组件
class _CachedNetworkImage extends StatefulWidget {
  final String url;
  final String mediaType;

  const _CachedNetworkImage({
    required this.url,
    required this.mediaType,
  });

  @override
  State<_CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<_CachedNetworkImage> {
  final MediaCacheService _mediaCache = MediaCacheService();
  final ThumbnailCacheService _thumbnailCache = ThumbnailCacheService();
  String? _localPath;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      String? localPath;
      if (widget.mediaType == 'thumbnails') {
        localPath = await _thumbnailCache.getThumbnail(widget.url);
      } else {
        localPath = await _mediaCache.getMedia(widget.url, widget.mediaType);
      }

      if (mounted) {
        setState(() {
          _localPath = localPath;
          _isLoading = false;
          _hasError = localPath == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_hasError || _localPath == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    return Image.file(
      File(_localPath!),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
