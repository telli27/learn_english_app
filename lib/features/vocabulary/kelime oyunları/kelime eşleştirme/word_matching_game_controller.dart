import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_data.dart';
import '../../models/word_models.dart';

/// Game state class to hold all the game data
class WordMatchingGameState {
  final GameLevel currentLevel;
  final Exercise currentExercise;
  final List<WordPair> currentWordPairs;
  final int score;
  final int totalLevelScore;
  final int timeLeft;
  final bool isPaused;
  final bool isGameActive;
  final bool isGameCompleted;
  final List<WordPair> matchedPairs;
  final List<WordPair> incorrectPairs;
  final String? selectedEnglishWord;
  final String? selectedTurkishWord;
  final List<String> availableEnglishWords;
  final List<String> availableTurkishWords;

  const WordMatchingGameState({
    required this.currentLevel,
    required this.currentExercise,
    required this.currentWordPairs,
    required this.score,
    required this.totalLevelScore,
    required this.timeLeft,
    required this.isPaused,
    required this.isGameActive,
    required this.isGameCompleted,
    required this.matchedPairs,
    required this.incorrectPairs,
    required this.selectedEnglishWord,
    required this.selectedTurkishWord,
    required this.availableEnglishWords,
    required this.availableTurkishWords,
  });

  WordMatchingGameState copyWith({
    GameLevel? currentLevel,
    Exercise? currentExercise,
    List<WordPair>? currentWordPairs,
    int? score,
    int? totalLevelScore,
    int? timeLeft,
    bool? isPaused,
    bool? isGameActive,
    bool? isGameCompleted,
    List<WordPair>? matchedPairs,
    List<WordPair>? incorrectPairs,
    String? selectedEnglishWord,
    String? selectedTurkishWord,
    List<String>? availableEnglishWords,
    List<String>? availableTurkishWords,
    bool clearSelectedEnglishWord = false,
    bool clearSelectedTurkishWord = false,
  }) {
    return WordMatchingGameState(
      currentLevel: currentLevel ?? this.currentLevel,
      currentExercise: currentExercise ?? this.currentExercise,
      currentWordPairs: currentWordPairs ?? this.currentWordPairs,
      score: score ?? this.score,
      totalLevelScore: totalLevelScore ?? this.totalLevelScore,
      timeLeft: timeLeft ?? this.timeLeft,
      isPaused: isPaused ?? this.isPaused,
      isGameActive: isGameActive ?? this.isGameActive,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      incorrectPairs: incorrectPairs ?? this.incorrectPairs,
      selectedEnglishWord: clearSelectedEnglishWord
          ? null
          : (selectedEnglishWord ?? this.selectedEnglishWord),
      selectedTurkishWord: clearSelectedTurkishWord
          ? null
          : (selectedTurkishWord ?? this.selectedTurkishWord),
      availableEnglishWords:
          availableEnglishWords ?? this.availableEnglishWords,
      availableTurkishWords:
          availableTurkishWords ?? this.availableTurkishWords,
    );
  }

  /// Check if all pairs have been matched
  bool get isExerciseComplete => matchedPairs.length == currentWordPairs.length;

  /// Check if a word is already matched
  bool isWordMatched(String word, bool isEnglish) {
    for (final pair in matchedPairs) {
      if (isEnglish && pair.english == word) {
        return true;
      } else if (!isEnglish && pair.turkish == word) {
        return true;
      }
    }
    return false;
  }
}

/// Provider for the word matching game controller
final wordMatchingGameControllerProvider = StateNotifierProvider.autoDispose
    .family<WordMatchingGameController, WordMatchingGameState, int>(
  (ref, initialLevel) => WordMatchingGameController(
    initialLevelId: initialLevel,
    ref: ref,
  ),
);

/// Controller class to manage the state and logic for the word matching game
class WordMatchingGameController extends StateNotifier<WordMatchingGameState> {
  final int initialLevelId;
  final AutoDisposeStateNotifierProviderRef ref;

  /// Game levels data
  final List<GameLevel> _levels;

