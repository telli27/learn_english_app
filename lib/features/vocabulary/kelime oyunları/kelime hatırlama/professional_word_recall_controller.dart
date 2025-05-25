import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game_enums.dart';
import '../game_models.dart';
import 'professional_game_data.dart';
import '../game_audio_service.dart';
import '../../services/achievement_service.dart';

/// Provider for the professional word recall game controller
final professionalWordRecallControllerProvider = StateNotifierProvider
    .autoDispose
    .family<ProfessionalWordRecallController, RecallGameState, DifficultyLevel>(
  (ref, difficulty) => ProfessionalWordRecallController(
    difficulty: difficulty,
    gameDataRepository: ref.watch(professionalGameDataProvider),
    audioService: ref.watch(gameAudioServiceProvider),
    achievementService: ref.watch(achievementServiceProvider),
  ),
);

/// Professional word recall game controller with clean architecture
class ProfessionalWordRecallController extends StateNotifier<RecallGameState> {
  final DifficultyLevel difficulty;
  final ProfessionalGameDataRepository gameDataRepository;
  final GameAudioService audioService;
  final AchievementService achievementService;

  Timer? _gameTimer;
  Timer? _phaseTransitionTimer;
  final List<RecallAttempt> _attempts = [];
  DateTime? _sessionStartTime;
  int _currentExerciseIndex = 0;

  ProfessionalWordRecallController({
    required this.difficulty,
    required this.gameDataRepository,
    required this.audioService,
    required this.achievementService,
  }) : super(_createInitialState(difficulty)) {
    _initializeGame();
  }

  static RecallGameState _createInitialState(DifficultyLevel difficulty) {
    return RecallGameState(
      gameId: 'recall_${DateTime.now().millisecondsSinceEpoch}',
      phase: RecallGamePhase.preparation,
      currentLevel: GameLevel(
        id: '0',
        title: 'Loading...',
        description: '',
        difficulty: difficulty,
        exercises: [],
      ),
      currentExercise: GameExercise(
        id: '0',
        levelId: '0',
        order: 1,
        title: 'Loading...',
        description: '',
        words: [],
        difficulty: difficulty,
      ),
      currentWords: [],
    );
  }

  /// Initialize the game with data
  Future<void> _initializeGame() async {
    _sessionStartTime = DateTime.now();

    final levels = await gameDataRepository.getLevelsForDifficulty(difficulty);
    if (levels.isEmpty) return;

    final level = levels.first;
    final exercise = level.exercises.first;

    state = state.copyWith(
      currentLevel: level,
      currentExercise: exercise,
      currentWords: List.from(exercise.words),
      phase: RecallGamePhase.preparation,
      phaseStartTime: DateTime.now(),
    );

    // Start preparation phase
    _startPreparationPhase();
  }

  /// Start the preparation phase
  void _startPreparationPhase() {
    audioService.playSound(SoundEffect.transition);

    _phaseTransitionTimer = Timer(const Duration(seconds: 2), () {
      _startStudyPhase();
    });
  }

  /// Start the study phase
  void _startStudyPhase() {
    audioService.playSound(SoundEffect.wordReveal);

    state = state.copyWith(
      phase: RecallGamePhase.study,
      timeLeft: state.currentExercise.studyTimeSeconds,
      phaseStartTime: DateTime.now(),
      studiedWords: List.from(state.currentWords),
    );

    _startGameTimer();
  }

  /// Start the transition phase
  void _startTransitionPhase() {
    audioService.playSound(SoundEffect.transition);

    state = state.copyWith(
      phase: RecallGamePhase.transition,
      timeLeft: 3,
      phaseStartTime: DateTime.now(),
    );

    _startGameTimer();
  }

  /// Start the recall phase
  void _startRecallPhase() {
    final shuffledWords = List<VocabularyWord>.from(state.currentWords)
      ..shuffle();

    state = state.copyWith(
      phase: RecallGamePhase.recall,
      currentWords: shuffledWords,
      currentWordIndex: 0,
      timeLeft: state.currentExercise.recallTimeSeconds,
      phaseStartTime: DateTime.now(),
    );

    _startGameTimer();
  }

