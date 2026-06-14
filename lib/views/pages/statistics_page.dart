import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tripProvider = context.watch<TripProvider>();
    final stats = tripProvider.statistics;
    final loc = AppLocalizations.of(context)!;

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
