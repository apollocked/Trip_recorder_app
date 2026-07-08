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

Future<ExpenseDialogResult?> showExpenseDialog(BuildContext context) =>
    showDialog<ExpenseDialogResult>(
      context: context,
      builder: (_) => const _ExpenseDialog(),
    );

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog();

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  ExpenseCategory _selectedCategory = ExpenseCategory.other;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addExpense),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              decoration: InputDecoration(
                labelText: l10n.expenseTitle,
                hintText: l10n.addExpenseHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(labelText: l10n.expenseAmount),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(labelText: l10n.expenseCategory),
              items: ExpenseCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(_categoryLabel(l10n, cat)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.notNow),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final text = _amountController.text.trim();
            final amount = double.tryParse(text);
            if (title.isEmpty || amount == null || amount <= 0) return;
            Navigator.pop(
              context,
              ExpenseDialogResult(
                title: title,
                amount: amount,
                category: _selectedCategory,
              ),
            );
          },
          child: Text(l10n.addExpense),
        ),
      ],
    );
  }
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
