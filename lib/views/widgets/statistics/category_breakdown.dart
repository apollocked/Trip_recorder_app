import 'package:flutter/material.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';

typedef CategoryLabeler<T> = String Function(AppLocalizations l10n, T category);

class CategoryBreakdown<T> extends StatelessWidget {
  final Map<T, int> categoryCounts;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final CategoryLabeler<T> labeler;

  const CategoryBreakdown({
    super.key,
    required this.categoryCounts,
    required this.colorScheme,
    required this.l10n,
    required this.labeler,
  });

  @override
  Widget build(BuildContext context) {
    final total = categoryCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Column(
        children: categoryCounts.entries.map<Widget>((entry) {
          final count = entry.value;
          final fraction = count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(labeler(l10n, entry.key),
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text('$count', textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
