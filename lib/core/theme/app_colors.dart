import 'package:flutter/material.dart';
import 'package:animations_in_flutter/model/expense_category.dart';

abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────
  /// Seed used for ColorScheme.fromSeed and the bottom‑nav FAB gradient.
  static const Color brandSeed = Color(0xFF00796B);

  // ── Chart palette ─────────────────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF4FC3F7),
    Color(0xFFFF8A65),
    Color(0xFF81C784),
    Color(0xFF9575CD),
    Color(0xFFFFD54F),
    Color(0xFFA1887F),
  ];

  // ── Budget category colors ────────────────────────────────
  static Color budgetCategoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.hotel:
        return Color(0xFF42A5F5);
      case ExpenseCategory.food:
        return Color(0xFFFF9800);
      case ExpenseCategory.transport:
        return Color(0xFFAB47BC);
      case ExpenseCategory.activities:
        return Color(0xFF66BB6A);
      case ExpenseCategory.shopping:
        return Color(0xFFEC407A);
      case ExpenseCategory.other:
        return Color(0xFF9E9E9E);
    }
  }

  // ── Rating & favorites ────────────────────────────────────
  static const Color ratingActive = Color(0xFFFFC107);
  static const Color favoriteActive = Color(0xFFE53935);
  static const Color favoriteActive20 = Color(0x33E53935);
  static const Color favoriteInactive = Color(0xFFBDBDBD);
  static const Color favoriteIconColor = Color(0xFFE53935);

  // ── Stat card icon accents ────────────────────────────────
  static const Color statNights = Color(0xFF3F51B5);
  static const Color statRating = Color(0xFFFFC107);
  static const Color statFavorites = Color(0xFFE53935);
  static const Color statSpending = Color(0xFF4CAF50);

  // ── Placeholder / empty states ────────────────────────────
  static const Color placeholderBg = Color(0xFFE0E0E0);
  static const Color placeholderIcon = Color(0xFF9E9E9E);

  // ── Shimmer ───────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ── Overlay / scrim ──────────────────────────────────────
  static const Color imageOverlay = Color(0x8A000000);

  // ── White / near-white helpers ────────────────────────────
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
}

