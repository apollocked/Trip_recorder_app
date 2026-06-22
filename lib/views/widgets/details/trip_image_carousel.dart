import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/pages/image_viewer_page.dart';
import 'package:animations_in_flutter/views/widgets/common/cover_image_leading.dart';
import 'package:animations_in_flutter/core/route_transition.dart';

class TripImageCarousel extends StatelessWidget {
  final Trip trip;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const TripImageCarousel({
    super.key,
    required this.trip,
    required this.colorScheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 280.0;

    if (trip.imagePaths.isEmpty) {
      return Center(
        child: Container(
          height: size,
          width: size,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Center(
            child: Icon(
              Icons.landscape,
              size: 60,
              color: AppColors.placeholderIcon,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: size,
      child: PageView.builder(
        itemCount: trip.imagePaths.length,
        controller: PageController(viewportFraction: 0.75),
        itemBuilder: (context, index) {
          return Center(
            child: SizedBox(
              height: size,
              width: size,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    slideRoute(ImageViewerPage(
                      imagePaths: trip.imagePaths,
                      initialIndex: index,
                    )),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface.withAlpha(200),
                        width: 1,
                      ),
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
                          label: l10n.imageCoverSemantics(index + 1),
                          child: coverImage(trip.imagePaths[index]),
                        ),
                      ),
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
}
