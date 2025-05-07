import 'package:flutter/material.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/features/home/presentation/pages/home_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_search_page.dart';
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart';
import 'package:cc/features/contacts/presentation/pages/contacts_page.dart';
import 'package:cc/features/contacts/presentation/pages/friend_requests_page.dart';

// 应用路由
Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const AuthPage(),
  '/home': (context) => const HomePage(),
  '/chat': (context) => const ChatDetailPage(conversationId: '1'),
  '/chat/search': (context) => const ChatSearchPage(
        conversationId: '1',
        conversationName: '聊天搜索',
      ),
  '/chat/info': (context) => const ChatInfoPage(conversationId: '1'),
  '/contacts': (context) => const ContactsPage(),
  '/contacts/friend_requests': (context) => const FriendRequestsPage(),
};
