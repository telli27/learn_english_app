import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/daily_word.dart';
import '../models/flashcard.dart';

class DailyWordNotifier extends StateNotifier<AsyncValue<List<DailyWord>>> {
  int _currentStreak = 0;
  DateTime? _lastCompleted;
  Set<String> _savedWordIds = {};
  Map<String, String> _wordMemos = {};

  DailyWordNotifier() : super(const AsyncValue.loading()) {
    loadDailyWords();
    _loadStreakData();
    _loadSavedWords();
    _loadMemos();
  }

  Future<void> loadDailyWords() async {
    try {
      final words = DailyWord.getSampleDailyWords();
      // Apply saved status to words from preferences
      final updatedWords = words.map((word) {
        if (_savedWordIds.contains(word.id)) {
          return word.copyWith(
            saved: true,
            memo: _wordMemos[word.id] ?? '',
          );
        }
        return word;
      }).toList();

      state = AsyncValue.data(updatedWords);
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
      _updateStreak();
    });
  }

  void saveWordMemo(String wordId, String memo) {
    state.whenData((words) {
      final updatedWords = words.map((word) {
        if (word.id == wordId) {
          return word.copyWith(memo: memo);
        }
        return word;
      }).toList();
      state = AsyncValue.data(updatedWords);
      _saveMemoToDisk(wordId, memo);
    });
  }

  Future<void> playWordAudio(String audioUrl) async {
    // This is a placeholder for audio playback functionality
    // Implement with audio player package
    print('Playing audio: $audioUrl');
  }

  int getCurrentStreak() {
    return _currentStreak;
  }

  double getWeeklyProgress() {
    return state.maybeWhen(
      data: (words) {
        // Get only words from the last 7 days
        final lastWeekWords = words.where((word) {
          final now = DateTime.now();
          final difference = now.difference(word.date).inDays;
          return difference <= 7;
        }).toList();

        return DailyWord.getWeeklyProgressPercentage(lastWeekWords);
      },
      orElse: () => 0.0,
    );
  }

  Future<void> _loadStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStreak = prefs.getInt('daily_word_streak') ?? 0;

      final lastCompletedString = prefs.getString('last_completed_day');
      if (lastCompletedString != null) {
        _lastCompleted = DateTime.parse(lastCompletedString);
      }
    } catch (e) {
      print('Error loading streak data: $e');
    }
  }

  Future<void> _updateStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayFormatted = DateFormat('yyyy-MM-dd').format(today);

      if (_lastCompleted == null) {
        // First time completing a word
        _currentStreak = 1;
        await prefs.setInt('daily_word_streak', _currentStreak);
        await prefs.setString('last_completed_day', todayFormatted);
        _lastCompleted = today;
        return;
      }

      final lastCompletedFormatted =
          DateFormat('yyyy-MM-dd').format(_lastCompleted!);

      if (lastCompletedFormatted == todayFormatted) {
        // Already completed today, no change to streak
        return;
      }

      // Check if last completion was yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayFormatted = DateFormat('yyyy-MM-dd').format(yesterday);

      if (lastCompletedFormatted == yesterdayFormatted) {
        // Continuing streak
        _currentStreak += 1;
      } else {
        // Broke the streak, starting over
        _currentStreak = 1;
      }

      await prefs.setInt('daily_word_streak', _currentStreak);
      await prefs.setString('last_completed_day', todayFormatted);
      _lastCompleted = today;
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  Future<void> _loadSavedWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWords = prefs.getStringList('saved_daily_words') ?? [];
      _savedWordIds = Set.from(savedWords);
    } catch (e) {
      print('Error loading saved words: $e');
    }
  }

  Future<void> _loadMemos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // Load all memos (keys that start with 'memo_')
      for (final key in keys) {
        if (key.startsWith('memo_')) {
          final wordId = key.substring(5); // Remove 'memo_' prefix
          final memo = prefs.getString(key) ?? '';
          _wordMemos[wordId] = memo;
        }
      }
    } catch (e) {
      print('Error loading memos: $e');
    }
  }

  Future<void> _saveToDisk(String wordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWords = prefs.getStringList('saved_daily_words') ?? [];
      if (!savedWords.contains(wordId)) {
        savedWords.add(wordId);
        await prefs.setStringList('saved_daily_words', savedWords);
        _savedWordIds.add(wordId);
      }
    } catch (e) {
      print('Error saving daily word: $e');
    }
  }

  Future<void> _saveMemoToDisk(String wordId, String memo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('memo_$wordId', memo);
      _wordMemos[wordId] = memo;
    } catch (e) {
      print('Error saving memo: $e');
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

// Current streak provider
final streakProvider = Provider<int>((ref) {
  return ref.watch(dailyWordProvider.notifier).getCurrentStreak();
});

// Weekly progress provider (percentage of words saved in the last week)
final weeklyProgressProvider = Provider<double>((ref) {
  return ref.watch(dailyWordProvider.notifier).getWeeklyProgress();
});
