import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  static const _categoryColors = [
    Color(0xFF4FC3F7), Color(0xFFFF8A65), Color(0xFF81C784),
    Color(0xFF9575CD), Color(0xFFFFD54F), Color(0xFFA1887F),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tripProvider = context.watch<TripProvider>();
    final stats = tripProvider.statistics;
    final loc = AppLocalizations.of(context)!;
    final trips = tripProvider.trips;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.statistics, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(loc.totalTrips, '${stats['totalTrips']}', Icons.flight_takeoff_rounded, colorScheme.primary, colorScheme),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard(loc.totalSpent, '\$${(stats['totalSpent'] as double).toStringAsFixed(0)}', Icons.attach_money_rounded, Colors.green, colorScheme)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(loc.totalNights, '${stats['totalNights']}', Icons.bedtime_rounded, Colors.indigo, colorScheme)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard(loc.avgRating, (stats['avgRating'] as double) > 0 ? (stats['avgRating'] as double).toStringAsFixed(1) : '--', Icons.star_rounded, Colors.amber, colorScheme)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(loc.favorites, '${stats['likedCount']}', Icons.favorite_rounded, Colors.red, colorScheme)),
              ],
            ),
            if ((stats['categoryCounts'] as Map).isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(loc.tripsByCategory, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPieChart(stats['categoryCounts'] as Map, colorScheme),
            ],
            if (_computeSpendByDestination(trips).isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(loc.spendingByDestination, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildBarChart(trips, colorScheme, textTheme),
            ],
            if (stats['topCategory'] != null) ...[
              const SizedBox(height: 24),
              Text(loc.topCategory, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildCategoryBreakdown(context, stats['categoryCounts'] as Map, colorScheme),
            ],
            if (stats['topDestination'] != null) ...[
              const SizedBox(height: 24),
              _buildStatCard(loc.mostVisited, stats['topDestination'] as String, Icons.place_rounded, colorScheme.tertiary, colorScheme),
            ],
            const SizedBox(height: 32),
          ],
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

  Widget _buildPieChart(Map categoryCounts, ColorScheme colorScheme) {
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
              Text('$total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('total', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Trip> trips, ColorScheme colorScheme, TextTheme textTheme) {
    final data = _computeSpendByDestination(trips);
    final items = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
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
                  if (idx < 0 || idx >= items.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      items[idx].key.length > 6 ? '${items[idx].key.substring(0, 6)}...' : items[idx].key,
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
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withAlpha(30), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, Map categoryCounts, ColorScheme colorScheme) {
    final total = categoryCounts.values.cast<int>().fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Column(
        children: categoryCounts.entries.map<Widget>((entry) {
          final count = entry.value as int;
          final fraction = count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text(entry.key.label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction, minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 30, child: Text('$count', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
