import 'package:flutter/material.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/home/home_page.dart';
import 'package:animations_in_flutter/views/pages/next_trips/next_trips_page.dart';
import 'package:animations_in_flutter/views/pages/settings/on_boarding_page.dart';
import 'package:animations_in_flutter/views/pages/settings/settings_page.dart';
import 'package:animations_in_flutter/views/pages/statistics/statistics_page.dart';
import 'package:animations_in_flutter/views/pages/home/main_shell.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(TripProvider tripProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: tripProvider,
    initialLocation: '/home',
    redirect: (context, state) {
      if (tripProvider.isFirstTime && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      if (!tripProvider.isFirstTime && state.matchedLocation == '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/next-trips',
                builder: (_, _) => const NextTripsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (_, _) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
