import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_data.dart';
import '../models/word_models.dart';

/// Provider for the word matching game controller
final wordMatchingGameControllerProvider =
    Provider.autoDispose.family<WordMatchingGameController, int>(
  (ref, initialLevel) => WordMatchingGameController(
    initialLevelId: initialLevel,
    ref: ref,
  ),
);

/// Controller class to manage the state and logic for the word matching game
class WordMatchingGameController {
  final int initialLevelId;
  final ProviderRef ref;

  /// Game levels data
  final List<GameLevel> _levels;

  /// Current game state
  late GameLevel _currentLevel;
  late Exercise _currentExercise;
  late List<WordPair> _currentWordPairs;

  /// Current game progress
  int _score = 0;
  int _totalLevelScore = 0;
  int _timeLeft = 60;
  bool _isPaused = false;
  bool _isGameActive = true;
  bool _isGameCompleted = false;

  /// Game matching state
  List<WordPair> _matchedPairs = [];
  List<WordPair> _incorrectPairs = [];

  /// Selected word tracking
  String? _selectedEnglishWord;
  String? _selectedTurkishWord;

  /// Available words to display
  late List<String> _availableEnglishWords;
  late List<String> _availableTurkishWords;

  /// Timer for game countdown
  Timer? _timer;

  /// Constructor
  WordMatchingGameController({
    required this.initialLevelId,
    required this.ref,
  }) : _levels = GameData.getLevels() {
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

    // Set the current word pairs
    _currentWordPairs = _currentExercise.wordPairs;

    // Reset matching state
    _matchedPairs = [];
    _incorrectPairs = [];
    _selectedEnglishWord = null;
    _selectedTurkishWord = null;

    // Create and shuffle available words
    _availableEnglishWords =
        _currentWordPairs.map((pair) => pair.english).toList()..shuffle();
    _availableTurkishWords =
        _currentWordPairs.map((pair) => pair.turkish).toList()..shuffle();

    // Reset score if not the first exercise
    if (exerciseOrder > 1) {
      _score = 0;
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
      } else {
        _timer?.cancel();
        _isPaused = true;
        onTimerTick();
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

  /// Select an English word
  void selectEnglishWord(String word) {
    if (_isPaused) return;

    if (isWordMatched(word, true)) return;

    if (_selectedEnglishWord == word) {
      _selectedEnglishWord = null;
    } else {
      _selectedEnglishWord = word;
    }
  }

  /// Select a Turkish word
  void selectTurkishWord(String word) {
    if (_isPaused) return;

    if (isWordMatched(word, false)) return;

    if (_selectedTurkishWord == word) {
      _selectedTurkishWord = null;
    } else {
      _selectedTurkishWord = word;
    }
  }

  /// Check if the currently selected words match
  bool checkMatch() {
    if (_isPaused ||
        _selectedEnglishWord == null ||
        _selectedTurkishWord == null) {
      return false;
    }

    final correctPair = _currentWordPairs.firstWhere(
      (pair) => pair.english == _selectedEnglishWord,
      orElse: () => WordPair(english: '', turkish: ''),
    );

    if (correctPair.turkish == _selectedTurkishWord) {
      // Add to matched pairs
      _matchedPairs.add(correctPair);

      // Add points
      _score += 10;

      // Remove from available words
      _availableEnglishWords.remove(_selectedEnglishWord);
      _availableTurkishWords.remove(_selectedTurkishWord);

      // Clear selections
      _selectedEnglishWord = null;
      _selectedTurkishWord = null;

      return true;
    } else {
      // Add to incorrect pairs
      _incorrectPairs.add(WordPair(
        english: _selectedEnglishWord!,
        turkish: _selectedTurkishWord!,
      ));

      // Deduct points
      _score = max(0, _score - 2);

      // Clear selections
      _selectedEnglishWord = null;
      _selectedTurkishWord = null;

      return false;
    }
  }

  /// Check if all pairs have been matched
  bool get isExerciseComplete =>
      _matchedPairs.length == _currentWordPairs.length;

  /// Check if a word is already matched
  bool isWordMatched(String word, bool isEnglish) {
    for (final pair in _matchedPairs) {
      if (isEnglish && pair.english == word) {
        return true;
      } else if (!isEnglish && pair.turkish == word) {
        return true;
      }
    }
    return false;
  }

  /// Complete the current exercise
  void completeExercise() {
    // Stop the timer
    _timer?.cancel();

    // Add time bonus to score
    int finalScore = _score + _timeLeft;

    // Add to total level score
    _totalLevelScore += finalScore;

    // Check if this was the last exercise in the level
    if (_currentExercise.orderInLevel == _currentLevel.exerciseCount) {
      // Level complete
      _isGameCompleted = initialLevelId >= _levels.length;
    }

    // Pause the game
    _isPaused = true;
  }

  /// Move to the next exercise
  void moveToNextExercise() {
    // Reset game state for the next exercise
    _score = 0;
    _timeLeft = 60;
    _isPaused = false;

    // Load the next exercise
    _loadExercise(_currentExercise.orderInLevel + 1);
  }

  /// Load a specific exercise by its order in the level
  void loadExercise(int exerciseOrder) {
    // Reset game state for the selected exercise
    _score = 0;
    _timeLeft = 60;
    _isPaused = false;

    // Load the exercise
    _loadExercise(exerciseOrder);
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
      _timeLeft = 60;
      _isPaused = false;

      // Load the first exercise of the new level
      _loadExercise(1);
    }
  }

  /// Reset the timer
  void resetTimer() {
    _timeLeft = 60;
  }

  /// Getters for the controller's state
  int get score => _score;
  int get timeLeft => _timeLeft;
  int get totalLevelScore => _totalLevelScore;
  bool get isPaused => _isPaused;
  bool get isGameCompleted => _isGameCompleted;

  GameLevel get currentLevel => _currentLevel;
  Exercise get currentExercise => _currentExercise;
  List<WordPair> get matchedPairs => _matchedPairs;

  String? get selectedEnglishWord => _selectedEnglishWord;
  String? get selectedTurkishWord => _selectedTurkishWord;

  List<String> get availableEnglishWords => _availableEnglishWords;
  List<String> get availableTurkishWords => _availableTurkishWords;

  /// Clean up resources
  void dispose() {
    _timer?.cancel();
  }
}
