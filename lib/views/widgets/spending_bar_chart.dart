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
    final data = _computeSpendByDestination(trips);
    final items = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = items.isNotEmpty ? items.first.value : 1.0;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(enabled: true),
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
                  if (idx < 0 || idx >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      items[idx].key.length > 6
                          ? '${items[idx].key.substring(0, 6)}...'
                          : items[idx].key,
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
          barGroups: items.asMap().entries.map((e) {
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
    );
  }

  Map<String, double> _computeSpendByDestination(List<Trip> trips) {
    final map = <String, double>{};
    for (final t in trips) {
      map[t.title] = (map[t.title] ?? 0) + t.price;
    }
    return map;
  }
}
