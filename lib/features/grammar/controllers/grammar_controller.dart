import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/grammar_topic.dart';
import '../repositories/grammar_repository.dart';

// State class for Grammar
class GrammarState {
  final bool isLoading;
  final List<GrammarTopic> topics;
  final GrammarTopic? currentTopic;
  final GrammarSubtopic? currentSubtopic;
  final String? errorMessage;

  const GrammarState({
    this.isLoading = false,
    this.topics = const [],
    this.currentTopic,
    this.currentSubtopic,
    this.errorMessage,
  });

  GrammarState copyWith({
    bool? isLoading,
    List<GrammarTopic>? topics,
    GrammarTopic? currentTopic,
    GrammarSubtopic? currentSubtopic,
    String? errorMessage,
  }) {
    return GrammarState(
      isLoading: isLoading ?? this.isLoading,
      topics: topics ?? this.topics,
      currentTopic: currentTopic ?? this.currentTopic,
      currentSubtopic: currentSubtopic ?? this.currentSubtopic,
      errorMessage: errorMessage,
    );
  }
}

class GrammarController extends StateNotifier<GrammarState> {
  final GrammarRepository _repository;
  bool _isLoadLocked = false;

  GrammarController(this._repository) : super(const GrammarState());

  // Load all grammar topics
  Future<void> loadGrammarTopics() async {
    // If already loading or lock is active, return
    if (state.isLoading || _isLoadLocked) return;

    // If topics are already loaded and no error, return
    if (state.topics.isNotEmpty && state.errorMessage == null) return;

    try {
      _isLoadLocked = true;
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        topics: [],
        currentTopic: null,
        currentSubtopic: null,
      );

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 300));

      // Load data
      final topics = _repository.getGrammarTopics();

      state = state.copyWith(
        topics: topics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Konular yüklenirken hata oluştu: ${e.toString()}',
      );
    } finally {
      _isLoadLocked = false;
    }
  }

  // Load a specific grammar topic by ID
  Future<void> loadGrammarTopic(String topicId) async {
    // If already loading or lock is active, return
    if (state.isLoading || _isLoadLocked) return;

    // If the same topic is already loaded and no error, return
    if (state.currentTopic != null &&
        state.currentTopic!.id == topicId &&
        state.errorMessage == null) {
      return;
    }

    try {
      _isLoadLocked = true;
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentTopic: null,
        currentSubtopic: null,
      );

      // If topics are not loaded, load them
      if (state.topics.isEmpty) {
        final topics = _repository.getGrammarTopics();
        state = state.copyWith(topics: topics);
      }

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 300));

      // Find the topic by ID
      final topic = _repository.getGrammarTopic(topicId);
      if (topic == null) {
        throw Exception('Konu bulunamadı');
      }

      state = state.copyWith(
        currentTopic: topic,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Konu yüklenirken hata oluştu: ${e.toString()}',
      );
    } finally {
      _isLoadLocked = false;
    }
  }

  // Load a specific grammar subtopic by topic ID and subtopic ID
  Future<void> loadGrammarSubtopic(String topicId, String subtopicId) async {
    // If already loading or lock is active, return
    if (state.isLoading || _isLoadLocked) return;

    // If the same subtopic is already loaded and no error, return
    if (state.currentTopic != null &&
        state.currentTopic!.id == topicId &&
        state.currentSubtopic != null &&
        state.currentSubtopic!.id == subtopicId &&
        state.errorMessage == null) {
      return;
    }

    try {
      _isLoadLocked = true;
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentSubtopic: null,
      );

      // If topics are not loaded or different topic, load the topic
      if (state.currentTopic == null || state.currentTopic!.id != topicId) {
        // If topics are not loaded, load them
        if (state.topics.isEmpty) {
          final topics = _repository.getGrammarTopics();
          state = state.copyWith(topics: topics);
        }

        // Find the topic by ID
        final topic = _repository.getGrammarTopic(topicId);
        if (topic == null) {
          throw Exception('Konu bulunamadı');
        }

        state = state.copyWith(currentTopic: topic);
      }

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 300));

      // Find the subtopic
      final subtopic = _repository.getGrammarSubtopic(topicId, subtopicId);
      if (subtopic == null) {
        throw Exception('Alt konu bulunamadı');
      }

      state = state.copyWith(
        currentSubtopic: subtopic,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Alt konu yüklenirken hata oluştu: ${e.toString()}',
      );
    } finally {
      _isLoadLocked = false;
    }
  }
}
