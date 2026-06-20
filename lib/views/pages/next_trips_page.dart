import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';
import 'package:animations_in_flutter/views/pages/packing_list_page.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';

class NextTripsPage extends StatelessWidget {
  const NextTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        final loc = AppLocalizations.of(context)!;
        final upcoming = provider.futureTrips
          ..sort((a, b) => a.date.compareTo(b.date));

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              loc.nextTripsTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: upcoming.isEmpty
              ? ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.12,
                    ),
                    EmptyState(
                      icon: Icons.flight_takeoff_rounded,
                      title: loc.noUpcomingTrips,
                      subtitle: loc.noUpcomingTripsSubtitle,
                      description: loc.nextTripsEmptyTip,
                      action: FilledButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: Text(loc.planTrip),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTripPage(),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) {
                    final trip = upcoming[index];
                    return _FutureTripCard(trip: trip, colorScheme: colorScheme);
                  },
                ),
        );
      },
    );
  }
}

class _FutureTripCard extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;

  const _FutureTripCard({required this.trip, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final daysLeft = trip.date.difference(DateTime.now()).inDays + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsPage(tripId: trip.id),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withAlpha(160),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.event_rounded,
                        color: colorScheme.onTertiaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.formatDateAbbreviated(trip.date),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (trip.nights > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${trip.nights} ${loc.nightsLabel}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: daysLeft <= 3
                            ? colorScheme.errorContainer.withAlpha(180)
                            : colorScheme.primaryContainer.withAlpha(120),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        daysLeft <= 1
                            ? loc.todayLabel
                            : loc.daysCount(daysLeft),
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: daysLeft <= 3
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.checklist_rounded, size: 18),
                  label: Text(loc.checklist),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PackingListPage(tripId: trip.id),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.primary.withAlpha(80),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
