import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      _KurdishMaterialFallbackDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      _KurdishCupertinoFallbackDelegate(),
      GlobalCupertinoLocalizations.delegate,
    ];

Locale appLocaleResolutionCallback(
  Locale? locale,
  Iterable<Locale> supportedLocales,
) {
  if (locale == null) return const Locale('en');

  for (final supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == locale.languageCode) {
      return supportedLocale;
    }
  }
  return const Locale('en');
}

TextDirection appTextDirectionForLocale(Locale locale) {
  // Keep the app layout direction stable for both Arabic and Kurdish.
  if (locale.languageCode == 'ar' || locale.languageCode == 'ku') {
    return TextDirection.rtl;
  }
  return TextDirection.ltr;
}

class _KurdishMaterialFallbackDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KurdishMaterialFallbackDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const DefaultMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(_KurdishMaterialFallbackDelegate old) => false;
}

class _KurdishCupertinoFallbackDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KurdishCupertinoFallbackDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      const DefaultCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(_KurdishCupertinoFallbackDelegate old) => false;
}
