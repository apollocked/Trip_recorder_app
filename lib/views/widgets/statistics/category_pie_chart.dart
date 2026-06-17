import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map categoryCounts;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const CategoryPieChart({
    super.key,
    required this.categoryCounts,
    required this.colorScheme,
    required this.l10n,
  });

  static const _categoryColors = [
    Color(0xFF4FC3F7),
    Color(0xFFFF8A65),
    Color(0xFF81C784),
    Color(0xFF9575CD),
    Color(0xFFFFD54F),
    Color(0xFFA1887F),
  ];

  @override
  Widget build(BuildContext context) {
    final total = categoryCounts.values.cast<int>().fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final entries = categoryCounts.entries.toList().asMap().entries.map((e) {
      final count = e.value.value as int;
      return PieChartSectionData(
        color: _categoryColors[e.key % _categoryColors.length],
        value: count.toDouble(),
        title: '$count',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(PieChartData(sections: entries, centerSpaceRadius: 45)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$total',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(l10n.totalLabel,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
