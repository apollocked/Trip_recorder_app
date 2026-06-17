import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/on_boarding/on_boarding_card.dart';
import 'package:animations_in_flutter/views/widgets/on_boarding/on_boarding_footer.dart';
import 'package:animations_in_flutter/views/widgets/on_boarding/onboarding_header.dart';
import 'package:animations_in_flutter/views/widgets/settings/settings_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final String tip;

  const OnboardingItem({required this.icon, required this.title, required this.description, required this.tip});
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _next(int total) {
    if (_page < total - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      context.read<TripProvider>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final items = [
      OnboardingItem(icon: Icons.auto_awesome_rounded, title: l.onboardingTitle1, description: l.onboardingDesc1, tip: l.onboardingTip1),
      OnboardingItem(icon: Icons.map_rounded, title: l.onboardingTitle2, description: l.onboardingDesc2, tip: l.onboardingTip2),
      OnboardingItem(icon: Icons.phonelink_setup_rounded, title: l.onboardingTitle3, description: l.onboardingDesc3, tip: l.onboardingTip3),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: t.colorScheme.surface,
        body: Stack(children: [
          AmbientGlow(),
          SafeArea(child: Column(children: [
            const SizedBox(height: 16),
            OnboardingHeader(title: l.appTitle, tooltipText: l.settingsTitle,
              onSettingsPressed: () => showSettingsModal(context)),
            Expanded(child: PageView.builder(
              controller: _ctrl, itemCount: items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => OnboardingCard(item: items[i]),
            )),
            OnboardingFooter(itemCount: items.length, currentPage: _page,
              buttonText: l.getStarted, onNextPressed: () => _next(items.length)),
          ])),
        ]),
      ),
    );
  }
}
