import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicy,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacyIntro,
              style: textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
            _section(
              textTheme,
              colorScheme,
              l10n.privacyDataTitle,
              l10n.privacyDataBody,
            ),
            const SizedBox(height: 20),
            _section(
              textTheme,
              colorScheme,
              l10n.privacyUseTitle,
              l10n.privacyUseBody,
            ),
            const SizedBox(height: 20),
            _section(
              textTheme,
              colorScheme,
              l10n.privacyStorageTitle,
              l10n.privacyStorageBody,
            ),
            const SizedBox(height: 20),
            _section(
              textTheme,
              colorScheme,
              l10n.privacyThirdPartyTitle,
              l10n.privacyThirdPartyBody,
            ),
            const SizedBox(height: 20),
            _section(
              textTheme,
              colorScheme,
              l10n.privacyContactTitle,
              l10n.privacyContactBody,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                l10n.privacyLastUpdated,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    TextTheme textTheme,
    ColorScheme colorScheme,
    String title,
    String body,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
