import 'package:animations_in_flutter/l10n/l10n.dart';
import 'package:animations_in_flutter/services/language_service.dart';
import 'package:animations_in_flutter/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSettingsModal(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => Container(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Text(
              'Settings',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 24),

            // Language Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withAlpha(102),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<LanguageService>(
                    builder: (context, languageService, _) {
                      return Wrap(
                        spacing: 8,
                        children: L10n.all.map((locale) {
                          final isSelected =
                              languageService.locale.languageCode ==
                              locale.languageCode;
                          return ChoiceChip(
                            label: Text(L10n.getNativeName(locale.languageCode)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                languageService.setLocale(locale);
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Theme Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withAlpha(102),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<ThemeService>(
                    builder: (context, themeService, _) {
                      return Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Light'),
                            selected: themeService.themeMode == ThemeMode.light,
                            onSelected: (selected) {
                              if (selected) {
                                themeService.setThemeMode(ThemeMode.light);
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Dark'),
                            selected: themeService.themeMode == ThemeMode.dark,
                            onSelected: (selected) {
                              if (selected) {
                                themeService.setThemeMode(ThemeMode.dark);
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('System'),
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
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
