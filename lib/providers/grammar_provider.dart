import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/data/grammar_data.dart';
import '../features/grammar/repositories/grammar_repository.dart';
import '../core/models/grammar_topic.dart';

class GrammarState {
  final List<GrammarTopic> topics;
  final bool isLoading;
  final String error;

  GrammarState({
    this.topics = const [],
    this.isLoading = false,
    this.error = '',
  });

  GrammarState copyWith({
    List<GrammarTopic>? topics,
    bool? isLoading,
    String? error,
  }) {
    return GrammarState(
      topics: topics ?? this.topics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final grammarProvider =
    StateNotifierProvider<GrammarNotifier, GrammarState>((ref) {
  return GrammarNotifier(GrammarRepository());
});

class GrammarNotifier extends StateNotifier<GrammarState> {
  GrammarNotifier(this._repository) : super(GrammarState());
  final GrammarRepository _repository;

  Future<void> loadGrammarTopic(String topicId) async {
    state = state.copyWith(isLoading: true);

    try {
      // Mock implementation - replace with actual data loading
      await Future.delayed(const Duration(seconds: 1));

      final topic = _repository.getGrammarTopics().firstWhere(
            (topic) => topic.id == topicId,
            orElse: () => throw Exception('Konu bulunamadı'),
          );

      state = state.copyWith(
        topics: [...state.topics, topic],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
