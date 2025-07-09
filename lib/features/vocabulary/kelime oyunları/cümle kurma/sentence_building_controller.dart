import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../game_enums.dart';
import '../game_audio_service.dart';
import '../../../../core/services/ad_service.dart';
import 'sentence_building_models.dart';
import 'sentence_building_data.dart';

/// Provider for the sentence building game controller
final sentenceBuildingControllerProvider = StateNotifierProvider.autoDispose
    .family<SentenceBuildingController, SentenceBuildingGameState, String>(
  (ref, levelId) => SentenceBuildingController(
    levelId: levelId,
    audioService: ref.watch(gameAudioServiceProvider),
  ),
);

/// Professional sentence building game controller with modern game flow
class SentenceBuildingController
    extends StateNotifier<SentenceBuildingGameState> {
  final String levelId;
  final GameAudioService audioService;
  final AdService _adService = AdService();
  late final SentenceBuildingDataRepository _repository;

  Timer? _gameTimer;
  Timer? _feedbackTimer;
  Timer? _adCheckTimer;
  final List<SentenceBuildingAttempt> _attempts = [];
  DateTime? _sessionStartTime;
  DateTime? _exerciseStartTime;

  SentenceBuildingController({
    required this.levelId,
    required this.audioService,
    AppLocalizations? l10n,
  }) : super(_createInitialState()) {
    // We'll initialize repository in _initializeGame when we have context
    _initializeGame();
    _preloadAds(); // Pre-load ads when controller is created
  }

  static SentenceBuildingGameState _createInitialState() {
    return SentenceBuildingGameState(
      gameId: 'sentence_${DateTime.now().millisecondsSinceEpoch}',
      phase: SentenceBuildingPhase.loading,
      currentLevel: SentenceBuildingLevel(
        id: '0',
        title: 'Loading...',
        description: '',
        difficulty: DifficultyLevel.beginner,
        exercises: [],
      ),
      currentExercise: SentenceBuildingExercise(
        id: '0',
        levelId: '0',
        order: 1,
        title: 'Loading...',
        description: '',
        targetSentence: '',
        turkishTranslation: '',
        words: [],
        distractorWords: [],
        grammarFocus: GrammarFocus.presentSimple,
        difficulty: DifficultyLevel.beginner,
        explanation: '',
        grammarRule: '',
        hints: [],
      ),
      availableWords: [],
      selectedWords: [],
      isLoading: true,
    );
  }

  /// Initialize the game with level data
  Future<void> _initializeGame() async {
    try {
      _sessionStartTime = DateTime.now();

      // Just set to loading state, UI will call initializeWithContext
      state = state.copyWith(
        phase: SentenceBuildingPhase.loading,
        isLoading: true,
      );
    } catch (e) {
      state = state.copyWith(
        phase: SentenceBuildingPhase.error,
        errorMessage: 'Failed to initialize game: $e',
        isLoading: false,
      );
    }
  }

  /// Initialize with context (called from UI)
  Future<void> initializeWithContext(AppLocalizations l10n) async {
    try {
      _repository = SentenceBuildingDataRepository(l10n);

      final level = _repository.getLevelById(levelId);
      if (level == null || level.exercises.isEmpty) {
        state = state.copyWith(
          phase: SentenceBuildingPhase.error,
          errorMessage: 'Level not found or empty',
          isLoading: false,
        );
        return;
      }

      final exercise = level.exercises.first;
      final shuffledWords = List<String>.from(exercise.allWords)..shuffle();

      state = state.copyWith(
        currentLevel: level,
        currentExercise: exercise,
        availableWords: shuffledWords,
        selectedWords: [],
        currentExerciseIndex: 0,
        timeLeft: exercise.timeLimit,
        phase: SentenceBuildingPhase.building,
        phaseStartTime: DateTime.now(),
        isLoading: false,
      );

      _startExercise();
    } catch (e) {
      state = state.copyWith(
        phase: SentenceBuildingPhase.error,
        errorMessage: 'Failed to initialize game: $e',
        isLoading: false,
      );
    }
  }

  /// Start a new exercise
  void _startExercise() {
    _exerciseStartTime = DateTime.now();

    state = state.copyWith(
      phase: SentenceBuildingPhase.building,
      timeLeft: state.currentExercise.timeLimit,
      phaseStartTime: DateTime.now(),
      showHint: false,
      hintsUsed: 0,
    );

    _startGameTimer();
    _startAdCheckTimer();
    audioService.playSound(SoundEffect.gameStart);
  }

  /// Start the game timer
  void _startGameTimer() {
    _stopGameTimer();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Don't update timer if game is paused
      if (state.isPaused) {
        return;
      }

      if (state.timeLeft <= 0) {
        _timeUp();
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);

        // Warning sounds at different intervals based on total time
        final totalTime = state.currentExercise.timeLimit;

        // Warning at 75% time remaining (e.g., 60s -> 45s, 45s -> 34s)
        if (state.timeLeft == (totalTime * 0.75).round()) {
          audioService.playSound(SoundEffect.tick);
        }
        // Warning at 50% time remaining (e.g., 60s -> 30s, 45s -> 23s)
        else if (state.timeLeft == (totalTime * 0.5).round()) {
          audioService.playSound(SoundEffect.tick);
        }
        // Warning at 25% time remaining (e.g., 60s -> 15s, 45s -> 11s)
        else if (state.timeLeft == (totalTime * 0.25).round()) {
          audioService.playSound(SoundEffect.tick);
        }
        // Urgent ticking for last 10 seconds
        else if (state.timeLeft <= 10 && state.timeLeft > 0) {
          audioService.playSound(SoundEffect.tick);
        }
      }
    });
  }

  /// Stop the game timer
  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  /// Handle time up
  void _timeUp() {
    _stopGameTimer();
    audioService.playSound(SoundEffect.timeUp);

    // If user has selected words, evaluate them
    if (state.selectedWords.isNotEmpty) {
      _submitCurrentSentence();
    } else {
      // If no words selected, show timeout feedback without auto-advance
      state = state.copyWith(
        phase: SentenceBuildingPhase.feedback,
        timeLeft: 0,
      );

      // Create a timeout attempt with minimal score
      final timeoutAttempt = SentenceBuildingAttempt(
        exerciseId: state.currentExercise.id,
        userSentence: [],
        correctSentence: state.currentExercise.words,
        isCorrect: false,
        isPartiallyCorrect: false,
        attemptTime: DateTime.now(),
        timeToComplete: Duration(seconds: state.currentExercise.timeLimit),
        score: 5, // Minimal score for timeout
        usedHint: state.hintsUsed > 0,
        hintsUsed: state.hintsUsed,
        incorrectWords: [],
        misplacedWords: [],
      );

      _attempts.add(timeoutAttempt);

      state = state.copyWith(
        score: timeoutAttempt.score,
        totalScore: state.totalScore + timeoutAttempt.score,
        attempts: List.from(_attempts),
        phaseStartTime: DateTime.now(),
      );

      // Don't auto-advance for timeout - let user decide
      // User can choose "Tekrar Dene" or "Geç" buttons
    }
  }

  /// Add word to sentence
  void addWordToSentence(String word) {
    if (state.phase != SentenceBuildingPhase.building || state.isPaused) return;

    final updatedAvailable = List<String>.from(state.availableWords);
    final updatedSelected = List<String>.from(state.selectedWords);

    if (updatedAvailable.contains(word)) {
      updatedAvailable.remove(word);
      updatedSelected.add(word);

      state = state.copyWith(
        availableWords: updatedAvailable,
        selectedWords: updatedSelected,
      );

      audioService.playSound(SoundEffect.wordSelect);
    }
  }

  /// Remove word from sentence
  void removeWordFromSentence(String word) {
    if (state.phase != SentenceBuildingPhase.building || state.isPaused) return;

    final updatedAvailable = List<String>.from(state.availableWords);
    final updatedSelected = List<String>.from(state.selectedWords);

    if (updatedSelected.contains(word)) {
      updatedSelected.remove(word);
      updatedAvailable.add(word);

      state = state.copyWith(
        availableWords: updatedAvailable,
        selectedWords: updatedSelected,
      );

      audioService.playSound(SoundEffect.wordDeselect);
    }
  }

  /// Clear all selected words
  void clearSentence() {
    if (state.phase != SentenceBuildingPhase.building || state.isPaused) return;

    final allWords = List<String>.from(state.currentExercise.allWords)
      ..shuffle();

    state = state.copyWith(
      availableWords: allWords,
      selectedWords: [],
    );

    audioService.playSound(SoundEffect.clear);
  }

  /// Use a hint
  void useHint() {
    if (!state.canUseHint ||
        state.phase != SentenceBuildingPhase.building ||
        state.isPaused) {
      return;
    }

    // Show the next word in correct position
    final correctWords = state.currentExercise.words;
    final currentLength = state.selectedWords.length;

    if (currentLength < correctWords.length) {
      final nextWord = correctWords[currentLength];

      // Add the hint word if it's available
      if (state.availableWords.contains(nextWord)) {
        addWordToSentence(nextWord);

        // Update hints used count
        state = state.copyWith(
          hintsUsed: state.hintsUsed + 1,
        );

        audioService.playSound(SoundEffect.hint);
      }
    }
  }

  /// Check if rewarded ad can be shown for hints
  bool canShowRewardedAdForHints() {
    debugPrint('Checking rewarded ad availability for sentence building:');
    debugPrint('- Can use hint: ${state.canUseHint}');
    debugPrint('- Hints used: ${state.hintsUsed}');
    debugPrint('- Max hints: ${state.maxHints}');
    debugPrint('- Rewarded ad ready: ${_adService.isRewardedAdReady}');

    // If hints are available, no need for ad
    if (state.canUseHint) return false;

    // Check if rewarded ad is ready
    return _adService.isRewardedAdReady;
  }

  /// Get rewarded ad ready status
  bool get isRewardedAdReady => _adService.isRewardedAdReady;

  /// Manually try to reload rewarded ad
  Future<void> tryReloadRewardedAd() async {
    debugPrint('Manual rewarded ad reload requested');
    await _preloadAds();
  }

  /// Show rewarded ad to get 3 more hints
  Future<bool> showRewardedAdForHints() async {
    if (!canShowRewardedAdForHints()) {
      debugPrint(
          'Cannot show rewarded ad: not available or hints still available');
      return false;
    }

    // Pause the timer while watching ad
    pauseGame();

    bool adWatched = false;

    try {
      debugPrint('Showing rewarded ad for hints...');
      await _adService.showRewardedAd(
        onRewarded: () {
          debugPrint('Rewarded ad completed successfully');
          // Grant 3 more hints
          state = state.copyWith(
            hintsUsed: 0, // Reset hints to 0 (giving 3 more)
            maxHints: 3,
          );
          adWatched = true;
        },
      );

      // Pre-load next rewarded ad
      _preloadAds();
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      return false;
    } finally {
      // Resume the timer after ad
      resumeGame();
    }

    return adWatched;
  }

  /// Submit the current sentence (public method)
  void submitSentence() {
    _submitCurrentSentence();
  }

  /// Submit the current sentence (internal)
  void _submitCurrentSentence() {
    if (state.phase != SentenceBuildingPhase.building) return;

    _stopGameTimer();

    // Analyze the sentence
    final result = _analyzeSentence();
    _attempts.add(result);

    // Update state with results
    state = state.copyWith(
      phase: SentenceBuildingPhase.feedback,
      score: result.score,
      totalScore: state.totalScore + result.score,
      attempts: List.from(_attempts),
      phaseStartTime: DateTime.now(),
    );

    // Play appropriate sound
    if (result.isCorrect) {
      audioService.playSound(SoundEffect.correct);
    } else if (result.isPartiallyCorrect) {
      audioService.playSound(SoundEffect.partialCorrect);
    } else {
      audioService.playSound(SoundEffect.incorrect);
    }

    // Auto-advance after feedback
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      _nextExercise();
    });
  }

  /// Analyze the submitted sentence
  SentenceBuildingAttempt _analyzeSentence() {
    final userSentence = state.selectedWords;
    final correctSentence = state.currentExercise.words;
    final timeToComplete = _exerciseStartTime != null
        ? DateTime.now().difference(_exerciseStartTime!)
        : Duration.zero;

    final isCorrect = _isSentenceCorrect(userSentence, correctSentence);
    final isPartiallyCorrect = !isCorrect &&
        _isSentencePartiallyCorrect(userSentence, correctSentence);
    final score =
        _calculateScore(userSentence, correctSentence, timeToComplete);
    final incorrectWords = _findIncorrectWords(userSentence, correctSentence);
    final misplacedWords = _findMisplacedWords(userSentence, correctSentence);

    return SentenceBuildingAttempt(
      exerciseId: state.currentExercise.id,
      userSentence: userSentence,
      correctSentence: correctSentence,
      isCorrect: isCorrect,
      isPartiallyCorrect: isPartiallyCorrect,
      attemptTime: DateTime.now(),
      timeToComplete: timeToComplete,
      score: score,
      usedHint: state.hintsUsed > 0,
      hintsUsed: state.hintsUsed,
      incorrectWords: incorrectWords,
      misplacedWords: misplacedWords,
    );
  }

  /// Check if sentence is correct
  bool _isSentenceCorrect(
      List<String> userSentence, List<String> correctSentence) {
    if (userSentence.length != correctSentence.length) return false;

    for (int i = 0; i < userSentence.length; i++) {
      if (userSentence[i].toLowerCase() != correctSentence[i].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  /// Check if sentence is partially correct
  bool _isSentencePartiallyCorrect(
      List<String> userSentence, List<String> correctSentence) {
    if (userSentence.isEmpty) return false;

    int correctPositions = 0;
    final minLength = math.min(userSentence.length, correctSentence.length);

    for (int i = 0; i < minLength; i++) {
      if (userSentence[i].toLowerCase() == correctSentence[i].toLowerCase()) {
        correctPositions++;
      }
    }

    return (correctPositions / correctSentence.length) >= 0.6;
  }

  /// Calculate score based on correctness and time
  int _calculateScore(List<String> userSentence, List<String> correctSentence,
      Duration timeToComplete) {
    if (_isSentenceCorrect(userSentence, correctSentence)) {
      // Perfect score with time bonus
      int baseScore = 100;
      int timeBonus = math.max(
          0, (state.currentExercise.timeLimit - timeToComplete.inSeconds) * 2);
      int hintPenalty = state.hintsUsed * 15;
      return math.max(50, baseScore + timeBonus - hintPenalty);
    } else if (_isSentencePartiallyCorrect(userSentence, correctSentence)) {
      // Partial score
      return math.max(25, 70 - (state.hintsUsed * 10));
    } else {
      // Minimal score for attempt
      return math.max(10, 30 - (state.hintsUsed * 5));
    }
  }

  /// Find incorrect words
  List<String> _findIncorrectWords(
      List<String> userSentence, List<String> correctSentence) {
    final incorrect = <String>[];
    final correctSet = correctSentence.map((w) => w.toLowerCase()).toSet();

    for (final word in userSentence) {
      if (!correctSet.contains(word.toLowerCase())) {
        incorrect.add(word);
      }
    }
    return incorrect;
  }

  /// Find misplaced words
  List<String> _findMisplacedWords(
      List<String> userSentence, List<String> correctSentence) {
    final misplaced = <String>[];
    final minLength = math.min(userSentence.length, correctSentence.length);

    for (int i = 0; i < minLength; i++) {
      if (userSentence[i].toLowerCase() != correctSentence[i].toLowerCase()) {
        if (correctSentence
            .map((w) => w.toLowerCase())
            .contains(userSentence[i].toLowerCase())) {
          misplaced.add(userSentence[i]);
        }
      }
    }
    return misplaced;
  }

  /// Move to next exercise
  void _nextExercise() {
    _feedbackTimer?.cancel();

    final nextIndex = state.currentExerciseIndex + 1;

    if (nextIndex >= state.currentLevel.exercises.length) {
      _completeLevel();
      return;
    }

    final nextExercise = state.currentLevel.exercises[nextIndex];
    final shuffledWords = List<String>.from(nextExercise.allWords)..shuffle();

    state = state.copyWith(
      currentExercise: nextExercise,
      currentExerciseIndex: nextIndex,
      availableWords: shuffledWords,
      selectedWords: [],
      timeLeft: nextExercise.timeLimit,
      phase: SentenceBuildingPhase.building,
      phaseStartTime: DateTime.now(),
      showHint: false,
      hintsUsed: 0,
    );

    _startExercise();
  }

  /// Load a specific exercise by index
  void loadExercise(int exerciseIndex) {
    if (exerciseIndex < 0 ||
        exerciseIndex >= state.currentLevel.exercises.length) {
      return;
    }

    _stopGameTimer();
    _feedbackTimer?.cancel();

    final exercise = state.currentLevel.exercises[exerciseIndex];
    final shuffledWords = List<String>.from(exercise.allWords)..shuffle();

    state = state.copyWith(
      currentExercise: exercise,
      currentExerciseIndex: exerciseIndex,
      availableWords: shuffledWords,
      selectedWords: [],
      timeLeft: exercise.timeLimit,
      phase: SentenceBuildingPhase.building,
      phaseStartTime: DateTime.now(),
      showHint: false,
      hintsUsed: 0,
      isPaused: false,
    );

    _startExercise();
  }

  /// Complete the level
  void _completeLevel() {
    _stopGameTimer();
    _feedbackTimer?.cancel();

    state = state.copyWith(
      phase: SentenceBuildingPhase.complete,
      phaseStartTime: DateTime.now(),
    );

    audioService.playSound(SoundEffect.levelComplete);
    _saveGameSession();
  }

  /// Save game session
  void _saveGameSession() {
    if (_sessionStartTime == null) return;

    // TODO: Implement session saving
    // Create session data and save to local storage or send to server
    final sessionData = {
      'sessionId': state.gameId,
      'startTime': _sessionStartTime!.toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      'difficulty': state.currentLevel.difficulty.name,
      'levelId': state.currentLevel.id,
      'totalScore': state.totalScore,
      'perfectSentences': _attempts.where((a) => a.isCorrect).length,
      'partialSentences':
          _attempts.where((a) => a.isPartiallyCorrect && !a.isCorrect).length,
      'incorrectSentences':
          _attempts.where((a) => !a.isCorrect && !a.isPartiallyCorrect).length,
      'totalTime': DateTime.now().difference(_sessionStartTime!).inSeconds,
      'hintsUsed': _attempts.fold(0, (sum, a) => sum + a.hintsUsed),
      'isCompleted': true,
    };

    // TODO: Save sessionData to local storage or send to server
  }

  /// Pause the game
  void pauseGame() {
    if (state.phase == SentenceBuildingPhase.building && !state.isPaused) {
      state = state.copyWith(isPaused: true);
      audioService.playSound(SoundEffect.pause);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.isPaused) {
      state = state.copyWith(isPaused: false);
      audioService.playSound(SoundEffect.resume);
    }
  }

  /// Restart current exercise
  void restartExercise() {
    // Allow restart from any phase except loading
    if (state.phase == SentenceBuildingPhase.loading) return;

    _stopGameTimer();
    _feedbackTimer?.cancel();

    final shuffledWords = List<String>.from(state.currentExercise.allWords)
      ..shuffle();

    state = state.copyWith(
      availableWords: shuffledWords,
      selectedWords: [],
      timeLeft: state.currentExercise.timeLimit,
      phase: SentenceBuildingPhase.building,
      phaseStartTime: DateTime.now(),
      showHint: false,
      hintsUsed: 0,
      isPaused: false,
    );

    _exerciseStartTime = DateTime.now();
    _startGameTimer();
    audioService.playSound(SoundEffect.restart);
  }

  /// Exit the game
  void exitGame() {
    _stopGameTimer();
    _feedbackTimer?.cancel();

    if (_attempts.isNotEmpty) {
      _saveGameSession();
    }
  }

  /// Pre-load ads for better user experience
  Future<void> _preloadAds() async {
    try {
      await _adService.loadRewardedAd();
      if (_adService.isRewardedAdReady) {
        debugPrint(
            'Rewarded ad pre-loaded successfully for sentence building game');
      } else {
        debugPrint('Rewarded ad failed to pre-load - no ad available');
      }
    } catch (e) {
      debugPrint('Failed to pre-load rewarded ad: $e');
    }
  }

  /// Start timer to periodically check ad status
  void _startAdCheckTimer() {
    _adCheckTimer?.cancel();
    _adCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // Try to load rewarded ad if not ready
      if (!_adService.isRewardedAdReady) {
        debugPrint('Attempting to reload rewarded ad...');
        _preloadAds();
      }
    });
  }

  /// Move to next exercise (public method)
  void nextExercise() {
    _nextExercise();
  }

  @override
  void dispose() {
    _stopGameTimer();
    _feedbackTimer?.cancel();
    _adCheckTimer?.cancel();
    super.dispose();
  }
}
