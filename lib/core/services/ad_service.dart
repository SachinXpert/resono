import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async'; // Required for Completer

class AdService {
  // TODO: Replace with Real IDs before publishing to Play Store
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  
  // TODO: Replace with Real IDs before publishing to Play Store
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID

  // TODO: Replace with Real IDs before publishing to Play Store
  static const String _appOpenAdUnitId = 'ca-app-pub-3940256099942544/9257395921'; // Test ID (Alternative)

  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  bool _isLoading = false;
  bool _isAppOpenAdLoading = false;
  DateTime? _appOpenAdLoadTime;
  bool isPremium = false;
  Completer<void>? _appOpenAdLoaderCompleter; // Fixed generic type

  Future<void> waitForAppOpenAdLoad() async {
    if (_appOpenAd != null) return;
    if (!_isAppOpenAdLoading) loadAppOpenAd();
    
    // Wait for existing load or new load
    if (_appOpenAdLoaderCompleter != null && !_appOpenAdLoaderCompleter!.isCompleted) {
       await _appOpenAdLoaderCompleter!.future;
    }
  }

  void loadAppOpenAd() {
    debugPrint('AdService: loadAppOpenAd called. Premium: $isPremium, Loading: $_isAppOpenAdLoading, Existing: ${_appOpenAd != null}');
    if (isPremium || _isAppOpenAdLoading || _appOpenAd != null) return;
    
    _isAppOpenAdLoading = true;
    _appOpenAdLoaderCompleter = Completer<void>(); // Using generic type, or void

    // Register Test Device
    // This is crucial for emulators and test devices to avoid "No Fill" or verification issues.
    final RequestConfiguration requestConfiguration = RequestConfiguration(
      testDeviceIds: ['F41B9B77E63A3F1AF54ABFCC3639F896'], 
    );
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);

    debugPrint('AdService: Requesting App Open Ad with ID: $_appOpenAdUnitId');
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: AppOpenAd loaded successfully');
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
          _appOpenAdLoadTime = DateTime.now();
          if (_appOpenAdLoaderCompleter != null && !_appOpenAdLoaderCompleter!.isCompleted) {
             _appOpenAdLoaderCompleter!.complete(null);
          }
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdLoading = false;
          debugPrint('AdService: AppOpenAd failed to load: ${error.code} - ${error.message}');
          if (_appOpenAdLoaderCompleter != null && !_appOpenAdLoaderCompleter!.isCompleted) {
             _appOpenAdLoaderCompleter!.complete(null);
          }
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    debugPrint('AdService: showAppOpenAdIfAvailable called. Loaded: ${_appOpenAd != null}, Loading: $_isAppOpenAdLoading');
    if (isPremium) return;
    
    if (_appOpenAd == null) {
      if (!_isAppOpenAdLoading) {
        debugPrint('AdService: Ad not loaded and not loading. Loading now...');
        loadAppOpenAd();
      } else {
         debugPrint('AdService: Ad is currently loading. Will show when loaded (if logic supports it, otherwise next launch).');
         // We could add a callback here, but for now let's just let it load for next time.
         // Or, if really needed, we can show it in onAdLoaded callback if app is resumed.
      }
      return;
    }

    // Check if ad is expired (4 hours is default for AdMob)
    if (_appOpenAdLoadTime != null && 
        DateTime.now().difference(_appOpenAdLoadTime!).inHours >= 4) {
      debugPrint('AdService: App Open Ad expired. Reloading.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: AppOpenAd dismissed');
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: AppOpenAd failed to show: ${error.message}');
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (ad) => debugPrint('AdService: AppOpenAd showed full screen content'),
    );
    _appOpenAd!.show();
  }

  BannerAd createBannerAd({
    required AdSize size,
    required void Function(Ad ad) onAdLoaded,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    debugPrint('AdService: Creating BannerAd with size: $size');
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdService: BannerAd loaded successfully. Size: ${ad.responseInfo}');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: BannerAd failed to load: ${error.code} - ${error.message} - ${error.domain}');
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
        onAdOpened: (ad) => debugPrint('AdService: BannerAd opened'),
        onAdClosed: (ad) => debugPrint('AdService: BannerAd closed'),
        onAdImpression: (ad) => debugPrint('AdService: BannerAd impression recorded'),
      ),
    );
  }

  void loadRewardedAd({Function? onAdLoaded}) {
    debugPrint('AdService: loadRewardedAd called. Premium: $isPremium, Loading: $_isLoading, Existing: ${_rewardedAd != null}');
    if (isPremium || _isLoading || _rewardedAd != null) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: RewardedAd loaded successfully');
          _rewardedAd = ad;
          _isLoading = false;
          onAdLoaded?.call();
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdService: RewardedAd dismissed');
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdService: RewardedAd failed to show: ${error.message}');
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
            onAdShowedFullScreenContent: (ad) => debugPrint('AdService: RewardedAd showed full screen content'),
            onAdImpression: (ad) => debugPrint('AdService: RewardedAd impression recorded'),
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _rewardedAd = null;
          debugPrint('AdService: RewardedAd failed to load: ${error.code} - ${error.message}');
        },
      ),
    );
  }

  void showRewardedAd({required Function onUserEarnedReward, Function? onAdFailed}) {
    debugPrint('AdService: showRewardedAd called. Ad available: ${_rewardedAd != null}');
    if (_rewardedAd == null) {
      onAdFailed?.call();
      debugPrint('AdService: showRewardedAd failed - Ad not ready. Reloading...');
      loadRewardedAd();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward();
      },
    );
  }
}

final adServiceProvider = kDebugMode ? AdService() : AdService(); // Singleton-like for simplicity
