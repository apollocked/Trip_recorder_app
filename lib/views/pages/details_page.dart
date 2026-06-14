import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/pages/budget_page.dart';
import 'package:animations_in_flutter/views/pages/image_viewer_page.dart';
import 'package:animations_in_flutter/views/pages/packing_list_page.dart';
import 'package:animations_in_flutter/views/widgets/cover_image_leading.dart';
import 'package:animations_in_flutter/views/widgets/heart_widget.dart';
import 'package:animations_in_flutter/views/widgets/star_rating.dart';
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
            body: const Center(child: Text('Trip not found')),
          );
        }
        return Scaffold(
          backgroundColor: colorScheme.surface,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                _buildImageCarousel(trip, colorScheme),
                Expanded(
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 1.0, end: 0.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, double op, Widget? child) => Opacity(
                      opacity: 1 - op,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 24, right: 24, left: 24, bottom: (op * 20),
                        ),
                        child: child,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(trip, colorScheme, textTheme),
                        const SizedBox(height: 16),
                        _buildInfoChips(trip, colorScheme, context),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ActionChip(
                                avatar: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                                label: Text(AppLocalizations.of(context)!.budgetLabel),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => BudgetPage(tripId: trip.id)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ActionChip(
                                avatar: const Icon(Icons.checklist_rounded, size: 18),
                                label: Text(AppLocalizations.of(context)!.checklist),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PackingListPage(tripId: trip.id)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: colorScheme.outlineVariant.withAlpha(128)),
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
                              padding: const EdgeInsets.only(bottom: 24.0),
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

  Widget _buildImageCarousel(Trip trip, ColorScheme colorScheme) {
    if (trip.imagePaths.isEmpty) {
      return Container(
        height: 280,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Center(child: Icon(Icons.landscape, size: 60, color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: trip.imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageViewerPage(
                    imagePaths: trip.imagePaths,
                    initialIndex: index,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.onSurface.withAlpha(200), width: 1),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'tag-image-${trip.imagePaths[index]}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Semantics(
                      label: 'Trip cover image ${index + 1}',
                      child: coverImage(trip.imagePaths[index]),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(Trip trip, ColorScheme colorScheme, TextTheme textTheme) {
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
                  fontWeight: FontWeight.bold, color: colorScheme.onSurface, height: 1.2,
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
                    trip.category.label,
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
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
          top: 0, end: 0,
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

  Widget _buildInfoChips(Trip trip, ColorScheme colorScheme, BuildContext context) {
    return Row(
      children: [
        _buildChip(context, Icons.bedtime_rounded,
            '${trip.nights} ${AppLocalizations.of(context)!.nightsLabel}', colorScheme),
        const SizedBox(width: 12),
        _buildChip(context, Icons.attach_money_rounded,
            '\$${trip.price.toStringAsFixed(0)}', colorScheme),
        ...[
          const SizedBox(width: 12),
          _buildChip(context, Icons.calendar_today_rounded,
              '${trip.date.day}/${trip.date.month}/${trip.date.year}', colorScheme),
        ],
      ],
    );
  }

  Widget _buildChip(BuildContext context, IconData icon, String label, ColorScheme colorScheme) {
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
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSecondaryContainer)),
        ],
      ),
    );
  }

  Future<void> _exportTrip(BuildContext context, Trip trip) async {
    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    buffer.writeln('=== ${trip.title} ===\n');
    buffer.writeln('${l10n.tripCategory}: ${trip.category.label}');
    buffer.writeln('${l10n.budget}: \$${trip.price.toStringAsFixed(0)}');
    buffer.writeln('${l10n.nights}: ${trip.nights}');
    buffer.writeln('${l10n.departureDate}: ${trip.date.day}/${trip.date.month}/${trip.date.year}');
    if (trip.rating > 0) {
      buffer.writeln('Rating: ${trip.rating.toStringAsFixed(1)} / 5');
    }
    if (trip.description.isNotEmpty) {
      buffer.writeln('\n${l10n.aboutjourney}:');
      buffer.writeln(trip.description);
    }
    buffer.writeln('\n---');
    buffer.writeln(l10n.appTitle.replaceAll('\n', ' '));

    final text = buffer.toString();
    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: trip.title));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.copiedToClipboard)),
        );
      }
    }
  }
}
