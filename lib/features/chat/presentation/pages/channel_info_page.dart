import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/features/chat/presentation/pages/create_channel_page.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/constants/app_colors.dart';

/// 频道介绍页面
/// 显示频道的作用和功能介绍，引导用户创建频道
class ChannelInfoPage extends StatelessWidget {
  const ChannelInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).back,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        leadingWidth: 80,
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 手机插图区域
            Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 手机框架
                      Container(
                        width: 200,
                        height: 360,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(30),
                          border:
                              Border.all(color: Colors.grey[600]!, width: 3),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            children: [
                              // 刘海
                              Container(
                                width: 80,
                                height: 6,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              // 屏幕内容
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(13),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 小鸭子图标
                                        Text(
                                          '🦆',
                                          style: TextStyle(fontSize: 60),
                                        ),
                                        SizedBox(height: 16),
                                        // 播放按钮
                                        Icon(
                                          Icons.play_circle_filled,
                                          color: AppColors.primary,
                                          size: 32,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 频道信息气泡
                      Positioned(
                        top: 40,
                        left: -20,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).channelTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '57k ${AppLocalizations.of(context).channelMembers}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 观看数气泡
                      Positioned(
                        top: 120,
                        right: -20,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context).channelViews,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.visibility,
                                color: Colors.grey,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                '1K',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 标题和描述
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context).whatIsChannel,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).channelDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // 创建频道按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 获取必要的Provider依赖
                        final chatsRepository = context.read<ChatsRepository>();
                        final chatRepository = context.read<ChatRepository>();
                        final chatRepositorySend =
                            context.read<ChatRepositorySend>();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiRepositoryProvider(
                              providers: [
                                RepositoryProvider<ChatsRepository>.value(
                                    value: chatsRepository),
                                RepositoryProvider<ChatRepository>.value(
                                    value: chatRepository),
                                RepositoryProvider<ChatRepositorySend>.value(
                                    value: chatRepositorySend),
                              ],
                              child: const CreateChannelPage(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context).createChannel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
