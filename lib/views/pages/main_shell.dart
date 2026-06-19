import 'dart:math' as math;
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onFabTap() {
    _fabController
      ..value = 0.0
      ..forward().then((_) => _fabController.reverse());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTripPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (i) => widget.navigationShell.goBranch(i),
            animationDuration: const Duration(milliseconds: 500),
            elevation: 0,
            shadowColor: AppColors.transparent,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.85,
            ),
            surfaceTintColor: AppColors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorShape: const StadiumBorder(),
            height: 72,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.stacked_bar_chart_outlined),
                selectedIcon: const Icon(Icons.stacked_bar_chart_rounded),
                label: l10n.statistics,
              ),

              NavigationDestination(
                icon: const Icon(Icons.assignment_outlined),
                selectedIcon: const Icon(Icons.assignment_rounded),
                label: l10n.todo,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: l10n.settingsTitle,
              ),
            ],
          ),
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _onFabTap,
                child: Tooltip(
                  message: l10n.fabTooltip,
                  child: AnimatedBuilder(
                    animation: _fabController,
                    builder: (context, _) {
                      final value = _fabController.value;
                      final rotation = value * 0.125 * 2 * math.pi;
                      final scale = 1.0 - (value * 0.12);
                      return Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: rotation,
                          child: Container(
                            height: 60,
                            width: 60,
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
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: colorScheme.onPrimary,
                              size: 28,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
