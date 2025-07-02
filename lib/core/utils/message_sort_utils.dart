import 'package:cc/core/database/models/message.dart';

/// 消息排序工具类
///
/// 提供统一的消息排序方法，处理临时消息（messageIndex = 0）的特殊排序需求
///
/// ## 排序规则
/// 1. **临时消息优先**：messageIndex = 0 的消息排在最前面
/// 2. **时间排序**：临时消息之间按创建时间降序排列（最新的在前）
/// 3. **正常排序**：非临时消息按 messageIndex 降序排列
/// 4. **辅助排序**：相同 messageIndex 时按创建时间排序
///
/// ## 数据库查询与内存排序结合使用
///
/// **重要提示：** 由于数据库不理解我们的特殊排序规则（临时消息 messageIndex = 0 优先），
/// 建议的最佳实践是：
///
/// ### 1. 数据库查询阶段
/// ```dart
/// // 在数据库查询时，先按 messageIndex 降序排序（这样正常消息是正确顺序）
/// final messages = await queryBuilder
///   .sortByMessageIndexDesc()  // 数据库层面排序
///   .findAll();
/// ```
///
/// ### 2. 内存排序阶段
/// ```dart
/// // 查询完成后，在内存中使用我们的排序规则重新排序
/// MessageSortUtils.sortForDisplay(messages);
/// ```
///
/// ### 3. 为什么需要两阶段排序？
/// - **数据库排序**：确保大部分正常消息已经是正确顺序，提高查询效率
/// - **内存排序**：处理临时消息（messageIndex = 0）的特殊位置需求
/// - **性能优化**：避免数据库返回完全无序的数据，减少内存排序负担
///
/// ### 4. 适用场景
/// - ✅ 聊天消息列表显示
/// - ✅ 搜索结果展示
/// - ✅ 消息历史记录
/// - ✅ 任何需要显示消息列表的地方
class MessageSortUtils {
  MessageSortUtils._(); // 私有构造函数，防止实例化

  /// 🎯 主要排序方法：用于聊天界面显示
  ///
  /// 排序规则：
  /// 1. messageIndex = 0（临时消息）排在最前面
  /// 2. 临时消息之间按创建时间降序排列（最新的在前）
  /// 3. 正常消息按 messageIndex 降序排列（大数值在前）
  /// 4. messageIndex 相同时按创建时间降序排列
  ///
  /// 使用场景：
  /// - 聊天页面消息列表显示
  /// - 搜索结果展示
  /// - 消息合并后的排序
  static int compareForDisplay(Message a, Message b) {
    // 如果 a 是临时消息，b 不是临时消息，a 排在前面
    if (a.messageIndex == 0 && b.messageIndex != 0) {
      return -1;
    }

    // 如果 b 是临时消息，a 不是临时消息，b 排在前面
    if (a.messageIndex != 0 && b.messageIndex == 0) {
      return 1;
    }

    // 如果都是临时消息，按创建时间降序排列（最新的在前）
    if (a.messageIndex == 0 && b.messageIndex == 0) {
      return b.createdAt.compareTo(a.createdAt);
    }

    // 如果都不是临时消息，按 messageIndex 降序排列
    final indexComparison = b.messageIndex.compareTo(a.messageIndex);
    if (indexComparison != 0) {
      return indexComparison;
    }

    // messageIndex 相同时，按创建时间降序排列
    return b.createdAt.compareTo(a.createdAt);
  }

