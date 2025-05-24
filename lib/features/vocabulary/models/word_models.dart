import 'package:flutter/foundation.dart';

/// A model representing a pair of words (English and Turkish)
class WordPair {
  final String english;
  final String turkish;

  const WordPair({
    required this.english,
    required this.turkish,
  });

  @override
  String toString() => 'WordPair(english: $english, turkish: $turkish)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordPair &&
        other.english == english &&
        other.turkish == turkish;
  }

  @override
  int get hashCode => english.hashCode ^ turkish.hashCode;
}

/// A model representing an exercise within a level
class Exercise {
  final int id;
  final int levelId;
  final int orderInLevel;
  final List<WordPair> wordPairs;

  const Exercise({
    required this.id,
    required this.levelId,
    required this.orderInLevel,
    required this.wordPairs,
  });

  @override
  String toString() =>
      'Exercise(id: $id, levelId: $levelId, orderInLevel: $orderInLevel, wordPairs: $wordPairs)';
}

/// A model representing a game level
class GameLevel {
  final int id;
  final String title;
  final String description;
  final String difficulty;
  final List<Exercise> exercises;

  const GameLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.exercises,
  });

  int get wordCount =>
      exercises.isNotEmpty ? exercises.first.wordPairs.length : 0;
  int get exerciseCount => exercises.length;

  @override
  String toString() =>
      'GameLevel(id: $id, title: $title, difficulty: $difficulty, exercises: $exercises)';
}

/// A model representing a word for the recall game with its status
class RecallWord {
  final String english;
  final String turkish;
  final String hint;
  bool isRevealed;
  bool isRecalled;

  RecallWord({
    required this.english,
    required this.turkish,
    this.hint = '',
    this.isRevealed = false,
    this.isRecalled = false,
  });

  @override
  String toString() =>
      'RecallWord(english: $english, turkish: $turkish, hint: $hint, isRevealed: $isRevealed, isRecalled: $isRecalled)';
}

/// A model representing a recall exercise
class RecallExercise {
  final int id;
  final int levelId;
  final int orderInLevel;
  final List<RecallWord> words;
  final int studyTimeSeconds;
  final int recallTimeSeconds;

  const RecallExercise({
    required this.id,
    required this.levelId,
    required this.orderInLevel,
    required this.words,
    this.studyTimeSeconds = 30,
    this.recallTimeSeconds = 60,
  });

  @override
  String toString() =>
      'RecallExercise(id: $id, levelId: $levelId, orderInLevel: $orderInLevel, words: $words, studyTime: $studyTimeSeconds, recallTime: $recallTimeSeconds)';
}

/// A model representing a recall game level
class RecallGameLevel {
  final int id;
  final String title;
  final String description;
  final String difficulty;
  final List<RecallExercise> exercises;

  const RecallGameLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.exercises,
  });

  int get wordCount => exercises.isNotEmpty ? exercises.first.words.length : 0;
  int get exerciseCount => exercises.length;

  @override
  String toString() =>
      'RecallGameLevel(id: $id, title: $title, difficulty: $difficulty, exercises: $exercises)';
}
