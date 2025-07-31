import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cc/core/services/log_service.dart';

class PhoneHistoryService {
  static const String _phoneHistoryKey = 'cc_phone_history';
  static const int _maxHistoryCount = 5;
  
  final _logger = LogService.instance;
  
  static final PhoneHistoryService _instance = PhoneHistoryService._internal();
  factory PhoneHistoryService() => _instance;
  PhoneHistoryService._internal();
  
  /// 获取手机号码历史记录
  Future<List<String>> getPhoneHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_phoneHistoryKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.cast<String>();
      }
    } catch (e) {
      _logger.e('获取手机号码历史记录失败', error: e);
    }
    return [];
  }
  
  /// 添加手机号码到历史记录
  Future<void> addPhoneToHistory(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber.length != 11) {
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = await getPhoneHistory();
      
      // 移除已存在的相同号码
      history.removeWhere((phone) => phone == phoneNumber);
      
      // 添加到列表开头
      history.insert(0, phoneNumber);
      
      // 限制历史记录数量
      if (history.length > _maxHistoryCount) {
        history = history.take(_maxHistoryCount).toList();
      }
      
      // 保存到存储
      await prefs.setString(_phoneHistoryKey, json.encode(history));
      
      _logger.d('添加手机号码到历史记录', extra: {
        'phoneNumber': phoneNumber,
        'historyCount': history.length
      });
    } catch (e) {
      _logger.e('添加手机号码到历史记录失败', error: e);
    }
  }
  
  /// 从历史记录中删除手机号码
  Future<void> removePhoneFromHistory(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = await getPhoneHistory();
      
      history.removeWhere((phone) => phone == phoneNumber);
      
      await prefs.setString(_phoneHistoryKey, json.encode(history));
      
      _logger.d('从历史记录删除手机号码', extra: {
        'phoneNumber': phoneNumber,
        'remainingCount': history.length
      });
    } catch (e) {
      _logger.e('删除手机号码历史记录失败', error: e);
    }
  }
  
  /// 清空所有历史记录
  Future<void> clearPhoneHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_phoneHistoryKey);
      _logger.d('清空手机号码历史记录');
    } catch (e) {
      _logger.e('清空手机号码历史记录失败', error: e);
    }
  }
}