import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/drift_database.dart';
import '../../data/repositories/quick_reply_repository.dart';

/// 快捷回复状态
class QuickReplyState extends Equatable {
  final List<QuickReply> quickReplies;
  final bool isLoading;
  final String? error;

  const QuickReplyState({
    this.quickReplies = const [],
    this.isLoading = false,
    this.error,
  });

  QuickReplyState copyWith({
    List<QuickReply>? quickReplies,
    bool? isLoading,
    String? error,
  }) {
    return QuickReplyState(
      quickReplies: quickReplies ?? this.quickReplies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [quickReplies, isLoading, error];
}

/// 快捷回复Cubit
class QuickReplyCubit extends Cubit<QuickReplyState> {
  final QuickReplyRepository _repository;

  QuickReplyCubit(this._repository) : super(const QuickReplyState());

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }

  /// 初始化快捷回复（从服务器同步）
  Future<void> initializeQuickReplies() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      
      // 从服务器同步数据
      final replies = await _repository.getAllQuickReplies();
      
      emit(state.copyWith(
        quickReplies: replies,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: '加载快捷回复失败: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  /// 强制刷新数据
  Future<void> refreshFromServer() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      
      final replies = await _repository.forceRefresh();
      
      emit(state.copyWith(
        quickReplies: replies,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: '刷新快捷回复失败: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  /// 获取最后同步时间
  Future<DateTime?> getLastSyncTime() async {
    return await _repository.getLastSyncTime();
  }

  /// 加载快捷回复
  Future<void> loadQuickReplies() async {
    try {
      emit(state.copyWith(isLoading: true));
      final replies = await _repository.getAllQuickReplies();
      emit(state.copyWith(
        quickReplies: replies,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  /// 按分类加载快捷回复
  Future<void> loadQuickRepliesByCategory(String category) async {
    try {
      emit(state.copyWith(isLoading: true));
      final replies = await _repository.getQuickRepliesByCategory(category);
      emit(state.copyWith(
        quickReplies: replies,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  /// 标记回复为已使用（简化版）
  void markReplyAsUsed(int id) {
    _repository.markReplyAsUsed(id);
    // 仅记录使用日志，不需要更新UI状态
  }

  /// 获取排序后的快捷回复（按分类和顺序）
  List<QuickReply> getSortedReplies() {
    final sortedReplies = List<QuickReply>.from(state.quickReplies)
      ..sort((a, b) {
        // 处理 category 可为 null 的情况
        final categoryA = a.category ?? '';
        final categoryB = b.category ?? '';
        final categoryCompare = categoryA.compareTo(categoryB);
        if (categoryCompare != 0) return categoryCompare;
        // 使用 orderIndex 而不是 order
        return a.orderIndex.compareTo(b.orderIndex);
      });
    return sortedReplies;
  }

  /// 搜索快捷回复
  List<QuickReply> searchQuickReplies(String query) {
    if (query.isEmpty) return state.quickReplies;
    
    return state.quickReplies
        .where((reply) => 
            reply.content.toLowerCase().contains(query.toLowerCase()) ||
            (reply.category?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }
}