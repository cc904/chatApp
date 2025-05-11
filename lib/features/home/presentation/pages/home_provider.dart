import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:cc/features/home/presentation/pages/home_page.dart';

/// 为HomePage提供必要的仓库和状态管理器
///
/// 这个包装器在用户登录成功后创建,负责初始化用户数据相关的仓库和状态管理器
/// 优点是避免在登录前访问未初始化的数据库
class HomeProvider extends StatelessWidget {
  const HomeProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = LogService.instance;
    final authState = context.read<AuthCubit>().state;

    // 确保DatabaseInitializer已经初始化
    if (!DatabaseInitializer.isInitialized) {
      logger.e('数据库未初始化,无法加载Home页面');
      return const Scaffold(
        body: Center(
          child: Text('数据库未初始化,请重新登录'),
        ),
      );
    }

    // 获取当前用户ID
    final userId = authState.userId;
    if (userId == null || userId.isEmpty) {
      logger.e('用户ID为空,无法加载Home页面');
      return const Scaffold(
        body: Center(
          child: Text('用户信息缺失,请重新登录'),
        ),
      );
    }

    logger.i('初始化Home页面提供者', extra: {'userId': userId});

    return MultiRepositoryProvider(
      providers: [
        // 提供仓库
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(
            isar: DatabaseInitializer.isar,
            currentUserId: userId,
          ),
        ),
        RepositoryProvider<ContactsRepository>(
          create: (context) => ContactsRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 添加ChatCubit
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(
              repository: context.read<ChatRepository>(),
              contactsRepository: context.read<ContactsRepository>(),
            ),
          ),
          // 添加ContactsCubit
          BlocProvider<ContactsCubit>(
            create: (context) => ContactsCubit(
              repository: context.read<ContactsRepository>(),
            ),
          ),
        ],
        child: const HomePage(),
      ),
    );
  }
}
