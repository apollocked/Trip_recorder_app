import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/route_transition.dart';

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
      duration: const Duration(milliseconds: 600),
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
      slideRoute(const AddTripPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = widget.navigationShell.currentIndex;

    final navIcons = [
      Icons.home_outlined,
      Icons.flight_takeoff_outlined,
      Icons.stacked_bar_chart_outlined,
      Icons.settings_outlined,
    ];

    final navSelectedIcons = [
      Icons.home_rounded,
      Icons.flight_takeoff_rounded,
      Icons.stacked_bar_chart_rounded,
      Icons.settings_rounded,
    ];

    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.65,
                    ),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 40,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < 2; i++)
                        Expanded(
                          child: _buildNavItem(
                            icon: currentIndex == i
                                ? navSelectedIcons[i]
                                : navIcons[i],
                            isSelected: currentIndex == i,
                            colorScheme: colorScheme,
                            onTap: () => widget.navigationShell.goBranch(i),
                          ),
                        ),
                      Expanded(
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
                                        height: 42,
                                        width: 42,
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
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: colorScheme.onPrimary,
                                          size: 24,
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
                      for (int i = 2; i < 4; i++)
                        Expanded(
                          child: _buildNavItem(
                            icon: currentIndex == i
                                ? navSelectedIcons[i]
                                : navIcons[i],
                            isSelected: currentIndex == i,
                            colorScheme: colorScheme,
                            onTap: () => widget.navigationShell.goBranch(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withAlpha(160)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: isSelected
                    ? Tween(begin: 0.85, end: 1.0)
                    : Tween(begin: 1.0, end: 0.85),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (context, scale, _) => Transform.scale(
                  scale: scale,
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 3,
                width: isSelected ? 16 : 0,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
