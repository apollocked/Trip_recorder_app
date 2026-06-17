import 'package:flutter/material.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';

class TotalExpenseCard extends StatelessWidget {
  final String currencySymbol;
  final double totalAmount;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const TotalExpenseCard({
    super.key,
    required this.currencySymbol,
    required this.totalAmount,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('$currencySymbol${totalAmount.toStringAsFixed(2)}',
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
