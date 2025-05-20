import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';
import '../models/ad_config.dart';

class AdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AdConfig _adConfig;

  // Reklam gösterim sayacı
  int _interstitialAdCount = 0;
  int _rewardedAdCount = 0;

  // Hazır reklamlar
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal() {
    _adConfig = AdConfig.defaultConfig;
    _loadAdConfig();
  }

  // Firebase'den reklam ayarlarını yükle
  Future<void> _loadAdConfig() async {
    try {
      final docSnapshot = await _firestore.collection('Ads').doc('ad_1').get();

      if (docSnapshot.exists) {
        _adConfig = AdConfig.fromFirestore(docSnapshot);
        debugPrint(
            'Ad config loaded: maxImpression=${_adConfig.maxImpression}, platform=${_adConfig.platform}');
        debugPrint('Is test mode: ${_adConfig.isTestMode}');
        debugPrint(
            'Real interstitial ad unit ID: ${_adConfig.realInterstitialAdUnitId}');
        debugPrint(
            'Test interstitial ad unit ID: ${_adConfig.testInterstitialAdUnitId}');
        debugPrint(
            'Using interstitial ad unit ID: ${_adConfig.interstitialAdUnitId}');
      } else {
        debugPrint('Ad config not found, using default values');
      }
    } catch (e) {
      debugPrint('Error loading ad config: $e');
    }
  }

  // Geçiş reklamı yükle
  Future<void> loadInterstitialAd() async {
    if (_interstitialAdCount >= _adConfig.maxImpression) {
      debugPrint(
          'Interstitial ad limit reached: $_interstitialAdCount >= ${_adConfig.maxImpression}');
      return;
    }

    final adUnitId = _adConfig.interstitialAdUnitId;
    debugPrint(
        'Loading interstitial ad with ID: $adUnitId (platform: ${_adConfig.platform}, isTestMode: ${_adConfig.isTestMode})');

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  // Geçiş reklamını göster
  Future<void> showInterstitialAd() async {
   if (RevenueCatIntegrationService.instance.isPremium.value) return;

    if (_interstitialAdCount >= _adConfig.maxImpression) {
      debugPrint(
          'Interstitial ad limit reached: $_interstitialAdCount >= ${_adConfig.maxImpression}');
      return;
    }

    if (_interstitialAd == null) {
      debugPrint('Interstitial ad not ready, loading...');
      await loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialAdCount++;
        debugPrint('Interstitial ad dismissed, count: $_interstitialAdCount');
        loadInterstitialAd(); // Pre-load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Interstitial ad showed');
      },
    );

    await _interstitialAd!.show();
  }

  // Ödüllü reklam yükle
  Future<void> loadRewardedAd() async {
    if (_rewardedAdCount >= _adConfig.maxImpression) {
      debugPrint(
          'Rewarded ad limit reached: $_rewardedAdCount >= ${_adConfig.maxImpression}');
      return;
    }

    await RewardedAd.load(
      adUnitId: _adConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  // Ödüllü reklamı göster ve tamamlandığında callback çağır
  Future<void> showRewardedAd({required Function onRewarded}) async {
    if (_rewardedAdCount >= _adConfig.maxImpression) {
      debugPrint(
          'Rewarded ad limit reached: $_rewardedAdCount >= ${_adConfig.maxImpression}');
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not ready, loading...');
      await loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedAdCount++;
        debugPrint('Rewarded ad dismissed, count: $_rewardedAdCount');
        loadRewardedAd(); // Pre-load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad showed');
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      onRewarded();
    });
  }

  // Reklam servisi durumunu sıfırla (örn. oturum açma/kapatma sırasında)
  void resetAdCounts() {
    _interstitialAdCount = 0;
    _rewardedAdCount = 0;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  // Geçerli yapılandırmayı al
  AdConfig get adConfig => _adConfig;

  // Geçiş reklamı gösterimi sınırına ulaşıldı mı?
  bool get isInterstitialLimitReached =>
      _interstitialAdCount >= _adConfig.maxImpression;

  // Ödüllü reklam gösterimi sınırına ulaşıldı mı?
  bool get isRewardedLimitReached =>
      _rewardedAdCount >= _adConfig.maxImpression;
}
