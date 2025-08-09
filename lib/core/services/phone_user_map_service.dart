import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 维护 (serverUrl, phone) -> userId 的本地映射
/// 用于在删除手机号历史记录时，定位并删除对应用户的本地数据库
class PhoneUserMapService {
  PhoneUserMapService._internal();
  static final PhoneUserMapService instance = PhoneUserMapService._internal();

  static const String _storageKey = 'cc_phone_user_map';

  String _makeKey({required String serverUrl, required String phone}) {
    return '${serverUrl.trim()}|${phone.trim()}';
  }

  Future<Map<String, String>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <String, String>{};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
    } catch (_) {}
    return <String, String>{};
  }

  Future<void> _saveAll(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(data));
  }

  Future<void> setUserIdForPhone({
    required String serverUrl,
    required String phone,
    required String userId,
  }) async {
    if (serverUrl.isEmpty || phone.isEmpty || userId.isEmpty) return;
    final all = await _loadAll();
    all[_makeKey(serverUrl: serverUrl, phone: phone)] = userId;
    await _saveAll(all);
  }

  Future<String?> getUserIdForPhone({
    required String serverUrl,
    required String phone,
  }) async {
    final all = await _loadAll();
    return all[_makeKey(serverUrl: serverUrl, phone: phone)];
  }

  Future<void> removeMapping({
    required String serverUrl,
    required String phone,
  }) async {
    final all = await _loadAll();
    all.remove(_makeKey(serverUrl: serverUrl, phone: phone));
    await _saveAll(all);
  }
}


