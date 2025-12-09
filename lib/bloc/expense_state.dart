import 'package:expense_tracker/model/expense_model.dart';

enum LimitType { daily, weekly, monthly }

class ExpenseState {
  final List<ExpenseModel> expenses;

  final double monthlyLimit;
  final double weeklyLimit;
  final double dailyLimit;
  final LimitType activeLimitType;
  final double saving;

  final bool overLimit;

  ExpenseState({
    this.expenses = const [],
    this.monthlyLimit = 0,
    this.weeklyLimit = 0,
    this.dailyLimit = 0,
    this.activeLimitType = LimitType.monthly,
    this.saving = 0,
    this.overLimit = false,
  });

  double get currentLimit {
    switch (activeLimitType) {
      case LimitType.daily:
        return dailyLimit;
      case LimitType.weekly:
        return weeklyLimit;
      case LimitType.monthly:
        return monthlyLimit;
    }
  }

  double get currentPeriodTotal {
    final now = DateTime.now();

    switch (activeLimitType) {
      case LimitType.daily:
        return expenses
            .where(
              (e) =>
                  !e.isIncome &&
                  e.date.year == now.year &&
                  e.date.month == now.month &&
                  e.date.day == now.day,
            )
            .fold(0.0, (sum, e) => sum + e.amount);

      case LimitType.weekly:
        final weeekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weeekStart.add(Duration(days: 7));
        return expenses
            .where(
              (e) =>
                  !e.isIncome &&
                  e.date.isAfter(weeekStart.subtract(Duration(days: 1))) &&
                  e.date.isBefore(weekEnd),
            )
            .fold(0.0, (sum, e) => sum + e.amount);

      case LimitType.monthly:
        return expenses
            .where(
              (e) =>
                  !e.isIncome &&
                  e.date.year == now.year &&
                  e.date.month == now.month,
            )
            .fold(0.0, (sum, e) => sum + e.amount);
    }
  }

  double get remainingBudget {
    return (currentLimit - currentPeriodTotal).clamp(0, double.infinity);
  }

  String get periodText {
    switch (activeLimitType) {
      case LimitType.daily:
        return "Today's Total";
      case LimitType.weekly:
        return "Weekly Total";
      case LimitType.monthly:
        return "Monthly Total";
    }
  }

  ExpenseState copyWith({
    List<ExpenseModel>? expenses,
    double? monthlyTotal,
    double? monthlyLimit,
    bool? overLimit,
    double? dailyLimit,
    double? weeklyLimit,
    LimitType? activeLimitType,
    double? saving,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,

      overLimit: overLimit ?? this.overLimit,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      activeLimitType: activeLimitType ?? this.activeLimitType,
      saving: saving ?? this.saving,
    );
  }

  double get monthlyTotal => currentPeriodTotal;
}
