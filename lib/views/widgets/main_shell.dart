import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (i) => navigationShell.goBranch(i),
            animationDuration: const Duration(milliseconds: 400),
            elevation: 0,
            shadowColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorShape: const StadiumBorder(),
            height: 72,
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: l10n.home),
              NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart_rounded), label: l10n.statistics),
              NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings_rounded), label: l10n.settingsTitle),
              NavigationDestination(icon: const Icon(Icons.assignment_outlined), selectedIcon: const Icon(Icons.assignment_rounded), label: l10n.todo),
            ],
          ),
          Positioned(
            top: -28, left: 0, right: 0,
            child: Center(
              child: SizedBox(height: 56, width: 56,
                child: Tooltip(message: l10n.fabTooltip, child: FloatingActionButton(
                  heroTag: 'nav_add',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTripPage())),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add_rounded),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
