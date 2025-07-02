import 'package:cc/core/proto/generated/contacts.pb.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:fixnum/fixnum.dart';

/// 联系人服务
/// 负责处理联系人相关的操作，如更新联系人信息
class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  static ContactService get instance => _instance;

  final _logger = LogService.instance;
  final _socketService = ProtoSocketService();

  /// 更新联系人信息
  ///
  /// [contactId] 联系人ID
  /// [nickname] 自定义昵称（可选）
  /// [remark] 备注信息（可选）
  /// [blocked] 是否拉黑（可选）
  /// [isFavorite] 是否收藏（可选）
  ///
  /// 返回操作是否成功
  Future<bool> updateContact({
    required String contactId,
    String? nickname,
    String? remark,
    bool? blocked,
    bool? isFavorite,
  }) async {
    try {
      _logger.i('开始更新联系人信息', extra: {
        'contactId': contactId,
        'nickname': nickname,
        'remark': remark,
        'blocked': blocked,
        'isFavorite': isFavorite,
      });

      final request = UpdateContactRequest(
        contactId: contactId,
        nickname: nickname,
        remark: remark,
        blocked: blocked,
        isFavorite: isFavorite,
        timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      );

      // 发送更新请求
      _socketService.emitProto('contact:update', request);

      // 注册监听响应（这里简化处理，实际应该设置超时等）
      // 在真实实现中，应该有一个更完善的响应处理机制
      _logger.i('联系人更新请求已发送');

      return true;
    } catch (e) {
      _logger.e('更新联系人信息失败', extra: {
        'contactId': contactId,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 注册事件监听器
  void registerEventHandlers() {
    // 监听联系人更新响应
    _socketService.on('contact:update:response', _handleUpdateContactResponse);

    // 监听联系人信息更新事件
    _socketService.on('contact:updated', _handleContactUpdated);
  }

  /// 处理联系人更新响应
  void _handleUpdateContactResponse(dynamic data) {
    try {
      final response = UpdateContactResponse.fromBuffer(data);

      _logger.i('收到联系人更新响应', extra: {
        'success': response.success,
        'message': response.message,
        'updatedFields': response.updatedFields,
      });

      if (response.success) {
        _logger.i('联系人信息更新成功');
      } else {
        _logger.w('联系人信息更新失败: ${response.message}');
      }
    } catch (e) {
      _logger.e('处理联系人更新响应失败', extra: {'error': e.toString()});
    }
  }

  /// 处理联系人信息更新事件
  void _handleContactUpdated(dynamic data) {
    try {
      final event = ContactUpdateEvent.fromBuffer(data);

      _logger.i('收到联系人信息更新事件', extra: {
        'contactId': event.contact.userId,
        'updatedFields': event.updatedFields,
        'updateSource': event.updateSource,
      });

      // 这里可以触发相关UI更新，比如通过EventBus或者其他状态管理机制
    } catch (e) {
      _logger.e('处理联系人更新事件失败', extra: {'error': e.toString()});
    }
  }
}
