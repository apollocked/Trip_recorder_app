import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/home/search_sort_bar.dart';
import 'package:animations_in_flutter/views/widgets/home/shimmer_card_widget.dart';
import 'package:animations_in_flutter/views/widgets/home/trip_widget.dart';

class TripListWidget extends StatelessWidget {
  const TripListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const _ShimmerList();
        }

        final past = provider.pastTrips;
        final trips = provider.filteredPastTrips;

        return Column(
          children: [
            const SearchSortBar(),
            Expanded(
              child: trips.isEmpty
                  ? EmptyState(
                      icon: past.isEmpty
                          ? Icons.explore_outlined
                          : Icons.search_off_rounded,
                      title: past.isEmpty
                          ? l10n.emptyTripTitle
                          : l10n.noTripsFound,
                      subtitle: past.isEmpty
                          ? l10n.emptylistDescription
                          : l10n.tryAdjustingSearch,
                      action: past.isEmpty
                          ? FilledButton.tonalIcon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddTripPage(),
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(l10n.emptyTripAction),
                            )
                          : null,
                    )
                  : RefreshIndicator(
                      onRefresh: provider.refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: trips.length,
                        itemBuilder: (context, index) {
                          final trip = trips[index];
                          return _TripListItem(trip: trip, index: index);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TripListItem extends StatelessWidget {
  final Trip trip;
  final int index;
  const _TripListItem({required this.trip, required this.index});

  @override
  Widget build(BuildContext context) {
    return tripWidget(
      trip,
      kAlwaysCompleteAnimation,
      context,
      index,
      onRemove: () {
        context.read<TripProvider>().deleteTrip(trip.id);
      },
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: 4,
            itemBuilder: (_, _) => shimmerCard(context),
          ),
        ),
      ],
    );
  }
}
