import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/expense.dart';
import 'package:animations_in_flutter/model/expense_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/common/confirmation_dialog.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final String tripId;
  final String currencySymbol;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final VoidCallback onDeleted;
  final Color Function(ExpenseCategory, ColorScheme) categoryColor;
  final String Function(AppLocalizations, ExpenseCategory) categoryLabel;
  final IconData Function(ExpenseCategory) categoryIcon;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.tripId,
    required this.currencySymbol,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
    required this.onDeleted,
    required this.categoryColor,
    required this.categoryLabel,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showConfirmationDialog(
        context: context,
        title: l10n.confirmDeleteTitle(expense.title),
        message: l10n.confirmDeleteMessage,
        icon: Icons.delete_rounded,
      ),
      background: Container(
        alignment: Directionality.of(context) == TextDirection.rtl
            ? Alignment.centerLeft
            : Alignment.centerRight,
        padding: EdgeInsets.only(
          right: Directionality.of(context) == TextDirection.rtl ? 0 : 20,
          left: Directionality.of(context) == TextDirection.rtl ? 20 : 0,
        ),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_rounded, color: colorScheme.onError),
      ),
      onDismissed: (_) async {
        await context.read<TripProvider>().deleteExpense(tripId, expense.id);
        onDeleted();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor(
                  expense.category,
                  colorScheme,
                ).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryIcon(expense.category),
                size: 18,
                color: categoryColor(expense.category, colorScheme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    categoryLabel(l10n, expense.category),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$currencySymbol${expense.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
