import 'package:animations_in_flutter/model/expense.dart';
import 'package:animations_in_flutter/model/expense_category.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';

class CloudExpenseRepository {
  final SupabaseService _svc = SupabaseService();

  Future<List<Expense>> getExpenses(String tripId) async {
    if (!_svc.isLoggedIn) return [];
    final data = await _svc.client
        .from('cloud_expenses')
        .select()
        .eq('trip_id', tripId)
        .eq('user_id', _svc.userId!);
    return (data as List).map((m) => Expense.fromMap(m)).toList();
  }

  Future<Expense> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required String category,
  }) async {
    final expense = Expense(
      tripId: tripId,
      title: title,
      amount: amount,
      category: ExpenseCategory.fromString(category),
    );
    final map = expense.toMap()..['user_id'] = _svc.userId;
    await _svc.client.from('cloud_expenses').insert(map);
    return expense;
  }

  Future<void> deleteExpense(String id) async {
    await _svc.client
        .from('cloud_expenses')
        .delete()
        .eq('id', id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> deleteAllTripExpenses(String tripId) async {
    await _svc.client
        .from('cloud_expenses')
        .delete()
        .eq('trip_id', tripId)
        .eq('user_id', _svc.userId!);
  }
}
