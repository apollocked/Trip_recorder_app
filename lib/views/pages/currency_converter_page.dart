import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/services/currency_converter_service.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IQD';
  double? _result;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    setState(() => _isLoading = true);
    final converted = await CurrencyConverterService.convert(
      amount,
      _fromCurrency,
      _toCurrency,
    );
    if (mounted) {
      setState(() {
        _result = converted;
        _isLoading = false;
      });
    }
  }

  void _swap() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _result = null;
    });
    if (_amountController.text.isNotEmpty) _convert();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.currencyConverter,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.amount,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '100',
                        prefixText: '${CurrencyInfo.symbolFor(_fromCurrency)} ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _CurrencyPicker(
              label: loc.from,
              selected: _fromCurrency,
              onChanged: (v) {
                setState(() {
                  _fromCurrency = v;
                  _result = null;
                });
              },
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 8),
            Center(
              child: IconButton(
                icon: Icon(
                  Icons.swap_vert_rounded,
                  size: 28,
                  color: colorScheme.primary,
                ),
                onPressed: _swap,
                tooltip: loc.swap,
              ),
            ),
            _CurrencyPicker(
              label: loc.to,
              selected: _toCurrency,
              onChanged: (v) {
                setState(() {
                  _toCurrency = v;
                  _result = null;
                });
              },
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _convert,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.swap_horiz_rounded),
                label: Text(
                  loc.convert,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 28),
              Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          loc.convertedAmount,
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${CurrencyInfo.symbolFor(_toCurrency)} ${_result!.toStringAsFixed(2)}',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  final String label;
  final String selected;
  final ValueChanged<String> onChanged;
  final ColorScheme colorScheme;

  const _CurrencyPicker({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected,
                  isExpanded: true,
                  items: CurrencyInfo.all
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.code,
                          child: Text('${c.symbol}  ${c.code} — ${c.name}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
