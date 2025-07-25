import 'package:flutter/material.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:cc/core/services/log_service.dart';
import 'dart:async';
import 'package:cc/core/utils/ui_notification_helper.dart';

class DatePickerUtility {
  final LogService _logger = LogService.instance;
  final String conversationId;
  final Set<DateTime> _messageDates = {};
  final Set<String> _loadedMonths = {};

  DatePickerUtility({required this.conversationId});

  // 添加messageDates的getter方法
  Set<DateTime> get messageDates => _messageDates;

  // 检查指定日期是否有消息
  bool hasMessagesOnDate(DateTime date) {
    // 提取日期部分（去掉时间）
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _messageDates.contains(dateOnly);
  }

  // 查找有消息的初始日期
  DateTime? findInitialDateWithMessages() {
    if (_messageDates.isEmpty) return null;

    // 查找离今天最近的有消息的日期
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    // 如果今天有消息,则返回今天
    if (_messageDates.contains(todayDateOnly)) {
      return today;
    }

    // 按日期从近到远排序
    final sortedDates = _messageDates.toList()..sort((a, b) => b.compareTo(a)); // 降序排序

    return sortedDates.first; // 返回最近的一个日期
  }

  // 加载消息日期 - 只加载指定月份的消息日期
  Future<void> loadMessageDates({DateTime? targetMonth}) async {
    try {
      // 如果没有指定月份,则使用当前月份
      final now = DateTime.now();
      final month = targetMonth ?? DateTime(now.year, now.month);

      // 构建月份的唯一标识,用于检查是否已加载
      final monthKey = '${month.year}-${month.month}';

      // 检查该月份是否已加载过,避免重复加载
      if (_loadedMonths.contains(monthKey)) {
        _logger.d('月份已加载过,跳过', extra: {'monthKey': monthKey});
        return;
      }

      _logger.i('加载指定月份的消息日期', extra: {'year': month.year, 'month': month.month});

      // 从数据库获取消息日期
      final db = AppDatabase.instance;
      Set<DateTime> dates = {};

      // 计算月份的起止日期范围
      final startDate = DateTime(month.year, month.month, 1);
      // 使用正确的方法计算月末
      final endDate = DateTime(month.year, month.month + 1, 1).subtract(const Duration(days: 1));

      _logger.d('查询日期范围', extra: {'start': startDate.toString(), 'end': endDate.toString()});

      // 查询指定时间范围内的消息
      final messages = await (db.select(db.messages)
            ..where((tbl) => tbl.conversationId.equals(conversationId))
            ..where((tbl) => tbl.createdAt.isBetweenValues(startDate, endDate.add(const Duration(days: 1)))))
          .get();

      // 提取日期
      for (var message in messages) {
        dates.add(DateTime(
          message.createdAt.year,
          message.createdAt.month,
          message.createdAt.day,
        ));
      }

      // 显示找到的日期数量
      _logger.i('找到唯一日期', extra: {'count': dates.length});

      // 添加到现有日期集合,保留之前加载的其他月份日期
      _messageDates.addAll(dates);
      // 记录该月份已加载
      _loadedMonths.add(monthKey);
    } catch (error) {
      _logger.e('从数据库加载消息日期失败', error: error, stackTrace: StackTrace.current);
      throw Exception('加载消息日期失败: $error');
    }
  }

