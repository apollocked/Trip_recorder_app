import '../database/app_database.dart';
import '../../model/expense.dart';
import '../../model/expense_category.dart';

class ExpenseRepository {
  final AppDatabase _database = AppDatabase();

  Future<List<Expense>> getExpenses(String tripId) async {
    final db = await _database.database;
    final maps = await db.query(
      'expenses',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'rowid ASC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
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
    final db = await _database.database;
    await db.insert('expenses', expense.toMap());
    return expense;
  }

  Future<void> deleteExpense(String id) async {
    final db = await _database.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllTripExpenses(String tripId) async {
    final db = await _database.database;
    await db.delete('expenses', where: 'trip_id = ?', whereArgs: [tripId]);
  }
}
