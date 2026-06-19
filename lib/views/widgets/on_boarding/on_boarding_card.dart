import 'dart:math' as math;

import 'package:animations_in_flutter/views/pages/on_boarding_page.dart';
import 'package:flutter/material.dart';

class FeatureBadge {
  final IconData icon;
  final String label;
  const FeatureBadge(this.icon, this.label);
}

class OnboardingCard extends StatefulWidget {
  final OnboardingItem item;
  final double pageFraction;

  const OnboardingCard({
    super.key,
    required this.item,
    this.pageFraction = 0.0,
  });

  @override
  State<OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<OnboardingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    if (widget.pageFraction.abs() < 0.5) _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingCard old) {
    super.didUpdateWidget(old);
    final dist = widget.pageFraction.abs();
    if (dist < 0.5 && !_ctrl.isCompleted) {
      _ctrl.forward();
    } else if (dist >= 0.5 && _ctrl.isCompleted) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroVisual(icon: widget.item.icon, colorScheme: colorScheme),
              const SizedBox(height: 40),
              if (widget.item.welcome != null) ...[
                Text(
                  widget.item.welcome!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.item.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              _FeatureBadgeRow(features: widget.item.features, colorScheme: colorScheme),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;

  const _HeroVisual({required this.icon, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surface,
          ],
          center: Alignment.center,
          radius: 0.9,
        ),
      ),
      child: Center(
        child: Transform.rotate(
          angle: -math.pi / 12,
          child: Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 60, color: colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _FeatureBadgeRow extends StatelessWidget {
  final List<FeatureBadge> features;
  final ColorScheme colorScheme;

  const _FeatureBadgeRow({required this.features, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(120),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(100),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(f.icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                f.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
