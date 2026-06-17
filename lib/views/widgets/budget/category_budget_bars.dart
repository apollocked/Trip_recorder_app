import 'package:flutter/material.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/expense_category.dart';

class CategoryBudgetBars extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  final double maxCatAmount;
  final String currencySymbol;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final Color Function(ExpenseCategory, ColorScheme) categoryColor;
  final String Function(AppLocalizations, ExpenseCategory) categoryLabel;

  const CategoryBudgetBars({
    super.key,
    required this.categoryTotals,
    required this.maxCatAmount,
    required this.currencySymbol,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
    required this.categoryColor,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.expenseCategory, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...categoryTotals.entries.map((entry) {
          final fraction = maxCatAmount > 0 ? entry.value / maxCatAmount : 0.0;
          final color = categoryColor(entry.key, colorScheme);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(categoryLabel(l10n, entry.key),
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 10,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text('$currencySymbol${entry.value.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Divider(color: colorScheme.outlineVariant.withAlpha(128)),
        const SizedBox(height: 8),
      ],
    );
  }
}
