import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/services/language_service.dart';
import 'package:animations_in_flutter/services/theme_service.dart';
import 'package:animations_in_flutter/views/pages/privacy_policy_page.dart';
import 'package:animations_in_flutter/core/route_transition.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.settingsTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 92 + MediaQuery.of(context).padding.bottom),
        children: [
          _SectionCard(
            icon: Icons.language_rounded,
            title: loc.language,
            colorScheme: colorScheme,
            textTheme: textTheme,
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
            colorScheme: colorScheme,
            textTheme: textTheme,
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
                        if (selected) themeService.setThemeMode(ThemeMode.dark);
                      },
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.phone_android_outlined),
                      label: Text(loc.system),
                      selected: themeService.themeMode == ThemeMode.system,
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

          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.privacy_tip_outlined,
            title: loc.privacyPolicy,
            colorScheme: colorScheme,
            textTheme: textTheme,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  slideRoute(const PrivacyPolicyPage()),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(loc.privacyPolicy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
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
