import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/expense.dart';
import 'package:animations_in_flutter/model/expense_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';

class BudgetPage extends StatefulWidget {
  final String tripId;
  const BudgetPage({super.key, required this.tripId});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final provider = context.read<TripProvider>();
    final expenses = await provider.getExpenses(widget.tripId);
    final trip = provider.getTripById(widget.tripId);
    if (mounted) {
      setState(() {
        _expenses = expenses;
        _isLoading = false;
        _currencySymbol = trip != null ? CurrencyInfo.symbolFor(trip.currency) : '\$';
      });
    }
  }

  Future<void> _showAddExpenseDialog() async {
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
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(ctx)!.notNow)),
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

    if (result != null && mounted) {
      await context.read<TripProvider>().addExpense(
        tripId: widget.tripId,
        title: result['title'],
        amount: result['amount'],
        category: result['category'],
      );
      _loadExpenses();
    }
  }

  String _categoryLabel(AppLocalizations l10n, ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.hotel: return l10n.categoryHotel;
      case ExpenseCategory.food: return l10n.categoryFood;
      case ExpenseCategory.transport: return l10n.categoryTransport;
      case ExpenseCategory.activities: return l10n.categoryActivities;
      case ExpenseCategory.shopping: return l10n.categoryShopping;
      case ExpenseCategory.other: return l10n.categoryOther;
    }
  }

  Color _categoryColor(ExpenseCategory cat, ColorScheme cs) {
    switch (cat) {
      case ExpenseCategory.hotel: return Colors.blue;
      case ExpenseCategory.food: return Colors.orange;
      case ExpenseCategory.transport: return Colors.purple;
      case ExpenseCategory.activities: return Colors.green;
      case ExpenseCategory.shopping: return Colors.pink;
      case ExpenseCategory.other: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final totalAmount = _expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final categoryTotals = <ExpenseCategory, double>{};
    for (final e in _expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final maxCatAmount = categoryTotals.values.isEmpty ? 1.0 : categoryTotals.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.budgetBreakdown, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddExpenseDialog,
            tooltip: l10n.addExpense,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(80),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(l10n.totalExpenses, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('$_currencySymbol${totalAmount.toStringAsFixed(2)}',
                              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (categoryTotals.isNotEmpty) ...[
                      Text(l10n.expenseCategory, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...categoryTotals.entries.map((entry) {
                        final fraction = maxCatAmount > 0 ? entry.value / maxCatAmount : 0.0;
                        final color = _categoryColor(entry.key, colorScheme);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(_categoryLabel(l10n, entry.key),
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
                                child: Text('$_currencySymbol${entry.value.toStringAsFixed(0)}',
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
                    Text(l10n.expenseTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_expenses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(l10n.noItemsYet, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ),
                      )
                    else
                      ...List.generate(_expenses.length, (index) {
                        final expense = _expenses[index];
                        return Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.delete_rounded, color: colorScheme.onError),
                          ),
                          onDismissed: (_) async {
                            await context.read<TripProvider>().deleteExpense(widget.tripId, expense.id);
                            _loadExpenses();
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
                                    color: _categoryColor(expense.category, colorScheme).withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _categoryIcon(expense.category),
                                    size: 18,
                                    color: _categoryColor(expense.category, colorScheme),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(expense.title, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                                      Text(_categoryLabel(l10n, expense.category),
                                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Text('$_currencySymbol${expense.amount.toStringAsFixed(0)}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _categoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.hotel: return Icons.hotel_rounded;
      case ExpenseCategory.food: return Icons.restaurant_rounded;
      case ExpenseCategory.transport: return Icons.directions_car_rounded;
      case ExpenseCategory.activities: return Icons.sports_esports_rounded;
      case ExpenseCategory.shopping: return Icons.shopping_bag_rounded;
      case ExpenseCategory.other: return Icons.receipt_rounded;
    }
  }
}
