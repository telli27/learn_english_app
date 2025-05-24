import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

import '../core/game_enums.dart';
import '../models/game_models.dart';
import '../controllers/professional_word_recall_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
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
    final gameState =
        ref.watch(professionalWordRecallControllerProvider(widget.difficulty));
    final controller = ref.read(
        professionalWordRecallControllerProvider(widget.difficulty).notifier);

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
                      onPressed: () => Navigator.pop(context),
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
                              '${gameState.currentWords.length} kelime • ${widget.difficulty.displayName}',
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
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Game info cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.psychology,
                        label: gameState.phase.displayName,
                        value: _getPhaseProgress(gameState),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.timer,
                        label: 'Süre',
                        value: '${gameState.timeLeft}s',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.star,
                        label: 'Skor',
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
        progressText = 'Oyun Başlıyor';
        break;
      case RecallGamePhase.study:
        progressText = 'Kelime İnceleme Aşaması';
        break;
      case RecallGamePhase.transition:
        progressText = 'Hatırlama Aşamasına Geçiliyor';
        break;
      case RecallGamePhase.recall:
        progressText = 'Kelime Hatırlama Aşaması';
        break;
      case RecallGamePhase.review:
        progressText = 'Sonuçlar Değerlendiriliyor';
        break;
      case RecallGamePhase.complete:
        progressText = 'Alıştırma Tamamlandı';
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
            'Hazırlanıyor...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${gameState.currentWords.length} kelime ile çalışacaksınız',
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
                      'Kelimeleri inceleyin, sonra hatırlamanız istenecek',
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
                padding:
                    const EdgeInsets.only(bottom: 80), // Bottom padding for FAB
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
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
                    'Hazırım',
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
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // İngilizce kelime - daha küçük
                Text(
                  word.english,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(widget.difficulty.colorValue),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Fonetik - daha küçük
                Text(
                  word.phonetic,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Türkçe kelime
                Text(
                  word.turkish,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
            'Hatırlama Aşaması',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${gameState.timeLeft} saniye sonra başlıyor...',
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
    if (gameState.currentWordIndex >= gameState.currentWords.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentWord = gameState.currentWords[gameState.currentWordIndex];

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                '${gameState.currentWordIndex + 1}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(widget.difficulty.colorValue),
                ),
              ),
              Text(
                ' / ${gameState.currentWords.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                'Doğru: ${gameState.correctWords.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Current word
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      currentWord.english,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(widget.difficulty.colorValue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentWord.phonetic,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (gameState.showHint) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '💡 ${currentWord.hint}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 30),

        // Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
              hintText: 'Türkçe karşılığını yazın...',
              prefixIcon: Icon(
                Icons.edit,
                color: Color(widget.difficulty.colorValue),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.showHint(),
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('İpucu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.skipCurrentWord(),
                icon: const Icon(Icons.skip_next),
                label: const Text('Geç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_inputController.text.trim().isNotEmpty) {
                    controller.submitAnswer(_inputController.text);
                    _inputController.clear();
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(widget.difficulty.colorValue),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const Spacer(),
      ],
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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Results summary
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  accuracy >= 0.9
                      ? Icons.emoji_events
                      : accuracy >= 0.7
                          ? Icons.thumb_up
                          : accuracy >= 0.5
                              ? Icons.sentiment_neutral
                              : Icons.sentiment_dissatisfied,
                  size: 60,
                  color: accuracy >= 0.7
                      ? Colors.amber
                      : Color(widget.difficulty.colorValue),
                ),
                const SizedBox(height: 16),
                Text(
                  result.displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(widget.difficulty.colorValue),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Skorunuz: ${gameState.score}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.check_circle,
                      label: 'Doğru',
                      value: '${gameState.correctWords.length}',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      icon: Icons.cancel,
                      label: 'Yanlış',
                      value: '${gameState.incorrectWords.length}',
                      color: Colors.red,
                    ),
                    _buildStatItem(
                      icon: Icons.skip_next,
                      label: 'Geçilen',
                      value: '${gameState.skippedWords.length}',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.completeExercise(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(widget.difficulty.colorValue),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Devam Et',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePhase(
      RecallGameState gameState, ProfessionalWordRecallController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
            'Alıştırma Tamamlandı!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Toplam Skorunuz: ${gameState.score}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Color(widget.difficulty.colorValue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Ana Menü'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.moveToNextExercise(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(widget.difficulty.colorValue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Sonraki Alıştırma'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
        return 'Hazırlanıyor';
      case RecallGamePhase.study:
        return 'İnceleme';
      case RecallGamePhase.transition:
        return 'Geçiş';
      case RecallGamePhase.recall:
        return '${gameState.currentWordIndex + 1}/${gameState.currentWords.length}';
      case RecallGamePhase.review:
        return 'Değerlendirme';
      case RecallGamePhase.complete:
        return 'Tamamlandı';
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
            padding: const EdgeInsets.all(24),
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
                    const Expanded(
                      child: Text(
                        'Alıştırma Seç',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Exercise list
                ...gameState.currentLevel.exercises
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  final isCurrentExercise =
                      exercise.id == gameState.currentExercise.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isCurrentExercise
                            ? null
                            : () {
                                Navigator.pop(context);
                                // Burada alıştırma değiştirme fonksiyonu çağırılacak
                                _changeExercise(controller, index);
                              },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCurrentExercise
                                ? Color(widget.difficulty.colorValue)
                                    .withOpacity(0.1)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrentExercise
                                  ? Color(widget.difficulty.colorValue)
                                  : Colors.grey[300]!,
                              width: isCurrentExercise ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentExercise
                                      ? Color(widget.difficulty.colorValue)
                                      : Colors.grey[400],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrentExercise
                                            ? Color(
                                                widget.difficulty.colorValue)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${exercise.words.length} kelime',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isCurrentExercise) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(widget.difficulty.colorValue),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Aktif',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 12),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(
                        fontSize: 16,
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
  void _changeExercise(
      ProfessionalWordRecallController controller, int exerciseIndex) {
    // Gerçek alıştırma değiştirme
    controller.changeToExercise(exerciseIndex);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alıştırma ${exerciseIndex + 1} başlatıldı'),
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
