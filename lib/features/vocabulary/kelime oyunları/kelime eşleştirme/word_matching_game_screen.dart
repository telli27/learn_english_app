import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';

import 'word_matching_game_controller.dart';
import '../../models/word_models.dart';
import '../../../../core/services/ad_service.dart';

/// Screen for the word matching game
class WordMatchingGameScreen extends ConsumerStatefulWidget {
  final int initialLevel;

  const WordMatchingGameScreen({
    super.key,
    this.initialLevel = 1,
  });

  @override
  ConsumerState<WordMatchingGameScreen> createState() =>
      _WordMatchingGameScreenState();
}

class _WordMatchingGameScreenState extends ConsumerState<WordMatchingGameScreen>
    with TickerProviderStateMixin {
  /// Keys for tracking word card positions for drawing connection lines
  final Map<String, GlobalKey> _englishKeys = {};
  final Map<String, GlobalKey> _turkishKeys = {};

  /// Key for the content area to use as reference for drawing connections
  final GlobalKey _contentKey = GlobalKey();

  /// Controller for the confetti animation
  late ConfettiController _confettiController;

  /// Controller for game state management
  WordMatchingGameController? _gameController;

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
    _gameController = ref
        .read(wordMatchingGameControllerProvider(widget.initialLevel).notifier);

    // Set initial exercise order
    _currentExerciseOrder = _gameController?.currentExercise.orderInLevel;

    // Initialize keys for the initial word set
    _initializeKeys();

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

  /// Initialize keys for tracking word positions
  void _initializeKeys() {
    if (_gameController == null) return;

    _englishKeys.clear();
    _turkishKeys.clear();

    for (final word in _gameController!.availableEnglishWords) {
      _englishKeys[word] = GlobalKey();
    }

    for (final word in _gameController!.availableTurkishWords) {
      _turkishKeys[word] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show opening animation if needed
    if (_showOpeningAnimation) {
      return _buildOpeningAnimation();
    }

    // Watch the controller state to rebuild on state changes
    final gameState =
        ref.watch(wordMatchingGameControllerProvider(widget.initialLevel));
    final controller = ref
        .read(wordMatchingGameControllerProvider(widget.initialLevel).notifier);

    // Always update _gameController to have the latest reference
    _gameController = controller;

    // Check if exercise has changed and reinitialize keys if needed
    if (_currentExerciseOrder != gameState.currentExercise.orderInLevel) {
      _currentExerciseOrder = gameState.currentExercise.orderInLevel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeKeys();
        }
      });
    }

    final currentExercise = gameState.currentExercise;
    final currentLevel = gameState.currentLevel;

    // Get theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // UI colors based on theme
    final primaryColor = theme.colorScheme.primary; // Use theme primary color
    final accentColor =
        const Color(0xFF6C5CE7); // Keep purple accent consistent

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
      appBar: AppBar(
        backgroundColor: accentColor,
        elevation: 0,
        title: const Text(
          'Kelime Eşleştirme',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Play/Pause button
          IconButton(
            icon: Icon(gameState.isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              controller.togglePause();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with level, exercise, and timer info
          _buildHeader(gameState, controller, accentColor),

          // Progress bar and score
          _buildProgressInfo(gameState, accentColor, textColor),

          // Word matching area
          Expanded(
            key: _contentKey,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // English words column
                              Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      gameState.availableEnglishWords.length,
                                  itemBuilder: (context, index) {
                                    final word =
                                        gameState.availableEnglishWords[index];
                                    return _buildWordCard(
                                        gameState,
                                        controller,
                                        word,
                                        true,
                                        cardColor,
                                        textColor,
                                        accentColor,
                                        index);
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Turkish words column
                              Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      gameState.availableTurkishWords.length,
                                  itemBuilder: (context, index) {
                                    final word =
                                        gameState.availableTurkishWords[index];
                                    return _buildWordCard(
                                        gameState,
                                        controller,
                                        word,
                                        false,
                                        cardColor,
                                        textColor,
                                        accentColor,
                                        index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Match button
                      _buildMatchButton(gameState, controller, accentColor),
                    ],
                  ),
                ),
                // Connection line between selected words
                if (gameState.selectedEnglishWord != null &&
                    gameState.selectedTurkishWord != null)
                  _buildConnectionLine(gameState, accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the game header with level, exercise, and timer information
  Widget _buildHeader(WordMatchingGameState gameState,
      WordMatchingGameController controller, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: accentColor,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    );
  }

  /// Build the progress bar and score display
  Widget _buildProgressInfo(
      WordMatchingGameState gameState, Color accentColor, Color textColor) {
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
                      'Eşleşme: ${gameState.matchedPairs.length}/${gameState.currentExercise.wordPairs.length}',
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
                        'Kalan: ${gameState.currentExercise.wordPairs.length - gameState.matchedPairs.length}',
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
                    value: gameState.matchedPairs.isEmpty
                        ? 0
                        : gameState.matchedPairs.length /
                            gameState.currentExercise.wordPairs.length,
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

  /// Build a word card for either English or Turkish
  Widget _buildWordCard(
      WordMatchingGameState gameState,
      WordMatchingGameController controller,
      String word,
      bool isEnglish,
      Color cardColor,
      Color textColor,
      Color accentColor,
      int index) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bool isSelected = isEnglish
        ? (gameState.selectedEnglishWord == word)
        : (gameState.selectedTurkishWord == word);

    bool isMatched = gameState.isWordMatched(word, isEnglish);

    final GlobalKey cardKey = isEnglish
        ? (_englishKeys[word] ?? GlobalKey())
        : (_turkishKeys[word] ?? GlobalKey());

    return Container(
      key: cardKey,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isMatched) {
            if (isEnglish) {
              controller.selectEnglishWord(word);
            } else {
              controller.selectTurkishWord(word);
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor
                : isMatched
                    ? Colors.green.withOpacity(0.2)
                    : cardColor,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2.0)
                : isMatched
                    ? Border.all(color: Colors.green, width: 1.0)
                    : isDarkMode
                        ? null
                        : Border.all(color: Colors.grey.shade200),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment:
                  isEnglish ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (isEnglish && isSelected)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                Text(
                  word,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : isMatched
                            ? Colors.green
                            : textColor,
                  ),
                ),
                if (!isEnglish && isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the connection line between selected words
  Widget _buildConnectionLine(
      WordMatchingGameState gameState, Color accentColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: CustomPaint(
          painter: ConnectionPainter(
            selectedEnglishWord: gameState.selectedEnglishWord!,
            selectedTurkishWord: gameState.selectedTurkishWord!,
            englishKeys: _englishKeys,
            turkishKeys: _turkishKeys,
            contentKey: _contentKey,
            lineColor: accentColor,
          ),
        ),
      ),
    );
  }

  /// Build the match button
  Widget _buildMatchButton(WordMatchingGameState gameState,
      WordMatchingGameController controller, Color accentColor) {
    final isActive = gameState.selectedEnglishWord != null &&
        gameState.selectedTurkishWord != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: ElevatedButton.icon(
        onPressed: isActive ? () => _checkMatch(gameState, controller) : null,
        icon: const Icon(
          Icons.compare_arrows,
          color: Colors.white,
          size: 22,
        ),
        label: const Text(
          "EŞLEŞTİR",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? const Color(0xFF4B3FD8) : Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: isActive ? 8 : 0,
          shadowColor:
              isActive ? accentColor.withOpacity(0.4) : Colors.transparent,
        ),
      ),
    );
  }

  /// Check if the selected words match
  void _checkMatch(
      WordMatchingGameState gameState, WordMatchingGameController controller) {
    final isCorrect = controller.checkMatch();

    if (isCorrect) {
      // Handle correct match
      Fluttertoast.showToast(
          msg: "Doğru eşleşme: +10 puan! 🎉",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      // Remove keys for matched words
      _englishKeys.remove(gameState.selectedEnglishWord);
      _turkishKeys.remove(gameState.selectedTurkishWord);

      // Check if exercise is complete (all words matched)
      if (controller.state.isExerciseComplete) {
        _onExerciseComplete(controller);
      }
    } else {
      // Handle incorrect match
      Fluttertoast.showToast(
          msg: "Yanlış eşleşme: -2 puan! ❌",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  /// Handle exercise completion
  void _onExerciseComplete(WordMatchingGameController controller) {
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
  void _showExerciseCompletionDialog(WordMatchingGameController controller) {
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
                              'Doğru Eşleşmeler:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '${gameState.matchedPairs.length} / ${gameState.currentExercise.wordPairs.length}',
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
            Positioned(
              top: -60,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 1,
                emissionFrequency: 0.03,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog when a level is completed
  void _showLevelCompletionDialog(WordMatchingGameController controller) {
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
                                builder: (context) => WordMatchingGameScreen(
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
            Positioned(
              top: -60,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 1,
                emissionFrequency: 0.03,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show exercise selection dialog
  void _showExerciseSelectionDialog(
      WordMatchingGameState gameState, WordMatchingGameController controller) {
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
      debugPrint('Game interstitial ad loaded for word matching exercise');
    } catch (e) {
      debugPrint('Failed to load game interstitial ad: $e');
    }
  }

  /// Show interstitial ad and move to next exercise
  Future<void> _showAdAndMoveToNext(
      WordMatchingGameController controller) async {
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
              wordMatchingGameControllerProvider(widget.initialLevel).notifier);

          // Ensure timer is reset to full value
          controller.resetTimer();

          // Reinitialize keys for the new exercise
          _initializeKeys();

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
    final gameState =
        ref.watch(wordMatchingGameControllerProvider(widget.initialLevel));
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
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6C5CE7),
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
                          Icons.extension,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Game title
                      const Text(
                        'Kelime Eşleştirme',
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
  void _showTimeUpDialog(WordMatchingGameController controller) {
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
                              'Doğru Eşleşmeler:',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            Text(
                              '${gameState.matchedPairs.length} / ${gameState.currentExercise.wordPairs.length}',
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

/// Painter for drawing connection lines between selected words
class ConnectionPainter extends CustomPainter {
  final String selectedEnglishWord;
  final String selectedTurkishWord;
  final Map<String, GlobalKey> englishKeys;
  final Map<String, GlobalKey> turkishKeys;
  final GlobalKey contentKey;
  final Color lineColor;

  ConnectionPainter({
    required this.selectedEnglishWord,
    required this.selectedTurkishWord,
    required this.englishKeys,
    required this.turkishKeys,
    required this.contentKey,
    this.lineColor = const Color(0xFF6C5CE7),
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final englishKey = englishKeys[selectedEnglishWord];
      final turkishKey = turkishKeys[selectedTurkishWord];
      final contentBox =
          contentKey.currentContext?.findRenderObject() as RenderBox?;

      if (englishKey?.currentContext == null ||
          turkishKey?.currentContext == null ||
          contentBox == null) {
        return;
      }

      final englishBox =
          englishKey!.currentContext!.findRenderObject() as RenderBox?;
      final turkishBox =
          turkishKey!.currentContext!.findRenderObject() as RenderBox?;

      if (englishBox == null || turkishBox == null) {
        return;
      }

      final contentPosition = contentBox.localToGlobal(Offset.zero);
      final englishPosition = englishBox.localToGlobal(Offset.zero);
      final turkishPosition = turkishBox.localToGlobal(Offset.zero);

      final englishRelative = Offset(
        englishPosition.dx - contentPosition.dx,
        englishPosition.dy - contentPosition.dy,
      );

      final turkishRelative = Offset(
        turkishPosition.dx - contentPosition.dx,
        turkishPosition.dy - contentPosition.dy,
      );

      final englishCenter = Offset(
        englishRelative.dx + englishBox.size.width,
        englishRelative.dy + (englishBox.size.height / 2),
      );

      final turkishCenter = Offset(
        turkishRelative.dx,
        turkishRelative.dy + (turkishBox.size.height / 2),
      );

      final paint = Paint()
        ..color = lineColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(englishCenter.dx, englishCenter.dy);

      final controlPoint1 = Offset(englishCenter.dx + 30, englishCenter.dy);
      final controlPoint2 = Offset(turkishCenter.dx - 30, turkishCenter.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        turkishCenter.dx,
        turkishCenter.dy,
      );

      canvas.drawPath(path, paint);

      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(englishCenter, 4, dotPaint);
      canvas.drawCircle(turkishCenter, 4, dotPaint);
    } catch (e) {
      // Handle any errors silently
    }
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.selectedEnglishWord != selectedEnglishWord ||
        oldDelegate.selectedTurkishWord != selectedTurkishWord ||
        oldDelegate.lineColor != lineColor;
  }
}
