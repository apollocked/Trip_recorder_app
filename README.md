# Trip Recorder

<p align="center">
  <img src="assets/icons/app_icon.png" alt="Trip Recorder" width="120" height="120">
</p>

<p align="center">
  <strong>A feature-rich Flutter travel journal</strong><br>
  Track past trips, plan future adventures — all offline and private.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.11+-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey" alt="Platform">
</p>

---

## Features

| Feature                 | Description                                                                                                                 |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Trip Management**     | Add, edit, and delete trips with title, description, dates, rating, category, currency, and multiple images                 |
| **Past & Future Trips** | Record past memories with photos and ratings, or plan future trips with countdown reminders                                 |
| **Budget Tracking**     | Per-trip expense tracking with category breakdown, spending bars, and total summaries                                       |
| **Journal Entries**     | Write journal entries with images for each trip                                                                             |
| **Packing Checklist**   | Organize items by category (documents, clothing, electronics, toiletries) with progress tracking                            |
| **Currency Converter**  | Built-in converter for planning expenses                                                                                    |
| **Statistics**          | Pie chart by category, spending bar chart, total nights, average rating, top destinations                                   |
| **Favorites**           | Like trips and view them in a dedicated favorites page                                                                      |
| **Memories**            | Timeline view grouped by month with expandable trip cards                                                                   |
| **Animations**          | Gradient FAB with spring rotation, shimmer loading, hero transitions, staggered list animations, animated route transitions |
| **Image Handling**      | Camera and gallery image picker with bundled fallback assets                                                                |
| **Multi-language**      | English, Arabic, Kurdish with full RTL support                                                                              |
| **Theming**             | Material 3 light and dark mode with centralized color system                                                                |
| **Onboarding**          | First-launch walkthrough with feature highlights                                                                            |
| **Local Persistence**   | SQLite via sqflite with shared preferences                                                                                  |
| **Notifications**       | Local notification reminders for upcoming trips                                                                             |

## Screenshots

<p align="center">
  <em>Screenshots coming soon</em>
</p>

## Architecture

The app follows a feature-first structure with clear separation of concerns.

```
lib/
├── core/
│   ├── constants.dart           # App-wide constants
│   ├── l10n/                    # ARB files + generated localizations
│   ├── routes/                  # GoRouter configuration
│   ├── route_transition.dart    # Custom page transitions
│   └── theme/                   # AppColors + AppTheme
├── data/
│   ├── database/                # SQLite database setup
│   └── repositories/            # Data access layer
├── model/                       # Data models
│   ├── trip.dart
│   ├── expense.dart
│   ├── journal_entry.dart
│   ├── checklist_item.dart
│   ├── trip_category.dart
│   ├── expense_category.dart
│   └── currency.dart
├── providers/                   # State management (ChangeNotifier)
│   ├── trip_provider.dart
│   └── mixins/                  # Feature-specific logic
├── services/                    # App services
│   ├── currency_converter_service.dart
│   ├── data_migration_service.dart
│   ├── language_service.dart
│   ├── notification_service.dart
│   └── theme_service.dart
└── views/
    ├── pages/                   # Screen-level widgets
    │   ├── add_trip_page.dart
    │   ├── budget_page.dart
    │   ├── details_page.dart
    │   ├── favorites_page.dart
    │   ├── home_page.dart
    │   ├── journal_page.dart
    │   ├── main_shell.dart
    │   ├── memory_page.dart
    │   ├── next_trips_page.dart
    │   ├── on_boarding_page.dart
    │   ├── packing_list_page.dart
    │   ├── settings_page.dart
    │   ├── statistics_page.dart
    │   └── trip_type_selector.dart
    ├── shimmer/                 # Shimmer loading widgets
    │   ├── shimmer_card_widget.dart
    │   ├── shimmer_budget_page.dart
    │   ├── shimmer_journal_page.dart
    │   ├── shimmer_packing_list_page.dart
    │   ├── shimmer_favorites_page.dart
    │   ├── shimmer_next_trips_page.dart
    │   ├── shimmer_statistics_page.dart
    │   ├── shimmer_memory_page.dart
    │   └── shimmer_details_page.dart
    └── widgets/                 # Reusable components
        ├── add_trip/
        ├── budget/
        ├── details/
        ├── home/
        ├── journal/
        ├── memory/
        ├── next_trips/
        ├── on_boarding/
        ├── settings/
        └── statistics/
```

### State Flow

```
User Action → Provider (ChangeNotifier) → Repository → SQLite
                  ↓
            Widget rebuild via Consumer/context.watch
```

## Tech Stack

| Concern          | Choice                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| State Management | [Provider](https://pub.dev/packages/provider) (ChangeNotifier)                      |
| Routing          | [go_router](https://pub.dev/packages/go_router)                                     |
| Database         | [sqflite](https://pub.dev/packages/sqflite)                                         |
| Charts           | [fl_chart](https://pub.dev/packages/fl_chart)                                       |
| Localization     | Flutter ARB + gen-l10n                                                              |
| Preferences      | [shared_preferences](https://pub.dev/packages/shared_preferences)                   |
| Images           | [image_picker](https://pub.dev/packages/image_picker)                               |
| Sharing          | [share_plus](https://pub.dev/packages/share_plus)                                   |
| Shimmer          | [shimmer](https://pub.dev/packages/shimmer)                                         |
| Notifications    | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| Permissions      | [permission_handler](https://pub.dev/packages/permission_handler)                   |
| HTTP             | [http](https://pub.dev/packages/http)                                               |
| UUID             | [uuid](https://pub.dev/packages/uuid)                                               |
| Icons            | [cupertino_icons](https://pub.dev/packages/cupertino_icons)                         |

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.11+
- Dart 3.11+

### Installation

```bash
# Clone the repository
git clone https://github.com/apollocked/Trip_recorder_app

# Navigate to the project
cd trip_recorder

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run the app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## Localization

The app supports three languages:

- **English** (en)
- **Arabic** (ar) — full RTL support
- **Kurdish** (ku) — full RTL support

To add a new locale:

1. Add an ARB file in `lib/core/l10n/`
2. Register the locale in `lib/core/l10n/l10n.dart`
3. Run `flutter gen-l10n`

## Project Structure Conventions

- **Pages** handle full-screen layouts and state
- **Widgets** are reusable components organized by feature
- **Shimmer widgets** are centralized in `views/shimmer/` for consistent loading states
- **Providers** use mixins to keep feature-specific logic separated
- **Services** wrap platform APIs and third-party dependencies
- **Models** are plain Dart classes with `copyWith`, `toMap`, and `fromMap`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Icons by [Material Design](https://material.io/icons)
- Font: xoshnus (Kurdish)
- Built with [Flutter](https://flutter.dev)

Created by [Apollocked](https://github.com/apollocked) with ❤️- 2026
