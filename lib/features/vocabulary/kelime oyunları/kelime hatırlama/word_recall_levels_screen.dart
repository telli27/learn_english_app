import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../game_enums.dart';
import 'professional_word_recall_screen.dart';

/// Modern Kelime Hatırlama Seviyeleri Ekranı
class WordRecallLevelsScreen extends StatefulWidget {
  const WordRecallLevelsScreen({super.key});

  @override
  State<WordRecallLevelsScreen> createState() => _WordRecallLevelsScreenState();
}

class _WordRecallLevelsScreenState extends State<WordRecallLevelsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Premium status from Firebase
  bool _isPremiumRequired = false;
  bool _isLoadingPremiumStatus = true;

  // Modern seviye tanımları
  List<Map<String, dynamic>> _getLevelOptions(AppLocalizations l10n) {
    return [
      {
        'level': 1,
        'title': l10n.difficulty_easy,
        'subtitle': l10n.basic_words,
        'description': 'Günlük hayatın en temel kelimeleri ile başlayın',
        'exerciseCount': 8,
        'wordCount': 5,
        'icon': Icons.school_outlined,
        'gradientColors': [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        'difficulty': l10n.difficulty_easy,
        'studyTime': '20s',
        'recallTime': '40s',
        'difficultyEnum': DifficultyLevel.beginner,
        'progress': 1.0,
      },
      {
        'level': 2,
        'title': l10n.difficulty_medium,
        'subtitle': l10n.daily_conversation,
        'description':
            'İngilizce öğreniminde en çok kullanılan kelimeleri öğrenin',
        'exerciseCount': 8,
        'wordCount': 5,
        'icon': Icons.trending_up_outlined,
        'gradientColors': [Color(0xFF2196F3), Color(0xFF42A5F5)],
        'difficulty': l10n.difficulty_medium,
        'studyTime': '25s',
        'recallTime': '50s',
        'difficultyEnum': DifficultyLevel.intermediate,
        'progress': 1.0,
      },
      {
        'level': 3,
        'title': l10n.difficulty_hard,
        'subtitle': l10n.academic_words,
        'description':
            'İngilizce öğreniminde en çok gereken kelimeleri keşfedin',
        'exerciseCount': 8,
        'wordCount': 5,
        'icon': Icons.emoji_events_outlined,
        'gradientColors': [Color(0xFFFF9800), Color(0xFFFFB74D)],
        'difficulty': l10n.difficulty_hard,
        'studyTime': '30s',
        'recallTime': '60s',
        'difficultyEnum': DifficultyLevel.advanced,
        'progress': 1.0,
      },
      {
        'level': 4,
        'title': l10n.difficulty_expert,
        'subtitle': l10n.professional_words,
        'description': 'En zorlu kelimelerle kendinizi test edin',
        'exerciseCount': 6,
        'wordCount': 5,
        'icon': Icons.military_tech_outlined,
        'gradientColors': [Color(0xFFE91E63), Color(0xFFF06292)],
        'difficulty': l10n.difficulty_expert,
        'studyTime': '35s',
        'recallTime': '70s',
        'difficultyEnum': DifficultyLevel.expert,
        'progress': 1.0,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();

    // Fetch premium status from Firebase
    _fetchPremiumStatus();
  }

  /// Fetch premium requirement status from Firebase
  Future<void> _fetchPremiumStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('practiceSettings')
          .doc('0OmtwQFjUl2yvobi1qxN')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _isPremiumRequired = data['isPremium'] ?? false;
          _isLoadingPremiumStatus = false;
        });
      } else {
        setState(() {
          _isPremiumRequired = false;
          _isLoadingPremiumStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching premium status: $e');
      setState(() {
        _isPremiumRequired = false;
        _isLoadingPremiumStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildModernHeader(),
              Expanded(
                child: _buildLevelsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Kelime Oyunu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Main title
          Text(
            AppLocalizations.of(context)!.level_select,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.choose_level,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsList() {
    // Show loading indicator while fetching premium status
    if (_isLoadingPremiumStatus) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                children: [
                  // Levels - İlerleme durumu kartını kaldırdık
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _getLevelOptions(AppLocalizations.of(context)!)
                          .length,
                      itemBuilder: (context, index) {
                        final levels =
                            _getLevelOptions(AppLocalizations.of(context)!);
                        return Transform.translate(
                          offset: Offset(0,
                              (1 - _fadeAnimation.value.clamp(0.0, 1.0)) * 50),
                          child: _buildModernLevelCard(
                            levels[index],
                            index,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernLevelCard(Map<String, dynamic> level, int index) {
    final gradientColors = level['gradientColors'] as List<Color>;
    final progress = level['progress'] as double;

    // Updated locking logic: use the new premium check method
    final isLocked = _shouldLockPremiumFeatures() && index > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap:
              isLocked ? () => _showPremiumDialog() : () => _launchLevel(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isLocked
                  ? LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    )
                  : LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.grey.withOpacity(0.3)
                      : gradientColors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isLocked
                            ? Icons.workspace_premium
                            : level['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            level['subtitle'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLocked) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          level['difficulty'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  isLocked
                      ? 'Bu seviye premium üyelik gerektirir. Tıklayarak premium olun!'
                      : level['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                if (!isLocked) ...[
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.assignment_outlined,
                        '${level['exerciseCount']} ${AppLocalizations.of(context)!.exercises}',
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        Icons.book_outlined,
                        '${level['wordCount']} Kelime',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Time info
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Çalışma: ${level['studyTime']} • Hatırlama: ${level['recallTime']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
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

  void _launchLevel(Map<String, dynamic> level) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfessionalWordRecallScreen(
          difficulty: level['difficultyEnum'] as DifficultyLevel,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Show premium subscription dialog
  void _showPremiumDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 32,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFFf093fb),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
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
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
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
                    'Premium Üyelik Gerekli',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Tüm seviyelere erişim için premium üyeliğe ihtiyacınız var. Premium ile sınırsız kelime öğrenin!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 17,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Premium features
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildPremiumFeature(
                          Icons.lock_open,
                          'Tüm Seviyelere Erişim',
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumFeature(
                          Icons.psychology,
                          'Sınırsız Kelime Çalışması',
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumFeature(
                          Icons.trending_up,
                          'Gelişmiş İstatistikler',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                          child: TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Daha Sonra',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Premium button
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              // Navigate to premium purchase screen
                              await RevenueCatIntegrationService.instance
                                  .goToSubscriptionPage(context);
                            },
                            icon: const Icon(
                              Icons.star,
                              color: Color(0xFF667eea),
                              size: 20,
                            ),
                            label: const Text(
                              'Premium Al',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
      },
    );
  }

  Widget _buildPremiumFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
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
}
