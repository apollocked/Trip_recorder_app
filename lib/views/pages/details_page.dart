import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/pages/budget_page.dart';
import 'package:animations_in_flutter/views/pages/journal_page.dart';
import 'package:animations_in_flutter/views/pages/packing_list_page.dart';
import 'package:animations_in_flutter/views/widgets/details/trip_header_section.dart';
import 'package:animations_in_flutter/views/widgets/details/trip_image_carousel.dart';
import 'package:animations_in_flutter/views/widgets/details/trip_info_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailsPage extends StatelessWidget {
  final String tripId;
  const DetailsPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TripProvider>(
      builder: (context, tripProvider, _) {
        final trip = tripProvider.getTripById(tripId);
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.tripNotFound)),
          );
        }
        return Scaffold(
          backgroundColor: colorScheme.surface,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: AppColors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 24),
                tooltip: l10n.exportTrip,
                onPressed: () => _exportTrip(context, trip),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 28),
                tooltip: l10n.editJourney,
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTripPage(tripId: trip.id),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TripImageCarousel(
                  trip: trip,
                  colorScheme: colorScheme,
                  l10n: l10n,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      right: 24,
                      left: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TripHeaderSection(
                          trip: trip,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 16),
                        TripInfoChips(trip: trip, colorScheme: colorScheme),
                        const SizedBox(height: 16),
                        _buildActionChips(context),
                        const SizedBox(height: 16),
                        if (trip.reminderDate != null)
                          _buildReminderBanner(trip, colorScheme, l10n),
                        Divider(
                          color: colorScheme.outlineVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.aboutjourney,
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Text(
                                trip.description.isNotEmpty
                                    ? trip.description
                                    : l10n.noDescriptionAdded,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionChips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tripId = this.tripId;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ActionChip(
            avatar: const Icon(Icons.account_balance_wallet_rounded, size: 18),
            label: Text(l10n.budgetLabel),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BudgetPage(tripId: tripId)),
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.checklist_rounded, size: 18),
            label: Text(l10n.checklist),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PackingListPage(tripId: tripId),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.article_rounded, size: 18),
            label: Text(l10n.journal),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JournalPage(tripId: tripId)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderBanner(Trip trip, ColorScheme colorScheme, var l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${l10n.reminder}: ${trip.reminderDate!.day}/${trip.reminderDate!.month}/${trip.reminderDate!.year} '
            '${trip.reminderDate!.hour.toString().padLeft(2, '0')}:${trip.reminderDate!.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTrip(BuildContext context, Trip trip) async {
    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    buffer.writeln(l10n.exportHeader(trip.title));
    buffer.writeln('${l10n.tripCategory}: ${trip.category.label(l10n)}');
    buffer.writeln(
      '${l10n.budget}: ${CurrencyInfo.symbolFor(trip.currency)}${trip.price.toStringAsFixed(0)}',
    );
    buffer.writeln('${l10n.nights}: ${trip.nights}');
    buffer.writeln(
      '${l10n.departureDate}: ${trip.date.day}/${trip.date.month}/${trip.date.year}',
    );
    if (trip.rating > 0) {
      buffer.writeln(l10n.exportRating(trip.rating.toStringAsFixed(1)));
    }
    if (trip.description.isNotEmpty) {
      buffer.writeln('\n${l10n.aboutjourney}:');
      buffer.writeln(trip.description);
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln(l10n.appTitle.replaceAll('\n', ' '));

    final text = buffer.toString();
    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: trip.title),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
      }
    }
  }
}
