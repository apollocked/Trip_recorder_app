class AppConstants {
  static const String dbName = 'animations_in_flutter.db';
  static const int dbVersion = 10;
  static const String tripsTable = 'trips';
  static const String expensesTable = 'expenses';
  static const String checklistTable = 'checklist_items';
  static const String journalTable = 'journal_entries';
  static const String customCategoriesTable = 'custom_categories';
  static const String tripTemplatesTable = 'trip_templates';
  static const String tripImagesDir = 'trip_images';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefDataMigrated = 'data_migrated_v2';

  static const int freeMaxTrips = 5;
  static const int freeMaxPhotosPerTrip = 3;
  static const int freeMaxCustomCategories = 0;
}
