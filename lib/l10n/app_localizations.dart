import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('zh')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'SanctuaryFlow'**
  String get appTitle;

  /// The application subtitle
  ///
  /// In en, this message translates to:
  /// **'Spiritual Growth'**
  String get appSubtitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @bibleReading.
  ///
  /// In en, this message translates to:
  /// **'Bible Reading'**
  String get bibleReading;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dailyVerse.
  ///
  /// In en, this message translates to:
  /// **'Daily Verse'**
  String get dailyVerse;

  /// No description provided for @readingStreak.
  ///
  /// In en, this message translates to:
  /// **'Reading Streak'**
  String get readingStreak;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @readingPlans.
  ///
  /// In en, this message translates to:
  /// **'Reading Plans'**
  String get readingPlans;

  /// No description provided for @verseArchive.
  ///
  /// In en, this message translates to:
  /// **'Verse Archive'**
  String get verseArchive;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettings;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @addReflection.
  ///
  /// In en, this message translates to:
  /// **'Add Reflection'**
  String get addReflection;

  /// No description provided for @saveReflection.
  ///
  /// In en, this message translates to:
  /// **'Save Reflection'**
  String get saveReflection;

  /// No description provided for @yourReflection.
  ///
  /// In en, this message translates to:
  /// **'Your reflection...'**
  String get yourReflection;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @reflectionHint.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts and reflections...'**
  String get reflectionHint;

  /// No description provided for @noReflection.
  ///
  /// In en, this message translates to:
  /// **'No reflection yet'**
  String get noReflection;

  /// No description provided for @bibleTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Reading Tracker'**
  String get bibleTrackerTitle;

  /// No description provided for @addReading.
  ///
  /// In en, this message translates to:
  /// **'Add Reading'**
  String get addReading;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @verses.
  ///
  /// In en, this message translates to:
  /// **'Verses'**
  String get verses;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'Reading Time'**
  String get readingTime;

  /// No description provided for @selectBook.
  ///
  /// In en, this message translates to:
  /// **'Select Book'**
  String get selectBook;

  /// No description provided for @chapterNumber.
  ///
  /// In en, this message translates to:
  /// **'Chapter Number'**
  String get chapterNumber;

  /// No description provided for @verseRange.
  ///
  /// In en, this message translates to:
  /// **'Verse Range (e.g., 1-10)'**
  String get verseRange;

  /// No description provided for @readingNotes.
  ///
  /// In en, this message translates to:
  /// **'Reading Notes'**
  String get readingNotes;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @prayerScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Schedule'**
  String get prayerScheduleTitle;

  /// No description provided for @addPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'Add Prayer Time'**
  String get addPrayerTime;

  /// No description provided for @prayerType.
  ///
  /// In en, this message translates to:
  /// **'Prayer Type'**
  String get prayerType;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @days_plural.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days_plural;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @messageTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Message Tracker'**
  String get messageTrackerTitle;

  /// No description provided for @addMessage.
  ///
  /// In en, this message translates to:
  /// **'Add Message'**
  String get addMessage;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @church.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get church;

  /// No description provided for @podcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get podcast;

  /// No description provided for @youtube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youtube;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @bookTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Tracker'**
  String get bookTrackerTitle;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get addBook;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @currentPage.
  ///
  /// In en, this message translates to:
  /// **'Current Page'**
  String get currentPage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Goals'**
  String get goalsTitle;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Title'**
  String get goalTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Target Value'**
  String get targetValue;

  /// No description provided for @currentValue.
  ///
  /// In en, this message translates to:
  /// **'Current Value'**
  String get currentValue;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @prayerCategory.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayerCategory;

  /// No description provided for @bibleStudy.
  ///
  /// In en, this message translates to:
  /// **'Bible Study'**
  String get bibleStudy;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @worship.
  ///
  /// In en, this message translates to:
  /// **'Worship'**
  String get worship;

  /// No description provided for @fellowship.
  ///
  /// In en, this message translates to:
  /// **'Fellowship'**
  String get fellowship;

  /// No description provided for @evangelism.
  ///
  /// In en, this message translates to:
  /// **'Evangelism'**
  String get evangelism;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @readingPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Plans'**
  String get readingPlansTitle;

  /// No description provided for @startPlan.
  ///
  /// In en, this message translates to:
  /// **'Start Plan'**
  String get startPlan;

  /// No description provided for @continuePlan.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuePlan;

  /// No description provided for @completedPlan.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedPlan;

  /// No description provided for @verseArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Verse Archive'**
  String get verseArchiveTitle;

  /// No description provided for @allVerses.
  ///
  /// In en, this message translates to:
  /// **'All Verses'**
  String get allVerses;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @searchVerses.
  ///
  /// In en, this message translates to:
  /// **'Search verses...'**
  String get searchVerses;

  /// No description provided for @offlineModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineModeTitle;

  /// No description provided for @downloadVerses.
  ///
  /// In en, this message translates to:
  /// **'Download Verses'**
  String get downloadVerses;

  /// No description provided for @downloadForOffline.
  ///
  /// In en, this message translates to:
  /// **'Download for Offline'**
  String get downloadForOffline;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @autoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync when online'**
  String get autoSync;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get lastSync;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// No description provided for @offlineVerses.
  ///
  /// In en, this message translates to:
  /// **'Offline verses'**
  String get offlineVerses;

  /// No description provided for @workingOffline.
  ///
  /// In en, this message translates to:
  /// **'Working Offline'**
  String get workingOffline;

  /// No description provided for @allSynced.
  ///
  /// In en, this message translates to:
  /// **'All Synced'**
  String get allSynced;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your spiritual growth journey'**
  String get welcomeMessage;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @startYourDay.
  ///
  /// In en, this message translates to:
  /// **'Start your day with prayer'**
  String get startYourDay;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackYourProgress;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteMessage;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Message showing the current streak
  ///
  /// In en, this message translates to:
  /// **'{count} day streak!'**
  String streakMessage(int count);

  /// Number of verses downloaded
  ///
  /// In en, this message translates to:
  /// **'{count} verses downloaded'**
  String versesDownloaded(int count);

  /// Goal progress indicator
  ///
  /// In en, this message translates to:
  /// **'{current} of {target}'**
  String goalProgress(int current, int target);
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
      <String>['en', 'es', 'fr', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
