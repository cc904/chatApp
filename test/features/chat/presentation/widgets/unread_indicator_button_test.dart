import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/presentation/widgets/unread_indicator_button.dart';

void main() {
  group('UnreadIndicatorButton Widget Tests', () {
    testWidgets('应该在有未读消息时显示按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 5,
              isVisible: true,
            ),
          ),
        ),
      );

      // 验证按钮存在
      expect(find.byType(UnreadIndicatorButton), findsOneWidget);
      expect(find.text('5条未读消息'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // 徽章中的数字
    });

    testWidgets('应该在没有未读消息时隐藏按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 0,
              isVisible: true,
            ),
          ),
        ),
      );

      // 验证按钮不显示（查找InkWell而不是Material）
      expect(find.byType(InkWell), findsNothing);
      expect(find.text('0条未读消息'), findsNothing);
    });

    testWidgets('应该在isVisible为false时隐藏按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 3,
              isVisible: false,
            ),
          ),
        ),
      );

      // 验证按钮不显示（查找InkWell而不是Material）
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('应该正确格式化未读数量', (WidgetTester tester) async {
      // 测试1条消息
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 1,
              isVisible: true,
            ),
          ),
        ),
      );

      expect(find.text('1条未读消息'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // 测试99条消息
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 99,
              isVisible: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('99条未读消息'), findsOneWidget);
      expect(find.text('99'), findsOneWidget);

      // 测试超过99条消息
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 150,
              isVisible: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('99+条未读消息'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('应该响应点击事件', (WidgetTester tester) async {
      bool buttonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 5,
              isVisible: true,
              onTap: () {
                buttonTapped = true;
              },
            ),
          ),
        ),
      );

      // 点击按钮
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // 验证回调被触发
      expect(buttonTapped, isTrue);
    });

    testWidgets('应该显示自定义文本', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 5,
              isVisible: true,
              text: '自定义文本',
            ),
          ),
        ),
      );

      expect(find.text('自定义文本'), findsOneWidget);
      expect(find.text('5条未读消息'), findsNothing);
    });

    testWidgets('应该包含必要的UI元素', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 10,
              isVisible: true,
            ),
          ),
        ),
      );

      // 验证包含箭头图标
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

      // 验证包含按钮的Material组件（通过elevation区分）
      final materials = find.byType(Material);
      expect(materials, findsWidgets);

      // 验证包含InkWell（点击效果）
      expect(find.byType(InkWell), findsOneWidget);
    });
  });

  group('SecondaryJumpButton Widget Tests', () {
    testWidgets('应该在isVisible为true时显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: true,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
            ),
          ),
        ),
      );

      expect(find.byType(SecondaryJumpButton), findsOneWidget);
      expect(find.text('有多条未读消息，选择跳转位置：'), findsOneWidget);
      expect(find.text('跳转到第一条'), findsOneWidget);
      expect(find.text('跳转到最新'), findsOneWidget);
    });

    testWidgets('应该在isVisible为false时隐藏', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: false,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
            ),
          ),
        ),
      );

      expect(find.text('有多条未读消息，选择跳转位置：'), findsNothing);
    });

    testWidgets('应该响应主要跳转按钮点击', (WidgetTester tester) async {
      bool primaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: true,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
              onPrimaryTap: () {
                primaryTapped = true;
              },
            ),
          ),
        ),
      );

      // 等待动画完成
      await tester.pumpAndSettle();

      // 点击主要按钮（使用TextButton查找器）
      final primaryButtons = find.byType(TextButton);
      await tester.tap(primaryButtons.first);
      await tester.pump();

      expect(primaryTapped, isTrue);
    });

    testWidgets('应该响应次要跳转按钮点击', (WidgetTester tester) async {
      bool secondaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: true,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
              onSecondaryTap: () {
                secondaryTapped = true;
              },
            ),
          ),
        ),
      );

      // 等待动画完成
      await tester.pumpAndSettle();

      // 点击次要按钮（使用TextButton查找器）
      final secondaryButtons = find.byType(TextButton);
      await tester.tap(secondaryButtons.last);
      await tester.pump();

      expect(secondaryTapped, isTrue);
    });

    testWidgets('应该响应关闭按钮点击', (WidgetTester tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: true,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      // 等待动画完成
      await tester.pumpAndSettle();

      // 点击关闭按钮（使用IconButton查找器）
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('应该包含必要的UI元素', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: true,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
            ),
          ),
        ),
      );

      // 验证包含信息图标
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // 验证包含关闭图标
      expect(find.byIcon(Icons.close), findsOneWidget);

      // 验证包含两个TextButton
      expect(find.byType(TextButton), findsNWidgets(2));

      // 验证包含分隔符
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('应该有正确的颜色主题', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: true,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
            ),
          ),
        ),
      );

      // 验证容器背景色
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SecondaryJumpButton),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.amber.shade100);
    });
  });

  group('动画测试', () {
    testWidgets('UnreadIndicatorButton应该有滑入动画', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 5,
              isVisible: true,
            ),
          ),
        ),
      );

      // 验证SlideTransition存在
      expect(find.byType(SlideTransition), findsOneWidget);
    });

    testWidgets('SecondaryJumpButton应该有滑入动画', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecondaryJumpButton(
              isVisible: true,
              primaryText: '跳转到第一条',
              secondaryText: '跳转到最新',
            ),
          ),
        ),
      );

      // 验证SlideTransition存在
      expect(find.byType(SlideTransition), findsOneWidget);
    });

    testWidgets('UnreadIndicatorButton应该有脉冲动画', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnreadIndicatorButton(
              unreadCount: 5,
              isVisible: true,
              showAnimation: true,
            ),
          ),
        ),
      );

      // 验证AnimatedBuilder存在（用于脉冲动画）
      final animatedBuilders = find.byType(AnimatedBuilder);
      expect(animatedBuilders, findsWidgets);
      
      // 验证Transform存在（缩放动画）
      final transforms = find.byType(Transform);
      expect(transforms, findsWidgets);
    });
  });
}