  /// Start the review phase
  void _startReviewPhase() {
    _stopGameTimer();

    final score = _calculateScore();
    final achievements = _checkAchievements();

    state = state.copyWith(
      phase: RecallGamePhase.review,
      score: score,
      phaseStartTime: DateTime.now(),
    );

    // Play achievement sounds if any
    if (achievements.isNotEmpty) {
      audioService.playSound(SoundEffect.victory);
    }
  }

  /// Complete the current exercise
  void completeExercise() {
    state = state.copyWith(
      phase: RecallGamePhase.complete,
      phaseStartTime: DateTime.now(),
    );

    audioService.playSound(SoundEffect.levelComplete);
    _saveGameSession();
  }

  /// Submit an answer for the current word
  void submitAnswer(String answer) {
    if (state.phase != RecallGamePhase.recall ||
        state.currentWordIndex >= state.currentWords.length) {
      return;
    }

    final currentWord = state.currentWords[state.currentWordIndex];
    final isCorrect = _isAnswerCorrect(answer, currentWord.turkish);
    final timeToAnswer = _getTimeToAnswer();

    // Record attempt
    final attempt = RecallAttempt(
      wordId: currentWord.id,
      userInput: answer.trim(),
      correctAnswer: currentWord.turkish,
      isCorrect: isCorrect,
      attemptTime: DateTime.now(),
      timeToAnswer: timeToAnswer,
      usedHint: state.showHint,
    );
    _attempts.add(attempt);

    // Update game state
    final updatedCorrectWords = List<VocabularyWord>.from(state.correctWords);
    final updatedIncorrectWords =
        List<VocabularyWord>.from(state.incorrectWords);
    int newStreak = state.streak;

    if (isCorrect) {
      updatedCorrectWords.add(currentWord);
      newStreak++;
      audioService.playSound(SoundEffect.correct);
    } else {
      updatedIncorrectWords.add(currentWord);
      newStreak = 0;
      audioService.playSound(SoundEffect.incorrect);
    }

    state = state.copyWith(
      correctWords: updatedCorrectWords,
      incorrectWords: updatedIncorrectWords,
      streak: newStreak,
      currentWordIndex: state.currentWordIndex + 1,
      showHint: false,
      currentInput: '',
    );

    // Check if all words are completed
    if (state.currentWordIndex >= state.currentWords.length) {
      _startReviewPhase();
    }
  }

  /// Skip the current word
  void skipCurrentWord() {
    if (state.phase != RecallGamePhase.recall ||
        state.currentWordIndex >= state.currentWords.length) {
      return;
    }

    final currentWord = state.currentWords[state.currentWordIndex];
    final timeToAnswer = _getTimeToAnswer();

    // Record attempt as skipped
    final attempt = RecallAttempt(
      wordId: currentWord.id,
      userInput: '',
      correctAnswer: currentWord.turkish,
      isCorrect: false,
      attemptTime: DateTime.now(),
      timeToAnswer: timeToAnswer,
      wasSkipped: true,
    );
    _attempts.add(attempt);

    // Update game state
    final updatedSkippedWords = List<VocabularyWord>.from(state.skippedWords)
      ..add(currentWord);

    state = state.copyWith(
      skippedWords: updatedSkippedWords,
      currentWordIndex: state.currentWordIndex + 1,
      streak: 0,
      showHint: false,
      currentInput: '',
    );

    // Check if all words are completed
    if (state.currentWordIndex >= state.currentWords.length) {
      _startReviewPhase();
    }
  }

  /// Show hint for current word
  void showHint() {
    if (state.phase == RecallGamePhase.recall && !state.showHint) {
      state = state.copyWith(showHint: true);
      audioService.playSound(SoundEffect.buttonTap);
    }
  }

  /// Update current input
  void updateInput(String input) {
    state = state.copyWith(currentInput: input);
  }

  /// Toggle pause state
  void togglePause() {
    if (state.phase == RecallGamePhase.study ||
        state.phase == RecallGamePhase.recall) {
      state = state.copyWith(isPaused: !state.isPaused);

      if (state.isPaused) {
        _stopGameTimer();
      } else {
        _startGameTimer();
      }
    }
  }

