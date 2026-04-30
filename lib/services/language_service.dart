import 'package:flutter/material.dart';
import 'package:animations_in_flutter/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  Locale _locale = const Locale('en');

  LanguageService() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_localeKey);
    if (savedLanguageCode == null) return;

    for (final supportedLocale in L10n.all) {
      if (supportedLocale.languageCode == savedLanguageCode) {
        _locale = supportedLocale;
        notifyListeners();
        return;
      }
    }
  }
}
