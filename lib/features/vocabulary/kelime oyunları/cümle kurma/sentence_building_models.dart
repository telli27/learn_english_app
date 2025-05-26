import '../game_enums.dart';

/// A sentence building exercise with comprehensive data
class SentenceBuildingExercise {
  final String id;
  final String levelId;
  final int order;
  final String title;
  final String description;
  final String targetSentence;
  final String turkishTranslation;
  final List<String> words;
  final List<String> distractorWords;
  final GrammarFocus grammarFocus;
  final DifficultyLevel difficulty;
  final String explanation;
  final String grammarRule;
  final List<String> hints;
  final int timeLimit;
  final int targetScore;
  final List<String> tags;

  const SentenceBuildingExercise({
    required this.id,
    required this.levelId,
    required this.order,
    required this.title,
    required this.description,
    required this.targetSentence,
    required this.turkishTranslation,
    required this.words,
    required this.distractorWords,
    required this.grammarFocus,
    required this.difficulty,
    required this.explanation,
    required this.grammarRule,
    required this.hints,
    this.timeLimit = 120,
    this.targetScore = 100,
    this.tags = const [],
  });

  SentenceBuildingExercise copyWith({
    String? id,
    String? levelId,
    int? order,
    String? title,
    String? description,
    String? targetSentence,
    String? turkishTranslation,
    List<String>? words,
    List<String>? distractorWords,
    GrammarFocus? grammarFocus,
    DifficultyLevel? difficulty,
    String? explanation,
    String? grammarRule,
    List<String>? hints,
    int? timeLimit,
    int? targetScore,
    List<String>? tags,
  }) {
    return SentenceBuildingExercise(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      order: order ?? this.order,
      title: title ?? this.title,
      description: description ?? this.description,
      targetSentence: targetSentence ?? this.targetSentence,
      turkishTranslation: turkishTranslation ?? this.turkishTranslation,
      words: words ?? this.words,
      distractorWords: distractorWords ?? this.distractorWords,
      grammarFocus: grammarFocus ?? this.grammarFocus,
      difficulty: difficulty ?? this.difficulty,
      explanation: explanation ?? this.explanation,
      grammarRule: grammarRule ?? this.grammarRule,
      hints: hints ?? this.hints,
      timeLimit: timeLimit ?? this.timeLimit,
      targetScore: targetScore ?? this.targetScore,
      tags: tags ?? this.tags,
    );
  }

  /// Get all words including distractors for shuffling
  List<String> get allWords => [...words, ...distractorWords];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentenceBuildingExercise &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Grammar focus categories for sentence building
enum GrammarFocus {
  presentSimple,
  presentContinuous,
  pastSimple,
  pastContinuous,
  presentPerfect,
  pastPerfect,
  futureSimple,
  futurePerfect,
  futureGoingTo,
  conditionals,
  passiveVoice,
  modalVerbs,
  questionFormation,
  negativeFormation,
  comparatives,
  superlatives,
  relativeClauses,
  reportedSpeech,
  subjunctive,
  causative,
  inversion,
  cleftSentences,
  participialClauses,
  gerunds,
  infinitives,
  articles,
  prepositions,
  conjunctions,
  adverbs,
  adjectives,
  wordOrder,
  subjectVerbAgreement,
}

/// Sentence building level with comprehensive metadata
class SentenceBuildingLevel {
  final String id;
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final List<SentenceBuildingExercise> exercises;
  final String imageUrl;
  final int requiredScore;
  final bool isUnlocked;
  final bool isCompleted;
  final int bestScore;
  final int stars;
  final List<GrammarFocus> grammarTopics;
  final bool isPremium;

  const SentenceBuildingLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.exercises,
    this.imageUrl = '',
    this.requiredScore = 0,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bestScore = 0,
    this.stars = 0,
    this.grammarTopics = const [],
    this.isPremium = false,
  });

  SentenceBuildingLevel copyWith({
    String? id,
    String? title,
    String? description,
    DifficultyLevel? difficulty,
    List<SentenceBuildingExercise>? exercises,
    String? imageUrl,
    int? requiredScore,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestScore,
    int? stars,
    List<GrammarFocus>? grammarTopics,
    bool? isPremium,
  }) {
    return SentenceBuildingLevel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      exercises: exercises ?? this.exercises,
      imageUrl: imageUrl ?? this.imageUrl,
      requiredScore: requiredScore ?? this.requiredScore,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
      stars: stars ?? this.stars,
      grammarTopics: grammarTopics ?? this.grammarTopics,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (exercises.isEmpty) return 0.0;
    return bestScore / (exercises.length * 100);
  }
}

/// Player's attempt at building a sentence
class SentenceBuildingAttempt {
  final String exerciseId;
  final List<String> userSentence;
  final List<String> correctSentence;
  final bool isCorrect;
  final bool isPartiallyCorrect;
  final DateTime attemptTime;
  final Duration timeToComplete;
  final int score;
  final bool usedHint;
  final int hintsUsed;
  final List<String> incorrectWords;
  final List<String> misplacedWords;

  const SentenceBuildingAttempt({
    required this.exerciseId,
    required this.userSentence,
    required this.correctSentence,
    required this.isCorrect,
    required this.isPartiallyCorrect,
    required this.attemptTime,
    required this.timeToComplete,
    required this.score,
    this.usedHint = false,
    this.hintsUsed = 0,
    this.incorrectWords = const [],
    this.misplacedWords = const [],
  });

