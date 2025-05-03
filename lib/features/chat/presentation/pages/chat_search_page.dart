import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/core/database/database_initializer.dart'; // 添加导入数据库初始化器
import 'package:isar/isar.dart'; // 添加导入Isar数据库

// 定义过滤类型枚举
enum FilterType {
  all,
  text,
  media, // 合并图片和视频
  file,
  date, // 选择日期
  month, // 最近一个月
  year, // 最近一年
}

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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Message> _searchResults = [];
  bool _isSearching = false;

  // 添加过滤状态
  FilterType _currentFilter = FilterType.all;
  List<Message> _allMessages = []; // 所有消息的缓存

  // 修改为单个日期
  DateTime? _selectedDate;

  // 有消息记录的日期集合
  Set<DateTime> _messageDates = {};

  @override
  void initState() {
    super.initState();
    // 自动聚焦到搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FocusScope.of(context).requestFocus(_searchFocusNode);
      // 预加载所有消息
      _loadAllMessages();
      // 预加载有消息的日期 - 使用异步方法
      await _loadMessageDates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 加载所有消息
  void _loadAllMessages() {
    final chatCubit = context.read<ChatCubit>();
    _allMessages = chatCubit.state.messagesByConversation[widget.conversationId] ?? [];

    // 按时间倒序排序
    _allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 加载所有有消息的日期 - 直接从数据库获取唯一日期
  Future<void> _loadMessageDates() async {
    try {
      // 显示日志
      dev.log('开始加载所有消息日期...');

      // 直接从数据库获取所有消息的唯一日期
      final Isar db = DatabaseInitializer.isar;

      // 获取此会话所有消息
      final allMessages = await db.messages.filter().conversationIdEqualTo(widget.conversationId).findAll();

      // 提取所有唯一日期
      Set<DateTime> dates = {};
      for (var message in allMessages) {
        // 转换为日期（只保留年月日）
        final date = DateTime(
          message.createdAt.year,
          message.createdAt.month,
          message.createdAt.day,
        );
        dates.add(date);
      }

      // 显示找到的日期数量
      dev.log('找到 ${dates.length} 个唯一日期');

      if (mounted) {
        setState(() {
          _messageDates = dates;
        });
      }
    } catch (e) {
      dev.log('直接从数据库加载消息日期失败: $e');
    }
  }

  // 检查指定日期是否有消息
  bool _hasMessagesOnDate(DateTime date) {
    // 提取日期部分（去掉时间）
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _messageDates.contains(dateOnly);
  }

  // 执行搜索
  void _performSearch(String query) {
    if (query.trim().isEmpty && _currentFilter == FilterType.all) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // 获取会话中的所有消息（如果未预加载）
    if (_allMessages.isEmpty) {
      _loadAllMessages();
    }

    // 先应用过滤器
    var filteredMessages = _applyFilter(_allMessages);

    // 再应用搜索文本
    if (query.trim().isNotEmpty) {
      final searchQuery = query.toLowerCase();
      filteredMessages = filteredMessages.where((message) {
        // 文本消息搜索内容
        if (message.type == MessageType.text) {
          return message.text?.toLowerCase().contains(searchQuery) ?? false;
        }
        // 文件消息搜索文件名
        else if (message.type == MessageType.file) {
          return message.fileName?.toLowerCase().contains(searchQuery) ?? false;
        }
        return false;
      }).toList();
    }

    setState(() {
      _searchResults = filteredMessages;
      _isSearching = false;
    });
  }

  // 应用过滤器
  List<Message> _applyFilter(List<Message> messages) {
    switch (_currentFilter) {
      case FilterType.all:
        return messages;

      case FilterType.text:
        return messages.where((m) => m.type == MessageType.text).toList();

      case FilterType.media:
        // 合并图片和视频
        return messages.where((m) => m.type == MessageType.image || m.type == MessageType.video).toList();

      case FilterType.file:
        return messages.where((m) => m.type == MessageType.file).toList();

      case FilterType.date:
        // 日期过滤
        if (_selectedDate == null) {
          return messages;
        }

        final startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
        final endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);

        return messages
            .where((m) => m.createdAt.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && m.createdAt.isBefore(endOfDay.add(const Duration(seconds: 1))))
            .toList();

      case FilterType.month:
        // 最近一个月
        final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
        return messages.where((m) => m.createdAt.isAfter(oneMonthAgo)).toList();

      case FilterType.year:
        // 最近一年
        final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
        return messages.where((m) => m.createdAt.isAfter(oneYearAgo)).toList();
    }
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

  // 修改日期选择方法，使用自定义选择器并禁用没有消息的日期
  Future<void> _selectDate(BuildContext context) async {
    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('加载消息日期中...'),
              ),
            ],
          ),
        );
      },
    );

    try {
      // 强制重新加载所有日期 - 确保完整性
      await _loadMessageDates();

      // 如果没有找到任何日期，显示提示
      if (_messageDates.isEmpty) {
        // 关闭加载指示器
        Navigator.of(context).pop();

        // 显示没有消息的提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('未找到任何聊天记录')),
        );
        return;
      }

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 发生错误，关闭加载指示器并显示错误
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载消息日期失败: $e')),
        );
      }
      return;
    }

    // 使用自定义日期选择器，点击日期后直接跳转
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 350.0, // 限制最大宽度
            ),
            child: Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                ),
                dialogTheme: DialogTheme(
                  backgroundColor: Colors.white,
                ),
              ),
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '选择日期',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 320,
                        child: CalendarDatePicker(
                          initialDate: _findInitialDateWithMessages() ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          selectableDayPredicate: (DateTime day) {
                            // 只有有消息的日期才可选
                            return _hasMessagesOnDate(day);
                          },
                          onDateChanged: (date) {
                            // 点击日期后立即关闭对话框并跳转
                            Navigator.of(context).pop();
                            _jumpToChatAtDate(date);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 查找有消息的初始日期
  DateTime? _findInitialDateWithMessages() {
    if (_messageDates.isEmpty) return null;

    // 查找离今天最近的有消息的日期
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    // 如果今天有消息，则返回今天
    if (_messageDates.contains(todayDateOnly)) {
      return today;
    }

    // 按日期从近到远排序
    final sortedDates = _messageDates.toList()..sort((a, b) => b.compareTo(a)); // 降序排序

    return sortedDates.first; // 返回最近的一个日期
  }

  // 查找最接近所选日期的消息并跳转到聊天界面
  void _jumpToChatAtDate(DateTime date) {
    // 确保所有消息已加载
    if (_allMessages.isEmpty) {
      _loadAllMessages();
    }

    // 计算所选日期的开始和结束
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // 查找当天的消息
    final messagesOnDate =
        _allMessages.where((m) => m.createdAt.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && m.createdAt.isBefore(endOfDay.add(const Duration(seconds: 1)))).toList();

    Message? targetMessage;

    // 如果当天有消息，选择按时间排序的第一条作为目标
    if (messagesOnDate.isNotEmpty) {
      // 按时间顺序从早到晚排序（升序）
      messagesOnDate.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 选择当天的第一条消息
      targetMessage = messagesOnDate.first;
      dev.log('找到当日第一条消息: ${targetMessage.messageId}, 时间: ${targetMessage.createdAt}');
    } else {
      // 如果当天没有消息，找最接近的消息
      // 按与目标日期的时间差排序
      _allMessages.sort((a, b) {
        final diffA = (a.createdAt.difference(startOfDay)).abs();
        final diffB = (b.createdAt.difference(startOfDay)).abs();
        return diffA.compareTo(diffB);
      });

      // 选择时间最接近的
      if (_allMessages.isNotEmpty) {
        targetMessage = _allMessages.first;
        dev.log('找到最接近该日期的消息: ${targetMessage.messageId}, 时间: ${targetMessage.createdAt}');
      }
    }

    // 如果找到目标消息，跳转到聊天界面
    if (targetMessage != null) {
      dev.log('跳转到日期: ${date.toString()}, 消息ID: ${targetMessage.messageId}');
      Navigator.pop(context, targetMessage.messageId);
    } else {
      // 如果没有找到消息，直接返回，不显示提示
      Navigator.pop(context);
    }
  }

  // 格式化日期的显示
  String _formatDate() {
    if (_selectedDate == null) {
      return '日期';
    }

    // 格式化日期
    return '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日';
  }

  @override
  Widget build(BuildContext context) {
    // 获取主题颜色
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

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
            if (value.isEmpty && _currentFilter == FilterType.all) {
              setState(() {
                _searchResults = [];
              });
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
          // 添加过滤器按钮
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () => _showFilterMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 快速过滤器栏 - 移除白色背景
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 筛选按钮组
                  _buildFilterChip(FilterType.all, primaryColor),
                  _buildFilterChip(FilterType.date, primaryColor),
                  _buildFilterChip(FilterType.media, primaryColor),
                  _buildFilterChip(FilterType.file, primaryColor),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // 搜索中指示器
          if (_isSearching) const LinearProgressIndicator(),

          // 搜索结果
          Expanded(
            child: _searchResults.isEmpty
                ? _buildEmptyResults()
                : _currentFilter == FilterType.media
                    ? _buildMediaGrid()
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildSearchResultItem(_searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 构建过滤器芯片
  Widget _buildFilterChip(FilterType type, Color primaryColor) {
    final isSelected = _currentFilter == type;

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
                isSelected && _selectedDate != null ? _formatDate() : '日期',
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
        setState(() {
          _currentFilter = type;
        });
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

  // 显示过滤器菜单
  void _showFilterMenu(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '筛选条件',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),

              // 按消息类型筛选
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '消息类型',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterOption(FilterType.all, primaryColor, setModalState),
                  _buildFilterOption(FilterType.text, primaryColor, setModalState),
                  _buildFilterOption(FilterType.media, primaryColor, setModalState),
                  _buildFilterOption(FilterType.file, primaryColor, setModalState),
                ],
              ),

              const SizedBox(height: 16),

              // 按时间筛选
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '时间范围',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterOption(FilterType.date, primaryColor, setModalState),
                  _buildFilterOption(FilterType.month, primaryColor, setModalState),
                  _buildFilterOption(FilterType.year, primaryColor, setModalState),
                ],
              ),

              const SizedBox(height: 16),

              // 应用按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _performSearch(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '应用筛选',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建过滤器选项
  Widget _buildFilterOption(FilterType type, Color primaryColor, StateSetter setState) {
    final isSelected = _currentFilter == type;

    // 日期筛选器需要特殊处理
    if (type == FilterType.date) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8),
        child: InkWell(
          onTap: () async {
            await _selectDate(context);
            setState(() {});
            this.setState(() {});
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.date_range,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Text(
                  isSelected && _selectedDate != null ? _formatDate() : '日期',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentFilter = type;
          });
          this.setState(() {});
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFilterIcon(type),
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                _getFilterName(type),
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建空搜索结果
  Widget _buildEmptyResults() {
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
            _searchController.text.isEmpty && _currentFilter == FilterType.all ? '输入关键词开始搜索' : '未找到符合条件的消息',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (_currentFilter != FilterType.all)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _currentFilter == FilterType.date && _selectedDate != null ? '选择日期: ${_formatDate()}' : '当前筛选: ${_getFilterName(_currentFilter)}',
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
  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final message = _searchResults[index];
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
        dev.log('点击图片: ${message.messageId}');
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
        dev.log('点击视频: ${message.messageId}');
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
        dev.log('跳转到消息: ${message.messageId}');
        Navigator.pop(context, message.messageId);
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

    // 查找所有匹配项，并构建TextSpan列表
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