  /// 🔄 历史排序方法：用于历史消息加载场景
  ///
  /// 排序规则：
  /// 1. 正常消息按 messageIndex 升序排列（小数值在前）
  /// 2. 临时消息排在最后
  /// 3. messageIndex 相同时按创建时间升序排列
  ///
  /// 使用场景：
  /// - 历史消息分页加载
  /// - 向上滚动加载更多消息
  /// - 按时间顺序展示历史记录
  static int compareForHistory(Message a, Message b) {
    // 如果 a 是临时消息，b 不是临时消息，a 排在后面
    if (a.messageIndex == 0 && b.messageIndex != 0) {
      return 1;
    }

    // 如果 b 是临时消息，a 不是临时消息，a 排在前面
    if (a.messageIndex != 0 && b.messageIndex == 0) {
      return -1;
    }

    // 如果都是临时消息，按创建时间升序排列
    if (a.messageIndex == 0 && b.messageIndex == 0) {
      return a.createdAt.compareTo(b.createdAt);
    }

    // 如果都不是临时消息，按 messageIndex 升序排列
    final indexComparison = a.messageIndex.compareTo(b.messageIndex);
    if (indexComparison != 0) {
      return indexComparison;
    }

    // messageIndex 相同时，按创建时间升序排列
    return a.createdAt.compareTo(b.createdAt);
  }

  /// 📋 便捷方法：对消息列表进行显示排序
  ///
  /// 直接对传入的消息列表进行就地排序，用于聊天界面显示
  ///
  /// Example:
  /// ```dart
  /// List<Message> messages = [...];
  /// MessageSortUtils.sortForDisplay(messages);
  /// // messages 现在已按显示顺序排序
  /// ```
  static void sortForDisplay(List<Message> messages) {
    messages.sort(compareForDisplay);
  }

  /// 📜 便捷方法：对消息列表进行历史排序
  ///
  /// 直接对传入的消息列表进行就地排序，用于历史记录展示
  ///
  /// Example:
  /// ```dart
  /// List<Message> messages = [...];
  /// MessageSortUtils.sortForHistory(messages);
  /// // messages 现在已按历史顺序排序
  /// ```
  static void sortForHistory(List<Message> messages) {
    messages.sort(compareForHistory);
  }

  /// 📊 获取排序后的新列表：显示排序
  ///
  /// 返回一个新的已排序列表，不修改原列表
  ///
  /// Example:
  /// ```dart
  /// List<Message> original = [...];
  /// List<Message> sorted = MessageSortUtils.getSortedForDisplay(original);
  /// // original 保持不变，sorted 是新的排序列表
  /// ```
  static List<Message> getSortedForDisplay(List<Message> messages) {
    final List<Message> sorted = List<Message>.from(messages);
    sorted.sort(compareForDisplay);
    return sorted;
  }

  /// 📜 获取排序后的新列表：历史排序
  ///
  /// 返回一个新的已排序列表，不修改原列表
  ///
  /// Example:
  /// ```dart
  /// List<Message> original = [...];
  /// List<Message> sorted = MessageSortUtils.getSortedForHistory(original);
  /// // original 保持不变，sorted 是新的排序列表
  /// ```
  static List<Message> getSortedForHistory(List<Message> messages) {
    final List<Message> sorted = List<Message>.from(messages);
    sorted.sort(compareForHistory);
    return sorted;
  }

