import 'package:flutter/material.dart';

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: -size.height * 0.08,
      left: -size.width * 0.1,
      child: Container(
        width: size.width * 0.8,
        height: size.width * 0.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

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
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(Icons.travel_explore, color: t.colorScheme.onSurfaceVariant, size: 28),
            const SizedBox(width: 10),
            Text(title.toUpperCase(), style: t.textTheme.titleMedium?.copyWith(
              color: t.colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ]),
          IconButton(
            icon: Icon(Icons.settings_suggest_rounded, color: t.colorScheme.onSurfaceVariant),
            onPressed: onSettingsPressed, tooltip: tooltipText),
        ],
      ),
    );
  }
}
