import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/constants/message_types.dart';

// 搜索状态
class SearchState extends Equatable {
  final List<Message> searchResults;
  final bool isSearching;
  final FilterType? currentFilter;
  final DateTime? selectedDate;
  final String searchQuery;

  const SearchState({
    this.searchResults = const [],
    this.isSearching = false,
    this.currentFilter,
    this.selectedDate,
    this.searchQuery = '',
  });

  SearchState copyWith({
    List<Message>? searchResults,
    bool? isSearching,
    FilterType? currentFilter,
    DateTime? selectedDate,
    String? searchQuery,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedDate: selectedDate ?? this.selectedDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [searchResults, isSearching, currentFilter, selectedDate, searchQuery];
}

// 过滤类型枚举
enum FilterType {
  all,
  text,
  media,
  file,
  date,
  month,
  year,
}

class SearchCubit extends Cubit<SearchState> {
  final LogService _logger = LogService.instance;

  SearchCubit() : super(const SearchState(currentFilter: FilterType.all));

  // 执行搜索操作
  void performSearch(String query, List<Message> messages) {
    if (query.trim().isEmpty && state.currentFilter == FilterType.all) {
      emit(state.copyWith(
        searchResults: [],
        isSearching: false,
        searchQuery: query,
      ));
      return;
    }

    // 开始搜索,更新状态
    emit(state.copyWith(
      isSearching: true,
      searchQuery: query,
    ));

    try {
      // 先应用过滤器
      var filteredMessages = _applyFilter(messages);

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

      // 更新结果状态
      emit(state.copyWith(
        searchResults: filteredMessages,
        isSearching: false,
      ));
    } catch (error) {
      _logger.e('搜索失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(
        isSearching: false,
      ));
    }
  }

  // 设置过滤类型
  void setFilter(FilterType filter) {
    emit(state.copyWith(currentFilter: filter));
  }

  // 设置选中的日期
  void setSelectedDate(DateTime? date) {
    emit(state.copyWith(
      selectedDate: date,
      currentFilter: date != null ? FilterType.date : state.currentFilter,
    ));
  }

  // 日期选择操作开始（显示加载状态）
  void dateSelectionStarted() {
    emit(state.copyWith(isSearching: true));
  }

  // 日期选择操作结束（隐藏加载状态）
  void dateSelectionEnded() {
    emit(state.copyWith(isSearching: false));
  }

  // 日期选择失败
  void dateSelectionFailed(String errorMessage) {
    _logger.e('日期选择失败', error: errorMessage);
    emit(state.copyWith(isSearching: false));
  }

  // 应用过滤器
  List<Message> _applyFilter(List<Message> messages) {
    switch (state.currentFilter) {
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
        if (state.selectedDate == null) {
          return messages;
        }

        final startOfDay = DateTime(state.selectedDate!.year, state.selectedDate!.month, state.selectedDate!.day);
        final endOfDay = DateTime(state.selectedDate!.year, state.selectedDate!.month, state.selectedDate!.day, 23, 59, 59);

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

      default:
        return messages;
    }
  }
}
