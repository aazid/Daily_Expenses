import 'package:expense_tracker/model/expense_model.dart';

class ExpenseState {
  final List<ExpenseModel> expenses;
  final double monthlyTotal;
  final double monthlyLimit;
  final bool overLimit;
  ExpenseState({
    required this.expenses,
    required this.monthlyLimit,
    required this.monthlyTotal,
    required this.overLimit,
  });
  ExpenseState copyWith({
    List<ExpenseModel>? expenses,
    double? monthlyTotal,
    double? monthlyLimit,
    bool? overLimit,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      monthlyTotal: monthlyTotal ?? this.monthlyTotal,
      overLimit: overLimit ?? this.overLimit,
    );
  }
}