  /// Timer for game countdown
  Timer? _timer;

  /// Constructor
  WordMatchingGameController({
    required this.initialLevelId,
    required this.ref,
  })  : _levels = GameData.getLevels(),
        super(_createInitialState(initialLevelId)) {
    _initializeGame();
  }

  /// Create initial state
  static WordMatchingGameState _createInitialState(int initialLevelId) {
    final levels = GameData.getLevels();
    final currentLevel = levels.firstWhere(
      (level) => level.id == initialLevelId,
      orElse: () => levels.first,
    );
    final currentExercise = currentLevel.exercises.first;
    final currentWordPairs = currentExercise.wordPairs;

    final availableEnglishWords =
        currentWordPairs.map((pair) => pair.english).toList()..shuffle();
    final availableTurkishWords =
        currentWordPairs.map((pair) => pair.turkish).toList()..shuffle();

    return WordMatchingGameState(
      currentLevel: currentLevel,
      currentExercise: currentExercise,
      currentWordPairs: currentWordPairs,
      score: 0,
      totalLevelScore: 0,
      timeLeft: 60,
      isPaused: false,
      isGameActive: true,
      isGameCompleted: false,
      matchedPairs: [],
      incorrectPairs: [],
      selectedEnglishWord: null,
      selectedTurkishWord: null,
      availableEnglishWords: availableEnglishWords,
      availableTurkishWords: availableTurkishWords,
    );
  }

  /// Initialize the game state
  void _initializeGame() {
    // Game is already initialized in the constructor
  }

  /// Load a specific exercise by its order in the level
  void _loadExercise(int exerciseOrder) {
    debugPrint('Loading exercise: $exerciseOrder');

    // Find the exercise with the given order
    final currentExercise = state.currentLevel.exercises.firstWhere(
      (exercise) => exercise.orderInLevel == exerciseOrder,
    );

    debugPrint(
        'Found exercise: ${currentExercise.orderInLevel} with ${currentExercise.wordPairs.length} word pairs');

    // Set the current word pairs
    final currentWordPairs = currentExercise.wordPairs;

    // Create and shuffle available words
    final availableEnglishWords =
        currentWordPairs.map((pair) => pair.english).toList()..shuffle();
    final availableTurkishWords =
        currentWordPairs.map((pair) => pair.turkish).toList()..shuffle();

    // Update state
    state = state.copyWith(
      currentExercise: currentExercise,
      currentWordPairs: currentWordPairs,
      matchedPairs: [],
      incorrectPairs: [],
      clearSelectedEnglishWord: true,
      clearSelectedTurkishWord: true,
      availableEnglishWords: availableEnglishWords,
      availableTurkishWords: availableTurkishWords,
      score: exerciseOrder > 1 ? 0 : state.score,
    );

    debugPrint(
        'Exercise loaded successfully: ${state.currentExercise.orderInLevel}');
  }

