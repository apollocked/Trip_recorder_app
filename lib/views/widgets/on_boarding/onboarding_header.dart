import 'package:flutter/material.dart';

class AmbientGlow extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;

  const AmbientGlow({
    super.key,
    this.color = Colors.transparent,
    this.size = 0.8,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final glowColor = color == Colors.transparent
        ? Theme.of(context).colorScheme.primary
        : color;
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: screenSize.width * size,
          height: screenSize.width * size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glowColor.withValues(alpha: 0.1),
          ),
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
            Icon(Icons.travel_explore, color: t.colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            Text(title.toUpperCase(), style: t.textTheme.titleMedium?.copyWith(
              color: t.colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ]),
          TextButton(
            onPressed: onSettingsPressed,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.settings_rounded, size: 18, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(tooltipText, style: TextStyle(color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}
