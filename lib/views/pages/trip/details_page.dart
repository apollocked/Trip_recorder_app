import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/data/repositories/template_repository.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/model/trip_template.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/services/pdf_export_service.dart';
import 'package:animations_in_flutter/services/premium_service.dart';
import 'package:animations_in_flutter/services/trip_share_service.dart';
import 'package:animations_in_flutter/views/pages/trip/add_trip_page.dart';
import 'package:animations_in_flutter/views/pages/budget/budget_page.dart';
import 'package:animations_in_flutter/views/pages/journal/journal_page.dart';
import 'package:animations_in_flutter/views/pages/packing_list/packing_list_page.dart';
import 'package:animations_in_flutter/views/widgets/details/trip_header_section.dart';
import 'package:animations_in_flutter/views/widgets/details/trip_image_carousel.dart';
import 'package:animations_in_flutter/views/widgets/details/trip_info_chips.dart';
import 'package:animations_in_flutter/views/widgets/shared/premium_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animations_in_flutter/core/route_transition.dart';

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
                  await Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push(slideRoute(AddTripPage(tripId: trip.id)));
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
            onPressed: () =>
                Navigator.push(context, slideRoute(BudgetPage(tripId: tripId))),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.checklist_rounded, size: 18),
            label: Text(l10n.checklist),
            onPressed: () => Navigator.push(
              context,
              slideRoute(PackingListPage(tripId: tripId)),
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.article_rounded, size: 18),
            label: Text(l10n.journal),
            onPressed: () => Navigator.push(
              context,
              slideRoute(JournalPage(tripId: tripId)),
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: Icon(Icons.save_as_rounded, size: 18,
              color: context.read<PremiumService>().isPremium ? null : Theme.of(context).colorScheme.onSurfaceVariant),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.saveAsTemplate),
                if (!context.read<PremiumService>().isPremium) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.lock_rounded, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ],
            ),
            onPressed: () async {
              final premium = context.read<PremiumService>();
              if (!premium.isPremium) {
                final result = await PremiumPopup.show(context);
                if (result == true && context.mounted) await premium.activatePremium();
                return;
              }
              _saveAsTemplate(context, trip);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveAsTemplate(BuildContext context, Trip trip) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: trip.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveAsTemplate),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.tripTemplate,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: Text(l10n.save)),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final repo = TemplateRepository();
      await repo.addTemplate(TripTemplate(
        name: result,
        category: trip.category.name,
        nights: trip.nights,
        description: trip.description,
        currency: trip.currency,
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.templateSaved)),
        );
      }
    }
  }

  Widget _buildReminderBanner(
    Trip trip,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
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
            '${l10n.reminder}: ${l10n.formatDateAbbreviated(trip.reminderDate!)} '
            '${trip.reminderDate!.hour.toString().padLeft(2, '0')}:${trip.reminderDate!.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTrip(BuildContext context, Trip trip) async {
    final l10n = AppLocalizations.of(context)!;
    final premium = context.read<PremiumService>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(l10n.exportTrip, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.text_snippet_rounded, color: cs.primary),
              title: Text(l10n.exportTrip),
              subtitle: Text(l10n.copiedToClipboard, style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final buffer = StringBuffer();
                buffer.writeln(l10n.exportHeader(trip.title));
                buffer.writeln('${l10n.tripCategory}: ${trip.category.label(l10n)}');
                buffer.writeln('${l10n.budget}: ${CurrencyInfo.symbolFor(trip.currency)}${trip.price.toStringAsFixed(0)}');
                buffer.writeln('${l10n.nights}: ${trip.nights}');
                buffer.writeln('${l10n.departureDate}: ${l10n.formatDateAbbreviated(trip.date)}');
                if (trip.rating > 0) buffer.writeln(l10n.exportRating(trip.rating.toStringAsFixed(1)));
                if (trip.description.isNotEmpty) {
                  buffer.writeln('\n${l10n.aboutjourney}:');
                  buffer.writeln(trip.description);
                }
                buffer.writeln('\n---\n${l10n.appTitle.replaceAll('\n', ' ')}');
                final text = buffer.toString();
                try {
                  await SharePlus.instance.share(ShareParams(text: text, subject: trip.title));
                } catch (_) {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf_rounded, color: premium.isPremium ? cs.primary : cs.onSurfaceVariant),
              title: Row(children: [
                Text(l10n.exportPdf),
                if (!premium.isPremium) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.lock_rounded, size: 14, color: cs.onSurfaceVariant),
                ],
              ]),
              subtitle: Text(premium.isPremium ? 'Generate PDF' : l10n.premiumUpgrade, style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                if (!premium.isPremium) {
                  final result = await PremiumPopup.show(context);
                  if (result == true && context.mounted) await premium.activatePremium();
                  return;
                }
                await PdfExportService.exportTrip(trip);
              },
            ),
            ListTile(
              leading: Icon(Icons.share_rounded, color: premium.isPremium ? cs.primary : cs.onSurfaceVariant),
              title: Row(children: [
                Text(l10n.shareTrip),
                if (!premium.isPremium) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.lock_rounded, size: 14, color: cs.onSurfaceVariant),
                ],
              ]),
              subtitle: Text(premium.isPremium ? 'Share trip details' : l10n.premiumUpgrade, style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                if (!premium.isPremium) {
                  final result = await PremiumPopup.show(context);
                  if (result == true && context.mounted) await premium.activatePremium();
                  return;
                }
                await TripShareService.shareTrip(trip);
              },
            ),
          ],
        ),
      ),
    );
  }
}
