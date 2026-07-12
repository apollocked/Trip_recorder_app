import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';

class LanguageService extends ChangeNotifier {
  static const String localeKey = 'selected_locale';
  Locale _locale = const Locale('en');
  SharedPreferences? _prefs;

  LanguageService({String? savedLanguageCode, SharedPreferences? prefs}) {
    _prefs = prefs;
    if (savedLanguageCode != null) {
      for (final supportedLocale in L10n.all) {
        if (supportedLocale.languageCode == savedLanguageCode) {
          _locale = supportedLocale;
          return;
        }
      }
    }
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(localeKey, locale.languageCode);
  }
}
