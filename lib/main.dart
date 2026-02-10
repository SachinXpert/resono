import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ringo_ringtones/core/router.dart';
import 'package:ringo_ringtones/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:ringo_ringtones/core/providers/theme_provider.dart';
import 'package:ringo_ringtones/core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ringo_ringtones/core/services/ad_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  // Ensure bindings are initialized, but don't await heavy tasks here.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run AppBootstrapper immediately to show Splash
  runApp(const AppBootstrapper());
}

/// A lightweight widget that shows the Splash Screen while initializing the app.
class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final minSplashTimer = Future.delayed(const Duration(seconds: 3)); // Branding duration

    try {
       // Initialize Firebase first
       await Firebase.initializeApp();

       // Initialize Ads in background
       MobileAds.instance.initialize();
       adServiceProvider.loadAppOpenAd();

       // Parallel Heavy Inits
       await Future.wait([
          SharedPreferences.getInstance().then((prefs) {
             _prefs = prefs;
             adServiceProvider.isPremium = prefs.getBool('is_premium_user') ?? false;
          }),
          FirebaseMessaging.instance.subscribeToTopic('all'),
          JustAudioBackground.init(
            androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
            androidNotificationChannelName: 'Audio playback',
            androidNotificationOngoing: true,
          ),
          NotificationService().initialize(),
       ]);

       FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

       // Wait for Ad (optional, max 3s total including splash time)
       // We don't want to block more than splash time if possible.
       try {
          await adServiceProvider.waitForAppOpenAdLoad().timeout(const Duration(milliseconds: 500));
       } catch (_) {}

    } catch (e) {
       debugPrint("Bootstrapper Init Error: $e");
    }

    await minSplashTimer;

    if (mounted) {
       // Check Ad and Transition
       adServiceProvider.showAppOpenAdIfAvailable();
       
       // Switch to Real App
       runApp(
        ProviderScope(
          overrides: [
            if (_prefs != null) ...[
               ringtoneRepositoryProvider.overrideWithValue(RingtoneRepository(_prefs!)),
               themeProvider.overrideWith((ref) => ThemeNotifier(_prefs!)),
            ]
          ],
          child: const RingoApp(),
        ),
      );
    }
  }

  SharedPreferences? _prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 100,
              color: Colors.deepPurpleAccent, // Hardcoded color for bootstrapper
            ).animate()
             .fade(duration: 600.ms)
             .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
             .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.5)),

            const SizedBox(height: 24),

            Text(
              'Ringo Ringtones',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                fontFamily: 'Roboto', // Default fallback
                decoration: TextDecoration.none,
              ),
            ).animate()
             .fadeIn(delay: 400.ms, duration: 600.ms)
             .moveY(begin: 20, end: 0, delay: 400.ms, duration: 600.ms),
             
             const SizedBox(height: 12),
             
             Text(
               'Premium Ringtones & Sounds',
               style: const TextStyle(
                 fontSize: 16,
                 color: Colors.white70,
                 decoration: TextDecoration.none,
               ),
             ).animate()
             .fadeIn(delay: 800.ms, duration: 600.ms),
             
             const SizedBox(height: 48),
             
             const SizedBox(
               width: 24,
               height: 24,
               child: CircularProgressIndicator(
                 strokeWidth: 2,
                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
               ),
             ).animate().fadeIn(delay: 1500.ms),
          ],
        ),
      ),
      ),
    );
  }
}


class RingoApp extends ConsumerStatefulWidget {
  const RingoApp({super.key});

  @override
  ConsumerState<RingoApp> createState() => _RingoAppState();
}

class _RingoAppState extends ConsumerState<RingoApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupInteractedMessage();
    // App Open Ad is handled by Bootstrapper on launch, logic here is for resume
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      adServiceProvider.showAppOpenAdIfAvailable();
    }
  }

  Future<void> _setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
     print("Handling FCM Message: ${message.data}");
     if (message.data['type'] == 'ringtone') {
        final String? ringtoneId = message.data['id'];
        if (ringtoneId != null) {
             final router = ref.read(routerProvider);
             final repo = ref.read(ringtoneRepositoryProvider);
             repo.fetchRingtone(ringtoneId).then((ringtone) {
                if (ringtone != null) {
                   router.push('/detail', extra: ringtone);
                }
             });
        }
     } else if (message.data['type'] == 'category') {
        final String? category = message.data['category'];
        if (category != null) {
          final router = ref.read(routerProvider);
          router.push('/category/$category'); 
        }
     }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Ringo Ringtones',
          theme: AppTheme.lightTheme(themeState.useDynamicColor ? lightDynamic : null),
          darkTheme: AppTheme.darkTheme(themeState.useDynamicColor ? darkDynamic : null),
          themeMode: themeState.themeMode,
          routerConfig: router,
          locale: locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('hi'), // Hindi
        Locale('fr'), // French
        Locale('de'), // German
        Locale('it'), // Italian
        Locale('pt'), // Portuguese
        Locale('ru'), // Russian
        Locale('zh'), // Chinese
        Locale('ja'), // Japanese
        Locale('ko'), // Korean
        Locale('ar'), // Arabic
        Locale('tr'), // Turkish
        Locale('vi'), // Vietnamese
        Locale('th'), // Thai
        Locale('id'), // Indonesian
        Locale('nl'), // Dutch
        Locale('pl'), // Polish
        Locale('uk'), // Ukrainian
        Locale('sv'), // Swedish
        Locale('cs'), // Czech
        Locale('el'), // Greek
        Locale('ro'), // Romanian
        Locale('hu'), // Hungarian
        Locale('da'), // Danish
        Locale('fi'), // Finnish
        Locale('no'), // Norwegian
        Locale('he'), // Hebrew
        Locale('ms'), // Malay
        Locale('bn'), // Bengali
        Locale('ur'), // Urdu
      ],
        );
      }
    );
  }
}
