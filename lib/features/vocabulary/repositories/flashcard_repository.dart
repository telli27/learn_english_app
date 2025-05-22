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
    // Added more flashcards
    Flashcard(
      id: '11',
      word: 'Friend',
      translation: 'Arkadaş',
      example: 'She is my best friend.',
      exampleTranslation: 'O benim en iyi arkadaşım.',
      category: 'Relationships',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/group.png',
    ),
    Flashcard(
      id: '12',
      word: 'School',
      translation: 'Okul',
      example: 'I go to school every weekday.',
      exampleTranslation: 'Her hafta içi okula giderim.',
      category: 'Education',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/school.png',
    ),
    Flashcard(
      id: '13',
      word: 'Teacher',
      translation: 'Öğretmen',
      example: 'My teacher helps me learn English.',
      exampleTranslation: 'Öğretmenim İngilizce öğrenmeme yardımcı olur.',
      category: 'Education',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/teacher.png',
    ),
    Flashcard(
      id: '14',
      word: 'Family',
      translation: 'Aile',
      example: 'I love spending time with my family.',
      exampleTranslation: 'Ailemle zaman geçirmeyi severim.',
      category: 'Relationships',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/family.png',
    ),
    Flashcard(
      id: '15',
      word: 'Food',
      translation: 'Yemek',
      example: 'Turkish food is delicious.',
      exampleTranslation: 'Türk yemeği lezzetlidir.',
      category: 'Food',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/meal.png',
    ),
    Flashcard(
      id: '16',
      word: 'City',
      translation: 'Şehir',
      example: 'Istanbul is a beautiful city.',
      exampleTranslation: 'İstanbul güzel bir şehirdir.',
      category: 'Travel',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/city.png',
    ),
    Flashcard(
      id: '17',
      word: 'Country',
      translation: 'Ülke',
      example: 'Turkey is a beautiful country.',
      exampleTranslation: 'Türkiye güzel bir ülkedir.',
      category: 'Travel',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/country.png',
    ),
    Flashcard(
      id: '18',
      word: 'Language',
      translation: 'Dil',
      example: 'I want to learn a new language.',
      exampleTranslation: 'Yeni bir dil öğrenmek istiyorum.',
      category: 'Education',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/language.png',
    ),
    Flashcard(
      id: '19',
      word: 'Sun',
      translation: 'Güneş',
      example: 'The sun rises in the east.',
      exampleTranslation: 'Güneş doğudan doğar.',
      category: 'Nature',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/sun.png',
    ),
    Flashcard(
      id: '20',
      word: 'Moon',
      translation: 'Ay',
      example: 'The moon was full last night.',
      exampleTranslation: 'Dün gece dolunay vardı.',
      category: 'Nature',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/moon.png',
    ),
    Flashcard(
      id: '21',
      word: 'Star',
      translation: 'Yıldız',
      example: 'I can see many stars in the sky tonight.',
      exampleTranslation: 'Bu gece gökyüzünde birçok yıldız görebiliyorum.',
      category: 'Nature',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/star.png',
    ),
    Flashcard(
      id: '22',
      word: 'Phone',
      translation: 'Telefon',
      example: 'I need to charge my phone.',
      exampleTranslation: 'Telefonumu şarj etmem gerekiyor.',
      category: 'Technology',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/smartphone.png',
    ),
    Flashcard(
      id: '23',
      word: 'Internet',
      translation: 'İnternet',
      example: 'I need internet to do my research.',
      exampleTranslation: 'Araştırma yapmak için internete ihtiyacım var.',
      category: 'Technology',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/internet.png',
    ),
    Flashcard(
      id: '24',
      word: 'Music',
      translation: 'Müzik',
      example: 'I listen to music every day.',
      exampleTranslation: 'Her gün müzik dinlerim.',
      category: 'Entertainment',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/musical-notes.png',
    ),
    Flashcard(
      id: '25',
      word: 'Movie',
      translation: 'Film',
      example: 'We watched a movie last night.',
      exampleTranslation: 'Dün gece bir film izledik.',
      category: 'Entertainment',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/movie.png',
    ),
    Flashcard(
      id: '26',
      word: 'Health',
      translation: 'Sağlık',
      example: 'Health is more important than money.',
      exampleTranslation: 'Sağlık paradan daha önemlidir.',
      category: 'Health',
      difficulty: 'Intermediate',
      imageUrl: 'https://img.icons8.com/color/96/health-book.png',
    ),
    Flashcard(
      id: '27',
      word: 'Hospital',
      translation: 'Hastane',
      example: 'My mother works at the hospital.',
      exampleTranslation: 'Annem hastanede çalışıyor.',
      category: 'Health',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/hospital.png',
    ),
    Flashcard(
      id: '28',
      word: 'Doctor',
      translation: 'Doktor',
      example: 'I need to see a doctor.',
      exampleTranslation: 'Bir doktora görünmem gerekiyor.',
      category: 'Health',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/doctor-male.png',
    ),
    Flashcard(
      id: '29',
      word: 'Store',
      translation: 'Mağaza',
      example: 'I bought this shirt at that store.',
      exampleTranslation: 'Bu gömleği o mağazadan aldım.',
      category: 'Shopping',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/shop.png',
    ),
    Flashcard(
      id: '30',
      word: 'Market',
      translation: 'Pazar',
      example: 'I buy fresh vegetables at the market.',
      exampleTranslation: 'Pazardan taze sebzeler alırım.',
      category: 'Shopping',
      difficulty: 'Beginner',
      imageUrl: 'https://img.icons8.com/color/96/market-square.png',
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
