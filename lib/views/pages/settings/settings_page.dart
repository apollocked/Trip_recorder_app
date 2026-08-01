import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/data/repositories/custom_category_repository.dart';
import 'package:animations_in_flutter/model/custom_category.dart';
import 'package:animations_in_flutter/services/iap_service.dart';
import 'package:animations_in_flutter/services/language_service.dart';
import 'package:animations_in_flutter/services/premium_service.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';
import 'package:animations_in_flutter/services/theme_service.dart';
import 'package:animations_in_flutter/views/pages/settings/privacy_policy_page.dart';
import 'package:animations_in_flutter/views/widgets/shared/premium_popup.dart';
import 'package:animations_in_flutter/core/route_transition.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final svc = SupabaseService();
    if (!svc.isInitialized) {
      setState(() => _error = 'Cloud sync is not available');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        await svc.signUp(email: _emailController.text.trim(), password: _passwordController.text);
      } else {
        await svc.signIn(email: _emailController.text.trim(), password: _passwordController.text);
      }
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService().signOut();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handlePremiumTap() async {
    final premium = context.read<PremiumService>();
    if (premium.isPremium) return;
    final result = await PremiumPopup.show(context);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.premiumPurchaseSuccess),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final svc = SupabaseService();
    final isLoggedIn = svc.isLoggedIn;
    final premium = context.watch<PremiumService>();

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
            icon: Icons.workspace_premium_rounded,
            title: loc.premiumTitle,
            colorScheme: colorScheme,
            textTheme: textTheme,
            child: premium.isPremium
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          premium.initials,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              premium.userName.isNotEmpty ? premium.userName : loc.premiumTitle,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              premium.userEmail,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                loc.premiumActiveLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.premiumDesc,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _handlePremiumTap,
                          icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                          label: Text(loc.premiumBuyFor(IapService().displayPrice)),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final premiumService = context.read<PremiumService>();
                            final restored = await premiumService.restorePurchases();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  restored
                                      ? loc.premiumPurchaseSuccess
                                      : (premiumService.error ?? loc.premiumPurchaseFailed),
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.restore_rounded, size: 18),
                          label: Text(loc.premiumRestore),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.cloud_outlined,
            title: loc.cloudSync,
            colorScheme: colorScheme,
            textTheme: textTheme,
            child: isLoggedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        svc.userEmail ?? '',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signOut,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: Text(loc.signOut),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.cloudSyncDesc,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: loc.email,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: loc.password,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: TextStyle(color: colorScheme.error, fontSize: 12)),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleAuth,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(_isSignUp ? loc.signUp : loc.signIn),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _isSignUp = !_isSignUp),
                          child: Text(_isSignUp ? loc.alreadyHaveAccount : loc.dontHaveAccount),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 14),
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
            child: Consumer2<ThemeService, PremiumService>(
              builder: (context, themeService, premium, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
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
                    ),
                    const SizedBox(height: 14),
                    Text(
                      loc.colorScheme,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ThemeService.themeNames.entries.map((entry) {
                        final isSelected = themeService.premiumTheme == entry.key;
                        final isLocked = ThemeService.isPremiumTheme(entry.key) && !premium.isPremium;
                        return ChoiceChip(
                          avatar: isLocked
                              ? const Icon(Icons.lock_rounded, size: 16)
                              : null,
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (isLocked) {
                              _handlePremiumThemeTap(context);
                              return;
                            }
                            if (selected) themeService.setPremiumTheme(entry.key);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.category_outlined,
            title: loc.customCategories,
            colorScheme: colorScheme,
            textTheme: textTheme,
            child: Consumer<PremiumService>(
              builder: (context, premium, _) {
                if (!premium.isPremium) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.customCategoriesDesc,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _handlePremiumThemeTap(context),
                          icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                          label: Text(loc.premiumUpgrade),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.customCategoriesDesc,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddCategoryDialog(context, 'trip'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(loc.addTripCategory),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddCategoryDialog(context, 'expense'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(loc.addExpenseCategory),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.support_agent_rounded,
            title: loc.prioritySupport,
            colorScheme: colorScheme,
            textTheme: textTheme,
            child: Consumer<PremiumService>(
              builder: (context, premium, _) {
                if (!premium.isPremium) {
                  return Text(
                    loc.premiumSupportDesc,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.premiumSupportActiveDesc,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.supportContactEmail),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.email_outlined, size: 18),
                        label: Text(loc.contactSupport),
                      ),
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

          const SizedBox(height: 24),
          Center(
            child: FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                return Text(
                  'Trip Recorder v${snapshot.data ?? ''}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '';
    }
  }

  Future<void> _handlePremiumThemeTap(BuildContext context) async {
    final premium = context.read<PremiumService>();
    if (premium.isPremium) return;
    final result = await PremiumPopup.show(context);
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.premiumPurchaseSuccess),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _showAddCategoryDialog(BuildContext context, String type) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'trip' ? loc.addTripCategory : loc.addExpenseCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: type == 'trip' ? 'e.g. Safari' : 'e.g. Visa',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(loc.save),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final repo = CustomCategoryRepository();
      await repo.addCategory(CustomCategory(name: result, type: type));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.categoryAdded),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
