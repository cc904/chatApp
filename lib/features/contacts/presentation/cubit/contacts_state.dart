import 'package:equatable/equatable.dart';
import 'package:cc/core/database/models/user.dart';

/// 联系人状态类
class ContactsState extends Equatable {
  final List<User> contacts;
  final Map<String, List<User>> groupedContacts;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final List<User> searchResults;

  const ContactsState({
    this.contacts = const [],
    this.groupedContacts = const {},
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.searchResults = const [],
  });

  /// 创建初始状态
  factory ContactsState.initial() {
    return const ContactsState();
  }

  /// 复制当前状态并修改指定字段
  ContactsState copyWith({
    List<User>? contacts,
    Map<String, List<User>>? groupedContacts,
    bool? isLoading,
    String? error,
    String? searchQuery,
    List<User>? searchResults,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      groupedContacts: groupedContacts ?? this.groupedContacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  /// 获取要显示的联系人列表
  /// 如果有搜索查询,则返回搜索结果,否则返回全部联系人
  List<User> get displayContacts => searchQuery != null && searchQuery!.isNotEmpty ? searchResults : contacts;

  /// 获取分组字母列表（按顺序）
  List<String> get sectionLetters {
    final letters = groupedContacts.keys.toList();
    // 确保#在最后
    letters.sort((a, b) {
      if (a == '#') return 1;
      if (b == '#') return -1;
      return a.compareTo(b);
    });
    return letters;
  }

  /// 是否有搜索结果
  bool get hasSearchResults => searchResults.isNotEmpty;

  /// 是否正在搜索
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  @override
  List<Object?> get props => [contacts, groupedContacts, isLoading, error, searchQuery, searchResults];
}
