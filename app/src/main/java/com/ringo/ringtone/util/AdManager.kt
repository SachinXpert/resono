package com.ringo.ringtone.util

import android.app.Activity
import android.content.Context
import android.util.Log
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.AdError

class AdManager private constructor() {
    companion object {
        private const val TAG = "AdManager"
        private var instance: AdManager? = null
        private const val INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712" // Test ad unit ID
        private const val BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111" // Test ad unit ID
        
        fun getInstance(): AdManager {
            if (instance == null) {
                instance = AdManager()
            }
            return instance!!
        }
    }
    
    private var interstitialAd: InterstitialAd? = null
    
    fun initialize(context: Context) {
        MobileAds.initialize(context) {}
    }
    
    fun loadInterstitialAd(activity: Activity) {
        val adRequest = AdRequest.Builder().build()
        
        InterstitialAd.load(
            activity,
            INTERSTITIAL_AD_UNIT_ID,
            adRequest,
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(interstitialAd: InterstitialAd) {
                    Log.d(TAG, "Interstitial ad loaded")
                    this@AdManager.interstitialAd = interstitialAd
                }
                
                override fun onAdFailedToLoad(adError: LoadAdError) {
                    Log.e(TAG, "Interstitial ad failed to load: ${adError.message}")
                    this@AdManager.interstitialAd = null
                }
            }
        )
    }
    
    fun showInterstitialAd(activity: Activity, onAdClosed: () -> Unit) {
        val ad = interstitialAd
        if (ad != null) {
            ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                override fun onAdDismissedFullScreenContent() {
                    Log.d(TAG, "Ad dismissed")
                    onAdClosed()
                    loadInterstitialAd(activity) // Load next ad
                }
                
                override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                    Log.e(TAG, "Ad failed to show: ${adError.message}")
                    onAdClosed()
                }
                
                override fun onAdShowedFullScreenContent() {
                    Log.d(TAG, "Ad showed")
                    this@AdManager.interstitialAd = null
                }
            }
            ad.show(activity)
        } else {
            Log.d(TAG, "Interstitial ad not ready")
            onAdClosed()
        }
    }
    
    fun createBannerAdRequest(): AdRequest {
        return AdRequest.Builder().build()
    }
    
    fun getBannerAdUnitId(): String {
        return BANNER_AD_UNIT_ID
    }
}