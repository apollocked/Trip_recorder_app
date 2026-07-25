import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.brandSeed);
  static ThemeData dark() => _build(Brightness.dark, AppColors.brandSeed);

  static ThemeData midnightLight() => _build(Brightness.light, const Color(0xFF1A237E));
  static ThemeData midnightDark() => _build(Brightness.dark, const Color(0xFF1A237E));

  static ThemeData sunsetLight() => _build(Brightness.light, const Color(0xFFE65100));
  static ThemeData sunsetDark() => _build(Brightness.dark, const Color(0xFFE65100));

  static ThemeData forestLight() => _build(Brightness.light, const Color(0xFF1B5E20));
  static ThemeData forestDark() => _build(Brightness.dark, const Color(0xFF1B5E20));

  static ThemeData _build(Brightness brightness, Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: "xoshnus",
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: seedColor,
      ),
    );
  }
}
