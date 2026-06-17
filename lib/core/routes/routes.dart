import 'package:flutter/material.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/home_page.dart';
import 'package:animations_in_flutter/views/pages/on_boarding_page.dart';
import 'package:animations_in_flutter/views/pages/settings_page.dart';
import 'package:animations_in_flutter/views/pages/statistics_page.dart';
import 'package:animations_in_flutter/views/pages/todo_page.dart';
import 'package:animations_in_flutter/views/widgets/main_shell.dart';
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
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/todo', builder: (_, _) => const TodoPage()),
            ],
          ),
        ],
      ),
    ],
  );
}
