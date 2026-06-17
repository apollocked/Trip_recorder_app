import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/expense.dart';
import 'package:animations_in_flutter/model/expense_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/budget/category_budget_bars.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/budget/expense_dialog.dart';
import 'package:animations_in_flutter/views/widgets/budget/expense_tile.dart';
import 'package:animations_in_flutter/views/widgets/budget/total_expense_card.dart';

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
    try {
      final provider = context.read<TripProvider>();
      final expenses = await provider.getExpenses(widget.tripId);
      final trip = provider.getTripById(widget.tripId);
      if (mounted) {
        setState(() {
          _expenses = expenses;
          _isLoading = false;
          _currencySymbol = trip != null
              ? CurrencyInfo.symbolFor(trip.currency)
              : '\$';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSavingTrip(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showAddExpenseDialog() async {
    final result = await showExpenseDialog(context);
    if (result != null && mounted) {
      await context.read<TripProvider>().addExpense(
        tripId: widget.tripId,
        title: result.title,
        amount: result.amount,
        category: result.category.name,
      );
      _loadExpenses();
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
    final maxCatAmount = categoryTotals.values.isEmpty
        ? 1.0
        : categoryTotals.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.budgetBreakdown,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
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
                    TotalExpenseCard(
                      currencySymbol: _currencySymbol,
                      totalAmount: totalAmount,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                    if (categoryTotals.isNotEmpty)
                      CategoryBudgetBars(
                        categoryTotals: categoryTotals,
                        maxCatAmount: maxCatAmount,
                        currencySymbol: _currencySymbol,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        l10n: l10n,
                        categoryColor: _categoryColor,
                        categoryLabel: _categoryLabel,
                      ),
                    Text(
                      l10n.expenseTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_expenses.isEmpty)
                      SizedBox(
                        height: 160,
                        child: EmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: l10n.noItemsYet,
                          subtitle: l10n.emptyBudgetSubtitle,
                          action: FilledButton.tonalIcon(
                            onPressed: _showAddExpenseDialog,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(l10n.addExpense),
                          ),
                        ),
                      )
                    else
                      ..._expenses.map(
                        (expense) => ExpenseTile(
                          expense: expense,
                          tripId: widget.tripId,
                          currencySymbol: _currencySymbol,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          l10n: l10n,
                          onDeleted: _loadExpenses,
                          categoryColor: _categoryColor,
                          categoryLabel: _categoryLabel,
                          categoryIcon: _categoryIcon,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  static Color _categoryColor(ExpenseCategory cat, ColorScheme cs) =>
      AppColors.budgetCategoryColor(cat);

  static String _categoryLabel(AppLocalizations l10n, ExpenseCategory cat) {
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

  static IconData _categoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.hotel:
        return Icons.hotel_rounded;
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.activities:
        return Icons.sports_esports_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.other:
        return Icons.receipt_rounded;
    }
  }
}
