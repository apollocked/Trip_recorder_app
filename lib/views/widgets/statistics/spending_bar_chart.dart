import 'package:animations_in_flutter/model/trip.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingBarChart extends StatelessWidget {
  final List<Trip> trips;
  final ColorScheme colorScheme;

  const SpendingBarChart({
    super.key,
    required this.trips,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final byCurrency = _groupByCurrency(trips);
    return Column(
      children: byCurrency.entries.map((e) => _CurrencyChart(currency: e.key, items: e.value, colorScheme: colorScheme)).toList(),
    );
  }

  Map<String, List<Trip>> _groupByCurrency(List<Trip> trips) {
    final map = <String, List<Trip>>{};
    for (final t in trips) {
      final cur = t.currency.isNotEmpty ? t.currency : 'USD';
      map.putIfAbsent(cur, () => []).add(t);
    }
    return map;
  }
}

class _CurrencyChart extends StatelessWidget {
  final String currency;
  final List<Trip> items;
  final ColorScheme colorScheme;

  const _CurrencyChart({
    required this.currency,
    required this.items,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final data = <String, double>{};
    for (final t in items) {
      data[t.title] = (data[t.title] ?? 0) + t.price;
    }
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currency, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: colorScheme.inverseSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${sorted[group.x.toInt()].key}\n',
                        TextStyle(
                          color: colorScheme.onInverseSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toStringAsFixed(0)} ${currency}',
                            style: TextStyle(
                              color: colorScheme.onInverseSurface.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            sorted[idx].key.length > 6
                                ? '${sorted[idx].key.substring(0, 6)}...'
                                : sorted[idx].key,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
                ),
                borderData: FlBorderData(show: false),
                barGroups: sorted.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: colorScheme.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
