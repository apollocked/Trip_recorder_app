import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
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
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
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
                  loc.premiumSubtitle,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
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
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      loc.premiumActivate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(loc.premiumNotNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
