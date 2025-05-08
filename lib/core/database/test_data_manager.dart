import 'dart:io';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/core/database/test_data_generator.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// 测试数据管理器
///
/// 负责管理独立的测试数据库，与用户数据完全隔离。
/// 提供测试数据的初始化、查询和搜索功能。
class TestDataManager {
  static final _logger = LogService('TestDataManager');
  static late Isar _testIsar;
  static bool _isInitialized = false;

  /// 测试数据库的Isar实例
  static Isar get testIsar {
    if (!_isInitialized) {
      throw 'TestDataManager未初始化，请先调用init()方法';
    }
    return _testIsar;
  }

  /// 是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 初始化测试数据库
  ///
  /// 这个方法会：
  /// 1. 获取应用文档目录
  /// 2. 创建并初始化testData.isar数据库
  /// 3. 如果generateIfEmpty为true且数据库为空，则生成测试数据
  static Future<void> init({bool generateIfEmpty = true}) async {
    if (_isInitialized) {
      _logger.i('TestDataManager已经初始化，无需重复操作');
      return;
    }

    try {
      _logger.i('正在初始化测试数据库...');
      final dir = await getApplicationDocumentsDirectory();

      _testIsar = await Isar.open(
        [
          MyUserSchema,
          UserSchema,
          ConversationSchema,
          MessageSchema,
        ],
        directory: dir.path,
        name: 'testData',
        inspector: true,
      );

      _isInitialized = true;
      _logger.i('测试数据库初始化成功: ${dir.path}/testData.isar');

      // 检查是否需要生成测试数据
      if (generateIfEmpty) {
        final contactCount = await _testIsar.users.count();
        if (contactCount == 0) {
          _logger.i('测试数据库为空，开始生成测试数据...');
          await TestDataGenerator.generateTestData();
        }
      }
    } catch (e) {
      _logger.e('初始化测试数据库失败', error: e);
      rethrow;
    }
  }

  /// 关闭测试数据库连接
  static Future<void> close() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _testIsar.close();
      _isInitialized = false;
      _logger.i('测试数据库连接已关闭');
    } catch (e) {
      _logger.e('关闭测试数据库连接失败', error: e);
    }
  }

  /// 清空测试数据库
  static Future<void> clearAll() async {
    if (!_isInitialized) {
      await init(generateIfEmpty: false);
    }

    try {
      await _testIsar.writeTxn(() async {
        await _testIsar.messages.clear();
        await _testIsar.conversations.clear();
        await _testIsar.users.clear();
        await _testIsar.myUsers.clear();
      });
      _logger.i('已清空测试数据库');
    } catch (e) {
      _logger.e('清空测试数据库失败', error: e);
    }
  }

  /// 重新生成测试数据
  ///
  /// 这个方法会：
  /// 1. 清空现有的测试数据
  /// 2. 生成新的测试数据
  static Future<void> regenerateTestData() async {
    if (!_isInitialized) {
      await init(generateIfEmpty: false);
    }

    try {
      await clearAll();
      await TestDataGenerator.generateTestData();
      _logger.i('已重新生成测试数据');
    } catch (e) {
      _logger.e('重新生成测试数据失败', error: e);
    }
  }

  /// 获取所有测试联系人
  static Future<List<User>> getAllTestContacts() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _testIsar.users.where().sortByName().findAll();
    } catch (e) {
      _logger.e('获取测试联系人失败', error: e);
      return [];
    }
  }

  /// 根据ID获取测试联系人
  static Future<User?> getTestContactById(String userId) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _testIsar.users.where().filter().userIdEqualTo(userId).findFirst();
    } catch (e) {
      _logger.e('根据ID获取测试联系人失败', error: e);
      return null;
    }
  }

  /// 搜索测试联系人
  static Future<List<User>> searchTestContacts(String keyword) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      if (keyword.isEmpty) {
        return await getAllTestContacts();
      }

      return await _testIsar.users
          .where()
          .filter()
          .nameContains(keyword, caseSensitive: false)
          .or()
          .phoneContains(keyword)
          .or()
          .pinyinContains(keyword, caseSensitive: false)
          .findAll();
    } catch (e) {
      _logger.e('搜索测试联系人失败', error: e);
      return [];
    }
  }

  /// 获取所有测试会话
  static Future<List<Conversation>> getAllTestConversations() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _testIsar.conversations.where().sortByCreatedAtDesc().findAll();
    } catch (e) {
      _logger.e('获取测试会话失败', error: e);
      return [];
    }
  }

  /// 获取测试会话消息
  static Future<List<Message>> getTestMessages(String conversationId, {int limit = 50}) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      return await _testIsar.messages.where().filter().conversationIdEqualTo(conversationId).sortByCreatedAtDesc().limit(limit).findAll();
    } catch (e) {
      _logger.e('获取测试会话消息失败', error: e);
      return [];
    }
  }

  /// 获取测试数据库文件大小
  static Future<int> getTestDatabaseSize() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/testData.isar');
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      _logger.e('获取测试数据库大小失败', error: e);
      return 0;
    }
  }
}
