import 'package:expense_tracker/bloc/expense_state.dart';
import 'package:expense_tracker/model/expense_model.dart';

abstract class ExpenseEvent {}

class LoadExpenses extends ExpenseEvent {}

class AddExpenses extends ExpenseEvent {
  final ExpenseModel expense;
  AddExpenses(this.expense);
}

class DeleteExpenses extends ExpenseEvent {
  final String id;
  DeleteExpenses(this.id);
}

class UpdateExpenses extends ExpenseEvent {
  final double newLimit;
  UpdateExpenses(this.newLimit);
}

class SetBudgetLimit extends ExpenseEvent {
  final double limit;
  SetBudgetLimit(this.limit);
}

class ClearAllExpenses extends ExpenseEvent {}

class SetMonthlyBudget extends ExpenseEvent {
  final double budget;
  SetMonthlyBudget(this.budget);
}

class ChangeLimitType extends ExpenseEvent {
  final LimitType limitType;
  ChangeLimitType(this.limitType);
}

class SetDailyLimit extends ExpenseEvent {
  final double limit;
  SetDailyLimit(this.limit);
}

class SetWeeklyLimit extends ExpenseEvent {
  final double limit;
  SetWeeklyLimit(this.limit);
}

class RemainingBudget extends ExpenseEvent {}
