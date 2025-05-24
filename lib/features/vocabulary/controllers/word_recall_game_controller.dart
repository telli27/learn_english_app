import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recall_game_data.dart';
import '../models/word_models.dart';

/// Provider for the word recall game controller
final wordRecallGameControllerProvider =
    Provider.autoDispose.family<WordRecallGameController, int>(
  (ref, initialLevel) => WordRecallGameController(
    initialLevelId: initialLevel,
    ref: ref,
  ),
);

/// Enum for the different phases of the recall game
enum RecallGamePhase {
  /// Study phase - words are shown to the player
  study,

  /// Recall phase - player must recall the words
  recall,

  /// Review phase - player can see what they remembered correctly
  review,

  /// Complete phase - exercise is completed
  complete
}

/// Controller class to manage the state and logic for the word recall game
class WordRecallGameController {
  final int initialLevelId;
  final ProviderRef ref;

  /// Game levels data
  final List<RecallGameLevel> _levels;

  /// Current game state
  late RecallGameLevel _currentLevel;
  late RecallExercise _currentExercise;
  late List<RecallWord> _currentWords;

  /// Current game progress
  int _score = 0;
  int _totalLevelScore = 0;
  int _timeLeft = 0;
  RecallGamePhase _gamePhase = RecallGamePhase.study;
  bool _isPaused = false;
  bool _isGameActive = true;
  bool _isGameCompleted = false;

  /// Word lists for display
  List<RecallWord> _studyWords = [];
  List<RecallWord> _recallWords = [];
  List<RecallWord> _correctlyRecalledWords = [];
  List<RecallWord> _incorrectlyRecalledWords = [];

  /// Timer for game countdown
  Timer? _timer;

  /// Constructor
  WordRecallGameController({
    required this.initialLevelId,
    required this.ref,
  }) : _levels = RecallGameData.getLevels() {
    _initializeGame();
  }

  /// Initialize the game state
  void _initializeGame() {
    // Find the level with the matching ID
    _currentLevel = _levels.firstWhere(
      (level) => level.id == initialLevelId,
      orElse: () => _levels.first,
    );

    // Set the first exercise
    _loadExercise(1);
  }

  /// Load a specific exercise by its order in the level
  void _loadExercise(int exerciseOrder) {
    // Find the exercise with the given order
    _currentExercise = _currentLevel.exercises.firstWhere(
      (exercise) => exercise.orderInLevel == exerciseOrder,
    );

    // Set the current words
    _currentWords = List.from(_currentExercise.words);

    // Initialize for study phase
    _startStudyPhase();
  }

  /// Start the study phase
  void _startStudyPhase() {
    _gamePhase = RecallGamePhase.study;
    _timeLeft = _currentExercise.studyTimeSeconds;
    _isPaused = false;

    // Reset word states
    _studyWords = List.from(_currentWords);
    _studyWords.forEach((word) {
      word.isRevealed = true;
      word.isRecalled = false;
    });

    _recallWords = [];
    _correctlyRecalledWords = [];
    _incorrectlyRecalledWords = [];
  }

  /// Start the recall phase
  void _startRecallPhase() {
    _gamePhase = RecallGamePhase.recall;
    _timeLeft = _currentExercise.recallTimeSeconds;

    // Create recall words list (words to be recalled)
    _recallWords = List.from(_currentWords);
    _recallWords.forEach((word) {
      word.isRevealed = false;
      word.isRecalled = false;
    });

    // Shuffle the order to make it more challenging
    _recallWords.shuffle();
  }

  /// Start the review phase
  void _startReviewPhase() {
    _gamePhase = RecallGamePhase.review;
    _isPaused = true;

    // Calculate score
    int totalWords = _currentWords.length;
    int correctWords = _correctlyRecalledWords.length;

    // Base score: 10 points per correct word
    _score = correctWords * 10;

    // Time bonus if recall phase ended with time left
    if (_timeLeft > 0) {
      _score += _timeLeft;
    }

    // Accuracy bonus: full points if all words recalled correctly
    if (correctWords == totalWords) {
      _score += 20;
    }

    // Add to total level score
    _totalLevelScore += _score;
  }

