import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';
import 'package:animations_in_flutter/views/pages/packing_list_page.dart';
import 'package:animations_in_flutter/views/widgets/confirmation_dialog.dart' show showConfirmationDialog;
import 'package:animations_in_flutter/core/route_transition.dart';

class FutureTripCard extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;

  const FutureTripCard({super.key, required this.trip, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final daysLeft = trip.date.difference(DateTime.now()).inDays + 1;

    return Dismissible(
      key: ValueKey(trip.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteConfirmation(context),
      onDismissed: (_) => context.read<TripProvider>().deleteTrip(trip.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_sweep_rounded, color: colorScheme.onError, size: 28),
      ),
      child: _CardContent(
        trip: trip,
        daysLeft: daysLeft,
        onLongPress: () => _showOptionsSheet(context),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return showConfirmationDialog(
      context: context,
      title: l10n.confirmDeleteTitle(trip.title),
      message: l10n.confirmDeleteMessage,
    );
  }

  void _showOptionsSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_calendar_rounded),
              title: Text(loc.reminder),
              subtitle: Text(loc.departureDate),
              onTap: () {
                Navigator.pop(ctx);
                _showReschedulePicker(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(loc.editJourney),
              onTap: () {
                Navigator.pop(ctx);
                  Navigator.of(context, rootNavigator: true).push(
                    slideRoute(AddTripPage(tripId: trip.id)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: colorScheme.error),
              title: Text(loc.delete, style: TextStyle(color: colorScheme.error)),
              onTap: () {
                final provider = context.read<TripProvider>();
                Navigator.pop(ctx);
                _showDeleteConfirmation(context).then((ok) {
                  if (ok == true) provider.deleteTrip(trip.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReschedulePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: trip.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null && context.mounted) {
      context.read<TripProvider>().rescheduleTrip(trip.id, date);
    }
  }
}

class _CardContent extends StatelessWidget {
  final Trip trip;
  final int daysLeft;
  final VoidCallback onLongPress;

  const _CardContent({
    required this.trip,
    required this.daysLeft,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              onLongPress: onLongPress,
              onTap: () => Navigator.push(
                context,
                slideRoute(DetailsPage(tripId: trip.id)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer.withAlpha(160),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.event_rounded,
                        color: cs.onTertiaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.formatDateAbbreviated(trip.date),
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          if (trip.nights > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${trip.nights} ${loc.nightsLabel}',
                              style: textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: daysLeft <= 3
                            ? cs.errorContainer.withAlpha(180)
                            : cs.primaryContainer.withAlpha(120),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        daysLeft <= 1
                            ? loc.todayLabel
                            : loc.daysCount(daysLeft),
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: daysLeft <= 3
                              ? cs.onErrorContainer
                              : cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.checklist_rounded, size: 18),
                  label: Text(loc.checklist),
                  onPressed: () => Navigator.push(
                    context,
                slideRoute(PackingListPage(tripId: trip.id)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
