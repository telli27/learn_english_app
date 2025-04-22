import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grammar_topic.dart';
import '../repositories/grammar_repository.dart';

// Repository provider
final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  return GrammarRepository();
});

// State class - immutable
class GrammarState {
  final List<GrammarTopic> topics;
  final GrammarTopic? selectedTopic;
  final GrammarSubtopic? selectedSubtopic;
  final bool isLoading;
  final String? errorMessage;

  const GrammarState({
    this.topics = const [],
    this.selectedTopic,
    this.selectedSubtopic,
    this.isLoading = false,
    this.errorMessage,
  });

  GrammarState copyWith({
    List<GrammarTopic>? topics,
    GrammarTopic? selectedTopic,
    GrammarSubtopic? selectedSubtopic,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GrammarState(
      topics: topics ?? this.topics,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      selectedSubtopic: selectedSubtopic ?? this.selectedSubtopic,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// StateNotifier
class GrammarNotifier extends StateNotifier<GrammarState> {
  final GrammarRepository _repository;

  GrammarNotifier(this._repository) : super(const GrammarState()) {
    loadAllTopics();
  }

  Future<void> loadAllTopics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final topics = await _repository.getGrammarTopics();
      state = state.copyWith(
        topics: topics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load topics: ${e.toString()}',
      );
    }
  }

  Future<void> loadTopic(String topicId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final topic = await _repository.getGrammarTopic(topicId);
      state = state.copyWith(
        selectedTopic: topic,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load topic: ${e.toString()}',
      );
    }
  }

  Future<void> loadSubtopic(String topicId, String subtopicId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final subtopic =
          await _repository.getGrammarSubtopic(topicId, subtopicId);
      state = state.copyWith(
        selectedSubtopic: subtopic,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load subtopic: ${e.toString()}',
      );
    }
  }

  void selectSubtopic(GrammarSubtopic subtopic) {
    state = state.copyWith(selectedSubtopic: subtopic);
  }

  void clearSelection() {
    state = state.copyWith(
      selectedTopic: null,
      selectedSubtopic: null,
    );
  }
}

// Main provider
final grammarProvider =
    StateNotifierProvider<GrammarNotifier, GrammarState>((ref) {
  final repository = ref.watch(grammarRepositoryProvider);
  return GrammarNotifier(repository);
});

// Convenience selectors
final topicsProvider = Provider<List<GrammarTopic>>((ref) {
  return ref.watch(grammarProvider).topics;
});

final selectedTopicProvider = Provider<GrammarTopic?>((ref) {
  return ref.watch(grammarProvider).selectedTopic;
});

final selectedSubtopicProvider = Provider<GrammarSubtopic?>((ref) {
  return ref.watch(grammarProvider).selectedSubtopic;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(grammarProvider).isLoading;
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(grammarProvider).errorMessage;
});
