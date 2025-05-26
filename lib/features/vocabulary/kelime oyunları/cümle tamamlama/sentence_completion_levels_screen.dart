import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';

import 'enhanced_sentence_completion_data.dart';
import 'sentence_completion_game_screen.dart';
import '../../../../core/services/ad_service.dart';

/// Screen for displaying sentence completion game levels
class SentenceCompletionLevelsScreen extends ConsumerStatefulWidget {
  const SentenceCompletionLevelsScreen({super.key});

  @override
  ConsumerState<SentenceCompletionLevelsScreen> createState() =>
      _SentenceCompletionLevelsScreenState();
}

class _SentenceCompletionLevelsScreenState
    extends ConsumerState<SentenceCompletionLevelsScreen> {
  /// Firebase premium status
  bool _isPremiumRequired = false;

  /// Loading states
  bool _isLoadingFirebase = true;

  /// Ad service
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
    _loadInterstitialAd();
  }

  /// Load premium status from Firebase
  Future<void> _loadPremiumStatus() async {
    await _loadFirebasePremiumStatus();
  }

  /// Load premium status from Firebase
  Future<void> _loadFirebasePremiumStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('practiceSettings')
          .doc('0OmtwQFjUl2yvobi1qxN')
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _isPremiumRequired = data?['isPremium'] ?? false;
          _isLoadingFirebase = false;
        });
      } else {
        setState(() {
          _isPremiumRequired = false;
          _isLoadingFirebase = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading Firebase premium status: $e');
      setState(() {
        _isPremiumRequired = false;
        _isLoadingFirebase = false;
      });
    }
  }

  /// Check if premium features should be locked
  /// Returns true if features should be locked (user needs premium)
  bool _shouldLockPremiumFeatures() {
    // If not on Android platform, don't check RevenueCat
    if (!kIsWeb && !Platform.isAndroid) {
      debugPrint(
          'Not on Android platform, using Firebase isPremium: $_isPremiumRequired');
      return _isPremiumRequired;
    }

    // If Firebase says premium is not required, don't lock
    if (!_isPremiumRequired) {
      debugPrint('Firebase isPremium is false, features unlocked');
      return false;
    }

    // Firebase says premium is required, check RevenueCat subscription
    final hasRevenueCatPremium =
        RevenueCatIntegrationService.instance.isPremium.value;
    debugPrint(
        'Firebase isPremium: $_isPremiumRequired, RevenueCat isPremium: $hasRevenueCatPremium');

    // If user has active subscription, don't lock
    if (hasRevenueCatPremium) {
      debugPrint('User has RevenueCat subscription, features unlocked');
      return false;
    }

    // Firebase requires premium AND user doesn't have subscription = lock features
    debugPrint(
        'Premium required but user has no subscription, features locked');
    return true;
  }

  /// Load interstitial ad
  Future<void> _loadInterstitialAd() async {
    try {
      await _adService.loadInterstitialAd();
      debugPrint('Interstitial ad loaded for sentence completion levels');
    } catch (e) {
      debugPrint('Failed to load interstitial ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Theme colors - Updated to purple/blue theme for better harmony
    final primaryColor =
        const Color(0xFF6C5CE7); // Purple theme for sentence completion
    final backgroundColor =
        isDarkMode ? const Color(0xFF1A1E2E) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF252A3D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2C3550);

    // Get levels data
    final levels = EnhancedSentenceCompletionData.getLevels();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header section with back button
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 10, 20, 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.9),
                  const Color(0xFF5A4FCF),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Cümle Tamamlama Seviyeleri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Eksik kelimeleri doldurarak cümle kurma yeteneğinizi geliştirin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.quiz,
                      label:
                          '${levels.fold(0, (sum, level) => sum + level.totalQuestions)} Soru',
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.timer,
                      label: '90 saniye',
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.school,
                      label: 'Gramer',
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Levels list
          Expanded(
            child: _isLoadingFirebase
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final isLocked = _shouldLockPremiumFeatures() &&
                          index > 0; // First level is always free

                      return _buildLevelCard(
                        level: level,
                        isLocked: isLocked,
                        cardColor: cardColor,
                        textColor: textColor,
                        primaryColor: primaryColor,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build stat chip widget
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build level card widget
  Widget _buildLevelCard({
    required SentenceLevel level,
    required bool isLocked,
    required Color cardColor,
    required Color textColor,
    required Color primaryColor,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLocked
              ? () => _showPremiumDialog()
              : () => _navigateToLevel(level),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Level icon with gradient background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isLocked
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getLevelColors(level.id),
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.quiz_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Level details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              level.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isLocked ? Colors.grey : textColor,
                              ),
                            ),
                          ),
                          if (isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocked
                              ? Colors.grey
                              : textColor.withOpacity(0.7),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSimpleStatChip(
                            icon: Icons.assignment_outlined,
                            label: '${level.exerciseCount} Alıştırma',
                            color: isLocked ? Colors.grey : primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _buildSimpleStatChip(
                            icon: Icons.quiz_outlined,
                            label: '${level.totalQuestions} Soru',
                            color: isLocked ? Colors.grey : primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: isLocked ? Colors.grey : primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get level colors based on level ID
  List<Color> _getLevelColors(int levelId) {
    switch (levelId) {
      case 1:
        return [const Color(0xFF6C5CE7), const Color(0xFF5A4FCF)];
      case 2:
        return [const Color(0xFF74B9FF), const Color(0xFF0984E3)];
      case 3:
        return [const Color(0xFFE17055), const Color(0xFFD63031)];
      default:
        return [const Color(0xFF6C5CE7), const Color(0xFF5A4FCF)];
    }
  }

  /// Build simple stat chip
  Widget _buildSimpleStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to selected level
  Future<void> _navigateToLevel(SentenceLevel level) async {
    try {
      // Show interstitial ad before navigation
      await _adService.showInterstitialAd();
    } catch (e) {
      debugPrint('Failed to show interstitial ad: $e');
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SentenceCompletionGameScreen(
            initialLevel: level.id,
          ),
        ),
      );
    }

    // Load next ad
    _loadInterstitialAd();
  }

  /// Show premium dialog
  void _showPremiumDialog() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF6C5CE7);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
                const Color(0xFF74B9FF).withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Premium Özellik',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              const Text(
                'Bu seviye premium kullanıcılar için özel olarak tasarlanmıştır.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Features
              Column(
                children: [
                  _buildPremiumFeature(
                    icon: Icons.quiz,
                    text: 'Gelişmiş gramer soruları',
                  ),
                  _buildPremiumFeature(
                    icon: Icons.school,
                    text: 'Akademik kelime dağarcığı',
                  ),
                  _buildPremiumFeature(
                    icon: Icons.trending_up,
                    text: 'İleri seviye cümle yapıları',
                  ),
                  _buildPremiumFeature(
                    icon: Icons.psychology,
                    text: 'Deyimler ve kalıp ifadeler',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Kapat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navigate to subscription screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Premium Al',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build premium feature item
  Widget _buildPremiumFeature({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
