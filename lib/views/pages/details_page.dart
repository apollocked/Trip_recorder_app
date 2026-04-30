import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/widgets/cover_image_leading.dart';
import 'package:animations_in_flutter/views/widgets/heart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DetailsPage extends StatelessWidget {
  final Trip trip;
  final int index;
  const DetailsPage({super.key, required this.trip, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Consumer<TripService>(
      builder: (context, tripService, _) {
        if (index >= tripService.trips.length) return const Scaffold();
        final currentTrip = tripService.trips[index];
        return Scaffold(
          backgroundColor: colorScheme.surface,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.edit_note_rounded,
                  size: 28,
                  semanticLabel: 'Edit the trip,',
                ),
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  final updatedTrip = await Navigator.push<Trip>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTripPage(trip: currentTrip),
                    ),
                  );
                  if (updatedTrip != null && context.mounted) {
                    tripService.updateTrip(index, updatedTrip);
                    HapticFeedback.vibrate();
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface.withAlpha(200),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Hero(
                      tag: 'tag-image-${currentTrip.img}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(32),
                        ),
                        child: Semantics(
                          label: 'Trip cover image',
                          child: coverImage(currentTrip.img),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 1.0, end: 0.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, double op, Widget? child) => Opacity(
                      opacity: 1 - op,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 24,
                          right: 24,
                          left: 24,
                          bottom: (op * 20),
                        ),
                        child: child,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. THE TEXT CONTENT (Title and Chips)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 60),
                                  child: Text(
                                    semanticsLabel:
                                        'Trip title is ${currentTrip.title}',
                                    currentTrip.title,
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Semantics(
                                      label: 'Trip duration is',
                                      child: _buildInfoChip(
                                        context,
                                        icon: Icons.bedtime_rounded,
                                        label: '${currentTrip.nights} Nights',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Semantics(
                                      label: 'Trip cost in dollars is ',
                                      child: _buildInfoChip(
                                        context,
                                        icon: Icons.attach_money_rounded,
                                        label: currentTrip.price,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withAlpha(
                                    150,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: HeartWidget(
                                  isLiked: currentTrip.isLiked,
                                  index: index,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: colorScheme.outlineVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.aboutjourney,
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
                                currentTrip.description.isNotEmpty
                                    ? currentTrip.description
                                    : AppLocalizations.of(
                                        context,
                                      )!.noDescriptionAdded,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.6,
                                ),
                                semanticsLabel:
                                    "the description of the trip is ${currentTrip.description.isEmpty ? 'empty' : currentTrip.description}",
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

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
