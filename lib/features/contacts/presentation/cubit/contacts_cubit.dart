import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/core/services/log_service.dart';

/// 联系人Cubit
/// 负责管理联系人列表的状态
class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _repository;
  final _logger = LogService('contacts_cubit.dart');

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
  Future<void> addContact(User contact) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _repository.addContact(contact);
      await loadContacts(); // 重新加载联系人列表
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      emit(state.copyWith(
        error: '添加联系人失败: $e',
        isLoading: false,
      ));
    }
  }

  /// 删除联系人
  Future<void> deleteContact(String userId) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _repository.deleteContact(userId);
      await loadContacts(); // 重新加载联系人列表
    } catch (e) {
      _logger.e('删除联系人失败', error: e);
      emit(state.copyWith(
        error: '删除联系人失败: $e',
        isLoading: false,
      ));
    }
  }

  /// 更新联系人
  Future<void> updateContact(User contact) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _repository.updateContact(contact);
      await loadContacts(); // 重新加载联系人列表
    } catch (e) {
      _logger.e('更新联系人失败', error: e);
      emit(state.copyWith(
        error: '更新联系人失败: $e',
        isLoading: false,
      ));
    }
  }

  /// 按首字母分组联系人
  Map<String, List<User>> _groupContactsByFirstLetter(List<User> contacts) {
    final Map<String, List<User>> groupedContacts = {};

    for (final contact in contacts) {
      final firstLetter = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '#';
      groupedContacts.putIfAbsent(firstLetter, () => []).add(contact);
    }

    // 对每个分组内的联系人按姓名排序
    groupedContacts.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    return groupedContacts;
  }
}
