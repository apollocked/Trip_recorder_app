import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';
import 'package:animations_in_flutter/views/widgets/confirmation_dialog.dart';
import 'package:animations_in_flutter/views/widgets/image_widget_leading.dart';
import 'package:animations_in_flutter/views/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations_in_flutter/core/route_transition.dart';

Widget tripWidget(
  Trip trip,
  Animation<double> animation,
  BuildContext context,
  int index, {

  required VoidCallback onRemove,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final l10n = AppLocalizations.of(context)!;

  return SlideTransition(
    position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        ),
    child: FadeTransition(
      opacity: animation,
      child: Dismissible(
        direction: DismissDirection.endToStart,
        key: ValueKey(trip.id),
        confirmDismiss: (direction) async {
          final l10n = AppLocalizations.of(context)!;
          return showConfirmationDialog(
            context: context,
            title: l10n.confirmDeleteTitle(trip.title),
            message: l10n.confirmDeleteMessage,
            icon: Icons.delete_rounded,
          );
        },
        onDismissed: (direction) {
          HapticFeedback.vibrate();
          onRemove();
        },
        background: Container(
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Directionality.of(context) == TextDirection.rtl
              ? Alignment.centerLeft
              : Alignment.centerRight,
          padding: EdgeInsets.only(
            right: Directionality.of(context) == TextDirection.rtl ? 0 : 24,
            left: Directionality.of(context) == TextDirection.rtl ? 24 : 0,
          ),
          child: Transform.flip(
            flipX: Directionality.of(context) == TextDirection.rtl,
            child: Icon(
              Icons.delete_sweep_rounded,
              color: colorScheme.onErrorContainer,
              size: 28,
            ),
          ),
        ),
        child: InkWell(
          onLongPress: () {
            final tripProvider = Provider.of<TripProvider>(
              context,
              listen: false,
            );
            final trip = tripProvider.getTripById(trip.tripId);
            if (trip == null) return;
            tripProvider.toggleLike(widget.tripId);
            HapticFeedback.selectionClick();
          },
          child: Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant.withAlpha(80)),
            ),
            color: colorScheme.surfaceContainerLow,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  slideRoute(DetailsPage(tripId: trip.id)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Hero(
                      tag: 'tag-image-${trip.primaryImagePath}',
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withAlpha(20),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: leadingImage(
                            trip.primaryImagePath,
                            context: context,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  trip.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withAlpha(
                                    120,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  trip.category.label(l10n),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (trip.rating > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: StarRating(rating: trip.rating, size: 14),
                            ),
                          Row(
                            children: [
                              Icon(
                                Icons.nights_stay_rounded,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${trip.nights} ${AppLocalizations.of(context)!.nightsLabel}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 12,
                                color: colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withAlpha(120),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${CurrencyInfo.symbolFor(trip.currency)}${trip.price.toStringAsFixed(0)}',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          size: 18,
                          color: colorScheme.outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
