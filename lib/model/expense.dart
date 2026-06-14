import 'package:uuid/uuid.dart';
import 'expense_category.dart';

class Expense {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final ExpenseCategory category;

  Expense({
    String? id,
    required this.tripId,
    required this.title,
    required this.amount,
    this.category = ExpenseCategory.other,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'title': title,
        'amount': amount,
        'category': category.name,
      };

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.fromString(map['category'] as String? ?? 'other'),
    );
  }
}
