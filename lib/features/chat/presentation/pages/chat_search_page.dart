import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
// 添加导入Isar数据库
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/presentation/utils/date_picker_utility.dart';
import 'package:cc/features/chat/presentation/cubit/search_cubit.dart';
// 导入本地化支持
import 'package:cc/core/utils/ui_notification_helper.dart';
import 'package:cc/core/constants/message_types.dart';

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
    final chatCubit = context.read<ChatCubit>();
    _allMessages = chatCubit.state.messagesByConversation[widget.conversationId] ?? [];

    // 按时间倒序排序
    _allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
      UINotificationHelper.showError('日期选择失败: $error');
    }
  }

  // 查找所选日期的消息并跳转到聊天界面
  void _jumpToChatAtDate(DateTime date) {
    try {
      _logger.i('开始跳转到日期', extra: {'date': date.toString(), 'type': date.runtimeType});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            final chatCubit = context.read<ChatCubit>();
            chatCubit.jumpToDate(widget.conversationId, date);
            // 使用标准格式的Map参数返回
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _logger.i('跳转到聊天界面', extra: {'set navigationData': date});
          } catch (error) {
            _logger.e('跳转到聊天界面失败', error: error, stackTrace: StackTrace.current);

            // 使用UINotificationHelper
            UINotificationHelper.showError('跳转到聊天界面失败: $error');
          }
        } else {
          _logger.w('组件已卸载,无法执行导航');
        }
      });
    } catch (error) {
      _logger.e('跳转到日期消息失败', error: error, stackTrace: StackTrace.current);

      // 使用UINotificationHelper
      UINotificationHelper.showError('日期选择失败: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取主题颜色
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

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
                  hintText: '搜索',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
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
                icon: Icon(Icons.arrow_back, color: Colors.black87),
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
                                return _buildSearchResultItem(state.searchResults[index]);
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
  Widget _buildFilterChip(FilterType type, Color primaryColor, SearchState state) {
    final isSelected = state.currentFilter == type;

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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.date_range,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                '日期',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // 更新过滤器类型并执行搜索
        _searchCubit.setFilter(type);
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFilterIcon(type),
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              _getFilterName(type),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 获取过滤器名称
  String _getFilterName(FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return '全部';
      case FilterType.text:
        return '文本';
      case FilterType.media:
        return '图片/视频';
      case FilterType.file:
        return '文件';
      case FilterType.date:
        return '日期';
      case FilterType.month:
        return '最近一月';
      case FilterType.year:
        return '最近一年';
    }
  }

  // 获取过滤器图标
  IconData _getFilterIcon(FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return Icons.all_inclusive;
      case FilterType.text:
        return Icons.text_fields;
      case FilterType.media:
        return Icons.perm_media;
      case FilterType.file:
        return Icons.insert_drive_file;
      case FilterType.date:
        return Icons.date_range;
      case FilterType.month:
        return Icons.calendar_today;
      case FilterType.year:
        return Icons.calendar_month;
    }
  }

  // 构建空搜索结果
  Widget _buildEmptyResults(SearchState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty && state.currentFilter == FilterType.all ? '输入关键词开始搜索' : '未找到符合条件的消息',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (state.currentFilter != FilterType.all)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '当前筛选: ${_getFilterName(state.currentFilter!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建媒体网格视图
  Widget _buildMediaGrid(List<Message> messages) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        if (message.type == MessageType.image) {
          return _buildImageThumbnail(message);
        } else if (message.type == MessageType.video) {
          return _buildVideoThumbnail(message);
        }
        return const SizedBox(); // 不应该到达这里
      },
    );
  }

  // 构建图片缩略图
  Widget _buildImageThumbnail(Message message) {
    return GestureDetector(
      onTap: () {
        _logger.i('点击图片', extra: {'messageId': message.messageId});
        Navigator.pop(context, message.messageId);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[200],
          image: message.mediaUrl != null && message.mediaUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(message.mediaUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: message.mediaUrl == null || message.mediaUrl!.isEmpty ? Center(child: Icon(Icons.image, color: Colors.grey[600])) : null,
      ),
    );
  }

  // 构建视频缩略图
  Widget _buildVideoThumbnail(Message message) {
    return GestureDetector(
      onTap: () {
        _logger.i('点击视频', extra: {'messageId': message.messageId});
        Navigator.pop(context, message.messageId);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
              image: message.thumbnailUrl != null && message.thumbnailUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(message.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: message.thumbnailUrl == null || message.thumbnailUrl!.isEmpty ? Center(child: Icon(Icons.videocam, color: Colors.grey[600])) : null,
          ),
          Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 128),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建搜索结果项
  Widget _buildSearchResultItem(Message message) {
    // 获取发送者名称
    final senderName = message.senderName ?? '未知用户';
    // 获取搜索高亮的文本
    final highlightedText = _getHighlightedText(message);
    // 格式化时间
    final formattedTime = _formatDateTime(message.createdAt);

    return InkWell(
      onTap: () {
        // 跳转到消息位置的实现可以在这里添加
        _logger.i('跳转到消息', extra: {'messageId': message.messageId});

        // 使用标准格式Map返回消息ID
        final result = {'targetMessageId': message.messageId};
        _logger.i('准备返回消息ID,使用Map格式', extra: {'result': result, 'type': result.runtimeType});

        Navigator.pop(context, result);
        _logger.i('已调用Navigator.pop传递消息ID参数');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 发送者和时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 消息内容
            _buildMessageContent(message, highlightedText),
          ],
        ),
      ),
    );
  }

  // 构建消息内容
  Widget _buildMessageContent(Message message, Widget textWidget) {
    switch (message.type) {
      case MessageType.text:
        return textWidget;

      case MessageType.image:
        return Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
                image: message.mediaUrl != null && message.mediaUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(message.mediaUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: message.mediaUrl == null || message.mediaUrl!.isEmpty ? Icon(Icons.image, color: Colors.grey[600]) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '图片',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        );

      case MessageType.video:
        return Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                    image: message.thumbnailUrl != null && message.thumbnailUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(message.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: message.thumbnailUrl == null || message.thumbnailUrl!.isEmpty ? Icon(Icons.videocam, color: Colors.grey[600]) : null,
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 128),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '视频',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        );

      case MessageType.file:
        return Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.insert_drive_file, color: Colors.grey[600]),
            ),
            const SizedBox(width: 10),
            Expanded(child: textWidget),
          ],
        );

      default:
        return textWidget;
    }
  }

  // 获取高亮显示的文本
  Widget _getHighlightedText(Message message) {
    final searchQuery = _searchController.text.toLowerCase();
    String content = '';

    if (message.type == MessageType.text) {
      content = message.text ?? '';
    } else if (message.type == MessageType.file) {
      content = message.fileName ?? '';
    }

    if (searchQuery.isEmpty || content.isEmpty) {
      return Text(
        content,
        style: TextStyle(fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final List<TextSpan> spans = [];
    final lowerContent = content.toLowerCase();
    int start = 0;

    // 查找所有匹配项,并构建TextSpan列表
    while (true) {
      final index = lowerContent.indexOf(searchQuery, start);
      if (index == -1) {
        // 添加剩余部分
        if (start < content.length) {
          spans.add(TextSpan(
            text: content.substring(start),
            style: TextStyle(fontSize: 14),
          ));
        }
        break;
      }

      // 添加不匹配部分
      if (index > start) {
        spans.add(TextSpan(
          text: content.substring(start, index),
          style: TextStyle(fontSize: 14),
        ));
      }

      // 添加匹配部分（高亮）
      spans.add(TextSpan(
        text: content.substring(index, index + searchQuery.length),
        style: TextStyle(
          fontSize: 14,
          color: Colors.green,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.green[50],
        ),
      ));

      // 更新起始点
      start = index + searchQuery.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // 格式化时间部分
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      return time; // 今天只显示时间
    } else if (messageDate == yesterday) {
      return '昨天 $time'; // 昨天
    } else if (now.difference(dateTime).inDays < 7) {
      // 一周内显示星期几
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return '${weekdays[dateTime.weekday % 7]} $time';
    } else {
      // 超过一周显示完整日期
      return '${dateTime.month}月${dateTime.day}日 $time';
    }
  }
}
