// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Ringo Soittoäänet';

  @override
  String get homeTab => 'Koti';

  @override
  String get searchTab => 'Haku';

  @override
  String get settingsTab => 'Asetukset';

  @override
  String get premiumTitle => 'Ringo Premium';

  @override
  String get premiumSubtitle => 'Avaa kaikki';

  @override
  String get appearanceHeader => 'Ulkoasu';

  @override
  String get darkMode => 'Tumma tila';

  @override
  String get dynamicColor => 'Dynaaminen väri';

  @override
  String get toolsHeader => 'Työkalut';

  @override
  String get ringtoneEditor => 'Soittoäänen muokkain';

  @override
  String get generalHeader => 'Yleiset';

  @override
  String get language => 'Kieli';

  @override
  String get storage => 'Tallennustila';

  @override
  String get legalHeader => 'Lakitiedot';

  @override
  String get privacyPolicy => 'Tietosuojakäytäntö';

  @override
  String get aboutUs => 'Meistä';

  @override
  String get version => 'Versio';

  @override
  String get searchHint => 'Etsi soittoääniä...';

  @override
  String get favoritesTitle => 'Suosikit';

  @override
  String get noFavorites => 'Ei suosikkeja vielä';

  @override
  String get ringtonesTitle => 'Ringtones';

  @override
  String get songsTitle => 'Kappaleet';

  @override
  String get noSongs => 'Kappaleita ei löytynyt.';

  @override
  String get latestTitle => 'Uusimmat';

  @override
  String get seeMore => 'Katso lisää';

  @override
  String get noLatestRingtones => 'Ei uusimpia soittoääniä.';

  @override
  String get categoriesTitle => 'Kategoriat';

  @override
  String get noCategories => 'Kategorioita ei löytynyt.';

  @override
  String get typeToSearch => 'Kirjoita etsiäksesi';

  @override
  String get noResults => 'Ei tuloksia';

  @override
  String get roleDeveloper => 'Kehittäjä';

  @override
  String get roleAppOwner => 'Omistaja';

  @override
  String get trendingTitle => 'Trendaavat';

  @override
  String get noTrending => 'Ei trendaavia';

  @override
  String get detailSetRingtone => 'Set Ringtone';

  @override
  String get detailDownload => 'Download';

  @override
  String get detailEdit => 'Edit';

  @override
  String get detailSetAs => 'Set as';

  @override
  String get detailSetSuccess => 'Successfully set as';

  @override
  String get detailSetFailed => 'Failed to set ringtone.';

  @override
  String get dialogPremiumTitle => 'Unlock Premium';

  @override
  String get dialogPremiumContent =>
      'Downloading is a Premium feature. Upgrade to unlock!';

  @override
  String get dialogEditPremiumContent =>
      'Editing is a Premium feature. Upgrade to unlock!';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnUpgrade => 'Upgrade';

  @override
  String get msgDownloading => 'Downloading to Music...';

  @override
  String get msgDownloadFailed => 'Download failed';

  @override
  String get msgSavedToMusic => 'Saved to Music';

  @override
  String get errorAudio => 'Error loading audio';

  @override
  String get permissionContact => 'Permission denied to pick contact';

  @override
  String get setAsRingtone => 'Set as Ringtone';

  @override
  String get setAsNotification => 'Set as Notification';

  @override
  String get setAsAlarm => 'Set as Alarm';

  @override
  String get setForContact => 'Set for Contact';

  @override
  String get editorTitle => 'Studio';

  @override
  String get editorSet => 'SET';

  @override
  String get editorExport => 'EXPORT';

  @override
  String get editorImport => 'IMPORT TRACK';

  @override
  String get editorFadeIn => 'Fade In';

  @override
  String get editorFadeOut => 'Fade Out';

  @override
  String get editorSpeed => 'Speed';

  @override
  String get msgExportSuccess => 'Exported successfully';

  @override
  String get msgExportFailed => 'Export failed';

  @override
  String get premiumUpgradeTitle => 'Upgrade to Premium';

  @override
  String get premiumUnlockDesc => 'Unlock exclusive ringtones and features!';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planLifetime => 'Lifetime';

  @override
  String get labelBestValue => 'BEST VALUE';

  @override
  String get linkRestorePurchase => 'Restore Purchase';

  @override
  String get btnSubscribe => 'Tilaa';

  @override
  String get msgPremiumWelcome => 'Welcome to Ringo Premium!';

  @override
  String get premiumAppBarTitle => 'Ringo Premium';

  @override
  String get periodMonth => '/ month';

  @override
  String get periodYear => '/ year';

  @override
  String get periodOneTime => 'one-time';

  @override
  String get requestRingtone => 'Pyydä soittoääntä';

  @override
  String get clearCache => 'Tyhjennä välimuisti';

  @override
  String get clearCacheSubtitle => 'Vapauta tilaa';

  @override
  String get cacheCleared => 'Välimuisti tyhjennetty';

  @override
  String get showLess => 'Show Less';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeMatchSystem => 'Match system wallpaper';

  @override
  String get themeCustomRingtones => 'Create custom ringtones';

  @override
  String get cantFindAsk => 'Can\'t find it? Ask us!';

  @override
  String get couldNotLaunchEmail => 'Could not launch email app';

  @override
  String get couldNotOpenPrivacy => 'Could not open Privacy Policy';

  @override
  String get copyrightNotice => 'Copyright Notice';

  @override
  String get copyrightRights => 'Content ownership & rights';

  @override
  String get copyrightDisclaimer => 'Copyright Disclaimer';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get noRingtoneData => 'No ringtone data provided';

  @override
  String get adNotReady => 'Ad not ready. Please try again in a moment.';

  @override
  String get unlockWithAd => 'Unlock with an ad to play this ringtone';

  @override
  String get previewSeek => 'PREVIEW & SEEK';

  @override
  String get trimRange => 'TRIM RANGE';

  @override
  String get failedToSaveMusic =>
      'Exported successfully, but failed to save to Music folder.';

  @override
  String get nativeTrimFailed => 'Export failed! Native trim failed.';

  @override
  String get copyrightContent =>
      'All ringtones, audio tracks, and sound effects available in this application are 100% original compositions produced and owned by the developer.\n\nThese works are protected by copyright law. Unauthorized reproduction, redistribution, or commercial use of this content is strictly prohibited.\n\n© 2026 Resono. All Rights Reserved.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageThai => 'ไทย';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languageSwedish => 'Svenska';

  @override
  String get languageCzech => 'Čeština';

  @override
  String get languageGreek => 'Ελληνικά';

  @override
  String get languageRomanian => 'Română';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get languageDanish => 'Dansk';

  @override
  String get languageFinnish => 'Suomi';

  @override
  String get languageNorwegian => 'Norsk';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get labelSaving => 'Saving...';

  @override
  String get appSubtitle => 'Premium Ringtones & Sounds';

  @override
  String get couldNotOpenLink =>
      'Could not open link. Please Ensure you have a browser or the app installed.';
}
