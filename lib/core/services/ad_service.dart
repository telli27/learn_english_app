import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';
import '../models/ad_config.dart';

class AdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AdConfig _adConfig;

  // Reklam gösterim sayacı
  int _interstitialAdCount = 0;
  int _rewardedAdCount = 0;
  int _bannerAdCount = 0;

  // Hazır reklamlar
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  Widget? bannerAdWidget;

  // Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal() {
    _adConfig = AdConfig.defaultConfig;
    _loadAdConfig();
  }

  // Firebase'den reklam ayarlarını yükle
  Future<void> _loadAdConfig() async {
    debugPrint('=== LOADING AD CONFIG FROM FIREBASE ===');
    try {
      final docSnapshot = await _firestore.collection('Ads').doc('ad_1').get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        debugPrint('Firebase ad config data: $data');

        _adConfig = AdConfig.fromFirestore(docSnapshot);
        debugPrint('✅ Ad config loaded successfully:');
        debugPrint('  - Max Impression: ${_adConfig.maxImpression}');
        debugPrint('  - Platform: ${_adConfig.platform}');
        debugPrint('  - Is Test Mode: ${_adConfig.isTestMode}');
        debugPrint(
            '  - Real Interstitial ID: ${_adConfig.realInterstitialAdUnitId}');
        debugPrint(
            '  - Test Interstitial ID: ${_adConfig.testInterstitialAdUnitId}');
        debugPrint(
            '  - Using Interstitial ID: ${_adConfig.interstitialAdUnitId}');
        debugPrint('  - Real Rewarded ID: ${_adConfig.realRewardedAdUnitId}');
        debugPrint('  - Test Rewarded ID: ${_adConfig.testRewardedAdUnitId}');
        debugPrint('  - Using Rewarded ID: ${_adConfig.rewardedAdUnitId}');
        debugPrint('  - Real Banner ID: ${_adConfig.realBannerAdUnitId}');
        debugPrint('  - Test Banner ID: ${_adConfig.testBannerAdUnitId}');
        debugPrint('  - Using Banner ID: ${_adConfig.bannerAdUnitId}');
      } else {
        debugPrint(
            '❌ Ad config document not found in Firebase, using default values');
        debugPrint('Default config: ${_adConfig.interstitialAdUnitId}');
      }
    } catch (e) {
      debugPrint('❌ Error loading ad config from Firebase: $e');
    }
    debugPrint('=== AD CONFIG LOADING COMPLETED ===');
  }

  // Banner reklamı yükle
  Future<void> loadBannerAd() async {
    if (RevenueCatIntegrationService.instance.isPremium.value) return;

    final adUnitId = _adConfig.bannerAdUnitId;
    if (adUnitId.isEmpty) {
      debugPrint('Banner ad unit ID is empty.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded.');
          _bannerAd = ad as BannerAd;
          bannerAdWidget = AdWidget(ad: _bannerAd!);
          _bannerAdCount++;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          bannerAdWidget = null;
        },
      ),
    );
    await _bannerAd!.load();
  }

  // Banner reklam widget'ını al
  Widget? getBannerAdWidget() {
    if (RevenueCatIntegrationService.instance.isPremium.value) {
      return null;
    }
    if (_bannerAd == null) {
      loadBannerAd();
      return null; // Yüklenirken null dönebilir veya bir yükleme göstergesi
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
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

  // Geçiş reklamını göster (Oyunlar için - limit yok)
  Future<void> showInterstitialAdPlayGame() async {
    debugPrint('=== GAME INTERSTITIAL AD PROCESS STARTED ===');

    // Premium kullanıcı kontrolü
    if (RevenueCatIntegrationService.instance.isPremium.value) {
      debugPrint('User is premium, skipping ad');
      return;
    }

    // Reklam hazır mı kontrol et
    if (_interstitialAd == null) {
      debugPrint('Interstitial ad not ready, attempting to load...');
      await loadInterstitialAdForGame();

      // Yükleme sonrası tekrar kontrol
      if (_interstitialAd == null) {
        debugPrint('Failed to load interstitial ad, cannot show');
        throw Exception('Interstitial ad could not be loaded');
      }
      debugPrint('Interstitial ad loaded successfully, proceeding to show');
    }

    // Completer to wait for ad to be fully dismissed
    final Completer<void> adCompleter = Completer<void>();
    bool adShown = false;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Game interstitial ad dismissed by user');
        ad.dispose();
        _interstitialAd = null;

        // Pre-load next ad
        loadInterstitialAdForGame().then((_) {
          debugPrint('Next game interstitial ad pre-loaded');
        }).catchError((error) {
          debugPrint('Failed to pre-load next ad: $error');
        });

        // Complete the future when ad is dismissed
        if (!adCompleter.isCompleted) {
          adCompleter.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Game interstitial ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;

        // Try to load a new ad
        loadInterstitialAdForGame().catchError((loadError) {
          debugPrint('Failed to load replacement ad: $loadError');
        });

        // Complete the future even if ad failed
        if (!adCompleter.isCompleted) {
          adCompleter.completeError('Ad failed to show: $error');
        }
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Game interstitial ad showed successfully');
        adShown = true;
      },
      onAdClicked: (ad) {
        debugPrint('Game interstitial ad clicked');
      },
    );

    try {
      debugPrint('Attempting to show game interstitial ad...');
      await _interstitialAd!.show();

      // Wait for the ad to be fully processed
      await adCompleter.future;

      if (adShown) {
        debugPrint(
            '=== GAME INTERSTITIAL AD PROCESS COMPLETED SUCCESSFULLY ===');
      } else {
        debugPrint('=== GAME INTERSTITIAL AD PROCESS COMPLETED (NO SHOW) ===');
      }
    } catch (e) {
      debugPrint('Error during game interstitial ad show process: $e');
      rethrow;
    }
  }

  // Oyunlar için reklam yükle (limit yok)
  Future<void> loadInterstitialAdForGame() async {
    debugPrint('=== LOADING GAME INTERSTITIAL AD ===');

    if (RevenueCatIntegrationService.instance.isPremium.value) {
      debugPrint('User is premium, skipping ad load');
      return;
    }

    final adUnitId = _adConfig.interstitialAdUnitId;
    debugPrint('Ad Unit ID: $adUnitId');
    debugPrint('Platform: ${_adConfig.platform}');
    debugPrint('Is Test Mode: ${_adConfig.isTestMode}');
    debugPrint('Real Ad Unit ID: ${_adConfig.realInterstitialAdUnitId}');
    debugPrint('Test Ad Unit ID: ${_adConfig.testInterstitialAdUnitId}');

    if (adUnitId.isEmpty) {
      debugPrint('ERROR: Ad Unit ID is empty! Cannot load ad.');
      throw Exception('Ad Unit ID is empty');
    }

    // Dispose existing ad if any
    if (_interstitialAd != null) {
      debugPrint('Disposing existing interstitial ad before loading new one');
      _interstitialAd!.dispose();
      _interstitialAd = null;
    }

    final Completer<void> loadCompleter = Completer<void>();

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Game interstitial ad loaded successfully');
            _interstitialAd = ad;
            if (!loadCompleter.isCompleted) {
              loadCompleter.complete();
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Game interstitial ad failed to load: $error');
            debugPrint('Error code: ${error.code}');
            debugPrint('Error message: ${error.message}');
            _interstitialAd = null;
            if (!loadCompleter.isCompleted) {
              loadCompleter.completeError(error);
            }
          },
        ),
      );

      // Wait for load to complete
      await loadCompleter.future;
      debugPrint('=== GAME INTERSTITIAL AD LOAD COMPLETED ===');
    } catch (e) {
      debugPrint('Exception during ad load: $e');
      _interstitialAd = null;
      rethrow;
    }
  }

  // Ödüllü reklam yükle
  Future<void> loadRewardedAd() async {
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
    if (RevenueCatIntegrationService.instance.isPremium.value) return;
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not ready');
      throw Exception('Rewarded ad not ready');
    }

    // Use a completer to handle ad show success/failure
    final Completer<void> adCompleter = Completer<void>();
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        _rewardedAd = null;
        _rewardedAdCount++;
        debugPrint('Rewarded ad dismissed, count: $_rewardedAdCount');

        // Pre-load next ad and wait for it to complete
        await loadRewardedAd();
        debugPrint('Next rewarded ad pre-loaded after dismissal');

        if (!adCompleter.isCompleted) {
          if (rewardEarned) {
            adCompleter.complete();
          } else {
            adCompleter.completeError('Ad dismissed without reward');
          }
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;

        // Try to load a new ad even if this one failed
        await loadRewardedAd();

        if (!adCompleter.isCompleted) {
          adCompleter.completeError('Rewarded ad failed to show: $error');
        }
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad showed');
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      rewardEarned = true;
      onRewarded();
    });

    // Wait for the ad to complete or fail
    await adCompleter.future;
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

  // Ödüllü reklam hazır mı?
  bool get isRewardedAdReady => _rewardedAd != null;

  // Geçiş reklamı hazır mı?
  bool get isInterstitialAdReady => _interstitialAd != null;

  // Debug: Reklam durumunu yazdır
  void printAdStatus() {
    debugPrint('=== AD SERVICE STATUS ===');
    debugPrint('Interstitial Ad Ready: $isInterstitialAdReady');
    debugPrint('Rewarded Ad Ready: $isRewardedAdReady');
    debugPrint('Interstitial Count: $_interstitialAdCount');
    debugPrint('Rewarded Count: $_rewardedAdCount');
    debugPrint('Interstitial Limit Reached: $isInterstitialLimitReached');
    debugPrint('Rewarded Limit Reached: $isRewardedLimitReached');
    debugPrint(
        'Is Premium: ${RevenueCatIntegrationService.instance.isPremium.value}');
    debugPrint('Current Ad Config:');
    debugPrint('  - Platform: ${_adConfig.platform}');
    debugPrint('  - Test Mode: ${_adConfig.isTestMode}');
    debugPrint('  - Interstitial ID: ${_adConfig.interstitialAdUnitId}');
    debugPrint('  - Max Impressions: ${_adConfig.maxImpression}');
    debugPrint('========================');
  }
}
