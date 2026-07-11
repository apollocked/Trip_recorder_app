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
    final cs = theme.colorScheme;
    final isSmall = MediaQuery.of(context).size.height < 700;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 60,
            bottom: 40,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeroVisual(icon: widget.item.icon, cs: cs, compact: isSmall),
                SizedBox(height: isSmall ? 24 : 40),
                if (widget.item.welcome != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.item.welcome!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: cs.onSurface,
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
                    color: cs.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: isSmall ? 20 : 32),
                _FeatureBadgeRow(features: widget.item.features, cs: cs),
                const SizedBox(height: 16),
                _TipBox(tip: widget.item.tip, cs: cs, theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  final bool compact;

  const _HeroVisual({required this.icon, required this.cs, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final outer = compact ? 120.0 : 180.0;
    final inner = compact ? 80.0 : 120.0;
    final iconSize = compact ? 36.0 : 52.0;
    return Container(
      height: outer,
      width: outer,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            cs.primaryContainer,
            cs.surface,
          ],
          center: Alignment.center,
          radius: 0.85,
        ),
      ),
      child: Center(
        child: Transform.rotate(
          angle: -math.pi / 12,
          child: Container(
            height: inner,
            width: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [cs.primary, cs.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: iconSize, color: cs.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _FeatureBadgeRow extends StatelessWidget {
  final List<FeatureBadge> features;
  final ColorScheme cs;

  const _FeatureBadgeRow({required this.features, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withAlpha(120),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withAlpha(80),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(f.icon, size: 15, color: cs.primary),
              const SizedBox(width: 5),
              Text(
                f.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String tip;
  final ColorScheme cs;
  final ThemeData theme;

  const _TipBox({
    required this.tip,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: cs.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onTertiaryContainer,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
