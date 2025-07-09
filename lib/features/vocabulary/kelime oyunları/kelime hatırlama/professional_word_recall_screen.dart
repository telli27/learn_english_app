import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';
import '../game_enums.dart';
import '../game_models.dart';
import '../game_audio_service.dart';

import '../../../../core/providers.dart';
import 'professional_word_recall_controller.dart';
import 'professional_game_data.dart';
import '../../../../core/services/ad_service.dart';

/// Professional Word Recall Game Screen with modern design
class ProfessionalWordRecallScreen extends ConsumerStatefulWidget {
  final DifficultyLevel difficulty;

  const ProfessionalWordRecallScreen({
    super.key,
    required this.difficulty,
  });

  @override
  ConsumerState<ProfessionalWordRecallScreen> createState() =>
      _ProfessionalWordRecallScreenState();
}

class _ProfessionalWordRecallScreenState
    extends ConsumerState<ProfessionalWordRecallScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Confetti controller
  late ConfettiController _confettiController;

  // Text controllers
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  // Ad service instance
  final AdService _adService = AdService();

  // Ad state tracking
  bool _isShowingAd = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Load interstitial ad when screen initializes
    _loadInterstitialAdForGame();
    ref.read(adServiceProvider).loadBannerAd();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start initial animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params =
        (difficulty: widget.difficulty, l10n: AppLocalizations.of(context)!);
    final gameState =
        ref.watch(professionalWordRecallControllerProvider(params));
    final controller =
        ref.read(professionalWordRecallControllerProvider(params).notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(widget.difficulty.colorValue),
              Color(widget.difficulty.colorValue).withOpacity(0.8),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background pattern
              _buildBackgroundPattern(),

              // Main content
              Column(
                children: [
                  _buildHeader(gameState, controller),
                  Expanded(
                    child: _buildGameContent(gameState, controller),
                  ),
                  if (RevenueCatIntegrationService.instance.isPremium.value ==
                      false)
                    Consumer(
                      builder: (context, ref, child) {
                        final adService = ref.watch(adServiceProvider);
                        final bannerAd = adService.getBannerAdWidget();
                        if (bannerAd != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: bannerAd,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),

              // Confetti overlay
              _buildConfettiOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPatternPainter(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildHeader(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top row with back button and settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(
                          context), // Direct navigation without ad
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Row(
                      children: [
                        // Exercise selection menu
                        IconButton(
                          onPressed: () => _showExerciseDialog(
                              context, gameState, controller),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.list,
                                color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${gameState.currentExercise.title}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${gameState.currentWords.length} ${AppLocalizations.of(context)!.words_count} • ${widget.difficulty.displayName}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Only show pause button during active phases, otherwise show completion icon
                    if (gameState.phase == RecallGamePhase.study ||
                        gameState.phase == RecallGamePhase.recall)
                      IconButton(
                        onPressed: () => controller.togglePause(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            gameState.isPaused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      // Show completion icon for review/complete phases
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Game info cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: gameState.phase == RecallGamePhase.review ||
                                gameState.phase == RecallGamePhase.complete
                            ? Icons.assessment
                            : Icons.psychology,
                        label: gameState.phase == RecallGamePhase.review ||
                                gameState.phase == RecallGamePhase.complete
                            ? AppLocalizations.of(context)!.evaluation
                            : gameState.phase.displayName,
                        value: gameState.phase == RecallGamePhase.review ||
                                gameState.phase == RecallGamePhase.complete
                            ? AppLocalizations.of(context)!.completed
                            : _getPhaseProgress(gameState),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: gameState.phase == RecallGamePhase.review ||
                                gameState.phase == RecallGamePhase.complete
                            ? Icons.percent
                            : Icons.timer,
                        label: gameState.phase == RecallGamePhase.review ||
                                gameState.phase == RecallGamePhase.complete
                            ? AppLocalizations.of(context)!.accuracy
                            : AppLocalizations.of(context)!.time,
                        value: gameState.phase == RecallGamePhase.review ||
                                gameState.phase == RecallGamePhase.complete
                            ? '${(gameState.accuracy * 100).toInt()}%'
                            : '${gameState.timeLeft}s',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.star,
                        label: AppLocalizations.of(context)!.score,
                        value: '${gameState.score}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar
                _buildProgressBar(gameState),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(RecallGameState gameState) {
    final progress = _calculateOverallProgress(gameState);

    // Daha açıklayıcı progress metni
    String progressText = '';
    switch (gameState.phase) {
      case RecallGamePhase.preparation:
        progressText = context.mounted
            ? AppLocalizations.of(context)!.preparing
            : 'Preparing...';
        break;
      case RecallGamePhase.study:
        progressText = AppLocalizations.of(context)!.word_study_phase;
        break;
      case RecallGamePhase.transition:
        progressText = AppLocalizations.of(context)!.recall_phase_starting;
        break;
      case RecallGamePhase.recall:
        progressText = AppLocalizations.of(context)!.word_recall_phase;
        break;
      case RecallGamePhase.review:
        progressText = AppLocalizations.of(context)!.results_ready;
        break;
      case RecallGamePhase.complete:
        progressText = AppLocalizations.of(context)!.completed;
        break;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progressText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildGameContent(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    // Don't show game content if ad is showing
    if (_isShowingAd) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.ad_loading,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: _buildPhaseContent(gameState, controller),
          ),
        );
      },
    );
  }

  Widget _buildPhaseContent(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    switch (gameState.phase) {
      case RecallGamePhase.preparation:
        return _buildPreparationPhase(gameState);
      case RecallGamePhase.study:
        return _buildStudyPhase(gameState, controller);
      case RecallGamePhase.transition:
        return _buildTransitionPhase(gameState);
      case RecallGamePhase.recall:
        return _buildRecallPhase(gameState, controller);
      case RecallGamePhase.review:
        return _buildReviewPhase(gameState, controller);
      case RecallGamePhase.complete:
        return _buildCompletePhase(gameState, controller);
    }
  }

  Widget _buildPreparationPhase(RecallGameState gameState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 60,
                    color: Color(widget.difficulty.colorValue),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            AppLocalizations.of(context)!.preparing,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${gameState.currentWords.length} ${AppLocalizations.of(context)!.words_to_study}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyPhase(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    return Stack(
      children: [
        Column(
          children: [
            // Compact phase header - daha küçük ve göze batmayan
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.review_words_instruction,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Compact words grid
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                    bottom: 120, top: 5), // More bottom padding for FAB
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      1.1, // Further reduced to make cards much taller
                  crossAxisSpacing: 10,
                  mainAxisSpacing:
                      12, // Increased spacing for better visibility
                ),
                itemCount: gameState.currentWords.length,
                itemBuilder: (context, index) {
                  final word = gameState.currentWords[index];
                  return _buildCompactStudyWordCard(word, index);
                },
              ),
            ),
          ],
        ),

        // Compact floating skip button - sağ altta küçük
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => controller.forceRecallPhase(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: 16,
                    color: Color(widget.difficulty.colorValue),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.ready,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(widget.difficulty.colorValue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Yeni kompakt kelime kartı widget'ı
  Widget _buildCompactStudyWordCard(VocabularyWord word, int index) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(widget.difficulty.colorValue).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Colorful top section
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40, // Increased height for better visibility
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(widget.difficulty.colorValue),
                            Color(widget.difficulty.colorValue)
                                .withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            top: -10,
                            right: -10,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: -8,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Index number
                          Positioned(
                            top: 8,
                            left: 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
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
                  ),

                  // Main content area
                  Positioned(
                    top: 40, // Adjusted to match new top section height
                    left: 0,
                    right: 0,
                    bottom: 5, // Leave space for bottom accent line
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8), // Better padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // Better distribution
                        children: [
                          // English word with special styling
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6), // More padding
                            decoration: BoxDecoration(
                              color: Color(widget.difficulty.colorValue)
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(widget.difficulty.colorValue)
                                    .withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              word.english,
                              style: TextStyle(
                                fontSize: 14, // Increased font size
                                fontWeight: FontWeight.w800,
                                color: Color(widget.difficulty.colorValue),
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Decorative arrow
                          Icon(
                            Icons.keyboard_double_arrow_down_rounded,
                            color: Colors.grey[400],
                            size: 14,
                          ),

                          // Turkish translation with container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              word.turkish,
                              style: const TextStyle(
                                fontSize: 12, // Increased font size
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3, // Allow more lines
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom accent line
                  Positioned(
                    bottom: 0,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(widget.difficulty.colorValue)
                                .withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransitionPhase(RecallGameState gameState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 60,
                    color: Color(widget.difficulty.colorValue),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            AppLocalizations.of(context)!.recall_phase_title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${gameState.timeLeft} ${AppLocalizations.of(context)!.seconds_remaining}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecallPhase(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    final currentWord = gameState.currentWords[gameState.currentWordIndex];
    final progress =
        (gameState.currentWordIndex + 1) / gameState.currentWords.length;

    return SingleChildScrollView(
      // Make the entire phase scrollable
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator with word count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${gameState.currentWordIndex + 1} / ${gameState.currentWords.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context)!.correct}: ${gameState.correctWords.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20), // Reduced spacing

          // Enhanced word card with clean design
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20), // Reduced padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(widget.difficulty.colorValue)
                            .withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 5),
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // English word with beautiful typography
                      Text(
                        currentWord.english,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(widget.difficulty.colorValue),
                          letterSpacing: 1.0,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12), // Reduced spacing

                      // Hint section with improved design (only if hint is shown)
                      if (gameState.showHint) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12), // Reduced padding
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withOpacity(0.1),
                                Colors.orange.withOpacity(0.05),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(12), // Reduced radius
                            border: Border.all(
                                color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(4), // Reduced padding
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber[700],
                                  size: 16, // Reduced size
                                ),
                              ),
                              const SizedBox(width: 8), // Reduced spacing
                              Expanded(
                                child: Text(
                                  currentWord.hint,
                                  style: TextStyle(
                                    fontSize: 12, // Reduced font size
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20), // Reduced spacing

          // Enhanced input field
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              onChanged: controller.updateInput,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.submitAnswer(value);
                  _inputController.clear();
                }
              },
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)!.enter_turkish_equivalent,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(widget.difficulty.colorValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Color(widget.difficulty.colorValue),
                    size: 18,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16), // Reduced spacing

          // Enhanced action buttons
          Column(
            children: [
              // Submit button (primary action)
              Container(
                width: double.infinity,
                height: 52, // Reduced height
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(widget.difficulty.colorValue),
                      Color(widget.difficulty.colorValue).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color(widget.difficulty.colorValue).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_inputController.text.trim().isNotEmpty) {
                      controller.submitAnswer(_inputController.text);
                      _inputController.clear();
                    }
                  },
                  icon:
                      const Icon(Icons.send_rounded, size: 20), // Reduced size
                  label: Text(
                    AppLocalizations.of(context)!.submit_answer,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15, // Reduced font size
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12), // Reduced spacing

              // Secondary action buttons
              Row(
                children: [
                  // Hint button
                  Expanded(
                    child: Container(
                      height: 44, // Reduced height
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => controller.showHint(),
                        icon: Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 16, // Reduced size
                          color: Colors.amber[700],
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.get_hint,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13, // Reduced font size
                            color: Colors.amber[700],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Skip button
                  Expanded(
                    child: Container(
                      height: 44, // Reduced height
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey[400]!,
                          width: 1.5,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => controller.skipCurrentWord(),
                        icon: Icon(
                          Icons.skip_next_rounded,
                          size: 16, // Reduced size
                          color: Colors.grey[600],
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.skip_word,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13, // Reduced font size
                            color: Colors.grey[600],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20), // Bottom spacing for scroll
        ],
      ),
    );
  }

  Widget _buildReviewPhase(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    final accuracy = gameState.accuracy;
    final result = GameResult.fromScore(accuracy * 100);

    // Trigger confetti for good results
    if (accuracy >= 0.7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }

    // Choose colors and content based on performance
    Color primaryColor;
    Color accentColor;
    IconData resultIcon;
    String motivationText;
    String subtitleText;

    if (accuracy >= 0.9) {
      primaryColor = Colors.amber[600]!;
      accentColor = Colors.amber[100]!;
      resultIcon = Icons.emoji_events_rounded;
      motivationText = AppLocalizations.of(context)!.excellent;
      subtitleText = AppLocalizations.of(context)!.great_performance;
    } else if (accuracy >= 0.7) {
      primaryColor = Colors.green[600]!;
      accentColor = Colors.green[100]!;
      resultIcon = Icons.thumb_up_rounded;
      motivationText = AppLocalizations.of(context)!.very_good;
      subtitleText = AppLocalizations.of(context)!.successful_study;
    } else if (accuracy >= 0.5) {
      primaryColor = Colors.blue[600]!;
      accentColor = Colors.blue[100]!;
      resultIcon = Icons.trending_up_rounded;
      motivationText = AppLocalizations.of(context)!.good_progress;
      subtitleText = AppLocalizations.of(context)!.showing_improvement;
    } else {
      primaryColor = Colors.orange[600]!;
      accentColor = Colors.orange[100]!;
      resultIcon = Icons.psychology_rounded;
      motivationText = AppLocalizations.of(context)!.keep_studying;
      subtitleText = AppLocalizations.of(context)!.every_study_helps;
    }

    return Column(
      children: [
        // Main scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hero result card - Main results display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        accentColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Animated icon
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                resultIcon,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        motivationText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        subtitleText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Score and accuracy in a row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildResultStat(
                            'Doğruluk',
                            '${(accuracy * 100).toInt()}%',
                            primaryColor,
                          ),
                          _buildResultStat(
                            'Puan',
                            '${gameState.score}',
                            Color(widget.difficulty.colorValue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick stats row - Always show performance summary
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatCard(
                        AppLocalizations.of(context)!.correct,
                        '${gameState.correctWords.length}',
                        Colors.green,
                        Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStatCard(
                        AppLocalizations.of(context)!.incorrect,
                        '${gameState.incorrectWords.length}',
                        Colors.red,
                        Icons.cancel_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStatCard(
                        AppLocalizations.of(context)!.skip,
                        '${gameState.skippedWords.length}',
                        Colors.orange,
                        Icons.skip_next_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Show correct answers section if there are any
                if (gameState.correctWords.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.correct_answers,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.green[700],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Text(
                                '${gameState.correctWords.length}/${gameState.currentWords.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Show first 3 correct words
                        ...gameState.correctWords.take(3).map(
                            (word) => _buildCorrectWordItem(word, controller)),

                        // Show remaining count if more words exist
                        if (gameState.correctWords.length > 3) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.more_horiz,
                                    color: Colors.green[600]),
                                const SizedBox(width: 8),
                                Text(
                                  '+${gameState.correctWords.length - 3} ${AppLocalizations.of(context)!.more_correct_answers}',
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Words to review section - Only if there are words to review
                if (gameState.incorrectWords.isNotEmpty ||
                    gameState.skippedWords.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.replay_rounded,
                              color: Colors.orange[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.words_to_review,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Show incorrect words with user answers
                        ...gameState.incorrectWords
                            .take(3)
                            .map((word) => _buildDetailedWordReviewItem(
                                  word,
                                  AppLocalizations.of(context)!.incorrect,
                                  Colors.red,
                                  Icons.close_rounded,
                                  controller,
                                )),

                        // Show skipped words
                        ...gameState.skippedWords.take(3).map((word) =>
                            _buildWordReviewItem(
                                word,
                                AppLocalizations.of(context)!.skip,
                                Colors.orange,
                                Icons.skip_next_rounded)),

                        // Show remaining count if more words exist
                        if ((gameState.incorrectWords.length +
                                gameState.skippedWords.length) >
                            6) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.more_horiz, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  '+${(gameState.incorrectWords.length + gameState.skippedWords.length) - 6} ${AppLocalizations.of(context)!.more_words}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Performance insights - Always show
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(widget.difficulty.colorValue).withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          Color(widget.difficulty.colorValue).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            color: Color(widget.difficulty.colorValue),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!
                                .learning_recommendations,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(widget.difficulty.colorValue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInsightRow(
                        accuracy >= 0.7 ? Icons.trending_up : Icons.lightbulb,
                        accuracy >= 0.7 ? Colors.green : Colors.orange,
                        accuracy >= 0.7
                            ? AppLocalizations.of(context)!.great_progress_msg
                            : AppLocalizations.of(context)!.regular_study_helps,
                      ),
                      const SizedBox(height: 12),
                      _buildInsightRow(
                        Icons.schedule,
                        Colors.purple,
                        AppLocalizations.of(context)!.daily_15_minutes,
                      ),
                      if (gameState.incorrectWords.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInsightRow(
                          Icons.replay,
                          Colors.blue,
                          AppLocalizations.of(context)!.repeat_incorrect_words,
                        ),
                      ],
                    ],
                  ),
                ),

                // Add some bottom padding for the fixed buttons
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Fixed bottom buttons
        Container(
          padding: const EdgeInsets.all(20), // Reduced from 24
          decoration: BoxDecoration(
            // Removed the problematic white gradient background
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern floating action buttons
              Row(
                children: [
                  // Home button - Floating circular design
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(
                          context), // Direct navigation without ad
                      child: Container(
                        height: 56, // Reduced from 64
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28), // Adjusted
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15, // Reduced
                              offset: const Offset(0, 6), // Reduced
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32, // Reduced from 40
                              height: 32, // Reduced from 40
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.home_rounded,
                                color: Colors.blue[600],
                                size: 18, // Reduced from 20
                              ),
                            ),
                            const SizedBox(width: 8), // Reduced from 12
                            Text(
                              'Ana Menü',
                              style: TextStyle(
                                fontSize: 13, // Reduced from 15
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12), // Reduced from 16

                  // Continue button - Premium gradient design
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _showAdAndMoveToNext(controller),
                      child: Container(
                        height: 56, // Reduced from 64
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                              Color.lerp(primaryColor, Colors.purple, 0.2)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28), // Adjusted
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 15, // Reduced from 20
                              offset: const Offset(0, 6), // Reduced from 8
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Animated background pattern
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Content
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30, // Reduced from 36
                                    height: 30, // Reduced from 36
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 16, // Reduced from 18
                                    ),
                                  ),
                                  const SizedBox(width: 8), // Reduced from 12
                                  const Text(
                                    'Devam Et',
                                    style: TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
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
                ],
              ),

              const SizedBox(height: 12), // Reduced from 16

              // Progress indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5, // Reduced from 6
                    height: 5, // Reduced from 6
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6), // Reduced from 8
                  Container(
                    width: 16, // Reduced from 20
                    height: 5, // Reduced from 6
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2.5), // Adjusted
                    ),
                  ),
                  const SizedBox(width: 6), // Reduced from 8
                  Container(
                    width: 5, // Reduced from 6
                    height: 5, // Reduced from 6
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordReviewItem(
      VocabularyWord word, String status, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.english,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  word.turkish,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedWordReviewItem(VocabularyWord word, String status,
      Color color, IconData icon, ProfessionalWordRecallController controller) {
    // Get user's actual answer from controller
    final attempt = controller.getAttemptForWord(word.id);
    String userAnswer = AppLocalizations.of(context)!.no_answer_provided;

    if (attempt != null) {
      if (attempt.wasSkipped) {
        userAnswer = AppLocalizations.of(context)!.skip;
      } else if (attempt.userInput.isNotEmpty) {
        userAnswer = attempt.userInput;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  word.english,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // User's answer vs correct answer comparison
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // User's answer
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.red[600],
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.user_answer,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userAnswer,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                          fontStyle: userAnswer ==
                                      AppLocalizations.of(context)!
                                          .no_answer_provided ||
                                  userAnswer ==
                                      AppLocalizations.of(context)!.skip
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Correct answer
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.correct_answer_label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        word.turkish,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),

                // Show hint usage if applicable
                if (attempt?.usedHint == true) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.lightbulb,
                          color: Colors.amber[600],
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.hint_used_label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletePhase(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // Reduced padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20), // Add top spacing

          // Animated celebration icon - smaller
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80, // Reduced size
                  height: 80, // Reduced size
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber[400]!,
                        Colors.orange[500]!,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 15, // Reduced blur
                        offset: const Offset(0, 5), // Reduced offset
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 40, // Reduced icon size
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20), // Reduced spacing

          // Title with beautiful typography - smaller
          Text(
            AppLocalizations.of(context)!.exercise_completed_title,
            style: TextStyle(
              fontSize: 22, // Reduced font size
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3, // Reduced letter spacing
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12), // Reduced spacing

          // Score display - smaller
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16), // Reduced radius
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              '${AppLocalizations.of(context)!.total_score}: ${gameState.score}',
              style: const TextStyle(
                fontSize: 16, // Reduced font size
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 30), // Reduced spacing

          // Modern action buttons with conditional logic
          Builder(
            builder: (context) {
              // Check if this is the last exercise
              final isLastExercise = gameState.currentExercise.order >=
                  gameState.currentLevel.exerciseCount;

              return Column(
                children: [
                  if (isLastExercise) ...[
                    // Single button for last exercise - Level Complete
                    Container(
                      width: double.infinity,
                      height: 48, // Reduced height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[100]!],
                        ),
                        borderRadius:
                            BorderRadius.circular(14), // Reduced radius
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 10, // Reduced blur
                            offset: const Offset(0, 4), // Reduced offset
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(
                            context), // Direct navigation without ad
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Color(widget.difficulty.colorValue),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.emoji_events_rounded, size: 18),
                        label: Text(
                          AppLocalizations.of(context)!.level_completed_title,
                          style: TextStyle(
                            fontSize: 13, // Reduced font size
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2, // Reduced letter spacing
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // Reduced spacing
                    // Secondary button for main menu
                    Container(
                      width: double.infinity,
                      height: 40, // Reduced height
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(12), // Reduced radius
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(
                            context), // Direct navigation without ad
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.home_rounded, size: 16),
                        label: Text(
                          AppLocalizations.of(context)!.return_to_main_menu,
                          style: TextStyle(
                            fontSize: 12, // Reduced font size
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Two buttons for non-last exercises
                    Row(
                      children: [
                        // Main menu button
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 44, // Reduced height
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(
                                  context), // Direct navigation without ad
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home_rounded, size: 14),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!.main_menu,
                                      style: TextStyle(
                                        fontSize: 11, // Reduced font size
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Next exercise button
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 44, // Reduced height
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey[100]!],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _showAdAndMoveToNext(controller),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor:
                                    Color(widget.difficulty.colorValue),
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_forward_rounded, size: 14),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .next_exercise,
                                      style: TextStyle(
                                        fontSize: 11, // Reduced font size
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 20), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildConfettiOverlay() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: math.pi / 2,
        emissionFrequency: 0.05,
        numberOfParticles: 30,
        gravity: 0.1,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.pink,
          Colors.yellow,
        ],
      ),
    );
  }

  String _getPhaseProgress(RecallGameState gameState) {
    switch (gameState.phase) {
      case RecallGamePhase.preparation:
        return context.mounted
            ? AppLocalizations.of(context)!.preparing
            : 'Preparing...';
      case RecallGamePhase.study:
        return context.mounted
            ? AppLocalizations.of(context)!.study_status
            : 'Study';
      case RecallGamePhase.transition:
        return context.mounted
            ? AppLocalizations.of(context)!.transition_phase
            : 'Transition';
      case RecallGamePhase.recall:
        return '${gameState.currentWordIndex + 1}/${gameState.currentWords.length}';
      case RecallGamePhase.review:
        return context.mounted
            ? AppLocalizations.of(context)!.evaluation
            : 'Review';
      case RecallGamePhase.complete:
        return context.mounted
            ? AppLocalizations.of(context)!.completed
            : 'Complete';
    }
  }

  double _calculateOverallProgress(RecallGameState gameState) {
    switch (gameState.phase) {
      case RecallGamePhase.preparation:
        return 0.1;
      case RecallGamePhase.study:
        final studyProgress = gameState.currentExercise.studyTimeSeconds > 0
            ? (gameState.currentExercise.studyTimeSeconds -
                    gameState.timeLeft) /
                gameState.currentExercise.studyTimeSeconds
            : 1.0;
        return 0.1 + (studyProgress * 0.3);
      case RecallGamePhase.transition:
        return 0.4;
      case RecallGamePhase.recall:
        final recallProgress = gameState.currentWords.isNotEmpty
            ? gameState.currentWordIndex / gameState.currentWords.length
            : 0.0;
        return 0.4 + (recallProgress * 0.4);
      case RecallGamePhase.review:
        return 0.9;
      case RecallGamePhase.complete:
        return 1.0;
    }
  }

  /// Show exercise selection dialog
  void _showExerciseDialog(BuildContext context, RecallGameState gameState,
      ProfessionalWordRecallController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Color(widget.difficulty.colorValue).withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(widget.difficulty.colorValue)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.list,
                        color: Color(widget.difficulty.colorValue),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.select_exercise,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Scrollable exercise list
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: gameState.currentLevel.exercises
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final exercise = entry.value;
                        final isCurrentExercise =
                            exercise.id == gameState.currentExercise.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: isCurrentExercise
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _changeExercise(controller, index);
                                    },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCurrentExercise
                                      ? Color(widget.difficulty.colorValue)
                                          .withOpacity(0.1)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrentExercise
                                        ? Color(widget.difficulty.colorValue)
                                            .withOpacity(0.2)
                                        : Colors.grey[300]!,
                                    width: isCurrentExercise ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isCurrentExercise
                                            ? Color(widget
                                                    .difficulty.colorValue)
                                                .withOpacity(0.1)
                                            : Colors.grey[400],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isCurrentExercise
                                                  ? Color(widget
                                                      .difficulty.colorValue)
                                                  : const Color(0xFF1E293B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${exercise.words.length} kelime',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isCurrentExercise) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Color(
                                              widget.difficulty.colorValue),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.active,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey[400],
                                        size: 14,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Change to a different exercise
  Future<void> _changeExercise(
      ProfessionalWordRecallController controller, int exerciseIndex) async {
    // Show ad before changing exercise
    if (_isShowingAd) return; // Prevent multiple ad calls

    _isShowingAd = true;
    try {
      debugPrint(
          'Starting to show game interstitial ad before exercise change...');
      await _adService.showInterstitialAdPlayGame();
      debugPrint('Game interstitial ad completed before exercise change');
    } catch (e) {
      debugPrint('Failed to show game interstitial ad: $e');
    } finally {
      _isShowingAd = false;

      // Change exercise only after ad is fully completed
      controller.changeToExercise(exerciseIndex);

      // Load next ad for the new exercise
      _loadInterstitialAdForGame();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.exercise_info} ${exerciseIndex + 1} ${AppLocalizations.of(context)!.exercise_started}'),
          backgroundColor: Color(widget.difficulty.colorValue),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Load interstitial ad for showing after exercise completion (game specific)
  Future<void> _loadInterstitialAdForGame() async {
    try {
      await _adService.loadInterstitialAdForGame();
      debugPrint('Game interstitial ad loaded for word recall exercise');
    } catch (e) {
      debugPrint('Failed to load game interstitial ad: $e');
    }
  }

  // Show interstitial ad and navigate back to main menu
  Future<void> _showAdAndNavigateBack() async {
    if (_isShowingAd) return; // Prevent multiple ad calls

    _isShowingAd = true;
    try {
      debugPrint('Starting to show game interstitial ad...');
      await _adService.showInterstitialAdPlayGame();
      debugPrint('Game interstitial ad completed after exercise completion');
    } catch (e) {
      debugPrint('Failed to show game interstitial ad: $e');
    } finally {
      _isShowingAd = false;
      // Navigate back only after ad is fully completed
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // Show interstitial ad and move to next exercise
  Future<void> _showAdAndMoveToNext(
      ProfessionalWordRecallController controller) async {
    if (_isShowingAd) return; // Prevent multiple ad calls

    _isShowingAd = true;
    try {
      debugPrint(
          'Starting to show game interstitial ad before next exercise...');
      await _adService.showInterstitialAdPlayGame();
      debugPrint('Game interstitial ad completed before next exercise');
    } catch (e) {
      debugPrint('Failed to show game interstitial ad: $e');
    } finally {
      _isShowingAd = false;
      // Move to next exercise only after ad is fully completed
      controller.moveToNextExercise();
      // Load next ad for the upcoming exercise
      _loadInterstitialAdForGame();
    }
  }

  Widget _buildCorrectWordItem(
      VocabularyWord word, ProfessionalWordRecallController controller) {
    final attempt = controller.getAttemptForWord(word.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.english,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  word.turkish,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Show additional info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (attempt?.usedHint == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber[600], size: 10),
                      const SizedBox(width: 2),
                      Text(
                        AppLocalizations.of(context)!.hint_tip,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.correct,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 50.0;
    const radius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
