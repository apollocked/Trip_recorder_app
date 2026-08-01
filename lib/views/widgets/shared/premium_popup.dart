import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/services/iap_service.dart';
import 'package:animations_in_flutter/services/premium_service.dart';
import 'package:provider/provider.dart';

class PremiumPopup extends StatefulWidget {
  const PremiumPopup({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremiumPopup(),
    );
  }

  @override
  State<PremiumPopup> createState() => _PremiumPopupState();
}

class _PremiumPopupState extends State<PremiumPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  bool _purchaseInProgress = false;
  Timer? _waitTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final topInset = MediaQuery.of(context).padding.top;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: EdgeInsets.only(top: topInset + 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Consumer<PremiumService>(
            builder: (context, premium, _) {
              final displayPrice = IapService().displayPrice;
              final price = premium.isLoading && _purchaseInProgress
                  ? '...'
                  : (displayPrice.isNotEmpty ? displayPrice : '4.99');

              return SingleChildScrollView(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.tertiary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: premium.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          loc.premiumTitle,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          premium.isLoading && _purchaseInProgress
                              ? 'Processing payment...'
                              : loc.premiumSubtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (premium.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 18,
                                  color: colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    premium.error!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => premium.clearError(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _FeatureRow(
                          icon: Icons.cloud_upload_rounded,
                          text: loc.premiumFeatureUpload,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _FeatureRow(
                          icon: Icons.sync_rounded,
                          text: loc.premiumFeatureSync,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _FeatureRow(
                          icon: Icons.backup_rounded,
                          text: loc.premiumFeatureBackup,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _FeatureRow(
                          icon: Icons.support_agent_rounded,
                          text: loc.premiumFeatureSupport,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _FeatureRow(
                          icon: Icons.bar_chart_rounded,
                          text: loc.premiumAdvancedStats,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _FeatureRow(
                          icon: Icons.picture_as_pdf_rounded,
                          text: loc.premiumFeatureExport,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: premium.isLoading
                                ? null
                                : () => _handleBuy(context, premium),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: premium.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    loc.premiumBuyFor(price),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: premium.isLoading
                              ? null
                              : () => _handleRestore(context, premium),
                          child: Text(loc.premiumRestore),
                        ),
                        TextButton(
                          onPressed: premium.isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          child: Text(loc.premiumNotNow),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleBuy(BuildContext context, PremiumService premium) async {
    setState(() => _purchaseInProgress = true);

    final success = await premium.buyPremium();

    if (!success) {
      setState(() => _purchaseInProgress = false);
      return;
    }

    if (!context.mounted) return;

    _waitForPurchaseResult(context, premium);
  }

  void _waitForPurchaseResult(BuildContext context, PremiumService premium) {
    int elapsed = 0;
    const maxWait = Duration(seconds: 60);

    _waitTimer?.cancel();
    _waitTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      elapsed += 500;

      if (premium.isPremium) {
        timer.cancel();
        if (context.mounted) {
          Navigator.pop(context, true);
        }
        return;
      }

      if (premium.error != null || premium.isLoading == false) {
        timer.cancel();
        if (context.mounted) {
          setState(() => _purchaseInProgress = false);
        }
        return;
      }

      if (elapsed >= maxWait.inMilliseconds) {
        timer.cancel();
        if (context.mounted) {
          setState(() => _purchaseInProgress = false);
        }
      }
    });
  }

  Future<void> _handleRestore(
    BuildContext context,
    PremiumService premium,
  ) async {
    final restored = await premium.restorePurchases();
    if (restored && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
