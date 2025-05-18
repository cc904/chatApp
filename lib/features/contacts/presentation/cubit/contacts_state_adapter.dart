import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_cubit.dart' as cubit;
import 'package:cc/features/contacts/presentation/cubit/contacts_state.dart' as state;
import 'package:lpinyin/lpinyin.dart';

/// 联系人状态适配器
/// 用于将contacts_cubit.dart中的ContactsCubitState适配到contacts_state.dart中的ContactsState
class ContactsStateAdapter {
  /// 缓存上次搜索的结果
  static List<User> _lastSearchResults = [];

  /// 缓存上次搜索的查询
  static String? _lastSearchQuery;

  /// 将contacts_cubit.dart中的ContactsCubitState转换成contacts_state.dart中的ContactsState
  static state.ContactsState adapt(cubit.ContactsCubitState cubitState) {
    // 按首字母分组
    final Map<String, List<User>> groupedContacts = {};
    for (final contact in cubitState.contacts) {
      final firstLetter = _getFirstLetter(contact);
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]!.add(contact);
    }

    // 对每个分组内的联系人按名称排序
    for (final key in groupedContacts.keys) {
      groupedContacts[key]!.sort((a, b) => a.name.compareTo(b.name));
    }

    return state.ContactsState(
      contacts: cubitState.contacts,
      groupedContacts: groupedContacts,
      isLoading: cubitState.isLoading,
      error: cubitState.errorMessage,
      searchQuery: _lastSearchQuery,
      searchResults: _lastSearchResults,
    );
  }

  /// 设置搜索结果,供适配器使用
  static void setSearchResults(String query, List<User> results) {
    _lastSearchQuery = query;
    _lastSearchResults = results;
  }

  /// 清除搜索结果
  static void clearSearch() {
    _lastSearchQuery = null;
    _lastSearchResults = [];
  }

  /// 获取名称的首字母,如果不是字母则返回#
  static String _getFirstLetter(User contact) {
    if (contact.name.isEmpty) return '#';

    // 获取名称首字符
    final firstChar = contact.name[0];

    // 如果是英文字母
    if (RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
      return firstChar.toUpperCase();
    }

    // 如果是中文字符，转换为拼音首字母
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(firstChar)) {
      final pinyin = PinyinHelper.getPinyinE(firstChar, format: PinyinFormat.WITHOUT_TONE);
      if (pinyin.isNotEmpty) {
        return pinyin[0].toUpperCase();
      }
    }

    return '#';
  }
}
