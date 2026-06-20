import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/next_trips/future_trip_card.dart';

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
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: upcoming.isEmpty
              ? ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.12),
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
                  itemBuilder: (context, index) => FutureTripCard(
                    trip: upcoming[index],
                    colorScheme: colorScheme,
                  ),
                ),
        );
      },
    );
  }
}
