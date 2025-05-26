import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'enhanced_sentence_completion_data.dart';

/// Game state class to hold all the sentence completion game data
class SentenceCompletionGameState {
  final SentenceLevel currentLevel;
  final SentenceExercise currentExercise;
  final SentenceQuestion currentQuestion;
  final int currentQuestionIndex;
  final int score;
  final int totalLevelScore;
  final int timeLeft;
  final bool isPaused;
  final bool isGameActive;
  final bool isGameCompleted;
  final String? selectedAnswer;
  final List<int> correctAnswers;
  final List<int> incorrectAnswers;
  final bool showExplanation;
  final bool isAnswerSubmitted;

  const SentenceCompletionGameState({
    required this.currentLevel,
    required this.currentExercise,
    required this.currentQuestion,
    required this.currentQuestionIndex,
    required this.score,
    required this.totalLevelScore,
    required this.timeLeft,
    required this.isPaused,
    required this.isGameActive,
    required this.isGameCompleted,
    required this.selectedAnswer,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.showExplanation,
    required this.isAnswerSubmitted,
  });

  SentenceCompletionGameState copyWith({
    SentenceLevel? currentLevel,
    SentenceExercise? currentExercise,
    SentenceQuestion? currentQuestion,
    int? currentQuestionIndex,
    int? score,
    int? totalLevelScore,
    int? timeLeft,
    bool? isPaused,
    bool? isGameActive,
    bool? isGameCompleted,
    String? selectedAnswer,
    List<int>? correctAnswers,
    List<int>? incorrectAnswers,
    bool? showExplanation,
    bool? isAnswerSubmitted,
    bool clearSelectedAnswer = false,
  }) {
    return SentenceCompletionGameState(
      currentLevel: currentLevel ?? this.currentLevel,
      currentExercise: currentExercise ?? this.currentExercise,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      totalLevelScore: totalLevelScore ?? this.totalLevelScore,
      timeLeft: timeLeft ?? this.timeLeft,
      isPaused: isPaused ?? this.isPaused,
      isGameActive: isGameActive ?? this.isGameActive,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
      selectedAnswer:
          clearSelectedAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      showExplanation: showExplanation ?? this.showExplanation,
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
    );
  }

  /// Check if all questions in the current exercise have been answered
  bool get isExerciseComplete =>
      currentQuestionIndex >= currentExercise.questionCount;

  /// Get progress percentage for current exercise
  double get exerciseProgress =>
      currentQuestionIndex / currentExercise.questionCount;

  /// Get the number of correct answers in current exercise
  int get correctAnswersCount => correctAnswers.length;

  /// Get the number of incorrect answers in current exercise
  int get incorrectAnswersCount => incorrectAnswers.length;

  /// Get accuracy percentage for current exercise
  double get accuracy {
    final totalAnswered = correctAnswersCount + incorrectAnswersCount;
    if (totalAnswered == 0) return 0.0;
    return correctAnswersCount / totalAnswered;
  }
}

/// Provider for the sentence completion game controller
final sentenceCompletionGameControllerProvider = StateNotifierProvider
    .autoDispose
    .family<SentenceCompletionGameController, SentenceCompletionGameState, int>(
  (ref, initialLevel) => SentenceCompletionGameController(
    initialLevelId: initialLevel,
    ref: ref,
  ),
);

