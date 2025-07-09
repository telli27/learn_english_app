import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math' as math;

import '../game_enums.dart';
import 'sentence_building_models.dart';
import 'sentence_building_data.dart';
import 'sentence_building_game_screen.dart';
import '../../../../core/services/ad_service.dart';

class SentenceBuildingLevelsScreen extends ConsumerStatefulWidget {
  const SentenceBuildingLevelsScreen({super.key});

  @override
  ConsumerState<SentenceBuildingLevelsScreen> createState() =>
      _SentenceBuildingLevelsScreenState();
}

class _SentenceBuildingLevelsScreenState
    extends ConsumerState<SentenceBuildingLevelsScreen>
    with TickerProviderStateMixin {
  bool _isPremiumRequired = false;

  bool _isLoadingFirebase = true;

  final AdService _adService = AdService();

  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
    _loadInterstitialAd();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutCubic,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsAnimationController.forward();
    });
  }

  Future<void> _loadPremiumStatus() async {
    await _loadFirebasePremiumStatus();
  }

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

  bool _shouldLockPremiumFeatures() {
    if (!kIsWeb && !Platform.isAndroid) {
      debugPrint(
          'Not on Android platform, using Firebase isPremium: $_isPremiumRequired');
      return _isPremiumRequired;
    }

    if (!_isPremiumRequired) {
      debugPrint('Firebase isPremium is false, features unlocked');
      return false;
    }

    final hasRevenueCatPremium =
        RevenueCatIntegrationService.instance.isPremium.value;
    debugPrint(
        'Firebase isPremium: $_isPremiumRequired, RevenueCat isPremium: $hasRevenueCatPremium');

    if (hasRevenueCatPremium) {
      debugPrint('User has RevenueCat subscription, features unlocked');
      return false;
    }

    debugPrint(
        'Premium required but user has no subscription, features locked');
    return true;
  }

  Future<void> _loadInterstitialAd() async {
    try {
      await _adService.loadInterstitialAd();
      debugPrint('Interstitial ad loaded for sentence building levels');
    } catch (e) {
      debugPrint('Failed to load interstitial ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryColor = const Color(0xFF8B5CF6);
    final secondaryColor = const Color(0xFF7C3AED);
    final accentColor = const Color(0xFF6366F1);
    final backgroundColor =
        isDarkMode ? const Color(0xFF0F0F23) : const Color(0xFFF8FAFC);

    final repository =
        SentenceBuildingDataRepository(AppLocalizations.of(context)!);
    final levels = repository.getAllLevels();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Enhanced animated header
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - _headerAnimation.value)),
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: _buildEnhancedHeader(primaryColor, secondaryColor,
                        accentColor, levels, isDarkMode),
                  ),
                );
              },
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: AnimatedBuilder(
              animation: _cardsAnimation,
              builder: (context, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final level = levels[index];
                      final delay = index * 0.1;
                      final animationValue = math.max(0.0,
                          math.min(1.0, (_cardsAnimation.value - delay) / 0.3));

                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - animationValue)),
                        child: Opacity(
                          opacity: animationValue,
                          child: _buildEnhancedLevelCard(
                            level: level,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            accentColor: accentColor,
                            isDarkMode: isDarkMode,
                            index: index,
                          ),
                        ),
                      );
                    },
                    childCount: levels.length,
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(
    Color primaryColor,
    Color secondaryColor,
    Color accentColor,
    List<SentenceBuildingLevel> levels,
    bool isDarkMode,
  ) {
    final totalExercises =
        levels.fold(0, (sum, level) => sum + level.exercises.length);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
            accentColor,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GeometricPatternPainter(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.sentence_building,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .word_matching_levels,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Gramer Becerilerinizi Geliştirin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Verilen kelimelerden doğru cümle kurarak İngilizce gramer bilginizi pekiştirin ve dil becerilerinizi geliştirin.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedStatChip(
                          icon: Icons.layers,
                          label: '${levels.length} Seviye',
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedStatChip(
                          icon: Icons.quiz,
                          label:
                              '$totalExercises ${AppLocalizations.of(context)!.exercises}',
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedStatChip(
                          icon: Icons.school,
                          label: 'Gramer',
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLevelCard({
    required SentenceBuildingLevel level,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
    required bool isDarkMode,
    required int index,
  }) {
    final isLocked = _shouldLockPremiumFeatures() && level.id != 'level_1';

    final cardColor = isDarkMode ? const Color(0xFF1A1D29) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isLocked ? Colors.grey : primaryColor).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: isLocked
              ? _showEnhancedPremiumDialog
              : () => _navigateToLevel(level),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLocked
                    ? Colors.grey.withOpacity(0.3)
                    : primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                if (!isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            primaryColor.withOpacity(0.05),
                            secondaryColor.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isLocked
                                    ? [
                                        Colors.grey.shade400,
                                        Colors.grey.shade600
                                      ]
                                    : [primaryColor, secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isLocked ? Colors.grey : primaryColor)
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    isLocked ? Icons.lock : Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                if (!isLocked)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          level.id,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
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
                                          color: textColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    if (isLocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B35),
                                              Color(0xFFFF8E53)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                const SizedBox(height: 8),
                                Text(
                                  level.description,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(level.difficulty)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getDifficultyColor(level.difficulty)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getDifficultyText(level.difficulty),
                              style: TextStyle(
                                color: _getDifficultyColor(level.difficulty),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedStatItem(
                                icon: Icons.quiz,
                                label: AppLocalizations.of(context)!.exercises,
                                value: '${level.exercises.length}',
                                color: primaryColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade300,
                            ),
                            Expanded(
                              child: _buildEnhancedStatItem(
                                icon: Icons.timer,
                                label: 'Süre',
                                value: '45-75s',
                                color: accentColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade300,
                            ),
                            Expanded(
                              child: _buildEnhancedStatItem(
                                icon: Icons.school,
                                label: 'Kategori',
                                value: 'Gramer',
                                color: secondaryColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isLocked
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade500
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [primaryColor, secondaryColor],
                                ),
                          boxShadow: [
                            if (!isLocked)
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: isLocked
                                ? _showEnhancedPremiumDialog
                                : () => _navigateToLevel(level),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isLocked ? Icons.lock : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isLocked
                                        ? 'Premium Gerekli'
                                        : 'Seviyeyi Başlat',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (!isLocked) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white60 : Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return const Color(0xFF10B981);
      case DifficultyLevel.intermediate:
        return const Color(0xFFF59E0B);
      case DifficultyLevel.advanced:
        return const Color(0xFFEF4444);
      case DifficultyLevel.expert:
        return const Color(0xFF8B5CF6);
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Başlangıç';
      case DifficultyLevel.intermediate:
        return 'Orta';
      case DifficultyLevel.advanced:
        return 'İleri';
      case DifficultyLevel.expert:
        return 'Uzman';
    }
  }

  void _navigateToLevel(SentenceBuildingLevel level) async {
    try {
      await _adService.showInterstitialAd();
      debugPrint(
          'Interstitial ad shown for sentence building level ${level.id}');
    } catch (e) {
      debugPrint('Failed to show interstitial ad: $e');
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SentenceBuildingGameScreen(levelId: level.id),
        ),
      );
    }
  }

  void _showEnhancedPremiumDialog() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF8B5CF6);
    final dialogBgColor = isDarkMode ? const Color(0xFF1A1D29) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: dialogBgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Premium Özellik',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bu seviye premium kullanıcılar için ayrılmıştır. Premium üyelik satın alarak tüm seviyelere erişim sağlayabilirsiniz.',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDarkMode ? Colors.white70 : Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, const Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Navigate to premium purchase screen
                          await RevenueCatIntegrationService.instance
                              .goToSubscriptionPage(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Premium Al',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
}

class _GeometricPatternPainter extends CustomPainter {
  final Color color;

  _GeometricPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 30.0) % size.height;

      if (i % 3 == 0) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      } else if (i % 3 == 1) {
        canvas.drawRect(Rect.fromLTWH(x, y, 6, 6), paint);
      } else {
        final path = Path();
        path.moveTo(x, y);
        path.lineTo(x + 6, y + 6);
        path.lineTo(x - 6, y + 6);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
