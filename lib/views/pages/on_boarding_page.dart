import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/on_boarding/on_boarding_card.dart';
import 'package:animations_in_flutter/views/widgets/on_boarding/on_boarding_footer.dart';
import 'package:animations_in_flutter/views/widgets/on_boarding/on_boarding_header.dart';
import 'package:animations_in_flutter/views/widgets/settings/settings_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

class OnboardingItem {
  final IconData icon;
  final String title;
  final String? welcome;
  final String description;
  final String tip;
  final List<FeatureBadge> features;

  const OnboardingItem({
    required this.icon,
    required this.title,
    this.welcome,
    required this.description,
    required this.tip,
    required this.features,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _page = 0;
  double _pageFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() => _pageFraction = _ctrl.page ?? 0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next(int total) {
    if (_page < total - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.read<TripProvider>().completeOnboarding();
    }
  }

  void _skip() {
    context.read<TripProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l = AppLocalizations.of(context)!;
    final items = [
      OnboardingItem(
        icon: Icons.explore_rounded,
        title: l.onboardingTitle1,
        welcome: l.onboardingWelcome,
        description: l.onboardingDesc1,
        tip: l.onboardingTip1,
        features: [
          FeatureBadge(Icons.photo_camera_rounded, l.onboardingBadgePhotos),
          FeatureBadge(Icons.star_rounded, l.onboardingBadgeRatings),
          FeatureBadge(Icons.category_rounded, l.onboardingBadgeCategories),
          FeatureBadge(Icons.event_rounded, l.onboardingBadgeFutureTrips),
        ],
      ),
      OnboardingItem(
        icon: Icons.dashboard_customize_rounded,
        title: l.onboardingTitle2,
        description: l.onboardingDesc2,
        tip: l.onboardingTip2,
        features: [
          FeatureBadge(Icons.checklist_rounded, l.onboardingBadgeChecklist),
          FeatureBadge(Icons.account_balance_wallet_rounded, l.onboardingBadgeBudget),
          FeatureBadge(Icons.auto_stories_rounded, l.onboardingBadgeJournal),
          FeatureBadge(Icons.notifications_active_rounded, l.onboardingBadgeReminders),
        ],
      ),
      OnboardingItem(
        icon: Icons.auto_awesome_rounded,
        title: l.onboardingTitle3,
        description: l.onboardingDesc3,
        tip: l.onboardingTip3,
        features: [
          FeatureBadge(Icons.bar_chart_rounded, l.onboardingBadgeStatistics),
          FeatureBadge(Icons.favorite_rounded, l.onboardingBadgeFavorites),
          FeatureBadge(Icons.timeline_rounded, l.onboardingBadgeMemories),
          FeatureBadge(Icons.currency_exchange_rounded, l.onboardingBadgeConverter),
          FeatureBadge(Icons.shield_rounded, l.onboardingBadgeOffline),
        ],
      ),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          children: [
            // Animated ambient glow that follows page
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) {
                final glowProgress = (_pageFraction % 1).clamp(0.0, 1.0);
                final colors = [cs.primary, cs.tertiary, cs.secondary];
                final i = _page.clamp(0, 2);
                final next = (i + 1).clamp(0, 2);
                final glowColor = Color.lerp(
                  colors[i],
                  colors[next],
                  glowProgress,
                )!;
                return Stack(
                  children: [
                    AmbientGlow(
                      color: glowColor,
                      size: 0.9,
                      alignment: Alignment.topLeft,
                    ),
                    AmbientGlow(
                      color: glowColor.withValues(alpha: 0.5),
                      size: 0.5,
                      alignment: Alignment.bottomRight,
                    ),
                  ],
                );
              },
            ),
            SafeArea(
              child: Column(
                children: [
                  // Top bar with settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.travel_explore, color: cs.primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l.appTitle.toUpperCase(),
                              style: t.textTheme.titleSmall?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => showSettingsModal(context),
                          style: TextButton.styleFrom(
                            foregroundColor: cs.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.settings_rounded, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                l.settingsTitle,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _ctrl,
                      itemCount: items.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) => OnboardingCard(
                        item: items[i],
                        pageFraction: _pageFraction - i,
                      ),
                    ),
                  ),
                  OnboardingFooter(
                    itemCount: items.length,
                    currentPage: _page,
                    buttonText: l.getStarted,
                    nextLabel: l.nextLabel,
                    skipLabel: l.skipLabel,
                    onNextPressed: () => _next(items.length),
                    onSkip: _skip,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}