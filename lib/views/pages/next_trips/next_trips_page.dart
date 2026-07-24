import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/route_transition.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/trip/trip_type_selector.dart';
import 'package:animations_in_flutter/views/widgets/shared/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/next_trips/future_trip_card.dart';

class NextTripsPage extends StatelessWidget {
  const NextTripsPage({super.key});

  String _sectionKey(DateTime tripDate, AppLocalizations loc) {
    final days = tripDate.difference(DateTime.now()).inDays;
    if (days <= 7) return loc.thisWeek;
    if (days <= 30) return loc.thisMonth;
    return loc.comingSoon;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        final loc = AppLocalizations.of(context)!;
        final upcoming = [...provider.futureTrips]
          ..sort((a, b) => a.date.compareTo(b.date));

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface, elevation: 0, centerTitle: true,
            title: Text(loc.nextTripsTitle,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: upcoming.isEmpty
                ? _emptyState(context, cs, tt, loc)
                : _content(context, cs, tt, loc, upcoming),
          ),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context, ColorScheme cs, TextTheme tt, AppLocalizations loc) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ListView(
      key: const ValueKey('empty'),
      padding: EdgeInsets.only(bottom: 92 + bottomInset),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Opacity(opacity: v, child: EmptyState(
            key: const ValueKey('empty-state'),
            icon: Icons.flight_takeoff_rounded,
            title: loc.noUpcomingTrips,
            subtitle: loc.noUpcomingTripsSubtitle,
            description: loc.nextTripsEmptyTip,
            action: FilledButton.icon(
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(loc.planTrip),
              onPressed: () => Navigator.of(context, rootNavigator: true).push(slideRoute(const TripTypeSelector())),
            ),
          )),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, ColorScheme cs, TextTheme tt, AppLocalizations loc, List<Trip> upcoming) {
    final grouped = <String, List<Trip>>{
      loc.thisWeek: [],
      loc.thisMonth: [],
      loc.comingSoon: [],
    };
    for (final t in upcoming) {
      grouped[_sectionKey(t.date, loc)]!.add(t);
    }

    final nextTrip = upcoming.first;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return RefreshIndicator(
      onRefresh: () => context.read<TripProvider>().refresh(),
      child: ListView(
        key: const ValueKey('list'),
        padding: EdgeInsets.fromLTRB(16, 8, 16, 92 + bottomInset),
        children: [
          _HeroSummary(cs: cs, tt: tt, loc: loc, upcoming: upcoming, nextTrip: nextTrip),
          const SizedBox(height: 20),
          for (final entry in grouped.entries)
            if (entry.value.isNotEmpty) ...[
              _SectionHeader(title: entry.key, cs: cs),
              const SizedBox(height: 8),
              for (int i = 0; i < entry.value.length; i++)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (i * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, ch) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - v)),
                      child: ch,
                    ),
                  ),
                  child: FutureTripCard(trip: entry.value[i], colorScheme: cs),
                ),
            ],
        ],
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final AppLocalizations loc;
  final List<Trip> upcoming;
  final Trip nextTrip;

  const _HeroSummary({
    required this.cs, required this.tt, required this.loc,
    required this.upcoming, required this.nextTrip,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = nextTrip.date.difference(DateTime.now()).inDays + 1;
    final count = upcoming.length;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Opacity(opacity: v, child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.secondaryContainer.withAlpha(180)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('$count', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800,
                    color: cs.onPrimaryContainer, height: 1)),
                const SizedBox(width: 8),
                Text(loc.totalTrips, style: TextStyle(fontSize: 13,
                    color: cs.onPrimaryContainer.withAlpha(180))),
              ]),
              const SizedBox(height: 12),
              Container(height: 1, color: cs.onPrimaryContainer.withAlpha(50)),
              const SizedBox(height: 12),
              Icon(Icons.flight_rounded, size: 14, color: cs.onPrimaryContainer.withAlpha(200)),
              const SizedBox(height: 4),
              Text(nextTrip.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: cs.onPrimaryContainer)),
              const SizedBox(height: 4),
              Text(
                daysUntil <= 1 ? loc.todayLabel : loc.daysCount(daysUntil),
                style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer.withAlpha(180)),
              ),
            ]),
          ),
          const SizedBox(width: 16),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: cs.onPrimaryContainer.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.explore_rounded, size: 36,
                color: cs.onPrimaryContainer.withAlpha(160)),
          ),
        ]),
      )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme cs;

  const _SectionHeader({required this.title, required this.cs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Opacity(opacity: v, child: Row(children: [
        Container(width: 4, height: 18,
            decoration: BoxDecoration(color: cs.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
            color: cs.onSurface, letterSpacing: -0.3)),
        const Spacer(),
        Container(
          height: 1, width: 60,
          color: cs.outlineVariant.withAlpha(100),
        ),
      ])),
    );
  }
}
