import 'search_page.dart';
import 'scan_code_page.dart';
import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/core/database/database_initializer.dart';

/// 消息页面
///
/// 显示所有聊天会话列表，是应用程序的主要入口页面之一
/// 包含搜索、筛选和新建聊天等核心功能
class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  /// 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  /// 日志服务实例
  final _logger = LogService.instance;

  /// 是否处于搜索状态
  bool _isSearching = false;

  /// 是否正在加载数据
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 会话列表数据
  List<Conversation> _conversations = [];

  /// 联系人列表数据
  List<User> _contacts = [];

  /// 当前打开的滑动菜单项ID
  String? _openedItemId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载会话和联系人数据
  ///
  /// 从数据库获取会话列表和相关联系人信息
  /// 设置加载状态并处理可能的错误
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 使用repository加载数据
      if (!DatabaseInitializer.isInitialized) {
        throw Exception('数据库未初始化');
      }
      
      final currentUserId = DatabaseInitializer.currentUserId ?? '';
      final isar = DatabaseInitializer.isar;
      
      // 创建仓库实例
      final chatRepository = ChatRepositoryImpl(
        isar: isar, 
        currentUserId: currentUserId
      );
      
      // 获取所有会话
      final conversations = await chatRepository.getAllConversations();
      
      // 获取联系人信息
      final List<User> contacts = [];
      for (final conversation in conversations) {
        if (conversation.contactUserId != null) {
          final contact = await chatRepository.getContactById(conversation.contactUserId!);
          if (contact != null && !contacts.contains(contact)) {
            contacts.add(contact);
          }
        }
      }
      
      setState(() {
        _conversations = conversations;
        _contacts = contacts;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 搜索会话
  ///
  /// 根据输入的查询文本搜索匹配的会话
  /// 如果查询为空，则重新加载所有会话
  ///
  /// 参数:
  ///   - query: 搜索关键词
  Future<void> _searchConversations(String query) async {
    if (query.isEmpty) {
      await _loadData();
      return;
    }

    try {
      // TODO: 实现搜索逻辑
      setState(() {
        _conversations = []; // 替换为搜索结果
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('ChatsPage build');
    return Scaffold(
      // AppBar: 自定义导航栏,包含标题、编辑按钮和新建聊天按钮
      // 顶部导航区配置了底部搜索栏作为扩展部分
      appBar: AppBar(
        // 中间标题
        title: const Text('消息', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 禁用默认返回按钮

        // 左侧筛选按钮
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),

        // 右侧操作按钮区域 - 添加新聊天按钮
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              // 设置弹出菜单的主题
              popupMenuTheme: const PopupMenuThemeData(
                // 强制控制菜单的宽度
                textStyle: TextStyle(fontSize: 14),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              offset: const Offset(0, 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              // 设置菜单的总宽度
              constraints: const BoxConstraints(maxWidth: 145),
              // 修改菜单位置
              position: PopupMenuPosition.under,
              // 调整项目宽度自适应内容
              onSelected: (value) {
                if (value == 'scan') {
                  // 扫一扫功能
                  _logger.d('打开扫一扫');
                  _openQRScanner(context);
                } else if (value == 'group') {
                  // 发起群聊
                  _logger.d('发起群聊');
                  // 打开搜索页面,默认选择找群标签
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                } else if (value == 'friend') {
                  // 添加朋友
                  _logger.d('添加朋友');
                  // 打开搜索页面,默认选择找人标签
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                _buildMenuItem('friend', Icons.person_add, '添加朋友或群'),
                const PopupMenuDivider(height: 0.5),
                _buildMenuItem('group', Icons.group_add, '发起群聊'),
                const PopupMenuDivider(height: 0.5),
                _buildMenuItem('scan', Icons.qr_code_scanner, '扫一扫'),
              ],
            ),
          ),
        ],
        centerTitle: true, // 标题居中显示

        // 底部搜索区域
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50), // 设置底部区域高度
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '搜索',
                hintStyle: const TextStyle(color: Colors.grey),
                // 删除搜索图标
                prefixIcon: null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                isDense: true,
                // 因为删除了外层Container,需要添加圆角和背景颜色
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
                // 当有输入内容时显示清除按钮和搜索按钮
                suffixIcon: _isSearching
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.grey, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isSearching = false;
                              });
                              _loadData();
                            },
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: Colors.grey[300],
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                // 执行搜索
                                final query = _searchController.text;
                                if (query.isNotEmpty) {
                                  _searchConversations(query);
                                }
                                // 隐藏键盘
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '搜索',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                });
                // 搜索内容变化时实时搜索
                if (value.isNotEmpty) {
                  _searchConversations(value);
                }
              },
            ),
          ),
        ),
      ),
      // 聊天列表主体
      body: GestureDetector(
        // 点击空白区域时关闭打开的滑动菜单
        onTap: () {
          if (_openedItemId != null) {
            setState(() {
              _openedItemId = null;
            });
          }
        },
        child: _buildChatList(),
      ),
    );
  }

  /// 构建聊天列表
  ///
  /// 根据当前状态(加载中/错误/空数据)构建不同的界面
  /// 正常状态下显示会话列表，每个项目显示联系人头像、名称、最后消息和时间
  ///
  /// 返回值:
  ///   - Widget: 构建的列表视图或状态提示视图
  Widget _buildChatList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('错误: $_error'));
    }

    if (_conversations.isEmpty) {
      return const Center(child: Text('没有会话'));
    }

    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        final contact = _contacts.firstWhere(
          (c) => c.userId == conversation.contactUserId,
          orElse: () => User()..name = '未知用户',
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                contact.avatar != null ? NetworkImage(contact.avatar!) : null,
            child: contact.avatar == null ? Text(contact.name[0]) : null,
          ),
          title: Text(contact.name),
          subtitle: Text(conversation.lastMessagePreview ?? ''),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(conversation.lastMessageTime),
                style: const TextStyle(fontSize: 12),
              ),
              if (conversation.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  conversationId: conversation.conversationId,
                  contact: contact,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 格式化消息时间
  ///
  /// 将时间戳转换为用户友好的显示格式:
  /// - 今天的消息显示时:分
  /// - 昨天的消息显示"昨天"
  /// - 一周内的消息显示"x天前"
  /// - 更早的消息显示月/日
  ///
  /// 参数:
  ///   - time: 需要格式化的时间
  ///
  /// 返回值:
  ///   - String: 格式化后的时间字符串
  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  /// 显示筛选对话框
  ///
  /// 弹出底部模态对话框，提供会话筛选选项:
  /// - 筛选未读消息
  /// - 筛选群聊
  /// - 筛选星标会话
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '筛选会话',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('未读消息'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选未读消息');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('群聊'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选群聊');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.green),
              title: const Text('星标会话'),
              onTap: () {
                Navigator.pop(context);
                _logger.d('筛选星标会话');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 打开二维码扫描页面
  ///
  /// 导航到扫码页面，用于扫描二维码添加好友或加入群聊
  ///
  /// 参数:
  ///   - context: 当前构建上下文
  void _openQRScanner(BuildContext context) {
    // 导航到二维码扫描页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScanCodePage(),
      ),
    );
  }

  /// 构建弹出菜单项
  ///
  /// 创建自定义样式的PopupMenuItem，用于添加功能菜单
  ///
  /// 参数:
  ///   - value: 菜单项的值，用于标识被选中的项
  ///   - iconData: 菜单项的图标
  ///   - label: 菜单项的文本标签
  ///
  /// 返回值:
  ///   - PopupMenuItem<String>: 构建的菜单项
  PopupMenuItem<String> _buildMenuItem(
      String value, IconData iconData, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
