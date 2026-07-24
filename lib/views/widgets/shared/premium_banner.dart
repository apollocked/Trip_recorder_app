import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.tertiaryContainer,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.premiumActiveLabel,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
