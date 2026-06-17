import 'package:flutter/material.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/services/currency_converter_service.dart';

class QuickConverter extends StatefulWidget {
  const QuickConverter({super.key});

  @override
  State<QuickConverter> createState() => _QuickConverterState();
}

class _QuickConverterState extends State<QuickConverter> {
  final _amountController = TextEditingController();
  String _from = 'USD';
  String _to = 'IQD';
  String? _result;
  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final amt = double.tryParse(_amountController.text);
    if (amt == null || amt <= 0) return;
    setState(() => _loading = true);
    final r = await CurrencyConverterService.convert(amt, _from, _to);
    if (mounted) setState(() { _result = '${CurrencyInfo.symbolFor(_to)}${r.toStringAsFixed(2)}'; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _dropdown(_from, (v) => setState(() { _from = v; _result = null; }), c)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: IconButton(
                      icon: Icon(Icons.swap_vert_rounded, size: 20, color: c.primary),
                      onPressed: () => setState(() { final t = _from; _from = _to; _to = t; _result = null; }),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  Expanded(child: _dropdown(_to, (v) => setState(() { _to = v; _result = null; }), c)),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '100',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: TextStyle(fontSize: 14, color: c.onSurface),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _loading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
                      : IconButton(
                          icon: Icon(Icons.check_circle_outline, color: c.primary),
                          onPressed: _convert,
                          visualDensity: VisualDensity.compact,
                        ),
                ],
              ),
              if (_result != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Text(loc.convertedAmount, style: TextStyle(fontSize: 12, color: c.onSurfaceVariant)),
                      const Spacer(),
                      Text(_result!, style: TextStyle(fontWeight: FontWeight.bold, color: c.primary, fontSize: 15)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String selected, ValueChanged<String> onChanged, ColorScheme c) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: c.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          isDense: true,
          style: TextStyle(fontSize: 13, color: c.onSurface),
          items: CurrencyInfo.all.map((cur) => DropdownMenuItem(
            value: cur.code,
            child: Text('${cur.symbol} ${cur.code}'),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}