  /// Start the game timer
  void startTimer(Function onTimerTick, {Function? onTimeUp}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPaused) return;

      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
        onTimerTick();
      } else {
        _timer?.cancel();
        state = state.copyWith(isPaused: true);
        onTimerTick();
        // Call the time up callback if provided
        if (onTimeUp != null) {
          onTimeUp();
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
    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// Check if a word is already matched
  bool isWordMatched(String word, bool isEnglish) {
    return state.isWordMatched(word, isEnglish);
  }

  /// Select an English word
  void selectEnglishWord(String word) {
    if (state.isPaused) return;

    if (isWordMatched(word, true)) return;

    if (state.selectedEnglishWord == word) {
      state = state.copyWith(clearSelectedEnglishWord: true);
    } else {
      state = state.copyWith(selectedEnglishWord: word);
    }
  }

  /// Select a Turkish word
  void selectTurkishWord(String word) {
    if (state.isPaused) return;

    if (isWordMatched(word, false)) return;

    if (state.selectedTurkishWord == word) {
      state = state.copyWith(clearSelectedTurkishWord: true);
    } else {
      state = state.copyWith(selectedTurkishWord: word);
    }
  }

  /// Check if the currently selected words match
  bool checkMatch() {
    if (state.isPaused ||
        state.selectedEnglishWord == null ||
        state.selectedTurkishWord == null) {
      return false;
    }

    final correctPair = state.currentWordPairs.firstWhere(
      (pair) => pair.english == state.selectedEnglishWord,
      orElse: () => WordPair(english: '', turkish: ''),
    );

    if (correctPair.turkish == state.selectedTurkishWord) {
      // Add to matched pairs
      state = state.copyWith(
        matchedPairs: [...state.matchedPairs, correctPair],
        score: state.score + 10,
        availableEnglishWords: state.availableEnglishWords
            .where((w) => w != state.selectedEnglishWord)
            .toList(),
        availableTurkishWords: state.availableTurkishWords
            .where((w) => w != state.selectedTurkishWord)
            .toList(),
        clearSelectedEnglishWord: true,
        clearSelectedTurkishWord: true,
      );

      return true;
    } else {
      // Add to incorrect pairs
      state = state.copyWith(
        incorrectPairs: [
          ...state.incorrectPairs,
          WordPair(
            english: state.selectedEnglishWord!,
            turkish: state.selectedTurkishWord!,
          )
        ],
        score: max(0, state.score - 2),
        clearSelectedEnglishWord: true,
        clearSelectedTurkishWord: true,
      );

      return false;
    }
  }

  /// Complete the current exercise
  void completeExercise() {
    // Stop the timer
    _timer?.cancel();

    // Add time bonus to score
    int finalScore = state.score + state.timeLeft;

    // Add to total level score
    state = state.copyWith(
      totalLevelScore: state.totalLevelScore + finalScore,
      isGameCompleted: initialLevelId >= _levels.length,
      isPaused: true,
    );
  }

  /// Move to the next exercise
  void moveToNextExercise() {
    // Calculate next exercise order
    final nextExerciseOrder = state.currentExercise.orderInLevel + 1;

    debugPrint(
        'Moving to next exercise: ${state.currentExercise.orderInLevel} -> $nextExerciseOrder');

    // Reset game state for the next exercise
    state = state.copyWith(
      score: 0,
      timeLeft: 60,
      isPaused: false,
    );

    // Load the next exercise
    _loadExercise(nextExerciseOrder);
  }

  /// Load a specific exercise by its order in the level
  void loadExercise(int exerciseOrder) {
    // Reset game state for the selected exercise
    state = state.copyWith(
      score: 0,
      timeLeft: 60,
      isPaused: false,
    );

    // Load the exercise
    _loadExercise(exerciseOrder);
  }

  /// Move to the next level
  void moveToNextLevel() {
    // Find the next level
    int nextLevelIndex =
        _levels.indexWhere((level) => level.id == state.currentLevel.id) + 1;

    if (nextLevelIndex < _levels.length) {
      // Set the next level
      state = state.copyWith(
        currentLevel: _levels[nextLevelIndex],
        score: 0,
        totalLevelScore: 0,
        timeLeft: 60,
        isPaused: false,
      );

      // Load the first exercise of the new level
      _loadExercise(1);
    }
  }

  /// Reset the timer
  void resetTimer() {
    state = state.copyWith(timeLeft: 60);
  }

  /// Getters for the controller's state
  int get score => state.score;
  int get timeLeft => state.timeLeft;
  int get totalLevelScore => state.totalLevelScore;
  bool get isPaused => state.isPaused;
  bool get isGameCompleted => state.isGameCompleted;

  GameLevel get currentLevel => state.currentLevel;
  Exercise get currentExercise => state.currentExercise;
  List<WordPair> get matchedPairs => state.matchedPairs;

  String? get selectedEnglishWord => state.selectedEnglishWord;
  String? get selectedTurkishWord => state.selectedTurkishWord;

  List<String> get availableEnglishWords => state.availableEnglishWords;
  List<String> get availableTurkishWords => state.availableTurkishWords;

  /// Clean up resources
  void dispose() {
    _timer?.cancel();
  }
}
