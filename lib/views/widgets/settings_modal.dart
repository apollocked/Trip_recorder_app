import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/l10n/l10n.dart';
import 'package:animations_in_flutter/services/language_service.dart';
import 'package:animations_in_flutter/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSettingsModal(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final loc = AppLocalizations.of(context)!;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
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
                _SectionCard(
                  icon: Icons.language_rounded,
                  title: loc.language,
                  child: Consumer<LanguageService>(
                    builder: (context, languageService, _) {
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: L10n.all.map((locale) {
                          final isSelected =
                              languageService.locale.languageCode ==
                              locale.languageCode;
                          return ChoiceChip(
                            label: Text(L10n.getNativeName(locale.languageCode)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) languageService.setLocale(locale);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.palette_outlined,
                  title: loc.theme,
                  child: Consumer<ThemeService>(
                    builder: (context, themeService, _) {
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ChoiceChip(
                            avatar: const Icon(Icons.light_mode_outlined),
                            label: Text(loc.light),
                            selected: themeService.themeMode == ThemeMode.light,
                            onSelected: (selected) {
                              if (selected) {
                                themeService.setThemeMode(ThemeMode.light);
                              }
                            },
                          ),
                          ChoiceChip(
                            avatar: const Icon(Icons.dark_mode_outlined),
                            label: Text(loc.dark),
                            selected: themeService.themeMode == ThemeMode.dark,
                            onSelected: (selected) {
                              if (selected) {
                                themeService.setThemeMode(ThemeMode.dark);
                              }
                            },
                          ),
                          ChoiceChip(
                            avatar: const Icon(Icons.phone_android_outlined),
                            label: Text(loc.system),
                            selected:
                                themeService.themeMode == ThemeMode.system,
                            onSelected: (selected) {
                              if (selected) {
                                themeService.setThemeMode(ThemeMode.system);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
