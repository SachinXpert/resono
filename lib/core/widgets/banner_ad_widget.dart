import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  final AdSize adSize;
  const BannerAdWidget({super.key, this.adSize = AdSize.banner});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  AdSize? _adaptiveSize;
  bool _isAdLoading = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load ad here where context (MediaQuery) is available
    _onInit();
  }

  void _onInit() {
    if (_isLoaded || _isAdLoading || _bannerAd != null) return;

    // Check if premium status is already known. 
    // Since this is a widget, we can use ref.read to check initial state.
    final isPremium = ref.read(isPremiumUserProvider);
    if (!isPremium) {
       _loadAd();
    }
  }

  void _loadAd() {
    debugPrint('BannerAdWidget: _loadAd called. _isAdLoading: $_isAdLoading');
    if (_isAdLoading) return;
    _isAdLoading = true;

    _getAdaptiveSize().then((size) {
      debugPrint('BannerAdWidget: Calculated adaptive size: $size');
      if (size == null) {
        _isAdLoading = false;
        debugPrint('BannerAdWidget: Adaptive size is null, aborting load.');
        return;
      }
      if (!mounted) {
        _isAdLoading = false;
        debugPrint('BannerAdWidget: Widget not mounted, aborting load.');
        return;
      }
      
      setState(() {
        _adaptiveSize = size;
      });

      debugPrint('BannerAdWidget: Requesting banner ad from AdService...');
      _bannerAd = adServiceProvider.createBannerAd(
        size: size,
        onAdLoaded: (ad) {
          debugPrint('BannerAdWidget: Ad loaded callback received.');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isAdLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAdWidget: Ad failed to load callback received.');
          _isAdLoading = false;
        },
      );
      _bannerAd!.load();
    });
  }

  Future<AdSize?> _getAdaptiveSize() async {
     final Orientation orientation = MediaQuery.of(context).orientation;
     final double width = MediaQuery.of(context).size.width.truncateToDouble() - 32;
     return AdSize.getAnchoredAdaptiveBannerAdSize(orientation, width.toInt());
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumUserProvider);
    
    // While loading (or failed), show a placeholder with the CORRECT EXPECTED HEIGHT
    final height = _adaptiveSize?.height.toDouble() ?? 50.0;

    if (kDebugMode && isPremium) {
       return Container(
         height: height,
         width: double.infinity,
         margin: const EdgeInsets.symmetric(vertical: 8),
         color: Colors.amber.withOpacity(0.1),
         child: const Center(
           child: Text(
             "Ads Hidden (User is Premium)", 
             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)
           )
         ),
       );
    }

    if (isPremium) return const SizedBox.shrink();

    // If loaded, show the ad
    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    
    if (kDebugMode) {
       return Container(
         height: height,
         width: _adaptiveSize?.width.toDouble() ?? double.infinity,
         margin: const EdgeInsets.symmetric(vertical: 8),
         color: Colors.grey.withOpacity(0.1),
         child: Center(
           child: Text(
             _isLoaded ? "Ad Load Failed" : "Loading Adaptive Ad...", 
             style: const TextStyle(fontSize: 10)
           )
         ),
       );
    }

    // In production, keep the space reserved if we know the size, or hide it
    return SizedBox(height: height);
  }
}
