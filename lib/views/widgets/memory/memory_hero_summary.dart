import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';

class MemoryHeroSummary extends StatelessWidget {
  final List<Trip> trips;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const MemoryHeroSummary({
    super.key,
    required this.trips,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final totalNights = trips.fold<int>(0, (s, t) => s + t.nights);
    final avgRating =
        trips.fold<double>(0, (s, t) => s + t.rating) / trips.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer.withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${trips.length}',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer, height: 1)),
                const SizedBox(height: 4),
                Text(loc.totalTrips,
                    style: TextStyle(fontSize: 13,
                        color: colorScheme.onPrimaryContainer.withAlpha(180))),
              ],
            ),
          ),
          _divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('$totalNights',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer, height: 1)),
                const SizedBox(height: 4),
                Text(loc.nightsLabel,
                    style: TextStyle(fontSize: 13,
                        color: colorScheme.onPrimaryContainer.withAlpha(180))),
              ],
            ),
          ),
          _divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(avgRating > 0 ? avgRating.toStringAsFixed(1) : '--',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer, height: 1)),
                const SizedBox(height: 4),
                Text(loc.ratingLabel,
                    style: TextStyle(fontSize: 13,
                        color: colorScheme.onPrimaryContainer.withAlpha(180))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 40, width: 1,
        color: colorScheme.onPrimaryContainer.withAlpha(60),
      );
}
