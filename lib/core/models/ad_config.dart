import 'package:cloud_firestore/cloud_firestore.dart';

class AdConfig {
  final int maxImpression;
  final String platform;
  final String realInterstitialAdUnitId;
  final String realRewardedAdUnitId;
  final String testInterstitialAdUnitId;
  final String testRewardedAdUnitId;

  AdConfig({
    required this.maxImpression,
    required this.platform,
    required this.realInterstitialAdUnitId,
    required this.realRewardedAdUnitId,
    required this.testInterstitialAdUnitId,
    required this.testRewardedAdUnitId,
  });

  factory AdConfig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdConfig(
      maxImpression: data['maxImpression'] ?? 10,
      platform: data['platform'] ?? "canli",
      realInterstitialAdUnitId: data['realInterstitialAdUnitId'] ?? "",
      realRewardedAdUnitId: data['realRewardedAdUnitId'] ?? "",
      testInterstitialAdUnitId: data['testInterstitialAdUnitId'] ?? "",
      testRewardedAdUnitId: data['testRewardedAdUnitId'] ?? "",
    );
  }

  // İş moduna göre doğru reklam ID'lerini döndüren metodlar
  bool get isTestMode => platform != "canli";

  String get interstitialAdUnitId =>
      isTestMode ? testInterstitialAdUnitId : realInterstitialAdUnitId;

  String get rewardedAdUnitId =>
      isTestMode ? testRewardedAdUnitId : realRewardedAdUnitId;

  // Default test config
  static AdConfig get defaultConfig => AdConfig(
        maxImpression: 10,
        platform: "canli",
        realInterstitialAdUnitId: "",
        realRewardedAdUnitId: "",
        testInterstitialAdUnitId: "",
        testRewardedAdUnitId: "",
      );
}
