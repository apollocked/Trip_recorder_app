import '../core/l10n/app_localizations.dart';

enum ExpenseCategory {
  hotel,
  food,
  transport,
  activities,
  shopping,
  other;

  String label(AppLocalizations l10n) {
    switch (this) {
      case ExpenseCategory.hotel:
        return l10n.categoryHotel;
      case ExpenseCategory.food:
        return l10n.categoryFood;
      case ExpenseCategory.transport:
        return l10n.categoryTransport;
      case ExpenseCategory.activities:
        return l10n.categoryActivities;
      case ExpenseCategory.shopping:
        return l10n.categoryShopping;
      case ExpenseCategory.other:
        return l10n.categoryOther;
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
