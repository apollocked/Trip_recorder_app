import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/pages/currency_converter_page.dart';
import 'package:animations_in_flutter/views/widgets/settings/settings_sections.dart';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/route_transition.dart';

void showSettingsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _SettingsModalBody(),
  );
}

class _SettingsModalBody extends StatelessWidget {
  const _SettingsModalBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.settingsTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              const LanguageSection(),
              const SizedBox(height: 14),
              const ThemeSection(),
              const SizedBox(height: 14),
              _CurrencySection(),
              const SizedBox(height: 14),
              const PrivacySection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                loc.currencyConverter,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  slideRoute(const CurrencyConverterPage()),
                );
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(loc.currencyConverter),
            ),
          ),
        ],
      ),
    );
  }
}
