import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: c.primaryContainer.withAlpha(80),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: c.primary.withAlpha(180)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: c.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: t.bodyMedium?.copyWith(
                  color: c.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (description != null) ...[
              const SizedBox(height: 16),
              Text(
                description!,
                style: t.bodySmall?.copyWith(
                  color: c.onSurfaceVariant.withAlpha(180),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
