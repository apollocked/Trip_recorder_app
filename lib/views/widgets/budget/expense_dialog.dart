import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/expense_category.dart';

class ExpenseDialogResult {
  final String title;
  final double amount;
  final ExpenseCategory category;
  ExpenseDialogResult({
    required this.title,
    required this.amount,
    required this.category,
  });
}

Future<ExpenseDialogResult?> showExpenseDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  ExpenseCategory selectedCategory = ExpenseCategory.other;

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(l10n.addExpense),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.expenseTitle,
                hintText: l10n.addExpenseHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(labelText: l10n.expenseAmount),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: selectedCategory,
              decoration: InputDecoration(labelText: l10n.expenseCategory),
              items: ExpenseCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(_categoryLabel(l10n, cat)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setDialogState(() => selectedCategory = val);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.notNow),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              Navigator.pop(ctx, {
                'title': titleController.text.trim(),
                'amount': amount,
                'category': selectedCategory.name,
              });
            },
            child: Text(l10n.addExpense),
          ),
        ],
      ),
    ),
  );

  titleController.dispose();
  amountController.dispose();

  if (result != null) {
    return ExpenseDialogResult(
      title: result['title'],
      amount: result['amount'],
      category: ExpenseCategory.values.firstWhere(
        (c) => c.name == result['category'],
      ),
    );
  }
  return null;
}

String _categoryLabel(AppLocalizations l10n, ExpenseCategory cat) {
  switch (cat) {
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
