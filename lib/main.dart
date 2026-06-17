import 'package:animations_in_flutter/core/constants.dart';
import 'package:animations_in_flutter/core/routes.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/l10n/localization_config.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/services/language_service.dart';
import 'package:animations_in_flutter/services/notification_service.dart';
import 'package:animations_in_flutter/services/theme_service.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool(AppConstants.prefOnboardingDone) != true;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TripProvider(isFirstTime: isFirstTime),
        ),
        ChangeNotifierProvider(create: (_) => LanguageService()),

        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<TripProvider>());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageService>().locale;
    final themeMode = context.watch<ThemeService>().themeMode;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: l10n,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      localeResolutionCallback: appLocaleResolutionCallback,
      builder: (context, child) {
        return Directionality(
          textDirection: appTextDirectionForLocale(l10n),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF00796B),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF00796B),
        ),
      ),
      themeMode: themeMode,
    );
  }
}
