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
            // Setting iconTheme ensures buttons are visible over the image
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 28),
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
                    HapticFeedback.vibrate(); // Solid feedback for update
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER IMAGE SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface.withAlpha(200),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(32)),
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
                        child: coverImage(currentTrip.img),
                      ),
                    ),
                  ),
                ),

                // TRIP INFO SECTION (Animated Entry)
                Flexible(
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 1.0, end: 0.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, double op, Widget? child) => Opacity(
                      opacity: 1 - op,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          right: 24,
                          left: 24,
                          bottom: (op * 20), // Slight slide up effect
                        ),
                        child: child,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentTrip.title,
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${currentTrip.nights} Nights • \$${currentTrip.price}',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Premium Heart placement
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withAlpha(
                                  200,
                                ),

                                shape: BoxShape.circle,
                              ),
                              child: HeartWidget(
                                isLiked: currentTrip.isLiked,
                                index: index,
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
                          "About this journey",
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
                            child: Text(
                              currentTrip.description.isNotEmpty
                                  ? currentTrip.description
                                  : 'No description added for this trip yet.',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.6,
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
}