  // 预加载最近3个月的消息日期
  Future<void> preloadRecentMessageDates() async {
    try {
      final now = DateTime.now();

      // 加载当前月份
      await loadMessageDates(targetMonth: DateTime(now.year, now.month));

      // 计算前两个月,处理年份变化
      DateTime prevMonth1;
      DateTime prevMonth2;

      // 处理当前是1月或2月的情况
      if (now.month == 1) {
        prevMonth1 = DateTime(now.year - 1, 12);
        prevMonth2 = DateTime(now.year - 1, 11);
      } else if (now.month == 2) {
        prevMonth1 = DateTime(now.year, 1);
        prevMonth2 = DateTime(now.year - 1, 12);
      } else {
        prevMonth1 = DateTime(now.year, now.month - 1);
        prevMonth2 = DateTime(now.year, now.month - 2);
      }

      // 加载前两个月
      await loadMessageDates(targetMonth: prevMonth1);
      await loadMessageDates(targetMonth: prevMonth2);

      _logger.i('预加载了最近3个月的消息日期',
          extra: {'current': '${now.year}年${now.month}月', 'prev1': '${prevMonth1.year}年${prevMonth1.month}月', 'prev2': '${prevMonth2.year}年${prevMonth2.month}月'});
    } catch (error) {
      _logger.e('预加载最近消息日期失败', error: error, stackTrace: StackTrace.current);
      throw Exception('预加载最近消息日期失败: $error');
    }
  }

  // 日期选择器
  Future<DateTime?> selectDate(BuildContext context) async {
    final Completer<DateTime?> completer = Completer<DateTime?>();

    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        _logger.i('显示加载指示器');
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // 非阻塞式延迟5秒以模拟加载过程
    // await Future.delayed(const Duration(seconds: 5));

    try {
      // 加载当前月份的日期
      final now = DateTime.now();
      await loadMessageDates(targetMonth: DateTime(now.year, now.month));

      // 如果没有找到任何日期,显示提示
      if (_messageDates.isEmpty) {
        // 关闭加载指示器
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // 使用UINotificationHelper显示没有消息的提示
        UINotificationHelper.showWarning('未找到任何聊天记录', duration: const Duration(seconds: 2));

        completer.complete(null);
        return completer.future;
      }

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      // 发生错误,关闭加载指示器并显示错误
      _logger.e('加载消息日期失败', error: error, stackTrace: StackTrace.current);
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (navError) {
          // 忽略可能的导航错误
        }

        // 使用UINotificationHelper显示错误
        UINotificationHelper.showError('加载消息日期失败: $error', duration: const Duration(seconds: 4));
      }
      completer.complete(null);
      return completer.future;
    }

    // 使用自定义日期选择器,点击日期后直接返回选中的日期
    if (!context.mounted) {
      completer.complete(null);
      return completer.future;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 350.0, // 限制最大宽度
            ),
            child: Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Colors.white,
                ),
              ),
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '选择日期',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              completer.complete(null);
                            },
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 320,
                        child: CalendarDatePicker(
                          initialDate: findInitialDateWithMessages() ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          selectableDayPredicate: (DateTime day) {
                            // 只有有消息的日期才可选
                            return hasMessagesOnDate(day);
                          },
                          onDateChanged: (date) {
                            // 点击日期后立即关闭对话框并返回选中的日期
                            Navigator.of(dialogContext).pop();
                            completer.complete(date);
                          },
                          onDisplayedMonthChanged: (DateTime month) {
                            // 当显示的月份改变时,加载该月的消息日期
                            _logger.i('显示月份已更改至', extra: {'year': month.year, 'month': month.month});

                            // 加载当前显示的月份数据
                            loadMessageDates(targetMonth: month);

                            // 预加载附近月份数据,处理年份边界问题
                            DateTime nextMonth;
                            DateTime prevMonth;

                            // 处理12月到下一年1月
                            if (month.month == 12) {
                              nextMonth = DateTime(month.year + 1, 1, 1);
                            } else {
                              nextMonth = DateTime(month.year, month.month + 1, 1);
                            }

                            // 处理1月到上一年12月
                            if (month.month == 1) {
                              prevMonth = DateTime(month.year - 1, 12, 1);
                            } else {
                              prevMonth = DateTime(month.year, month.month - 1, 1);
                            }

                            // 加载前后月份数据（如果在合理范围内）
                            if (prevMonth.year >= 2000) {
                              loadMessageDates(targetMonth: prevMonth);
                            }

                            if (nextMonth.isBefore(DateTime.now())) {
                              loadMessageDates(targetMonth: nextMonth);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return completer.future;
  }
}
