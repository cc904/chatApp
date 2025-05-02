import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:logger/logger.dart';

/// 联系人Cubit
/// 负责管理联系人列表的状态
class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _repository;
  final Logger _logger = Logger();

  ContactsCubit({required ContactsRepository repository})
      : _repository = repository,
        super(ContactsState.initial());

  /// 加载所有联系人
  Future<void> loadContacts() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final contacts = await _repository.getAllContacts();

      // 按首字母分组
      final groupedContacts = _groupContactsByFirstLetter(contacts);

      emit(state.copyWith(
        contacts: contacts,
        groupedContacts: groupedContacts,
        isLoading: false,
      ));
    } catch (e) {
      _logger.e('加载联系人失败', error: e);
      emit(state.copyWith(
        error: '加载联系人失败: $e',
        isLoading: false,
      ));
    }
  }

  /// 搜索联系人
  Future<void> searchContacts(String keyword) async {
    if (keyword.isEmpty) {
      // 如果关键词为空，恢复显示所有联系人
      await loadContacts();
      return;
    }

    try {
      emit(state.copyWith(isLoading: true, error: null));

      final results = await _repository.searchContacts(keyword);

      emit(state.copyWith(
        searchResults: results,
        searchQuery: keyword,
        isLoading: false,
      ));
    } catch (e) {
      _logger.e('搜索联系人失败', error: e);
      emit(state.copyWith(
        error: '搜索联系人失败: $e',
        isLoading: false,
      ));
    }
  }

  /// 添加联系人
  Future<void> addContact(User user) async {
    try {
      await _repository.addContact(user);
      // 重新加载联系人列表
      await loadContacts();
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      emit(state.copyWith(error: '添加联系人失败: $e'));
    }
  }

  /// 删除联系人
  Future<void> deleteContact(String userId) async {
    try {
      await _repository.deleteContact(userId);
      // 重新加载联系人列表
      await loadContacts();
    } catch (e) {
      _logger.e('删除联系人失败', error: e);
      emit(state.copyWith(error: '删除联系人失败: $e'));
    }
  }

  /// 按首字母分组联系人
  Map<String, List<User>> _groupContactsByFirstLetter(List<User> contacts) {
    final grouped = <String, List<User>>{};

    for (var contact in contacts) {
      if (contact.name.isEmpty) continue;

      // 获取联系人名称的首字母，转为大写
      String firstLetter = contact.name[0].toUpperCase();

      // 如果不是A-Z，归类到#组
      if (!RegExp(r'[A-Z]').hasMatch(firstLetter)) {
        firstLetter = '#';
      }

      // 将联系人添加到对应分组
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(contact);
    }

    // 对每个分组中的联系人按名称排序
    grouped.forEach((key, list) {
      list.sort((a, b) => a.name.compareTo(b.name));
    });

    return grouped;
  }
}
