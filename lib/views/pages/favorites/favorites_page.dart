import 'dart:io';

import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/trip/details_page.dart';
import 'package:animations_in_flutter/views/widgets/shared/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/route_transition.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final trips = context.watch<TripProvider>().pastTrips;
    final liked = trips.where((t) => t.isLiked).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.favorites,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: liked.isEmpty
          ? Center(
              key: const ValueKey('empty'),
              child: EmptyState(
                icon: Icons.favorite_rounded,
                title: loc.favorites,
                subtitle: loc.emptyStatsSubtitle,
              ),
            )
          : ListView.separated(
              key: const ValueKey('list'),
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 92),
              itemCount: liked.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = liked[index];
                return _FavoriteTripCard(trip: trip, colorScheme: colorScheme);
              },
            ),
      ),
    );
  }
}

class _FavoriteTripCard extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;

  const _FavoriteTripCard({required this.trip, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final weekday = DateFormat('EEEE').format(trip.date);
    final formattedDate = loc.formatDateAbbreviated(trip.date);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        slideRoute(DetailsPage(tripId: trip.id)),
      ),
      onLongPress: () {
        context.read<TripProvider>().toggleLike(trip.id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.removedFromFavorites),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (trip.imagePaths.isNotEmpty)
              Hero(
                tag: 'tag-image-${trip.imagePaths.first}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,

                    child: _tripImage(trip.imagePaths.first),
                  ),
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.landscape_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$weekday, $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.nights} ${loc.nightsLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.ratingActive,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.rating > 0 ? trip.rating.toStringAsFixed(1) : '--',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.favorite_rounded,
              color: AppColors.favoriteIconColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
        ),
      );
    }
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
