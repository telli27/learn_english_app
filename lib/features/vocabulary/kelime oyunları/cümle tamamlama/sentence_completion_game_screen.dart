import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';

import 'sentence_completion_controller.dart';
import 'sentence_completion_data.dart';
import '../../../../core/services/ad_service.dart';

/// Screen for the sentence completion game
class SentenceCompletionGameScreen extends ConsumerStatefulWidget {
  final int initialLevel;

  const SentenceCompletionGameScreen({
    super.key,
    this.initialLevel = 1,
  });

  @override
  ConsumerState<SentenceCompletionGameScreen> createState() =>
      _SentenceCompletionGameScreenState();
}

class _SentenceCompletionGameScreenState
    extends ConsumerState<SentenceCompletionGameScreen>
    with TickerProviderStateMixin {
  /// Controller for the confetti animation
  late ConfettiController _confettiController;

  /// Controller for game state management
  SentenceCompletionGameController? _gameController;

  /// Ad service for showing interstitial ads
  final AdService _adService = AdService();

  /// Flag to prevent multiple ad calls
  bool _isShowingAd = false;

  /// Opening animation controllers
  late AnimationController _openingAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  /// Game state for opening animation
  bool _showOpeningAnimation = true;
  int _countdownSeconds = 3;

  /// Track current exercise to detect changes
  int? _currentExerciseOrder;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Initialize opening animation controller
    _openingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _openingAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _openingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize the game controller
    _gameController = ref.read(
        sentenceCompletionGameControllerProvider(widget.initialLevel).notifier);

    // Set initial exercise order
    _currentExerciseOrder = _gameController?.currentExercise.orderInLevel;

    // Load interstitial ad for game
    _loadInterstitialAdForGame();

    // Start opening animation and countdown
    _startOpeningSequence();
  }

  @override
  void dispose() {
    // Dispose confetti controller
    _confettiController.dispose();

    // Dispose opening animation controller
    _openingAnimationController.dispose();

    // Dispose game controller if initialized
    _gameController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show opening animation if needed
    if (_showOpeningAnimation) {
      return _buildOpeningAnimation();
    }

    // Watch the controller state to rebuild on state changes
    final gameState = ref
        .watch(sentenceCompletionGameControllerProvider(widget.initialLevel));
    final controller = ref.read(
        sentenceCompletionGameControllerProvider(widget.initialLevel).notifier);

    // Always update _gameController to have the latest reference
    _gameController = controller;

    // Check if exercise has changed and handle transitions
    if (_currentExerciseOrder != gameState.currentExercise.orderInLevel) {
      _currentExerciseOrder = gameState.currentExercise.orderInLevel;
    }

    final currentExercise = gameState.currentExercise;
    final currentLevel = gameState.currentLevel;
    final currentQuestion = gameState.currentQuestion;

    // Get theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // UI colors based on theme
    final primaryColor =
        const Color(0xFF6C5CE7); // Purple theme for sentence completion
    final accentColor = const Color(0xFF6C5CE7);

    // Background and card colors based on theme
    final backgroundColor =
        isDarkMode ? const Color(0xFF1F2247) : theme.scaffoldBackgroundColor;
    final cardColor = isDarkMode
        ? const Color(0xFF2A2E5A)
        : theme.cardTheme.color ?? Colors.white;

    // Text color based on theme
    final textColor = isDarkMode
        ? Colors.white
        : theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header with level, exercise, and timer information
          _buildHeader(gameState, controller, accentColor),

          // Progress bar and score
          _buildProgressInfo(gameState, accentColor, textColor),

          // Question and options area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question counter
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Soru ${gameState.currentQuestionIndex + 1}/${currentExercise.questionCount}',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sentence with blank
                  _buildSentenceDisplay(
                      currentQuestion, cardColor, textColor, accentColor),

                  const SizedBox(height: 30),

                  // Answer options
                  _buildAnswerOptions(
                      gameState, controller, cardColor, textColor, accentColor),

                  const SizedBox(height: 20),

                  // Submit button
                  if (!gameState.isAnswerSubmitted)
                    _buildSubmitButton(gameState, controller, accentColor),

                  // Explanation section
                  if (gameState.showExplanation)
                    _buildExplanationSection(gameState, controller, cardColor,
                        textColor, accentColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the game header with level, exercise, and timer information
  Widget _buildHeader(SentenceCompletionGameState gameState,
      SentenceCompletionGameController controller, Color accentColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            accentColor.withOpacity(0.9),
            const Color(0xFF5A4FCF),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with back button, title, and pause button
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
                  'Cümle Tamamlama',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: Icon(
                  gameState.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  controller.togglePause();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Game info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Seviye ${gameState.currentLevel.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Exercise indicator
              GestureDetector(
                onTap: () {
                  _showExerciseSelectionDialog(gameState, controller);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_list_numbered,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Alıştırma ${gameState.currentExercise.orderInLevel}/${gameState.currentLevel.exerciseCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Timer
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: gameState.timeLeft < 15
                      ? Colors.red.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gameState.timeLeft < 15
                        ? Colors.red.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${gameState.timeLeft} s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the progress bar and score display
  Widget _buildProgressInfo(SentenceCompletionGameState gameState,
      Color accentColor, Color textColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.grey.shade50,
        border: isDarkMode
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'İlerleme: ${gameState.currentQuestionIndex}/${gameState.currentExercise.questionCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Doğru: ${gameState.correctAnswersCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: gameState.exerciseProgress,
                    backgroundColor: isDarkMode
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.grey.shade200,
                    color: accentColor,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? accentColor.withOpacity(0.2)
                  : accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: accentColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gameState.score} puan',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build sentence display with blank
  Widget _buildSentenceDisplay(SentenceQuestion question, Color cardColor,
      Color textColor, Color accentColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
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
                Icons.quiz,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Cümleyi tamamlayın',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: textColor,
              ),
              children: _buildSentenceSpans(question, accentColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Build sentence spans with highlighted blank
  List<TextSpan> _buildSentenceSpans(
      SentenceQuestion question, Color accentColor) {
    final words = question.sentence.split(' ');
    final spans = <TextSpan>[];

    for (int i = 0; i < words.length; i++) {
      if (i == question.missingWordIndex) {
        // Add blank space
        spans.add(
          TextSpan(
            text: '____',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
              decoration: TextDecoration.underline,
              decorationColor: accentColor,
              decorationThickness: 2,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: words[i]));
      }

      // Add space between words (except for the last word)
      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return spans;
  }

  /// Build answer options
  Widget _buildAnswerOptions(
      SentenceCompletionGameState gameState,
      SentenceCompletionGameController controller,
      Color cardColor,
      Color textColor,
      Color accentColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seçenekler:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ...gameState.currentQuestion.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = gameState.selectedAnswer == option;
          final isCorrect = gameState.currentQuestion.correctAnswer == option;
          final showResult = gameState.showExplanation;

          Color? backgroundColor;
          Color? borderColor;
          Color? textOptionColor = textColor;

          if (showResult) {
            if (isCorrect) {
              backgroundColor = Colors.green.withOpacity(0.2);
              borderColor = Colors.green;
              textOptionColor = Colors.green;
            } else if (isSelected && !isCorrect) {
              backgroundColor = Colors.red.withOpacity(0.2);
              borderColor = Colors.red;
              textOptionColor = Colors.red;
            }
          } else if (isSelected) {
            backgroundColor = accentColor.withOpacity(0.1);
            borderColor = accentColor;
            textOptionColor = accentColor;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: gameState.isAnswerSubmitted
                    ? null
                    : () => controller.selectAnswer(option),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor ??
                          (isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade300),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (textOptionColor ?? accentColor)
                              : Colors.transparent,
                          border: Border.all(
                            color: textOptionColor ?? Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (textOptionColor ?? Colors.grey),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: textOptionColor,
                          ),
                        ),
                      ),
                      if (showResult && isCorrect)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      if (showResult && isSelected && !isCorrect)
                        const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Build submit button
  Widget _buildSubmitButton(SentenceCompletionGameState gameState,
      SentenceCompletionGameController controller, Color accentColor) {
    final isActive = gameState.selectedAnswer != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive ? () => _submitAnswer(controller) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? accentColor : Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isActive ? 4 : 0,
        ),
        child: Text(
          'CEVABI ONAYLA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build explanation section
  Widget _buildExplanationSection(
      SentenceCompletionGameState gameState,
      SentenceCompletionGameController controller,
      Color cardColor,
      Color textColor,
      Color accentColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isCorrect = gameState.currentQuestion
        .isCorrectAnswer(gameState.selectedAnswer ?? '');

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Doğru Cevap!' : 'Yanlış Cevap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            gameState.currentQuestion.explanation,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Doğru cevap: ${gameState.currentQuestion.correctAnswer}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _moveToNextQuestion(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                gameState.isExerciseComplete
                    ? 'Alıştırmayı Bitir'
                    : 'Sonraki Soru',
                style: const TextStyle(
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

  /// Submit answer
  void _submitAnswer(SentenceCompletionGameController controller) {
    final isCorrect = controller.submitAnswer();

    if (isCorrect) {
      Fluttertoast.showToast(
        msg: "Doğru cevap! +10 puan! 🎉",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Yanlış cevap! -3 puan! ❌",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  /// Move to next question or complete exercise
  void _moveToNextQuestion(SentenceCompletionGameController controller) {
    controller.moveToNextQuestion();

    if (controller.state.isExerciseComplete) {
      _onExerciseComplete(controller);
    }
  }

  /// Handle exercise completion
  void _onExerciseComplete(SentenceCompletionGameController controller) {
    // Complete the exercise in the controller
    controller.completeExercise();

    final gameState = controller.state;

    // Check if this was the last exercise in the level
    final isLastExercise = gameState.currentExercise.orderInLevel ==
        gameState.currentLevel.exerciseCount;

    if (isLastExercise) {
      _showLevelCompletionDialog(controller);
    } else {
      _showExerciseCompletionDialog(controller);
    }
  }

  /// Show dialog when an exercise is completed
  void _showExerciseCompletionDialog(
      SentenceCompletionGameController controller) {
    final gameState = controller.state;
    final exerciseScore = gameState.score;
    final timeBonus = gameState.timeLeft;
    final totalScore = exerciseScore + timeBonus;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor = const Color(0xFF6C5CE7);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final statsBoxBgColor =
        isDarkMode ? const Color(0xFF1F2247) : Colors.grey.shade100;
    final textColor = isDarkMode
        ? Colors.white
        : theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        isDarkMode ? Colors.white70 : Colors.grey.shade700;

    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Alıştırma ${gameState.currentExercise.orderInLevel} Tamamlandı!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: statsBoxBgColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Doğru Cevaplar:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '${gameState.correctAnswersCount} / ${gameState.currentExercise.questionCount}',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Zaman Bonusu:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '+$timeBonus puan',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Alıştırma Puanı:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '$totalScore',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Seviye ${gameState.currentLevel.id}\'deki bir sonraki alıştırmaya geçmeye hazır mısınız?',
                    style: TextStyle(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Ana Menü',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAdAndMoveToNext(controller);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          'Devam Et',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: dialogBgColor, width: 5),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog when a level is completed
  void _showLevelCompletionDialog(SentenceCompletionGameController controller) {
    final gameState = controller.state;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor = const Color(0xFF6C5CE7);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final statsBoxBgColor =
        isDarkMode ? const Color(0xFF1F2247) : Colors.grey.shade100;
    final textColor = isDarkMode
        ? Colors.white
        : theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        isDarkMode ? Colors.white70 : Colors.grey.shade700;

    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gameState.isGameCompleted
                        ? 'Tebrikler! Oyunu Tamamladınız!'
                        : 'Seviye ${gameState.currentLevel.id} Tamamlandı!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: statsBoxBgColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tamamlanan Alıştırmalar:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '${gameState.currentLevel.exerciseCount} / ${gameState.currentLevel.exerciseCount}',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Son Alıştırma Bonusu:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '+${gameState.timeLeft} puan',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam Seviye Puanı:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '${gameState.totalLevelScore}',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    gameState.isGameCompleted
                        ? 'Tüm seviyeleri başarıyla tamamladınız!'
                        : 'Bir sonraki seviyeye geçmeye hazır mısınız?',
                    style: TextStyle(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Ana Menü',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ),
                      if (!gameState.isGameCompleted)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            // Navigate to next level screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SentenceCompletionGameScreen(
                                  initialLevel: gameState.currentLevel.id + 1,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'Sonraki Seviye',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (gameState.isGameCompleted)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'Bitir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: dialogBgColor, width: 5),
                ),
                child: Icon(
                  gameState.isGameCompleted
                      ? Icons.emoji_events
                      : Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show exercise selection dialog
  void _showExerciseSelectionDialog(SentenceCompletionGameState gameState,
      SentenceCompletionGameController controller) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor = const Color(0xFF6C5CE7);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode
        ? Colors.white
        : theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        isDarkMode ? Colors.white70 : Colors.grey.shade700;

    // Calculate current level's exercise count
    final exerciseCount = gameState.currentLevel.exerciseCount;
    final currentExerciseOrder = gameState.currentExercise.orderInLevel;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Alıştırma Seç',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Seviye ${gameState.currentLevel.id}',
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Exercise list
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      exerciseCount,
                      (index) {
                        final exerciseOrder = index + 1;
                        final isCurrentExercise =
                            exerciseOrder == currentExerciseOrder;
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);

                            // Only navigate if this isn't the current exercise
                            if (!isCurrentExercise) {
                              // Load the selected exercise
                              controller.loadExercise(exerciseOrder);

                              // Show opening animation for the selected exercise
                              setState(() {
                                _showOpeningAnimation = true;
                              });
                              _startOpeningSequence();
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isCurrentExercise
                                  ? accentColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isCurrentExercise
                                    ? accentColor
                                    : accentColor.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$exerciseOrder',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentExercise
                                        ? Colors.white
                                        : accentColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Alıştırma',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCurrentExercise
                                        ? Colors.white.withOpacity(0.8)
                                        : secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Kapat',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Load interstitial ad for showing after exercise completion (game specific)
  Future<void> _loadInterstitialAdForGame() async {
    try {
      await _adService.loadInterstitialAdForGame();
      debugPrint(
          'Game interstitial ad loaded for sentence completion exercise');
    } catch (e) {
      debugPrint('Failed to load game interstitial ad: $e');
    }
  }

  /// Show interstitial ad and move to next exercise
  Future<void> _showAdAndMoveToNext(
      SentenceCompletionGameController controller) async {
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

      // Show opening animation for new exercise
      if (mounted) {
        setState(() {
          _showOpeningAnimation = true;
        });
        _startOpeningSequence();
      }

      // Load next ad for the upcoming exercise
      _loadInterstitialAdForGame();
    }
  }

  /// Start opening animation and countdown
  void _startOpeningSequence() {
    _openingAnimationController.forward();
    _countdownSeconds = 3;
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showOpeningAnimation = false;
        });

        // Start the game timer after animation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final controller = ref.read(
              sentenceCompletionGameControllerProvider(widget.initialLevel)
                  .notifier);

          // Ensure timer is reset to full value
          controller.resetTimer();

          // Start the timer with state update callback
          controller.startTimer(() {
            if (mounted) {
              setState(() {});
            }
          }, onTimeUp: () {
            if (mounted) {
              _showTimeUpDialog(controller);
            }
          });
        });
      }
    });
  }

  /// Build the opening animation
  Widget _buildOpeningAnimation() {
    // Get current state from provider to ensure we have the latest data
    final gameState = ref
        .watch(sentenceCompletionGameControllerProvider(widget.initialLevel));
    final currentLevel = gameState.currentLevel;
    final currentExercise = gameState.currentExercise;

    // Debug print to track exercise changes
    debugPrint(
        'Opening animation - Level: ${currentLevel.id}, Exercise: ${currentExercise.orderInLevel}');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFF5A4FCF),
              Color(0xFF4834D4),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _openingAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated game icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.quiz,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Game title
                      const Text(
                        'Cümle Tamamlama',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Level and exercise info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Seviye ${currentLevel.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.assignment,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Alıştırma ${currentExercise.orderInLevel}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Countdown
                      if (_countdownSeconds > 0) ...[
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$_countdownSeconds',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Alıştırma başlıyor...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        // Starting message
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'Başlıyor!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        ),
      ),
    );
  }

  /// Show dialog when time runs out
  void _showTimeUpDialog(SentenceCompletionGameController controller) {
    final gameState = controller.state;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor = const Color(0xFF6C5CE7);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final statsBoxBgColor =
        isDarkMode ? const Color(0xFF1F2247) : Colors.grey.shade100;
    final textColor = isDarkMode
        ? Colors.white
        : theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        isDarkMode ? Colors.white70 : Colors.grey.shade700;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Süre Bitti!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: statsBoxBgColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Doğru Cevaplar:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '${gameState.correctAnswersCount} / ${gameState.currentExercise.questionCount}',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Alıştırma Puanı:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '${gameState.score}',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Süre doldu! Alıştırmayı tekrar denemek ister misiniz?',
                    style: TextStyle(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Ana Menü',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Restart the current exercise
                          controller.loadExercise(
                              gameState.currentExercise.orderInLevel);

                          // Show opening animation for the restarted exercise
                          setState(() {
                            _showOpeningAnimation = true;
                          });
                          _startOpeningSequence();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          'Tekrar Dene',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: dialogBgColor, width: 5),
                ),
                child: const Icon(
                  Icons.timer_off,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