  /// Move to next exercise
  void moveToNextExercise() {
    _currentExerciseIndex++;

    if (_currentExerciseIndex < state.currentLevel.exercises.length) {
      final nextExercise = state.currentLevel.exercises[_currentExerciseIndex];

      state = state.copyWith(
        currentExercise: nextExercise,
        currentWords: List.from(nextExercise.words),
        phase: RecallGamePhase.preparation,
        score: 0,
        timeLeft: 0,
        streak: 0,
        correctWords: [],
        incorrectWords: [],
        skippedWords: [],
        currentWordIndex: 0,
        showHint: false,
        currentInput: '',
        phaseStartTime: DateTime.now(),
      );

      _attempts.clear();
      _startPreparationPhase();
    }
  }

  /// Change to a specific exercise
  void changeToExercise(int exerciseIndex) {
    if (exerciseIndex >= 0 &&
        exerciseIndex < state.currentLevel.exercises.length) {
      _currentExerciseIndex = exerciseIndex;
      final targetExercise = state.currentLevel.exercises[exerciseIndex];

      state = state.copyWith(
        currentExercise: targetExercise,
        currentWords: List.from(targetExercise.words),
        phase: RecallGamePhase.preparation,
        score: 0,
        timeLeft: 0,
        streak: 0,
        correctWords: [],
        incorrectWords: [],
        skippedWords: [],
        currentWordIndex: 0,
        showHint: false,
        currentInput: '',
        phaseStartTime: DateTime.now(),
      );

      _attempts.clear();
      _startPreparationPhase();
    }
  }

  /// Force transition to recall phase (skip study)
  void forceRecallPhase() {
    if (state.phase == RecallGamePhase.study) {
      _stopGameTimer();
      _startTransitionPhase();
    }
  }

  /// Start the game timer
  void _startGameTimer() {
    _stopGameTimer();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPaused) return;

      final newTimeLeft = math.max(0, state.timeLeft - 1);
      state = state.copyWith(timeLeft: newTimeLeft);