/// Controller class to manage the state and logic for the sentence completion game
class SentenceCompletionGameController
    extends StateNotifier<SentenceCompletionGameState> {
  final int initialLevelId;
  final AutoDisposeStateNotifierProviderRef ref;

  /// Game levels data
  final List<SentenceLevel> _levels;

  /// Timer for game countdown
  Timer? _timer;

  /// Constructor
  SentenceCompletionGameController({
    required this.initialLevelId,
    required this.ref,
  })  : _levels = EnhancedSentenceCompletionData.getLevels(),
        super(_createInitialState(initialLevelId)) {
    _initializeGame();
  }

  /// Create initial state
  static SentenceCompletionGameState _createInitialState(int initialLevelId) {
    final levels = EnhancedSentenceCompletionData.getLevels();
    final currentLevel = levels.firstWhere(
      (level) => level.id == initialLevelId,
      orElse: () => levels.first,
    );
    final currentExercise = currentLevel.exercises.first;
    final currentQuestion = currentExercise.questions.first;

    return SentenceCompletionGameState(
      currentLevel: currentLevel,
      currentExercise: currentExercise,
      currentQuestion: currentQuestion,
      currentQuestionIndex: 0,
      score: 0,
      totalLevelScore: 0,
      timeLeft: currentExercise.timeLimit,
      isPaused: false,
      isGameActive: true,
      isGameCompleted: false,
      selectedAnswer: null,
      correctAnswers: [],
      incorrectAnswers: [],
      showExplanation: false,
      isAnswerSubmitted: false,
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
        'Found exercise: ${currentExercise.orderInLevel} with ${currentExercise.questionCount} questions');

    // Get the first question of the exercise
    final currentQuestion = currentExercise.questions.first;

    // Update state
    state = state.copyWith(
      currentExercise: currentExercise,
      currentQuestion: currentQuestion,
      currentQuestionIndex: 0,
      correctAnswers: [],
      incorrectAnswers: [],
      clearSelectedAnswer: true,
      showExplanation: false,
      isAnswerSubmitted: false,
      score: exerciseOrder > 1 ? 0 : state.score,
      timeLeft: currentExercise.timeLimit,
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

  /// Select an answer option
  void selectAnswer(String answer) {
    if (state.isPaused || state.isAnswerSubmitted) return;

    state = state.copyWith(selectedAnswer: answer);
  }

  /// Submit the selected answer
  bool submitAnswer() {
    if (state.isPaused ||
        state.selectedAnswer == null ||
        state.isAnswerSubmitted) {
      return false;
    }

    final isCorrect =
        state.currentQuestion.isCorrectAnswer(state.selectedAnswer!);

    // Update score and tracking lists
    if (isCorrect) {
      state = state.copyWith(
        score: state.score + 10,
        correctAnswers: [...state.correctAnswers, state.currentQuestionIndex],
      );
    } else {
      state = state.copyWith(
        score: max(0, state.score - 3),
        incorrectAnswers: [
          ...state.incorrectAnswers,
          state.currentQuestionIndex
        ],
      );
    }

    // Show explanation and mark as submitted
    state = state.copyWith(
      showExplanation: true,
      isAnswerSubmitted: true,
    );

    return isCorrect;
  }

  /// Move to the next question
  void moveToNextQuestion() {
    final nextQuestionIndex = state.currentQuestionIndex + 1;

    if (nextQuestionIndex < state.currentExercise.questionCount) {
      // Move to next question in the same exercise
      final nextQuestion = state.currentExercise.questions[nextQuestionIndex];

      state = state.copyWith(
        currentQuestion: nextQuestion,
        currentQuestionIndex: nextQuestionIndex,
        clearSelectedAnswer: true,
        showExplanation: false,
        isAnswerSubmitted: false,
      );
    } else {
      // Exercise is complete
      state = state.copyWith(
        currentQuestionIndex:
            nextQuestionIndex, // This will make isExerciseComplete true
      );
    }
  }

  /// Complete the current exercise
  void completeExercise() {
    // Stop the timer
    _timer?.cancel();

    // Add time bonus to score
    int timeBonus = state.timeLeft;
    int finalScore = state.score + timeBonus;

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
        isPaused: false,
      );

      // Load the first exercise of the new level
      _loadExercise(1);
    }
  }

  /// Reset the timer
  void resetTimer() {
    state = state.copyWith(timeLeft: state.currentExercise.timeLimit);
  }

  /// Hide explanation and prepare for next question
  void hideExplanation() {
    state = state.copyWith(
      showExplanation: false,
      isAnswerSubmitted: false,
    );
  }

  /// Restart current question (for wrong answers)
  void restartCurrentQuestion() {
    state = state.copyWith(
      clearSelectedAnswer: true,
      showExplanation: false,
      isAnswerSubmitted: false,
    );
  }

  /// Get hint for current question (reduces score)
  String getHint() {
    // Reduce score for using hint
    state = state.copyWith(score: max(0, state.score - 5));

    // Return a hint based on the correct answer
    final correctAnswer = state.currentQuestion.correctAnswer;
    final options = state.currentQuestion.options;

    // Remove one incorrect option as hint
    final incorrectOptions =
        options.where((option) => option != correctAnswer).toList();
    if (incorrectOptions.isNotEmpty) {
      final randomIncorrect =
          incorrectOptions[Random().nextInt(incorrectOptions.length)];
      return 'İpucu: "$randomIncorrect" doğru cevap değil.';
    }

    return 'İpucu: Cümlenin anlamını düşünün.';
  }

  /// Getters for the controller's state
  int get score => state.score;
  int get timeLeft => state.timeLeft;
  int get totalLevelScore => state.totalLevelScore;
  bool get isPaused => state.isPaused;
  bool get isGameCompleted => state.isGameCompleted;

  SentenceLevel get currentLevel => state.currentLevel;
  SentenceExercise get currentExercise => state.currentExercise;
  SentenceQuestion get currentQuestion => state.currentQuestion;
  int get currentQuestionIndex => state.currentQuestionIndex;

  String? get selectedAnswer => state.selectedAnswer;
  bool get showExplanation => state.showExplanation;
  bool get isAnswerSubmitted => state.isAnswerSubmitted;

  List<int> get correctAnswers => state.correctAnswers;
  List<int> get incorrectAnswers => state.incorrectAnswers;

  /// Clean up resources
  void dispose() {
    _timer?.cancel();
  }
}
