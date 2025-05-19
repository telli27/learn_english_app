class Flashcard {
  final String id;
  final String word;
  final String translation;
  final String example;
  final String exampleTranslation;
  final String imageUrl;
  final String category;
  final String difficulty;
  final bool isFavorite;

  Flashcard({
    required this.id,
    required this.word,
    required this.translation,
    required this.example,
    required this.exampleTranslation,
    this.imageUrl = '',
    required this.category,
    required this.difficulty,
    this.isFavorite = false,
  });

  Flashcard copyWith({
    String? id,
    String? word,
    String? translation,
    String? example,
    String? exampleTranslation,
    String? imageUrl,
    String? category,
    String? difficulty,
    bool? isFavorite,
  }) {
    return Flashcard(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'example': example,
      'exampleTranslation': exampleTranslation,
      'imageUrl': imageUrl,
      'category': category,
      'difficulty': difficulty,
      'isFavorite': isFavorite,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? '',
      word: map['word'] ?? '',
      translation: map['translation'] ?? '',
      example: map['example'] ?? '',
      exampleTranslation: map['exampleTranslation'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
