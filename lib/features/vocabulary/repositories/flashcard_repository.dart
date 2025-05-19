import 'dart:math';
import '../models/flashcard.dart';

class FlashcardRepository {
  // Dummy data for initial testing
  final List<Flashcard> _dummyFlashcards = [
    Flashcard(
      id: '1',
      word: 'Apple',
      translation: 'Elma',
      example: 'I eat an apple every day.',
      exampleTranslation: 'Her gün bir elma yerim.',
      category: 'Food',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/apple--v1.png',
    ),
    Flashcard(
      id: '2',
      word: 'Book',
      translation: 'Kitap',
      example: 'I read a book before bed.',
      exampleTranslation: 'Yatmadan önce kitap okurum.',
      category: 'Education',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/book--v1.png',
    ),
    Flashcard(
      id: '3',
      word: 'Computer',
      translation: 'Bilgisayar',
      example: 'I work on my computer every day.',
      exampleTranslation: 'Her gün bilgisayarımda çalışırım.',
      category: 'Technology',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/computer--v1.png',
    ),
    Flashcard(
      id: '4',
      word: 'House',
      translation: 'Ev',
      example: 'My house is near the park.',
      exampleTranslation: 'Evim parkın yanında.',
      category: 'Home',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/home--v1.png',
    ),
    Flashcard(
      id: '5',
      word: 'Car',
      translation: 'Araba',
      example: 'I drive my car to work.',
      exampleTranslation: 'İşe arabamla giderim.',
      category: 'Transportation',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/car--v1.png',
    ),
    Flashcard(
      id: '6',
      word: 'Telephone',
      translation: 'Telefon',
      example: 'I forgot my telephone at home.',
      exampleTranslation: 'Telefonumu evde unuttum.',
      category: 'Technology',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/phone--v1.png',
    ),
    Flashcard(
      id: '7',
      word: 'Water',
      translation: 'Su',
      example: 'I drink a lot of water every day.',
      exampleTranslation: 'Her gün çok su içerim.',
      category: 'Food',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/water--v1.png',
    ),
    Flashcard(
      id: '8',
      word: 'Coffee',
      translation: 'Kahve',
      example: 'I drink coffee in the morning.',
      exampleTranslation: 'Sabahları kahve içerim.',
      category: 'Food',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/coffee--v1.png',
    ),
    Flashcard(
      id: '9',
      word: 'Time',
      translation: 'Zaman',
      example: 'Time flies when you are having fun.',
      exampleTranslation: 'Eğlenirken zaman uçup gider.',
      category: 'Abstract',
      difficulty: 'Intermediate',
      imageUrl: 'https://img.icons8.com/color/96/time--v1.png',
    ),
    Flashcard(
      id: '10',
      word: 'Money',
      translation: 'Para',
      example: 'I need to save money for vacation.',
      exampleTranslation: 'Tatil için para biriktirmem gerekiyor.',
      category: 'Finance',
      difficulty: 'Intermediate',
      imageUrl: 'https://img.icons8.com/color/96/money--v1.png',
    ),
  ];

  // List for user's custom flashcards
  final List<Flashcard> _customFlashcards = [];

  // Get all built-in flashcards
  Future<List<Flashcard>> getFlashcards() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyFlashcards;
  }

  // Get user's custom flashcards
  Future<List<Flashcard>> getCustomFlashcards() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _customFlashcards;
  }

  // Get unique categories
  Future<List<String>> getCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Extract unique categories from both standard and custom cards
    final allFlashcards = [..._dummyFlashcards, ..._customFlashcards];
    final categories =
        allFlashcards.map((card) => card.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  // Update a flashcard
  Future<void> updateFlashcard(Flashcard updatedCard) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Check in regular flashcards
    final standardIndex =
        _dummyFlashcards.indexWhere((card) => card.id == updatedCard.id);
    if (standardIndex != -1) {
      _dummyFlashcards[standardIndex] = updatedCard;
      return;
    }

    // Check in custom flashcards
    final customIndex =
        _customFlashcards.indexWhere((card) => card.id == updatedCard.id);
    if (customIndex != -1) {
      _customFlashcards[customIndex] = updatedCard;
    }
  }

  // Add a new custom flashcard
  Future<Flashcard> addCustomFlashcard(Flashcard flashcard) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    // Generate a unique ID if not provided
    final newId = flashcard.id.isEmpty ? _generateId() : flashcard.id;
    final newCard = flashcard.copyWith(id: newId);

    _customFlashcards.add(newCard);
    return newCard;
  }

  // Delete a flashcard
  Future<void> deleteFlashcard(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Remove from custom flashcards (we only allow deleting custom cards)
    _customFlashcards.removeWhere((card) => card.id == id);
  }

  // Helper method to generate a random ID
  String _generateId() {
    final random = Random();
    return 'custom_${random.nextInt(1000000)}';
  }
}
