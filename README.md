# Trip Recorder App

A feature-rich Flutter travel journal with smooth animations, multi-language support, and offline-first local storage.

## Features

- **Trip management** — Add, edit, delete trips with title, description, dates, rating, category, currency, images
- **Budget tracking** — Per-trip expenses with category breakdown and spending charts
- **Journal entries** — Write and manage journal entries for each trip
- **Packing checklist** — Per-trip checklist items
- **Currency converter** — Built-in converter
- **Statistics** — Pie chart by category, spending bar chart, total nights, average rating, top destinations
- **Favorites** — Like trips and view them in a dedicated favorites page
- **Memories** — Timeline view grouped by month with expandable cards
- **Animations** — Gradient FAB with spring rotation, animated heart button, shimmer loading, hero transitions, staggered list animations
- **Image handling** — Camera/gallery image picker with bundled fallback assets
- **Multi-language** — English, Arabic, Kurdish with full RTL support
- **Theming** — Material 3 light/dark mode with centralized color system
- **Onboarding** — First-launch walkthrough
- **Local persistence** — SQLite via sqflite + shared preferences
- **Notifications** — Local notification reminders

## Architecture

```
lib/
├── core/
│   ├── constants.dart
│   ├── l10n/          # ARB files + generated localizations
│   ├── routes/        # GoRouter configuration
│   └── theme/         # AppColors + AppTheme
├── data/
│   ├── database/      # SQLite database setup
│   └── repositories/  # Data access layer (trip, expense, journal, checklist)
├── model/             # Data models (Trip, Expense, JournalEntry, etc.)
├── providers/         # ChangeNotifier providers (state management)
│   └── mixins/        # Feature-specific logic (statistics, checklist, etc.)
├── services/          # App services (currency, notifications, theme, language)
└── views/
    ├── pages/         # Screen-level widgets (16 pages)
    └── widgets/       # Reusable components, organized by feature
        ├── add_trip/
        ├── budget/
        ├── details/
        ├── home/
        ├── journal/
        ├── on_boarding/
        ├── settings/
        └── statistics/
```

## Getting Started

1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Clone this repository
3. `flutter pub get`
4. `flutter run`

## Tech Stack

| Concern | Choice |
|---------|--------|
| State management | Provider (ChangeNotifier) |
| Routing | go_router |
| Database | sqflite |
| Charts | fl_chart |
| Localization | Flutter ARB + gen-l10n |
| Storage | SharedPreferences |
| Images | image_picker |
| Sharing | share_plus |
| Shimmer | shimmer |
| Notifications | flutter_local_notifications |
