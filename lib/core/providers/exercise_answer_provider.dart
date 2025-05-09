import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../features/grammar/repositories/exercise_answer_repository.dart';
import '../models/exercise_answer.dart';

// State for exercise answers
class ExerciseAnswerState {
  final bool isLoading;
  final List<ExerciseAnswer> userAnswers;
  final List<String> correctExerciseIds;
  final String? errorMessage;

  const ExerciseAnswerState({
    this.isLoading = false,
    this.userAnswers = const [],
    this.correctExerciseIds = const [],
    this.errorMessage,
  });

  ExerciseAnswerState copyWith({
    bool? isLoading,
    List<ExerciseAnswer>? userAnswers,
    List<String>? correctExerciseIds,
    String? errorMessage,
  }) {
    return ExerciseAnswerState(
      isLoading: isLoading ?? this.isLoading,
      userAnswers: userAnswers ?? this.userAnswers,
      correctExerciseIds: correctExerciseIds ?? this.correctExerciseIds,
      errorMessage: errorMessage,
    );
  }
}

class ExerciseAnswerNotifier extends StateNotifier<ExerciseAnswerState> {
  final ExerciseAnswerRepository _repository;

  ExerciseAnswerNotifier(this._repository) : super(const ExerciseAnswerState());

  // Save an exercise answer
  Future<bool> saveExerciseAnswer({
    required String userId,
    required String topicId,
    required String subtopicId,
    required String exerciseId,
    required bool isCorrect,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Debug prints to track the function execution
    debugPrint(
        'Saving exercise answer: userId=$userId, exerciseId=$exerciseId, isCorrect=$isCorrect');
    debugPrint('Current correctExerciseIds: ${state.correctExerciseIds}');

    try {
      await _repository.saveExerciseAnswer(
        userId: userId,
        topicId: topicId,
        subtopicId: subtopicId,
        exerciseId: exerciseId,
        isCorrect: isCorrect,
      );

      // If answer is correct, add to list of correct IDs
      if (isCorrect) {
        final updatedIds = List<String>.from(state.correctExerciseIds);
        if (!updatedIds.contains(exerciseId)) {
          updatedIds.add(exerciseId);
          debugPrint('Added $exerciseId to correctExerciseIds');
        } else {
          debugPrint('$exerciseId already in correctExerciseIds');
        }
        state = state.copyWith(
          isLoading: false,
          correctExerciseIds: updatedIds,
        );
        debugPrint('Updated correctExerciseIds: ${state.correctExerciseIds}');
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
    } catch (e) {
      debugPrint('Error saving exercise answer: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error saving exercise answer: ${e.toString()}',
      );
      return false;
    }
  }

  // Load all user's correct exercise IDs
  Future<void> loadUserCorrectExerciseIds(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final correctIds = await _repository.getUserCorrectExerciseIds(userId);
      state = state.copyWith(
        isLoading: false,
        correctExerciseIds: correctIds,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading correct exercise IDs: ${e.toString()}',
      );
    }
  }

  // Check if an exercise is completed correctly
  bool isExerciseCompletedCorrectly(String exerciseId) {
    return state.correctExerciseIds.contains(exerciseId);
  }

  // Get list of exercises that need to be shown to user
  // (excludes correctly completed exercises)
  List<String> getExercisesToShow(List<String> allExerciseIds) {
    return allExerciseIds
        .where((id) => !state.correctExerciseIds.contains(id))
        .toList();
  }
}

// Provider for the exercise answer repository
final exerciseAnswerRepositoryProvider = Provider<ExerciseAnswerRepository>(
  (ref) => ExerciseAnswerRepository(),
);

// Provider for the exercise answer state
final exerciseAnswerProvider =
    StateNotifierProvider<ExerciseAnswerNotifier, ExerciseAnswerState>(
  (ref) => ExerciseAnswerNotifier(
    ref.watch(exerciseAnswerRepositoryProvider),
  ),
);