  SentenceBuildingAttempt copyWith({
    String? exerciseId,
    List<String>? userSentence,
    List<String>? correctSentence,
    bool? isCorrect,
    bool? isPartiallyCorrect,
    DateTime? attemptTime,
    Duration? timeToComplete,
    int? score,
    bool? usedHint,
    int? hintsUsed,
    List<String>? incorrectWords,
    List<String>? misplacedWords,
  }) {
    return SentenceBuildingAttempt(
      exerciseId: exerciseId ?? this.exerciseId,
      userSentence: userSentence ?? this.userSentence,
      correctSentence: correctSentence ?? this.correctSentence,
      isCorrect: isCorrect ?? this.isCorrect,
      isPartiallyCorrect: isPartiallyCorrect ?? this.isPartiallyCorrect,
      attemptTime: attemptTime ?? this.attemptTime,
      timeToComplete: timeToComplete ?? this.timeToComplete,
      score: score ?? this.score,
      usedHint: usedHint ?? this.usedHint,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      incorrectWords: incorrectWords ?? this.incorrectWords,
      misplacedWords: misplacedWords ?? this.misplacedWords,
    );
  }
}

/// Game state for sentence building
class SentenceBuildingGameState {
  final String gameId;
  final SentenceBuildingPhase phase;
  final SentenceBuildingLevel currentLevel;
  final SentenceBuildingExercise currentExercise;
  final List<String> availableWords;
  final List<String> selectedWords;
  final int currentExerciseIndex;
  final int timeLeft;
  final int score;
  final int totalScore;
  final bool showHint;
  final int hintsUsed;
  final int maxHints;
  final DateTime? phaseStartTime;
  final List<SentenceBuildingAttempt> attempts;
  final bool isPaused;
  final String? errorMessage;
  final bool isLoading;

  const SentenceBuildingGameState({
    required this.gameId,
    required this.phase,
    required this.currentLevel,
    required this.currentExercise,
    required this.availableWords,
    required this.selectedWords,
    this.currentExerciseIndex = 0,
    this.timeLeft = 0,
    this.score = 0,
    this.totalScore = 0,
    this.showHint = false,
    this.hintsUsed = 0,
    this.maxHints = 3,
    this.phaseStartTime,
    this.attempts = const [],
    this.isPaused = false,
    this.errorMessage,
    this.isLoading = false,
  });

  SentenceBuildingGameState copyWith({
    String? gameId,
    SentenceBuildingPhase? phase,
    SentenceBuildingLevel? currentLevel,
    SentenceBuildingExercise? currentExercise,
    List<String>? availableWords,
    List<String>? selectedWords,
    int? currentExerciseIndex,
    int? timeLeft,
    int? score,
    int? totalScore,
    bool? showHint,
    int? hintsUsed,
    int? maxHints,
    DateTime? phaseStartTime,
    List<SentenceBuildingAttempt>? attempts,
    bool? isPaused,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SentenceBuildingGameState(
      gameId: gameId ?? this.gameId,
      phase: phase ?? this.phase,
      currentLevel: currentLevel ?? this.currentLevel,
      currentExercise: currentExercise ?? this.currentExercise,
      availableWords: availableWords ?? this.availableWords,
      selectedWords: selectedWords ?? this.selectedWords,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      score: score ?? this.score,
      totalScore: totalScore ?? this.totalScore,
      showHint: showHint ?? this.showHint,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      maxHints: maxHints ?? this.maxHints,
      phaseStartTime: phaseStartTime ?? this.phaseStartTime,
      attempts: attempts ?? this.attempts,
      isPaused: isPaused ?? this.isPaused,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if current sentence is complete
  bool get isSentenceComplete =>
      selectedWords.length == currentExercise.words.length;

  /// Get current sentence as string
  String get currentSentence => selectedWords.join(' ');

  /// Check if hints are available
  bool get canUseHint => hintsUsed < maxHints;

  /// Get progress percentage for current level
  double get levelProgress {
    if (currentLevel.exercises.isEmpty) return 0.0;
    return currentExerciseIndex / currentLevel.exercises.length;
  }
}

/// Game phases for sentence building
enum SentenceBuildingPhase {
  loading,
  preparation,
  instruction,
  building,
  checking,
  feedback,
  complete,
  paused,
  error,
}

/// Game session statistics
class SentenceBuildingSession {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final DifficultyLevel difficulty;
  final String levelId;
  final List<SentenceBuildingAttempt> attempts;
  final int totalScore;
  final int perfectSentences;
  final int partialSentences;
  final int incorrectSentences;
  final Duration totalTime;
  final int hintsUsed;
  final bool isCompleted;

  const SentenceBuildingSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.difficulty,
    required this.levelId,
    required this.attempts,
    required this.totalScore,
    required this.perfectSentences,
    required this.partialSentences,
    required this.incorrectSentences,
    required this.totalTime,
    required this.hintsUsed,
    required this.isCompleted,
  });

  /// Calculate accuracy percentage
  double get accuracy {
    if (attempts.isEmpty) return 0.0;
    final correct = attempts.where((a) => a.isCorrect).length;
    return (correct / attempts.length) * 100;
  }

  /// Calculate average time per sentence
  Duration get averageTimePerSentence {
    if (attempts.isEmpty) return Duration.zero;
    final totalMs = attempts
        .map((a) => a.timeToComplete.inMilliseconds)
        .reduce((a, b) => a + b);
    return Duration(milliseconds: totalMs ~/ attempts.length);
  }
}
