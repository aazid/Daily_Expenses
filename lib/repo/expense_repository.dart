import 'package:expense_tracker/model/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseRepository {
  static const String expensesKey = "expenses";
  static const String budgetKey = "budgetLimit";

  Future<List<ExpenseModel>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(expensesKey) ?? [];
    return data.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final data = expenses.map((e) => e.toJson()).toList();
    await prefs.setStringList(expensesKey, data);
  }

  Future<double> getBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(budgetKey) ?? 0;
  }

  Future<void> setBudgetLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(budgetKey, limit);
  }
}
