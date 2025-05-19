import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/flashcard.dart';

// Model for learning contexts
class LearningContext {
  final String situation;
  final List<String> sentences;
  final String audioUrl;
  final IconData situationIcon;
  List<ComprehensionQuestion> questions;

  LearningContext({
    required this.situation,
    required this.sentences,
    required this.audioUrl,
    this.situationIcon = Icons.location_on,
    List<ComprehensionQuestion>? questions,
  }) : questions = questions ?? [];
}

// Model for comprehension questions
class ComprehensionQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  ComprehensionQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// Learning progress state
class LearningProgress {
  final Map<String, int> wordProgress;
  final int totalWords;
  final int masteredWords;

  LearningProgress({
    required this.wordProgress,
    this.totalWords = 0,
    this.masteredWords = 0,
  });

  LearningProgress copyWith({
    Map<String, int>? wordProgress,
    int? totalWords,
    int? masteredWords,
  }) {
    return LearningProgress(
      wordProgress: wordProgress ?? this.wordProgress,
      totalWords: totalWords ?? this.totalWords,
      masteredWords: masteredWords ?? this.masteredWords,
    );
  }
}

// Provider for learning contexts
class ImmersiveContextNotifier extends StateNotifier<List<LearningContext>> {
  ImmersiveContextNotifier() : super([]);

  // Mock method to get contexts for a word
  Future<List<LearningContext>> getContextsForWord(String word) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Return mock contexts
    return [
      LearningContext(
        situation: 'At a restaurant',
        sentences: [
          'The food at this restaurant is delicious.',
          'I would like to order $word for dinner.',
          'The waiter recommended the $word special.',
          'We enjoyed our meal very much.',
        ],
        audioUrl: 'assets/audio/context_1.mp3',
        situationIcon: Icons.restaurant,
      ),
      LearningContext(
        situation: 'At work',
        sentences: [
          'I need to finish this project by tomorrow.',
          'My colleague used $word in his presentation.',
          'The meeting was about the new $word initiative.',
          'We discussed how to implement the strategy.',
        ],
        audioUrl: 'assets/audio/context_2.mp3',
        situationIcon: Icons.work,
      ),
    ];
  }

  // Mock method to play audio
  void playAudio(String audioUrl) {
    // In a real app, this would play audio
    print('Playing audio: $audioUrl');
  }

  // Mock method to stop audio
  void stopAudio() {
    // In a real app, this would stop audio
    print('Stopping audio');
  }
}

// Provider for learning progress
class LearningProgressNotifier
    extends StateNotifier<AsyncValue<LearningProgress>> {
  LearningProgressNotifier()
      : super(AsyncData(LearningProgress(
            wordProgress: {}, totalWords: 50, masteredWords: 12)));

  // Record correct answer for a word
  void recordCorrectAnswer(String flashcardId, String word) {
    state.whenData((currentProgress) {
      final currentWordProgress = currentProgress.wordProgress[word] ?? 0;
      final updatedWordProgress = currentWordProgress + 5; // Increment by 5%

      final updatedProgress = {...currentProgress.wordProgress};
      updatedProgress[word] =
          updatedWordProgress > 100 ? 100 : updatedWordProgress;

      // Update mastered words count if this word just reached 100%
      int masteredCount = currentProgress.masteredWords;
      if (updatedWordProgress >= 100 && currentWordProgress < 100) {
        masteredCount++;
      }

      state = AsyncData(
        currentProgress.copyWith(
          wordProgress: updatedProgress,
          masteredWords: masteredCount,
        ),
      );
    });
  }
}

// Providers
final immersiveContextProvider =
    StateNotifierProvider<ImmersiveContextNotifier, List<LearningContext>>(
        (ref) {
  return ImmersiveContextNotifier();
});

final learningProgressProvider = StateNotifierProvider<LearningProgressNotifier,
    AsyncValue<LearningProgress>>((ref) {
  return LearningProgressNotifier();
});

// Additional providers for streak and weekly progress
final streakProvider = Provider<int>((ref) => 12); // Mock streak
final weeklyProgressProvider = Provider<double>((ref) => 0.7); // 70% progress
