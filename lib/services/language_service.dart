import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';

class LanguageService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  static Locale readSavedLocale(SharedPreferences prefs) {
    final savedLanguageCode = prefs.getString(_localeKey);
    if (savedLanguageCode == null) return const Locale('en');
    for (final supportedLocale in L10n.all) {
      if (supportedLocale.languageCode == savedLanguageCode) {
        return supportedLocale;
      }
    }
    return const Locale('en');
  }

  Locale _locale;

  LanguageService({Locale? initialLocale})
      : _locale = initialLocale ?? const Locale('en');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;
    if (_locale == locale) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    _locale = locale;
    notifyListeners();
  }
}
