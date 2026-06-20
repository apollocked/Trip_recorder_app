import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';

class MemoryExpandedTripCard extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;
  final AppLocalizations loc;

  const MemoryExpandedTripCard({
    super.key,
    required this.trip,
    required this.colorScheme,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat('EEEE').format(trip.date);
    final formattedDate = loc.formatDateAbbreviated(trip.date);

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
                  child: _image(trip.imagePaths.first),
                ),
              ),
            ),
          Row(children: [
            _QuickStat(icon: Icons.nightlight_round, value: '${trip.nights}',
                label: loc.nightsLabel, color: AppColors.statNights,
                colorScheme: colorScheme),
            const SizedBox(width: 8),
            _QuickStat(icon: Icons.star_rounded,
                value: trip.rating > 0 ? trip.rating.toStringAsFixed(1) : '--',
                label: loc.ratingLabel, color: AppColors.ratingActive,
                colorScheme: colorScheme),
            const SizedBox(width: 8),
            _QuickStat(icon: Icons.favorite_rounded,
                value: trip.isLiked ? loc.labelYes : loc.labelNo,
                label: loc.favorites, color: AppColors.favoriteActive,
                colorScheme: colorScheme),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 13,
                color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text('$weekday, $formattedDate',
                style: TextStyle(fontSize: 12,
                    color: colorScheme.onSurfaceVariant)),
          ]),
          if (trip.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(trip.description, maxLines: 3, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13,
                    color: colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => DetailsPage(tripId: trip.id))),
              child: Text(loc.viewDetailsLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(String path) {
    final isFile = File(path).isAbsolute;
    if (isFile) {
      return Image.file(File(path), fit: BoxFit.cover,
          errorBuilder: (_, e, s) => Container(
              color: colorScheme.surfaceContainerHighest,
              child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant)));
    }
    return Image.asset(path.startsWith('images/') ? path : 'images/$path',
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: Icon(Icons.landscape, color: colorScheme.onSurfaceVariant)));
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
        child: Column(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: colorScheme.onSurface)),
          Text(label, style: TextStyle(fontSize: 10,
              color: colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
