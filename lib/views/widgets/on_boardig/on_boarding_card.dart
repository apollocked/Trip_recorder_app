import 'dart:ui';

import 'package:animations_in_flutter/views/pages/on_boarding_page.dart';
import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  // Fixed: Changed .withOpacity(0.06) to .withValues(alpha: 0.06)
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    // Fixed: Changed .withOpacity(0.12) to .withValues(alpha: 0.12)
                    color: colorScheme.onSurface.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Icon(item.icon, size: 72, color: colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
