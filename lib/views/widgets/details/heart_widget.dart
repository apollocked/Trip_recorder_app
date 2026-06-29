// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HeartWidget extends StatefulWidget {
  final String tripId;
  final bool isLiked;

  const HeartWidget({super.key, required this.isLiked, required this.tripId});

  @override
  State<HeartWidget> createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> colorAnimation;
  late Animation<double> sizeAnimation;
  late Animation<double> curveAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    curveAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.slowMiddle,
    );

    colorAnimation = ColorTween(
      begin: AppColors.favoriteInactive,
      end: AppColors.favoriteActive,
    ).animate(curveAnimation);

    sizeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 30, end: 50), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 50, end: 30), weight: 50),
    ]).animate(curveAnimation);

    if (widget.isLiked) {
      controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onPressed() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final trip = tripProvider.getTripById(widget.tripId);
    if (trip == null) return;
    tripProvider.toggleLike(widget.tripId);
    if (!trip.isLiked) {
      controller.forward();
    } else {
      controller.reverse();
    }
    HapticFeedback.errorNotification();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        return ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface.withAlpha(153),
                border: Border.all(
                  color: colorScheme.outlineVariant.withAlpha(102),
                  width: 1,
                ),
              ),
              child: IconButton(
                padding: const EdgeInsets.all(12),
                icon: Icon(
                  Icons.favorite_rounded,
                  color: colorAnimation.value,
                  size: sizeAnimation.value,
                  semanticLabel: AppLocalizations.of(context)!.addToFavorites,
                ),
                onPressed: () async {
                  final l10n = AppLocalizations.of(context)!;
                  onPressed();
                  if (controller.value > 0.5) {
                    SemanticsService.announce(
                      l10n.addedToFavorites,
                      Directionality.of(context),
                    );
                  } else {
                    SemanticsService.announce(
                      l10n.removedFromFavorites,
                      Directionality.of(context),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
