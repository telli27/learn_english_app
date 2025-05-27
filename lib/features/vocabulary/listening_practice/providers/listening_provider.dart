import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listening_models.dart';
import '../data/listening_data.dart';

/// Provider for listening levels
final listeningLevelsProvider = Provider<List<ListeningLevel>>((ref) {
  return ListeningData.levels;
});

/// Provider for listening progress
final listeningProgressProvider =
    StateNotifierProvider<ListeningProgressNotifier, ListeningProgress>((ref) {
  return ListeningProgressNotifier();
});

/// Provider for current listening session
final listeningSessionProvider =
    StateNotifierProvider<ListeningSessionNotifier, ListeningSession?>((ref) {
  return ListeningSessionNotifier();
});

/// Provider for TTS state
final ttsStateProvider =
    StateNotifierProvider<TTSStateNotifier, TTSState>((ref) {
  return TTSStateNotifier();
});

/// Provider to check if a level is unlocked
final isLevelUnlockedProvider =
    Provider.family<bool, ListeningLevel>((ref, level) {
  final notifier = ref.watch(listeningProgressProvider.notifier);
  return notifier.isLevelUnlocked(level);
});

/// Listening progress notifier
class ListeningProgressNotifier extends StateNotifier<ListeningProgress> {
  ListeningProgressNotifier() : super(const ListeningProgress(userId: 'user1'));

  /// Check if level is unlocked
  bool isLevelUnlocked(ListeningLevel level) {
    return level.isUnlocked;
  }

  /// Complete a story
  void completeStory(String storyId, int comprehensionScore) {
    if (!state.completedStoryIds.contains(storyId)) {
      final updatedCompletedStories = [...state.completedStoryIds, storyId];
      final newTotalCompleted = state.totalStoriesCompleted + 1;

      // Calculate new average score
      final totalScore =
          (state.averageComprehensionScore * state.totalStoriesCompleted) +
              comprehensionScore;
      final newAverageScore = totalScore / newTotalCompleted;

      state = state.copyWith(
        completedStoryIds: updatedCompletedStories,
        totalStoriesCompleted: newTotalCompleted,
        averageComprehensionScore: newAverageScore,
        lastPracticeDate: DateTime.now(),
      );
    }
  }

  /// Update listening time
  void updateListeningTime(Duration additionalTime) {
    state = state.copyWith(
      totalListeningTime: state.totalListeningTime + additionalTime,
    );
  }

  /// Update topic progress
  void updateTopicProgress(ListeningTopic topic) {
    final currentProgress = state.topicProgress[topic] ?? 0;
    final updatedTopicProgress =
        Map<ListeningTopic, int>.from(state.topicProgress);
    updatedTopicProgress[topic] = currentProgress + 1;

    state = state.copyWith(
      topicProgress: updatedTopicProgress,
    );
  }

  /// Update difficulty progress
  void updateDifficultyProgress(ListeningDifficulty difficulty) {
    final currentProgress = state.difficultyProgress[difficulty] ?? 0;
    final updatedDifficultyProgress =
        Map<ListeningDifficulty, int>.from(state.difficultyProgress);
    updatedDifficultyProgress[difficulty] = currentProgress + 1;

    state = state.copyWith(
      difficultyProgress: updatedDifficultyProgress,
    );
  }

  /// Set preferred speed
  void setPreferredSpeed(AudioSpeed speed) {
    state = state.copyWith(preferredSpeed: speed);
  }
}

/// Listening session notifier
class ListeningSessionNotifier extends StateNotifier<ListeningSession?> {
  ListeningSessionNotifier() : super(null);

  /// Start a new listening session
  void startSession(String storyId) {
    state = ListeningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      storyId: storyId,
      startedAt: DateTime.now(),
    );
  }

  /// Update session with answer
  void updateAnswer(String questionId, String answer) {
    if (state != null) {
      final updatedAnswers = Map<String, String>.from(state!.questionAnswers);
      updatedAnswers[questionId] = answer;

      state = state!.copyWith(questionAnswers: updatedAnswers);
    }
  }

  /// Complete session
  void completeSession(int score) {
    if (state != null) {
      state = state!.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        comprehensionScore: score,
      );
    }
  }

  /// Update playback speed
  void updatePlaybackSpeed(AudioSpeed speed) {
    if (state != null) {
      state = state!.copyWith(playbackSpeed: speed);
    }
  }

  /// Increment pause count
  void incrementPauseCount() {
    if (state != null) {
      state = state!.copyWith(pauseCount: state!.pauseCount + 1);
    }
  }

  /// Increment replay count
  void incrementReplayCount() {
    if (state != null) {
      state = state!.copyWith(replayCount: state!.replayCount + 1);
    }
  }

  /// Update total listening time
  void updateTotalListeningTime(Duration time) {
    if (state != null) {
      state = state!.copyWith(totalListeningTime: time);
    }
  }

  /// End session
  void endSession() {
    state = null;
  }
}

/// TTS State model
class TTSState {
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final AudioSpeed currentSpeed;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? currentText;
  final String? error;

  const TTSState({
    this.isPlaying = false,
    this.isPaused = false,
    this.isLoading = false,
    this.currentSpeed = AudioSpeed.slow,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentText,
    this.error,
  });

  TTSState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    AudioSpeed? currentSpeed,
    Duration? currentPosition,
    Duration? totalDuration,
    String? currentText,
    String? error,
  }) {
    return TTSState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentText: currentText ?? this.currentText,
      error: error ?? this.error,
    );
  }
}

/// TTS State notifier
class TTSStateNotifier extends StateNotifier<TTSState> {
  TTSStateNotifier() : super(const TTSState());

  /// Start playing text
  void startPlaying(String text) {
    state = state.copyWith(
      isPlaying: true,
      isPaused: false,
      isLoading: false,
      currentText: text,
      error: null,
    );
  }

  /// Pause playback
  void pause() {
    state = state.copyWith(
      isPlaying: false,
      isPaused: true,
    );
  }

  /// Resume playback
  void resume() {
    state = state.copyWith(
      isPlaying: true,
      isPaused: false,
    );
  }

  /// Stop playback
  void stop() {
    state = state.copyWith(
      isPlaying: false,
      isPaused: false,
      currentPosition: Duration.zero,
    );
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Update position
  void updatePosition(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  /// Set total duration
  void setTotalDuration(Duration duration) {
    state = state.copyWith(totalDuration: duration);
  }

  /// Change speed
  void changeSpeed(AudioSpeed speed) {
    state = state.copyWith(currentSpeed: speed);
  }

  /// Set error
  void setError(String error) {
    state = state.copyWith(
      error: error,
      isPlaying: false,
      isLoading: false,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
