import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

class FutureTripBanner extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const FutureTripBanner({
    super.key,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.tertiary.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.futureTripInfo,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
