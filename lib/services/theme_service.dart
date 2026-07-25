import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String themeModeKey = 'selected_theme_mode';
  static const String premiumThemeKey = 'selected_premium_theme';
  ThemeMode _themeMode = ThemeMode.system;
  String _premiumTheme = 'default';
  SharedPreferences? _prefs;

  ThemeService({String? savedThemeMode, SharedPreferences? prefs}) {
    _prefs = prefs;
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  ThemeMode get themeMode => _themeMode;
  String get premiumTheme => _premiumTheme;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, mode.name);
  }

  Future<void> setPremiumTheme(String themeName) async {
    _premiumTheme = themeName;
    notifyListeners();
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(premiumThemeKey, themeName);
  }

  void loadPremiumTheme() {
    _premiumTheme = _prefs?.getString(premiumThemeKey) ?? 'default';
  }

  static bool isPremiumTheme(String name) => name != 'default';

  static const Map<String, String> themeNames = {
    'default': 'Default',
    'midnight': 'Midnight',
    'sunset': 'Sunset',
    'forest': 'Forest',
  };
}
