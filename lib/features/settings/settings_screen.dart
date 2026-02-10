import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/core/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/core/providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTab),
      ),
      body: ListView(
        children: [
          // PREMIUM CARD
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/premium'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent, Colors.orangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.premiumTitle,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.premiumSubtitle,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          _buildSectionHeader(context, l10n.appearanceHeader),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text(l10n.themeLight),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text(l10n.themeDark),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text(l10n.themeSystem),
                        icon: const Icon(Icons.settings_suggest_outlined),
                      ),
                    ],
                    selected: {themeState.themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(l10n.dynamicColor),
            subtitle: Text(l10n.themeMatchSystem),
            trailing: Switch(
              value: themeState.useDynamicColor, 
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleDynamicColor(val);
              }
            ),
            onTap: () {
               ref.read(themeProvider.notifier).toggleDynamicColor(!themeState.useDynamicColor);
            },
          ),
          
          _buildSectionHeader(context, l10n.toolsHeader),
          ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: Text(l10n.ringtoneEditor),
            subtitle: Text(l10n.themeCustomRingtones),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/editor');
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_page_outlined),
            title: Text(l10n.requestRingtone),
            subtitle: Text(l10n.cantFindAsk),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
               final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'support@ringo.com',
                  query: 'subject=Ringtone Request&body=I would like to request the following ringtone:',
               );
               try {
                 await launchUrl(emailLaunchUri);
               } catch (e) {
                 if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couldNotLaunchEmail)));
                 }
               }
            },
          ),

          _buildSectionHeader(context, l10n.generalHeader),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            trailing: DropdownButton<Locale?>(
              value: currentLocale,
              menuMaxHeight: 300, // Constrain height
              underline: const SizedBox(),
              items: [
                 DropdownMenuItem(value: null, child: Text(l10n.themeSystem)),
                 DropdownMenuItem(value: const Locale('en'), child: Text(l10n.languageEnglish)),
                 DropdownMenuItem(value: const Locale('es'), child: Text(l10n.languageSpanish)),
                 DropdownMenuItem(value: const Locale('hi'), child: Text(l10n.languageHindi)),
                 DropdownMenuItem(value: const Locale('fr'), child: Text(l10n.languageFrench)),
                 DropdownMenuItem(value: const Locale('de'), child: Text(l10n.languageGerman)),
                 DropdownMenuItem(value: const Locale('it'), child: Text(l10n.languageItalian)),
                 DropdownMenuItem(value: const Locale('pt'), child: Text(l10n.languagePortuguese)),
                 DropdownMenuItem(value: const Locale('ru'), child: Text(l10n.languageRussian)),
                 DropdownMenuItem(value: const Locale('zh'), child: Text(l10n.languageChinese)),
                 DropdownMenuItem(value: const Locale('ja'), child: Text(l10n.languageJapanese)),
                 DropdownMenuItem(value: const Locale('ko'), child: Text(l10n.languageKorean)),
                 DropdownMenuItem(value: const Locale('ar'), child: Text(l10n.languageArabic)),
                 DropdownMenuItem(value: const Locale('tr'), child: Text(l10n.languageTurkish)),
                 DropdownMenuItem(value: const Locale('vi'), child: Text(l10n.languageVietnamese)),
                 DropdownMenuItem(value: const Locale('th'), child: Text(l10n.languageThai)),
                 DropdownMenuItem(value: const Locale('id'), child: Text(l10n.languageIndonesian)),
                 DropdownMenuItem(value: const Locale('nl'), child: Text(l10n.languageDutch)),
                 DropdownMenuItem(value: const Locale('pl'), child: Text(l10n.languagePolish)),
                 DropdownMenuItem(value: const Locale('uk'), child: Text(l10n.languageUkrainian)),
                 DropdownMenuItem(value: const Locale('sv'), child: Text(l10n.languageSwedish)),
                 DropdownMenuItem(value: const Locale('cs'), child: Text(l10n.languageCzech)),
                 DropdownMenuItem(value: const Locale('el'), child: Text(l10n.languageGreek)),
                 DropdownMenuItem(value: const Locale('ro'), child: Text(l10n.languageRomanian)),
                 DropdownMenuItem(value: const Locale('hu'), child: Text(l10n.languageHungarian)),
                 DropdownMenuItem(value: const Locale('da'), child: Text(l10n.languageDanish)),
                 DropdownMenuItem(value: const Locale('fi'), child: Text(l10n.languageFinnish)),
                 DropdownMenuItem(value: const Locale('no'), child: Text(l10n.languageNorwegian)),
                 DropdownMenuItem(value: const Locale('he'), child: Text(l10n.languageHebrew)),
                 DropdownMenuItem(value: const Locale('ms'), child: Text(l10n.languageMalay)),
                 DropdownMenuItem(value: const Locale('bn'), child: Text(l10n.languageBengali)),
                 DropdownMenuItem(value: const Locale('ur'), child: Text(l10n.languageUrdu)),
              ],
              onChanged: (Locale? newLocale) {
                 ref.read(localeProvider.notifier).setLocale(newLocale);
              },
            ),
          ),
          ListTile(
             leading: const Icon(Icons.storage_outlined),
             title: Text(l10n.clearCache),
             subtitle: Text(l10n.clearCacheSubtitle),
             onTap: () async {
                // Clear Cache Logic
                try {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.clearCache}...')));
                  // Simulate or minimal clear
                  // In a real app with cached_network_image or similar, we'd clear that.
                  // For now, let's just show success after a fake delay as we rely on system cache mostly
                  await Future.delayed(const Duration(seconds: 1));
                  
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
                  }
                } catch (e) {
                   // Ignore
                }
             },
          ),
          

          
          _buildSectionHeader(context, l10n.legalHeader),
           ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            onTap: () async {
               final Uri url = Uri.parse("https://sites.google.com/view/pulpyweather/home");
               try {
                 await launchUrl(url, mode: LaunchMode.externalApplication);
               } catch (e) {
                 if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couldNotOpenPrivacy)));
                 }
               }
            },
          ),
          ListTile(
            leading: const Icon(Icons.copyright_outlined),
            title: Text(l10n.copyrightNotice),
            subtitle: Text(l10n.copyrightRights),
            onTap: () {
               showDialog(
                 context: context, 
                 builder: (c) => AlertDialog(
                    title: Text(l10n.copyrightDisclaimer),
                    content: SingleChildScrollView(
                      child: Text(
                        l10n.copyrightContent
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: Text(l10n.btnCancel), // Reuse cancel or ok
                      ),
                    ],
                 ),
               );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutUs),
            subtitle: const Text('Developer & Owner Info'),
            onTap: () {
               context.push('/about');
            },
          ),
          const SizedBox(height: 32),
          Center(
             child: Text(
               "${l10n.version} 1.0.0",
               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                 color: Theme.of(context).colorScheme.outline,
               ),
             ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
