// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ringo Sonneries';

  @override
  String get homeTab => 'Accueil';

  @override
  String get searchTab => 'Recherche';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get premiumTitle => 'Ringo Premium';

  @override
  String get premiumSubtitle => 'Débloquez tout';

  @override
  String get appearanceHeader => 'Apparence';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get dynamicColor => 'Couleur dynamique';

  @override
  String get toolsHeader => 'Outils';

  @override
  String get ringtoneEditor => 'Éditeur de sonnerie';

  @override
  String get generalHeader => 'Général';

  @override
  String get language => 'Langue';

  @override
  String get storage => 'Stockage';

  @override
  String get legalHeader => 'Mentions légales';

  @override
  String get privacyPolicy => 'Confidentialité';

  @override
  String get aboutUs => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get searchHint => 'Rechercher des sonneries...';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get noFavorites => 'Pas encore de favoris';

  @override
  String get ringtonesTitle => 'Ringtones';

  @override
  String get songsTitle => 'Chansons';

  @override
  String get noSongs => 'Aucune chanson trouvée.';

  @override
  String get latestTitle => 'Derniers';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get noLatestRingtones => 'Aucune sonnerie récente.';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get noCategories => 'Aucune catégorie trouvée.';

  @override
  String get typeToSearch => 'Tapez pour rechercher';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get roleDeveloper => 'Développeur';

  @override
  String get roleAppOwner => 'Propriétaire';

  @override
  String get trendingTitle => 'Tendances';

  @override
  String get noTrending => 'Pas de sonneries tendance.';

  @override
  String get detailSetRingtone => 'Définir Sonnerie';

  @override
  String get detailDownload => 'Télécharger';

  @override
  String get detailEdit => 'Éditer';

  @override
  String get detailSetAs => 'Définir comme';

  @override
  String get detailSetSuccess => 'Défini avec succès comme';

  @override
  String get detailSetFailed => 'Échec de la définition.';

  @override
  String get dialogPremiumTitle => 'Débloquer Premium';

  @override
  String get dialogPremiumContent =>
      'Le téléchargement est une fonctionnalité Premium. Mettez à niveau !';

  @override
  String get dialogEditPremiumContent =>
      'L\'édition est une fonctionnalité Premium. Mettez à niveau !';

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnUpgrade => 'Mettre à niveau';

  @override
  String get msgDownloading => 'Téléchargement...';

  @override
  String get msgDownloadFailed => 'Échec du téléchargement';

  @override
  String get msgSavedToMusic => 'Enregistré dans Musique';

  @override
  String get errorAudio => 'Erreur audio';

  @override
  String get permissionContact => 'Permission refusée';

  @override
  String get setAsRingtone => 'Définir comme Sonnerie';

  @override
  String get setAsNotification => 'Définir comme Notification';

  @override
  String get setAsAlarm => 'Définir comme Alarme';

  @override
  String get setForContact => 'Définir pour Contact';

  @override
  String get editorTitle => 'Studio';

  @override
  String get editorSet => 'DÉFINIR';

  @override
  String get editorExport => 'EXPORTER';

  @override
  String get editorImport => 'IMPORTER';

  @override
  String get editorFadeIn => 'Fondu Entrant';

  @override
  String get editorFadeOut => 'Fondu Sortant';

  @override
  String get editorSpeed => 'Vitesse';

  @override
  String get msgExportSuccess => 'Exporté avec succès';

  @override
  String get msgExportFailed => 'Échec de l\'exportation';

  @override
  String get premiumUpgradeTitle => 'Passer à Premium';

  @override
  String get premiumUnlockDesc => 'Débloquez tout !';

  @override
  String get planMonthly => 'Mensuel';

  @override
  String get planYearly => 'Annuel';

  @override
  String get planLifetime => 'À vie';

  @override
  String get labelBestValue => 'MEILLEUR';

  @override
  String get linkRestorePurchase => 'Restaurer';

  @override
  String get btnSubscribe => 'S\'abonner';

  @override
  String get msgPremiumWelcome => 'Bienvenue !';

  @override
  String get premiumAppBarTitle => 'Ringo Premium';

  @override
  String get periodMonth => '/ mois';

  @override
  String get periodYear => '/ an';

  @override
  String get periodOneTime => 'une fois';

  @override
  String get requestRingtone => 'Demander Sonnerie';

  @override
  String get clearCache => 'Vider Cache';

  @override
  String get clearCacheSubtitle => 'Libérer espace';

  @override
  String get cacheCleared => 'Cache vidé';

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
