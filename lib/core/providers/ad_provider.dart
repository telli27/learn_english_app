import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';
import '../models/ad_config.dart';

// AdService provider
final adServiceProvider = StateProvider<AdService>((ref) {
  return AdService();
});

// AdConfig provider
final adConfigProvider = StateProvider<AdConfig>((ref) {
  final adService = ref.watch(adServiceProvider).adConfig;
  return adService;
});

// Interstitial ad limit reached provider
final isInterstitialLimitReachedProvider = StateProvider<bool>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.isInterstitialLimitReached;
});

// Rewarded ad limit reached provider
final isRewardedLimitReachedProvider = StateProvider<bool>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.isRewardedLimitReached;
});
