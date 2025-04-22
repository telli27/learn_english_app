import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/grammar/controllers/grammar_controller.dart';
import '../features/grammar/repositories/grammar_repository.dart';
import '../features/auth/controllers/theme_controller.dart';
import '../core/models/grammar_topic.dart';

// Grammar providers
final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  return GrammarRepository();
});

final grammarControllerProvider =
    StateNotifierProvider<GrammarController, GrammarState>((ref) {
  final repository = ref.watch(grammarRepositoryProvider);
  return GrammarController(repository);
});

final grammarTopicsProvider = Provider<List<GrammarTopic>>((ref) {
  final state = ref.watch(grammarControllerProvider);
  return state.topics;
});

final currentTopicProvider = Provider<GrammarTopic?>((ref) {
  final state = ref.watch(grammarControllerProvider);
  return state.currentTopic;
});

final currentSubtopicProvider = Provider<GrammarSubtopic?>((ref) {
  final state = ref.watch(grammarControllerProvider);
  return state.currentSubtopic;
});

final isLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(grammarControllerProvider);
  return state.isLoading;
});

final errorMessageProvider = Provider<String?>((ref) {
  final state = ref.watch(grammarControllerProvider);
  return state.errorMessage;
});

// Theme providers
final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeControllerProvider);
  return themeMode == ThemeMode.dark;
});
