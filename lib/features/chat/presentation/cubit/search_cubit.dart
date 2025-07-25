import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/drift_database.dart';
import 'dart:convert';

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
    this.currentFilter,
    this.selectedDate,
    this.errorMessage,
  });

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

// Cubit类
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  final LogService _logger = LogService.instance;

  /// 从消息内容中提取文本
  String? _extractTextFromMessage(Message message) {
    try {
      if (message.content == null || message.content!.isEmpty) {
        return null;
      }

      final contentJson = jsonDecode(message.content!);
      
      // 检查是否是文本消息
      if (contentJson['text_message'] != null) {
        final textMessage = contentJson['text_message'] as Map<String, dynamic>;
        return textMessage['text'] as String?;
      }
      
      // 检查媒体消息的说明文字
      if (contentJson['media_message'] != null) {
        final mediaMessage = contentJson['media_message'] as Map<String, dynamic>;
        return mediaMessage['caption'] as String?;
      }
      
      return null;
    } catch (e) {
      _logger.e('解析消息文本失败', error: e, extra: {
        'messageId': message.messageId,
        'content': message.content,
      });
      return null;
    }
  }

  /// 检查是否是文本消息
  bool _isTextMessage(Message message) {
    return message.messageType == 'TEXT';
  }

  /// 检查是否是媒体消息
  bool _isMediaMessage(Message message) {
    return message.messageType == 'IMAGE' || message.messageType == 'VIDEO';
  }

  /// 检查是否是文件消息
  bool _isFileMessage(Message message) {
    return message.messageType == 'FILE';
  }

  /// 获取消息的DateTime时间
  /// 在 Drift 模型中，createdAt 已经是 DateTime 类型
  DateTime _getMessageDateTime(Message message) {
    return message.createdAt;
  }

  void search(String query, List<Message> messages) async {
    try {
      emit(state.copyWith(isSearching: true, isInitial: false, errorMessage: null));

      List<Message> results = [];

      if (query.isNotEmpty) {
        // 搜索文本内容
        results = messages.where((message) {
          final text = _extractTextFromMessage(message);
          return text != null && text.toLowerCase().contains(query.toLowerCase());
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

  List<Message> _applyFilter(List<Message> messages, FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return messages;
      case FilterType.text:
        return messages.where((m) => _isTextMessage(m)).toList();
      case FilterType.media:
        return messages.where((m) => _isMediaMessage(m)).toList();
      case FilterType.file:
        return messages.where((m) => _isFileMessage(m)).toList();
      case FilterType.date:
        if (state.selectedDate != null) {
          final date = state.selectedDate!;
          return messages.where((m) {
            final messageDateTime = _getMessageDateTime(m);
            final messageDate = DateTime(
              messageDateTime.year,
              messageDateTime.month,
              messageDateTime.day,
            );
            final targetDate = DateTime(date.year, date.month, date.day);
            return messageDate.isAtSameMomentAs(targetDate);
          }).toList();
        }
        return messages;
      case FilterType.month:
        final now = DateTime.now();
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
        return messages.where((m) {
          final messageDateTime = _getMessageDateTime(m);
          return messageDateTime.isAfter(oneMonthAgo);
        }).toList();
      case FilterType.year:
        final now = DateTime.now();
        final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
        return messages.where((m) {
          final messageDateTime = _getMessageDateTime(m);
          return messageDateTime.isAfter(oneYearAgo);
        }).toList();
    }
  }

  void setFilter(FilterType filter) {
    emit(state.copyWith(currentFilter: filter));
  }

  void setDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void clearSearch() {
    emit(const SearchState());
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}