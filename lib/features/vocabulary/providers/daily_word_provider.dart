import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_word.dart';
import '../models/flashcard.dart';

class DailyWordNotifier extends StateNotifier<AsyncValue<List<DailyWord>>> {
  DailyWordNotifier() : super(const AsyncValue.loading()) {
    loadDailyWords();
  }

  Future<void> loadDailyWords() async {
    try {
      state = AsyncValue.data(DailyWord.getSampleDailyWords());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void saveDailyWord(String wordId) {
    state.whenData((words) {
      final updatedWords = words.map((word) {
        if (word.id == wordId) {
          return word.copyWith(saved: true);
        }
        return word;
      }).toList();
      state = AsyncValue.data(updatedWords);
      _saveToDisk(wordId);
    });
  }

  Future<void> _saveToDisk(String wordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWords = prefs.getStringList('saved_daily_words') ?? [];
      if (!savedWords.contains(wordId)) {
        savedWords.add(wordId);
        await prefs.setStringList('saved_daily_words', savedWords);
      }
    } catch (e) {
      print('Error saving daily word: $e');
    }
  }

  // Convert a daily word to a flashcard for adding to custom flashcards
  Flashcard dailyWordToFlashcard(DailyWord word) {
    return Flashcard(
      id: word.id,
      word: word.word,
      translation: word.translation,
      example: word.example,
      exampleTranslation: word.exampleTranslation,
      category: word.category,
      difficulty: word.difficulty,
      imageUrl: word.imageUrl,
      isFavorite: false,
    );
  }
}

final dailyWordProvider =
    StateNotifierProvider<DailyWordNotifier, AsyncValue<List<DailyWord>>>(
  (ref) => DailyWordNotifier(),
);

// Today's word provider
final todayWordProvider = Provider<AsyncValue<DailyWord>>((ref) {
  final dailyWordsAsync = ref.watch(dailyWordProvider);

  return dailyWordsAsync.when(
    data: (words) {
      // Find today's word (the first one in the list)
      if (words.isNotEmpty) {
        return AsyncValue.data(words.first);
      }
      return const AsyncValue.error(
          "No daily word available", StackTrace.empty);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Weekly words provider (past 7 days)
final weeklyWordsProvider = Provider<AsyncValue<List<DailyWord>>>((ref) {
  final dailyWordsAsync = ref.watch(dailyWordProvider);

  return dailyWordsAsync.when(
    data: (words) {
      // Get words from the past 7 days
      return AsyncValue.data(words.take(7).toList());
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
