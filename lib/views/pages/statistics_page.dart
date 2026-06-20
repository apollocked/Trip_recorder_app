import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/favorites_page.dart';
import 'package:animations_in_flutter/views/widgets/statistics/category_breakdown.dart';
import 'package:animations_in_flutter/views/widgets/statistics/category_pie_chart.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/statistics/spending_bar_chart.dart';
import 'package:animations_in_flutter/views/widgets/statistics/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/route_transition.dart';
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
    final trips = tripProvider.pastTrips;
    final spentByCurrency = stats['spentByCurrency'] as Map<String, double>;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.statistics,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: trips.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.bar_chart_rounded,
                title: loc.emptyStatsTitle,
                subtitle: loc.emptyStatsSubtitle,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatCard(
                    title: loc.totalTrips,
                    value: '${stats['totalTrips']}',
                    icon: Icons.flight_takeoff_rounded,
                    iconColor: colorScheme.primary,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  if (spentByCurrency.length > 1) ...[
                    ..._currencyCards(spentByCurrency, loc, colorScheme),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: loc.totalNights,
                            value: '${stats['totalNights']}',
                            icon: Icons.bedtime_rounded,
                            iconColor: AppColors.statNights,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: loc.avgRating,
                            value: (stats['avgRating'] as double) > 0
                                ? (stats['avgRating'] as double)
                                      .toStringAsFixed(1)
                                : loc.notRated,
                            icon: Icons.star_rounded,
                            iconColor: AppColors.statRating,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      title: loc.favorites,
                      value: '${stats['likedCount']}',
                      icon: Icons.favorite_rounded,
                      iconColor: AppColors.statFavorites,
                      colorScheme: colorScheme,
                      onTap: () => Navigator.push(
                        context,
                        slideRoute(const FavoritesPage()),
                      ),
                    ),
                  ] else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: loc.totalSpent,
                                value:
                                    '${(stats['totalSpent'] as double).toStringAsFixed(0)} ${spentByCurrency.keys.first}',
                                icon: Icons.attach_money_rounded,
                                iconColor: AppColors.statSpending,
                                colorScheme: colorScheme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: loc.totalNights,
                                value: '${stats['totalNights']}',
                                icon: Icons.bedtime_rounded,
                                iconColor: AppColors.statNights,
                                colorScheme: colorScheme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: loc.avgRating,
                                value: (stats['avgRating'] as double) > 0
                                    ? (stats['avgRating'] as double)
                                          .toStringAsFixed(1)
                                    : loc.notRated,
                                icon: Icons.star_rounded,
                                iconColor: AppColors.statRating,
                                colorScheme: colorScheme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: loc.favorites,
                                value: '${stats['likedCount']}',
                                icon: Icons.favorite_rounded,
                                iconColor: AppColors.statFavorites,
                                colorScheme: colorScheme,
                                onTap: () => Navigator.push(
                                  context,
                                  slideRoute(const FavoritesPage()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if ((stats['categoryCounts'] as Map).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      loc.tripsByCategory,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CategoryPieChart(
                      categoryCounts: stats['categoryCounts'] as Map,
                      colorScheme: colorScheme,
                      l10n: loc,
                    ),
                  ],
                  if (_spendByDestination(trips).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      loc.spendingByDestination,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SpendingBarChart(trips: trips, colorScheme: colorScheme),
                  ],
                  if (stats['topCategory'] != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      loc.topCategory,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategoryBreakdown<TripCategory>(
                      categoryCounts:
                          stats['categoryCounts'] as Map<TripCategory, int>,
                      colorScheme: colorScheme,
                      l10n: loc,
                      labeler: (l, c) => c.label(l),
                    ),
                  ],
                  if (stats['topDestination'] != null) ...[
                    const SizedBox(height: 24),
                    StatCard(
                      title: loc.mostVisited,
                      value: stats['topDestination'] as String,
                      icon: Icons.place_rounded,
                      iconColor: colorScheme.tertiary,
                      colorScheme: colorScheme,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  List<Widget> _currencyCards(
    Map<String, double> spentByCurrency,
    AppLocalizations loc,
    ColorScheme colorScheme,
  ) {
    return spentByCurrency.entries
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StatCard(
              title: '${loc.totalSpent} (${e.key})',
              value: e.value.toStringAsFixed(0),
              icon: Icons.attach_money_rounded,
              iconColor: AppColors.statSpending,
              colorScheme: colorScheme,
            ),
          ),
        )
        .toList();
  }

  Map<String, double> _spendByDestination(List<Trip> trips) {
    final map = <String, double>{};
    for (final t in trips) {
      final key = '${t.title} (${t.currency.isNotEmpty ? t.currency : "USD"})';
      map[key] = (map[key] ?? 0) + t.price;
    }
    return map;
  }
}
