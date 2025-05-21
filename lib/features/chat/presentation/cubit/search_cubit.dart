import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/constants/message_types.dart';

// 定义过滤器类型
enum FilterType { all, text, media, file, date, month, year }

// 定义状态类
class SearchState extends Equatable {
  final bool isSearching;
  final bool isInitial; // 添加初始状态标志
  final String? searchQuery;
  final List<Message> searchResults;
  final FilterType? currentFilter;
  final DateTime? selectedDate;
  final String? errorMessage;

  const SearchState({
    this.isSearching = false,
    this.isInitial = true, // 默认为初始状态
    this.searchQuery,
    this.searchResults = const [],
    this.currentFilter = FilterType.all,
    this.selectedDate,
    this.errorMessage,
  });

  // 工厂构造函数 - 初始状态
  factory SearchState.initial() {
    return const SearchState(
      isSearching: false,
      isInitial: true,
      searchResults: [],
      currentFilter: FilterType.all,
    );
  }

  // 复制方法
  SearchState copyWith({
    bool? isSearching,
    bool? isInitial,
    String? searchQuery,
    List<Message>? searchResults,
    FilterType? currentFilter,
    DateTime? selectedDate,
    String? errorMessage,
  }) {
    return SearchState(
      isSearching: isSearching ?? this.isSearching,
      isInitial: isInitial ?? this.isInitial,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isSearching,
        isInitial,
        searchQuery,
        searchResults,
        currentFilter,
        selectedDate,
        errorMessage,
      ];
}

class SearchCubit extends Cubit<SearchState> {
  final _logger = LogService.instance;

  SearchCubit() : super(SearchState.initial());

  // 执行搜索
  void performSearch(String query, List<Message> messages) {
    if (query.isEmpty && state.currentFilter == FilterType.all) {
      // 如果搜索词为空且过滤器为全部，则返回空结果
      emit(state.copyWith(
        isSearching: false,
        isInitial: false,
        searchQuery: query,
        searchResults: [],
      ));
      return;
    }

    emit(state.copyWith(isSearching: true, isInitial: false));

    try {
      List<Message> results = [];

      if (query.isNotEmpty) {
        // 搜索文本内容
        results = messages.where((message) {
          return message.text != null &&
              message.text!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        // 只应用过滤器
        results = messages;
      }

      // 应用过滤器
      results = _applyFilter(results, state.currentFilter!);

      emit(state.copyWith(
        isSearching: false,
        searchQuery: query,
        searchResults: results,
      ));
    } catch (error) {
      _logger.e('搜索失败', error: error);
      emit(state.copyWith(
        isSearching: false,
        errorMessage: error.toString(),
      ));
    }
  }

  // 设置过滤器
  void setFilter(FilterType filter) {
    emit(state.copyWith(currentFilter: filter));
  }

  // 设置日期
  void setSelectedDate(DateTime date) {
    emit(state.copyWith(selectedDate: date, currentFilter: FilterType.date));
  }

  // 应用过滤器
  List<Message> _applyFilter(List<Message> messages, FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return messages;
      case FilterType.text:
        return messages.where((m) => m.type == MessageType.text).toList();
      case FilterType.media:
        return messages
            .where((m) =>
                m.type == MessageType.image || m.type == MessageType.video)
            .toList();
      case FilterType.file:
        return messages.where((m) => m.type == MessageType.file).toList();
      case FilterType.date:
        if (state.selectedDate != null) {
          final date = state.selectedDate!;
          return messages.where((m) {
            final messageDate = DateTime(
              m.createdAt.year,
              m.createdAt.month,
              m.createdAt.day,
            );
            final targetDate = DateTime(date.year, date.month, date.day);
            return messageDate.isAtSameMomentAs(targetDate);
          }).toList();
        }
        return messages;
      case FilterType.month:
        final now = DateTime.now();
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
        return messages.where((m) => m.createdAt.isAfter(oneMonthAgo)).toList();
      case FilterType.year:
        final now = DateTime.now();
        final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
        return messages.where((m) => m.createdAt.isAfter(oneYearAgo)).toList();
      }
  }

  // 应用过滤器到消息列表（供外部调用）
  void applyFilter(List<Message> messages) {
    final filtered = _applyFilter(messages, state.currentFilter!);
    emit(state.copyWith(
      searchResults: filtered,
      isInitial: false,
    ));
  }

  // 日期选择失败
  void dateSelectionFailed(String errorMessage) {
    emit(state.copyWith(errorMessage: errorMessage));
  }
}
