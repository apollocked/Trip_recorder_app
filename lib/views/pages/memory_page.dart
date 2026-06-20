import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  String? _expandedTripId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final trips = context.watch<TripProvider>().trips;

    if (trips.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            loc.memories,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: EmptyState(
            icon: Icons.timeline_rounded,
            title: loc.memories,
            subtitle: loc.emptyStatsSubtitle,
          ),
        ),
      );
    }

    final sorted = List<Trip>.from(trips)
      ..sort((a, b) => b.date.compareTo(a.date));
    final grouped = <String, List<Trip>>{};
    for (final t in sorted) {
      final key = DateFormat('MMMM yyyy').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.memories,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _HeroSummary(
            trips: trips,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 24),
          ...grouped.entries.map(
            (entry) => _MonthSection(
              month: entry.key,
              trips: entry.value,
              expandedId: _expandedTripId,
              onTap: (id) => setState(
                () => _expandedTripId = _expandedTripId == id ? null : id,
              ),
              colorScheme: colorScheme,
              loc: loc,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  final List<Trip> trips;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _HeroSummary({
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
                Text(
                  '${trips.length}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.totalTrips,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onPrimaryContainer.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: colorScheme.onPrimaryContainer.withAlpha(60),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$totalNights',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.nightsLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onPrimaryContainer.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: colorScheme.onPrimaryContainer.withAlpha(60),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      avgRating > 0 ? avgRating.toStringAsFixed(1) : '--',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  loc.ratingLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onPrimaryContainer.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  final String month;
  final List<Trip> trips;
  final String? expandedId;
  final ValueChanged<String> onTap;
  final ColorScheme colorScheme;
  final AppLocalizations loc;

  const _MonthSection({
    required this.month,
    required this.trips,
    required this.expandedId,
    required this.onTap,
    required this.colorScheme,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            month,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trips.map((t) {
            final isExpanded = expandedId == t.id;
            return _DateTripTile(
              trip: t,
              isExpanded: isExpanded,
              onTap: () => onTap(t.id),
              colorScheme: colorScheme,
            );
          }).toList(),
        ),
        ...trips
            .where((t) => expandedId == t.id)
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _ExpandedTripCard(
                  trip: t,
                  colorScheme: colorScheme,
                  loc: loc,
                ),
              ),
            ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _DateTripTile extends StatelessWidget {
  final Trip trip;
  final bool isExpanded;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _DateTripTile({
    required this.trip,
    required this.isExpanded,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final day = trip.date.day.toString();
    final month = DateFormat('MMM').format(trip.date);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isExpanded
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpanded
                ? colorScheme.primary.withAlpha(120)
                : colorScheme.outlineVariant.withAlpha(100),
            width: isExpanded ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: isExpanded
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isExpanded
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedTripCard extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;
  final AppLocalizations loc;

  const _ExpandedTripCard({
    required this.trip,
    required this.colorScheme,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat('EEEE').format(trip.date);
    final formattedDate = DateFormat('MMM d, yyyy').format(trip.date);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          if (trip.imagePaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _expandImage(trip.imagePaths.first),
                ),
              ),
            ),
          Row(
            children: [
              _QuickStat(
                icon: Icons.nightlight_round,
                value: '${trip.nights}',
                label: loc.nightsLabel,
                color: AppColors.statNights,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              _QuickStat(
                icon: Icons.star_rounded,
                value: trip.rating > 0 ? trip.rating.toStringAsFixed(1) : '--',
                label: loc.ratingLabel,
                color: AppColors.ratingActive,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              _QuickStat(
                icon: Icons.favorite_rounded,
                value: trip.isLiked ? loc.labelYes : loc.labelNo,
                label: loc.favorites,
                color: AppColors.favoriteActive,
                colorScheme: colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '$weekday, $formattedDate',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (trip.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              trip.description,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailsPage(tripId: trip.id)),
              ),
              child: Text(loc.viewDetailsLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandImage(String path) {
    final isFile = File(path).isAbsolute;
    if (isFile) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    return Image.asset(
      path.startsWith('images/') ? path : 'images/$path',
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) => Container(
        color: colorScheme.surfaceContainerHighest,
        child: Icon(Icons.landscape, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ColorScheme colorScheme;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
