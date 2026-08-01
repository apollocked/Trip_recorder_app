import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/trip.dart';

class TripInfoChips extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;

  const TripInfoChips({
    super.key,
    required this.trip,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            Icons.bedtime_rounded,
            '${trip.nights} ${l10n.nightsLabel}',
            colorScheme,
          ),
          const SizedBox(width: 12),
          _buildChip(
            Icons.attach_money_rounded,
            '${CurrencyInfo.symbolFor(trip.currency)}${trip.price.toStringAsFixed(0)}',
            colorScheme,
          ),
          const SizedBox(width: 12),
          _buildChip(
            Icons.calendar_today_rounded,
            '${trip.date.day}/${trip.date.month}/${trip.date.year}',
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(102),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
