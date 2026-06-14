enum ExpenseCategory {
  hotel,
  food,
  transport,
  activities,
  shopping,
  other;

  String get label {
    switch (this) {
      case ExpenseCategory.hotel:
        return 'Hotel';
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.activities:
        return 'Activities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
