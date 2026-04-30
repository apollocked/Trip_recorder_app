import 'package:flutter/material.dart';
import 'package:animations_in_flutter/l10n/l10n.dart'; // Change to your package name

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }
}
