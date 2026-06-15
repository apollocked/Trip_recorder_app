// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get trip => 'Trip';

  @override
  String get recorder => 'Recorder';

  @override
  String get tripsList => 'My Trips';

  @override
  String get newjourney => 'New Journey';

  @override
  String get aboutjourney => 'About this journey';

  @override
  String get night => 'Night';

  @override
  String get noTripsFound => 'No Trips Found';

  @override
  String get emptylistDescription =>
      'Time to start planning your next adventure! \nPull down to check again.';

  @override
  String get pullToRefresh => 'Pull down to Refresh the tips';

  @override
  String get addtitle => 'Add New Journey';

  @override
  String get coverphoto => 'Cover Photo';

  @override
  String get photoreq => 'A photo is required';

  @override
  String get photoErrorReq => 'Please select a trip image';

  @override
  String get appTitle => 'Trip \nRecorder';

  @override
  String get editJourney => 'Edit Journey';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get destination => 'Destination';

  @override
  String get budget => 'Budget';

  @override
  String get nights => 'Nights';

  @override
  String get departureDate => 'Departure Date';

  @override
  String get tripDescription => 'About this trip (Optional)';

  @override
  String get createJourney => 'Create Journey';

  @override
  String get updateJourney => 'Update Journey';

  @override
  String get destinationRequired => 'Destination name is required';

  @override
  String get required => 'Required';

  @override
  String get noDescriptionAdded => 'No description added for this trip yet.';

  @override
  String get shareJourney => 'Share your journey!';

  @override
  String get permissionDescription =>
      'We need access to your camera and gallery so you can upload beautiful photos of your trips.';

  @override
  String get notNow => 'Not Now';

  @override
  String get allowAccess => 'Allow Access';

  @override
  String get selectPhotoSource => 'Select Photo Source';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get nightsLabel => 'nights';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get onboardingTitle1 => 'Capture the Moment';

  @override
  String get onboardingDesc1 =>
      'Log your favorite travel memories, dynamic routes, and beautiful moments smoothly.';

  @override
  String get onboardingTitle2 => 'Fluid Interactions';

  @override
  String get onboardingDesc2 =>
      'Explore high-fidelity implicit animations, custom transitions, and interactive UI micro-interactions.';

  @override
  String get onboardingTitle3 => 'Your Logs, Offline First';

  @override
  String get onboardingDesc3 =>
      'All your travel notebooks and photos are stored safely on your device with local persistence.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get searchTrips => 'Search trips...';

  @override
  String get rateTrip => 'Rate this trip';

  @override
  String get tripCategory => 'Category';

  @override
  String get tapToAddPhotos => 'Tap to add photos';

  @override
  String get addMorePhotos => 'Add more photos';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalTrips => 'Total Trips';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get totalNights => 'Total Nights';

  @override
  String get avgRating => 'Avg Rating';

  @override
  String get favorites => 'Favorites';

  @override
  String get topCategory => 'Top Category';

  @override
  String get mostVisited => 'Most Visited';

  @override
  String get sortLabel => 'Sort';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get priceAsc => 'Price \$';

  @override
  String get priceDesc => 'Price \$\$';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get az => 'A-Z';

  @override
  String get all => 'All';

  @override
  String get settings => 'Settings';

  @override
  String get exportTrip => 'Export';

  @override
  String get copiedToClipboard => 'Trip exported to clipboard!';

  @override
  String get budgetBreakdown => 'Budget Breakdown';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get expenseTitle => 'Expense Title';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseCategory => 'Category';

  @override
  String get addExpenseHint => 'e.g. Hotel booking';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get categoryHotel => 'Hotel';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryActivities => 'Activities';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryOther => 'Other';

  @override
  String get packingList => 'Packing List';

  @override
  String get addItem => 'Add Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get addItemHint => 'e.g. Passport';

  @override
  String itemsChecked(int checked, int total) {
    return '$checked/$total items';
  }

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get checklist => 'Checklist';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyIntro =>
      'Trip Recorder values your privacy. This policy explains how we handle your data.';

  @override
  String get privacyDataTitle => 'Data We Collect';

  @override
  String get privacyDataBody =>
      'Trip Recorder stores all your data locally on your device. We do not collect, transmit, or sell any personal information. Trip details, photos, and preferences remain solely on your device.';

  @override
  String get privacyUseTitle => 'How We Use Data';

  @override
  String get privacyUseBody =>
      'Your trip data is used exclusively to display your travel logs within the app. No data is sent to external servers or shared with third parties.';

  @override
  String get privacyStorageTitle => 'Data Storage';

  @override
  String get privacyStorageBody =>
      'All information is stored locally using on-device databases and file storage. You can delete any or all of your data at any time by removing individual trips or clearing app data.';

  @override
  String get privacyThirdPartyTitle => 'Third-Party Services';

  @override
  String get privacyThirdPartyBody =>
      'This app uses no third-party analytics, advertising, or tracking services. The image picker and share sheet use system-provided APIs that do not transmit your data externally.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String get privacyContactBody =>
      'If you have questions about this privacy policy, please contact the developer through the app store listing.';

  @override
  String get privacyLastUpdated => 'Last updated: June 2026';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get journal => 'Journal';

  @override
  String get addJournalEntry => 'Add Entry';

  @override
  String get journalTitle => 'Entry Title';

  @override
  String get journalTitleHint => 'e.g. First day in Paris';

  @override
  String get journalText => 'Notes';

  @override
  String get journalTextHint => 'What happened today?';

  @override
  String get noJournalEntries => 'No journal entries yet';

  @override
  String get tripsByCategory => 'Trips by Category';

  @override
  String get spendingByDestination => 'Spending by Destination';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get reminder => 'Reminder';

  @override
  String get notSet => 'Not set';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String confirmDeleteTitle(String item) {
    return 'Delete $item?';
  }

  @override
  String get confirmDeleteMessage => 'This action cannot be undone.';

  @override
  String errorSavingTrip(String error) {
    return 'Error saving trip: $error';
  }

  @override
  String get tripNotFound => 'Trip not found';

  @override
  String get totalLabel => 'total';

  @override
  String get notRated => '--';

  @override
  String exportHeader(String title) {
    return '=== $title ===';
  }

  @override
  String exportRating(String rating) {
    return 'Rating: $rating / 5';
  }

  @override
  String get notificationChannelName => 'Trip Reminders';

  @override
  String get notificationTitle => 'Upcoming Trip';

  @override
  String notificationBody(String tripTitle) {
    return '$tripTitle is coming up!';
  }

  @override
  String get notificationPermissionTitle => 'Stay Updated';

  @override
  String get notificationPermissionDescription =>
      'We\'d like to send you reminders about your upcoming trips so you never miss a journey.';

  @override
  String get goToSettings => 'Open Settings';

  @override
  String get editFormSemantics => 'Edit Journey form';

  @override
  String get addFormSemantics => 'Add New Journey form';

  @override
  String get appBannerSemantics => 'Banner of the app';

  @override
  String get appTitleSemantics => 'Title of the app';

  @override
  String get tripListTitle => 'My Trips';

  @override
  String tripCardSemantics(String title) {
    return 'Trip item of $title, tap for details, swipe left to delete';
  }

  @override
  String get shimmerSemantics => 'Loading for trip details';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get coverPhotoSemantics => 'Cover photo of the trip';

  @override
  String morePhotosCount(int count) {
    return '+$count';
  }

  @override
  String imageCoverSemantics(int index) {
    return 'Trip cover image $index';
  }

  @override
  String get home => 'Home';

  @override
  String get todo => 'To-Do';
}
