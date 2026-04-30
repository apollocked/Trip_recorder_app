import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/l10n/localization_config.dart';
import 'package:animations_in_flutter/services/language_service.dart';
import 'package:animations_in_flutter/services/theme_service.dart';
import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:animations_in_flutter/views/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageService>().locale;
    final themeMode = context.watch<ThemeService>().themeMode;
    return MaterialApp(
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
      home: const HomePage(),
    );
  }
}
