import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../repositories/flashcard_repository.dart';

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return FlashcardRepository();
});

final flashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  final repository = ref.watch(flashcardRepositoryProvider);
  return repository.getFlashcards();
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(flashcardRepositoryProvider);
  return repository.getCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  final flashcards = await ref.watch(flashcardsProvider.future);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null || selectedCategory == 'All') {
    return flashcards;
  }

  return flashcards.where((card) => card.category == selectedCategory).toList();
});

final favoriteFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  final flashcards = await ref.watch(flashcardsProvider.future);
  return flashcards.where((card) => card.isFavorite).toList();
});

// Provider for custom user-created flashcards
final customFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  final repository = ref.watch(flashcardRepositoryProvider);
  return repository.getCustomFlashcards();
});

class FlashcardNotifier extends StateNotifier<AsyncValue<List<Flashcard>>> {
  final FlashcardRepository repository;

  FlashcardNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadFlashcards();
  }

  Future<void> loadFlashcards() async {
    try {
      state = const AsyncValue.loading();
      final flashcards = await repository.getFlashcards();
      state = AsyncValue.data(flashcards);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleFavorite(String id) async {
    final currentState = state;
    if (currentState is AsyncData<List<Flashcard>>) {
      final flashcards = currentState.value;
      final index = flashcards.indexWhere((card) => card.id == id);
      if (index != -1) {
        final updatedCard = flashcards[index].copyWith(
          isFavorite: !flashcards[index].isFavorite,
        );
        final updatedList = List<Flashcard>.from(flashcards);
        updatedList[index] = updatedCard;
        state = AsyncValue.data(updatedList);

        // Save the change to the repository
        await repository.updateFlashcard(updatedCard);
      }
    }
  }

  // Add a new custom flashcard
  Future<void> addFlashcard(Flashcard flashcard) async {
    try {
      final newCard = await repository.addCustomFlashcard(flashcard);

      final currentState = state;
      if (currentState is AsyncData<List<Flashcard>>) {
        final updatedList = [...currentState.value, newCard];
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      // Error handling
      print('Error adding flashcard: $e');
    }
  }

  // Update an existing flashcard
  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      await repository.updateFlashcard(flashcard);

      final currentState = state;
      if (currentState is AsyncData<List<Flashcard>>) {
        final flashcards = currentState.value;
        final index = flashcards.indexWhere((card) => card.id == flashcard.id);

        if (index != -1) {
          final updatedList = List<Flashcard>.from(flashcards);
          updatedList[index] = flashcard;
          state = AsyncValue.data(updatedList);
        }
      }
    } catch (e) {
      // Error handling
      print('Error updating flashcard: $e');
    }
  }

  // Delete a flashcard
  Future<void> deleteFlashcard(String id) async {
    try {
      await repository.deleteFlashcard(id);

      final currentState = state;
      if (currentState is AsyncData<List<Flashcard>>) {
        final updatedList =
            currentState.value.where((card) => card.id != id).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      // Error handling
      print('Error deleting flashcard: $e');
    }
  }
}

final flashcardNotifierProvider =
    StateNotifierProvider<FlashcardNotifier, AsyncValue<List<Flashcard>>>(
        (ref) {
  final repository = ref.watch(flashcardRepositoryProvider);
  return FlashcardNotifier(repository);
});
