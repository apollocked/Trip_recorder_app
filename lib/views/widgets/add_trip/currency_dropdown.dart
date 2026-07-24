import 'package:flutter/material.dart';
import 'package:animations_in_flutter/model/currency.dart';

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onChanged;
  final ColorScheme colorScheme;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedCurrency,
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      items: CurrencyInfo.all
          .map(
            (c) => DropdownMenuItem(
              value: c.code,
              child: Text('${c.symbol}  ${c.code} — ${c.name}'),
            ),
          )
          .toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}
