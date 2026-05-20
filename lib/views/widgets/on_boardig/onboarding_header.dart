import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  final String title;
  final String tooltipText;
  final VoidCallback onSettingsPressed;

  const OnboardingHeader({
    super.key,
    required this.title,
    required this.tooltipText,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.travel_explore,
                color: theme.colorScheme.onSurfaceVariant,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.settings_suggest_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: onSettingsPressed,
            tooltip: tooltipText,
          ),
        ],
      ),
    );
  }
}

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: -100,
      start: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Fixed: Changed .withOpacity(0.15) to .withValues(alpha: 0.15)
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
