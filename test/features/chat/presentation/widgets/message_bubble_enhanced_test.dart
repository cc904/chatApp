import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/presentation/widgets/message_bubble_enhanced.dart';
import 'package:cc/core/database/models/message.dart';

void main() {
  group('MessageBubbleEnhanced Widget Tests', () {
    late Message testMessage;
    const String currentUserId = 'current_user_123';

    setUp(() {
      testMessage = Message()
        ..messageId = 'test_msg_001'
        ..conversationId = 'test_conv_001'
        ..senderId = 'sender_123'
        ..senderName = 'Test Sender'
        ..createdAt = DateTime.now()
        ..isRead = true
        ..status = 'sent'
        ..type = 'text'
        ..text = 'Hello, this is a test message!';
    });

    group('基础渲染测试', () {
      testWidgets('应该正确渲染文本消息', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证消息文本显示
        expect(find.text('Hello, this is a test message!'), findsOneWidget);

        // 验证消息气泡存在
        expect(find.byType(Container), findsWidgets);

        // 验证时间戳显示
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('应该正确显示自己发送的消息', (WidgetTester tester) async {
        testMessage.senderId = currentUserId;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: true,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证消息状态指示器存在（只有自己的消息才显示）
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('应该正确显示发送者信息', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                showSenderInfo: true,
              ),
            ),
          ),
        );

        // 验证发送者名称显示
        expect(find.text('Test Sender'), findsOneWidget);
      });
    });

    group('消息类型测试', () {
      testWidgets('应该正确渲染图片消息', (WidgetTester tester) async {
        testMessage.type = 'image';
        testMessage.mediaUrl = 'https://example.com/image.jpg';
        testMessage.text = '图片说明';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证图片组件存在
        expect(find.byType(Image), findsOneWidget);

        // 验证图片说明文字
        expect(find.text('图片说明'), findsOneWidget);
      });

      testWidgets('应该正确渲染语音消息', (WidgetTester tester) async {
        testMessage.type = 'voice';
        testMessage.duration = 30000; // 30秒

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证播放按钮存在
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        // 验证时长显示
        expect(find.text('0:30'), findsOneWidget);
      });

      testWidgets('应该正确渲染视频消息', (WidgetTester tester) async {
        testMessage.type = 'video';
        testMessage.thumbnailUrl = null; // 设置为null避免网络加载
        testMessage.duration = 120000; // 2分钟

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证播放按钮存在
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        // 验证时长显示
        expect(find.text('2:00'), findsOneWidget);
      });

      testWidgets('应该正确渲染文件消息', (WidgetTester tester) async {
        testMessage.type = 'file';
        testMessage.fileName = 'document.pdf';
        testMessage.fileSize = 1024.0; // 1KB

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证文件名显示
        expect(find.text('document.pdf'), findsOneWidget);

        // 验证文件大小显示
        expect(find.text('1.0 KB'), findsOneWidget);

        // 验证PDF图标
        expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      });

      testWidgets('应该正确渲染位置消息', (WidgetTester tester) async {
        testMessage.type = 'location';
        testMessage.locationAddress = '北京市朝阳区';
        testMessage.latitude = 39.9042;
        testMessage.longitude = 116.4074;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证位置图标
        expect(find.byIcon(Icons.location_on), findsOneWidget);

        // 验证位置信息文字
        expect(find.text('位置信息'), findsOneWidget);

        // 验证地址显示
        expect(find.text('北京市朝阳区'), findsOneWidget);
      });
    });

    group('特殊消息状态测试', () {
      testWidgets('应该正确显示撤销消息', (WidgetTester tester) async {
        testMessage.status = 'revoked';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证撤销消息文字
        expect(find.text('Test Sender撤回了一条消息'), findsOneWidget);

        // 验证撤销图标
        expect(find.byIcon(Icons.block), findsOneWidget);
      });

      testWidgets('应该正确显示系统消息', (WidgetTester tester) async {
        testMessage.type = 'system';
        testMessage.text = '用户加入了群聊';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证系统消息文字
        expect(find.text('用户加入了群聊'), findsOneWidget);
      });

      testWidgets('删除的消息对其他人不可见', (WidgetTester tester) async {
        testMessage.status = 'deleted';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false, // 不是自己发送的
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证消息不显示
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.text('Hello, this is a test message!'), findsNothing);
      });
    });

    group('消息状态指示器测试', () {
      testWidgets('应该显示正确的发送状态', (WidgetTester tester) async {
        testMessage.senderId = currentUserId;
        testMessage.status = 'sending';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: true,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证发送中的进度指示器
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('应该显示已送达状态', (WidgetTester tester) async {
        testMessage.senderId = currentUserId;
        testMessage.status = 'delivered';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: true,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证双勾图标
        expect(find.byIcon(Icons.done_all), findsOneWidget);
      });

      testWidgets('应该显示已读状态', (WidgetTester tester) async {
        testMessage.senderId = currentUserId;
        testMessage.status = 'read';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: true,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证蓝色双勾图标
        expect(find.byIcon(Icons.done_all), findsOneWidget);
      });

      testWidgets('应该显示发送失败状态', (WidgetTester tester) async {
        testMessage.senderId = currentUserId;
        testMessage.status = 'failed';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: true,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证错误图标
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('引用消息测试', () {
      testWidgets('应该显示引用消息', (WidgetTester tester) async {
        testMessage.quotedMessageId = 'quoted_msg_123';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证引用消息显示
        expect(find.text('回复消息: quoted_msg_123'), findsOneWidget);
      });

      testWidgets('点击引用消息应该触发回调', (WidgetTester tester) async {
        testMessage.quotedMessageId = 'quoted_msg_123';
        bool quoteTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                onQuoteTap: () {
                  quoteTapped = true;
                },
              ),
            ),
          ),
        );

        // 点击引用消息
        await tester.tap(find.text('回复消息: quoted_msg_123'));
        await tester.pump();

        // 验证回调被触发
        expect(quoteTapped, isTrue);
      });
    });

    group('交互测试', () {
      testWidgets('点击消息应该触发回调', (WidgetTester tester) async {
        bool messageTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                onTap: () {
                  messageTapped = true;
                },
              ),
            ),
          ),
        );

        // 点击消息气泡（使用GestureDetector查找器）
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // 验证回调被触发
        expect(messageTapped, isTrue);
      });

      testWidgets('长按消息应该触发回调', (WidgetTester tester) async {
        bool messageLongPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                onLongPress: () {
                  messageLongPressed = true;
                },
              ),
            ),
          ),
        );

        // 长按消息气泡（使用GestureDetector查找器）
        await tester.longPress(find.byType(GestureDetector));
        await tester.pump();

        // 验证回调被触发
        expect(messageLongPressed, isTrue);
      });
    });

    group('动画测试', () {
      testWidgets('高亮状态应该触发动画', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                isHighlighted: false,
              ),
            ),
          ),
        );

        // 初始状态
        await tester.pump();

        // 更新为高亮状态
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                isHighlighted: true,
              ),
            ),
          ),
        );

        // 等待动画完成
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // 验证组件仍然存在（动画正在进行）
        expect(find.byType(MessageBubbleEnhanced), findsOneWidget);
      });

      testWidgets('选择状态应该触发缩放动画', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                isSelected: false,
              ),
            ),
          ),
        );

        // 初始状态
        await tester.pump();

        // 更新为选择状态
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
                isSelected: true,
              ),
            ),
          ),
        );

        // 等待动画完成
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // 验证MessageBubbleEnhanced组件存在（动画正在进行）
        expect(find.byType(MessageBubbleEnhanced), findsOneWidget);

        // 验证Transform组件存在（但不要求具体数量，因为可能有多个Transform）
        expect(find.byType(Transform), findsWidgets);
      });
    });

    group('时间格式化测试', () {
      testWidgets('应该正确格式化今天的时间', (WidgetTester tester) async {
        final now = DateTime.now();
        testMessage.createdAt = DateTime(now.year, now.month, now.day, 14, 30);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证时间格式（HH:MM）
        expect(find.text('14:30'), findsOneWidget);
      });

      testWidgets('应该正确格式化昨天的时间', (WidgetTester tester) async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        testMessage.createdAt = yesterday;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        // 验证日期格式（M/D）
        expect(
            find.text('${yesterday.month}/${yesterday.day}'), findsOneWidget);
      });
    });

    group('文件大小格式化测试', () {
      testWidgets('应该正确格式化字节', (WidgetTester tester) async {
        testMessage.type = 'file';
        testMessage.fileName = 'small.txt';
        testMessage.fileSize = 512.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        expect(find.text('512 B'), findsOneWidget);
      });

      testWidgets('应该正确格式化KB', (WidgetTester tester) async {
        testMessage.type = 'file';
        testMessage.fileName = 'medium.txt';
        testMessage.fileSize = 2048.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        expect(find.text('2.0 KB'), findsOneWidget);
      });

      testWidgets('应该正确格式化MB', (WidgetTester tester) async {
        testMessage.type = 'file';
        testMessage.fileName = 'large.txt';
        testMessage.fileSize = 2097152.0; // 2MB

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleEnhanced(
                message: testMessage,
                isMe: false,
                currentUserId: currentUserId,
              ),
            ),
          ),
        );

        expect(find.text('2.0 MB'), findsOneWidget);
      });
    });
  });
}
