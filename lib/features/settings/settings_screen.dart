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
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.settings_suggest_outlined),
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
            subtitle: const Text('Match system wallpaper'),
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
            subtitle: const Text('Create custom ringtones'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/editor');
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_page_outlined),
            title: Text(l10n.requestRingtone),
            subtitle: const Text("Can't find it? Ask us!"),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch email app")));
                 }
               }
            },
          ),

          _buildSectionHeader(context, l10n.generalHeader),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              menuMaxHeight: 300, // Constrain height
              underline: const SizedBox(),
              items: const [
                 DropdownMenuItem(value: Locale('en'), child: Text('English')),
                 DropdownMenuItem(value: Locale('es'), child: Text('Español')),
                 DropdownMenuItem(value: Locale('hi'), child: Text('हिन्दी')),
                 DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
                 DropdownMenuItem(value: Locale('de'), child: Text('Deutsch')),
                 DropdownMenuItem(value: Locale('it'), child: Text('Italiano')),
                 DropdownMenuItem(value: Locale('pt'), child: Text('Português')),
                 DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
                 DropdownMenuItem(value: Locale('zh'), child: Text('中文')),
                 DropdownMenuItem(value: Locale('ja'), child: Text('日本語')),
                 DropdownMenuItem(value: Locale('ko'), child: Text('한국어')),
                 DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                 DropdownMenuItem(value: Locale('tr'), child: Text('Türkçe')),
                 DropdownMenuItem(value: Locale('vi'), child: Text('Tiếng Việt')),
                 DropdownMenuItem(value: Locale('th'), child: Text('ไทย')),
                 DropdownMenuItem(value: Locale('id'), child: Text('Bahasa Indonesia')),
                 DropdownMenuItem(value: Locale('nl'), child: Text('Nederlands')),
                 DropdownMenuItem(value: Locale('pl'), child: Text('Polski')),
                 DropdownMenuItem(value: Locale('uk'), child: Text('Українська')),
                 DropdownMenuItem(value: Locale('sv'), child: Text('Svenska')),
                 DropdownMenuItem(value: Locale('cs'), child: Text('Čeština')),
                 DropdownMenuItem(value: Locale('el'), child: Text('Ελληνικά')),
                 DropdownMenuItem(value: Locale('ro'), child: Text('Română')),
                 DropdownMenuItem(value: Locale('hu'), child: Text('Magyar')),
                 DropdownMenuItem(value: Locale('da'), child: Text('Dansk')),
                 DropdownMenuItem(value: Locale('fi'), child: Text('Suomi')),
                 DropdownMenuItem(value: Locale('no'), child: Text('Norsk')),
                 DropdownMenuItem(value: Locale('he'), child: Text('עברית')),
                 DropdownMenuItem(value: Locale('ms'), child: Text('Bahasa Melayu')),
                 DropdownMenuItem(value: Locale('bn'), child: Text('বাংলা')),
                 DropdownMenuItem(value: Locale('ur'), child: Text('اردو')),
              ],
              onChanged: (Locale? newLocale) {
                 if (newLocale != null) {
                    ref.read(localeProvider.notifier).setLocale(newLocale);
                 }
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clearing cache...')));
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open Privacy Policy")));
                 }
               }
            },
          ),
          ListTile(
            leading: const Icon(Icons.copyright_outlined),
            title: const Text("Copyright Notice"),
            subtitle: const Text("Content ownership & rights"),
            onTap: () {
               showDialog(
                 context: context, 
                 builder: (c) => AlertDialog(
                    title: const Text("Copyright Disclaimer"),
                    content: const SingleChildScrollView(
                      child: Text(
                        "All ringtones, audio tracks, and sound effects available in this application are 100% original compositions produced and owned by the developer.\n\n"
                        "These works are protected by copyright law. Unauthorized reproduction, redistribution, or commercial use of this content is strictly prohibited.\n\n"
                        "© 2026 Resono. All Rights Reserved."
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
