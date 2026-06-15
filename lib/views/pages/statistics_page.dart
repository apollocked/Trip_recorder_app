import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/expense_category.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/category_breakdown.dart';
import 'package:animations_in_flutter/views/widgets/category_pie_chart.dart';
import 'package:animations_in_flutter/views/widgets/spending_bar_chart.dart';
import 'package:animations_in_flutter/views/widgets/stat_card.dart';
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
            StatCard(title: loc.totalTrips, value: '${stats['totalTrips']}', icon: Icons.flight_takeoff_rounded, iconColor: colorScheme.primary, colorScheme: colorScheme),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StatCard(title: loc.totalSpent, value: (stats['totalSpent'] as double).toStringAsFixed(0), icon: Icons.attach_money_rounded, iconColor: Colors.green, colorScheme: colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: loc.totalNights, value: '${stats['totalNights']}', icon: Icons.bedtime_rounded, iconColor: Colors.indigo, colorScheme: colorScheme)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StatCard(title: loc.avgRating, value: (stats['avgRating'] as double) > 0 ? (stats['avgRating'] as double).toStringAsFixed(1) : loc.notRated, icon: Icons.star_rounded, iconColor: Colors.amber, colorScheme: colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: loc.favorites, value: '${stats['likedCount']}', icon: Icons.favorite_rounded, iconColor: Colors.red, colorScheme: colorScheme)),
            ]),
            if ((stats['categoryCounts'] as Map).isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(loc.tripsByCategory, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              CategoryPieChart(categoryCounts: stats['categoryCounts'] as Map, colorScheme: colorScheme, l10n: loc),
            ],
            if (_spendByDestination(trips).isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(loc.spendingByDestination, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SpendingBarChart(trips: trips, colorScheme: colorScheme),
            ],
            if (stats['topCategory'] != null) ...[
              const SizedBox(height: 24),
              Text(loc.topCategory, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CategoryBreakdown(categoryCounts: stats['categoryCounts'] as Map<ExpenseCategory, int>, colorScheme: colorScheme, l10n: loc),
            ],
            if (stats['topDestination'] != null) ...[
              const SizedBox(height: 24),
              StatCard(title: loc.mostVisited, value: stats['topDestination'] as String, icon: Icons.place_rounded, iconColor: colorScheme.tertiary, colorScheme: colorScheme),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Map<String, double> _spendByDestination(List<Trip> trips) {
    final map = <String, double>{};
    for (final t in trips) {
      map[t.title] = (map[t.title] ?? 0) + t.price;
    }
    return map;
  }
}
