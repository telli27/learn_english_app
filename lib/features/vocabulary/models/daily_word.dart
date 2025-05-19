import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class DailyWord {
  final String id;
  final String word;
  final String translation;
  final String example;
  final String exampleTranslation;
  final String category;
  final String difficulty;
  final String imageUrl;
  final DateTime date;
  final bool saved;

  DailyWord({
    String? id,
    required this.word,
    required this.translation,
    required this.example,
    required this.exampleTranslation,
    required this.category,
    required this.difficulty,
    this.imageUrl = '',
    DateTime? date,
    this.saved = false,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  DailyWord copyWith({
    String? word,
    String? translation,
    String? example,
    String? exampleTranslation,
    String? category,
    String? difficulty,
    String? imageUrl,
    DateTime? date,
    bool? saved,
  }) {
    return DailyWord(
      id: id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      saved: saved ?? this.saved,
    );
  }

  // Sample daily words for different days
  static List<DailyWord> getSampleDailyWords() {
    return [
      DailyWord(
        word: "Serendipity",
        translation: "Şans eseri",
        example: "Meeting my wife was pure serendipity.",
        exampleTranslation: "Eşimle tanışmam tam bir şans eseriydi.",
        category: "Abstract",
        difficulty: "Advanced",
        imageUrl:
            "https://images.unsplash.com/photo-1501139083538-0139583c060f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        date: DateTime.now(),
      ),
      DailyWord(
        word: "Scrumptious",
        translation: "Çok lezzetli",
        example: "The cake was absolutely scrumptious.",
        exampleTranslation: "Pasta kesinlikle çok lezzetliydi.",
        category: "Food",
        difficulty: "Intermediate",
        imageUrl:
            "https://images.unsplash.com/photo-1578985545062-69928b1d9587?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DailyWord(
        word: "Meticulous",
        translation: "Titiz",
        example: "He is meticulous about his work.",
        exampleTranslation: "İşi konusunda çok titizdir.",
        category: "Abstract",
        difficulty: "Intermediate",
        imageUrl:
            "https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DailyWord(
        word: "Resilience",
        translation: "Dayanıklılık",
        example: "Her resilience in the face of adversity was remarkable.",
        exampleTranslation:
            "Zorluklar karşısındaki dayanıklılığı dikkat çekiciydi.",
        category: "Abstract",
        difficulty: "Advanced",
        imageUrl:
            "https://images.unsplash.com/photo-1520006403909-838d6b92c22e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DailyWord(
        word: "Quintessential",
        translation: "Tipik, özünü yansıtan",
        example: "This is a quintessential example of her work.",
        exampleTranslation: "Bu, onun çalışmalarının tipik bir örneğidir.",
        category: "Abstract",
        difficulty: "Advanced",
        imageUrl:
            "https://images.unsplash.com/photo-1522199755839-a2bacb67c546?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      DailyWord(
        word: "Ephemeral",
        translation: "Kısa ömürlü, geçici",
        example: "The beauty of cherry blossoms is ephemeral.",
        exampleTranslation: "Kiraz çiçeklerinin güzelliği geçicidir.",
        category: "Abstract",
        difficulty: "Advanced",
        imageUrl:
            "https://images.unsplash.com/photo-1522748906645-95d8adfd52c7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DailyWord(
        word: "Wanderlust",
        translation: "Gezme tutkusu",
        example: "Her wanderlust took her to many exotic places.",
        exampleTranslation: "Gezme tutkusu onu birçok egzotik yere götürdü.",
        category: "Abstract",
        difficulty: "Intermediate",
        imageUrl:
            "https://images.unsplash.com/photo-1500835556837-99ac94a94552?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        date: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }
}
