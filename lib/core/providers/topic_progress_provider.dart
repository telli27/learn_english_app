import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic_progress.dart';
import '../services/topic_progress_service.dart';
import '../../auth/providers/auth_provider.dart';

// Provider for the TopicProgressService
final topicProgressServiceProvider = Provider<TopicProgressService>((ref) {
  return TopicProgressService();
});

// State class for topic progress
class TopicProgressState {
  final List<TopicProgress> progressList;
  final bool isLoading;
  final String? errorMessage;

  TopicProgressState({
    this.progressList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TopicProgressState copyWith({
    List<TopicProgress>? progressList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TopicProgressState(
      progressList: progressList ?? this.progressList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  // Get progress for a specific topic
  double getProgressForTopic(String topicId) {
    final topicProgress =
        progressList.where((p) => p.topicId == topicId).toList();
    if (topicProgress.isEmpty) {
      return 0.0;
    }
    return topicProgress.first.progressPercentage;
  }
}

// StateNotifier for topic progress
class TopicProgressNotifier extends StateNotifier<TopicProgressState> {
  final TopicProgressService _service;
  final Ref _ref;

  TopicProgressNotifier(this._service, this._ref) : super(TopicProgressState());

  // Load all progress for current user
  Future<void> loadUserProgress() async {
    final authState = _ref.read(authProvider);

    // If not logged in, just return empty state
    if (!authState.isLoggedIn || authState.userId == null) {
      state = TopicProgressState(
        progressList: [],
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final progressList = await _service.getUserProgress(authState.userId!);
      state = state.copyWith(
        progressList: progressList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading progress: ${e.toString()}',
      );
    }
  }

  // Update progress for a specific topic
  Future<bool> updateTopicProgress(
      String topicId, double progressPercentage, int lastPosition) async {
    final authState = _ref.read(authProvider);

    // If not logged in, we can't update progress
    if (!authState.isLoggedIn || authState.userId == null) {
      state = state.copyWith(
        errorMessage: 'User not logged in',
      );
      return false;
    }

    try {
      final success = await _service.updateTopicProgress(
          authState.userId!, topicId, progressPercentage, lastPosition);

      if (success) {
        // Refresh the progress list
        await loadUserProgress();
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error updating progress: ${e.toString()}',
      );
      return false;
    }
  }
}

// Provider for topic progress
final topicProgressProvider =
    StateNotifierProvider<TopicProgressNotifier, TopicProgressState>((ref) {
  final service = ref.watch(topicProgressServiceProvider);
  return TopicProgressNotifier(service, ref);
});
