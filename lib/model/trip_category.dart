enum TripCategory {
  beach,
  adventure,
  city,
  nature,
  cultural,
  other;

  String get label {
    switch (this) {
      case TripCategory.beach:
        return 'Beach';
      case TripCategory.adventure:
        return 'Adventure';
      case TripCategory.city:
        return 'City';
      case TripCategory.nature:
        return 'Nature';
      case TripCategory.cultural:
        return 'Cultural';
      case TripCategory.other:
        return 'Other';
    }
  }

  static TripCategory fromString(String value) {
    return TripCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => TripCategory.other,
    );
  }
}
