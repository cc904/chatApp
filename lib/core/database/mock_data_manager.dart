import 'dart:io';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/database/mock_data_generator.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// 模拟数据管理器
///
/// 负责管理独立的模拟数据库，与用户数据完全隔离。
/// 提供模拟数据的初始化、查询和搜索功能。
class MockDataManager {
  static final _logger = LogService('MockDataManager');
  static late Isar _mockIsar;
  static bool _isInitialized = false;

  /// 模拟数据库的Isar实例
  static Isar get mockIsar {
    if (!_isInitialized) {
      throw 'MockDataManager未初始化，请先调用init()方法';
    }
    return _mockIsar;
  }

  /// 是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 初始化模拟数据库
  ///
  /// 这个方法会：
  /// 1. 获取应用文档目录
  /// 2. 创建并初始化mockdata.isar数据库
  /// 3. 根据isSimulationMode决定是否生成模拟数据
  static Future<void> init() async {
    if (_isInitialized) {
      _logger.i('模拟数据管理器已经初始化，无需重复操作');
      return;
    }

    try {
      _logger.i('正在初始化模拟数据库...');
      final dir = await getApplicationDocumentsDirectory();

      _mockIsar = await Isar.open(
        [
          MyUserSchema,
          UserSchema,
          ConversationSchema,
          MessageSchema,
        ],
        directory: dir.path,
        name: 'mockdata',
        inspector: true,
      );

      _isInitialized = true;
      _logger.i('模拟数据库初始化成功: ${dir.path}/mockdata.isar');

      // 检查是否需要生成模拟数据
      final appConfig = AppConfig();
      if (appConfig.isSimulationMode) {
        final contactCount = await _mockIsar.users.count();
        if (contactCount == 0) {
          _logger.i('模拟数据库为空，开始生成模拟数据...');
          await MockDataGenerator.generateMockData();
        }
      }
    } catch (e) {
      _logger.e('初始化模拟数据库失败', error: e);
      rethrow;
    }
  }

  /// 关闭模拟数据库连接
  static Future<void> close() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _mockIsar.close();
      _isInitialized = false;
      _logger.i('模拟数据库连接已关闭');
    } catch (e) {
      _logger.e('关闭模拟数据库连接失败', error: e);
    }
  }

  /// 清空模拟数据库
  static Future<void> clearAll() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await _mockIsar.writeTxn(() async {
        await _mockIsar.messages.clear();
        await _mockIsar.conversations.clear();
        await _mockIsar.users.clear();
        await _mockIsar.myUsers.clear();
      });
      _logger.i('已清空模拟数据库');
    } catch (e) {
      _logger.e('清空模拟数据库失败', error: e);
    }
  }

  /// 重新生成模拟数据
  ///
  /// 这个方法会：
  /// 1. 清空现有的模拟数据
  /// 2. 生成新的模拟数据
  static Future<void> regenerateMockData() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await clearAll();
      await MockDataGenerator.generateMockData();
      _logger.i('已重新生成模拟数据');
    } catch (e) {
      _logger.e('重新生成模拟数据失败', error: e);
    }
  }

  /// 获取所有模拟联系人
  static Future<List<User>> getAllMockContacts() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _mockIsar.users.where().sortByName().findAll();
    } catch (e) {
      _logger.e('获取模拟联系人失败', error: e);
      return [];
    }
  }

  /// 根据ID获取模拟联系人
  static Future<User?> getMockContactById(String userId) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _mockIsar.users.where().filter().userIdEqualTo(userId).findFirst();
    } catch (e) {
      _logger.e('根据ID获取模拟联系人失败', error: e);
      return null;
    }
  }

  /// 搜索模拟联系人
  static Future<List<User>> searchMockContacts(String keyword) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      if (keyword.isEmpty) {
        return await getAllMockContacts();
      }

      return await _mockIsar.users
          .where()
          .filter()
          .nameContains(keyword, caseSensitive: false)
          .or()
          .phoneContains(keyword)
          .or()
          .pinyinContains(keyword, caseSensitive: false)
          .findAll();
    } catch (e) {
      _logger.e('搜索模拟联系人失败', error: e);
      return [];
    }
  }

  /// 获取所有模拟会话
  static Future<List<Conversation>> getAllMockConversations() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _mockIsar.conversations.where().sortByCreatedAtDesc().findAll();
    } catch (e) {
      _logger.e('获取模拟会话失败', error: e);
      return [];
    }
  }

  /// 获取模拟会话消息
  static Future<List<Message>> getMockMessages(String conversationId, {int limit = 50}) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _mockIsar.messages.where().filter().conversationIdEqualTo(conversationId).sortByCreatedAtDesc().limit(limit).findAll();
    } catch (e) {
      _logger.e('获取模拟会话消息失败', error: e);
      return [];
    }
  }

  /// 获取模拟数据库文件大小
  static Future<int> getMockDatabaseSize() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/mockdata.isar');
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      _logger.e('获取模拟数据库大小失败', error: e);
      return 0;
    }
  }
}
