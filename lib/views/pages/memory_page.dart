import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final trips = context.watch<TripProvider>().trips;

    if (trips.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(title: Text(loc.memories, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), centerTitle: true),
        body: Center(child: EmptyState(icon: Icons.timeline_rounded, title: loc.memories, subtitle: loc.emptyStatsSubtitle)),
      );
    }

    final grouped = <String, List<Trip>>{};
    for (final t in trips) {
      final key = DateFormat('yyyy-MM-dd').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.memories, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedKeys.length,
        itemBuilder: (_, i) {
          final date = DateTime.parse(sortedKeys[i]);
          final dayTrips = grouped[sortedKeys[i]]!;
          return _DaySection(date: date, trips: dayTrips, colorScheme: colorScheme, textTheme: textTheme, l10n: loc);
        },
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime date;
  final List<Trip> trips;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const _DaySection({
    required this.date,
    required this.trips,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMM').format(date);
    final day = date.day.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(month, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                    Text(day, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                  ],
                ),
              ),
              Container(width: 2, height: 20, color: colorScheme.outlineVariant),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: trips.map((t) => _TripMemoryCard(trip: t, colorScheme: colorScheme, l10n: l10n)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripMemoryCard extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const _TripMemoryCard({required this.trip, required this.colorScheme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(tripId: trip.id))),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.title, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.nights} ${l10n.nightsLabel} · ${CurrencyInfo.symbolFor(trip.currency)}${trip.price.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (trip.isLiked) Icon(Icons.favorite_rounded, size: 18, color: Colors.red.shade300),
            ],
          ),
        ),
      ),
    );
  }
}