  /// 🔍 调试方法：验证排序结果是否正确
  ///
  /// 检查给定的消息列表是否已按显示规则正确排序
  /// 返回验证结果和错误信息
  ///
  /// Example:
  /// ```dart
  /// List<Message> messages = [...];
  /// final result = MessageSortUtils.validateDisplaySort(messages);
  /// if (!result.isValid) {
  ///   print('排序错误：${result.errors}');
  /// }
  /// ```
  static ValidationResult validateDisplaySort(List<Message> messages) {
    final errors = <String>[];

    for (int i = 0; i < messages.length - 1; i++) {
      final current = messages[i];
      final next = messages[i + 1];

      // 检查临时消息是否在正常消息前面
      if (current.messageIndex != 0 && next.messageIndex == 0) {
        errors.add('位置 $i: 临时消息应该在正常消息前面');
      }

      // 检查临时消息内部排序
      if (current.messageIndex == 0 && next.messageIndex == 0) {
        if (current.createdAt.isBefore(next.createdAt)) {
          errors.add('位置 $i: 临时消息时间排序错误');
        }
      }

      // 检查正常消息内部排序
      if (current.messageIndex != 0 && next.messageIndex != 0) {
        if (current.messageIndex < next.messageIndex) {
          errors.add('位置 $i: 正常消息 messageIndex 排序错误');
        }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 🔗 获取连续消息段：基于messageIndex连续性
  ///
  /// 找出与指定锚点messageIndex最接近的连续消息段
  /// 连续性定义：messageIndex值连续递增，中间没有缺失
  ///
  /// 算法步骤：
  /// 1. 如果anchorMessageIndex <= 0，自动使用消息列表中最大的messageIndex作为锚点
  /// 2. 在消息列表中找到指定anchorMessageIndex的消息
  /// 3. 从锚点位置向前扩展，检查messageIndex是否连续递减
  /// 4. 从锚点位置向后扩展，检查messageIndex是否连续递增
  /// 5. 返回包含锚点的完整连续段
  ///
  /// Example:
  /// ```dart
  /// // 消息列表的messageIndex: [98, 99, 100, 101, 102, 105, 106]
  /// // 锚点messageIndex: 101
  /// List<Message> messages = [...];
  /// List<Message> continuous = MessageSortUtils.getContinuousMessagesAroundAnchor(messages, 101);
  /// // 返回messageIndex为[99, 100, 101, 102]的消息列表
  ///
  /// // 特殊情况：锚点 <= 0 时自动使用最大值
  /// List<Message> continuous2 = MessageSortUtils.getContinuousMessagesAroundAnchor(messages, 0);
  /// // 自动使用106作为锚点，返回messageIndex为[105, 106]的消息列表
  /// ```
  ///
  /// 参数：
  /// - [messages] 消息列表（应该已按messageIndex排序）
  /// - [anchorMessageIndex] 锚点消息的messageIndex值，如果 <= 0 则使用最大值
  ///
  /// 返回：
  /// - 包含锚点的连续消息段，如果找不到锚点则返回空列表
  static List<Message> getContinuousMessagesAroundAnchor(
    List<Message> messages,
    int anchorMessageIndex,
  ) {
    // 检查消息列表是否为空
    if (messages.isEmpty) {
      return <Message>[];
    }

    // 如果锚点messageIndex <= 0，使用消息列表中最大的messageIndex作为锚点
    if (anchorMessageIndex <= 0) {
      int maxMessageIndex = 0;
      for (final message in messages) {
        if (message.messageIndex > maxMessageIndex) {
          maxMessageIndex = message.messageIndex;
        }
      }
      // 如果没有找到有效的messageIndex，返回空列表
      if (maxMessageIndex <= 0) {
        return <Message>[];
      }
      // 使用最大messageIndex作为新的锚点
      anchorMessageIndex = maxMessageIndex;
    }

    // 查找锚点消息的位置
    int anchorPosition = -1;
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.messageIndex == anchorMessageIndex) {
        anchorPosition = i;
        break;
      }
    }

    // 如果找不到锚点消息，返回空列表
    if (anchorPosition == -1) {
      return <Message>[];
    }

    // 向前扩展：查找连续的较小messageIndex
    int startPosition = anchorPosition;
    for (int i = anchorPosition - 1; i >= 0; i--) {
      final currentMessage = messages[i];
      final nextMessage = messages[i + 1];

      // 检查是否连续（当前消息的messageIndex应该等于下一条消息的messageIndex-1）
      if (currentMessage.messageIndex == nextMessage.messageIndex - 1) {
        startPosition = i;
      } else {
        break; // 不连续，停止向前扩展
      }
    }

    // 向后扩展：查找连续的较大messageIndex
    int endPosition = anchorPosition;
    for (int i = anchorPosition + 1; i < messages.length; i++) {
      final currentMessage = messages[i];
      final prevMessage = messages[i - 1];

      // 检查是否连续（当前消息的messageIndex应该等于前一条消息的messageIndex+1）
      if (currentMessage.messageIndex == prevMessage.messageIndex + 1) {
        endPosition = i;
      } else {
        break; // 不连续，停止向后扩展
      }
    }

    // 返回连续消息段
    return messages.sublist(startPosition, endPosition + 1);
  }
}

/// 排序验证结果
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
}
