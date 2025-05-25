import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';

import 'word_recall_game_controller.dart';
import '../../models/word_models.dart';

/// Screen for the word recall game
class WordRecallGameScreen extends ConsumerStatefulWidget {
  final int initialLevel;

  const WordRecallGameScreen({
    super.key,
    this.initialLevel = 1,
  });

  @override
  ConsumerState<WordRecallGameScreen> createState() =>
      _WordRecallGameScreenState();
}

class _WordRecallGameScreenState extends ConsumerState<WordRecallGameScreen> {
  /// Controller for the confetti animation
  late ConfettiController _confettiController;

  /// Text controllers for recall input
  final TextEditingController _recallInputController = TextEditingController();

  /// Focus node for recall input
  final FocusNode _recallInputFocusNode = FocusNode();

  /// Current word being recalled
  RecallWord? _currentRecallWord;

  /// Controller for game state management
  WordRecallGameController? _gameController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Initialize the game controller
    _gameController =
        ref.read(wordRecallGameControllerProvider(widget.initialLevel));

    // Start the game timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_gameController != null) {
        // Start the timer with state update callback
        _gameController!.startTimer(() {
          if (mounted) {
            setState(() {
              // Select a new word to recall if needed
              _selectCurrentRecallWord();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _confettiController.dispose();
    _recallInputController.dispose();
    _recallInputFocusNode.dispose();

    // Dispose game controller if initialized
    _gameController?.dispose();

    super.dispose();
  }

  /// Select a word to recall if not already selected
  void _selectCurrentRecallWord() {
    if (_gameController == null) return;

    if (_gameController!.gamePhase == RecallGamePhase.recall &&
        _currentRecallWord == null &&
        _gameController!.recallWords.isNotEmpty) {
      setState(() {
        _currentRecallWord = _gameController!.recallWords.first;
        _recallInputController.clear();
        _recallInputFocusNode.requestFocus();
      });
    }
  }

  /// Check the recalled word
  void _checkRecall() {
    if (_gameController == null || _currentRecallWord == null) return;

    final recalledText = _recallInputController.text;

    if (recalledText.isEmpty) {
      // Show toast for empty input
      Fluttertoast.showToast(
        msg: "Lütfen bir cevap girin",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    final isCorrect = _gameController!.checkWordRecall(
      _currentRecallWord!,
      recalledText,
    );

    // Show feedback
    Fluttertoast.showToast(
      msg: isCorrect
          ? "Doğru! 🎉"
          : "Yanlış! Doğru cevap: ${_currentRecallWord!.turkish}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: isCorrect ? Colors.green : Colors.red,
      textColor: Colors.white,
    );

    if (isCorrect) {
      _confettiController.play();
    }

    // Reset for next word
    setState(() {
      _currentRecallWord = null;
      _recallInputController.clear();

      // Check if we need to select a new word
      _selectCurrentRecallWord();
    });
  }

  /// Skip the current word
  void _skipCurrentWord() {
    if (_gameController == null || _currentRecallWord == null) return;

    // Show the correct answer
    Fluttertoast.showToast(
      msg: "Doğru cevap: ${_currentRecallWord!.turkish}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );

    // Skip the word
    _gameController!.skipWord(_currentRecallWord!);

    // Reset for next word
    setState(() {
      _currentRecallWord = null;
      _recallInputController.clear();

      // Check if we need to select a new word
      _selectCurrentRecallWord();
    });
  }

  /// Get color theme based on current game phase
  Color _getPhaseColor(RecallGamePhase phase) {
    switch (phase) {
      case RecallGamePhase.study:
        return const Color(0xFF00B894); // Green
      case RecallGamePhase.recall:
        return const Color(0xFF6C5CE7); // Purple
      case RecallGamePhase.review:
        return const Color(0xFFFF7675); // Red
      case RecallGamePhase.complete:
        return const Color(0xFFFDAA63); // Orange
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller to rebuild on state changes
    final controller =
        ref.watch(wordRecallGameControllerProvider(widget.initialLevel));

    // Always update _gameController to have the latest reference
    _gameController = controller;

    final currentExercise = controller.currentExercise;
    final currentLevel = controller.currentLevel;
    final currentPhase = controller.gamePhase;

    // Get theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // UI colors based on theme
    final primaryColor = _getPhaseColor(currentPhase);
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
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Kelime Hatırlama',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Play/Pause button (only in study and recall phases)
          if (currentPhase == RecallGamePhase.study ||
              currentPhase == RecallGamePhase.recall)
            IconButton(
              icon: Icon(controller.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                setState(() {
                  controller.togglePause();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Header with level, exercise, and timer info
          _buildHeader(controller, primaryColor),

          // Progress bar and score
          _buildProgressInfo(controller, primaryColor, textColor),

          // Main content area based on game phase
          Expanded(
            child: _buildMainContent(
                controller, primaryColor, cardColor, textColor),
          ),
        ],
      ),
    );
  }

  /// Build the game header with level, exercise, and timer information
  Widget _buildHeader(WordRecallGameController controller, Color primaryColor) {
    String phaseText = '';
    switch (controller.gamePhase) {
      case RecallGamePhase.study:
        phaseText = 'Çalışma Aşaması';
        break;
      case RecallGamePhase.recall:
        phaseText = 'Hatırlama Aşaması';
        break;
      case RecallGamePhase.review:
        phaseText = 'İnceleme Aşaması';
        break;
      case RecallGamePhase.complete:
        phaseText = 'Tamamlandı';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
                  'Seviye ${controller.currentLevel.id}',
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
                  Icons.format_list_numbered,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Alıştırma ${controller.currentExercise.orderInLevel}/${controller.currentLevel.exercises.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Phase and timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: controller.timeLeft < 10 &&
                      (controller.gamePhase == RecallGamePhase.study ||
                          controller.gamePhase == RecallGamePhase.recall)
                  ? Colors.red.withOpacity(0.3)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.timeLeft < 10 &&
                        (controller.gamePhase == RecallGamePhase.study ||
                            controller.gamePhase == RecallGamePhase.recall)
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.gamePhase == RecallGamePhase.study
                      ? Icons.visibility
                      : controller.gamePhase == RecallGamePhase.recall
                          ? Icons.psychology
                          : Icons.check_circle,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  controller.gamePhase == RecallGamePhase.study ||
                          controller.gamePhase == RecallGamePhase.recall
                      ? '$phaseText: ${controller.timeLeft}s'
                      : phaseText,
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
  Widget _buildProgressInfo(WordRecallGameController controller,
      Color primaryColor, Color textColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    String progressText = '';
    double progressValue = 0.0;

    switch (controller.gamePhase) {
      case RecallGamePhase.study:
        progressText = 'Çalışma İlerlemesi';
        progressValue = 1.0 -
            (controller.timeLeft / controller.currentExercise.studyTimeSeconds);
        break;
      case RecallGamePhase.recall:
        final totalWords = controller.wordCount;
        final recalledWords = controller.correctlyRecalledWords.length +
            controller.incorrectlyRecalledWords.length;
        progressText = 'Hatırlanan: $recalledWords/$totalWords';
        progressValue = totalWords > 0 ? recalledWords / totalWords : 0;
        break;
      case RecallGamePhase.review:
      case RecallGamePhase.complete:
        final correctWords = controller.correctlyRecalledWords.length;
        final totalWords = controller.wordCount;
        progressText = 'Doğru: $correctWords/$totalWords';
        progressValue = totalWords > 0 ? correctWords / totalWords : 0;
        break;
    }

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
                Text(
                  progressText,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: isDarkMode
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.grey.shade200,
                    color: primaryColor,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          if (controller.gamePhase == RecallGamePhase.review ||
              controller.gamePhase == RecallGamePhase.complete)
            Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? primaryColor.withOpacity(0.2)
                    : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.score} puan',
                    style: TextStyle(
                      color: primaryColor,
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

  /// Build the main content area based on game phase
  Widget _buildMainContent(WordRecallGameController controller,
      Color primaryColor, Color cardColor, Color textColor) {
    switch (controller.gamePhase) {
      case RecallGamePhase.study:
        return _buildStudyPhase(controller, cardColor, textColor, primaryColor);
      case RecallGamePhase.recall:
        return _buildRecallPhase(
            controller, cardColor, textColor, primaryColor);
      case RecallGamePhase.review:
        return _buildReviewPhase(
            controller, cardColor, textColor, primaryColor);
      case RecallGamePhase.complete:
        return _buildCompletePhase(
            controller, cardColor, textColor, primaryColor);
    }
  }

  /// Build the study phase content
  Widget _buildStudyPhase(WordRecallGameController controller, Color cardColor,
      Color textColor, Color primaryColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Study phase instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kelimeleri Ezberleyin',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bu kelimeleri şimdi çalışın. Süre bittiğinde hatırlamanız istenecek.',
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Study word cards
                Expanded(
                  child: controller.studyWords.isEmpty
                      ? Center(
                          child: Text('Yükleniyor...',
                              style: TextStyle(color: textColor)))
                      : ListView.builder(
                          itemCount: controller.studyWords.length,
                          itemBuilder: (context, index) {
                            final word = controller.studyWords[index];
                            return _buildStudyWordCard(
                                word, cardColor, textColor, primaryColor);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        // Skip study phase button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                controller.proceedToRecallPhase();
                _selectCurrentRecallWord();
              });
            },
            icon: const Icon(
              Icons.skip_next,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              "HATIRLAMA AŞAMASINA GEÇ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  /// Build a study word card
  Widget _buildStudyWordCard(
      RecallWord word, Color cardColor, Color textColor, Color primaryColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // English word
            Text(
              word.english,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Divider(),
            // Turkish translation
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.translate,
                  size: 16,
                  color: textColor.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    word.turkish,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (word.hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              // Hint
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      word.hint,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the recall phase content
  Widget _buildRecallPhase(WordRecallGameController controller, Color cardColor,
      Color textColor, Color primaryColor) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentRecallWord != null) ...[
                      // English word to recall
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _currentRecallWord!.english,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Hint button
                      if (_currentRecallWord!.hint.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "İpucu: ${_currentRecallWord!.hint}",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.black87,
                              textColor: Colors.white,
                            );
                          },
                          icon: Icon(Icons.lightbulb_outline,
                              color: primaryColor),
                          label: Text(
                            'İpucu Göster',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      const SizedBox(height: 30),

                      // Recall input field
                      TextField(
                        controller: _recallInputController,
                        focusNode: _recallInputFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Türkçe karşılığını yazın',
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _checkRecall,
                            color: primaryColor,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          color: textColor,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _checkRecall(),
                      ),
                      const SizedBox(height: 20),

                      // Skip button
                      TextButton.icon(
                        onPressed: _skipCurrentWord,
                        icon: const Icon(Icons.skip_next, color: Colors.grey),
                        label: const Text(
                          'Atla',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ] else if (controller.recallWords.isEmpty) ...[
                      // All words recalled
                      const CircularProgressIndicator(),
                    ] else ...[
                      // Loading next word
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // Confetti overlay for correct answers
        Align(
          alignment: Alignment.topCenter,
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
    );
  }

  /// Build the review phase content
  Widget _buildReviewPhase(WordRecallGameController controller, Color cardColor,
      Color textColor, Color primaryColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Review phase summary
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assessment, color: primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Alıştırma Sonuçları',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'Doğru Cevaplar:',
                        '${controller.correctlyRecalledWords.length}/${controller.wordCount}',
                        Icons.check_circle,
                        Colors.green,
                        textColor,
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Yanlış Cevaplar:',
                        '${controller.incorrectlyRecalledWords.length}/${controller.wordCount}',
                        Icons.cancel,
                        Colors.red,
                        textColor,
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Doğruluk Oranı:',
                        '%${(controller.recallAccuracy * 100).round()}',
                        Icons.analytics,
                        primaryColor,
                        textColor,
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Toplam Puan:',
                        '${controller.score}',
                        Icons.emoji_events,
                        const Color(0xFFFFB74D),
                        textColor,
                      ),
                    ],
                  ),
                ),

                // Review words
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Kelime İncelemesi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            if (controller
                                .correctlyRecalledWords.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, bottom: 8, top: 8),
                                child: Text(
                                  'Doğru Hatırlanan Kelimeler',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ...controller.correctlyRecalledWords.map(
                                (word) => _buildReviewWordCard(
                                  word,
                                  cardColor,
                                  textColor,
                                  Colors.green,
                                  true,
                                ),
                              ),
                            ],
                            if (controller
                                .incorrectlyRecalledWords.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, bottom: 8, top: 16),
                                child: Text(
                                  'Yanlış Hatırlanan Kelimeler',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ...controller.incorrectlyRecalledWords.map(
                                (word) => _buildReviewWordCard(
                                  word,
                                  cardColor,
                                  textColor,
                                  Colors.red,
                                  false,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Complete exercise button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                controller.completeExercise();
              });
            },
            icon: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              "ALISTIRMAYI TAMAMLA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  /// Build a result row for the review summary
  Widget _buildResultRow(String label, String value, IconData icon,
      Color iconColor, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Build a review word card
  Widget _buildReviewWordCard(RecallWord word, Color cardColor, Color textColor,
      Color statusColor, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check : Icons.close,
                color: statusColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.english,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.turkish,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the complete phase content
  Widget _buildCompletePhase(WordRecallGameController controller,
      Color cardColor, Color textColor, Color primaryColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Check if this was the last exercise in the level
    final isLastExercise = controller.currentExercise.orderInLevel ==
        controller.currentLevel.exercises.length;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLastExercise
                            ? Icons.emoji_events
                            : Icons.check_circle,
                        size: 60,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Completion message
                    Text(
                      isLastExercise
                          ? 'Seviye ${controller.currentLevel.id} Tamamlandı!'
                          : 'Alıştırma ${controller.currentExercise.orderInLevel} Tamamlandı!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Score summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.3)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildResultRow(
                            'Doğru Kelimeler:',
                            '${controller.correctlyRecalledWords.length}/${controller.wordCount}',
                            Icons.spellcheck,
                            primaryColor,
                            textColor,
                          ),
                          const SizedBox(height: 12),
                          _buildResultRow(
                            'Doğruluk Oranı:',
                            '%${(controller.recallAccuracy * 100).round()}',
                            Icons.analytics,
                            primaryColor,
                            textColor,
                          ),
                          const SizedBox(height: 12),
                          _buildResultRow(
                            'Alıştırma Puanı:',
                            '${controller.score}',
                            Icons.emoji_events,
                            const Color(0xFFFFB74D),
                            textColor,
                          ),
                          if (isLastExercise) ...[
                            const Divider(height: 24),
                            _buildResultRow(
                              'Toplam Seviye Puanı:',
                              '${controller.totalLevelScore}',
                              Icons.star,
                              const Color(0xFFFFD700),
                              textColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Return to menu button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 18,
                    ),
                    label: const Text(
                      "ANA MENÜ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(
                        color: textColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Next button (either next exercise or next level)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isLastExercise) {
                          if (controller.isGameCompleted) {
                            // Game completed, return to menu
                            Navigator.pop(context);
                          } else {
                            // Go to next level
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WordRecallGameScreen(
                                  initialLevel: controller.currentLevel.id + 1,
                                ),
                              ),
                            );
                          }
                        } else {
                          // Move to next exercise
                          setState(() {
                            controller.moveToNextExercise();
                          });
                        }
                      },
                      icon: Icon(
                        isLastExercise
                            ? controller.isGameCompleted
                                ? Icons.check_circle
                                : Icons.arrow_forward
                            : Icons.skip_next,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        isLastExercise
                            ? controller.isGameCompleted
                                ? "BİTİR"
                                : "SONRAKİ SEVİYE"
                            : "SONRAKİ ALIŞTIRMA",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
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
    );
  }
}
