import 'package:expense_tracker/bloc/exense_event.dart';
import 'package:expense_tracker/bloc/expense_state.dart';
import 'package:expense_tracker/model/expense_model.dart';
import 'package:expense_tracker/repo/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;
  ExpenseBloc(this.repository)
    : super(ExpenseState(expenses: [], monthlyLimit: 0, overLimit: false)) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpenses>(_onAddExpenses);
    on<DeleteExpenses>(_onDeleteExpenses);
    on<UpdateExpenses>(_onUpdateExpenses);
    on<SetBudgetLimit>(_onSetBudgetLimit);
    on<ClearAllExpenses>(_onClearAllExpenses);
    on<SetMonthlyBudget>(_onSetMonthlyBudget);
    on<ChangeLimitType>(_onChangeLimitType);
    on<SetDailyLimit>(_onSetDailyLimit);
    on<SetWeeklyLimit>(_onSetWeeklyLimit);
    on<RemainingBudget>(_onRemainingBudget);
  }

  void _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    final expenses = await repository.getExpenses();
    final limit = await repository.getBudgetLimit();
    final dailyLimit = await repository.getDailyLimit();
    final weeklyLimit = await repository.getWeeklyLimit();
    final limitType = await repository.getLimitType();
    final savings = await repository.getSavings();
    final total = _calculateMonthlyTotal(expenses);

    emit(
      state.copyWith(
        expenses: expenses,
        monthlyLimit: limit,
        dailyLimit: dailyLimit,
        weeklyLimit: weeklyLimit,
        activeLimitType: limitType,
        saving: savings,
        monthlyTotal: total,
        overLimit: limit > 0 && total > limit,
      ),
    );
  }

  void _onAddExpenses(AddExpenses event, Emitter<ExpenseState> emit) async {
    final expenses = List<ExpenseModel>.from(state.expenses)
      ..add(event.expense);
    await repository.saveExpenses(expenses);

    final total = _calculateMonthlyTotal(expenses);
    emit(
      state.copyWith(
        expenses: expenses,
        monthlyTotal: total,
        overLimit: state.monthlyLimit > 0 && total > state.monthlyLimit,
      ),
    );
  }

  void _onDeleteExpenses(
    DeleteExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final expenses = List<ExpenseModel>.from(state.expenses)
      ..removeWhere((e) => e.id == event.id);
    await repository.saveExpenses(expenses);

    final total = _calculateMonthlyTotal(expenses);
    emit(
      state.copyWith(
        expenses: expenses,
        monthlyTotal: total,
        overLimit: state.monthlyLimit > 0 && total > state.monthlyLimit,
      ),
    );
  }

  void _onUpdateExpenses(
    UpdateExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    await repository.setBudgetLimit(event.newLimit);
    emit(
      state.copyWith(
        monthlyLimit: event.newLimit,
        overLimit: event.newLimit > 0 && state.monthlyTotal > event.newLimit,
      ),
    );
  }

  void _onSetBudgetLimit(
    SetBudgetLimit event,
    Emitter<ExpenseState> emit,
  ) async {
    await repository.setBudgetLimit(event.limit);
    emit(
      state.copyWith(
        monthlyLimit: event.limit,
        overLimit: event.limit > 0 && state.monthlyTotal > event.limit,
      ),
    );
  }

  void _onClearAllExpenses(
    ClearAllExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    await repository.saveExpenses([]);
    await repository.setBudgetLimit(0);
    emit(
      state.copyWith(
        expenses: [],
        monthlyTotal: 0,
        monthlyLimit: 0,
        overLimit: false,
      ),
    );
  }

  void _onSetMonthlyBudget(
    SetMonthlyBudget event,
    Emitter<ExpenseState> emit,
  ) async {
    await repository.setBudgetLimit(event.budget);
    emit(
      state.copyWith(
        monthlyLimit: event.budget,
        overLimit: event.budget > 0 && state.monthlyTotal > event.budget,
      ),
    );
  }

  void _onChangeLimitType(
    ChangeLimitType event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(activeLimitType: event.limitType));
    await repository.saveLimitType(event.limitType);
  }

  void _onSetDailyLimit(SetDailyLimit event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(dailyLimit: event.limit));
    await repository.saveDailyLimit(event.limit);
  }

  void _onSetWeeklyLimit(
    SetWeeklyLimit event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(weeklyLimit: event.limit));
    await repository.saveWeeklyLimit(event.limit);
  }

  void _onRemainingBudget(
    RemainingBudget event,
    Emitter<ExpenseState> emit,
  ) async {
    final remaining = state.remainingBudget;
    if (remaining > 0) {
      final newSaving = state.saving + remaining;
      emit(state.copyWith(saving: newSaving));
      await repository.saveSavings(newSaving);
      print('Saved $remaining to savings! Total savings: $newSaving');
    }
  }

  double _calculateMonthlyTotal(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    return expenses
        .where(
          (v) =>
              v.date.month == now.month &&
              v.date.year == now.year &&
              !v.isIncome,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }
}