      if (newTimeLeft == 0) {
        _handleTimerExpired();
      } else if (newTimeLeft <= 5 && state.phase == RecallGamePhase.recall) {
        audioService.playSound(SoundEffect.tick);
      }
    });
  }

  /// Stop the game timer
  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  /// Handle timer expiration
  void _handleTimerExpired() {
    switch (state.phase) {
      case RecallGamePhase.study:
        _startTransitionPhase();
        break;
      case RecallGamePhase.transition:
        _startRecallPhase();
        break;
      case RecallGamePhase.recall:
        // Auto-skip remaining words
        _autoSkipRemainingWords();
        _startReviewPhase();
        break;
      default:
        break;
    }
  }

  /// Auto-skip remaining words when time expires
  void _autoSkipRemainingWords() {
    final remainingWords = state.currentWords.skip(state.currentWordIndex);
    final updatedSkippedWords = List<VocabularyWord>.from(state.skippedWords)
      ..addAll(remainingWords);

    // Record skipped attempts
    for (final word in remainingWords) {
      _attempts.add(RecallAttempt(
        wordId: word.id,
        userInput: '',
        correctAnswer: word.turkish,
        isCorrect: false,
        attemptTime: DateTime.now(),
        timeToAnswer: 0,
        wasSkipped: true,
      ));
    }

    state = state.copyWith(
      skippedWords: updatedSkippedWords,
      currentWordIndex: state.currentWords.length,
    );
  }

  /// Check if answer is correct
  bool _isAnswerCorrect(String userAnswer, String correctAnswer) {
    final cleanUser = userAnswer.trim().toLowerCase();
    final cleanCorrect = correctAnswer.trim().toLowerCase();

    // Exact match
    if (cleanUser == cleanCorrect) return true;

    // Allow minor typos (Levenshtein distance <= 1 for words > 3 chars)
    if (correctAnswer.length > 3) {
      return _levenshteinDistance(cleanUser, cleanCorrect) <= 1;
    }

    return false;
  }

  /// Calculate Levenshtein distance for typo tolerance
  int _levenshteinDistance(String s1, String s2) {
    if (s1.length < s2.length) return _levenshteinDistance(s2, s1);
    if (s2.isEmpty) return s1.length;

    List<int> previousRow = List.generate(s2.length + 1, (i) => i);

    for (int i = 0; i < s1.length; i++) {
      List<int> currentRow = [i + 1];

      for (int j = 0; j < s2.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (s1[i] != s2[j] ? 1 : 0);
        currentRow
            .add(math.min(math.min(insertions, deletions), substitutions));
      }

      previousRow = currentRow;
    }

    return previousRow.last;
  }

  /// Calculate score based on performance
  int _calculateScore() {
    final totalWords = state.currentWords.length;
    final correctWords = state.correctWords.length;
    final incorrectWords = state.incorrectWords.length;

    if (totalWords == 0) return 0;

    // Base score: 100 points per correct word
    int score = correctWords * 100;

    // Accuracy bonus: up to 200 points
    final accuracy = correctWords / totalWords;
    score += (accuracy * 200).round();

    // Speed bonus: remaining time as bonus points
    if (state.timeLeft > 0) {
      score += state.timeLeft * 2;
    }

    // Streak bonus: extra points for consecutive correct answers
    final maxStreak = _getMaxStreak();
    score += maxStreak * 10;

    // Perfect score bonus
    if (correctWords == totalWords && incorrectWords == 0) {
      score += 500;
    }

    return score;
  }

  /// Get user's answer for a specific word
  String? getUserAnswerForWord(String wordId) {
    final attempt = _attempts.where((a) => a.wordId == wordId).lastOrNull;
    return attempt?.userInput.isEmpty == true ? null : attempt?.userInput;
  }

  /// Get all user attempts for review
  List<RecallAttempt> get userAttempts => List.unmodifiable(_attempts);

  /// Get user's attempt for a specific word
  RecallAttempt? getAttemptForWord(String wordId) {
    return _attempts.where((a) => a.wordId == wordId).lastOrNull;
  }

  /// Get maximum streak from attempts
  int _getMaxStreak() {
    int maxStreak = 0;
    int currentStreak = 0;

    for (final attempt in _attempts) {
      if (attempt.isCorrect && !attempt.wasSkipped) {
        currentStreak++;
        maxStreak = math.max(maxStreak, currentStreak);
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }

  /// Check for achievements
  List<Achievement> _checkAchievements() {
    final achievements = <Achievement>[];
    final accuracy = state.accuracy;
    final totalTime = state.currentExercise.studyTimeSeconds +
        state.currentExercise.recallTimeSeconds;
    final timeUsed = totalTime - state.timeLeft;

    // Perfect score achievement
    if (accuracy >= 1.0) {
      achievements.add(Achievement(
        id: 'perfect_${state.gameId}',
        type: AchievementType.perfectScore,
        unlockedAt: DateTime.now(),
        title: AchievementType.perfectScore.title,
        description: AchievementType.perfectScore.description,
      ));
    }

    // Speed master achievement
    if (timeUsed <= totalTime * 0.5 && accuracy >= 0.8) {
      achievements.add(Achievement(
        id: 'speed_${state.gameId}',
        type: AchievementType.speedMaster,
        unlockedAt: DateTime.now(),
        title: AchievementType.speedMaster.title,
        description: AchievementType.speedMaster.description,
      ));
    }

    // Streak achievement
    final maxStreak = _getMaxStreak();
    if (maxStreak >= 5) {
      achievements.add(Achievement(
        id: 'streak_${state.gameId}',
        type: AchievementType.streak,
        unlockedAt: DateTime.now(),
        title: AchievementType.streak.title,
        description: '${maxStreak} ardışık doğru cevap!',
      ));
    }

    return achievements;
  }

  /// Get time to answer current word
  int _getTimeToAnswer() {
    if (state.phaseStartTime == null) return 0;
    return DateTime.now().difference(state.phaseStartTime!).inSeconds;
  }

  /// Save game session data
  void _saveGameSession() {
    if (_sessionStartTime == null) return;

    // This would typically save to a repository/database
    if (kDebugMode) {
      print('Game session completed:');
      print('Difficulty: ${difficulty.displayName}');
      print('Score: ${state.score}');
      print('Accuracy: ${(state.accuracy * 100).toStringAsFixed(1)}%');
      print(
          'Time spent: ${DateTime.now().difference(_sessionStartTime!).inMinutes} minutes');
    }
  }

  @override
  void dispose() {
    _stopGameTimer();
    _phaseTransitionTimer?.cancel();
    super.dispose();
  }
}
