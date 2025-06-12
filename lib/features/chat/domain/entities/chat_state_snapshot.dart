import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';

/// 会话状态快照
///
/// 用于在用户快速切换会话时保存和恢复聊天状态
/// 避免重新加载数据，提升用户体验
class ChatStateSnapshot {
  /// 消息列表
  final List<Message> messages;

  /// 滚动位置（像素）
  final CurrentScrollPosition? currentScrollPosition;

  const ChatStateSnapshot({
    required this.messages,
    this.currentScrollPosition,
  });

  /// 检查快照是否仍然有效（5分钟内）
  bool get isValid {
    return DateTime.now().difference(DateTime.now()).inMinutes < 5;
  }

  /// 获取快照年龄（秒）
  int get ageInSeconds {
    return DateTime.now().difference(DateTime.now()).inSeconds;
  }

  /// 复制快照并更新字段
  ChatStateSnapshot copyWith({
    List<Message>? messages,
    CurrentScrollPosition? currentScrollPosition,
  }) {
    return ChatStateSnapshot(
      messages: messages ?? this.messages,
      currentScrollPosition:
          currentScrollPosition ?? this.currentScrollPosition,
    );
  }

  @override
  String toString() {
    return 'ChatStateSnapshot{messageCount: ${messages.length}, currentScrollPosition: $currentScrollPosition, age: ${ageInSeconds}s}';
  }
}
