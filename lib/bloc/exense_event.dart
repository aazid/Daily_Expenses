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
