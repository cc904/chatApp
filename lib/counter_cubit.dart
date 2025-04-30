import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit 示例：计数器
class CounterCubit extends Cubit<int> {
  // 初始状态为0
  CounterCubit() : super(0);

  // 直接定义方法来改变状态
  void increment() => emit(state + 1);

  void decrement() => emit(state - 1);

  void reset() => emit(0);
}
