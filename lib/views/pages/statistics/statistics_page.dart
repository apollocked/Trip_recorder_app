import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/services/premium_service.dart';
import 'package:animations_in_flutter/views/pages/favorites/favorites_page.dart';
import 'package:animations_in_flutter/views/pages/statistics/annual_report_page.dart';
import 'package:animations_in_flutter/views/widgets/statistics/category_breakdown.dart';
import 'package:animations_in_flutter/views/widgets/statistics/category_pie_chart.dart';
import 'package:animations_in_flutter/views/widgets/shared/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/shared/premium_popup.dart';
import 'package:animations_in_flutter/views/widgets/statistics/spending_bar_chart.dart';
import 'package:animations_in_flutter/views/widgets/statistics/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/route_transition.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, double>? _cachedSpendByDestination;
  List<Trip>? _cachedTrips;

  Map<String, double> _spendByDestination(List<Trip> trips) {
    if (identical(_cachedTrips, trips) && _cachedSpendByDestination != null) {
      return _cachedSpendByDestination!;
    }
    final map = <String, double>{};
    for (final t in trips) {
      final key = '${t.title} (${t.currency.isNotEmpty ? t.currency : "USD"})';
      map[key] = (map[key] ?? 0) + t.price;
    }
    _cachedTrips = trips;
    _cachedSpendByDestination = map;
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tripProvider = context.watch<TripProvider>();
    final stats = tripProvider.statistics;
    final loc = AppLocalizations.of(context)!;
    final trips = tripProvider.pastTrips;
    final spentByCurrency =
        (stats['spentByCurrency'] as Map<String, double>?) ?? {};
    final totalTrips = (stats['totalTrips'] as int?) ?? 0;
    final totalNights = (stats['totalNights'] as int?) ?? 0;
    final avgRating = (stats['avgRating'] as double?) ?? 0.0;
    final likedCount = (stats['likedCount'] as int?) ?? 0;
    final totalSpent = (stats['totalSpent'] as double?) ?? 0.0;
    final categoryCounts = (stats['categoryCounts'] as Map?) ?? {};
    final topCategory = stats['topCategory'];
    final topDestination = stats['topDestination'] as String?;
    final premium = context.watch<PremiumService>();

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
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                92 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatCard(
                    title: loc.totalTrips,
                    value: '$totalTrips',
                    icon: Icons.flight_takeoff_rounded,
                    iconColor: colorScheme.primary,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  if (spentByCurrency.length > 1) ...[
                    ..._currencyCards(spentByCurrency, loc, colorScheme),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: loc.totalNights,
                          value: '$totalNights',
                          icon: Icons.bedtime_rounded,
                          iconColor: AppColors.statNights,
                          colorScheme: colorScheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: loc.avgRating,
                          value: avgRating > 0
                              ? avgRating.toStringAsFixed(1)
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
                    title: loc.totalSpent,
                    value: spentByCurrency.length > 1
                        ? totalSpent.toStringAsFixed(0)
                        : '${totalSpent.toStringAsFixed(0)} ${spentByCurrency.keys.first}',
                    icon: Icons.attach_money_rounded,
                    iconColor: AppColors.statSpending,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    title: loc.favorites,
                    value: '$likedCount',
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.statFavorites,
                    colorScheme: colorScheme,
                    onTap: () => Navigator.push(
                      context,
                      slideRoute(const FavoritesPage()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, slideRoute(const AnnualReportPage())),
                      icon: Icon(Icons.assessment_rounded, color: premium.isPremium ? colorScheme.primary : colorScheme.onSurfaceVariant),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(loc.annualReport),
                          if (!premium.isPremium) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.lock_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!premium.isPremium) ...[
                    _PremiumStatsOverlay(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      loc: loc,
                    ),
                  ] else ...[
                    if (categoryCounts.isNotEmpty) ...[
                      Text(
                        loc.tripsByCategory,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CategoryPieChart(
                        categoryCounts: categoryCounts,
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
                    if (topCategory != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        loc.topCategory,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CategoryBreakdown<TripCategory>(
                        categoryCounts: categoryCounts.map(
                          (k, v) => MapEntry(k as TripCategory, v as int),
                        ),
                        colorScheme: colorScheme,
                        l10n: loc,
                        labeler: (l, c) => c.label(l),
                      ),
                    ],
                    if (topDestination != null) ...[
                      const SizedBox(height: 24),
                      StatCard(
                        title: loc.mostVisited,
                        value: topDestination,
                        icon: Icons.place_rounded,
                        iconColor: colorScheme.tertiary,
                        colorScheme: colorScheme,
                      ),
                    ],
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
}

class _PremiumStatsOverlay extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations loc;

  const _PremiumStatsOverlay({
    required this.colorScheme,
    required this.textTheme,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await PremiumPopup.show(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withAlpha(80),
              colorScheme.tertiaryContainer.withAlpha(60),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.primary.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 36,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              loc.premiumAdvancedStats,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              loc.premiumAdvancedStatsDesc,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: () async {
                await PremiumPopup.show(context);
              },
              child: Text(loc.premiumUpgrade),
            ),
          ],
        ),
      ),
    );
  }
}
