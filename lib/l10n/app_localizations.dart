import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku'),
  ];

  /// No description provided for @trip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// No description provided for @recorder.
  ///
  /// In en, this message translates to:
  /// **'Recorder'**
  String get recorder;

  /// No description provided for @tripsList.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get tripsList;

  /// No description provided for @newjourney.
  ///
  /// In en, this message translates to:
  /// **'New Journey'**
  String get newjourney;

  /// No description provided for @aboutjourney.
  ///
  /// In en, this message translates to:
  /// **'About this journey'**
  String get aboutjourney;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @noTripsFound.
  ///
  /// In en, this message translates to:
  /// **'No Trips Found'**
  String get noTripsFound;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingSearch;

  /// No description provided for @emptylistDescription.
  ///
  /// In en, this message translates to:
  /// **'Time to start planning your next adventure!\nPull down to check again.'**
  String get emptylistDescription;

  /// No description provided for @emptyTripTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get emptyTripTitle;

  /// No description provided for @emptyTripAction.
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get emptyTripAction;

  /// No description provided for @emptyBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet. Start tracking your spending.'**
  String get emptyBudgetSubtitle;

  /// No description provided for @emptyStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get emptyStatsTitle;

  /// No description provided for @emptyStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your statistics will appear once you add trips.'**
  String get emptyStatsSubtitle;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to Refresh the tips'**
  String get pullToRefresh;

  /// No description provided for @addtitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Journey'**
  String get addtitle;

  /// No description provided for @coverphoto.
  ///
  /// In en, this message translates to:
  /// **'Cover Photo'**
  String get coverphoto;

  /// No description provided for @photoreq.
  ///
  /// In en, this message translates to:
  /// **'A photo is required'**
  String get photoreq;

  /// No description provided for @photoErrorReq.
  ///
  /// In en, this message translates to:
  /// **'Please select a trip image'**
  String get photoErrorReq;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip \nRecorder'**
  String get appTitle;

  /// No description provided for @editJourney.
  ///
  /// In en, this message translates to:
  /// **'Edit Journey'**
  String get editJourney;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @nights.
  ///
  /// In en, this message translates to:
  /// **'Nights'**
  String get nights;

  /// No description provided for @departureDate.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDate;

  /// No description provided for @tripDescription.
  ///
  /// In en, this message translates to:
  /// **'About this trip (Optional)'**
  String get tripDescription;

  /// No description provided for @createJourney.
  ///
  /// In en, this message translates to:
  /// **'Create Journey'**
  String get createJourney;

  /// No description provided for @updateJourney.
  ///
  /// In en, this message translates to:
  /// **'Update Journey'**
  String get updateJourney;

  /// No description provided for @destinationRequired.
  ///
  /// In en, this message translates to:
  /// **'Destination name is required'**
  String get destinationRequired;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @noDescriptionAdded.
  ///
  /// In en, this message translates to:
  /// **'No description added for this trip yet.'**
  String get noDescriptionAdded;

  /// No description provided for @shareJourney.
  ///
  /// In en, this message translates to:
  /// **'Share your journey!'**
  String get shareJourney;

  /// No description provided for @permissionDescription.
  ///
  /// In en, this message translates to:
  /// **'We need access to your camera and gallery so you can upload beautiful photos of your trips.'**
  String get permissionDescription;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @allowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get allowAccess;

  /// No description provided for @selectPhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Select Photo Source'**
  String get selectPhotoSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @nightsLabel.
  ///
  /// In en, this message translates to:
  /// **'nights'**
  String get nightsLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Trips'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Create trips with photos, budgets, and categories. Track every detail of your journey in one place.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTip1.
  ///
  /// In en, this message translates to:
  /// **'Tip: Tap + to create your first trip'**
  String get onboardingTip1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Stay Organized'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Manage packing checklists, track expenses by category, and keep a travel journal with photos.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTip2.
  ///
  /// In en, this message translates to:
  /// **'Tip: Swipe left on items to delete them'**
  String get onboardingTip2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Private & Offline'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'No account needed. All your data stays safely on your device. Your privacy is built in.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTip3.
  ///
  /// In en, this message translates to:
  /// **'Tip: View Statistics for travel insights'**
  String get onboardingTip3;

  /// No description provided for @fabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create a new trip'**
  String get fabTooltip;

  /// No description provided for @firstLaunchHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to start planning your first trip!'**
  String get firstLaunchHint;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @searchTrips.
  ///
  /// In en, this message translates to:
  /// **'Search trips...'**
  String get searchTrips;

  /// No description provided for @rateTrip.
  ///
  /// In en, this message translates to:
  /// **'Rate this trip'**
  String get rateTrip;

  /// No description provided for @tripCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tripCategory;

  /// No description provided for @tripCatBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get tripCatBeach;

  /// No description provided for @tripCatAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get tripCatAdventure;

  /// No description provided for @tripCatCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get tripCatCity;

  /// No description provided for @tripCatNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get tripCatNature;

  /// No description provided for @tripCatCultural.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get tripCatCultural;

  /// No description provided for @tripCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get tripCatOther;

  /// No description provided for @tapToAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photos'**
  String get tapToAddPhotos;

  /// No description provided for @addMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add more photos'**
  String get addMorePhotos;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalTrips.
  ///
  /// In en, this message translates to:
  /// **'Total Trips'**
  String get totalTrips;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @totalNights.
  ///
  /// In en, this message translates to:
  /// **'Total Nights'**
  String get totalNights;

  /// No description provided for @avgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get avgRating;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get topCategory;

  /// No description provided for @mostVisited.
  ///
  /// In en, this message translates to:
  /// **'Most Visited'**
  String get mostVisited;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @priceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price \$'**
  String get priceAsc;

  /// No description provided for @priceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price \$\$'**
  String get priceDesc;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @az.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get az;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @exportTrip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTrip;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Trip exported to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @budgetBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Budget Breakdown'**
  String get budgetBreakdown;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @expenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Title'**
  String get expenseTitle;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @addExpenseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hotel booking'**
  String get addExpenseHint;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @categoryHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get categoryHotel;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get categoryActivities;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @packingList.
  ///
  /// In en, this message translates to:
  /// **'Packing List'**
  String get packingList;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @addItemHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Passport'**
  String get addItemHint;

  /// Checked items counter
  ///
  /// In en, this message translates to:
  /// **'{checked}/{total} items'**
  String itemsChecked(int checked, int total);

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @prepCatDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get prepCatDocuments;

  /// No description provided for @prepCatClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get prepCatClothing;

  /// No description provided for @prepCatElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get prepCatElectronics;

  /// No description provided for @prepCatToiletries.
  ///
  /// In en, this message translates to:
  /// **'Toiletries'**
  String get prepCatToiletries;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetLabel;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Trip Recorder values your privacy. This policy explains how we handle your data.'**
  String get privacyIntro;

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data We Collect'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Trip Recorder stores all your data locally on your device. We do not collect, transmit, or sell any personal information. Trip details, photos, and preferences remain solely on your device.'**
  String get privacyDataBody;

  /// No description provided for @privacyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How We Use Data'**
  String get privacyUseTitle;

  /// No description provided for @privacyUseBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip data is used exclusively to display your travel logs within the app. No data is sent to external servers or shared with third parties.'**
  String get privacyUseBody;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageBody.
  ///
  /// In en, this message translates to:
  /// **'All information is stored locally using on-device databases and file storage. You can delete any or all of your data at any time by removing individual trips or clearing app data.'**
  String get privacyStorageBody;

  /// No description provided for @privacyThirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get privacyThirdPartyTitle;

  /// No description provided for @privacyThirdPartyBody.
  ///
  /// In en, this message translates to:
  /// **'This app uses no third-party analytics, advertising, or tracking services. The image picker and share sheet use system-provided APIs that do not transmit your data externally.'**
  String get privacyThirdPartyBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this privacy policy, please contact the developer through the app store listing.'**
  String get privacyContactBody;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: June 2026'**
  String get privacyLastUpdated;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @currencyConverter.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get currencyConverter;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @convertedAmount.
  ///
  /// In en, this message translates to:
  /// **'Converted Amount'**
  String get convertedAmount;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @addJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addJournalEntry;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry Title'**
  String get journalTitle;

  /// No description provided for @journalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. First day in Paris'**
  String get journalTitleHint;

  /// No description provided for @journalText.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get journalText;

  /// No description provided for @journalTextHint.
  ///
  /// In en, this message translates to:
  /// **'What happened today?'**
  String get journalTextHint;

  /// No description provided for @noJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get noJournalEntries;

  /// No description provided for @tripsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Trips by Category'**
  String get tripsByCategory;

  /// No description provided for @spendingByDestination.
  ///
  /// In en, this message translates to:
  /// **'Spending by Destination'**
  String get spendingByDestination;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {item}?'**
  String confirmDeleteTitle(String item);

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// No description provided for @errorSavingTrip.
  ///
  /// In en, this message translates to:
  /// **'Error saving trip: {error}'**
  String errorSavingTrip(String error);

  /// No description provided for @tripNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trip not found'**
  String get tripNotFound;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get totalLabel;

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get notRated;

  /// No description provided for @exportHeader.
  ///
  /// In en, this message translates to:
  /// **'=== {title} ==='**
  String exportHeader(String title);

  /// No description provided for @exportRating.
  ///
  /// In en, this message translates to:
  /// **'Rating: {rating} / 5'**
  String exportRating(String rating);

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Trip Reminders'**
  String get notificationChannelName;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trip'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'{tripTitle} is coming up!'**
  String notificationBody(String tripTitle);

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Updated'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'d like to send you reminders about your upcoming trips so you never miss a journey.'**
  String get notificationPermissionDescription;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get goToSettings;

  /// No description provided for @editFormSemantics.
  ///
  /// In en, this message translates to:
  /// **'Edit Journey form'**
  String get editFormSemantics;

  /// No description provided for @addFormSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add New Journey form'**
  String get addFormSemantics;

  /// No description provided for @appBannerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Banner of the app'**
  String get appBannerSemantics;

  /// No description provided for @appTitleSemantics.
  ///
  /// In en, this message translates to:
  /// **'Title of the app'**
  String get appTitleSemantics;

  /// No description provided for @tripListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get tripListTitle;

  /// No description provided for @tripCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'Trip item of {title}, tap for details, swipe left to delete'**
  String tripCardSemantics(String title);

  /// No description provided for @shimmerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading for trip details'**
  String get shimmerSemantics;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @coverPhotoSemantics.
  ///
  /// In en, this message translates to:
  /// **'Cover photo of the trip'**
  String get coverPhotoSemantics;

  /// No description provided for @morePhotosCount.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String morePhotosCount(int count);

  /// No description provided for @imageCoverSemantics.
  ///
  /// In en, this message translates to:
  /// **'Trip cover image {index}'**
  String imageCoverSemantics(int index);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @todo.
  ///
  /// In en, this message translates to:
  /// **'Travel Prep'**
  String get todo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
