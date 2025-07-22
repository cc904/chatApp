/// 快捷回复数据模型（简化版）
class QuickReply {
  /// ID
  final int id;

  /// 回复内容
  final String content;

  /// 分类标签 (如: 问候、道歉、解决方案等)
  final String category;

  /// 显示顺序
  final int order;

  /// 是否启用
  final bool isEnabled;

  const QuickReply({
    required this.id,
    required this.content,
    required this.category,
    this.order = 0,
    this.isEnabled = true,
  });

  /// 转换为JSON（本地缓存用）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category': category,
      'order': order,
      'isEnabled': isEnabled,
    };
  }

  /// 从JSON创建（本地存储格式）
  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'],
      content: json['content'],
      category: json['category'],
      order: json['order'] ?? 0,
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  /// 从服务器JSON创建
  factory QuickReply.fromServerJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'],
      content: json['content'],
      category: json['category'],
      order: json['order_index'] ?? 0,
      isEnabled: json['is_enabled'] ?? true,
    );
  }
}

/// 快捷回复分类
enum QuickReplyCategory {
  greeting('问候'),
  apology('道歉'),
  solution('解决方案'),
  information('信息提供'),
  closing('结束语'),
  common('常用');

  const QuickReplyCategory(this.displayName);
  final String displayName;
}