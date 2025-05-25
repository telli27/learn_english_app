import 'game_enums.dart';

/// A vocabulary word with comprehensive data
class VocabularyWord {
  final String id;
  final String english;
  final String turkish;
  final String phonetic;
  final String category;
  final DifficultyLevel difficulty;
  final String hint;
  final String example;
  final String audioUrl;
  final bool isFavorite;
  final int timesStudied;
  final int timesCorrect;
  final int timesWrong;

  const VocabularyWord({
    required this.id,
    required this.english,
    required this.turkish,
    required this.phonetic,
    required this.category,
    required this.difficulty,
    this.hint = '',
    this.example = '',
    this.audioUrl = '',
    this.isFavorite = false,
    this.timesStudied = 0,
    this.timesCorrect = 0,
    this.timesWrong = 0,
  });

  VocabularyWord copyWith({
    String? id,
    String? english,
    String? turkish,
    String? phonetic,
    String? category,
    DifficultyLevel? difficulty,
    String? hint,
    String? example,
    String? audioUrl,
    bool? isFavorite,
    int? timesStudied,
    int? timesCorrect,
    int? timesWrong,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      english: english ?? this.english,
      turkish: turkish ?? this.turkish,
      phonetic: phonetic ?? this.phonetic,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      hint: hint ?? this.hint,
      example: example ?? this.example,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      timesStudied: timesStudied ?? this.timesStudied,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesWrong: timesWrong ?? this.timesWrong,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyWord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VocabularyWord(id: $id, english: $english, turkish: $turkish)';
}

/// Player achievement model
class Achievement {
  final String id;
  final AchievementType type;
  final DateTime unlockedAt;
  final String title;
  final String description;
  final bool isNotified;

  const Achievement({
    required this.id,
    required this.type,
    required this.unlockedAt,
    required this.title,
    required this.description,
    this.isNotified = false,
  });

  Achievement copyWith({
    String? id,
    AchievementType? type,
    DateTime? unlockedAt,
    String? title,
    String? description,
    bool? isNotified,
  }) {
    return Achievement(
      id: id ?? this.id,
      type: type ?? this.type,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      isNotified: isNotified ?? this.isNotified,
    );
  }
}

/// Game exercise with enhanced metadata
class GameExercise {
  final String id;
  final String levelId;
  final int order;
  final String title;
  final String description;
  final List<VocabularyWord> words;
  final DifficultyLevel difficulty;
  final int studyTimeSeconds;
  final int recallTimeSeconds;
  final int targetScore;
  final List<String> tags;

  const GameExercise({
    required this.id,
    required this.levelId,
    required this.order,
    required this.title,
    required this.description,
    required this.words,
    required this.difficulty,
    this.studyTimeSeconds = 30,
    this.recallTimeSeconds = 60,
    this.targetScore = 0,
    this.tags = const [],
  });

  GameExercise copyWith({
    String? id,
    String? levelId,
    int? order,
    String? title,
    String? description,
    List<VocabularyWord>? words,
    DifficultyLevel? difficulty,
    int? studyTimeSeconds,
    int? recallTimeSeconds,
    int? targetScore,
    List<String>? tags,
  }) {
    return GameExercise(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      order: order ?? this.order,
      title: title ?? this.title,
      description: description ?? this.description,
      words: words ?? this.words,
      difficulty: difficulty ?? this.difficulty,
      studyTimeSeconds: studyTimeSeconds ?? this.studyTimeSeconds,
      recallTimeSeconds: recallTimeSeconds ?? this.recallTimeSeconds,
      targetScore: targetScore ?? this.targetScore,
      tags: tags ?? this.tags,
    );
  }
}

/// Game level with comprehensive metadata
class GameLevel {
  final String id;
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final List<GameExercise> exercises;
  final String imageUrl;
  final int requiredScore;
  final bool isUnlocked;
  final bool isCompleted;
  final int bestScore;
  final int stars;

  const GameLevel({
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
  });

  int get totalWords =>
      exercises.fold(0, (sum, exercise) => sum + exercise.words.length);
  int get exerciseCount => exercises.length;

  GameLevel copyWith({
    String? id,
    String? title,
    String? description,
    DifficultyLevel? difficulty,
    List<GameExercise>? exercises,
    String? imageUrl,
    int? requiredScore,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestScore,
    int? stars,
  }) {
    return GameLevel(
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
    );
  }
}

/// Game state for word recall game
class RecallGameState {
  final String gameId;
  final RecallGamePhase phase;
  final GameLevel currentLevel;
  final GameExercise currentExercise;
  final List<VocabularyWord> currentWords;
  final int currentWordIndex;
  final int score;
  final int timeLeft;
  final int streak;
  final bool isPaused;
  final List<VocabularyWord> studiedWords;
  final List<VocabularyWord> correctWords;
  final List<VocabularyWord> incorrectWords;
  final List<VocabularyWord> skippedWords;
  final String currentInput;
  final bool showHint;
  final DateTime? phaseStartTime;

  const RecallGameState({
    required this.gameId,
    required this.phase,
    required this.currentLevel,
    required this.currentExercise,
    required this.currentWords,
    this.currentWordIndex = 0,
    this.score = 0,
    this.timeLeft = 0,
    this.streak = 0,
    this.isPaused = false,
    this.studiedWords = const [],
    this.correctWords = const [],
    this.incorrectWords = const [],
    this.skippedWords = const [],
    this.currentInput = '',
    this.showHint = false,
    this.phaseStartTime,
  });

  RecallGameState copyWith({
    String? gameId,
    RecallGamePhase? phase,
    GameLevel? currentLevel,
    GameExercise? currentExercise,
    List<VocabularyWord>? currentWords,
    int? currentWordIndex,
    int? score,
    int? timeLeft,
    int? streak,
    bool? isPaused,
    List<VocabularyWord>? studiedWords,
    List<VocabularyWord>? correctWords,
    List<VocabularyWord>? incorrectWords,
    List<VocabularyWord>? skippedWords,
    String? currentInput,
    bool? showHint,
    DateTime? phaseStartTime,
  }) {
    return RecallGameState(
      gameId: gameId ?? this.gameId,
      phase: phase ?? this.phase,
      currentLevel: currentLevel ?? this.currentLevel,
      currentExercise: currentExercise ?? this.currentExercise,
      currentWords: currentWords ?? this.currentWords,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      streak: streak ?? this.streak,
      isPaused: isPaused ?? this.isPaused,
      studiedWords: studiedWords ?? this.studiedWords,
      correctWords: correctWords ?? this.correctWords,
      incorrectWords: incorrectWords ?? this.incorrectWords,
      skippedWords: skippedWords ?? this.skippedWords,
      currentInput: currentInput ?? this.currentInput,
      showHint: showHint ?? this.showHint,
      phaseStartTime: phaseStartTime ?? this.phaseStartTime,
    );
  }

  double get accuracy =>
      currentWords.isEmpty ? 0 : correctWords.length / currentWords.length;

  double get progressPercentage => currentWords.isEmpty
      ? 0
      : (correctWords.length + incorrectWords.length + skippedWords.length) /
          currentWords.length;
}

/// Word recall attempt data
class RecallAttempt {
  final String wordId;
  final String userInput;
  final String correctAnswer;
  final bool isCorrect;
  final DateTime attemptTime;
  final int timeToAnswer;
  final bool usedHint;
  final bool wasSkipped;

  const RecallAttempt({
    required this.wordId,
    required this.userInput,
    required this.correctAnswer,
    required this.isCorrect,
    required this.attemptTime,
    required this.timeToAnswer,
    this.usedHint = false,
    this.wasSkipped = false,
  });
}
