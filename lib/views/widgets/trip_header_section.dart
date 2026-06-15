import 'package:flutter/material.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/widgets/heart_widget.dart';
import 'package:animations_in_flutter/views/widgets/star_rating.dart';

class TripHeaderSection extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const TripHeaderSection({
    super.key,
    required this.trip,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 60),
              child: Text(
                trip.title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(120),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trip.category.label(l10n),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (trip.rating > 0) StarRating(rating: trip.rating, size: 18),
              ],
            ),
          ],
        ),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(150),
              shape: BoxShape.circle,
            ),
            child: HeartWidget(isLiked: trip.isLiked, tripId: trip.id),
          ),
        ),
      ],
    );
  }
}