  /// Check if a word has been correctly recalled
  bool checkWordRecall(RecallWord word, String recalledText) {
    if (_gamePhase != RecallGamePhase.recall) return false;

    // Check if the recalled text matches the word
    bool isCorrect =
        recalledText.trim().toLowerCase() == word.turkish.toLowerCase();

    // Update word status
    word.isRecalled = true;
    word.isRevealed = true;

    if (isCorrect) {
      _correctlyRecalledWords.add(word);
    } else {
      _incorrectlyRecalledWords.add(word);
    }

    // Remove from recall words list
    _recallWords.remove(word);

    // Check if all words have been recalled
    if (_recallWords.isEmpty) {
      _startReviewPhase();
    }

    return isCorrect;
  }

  /// Skip a word during recall phase
  void skipWord(RecallWord word) {
    if (_gamePhase != RecallGamePhase.recall) return;

    // Mark as not recalled
    word.isRecalled = true;
    word.isRevealed = true;

    // Add to incorrect list
    _incorrectlyRecalledWords.add(word);

    // Remove from recall words list
    _recallWords.remove(word);

    // Check if all words have been recalled
    if (_recallWords.isEmpty) {
      _startReviewPhase();
    }
  }

  /// Start the game timer
  void startTimer(Function onTimerTick) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_timeLeft > 0) {
        _timeLeft--;
        onTimerTick();

        // If time runs out during study phase, transition to recall phase
        if (_timeLeft == 0 && _gamePhase == RecallGamePhase.study) {
          _startRecallPhase();
          onTimerTick();
        }

        // If time runs out during recall phase, move to review
        else if (_timeLeft == 0 && _gamePhase == RecallGamePhase.recall) {
          // Any remaining words are marked as not recalled
          for (var word in _recallWords) {
            word.isRecalled = true;
            word.isRevealed = true;
            _incorrectlyRecalledWords.add(word);
          }
          _recallWords = [];

          _startReviewPhase();
          onTimerTick();
        }
      }
    });
  }

  /// Stop the game timer
  void stopTimer() {
    _timer?.cancel();
  }

  /// Toggle pause state
  void togglePause() {
    _isPaused = !_isPaused;
  }

  /// Complete the current exercise and move to complete phase
  void completeExercise() {
    _gamePhase = RecallGamePhase.complete;

    // Stop the timer
    _timer?.cancel();

    // Check if this was the last exercise in the level
    if (_currentExercise.orderInLevel == _currentLevel.exercises.length) {
      // Level complete
      _isGameCompleted = initialLevelId >= _levels.length;
    }
  }

  /// Move to the next exercise
  void moveToNextExercise() {
    // Reset game state for the next exercise
    _score = 0;
    _isPaused = false;

    // Load the next exercise
    _loadExercise(_currentExercise.orderInLevel + 1);
  }

  /// Move to the next level
  void moveToNextLevel() {
    // Find the next level
    int nextLevelIndex =
        _levels.indexWhere((level) => level.id == _currentLevel.id) + 1;

    if (nextLevelIndex < _levels.length) {
      // Set the next level
      _currentLevel = _levels[nextLevelIndex];

      // Reset game state for the new level
      _score = 0;
      _totalLevelScore = 0;
      _isPaused = false;

      // Load the first exercise of the new level
      _loadExercise(1);
    }
  }

  /// Restart the current exercise
  void restartExercise() {
    _score = 0;
    _isPaused = false;
    _loadExercise(_currentExercise.orderInLevel);
  }

  /// Move from study phase to recall phase (user can skip the study phase)
  void proceedToRecallPhase() {
    if (_gamePhase == RecallGamePhase.study) {
      _startRecallPhase();
    }
  }

  /// Getters for the controller's state
  int get score => _score;
  int get timeLeft => _timeLeft;
  int get totalLevelScore => _totalLevelScore;
  bool get isPaused => _isPaused;
  bool get isGameCompleted => _isGameCompleted;
  RecallGamePhase get gamePhase => _gamePhase;

  RecallGameLevel get currentLevel => _currentLevel;
  RecallExercise get currentExercise => _currentExercise;

  List<RecallWord> get studyWords => _studyWords;
  List<RecallWord> get recallWords => _recallWords;
  List<RecallWord> get correctlyRecalledWords => _correctlyRecalledWords;
  List<RecallWord> get incorrectlyRecalledWords => _incorrectlyRecalledWords;

  int get wordCount => _currentWords.length;
  int get correctWordCount => _correctlyRecalledWords.length;
  double get recallAccuracy => _currentWords.isEmpty
      ? 0
      : _correctlyRecalledWords.length / _currentWords.length;

  /// Clean up resources
  void dispose() {
    _timer?.cancel();
  }
}
