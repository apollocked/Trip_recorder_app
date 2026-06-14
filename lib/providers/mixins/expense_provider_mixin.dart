import 'package:flutter/material.dart';
import '../../data/repositories/expense_repository.dart';
import '../../model/expense.dart';

mixin ExpenseProviderMixin on ChangeNotifier {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final Map<String, List<Expense>> _expensesCache = {};

  Future<List<Expense>> getExpenses(String tripId) async {
    if (_expensesCache.containsKey(tripId)) return _expensesCache[tripId]!;
    final expenses = await _expenseRepository.getExpenses(tripId);
    _expensesCache[tripId] = expenses;
    return expenses;
  }

  Future<void> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required String category,
  }) async {
    final expense = await _expenseRepository.addExpense(
      tripId: tripId,
      title: title,
      amount: amount,
      category: category,
    );
    _expensesCache[tripId] = [...(_expensesCache[tripId] ?? []), expense];
    notifyListeners();
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    await _expenseRepository.deleteExpense(expenseId);
    final list = _expensesCache[tripId];
    if (list != null) {
      list.removeWhere((e) => e.id == expenseId);
      notifyListeners();
    }
  }

  Future<void> deleteAllTripExpenses(String tripId) async {
    await _expenseRepository.deleteAllTripExpenses(tripId);
    _expensesCache.remove(tripId);
    notifyListeners();
  }

  void clearExpensesCache(String tripId) {
    _expensesCache.remove(tripId);
  }
}
