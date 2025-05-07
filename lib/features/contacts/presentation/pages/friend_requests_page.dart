import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final LogService _logger = LogService('friend_requests_page.dart');
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    await context.read<ContactsCubit>().loadFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('好友请求'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ContactsCubit, ContactsCubitState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingRequests = state.friendRequests.where((req) => req.status == FriendRequestStatus.pending).toList();

          if (pendingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_disabled, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('暂无好友请求', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadFriendRequests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('刷新'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadFriendRequests,
                color: Colors.green,
                child: ListView.builder(
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = pendingRequests[index];
                    return _buildRequestItem(context, request);
                  },
                ),
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 120),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, FriendRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: request.senderAvatar != null ? NetworkImage(request.senderAvatar!) : null,
                  child: request.senderAvatar == null
                      ? Text(
                          request.senderName.isNotEmpty ? request.senderName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${timeago.format(request.createdAt, locale: 'zh')}发送请求',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.message != null && request.message!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  '验证消息: ${request.message}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _handleRejectRequest(request),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('拒绝'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleAcceptRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('接受'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAcceptRequest(FriendRequest request) async {
    try {
      _logger.i('接受好友请求', extra: {'requestId': request.requestId});

      setState(() {
        _isProcessing = true;
      });

      final success = await context.read<ContactsCubit>().acceptFriendRequest(request.requestId);

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (success) {
          UINotificationHelper.showSuccess('已添加为好友');
        } else {
          UINotificationHelper.showError('添加好友失败，请重试');
        }
      }
    } catch (e) {
      _logger.e('接受好友请求失败', error: e);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        UINotificationHelper.showError('添加好友失败: $e');
      }
    }
  }

  Future<void> _handleRejectRequest(FriendRequest request) async {
    try {
      _logger.i('拒绝好友请求', extra: {'requestId': request.requestId});

      setState(() {
        _isProcessing = true;
      });

      final success = await context.read<ContactsCubit>().rejectFriendRequest(request.requestId);

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (success) {
          UINotificationHelper.showSuccess('已拒绝好友请求');
        } else {
          UINotificationHelper.showError('拒绝请求失败，请重试');
        }
      }
    } catch (e) {
      _logger.e('拒绝好友请求失败', error: e);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        UINotificationHelper.showError('拒绝请求失败: $e');
      }
    }
  }
}
