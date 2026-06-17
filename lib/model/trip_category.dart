import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

enum TripCategory {
  beach,
  adventure,
  city,
  nature,
  cultural,
  other;

  String label(AppLocalizations l10n) => switch (this) {
    TripCategory.beach => l10n.tripCatBeach,
    TripCategory.adventure => l10n.tripCatAdventure,
    TripCategory.city => l10n.tripCatCity,
    TripCategory.nature => l10n.tripCatNature,
    TripCategory.cultural => l10n.tripCatCultural,
    TripCategory.other => l10n.tripCatOther,
  };

  static TripCategory fromString(String value) {
    return TripCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => TripCategory.other,
    );
  }
}
