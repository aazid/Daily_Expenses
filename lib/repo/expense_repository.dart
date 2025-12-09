import 'package:expense_tracker/model/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/bloc/expense_state.dart';

class ExpenseRepository {
  static const String expensesKey = "expenses";
  static const String budgetKey = "budgetLimit";
  static const String dailyLimitKey = "dailyLimit";
  static const String weeklyLimitKey = "weeklyLimit";
  static const String savingsKey = "savings";
  static const String limitTypeKey = "limitType";

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

  Future<double> getDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(dailyLimitKey) ?? 0;
  }

  Future<void> saveDailyLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(dailyLimitKey, limit);
  }

  Future<double> getWeeklyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(weeklyLimitKey) ?? 0;
  }

  Future<void> saveWeeklyLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(weeklyLimitKey, limit);
  }

  Future<double> getSavings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(savingsKey) ?? 0;
  }

  Future<void> saveSavings(double savings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(savingsKey, savings);
  }

  Future<LimitType> getLimitType() async {
    final prefs = await SharedPreferences.getInstance();
    final typeString = prefs.getString(limitTypeKey);
    if (typeString == null) return LimitType.monthly;

    if (typeString.contains('daily')) return LimitType.daily;
    if (typeString.contains('weekly')) return LimitType.weekly;
    return LimitType.monthly;
  }

  Future<void> saveLimitType(LimitType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(limitTypeKey, type.toString());
  }
}
