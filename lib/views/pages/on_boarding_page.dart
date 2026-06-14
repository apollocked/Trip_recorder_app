import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/on_boardig/on_boarding_card.dart';
import 'package:animations_in_flutter/views/widgets/on_boardig/on_boarding_footer.dart';
import 'package:animations_in_flutter/views/widgets/on_boardig/onboarding_header.dart';
import 'package:animations_in_flutter/views/widgets/settings_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNavigation(int totalItems) async {
    if (_currentPage < totalItems - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await context.read<TripProvider>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final List<OnboardingItem> items = [
      OnboardingItem(
        icon: Icons.auto_awesome_rounded,
        title: loc.onboardingTitle1,
        description: loc.onboardingDesc1,
      ),
      OnboardingItem(
        icon: Icons.map_rounded,
        title: loc.onboardingTitle2,
        description: loc.onboardingDesc2,
      ),
      OnboardingItem(
        icon: Icons.phonelink_setup_rounded,
        title: loc.onboardingTitle3,
        description: loc.onboardingDesc3,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          const AmbientGlow(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                OnboardingHeader(
                  title: loc.appTitle,
                  tooltipText: loc.settingsTitle,
                  onSettingsPressed: () => showSettingsModal(context),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) =>
                        OnboardingCard(item: items[index]),
                  ),
                ),
                OnboardingFooter(
                  itemCount: items.length,
                  currentPage: _currentPage,
                  buttonText: loc.getStarted,
                  onNextPressed: () => _handleNavigation(items.length),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
