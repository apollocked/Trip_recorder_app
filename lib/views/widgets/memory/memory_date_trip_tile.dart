import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/model/trip.dart';

class MemoryDateTripTile extends StatelessWidget {
  final Trip trip;
  final bool isExpanded;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const MemoryDateTripTile({
    super.key,
    required this.trip,
    required this.isExpanded,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final day = trip.date.day.toString();
    final loc = AppLocalizations.of(context)!;
    final month = loc.monthShort(trip.date.month);

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
            Text(month.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: isExpanded
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(day,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                    color: isExpanded
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
