import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/widgets/memory/memory_date_trip_tile.dart';
import 'package:animations_in_flutter/views/widgets/memory/memory_expanded_trip_card.dart';

class MemoryMonthSection extends StatelessWidget {
  final String month;
  final List<Trip> trips;
  final String? expandedId;
  final ValueChanged<String> onTap;
  final ColorScheme colorScheme;
  final AppLocalizations loc;

  const MemoryMonthSection({
    super.key,
    required this.month,
    required this.trips,
    required this.expandedId,
    required this.onTap,
    required this.colorScheme,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(month, style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w800, color: colorScheme.onSurface,
            letterSpacing: -0.5)),
      ),
      Wrap(spacing: 8, runSpacing: 8,
          children: trips.map((t) => MemoryDateTripTile(
              trip: t, isExpanded: expandedId == t.id,
              onTap: () => onTap(t.id), colorScheme: colorScheme)).toList()),
      ...trips.where((t) => expandedId == t.id).map((t) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MemoryExpandedTripCard(trip: t, colorScheme: colorScheme, loc: loc))),
      const SizedBox(height: 20),
    ]);
  }
}
