import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
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
    Locale('ar'),
    Locale('bn'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('nl'),
    Locale('no'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sv'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ringo Ringtones'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @searchTab.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Ringo Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all ringtones & features'**
  String get premiumSubtitle;

  /// No description provided for @appearanceHeader.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceHeader;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Color'**
  String get dynamicColor;

  /// No description provided for @toolsHeader.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsHeader;

  /// No description provided for @ringtoneEditor.
  ///
  /// In en, this message translates to:
  /// **'Ringtone Editor'**
  String get ringtoneEditor;

  /// No description provided for @generalHeader.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalHeader;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @legalHeader.
  ///
  /// In en, this message translates to:
  /// **'Legal & Support'**
  String get legalHeader;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search ringtones...'**
  String get searchHint;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @ringtonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ringtones'**
  String get ringtonesTitle;

  /// No description provided for @songsTitle.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songsTitle;

  /// No description provided for @noSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs found.'**
  String get noSongs;

  /// No description provided for @latestTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestTitle;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @noLatestRingtones.
  ///
  /// In en, this message translates to:
  /// **'No latest ringtones found.'**
  String get noLatestRingtones;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories found.'**
  String get noCategories;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search'**
  String get typeToSearch;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @roleDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get roleDeveloper;

  /// No description provided for @roleAppOwner.
  ///
  /// In en, this message translates to:
  /// **'App Owner'**
  String get roleAppOwner;

  /// No description provided for @trendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingTitle;

  /// No description provided for @noTrending.
  ///
  /// In en, this message translates to:
  /// **'No trending ringtones found.'**
  String get noTrending;

  /// No description provided for @detailSetRingtone.
  ///
  /// In en, this message translates to:
  /// **'Set Ringtone'**
  String get detailSetRingtone;

  /// No description provided for @detailDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get detailDownload;

  /// No description provided for @detailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailEdit;

  /// No description provided for @detailSetAs.
  ///
  /// In en, this message translates to:
  /// **'Set as'**
  String get detailSetAs;

  /// No description provided for @detailSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully set as'**
  String get detailSetSuccess;

  /// No description provided for @detailSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set ringtone.'**
  String get detailSetFailed;

  /// No description provided for @dialogPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get dialogPremiumTitle;

  /// No description provided for @dialogPremiumContent.
  ///
  /// In en, this message translates to:
  /// **'Downloading is a Premium feature. Upgrade to unlock!'**
  String get dialogPremiumContent;

  /// No description provided for @dialogEditPremiumContent.
  ///
  /// In en, this message translates to:
  /// **'Editing is a Premium feature. Upgrade to unlock!'**
  String get dialogEditPremiumContent;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get btnUpgrade;

  /// No description provided for @msgDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading to Music...'**
  String get msgDownloading;

  /// No description provided for @msgDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get msgDownloadFailed;

  /// No description provided for @msgSavedToMusic.
  ///
  /// In en, this message translates to:
  /// **'Saved to Music'**
  String get msgSavedToMusic;

  /// No description provided for @errorAudio.
  ///
  /// In en, this message translates to:
  /// **'Error loading audio'**
  String get errorAudio;

  /// No description provided for @permissionContact.
  ///
  /// In en, this message translates to:
  /// **'Permission denied to pick contact'**
  String get permissionContact;

  /// No description provided for @setAsRingtone.
  ///
  /// In en, this message translates to:
  /// **'Set as Ringtone'**
  String get setAsRingtone;

  /// No description provided for @setAsNotification.
  ///
  /// In en, this message translates to:
  /// **'Set as Notification'**
  String get setAsNotification;

  /// No description provided for @setAsAlarm.
  ///
  /// In en, this message translates to:
  /// **'Set as Alarm'**
  String get setAsAlarm;

  /// No description provided for @setForContact.
  ///
  /// In en, this message translates to:
  /// **'Set for Contact'**
  String get setForContact;

  /// No description provided for @editorTitle.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get editorTitle;

  /// No description provided for @editorSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get editorSet;

  /// No description provided for @editorExport.
  ///
  /// In en, this message translates to:
  /// **'EXPORT'**
  String get editorExport;

  /// No description provided for @editorImport.
  ///
  /// In en, this message translates to:
  /// **'IMPORT TRACK'**
  String get editorImport;

  /// No description provided for @editorFadeIn.
  ///
  /// In en, this message translates to:
  /// **'Fade In'**
  String get editorFadeIn;

  /// No description provided for @editorFadeOut.
  ///
  /// In en, this message translates to:
  /// **'Fade Out'**
  String get editorFadeOut;

  /// No description provided for @editorSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get editorSpeed;

  /// No description provided for @msgExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully'**
  String get msgExportSuccess;

  /// No description provided for @msgExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get msgExportFailed;

  /// No description provided for @premiumUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get premiumUpgradeTitle;

  /// No description provided for @premiumUnlockDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock exclusive ringtones and features!'**
  String get premiumUnlockDesc;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @planLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get planLifetime;

  /// No description provided for @labelBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get labelBestValue;

  /// No description provided for @linkRestorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get linkRestorePurchase;

  /// No description provided for @btnSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get btnSubscribe;

  /// No description provided for @msgPremiumWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ringo Premium!'**
  String get msgPremiumWelcome;

  /// No description provided for @premiumAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Ringo Premium'**
  String get premiumAppBarTitle;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get periodYear;

  /// No description provided for @periodOneTime.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get periodOneTime;

  /// No description provided for @requestRingtone.
  ///
  /// In en, this message translates to:
  /// **'Request Ringtone'**
  String get requestRingtone;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free up space'**
  String get clearCacheSubtitle;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'he',
    'hi',
    'hu',
    'id',
    'it',
    'ja',
    'ko',
    'ms',
    'nl',
    'no',
    'pl',
    'pt',
    'ro',
    'ru',
    'sv',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'nl':
      return AppLocalizationsNl();
    case 'no':
      return AppLocalizationsNo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
