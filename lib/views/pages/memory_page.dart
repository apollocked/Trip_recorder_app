import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/memory/memory_hero_summary.dart';
import 'package:animations_in_flutter/views/widgets/memory/memory_month_section.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  String? _expandedTripId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final trips = context.watch<TripProvider>().pastTrips;

    if (trips.isEmpty) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(title: Text(loc.memories,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            centerTitle: true),
        body: Center(child: EmptyState(icon: Icons.timeline_rounded,
            title: loc.memories, subtitle: loc.emptyStatsSubtitle)),
      );
    }

    final sorted = List<Trip>.from(trips)
      ..sort((a, b) => b.date.compareTo(a.date));
    final grouped = <String, List<Trip>>{};
    for (final t in sorted) {
      grouped.putIfAbsent(loc.formatMonthYear(t.date), () => []).add(t);
    }
    final entries = grouped.entries.toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: Text(loc.memories,
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 92),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(children: [
              MemoryHeroSummary(trips: trips, colorScheme: cs, textTheme: tt),
              const SizedBox(height: 24),
            ]);
          }
          final e = entries[index - 1];
          return MemoryMonthSection(
            month: e.key, trips: e.value,
            expandedId: _expandedTripId,
            onTap: (id) => setState(
                () => _expandedTripId = _expandedTripId == id ? null : id),
            colorScheme: cs, loc: loc,
          );
        },
      ),
    );
  }
}
