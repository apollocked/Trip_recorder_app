import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/services/pdf_export_service.dart';
import 'package:animations_in_flutter/services/premium_service.dart';
import 'package:animations_in_flutter/views/widgets/shared/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/shared/premium_popup.dart';
import 'package:animations_in_flutter/views/widgets/statistics/stat_card.dart';

class AnnualReportPage extends StatefulWidget {
  const AnnualReportPage({super.key});

  @override
  State<AnnualReportPage> createState() => _AnnualReportPageState();
}

class _AnnualReportPageState extends State<AnnualReportPage> {
  late int _selectedYear;
  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    final trips = context.read<TripProvider>().pastTrips;
    final years = trips.map((t) => t.date.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    _availableYears = years.isEmpty ? [now.year] : years;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final premium = context.watch<PremiumService>();
    final trips = context.watch<TripProvider>().pastTrips;

    if (!premium.isPremium) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(loc.annualReport, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium_rounded, size: 64, color: cs.primary),
              const SizedBox(height: 16),
              Text(loc.premiumTitle, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(loc.premiumAdvancedStatsDesc, textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: () async {
                  final result = await PremiumPopup.show(context);
                  if (result == true && context.mounted) {
                    await context.read<PremiumService>().activatePremium();
                  }
                },
                child: Text(loc.premiumUpgrade),
              ),
            ],
          ),
        ),
      );
    }

    final yearTrips = trips.where((t) => t.date.year == _selectedYear).toList();
    final totalTrips = yearTrips.length;
    final totalNights = yearTrips.fold<int>(0, (sum, t) => sum + t.nights);
    final totalSpent = yearTrips.fold<double>(0, (sum, t) => sum + t.price);
    final avgRating = totalTrips > 0
        ? yearTrips.fold<double>(0, (sum, t) => sum + t.rating) / totalTrips
        : 0.0;
    final topCategory = _topCategory(yearTrips);
    final destinations = yearTrips.map((t) => t.title).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(loc.annualReport, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (yearTrips.isNotEmpty)
            IconButton(
              onPressed: () => _exportReport(yearTrips),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              tooltip: loc.exportPdf,
            ),
        ],
      ),
      body: yearTrips.isEmpty
          ? Center(child: EmptyState(
              icon: Icons.assessment_rounded,
              title: '${loc.annualReport} $_selectedYear',
              subtitle: loc.emptyStatsSubtitle,
            ))
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 92 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          items: _availableYears
                              .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                              .toList(),
                          onChanged: (y) => setState(() => _selectedYear = y!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(loc.statistics, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  StatCard(title: loc.totalTrips, value: '$totalTrips',
                    icon: Icons.flight_takeoff_rounded, iconColor: cs.primary, colorScheme: cs),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: StatCard(title: loc.totalNights, value: '$totalNights',
                      icon: Icons.bedtime_rounded, iconColor: AppColors.statNights, colorScheme: cs)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(title: loc.avgRating, value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '--',
                      icon: Icons.star_rounded, iconColor: AppColors.statRating, colorScheme: cs)),
                  ]),
                  const SizedBox(height: 12),
                  StatCard(title: loc.totalSpent, value: totalSpent.toStringAsFixed(0),
                    icon: Icons.attach_money_rounded, iconColor: AppColors.statSpending, colorScheme: cs),
                  if (topCategory != null) ...[
                    const SizedBox(height: 12),
                    StatCard(title: loc.topCategory, value: topCategory,
                      icon: Icons.category_rounded, iconColor: cs.tertiary, colorScheme: cs),
                  ],
                  if (destinations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(loc.destination, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...destinations.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        Icon(Icons.place_rounded, size: 16, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(d, style: tt.bodyMedium),
                      ]),
                    )),
                  ],
                ],
              ),
            ),
    );
  }

  String? _topCategory(List<Trip> trips) {
    if (trips.isEmpty) return null;
    final counts = <String, int>{};
    for (final t in trips) {
      counts[t.category.name] = (counts[t.category.name] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  Future<void> _exportReport(List<Trip> trips) async {
    if (trips.length == 1) {
      await PdfExportService.exportTrip(trips.first);
    } else {
      final first = trips.first;
      await PdfExportService.exportTrip(first);
    }
  }
}
