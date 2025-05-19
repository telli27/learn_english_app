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
  final String pronunciation; // IPA pronunciation
  final String audioUrl; // URL to audio file for pronunciation
  final String usageFrequency; // Common, Rare, etc.
  final List<String> synonyms; // Related words with similar meaning
  final List<String> antonyms; // Words with opposite meanings
  final String memo; // User's personal note about the word

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
    this.pronunciation = '',
    this.audioUrl = '',
    this.usageFrequency = 'Common',
    this.synonyms = const [],
    this.antonyms = const [],
    this.memo = '',
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
    String? pronunciation,
    String? audioUrl,
    String? usageFrequency,
    List<String>? synonyms,
    List<String>? antonyms,
    String? memo,
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
      pronunciation: pronunciation ?? this.pronunciation,
      audioUrl: audioUrl ?? this.audioUrl,
      usageFrequency: usageFrequency ?? this.usageFrequency,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      memo: memo ?? this.memo,
    );
  }

  // Add method to save user's memo
  DailyWord addMemo(String newMemo) {
    return copyWith(memo: newMemo);
  }

  // Static method to get daily word progress percentage for week
  static double getWeeklyProgressPercentage(List<DailyWord> words) {
    if (words.isEmpty) return 0.0;

    final savedCount = words.where((word) => word.saved).length;
    return savedCount / words.length;
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
        pronunciation: "/ˌser.ənˈdɪp.ə.ti/",
        audioUrl: "https://audio-samples.github.io/samples/mp3/serendipity.mp3",
        usageFrequency: "Uncommon",
        synonyms: ["Luck", "Fortuity", "Chance"],
        antonyms: ["Misfortune", "Design", "Intent"],
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
        pronunciation: "/ˈskrʌmp.ʃəs/",
        audioUrl: "https://audio-samples.github.io/samples/mp3/scrumptious.mp3",
        usageFrequency: "Common",
        synonyms: ["Delicious", "Tasty", "Appetizing"],
        antonyms: ["Disgusting", "Unappetizing", "Tasteless"],
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
        pronunciation: "/məˈtɪk.jə.ləs/",
        audioUrl: "https://audio-samples.github.io/samples/mp3/meticulous.mp3",
        usageFrequency: "Common",
        synonyms: ["Careful", "Precise", "Thorough"],
        antonyms: ["Careless", "Sloppy", "Negligent"],
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
        pronunciation: "/rɪˈzɪl.i.əns/",
        audioUrl: "https://audio-samples.github.io/samples/mp3/resilience.mp3",
        usageFrequency: "Common",
        synonyms: ["Toughness", "Flexibility", "Adaptability"],
        antonyms: ["Fragility", "Weakness", "Vulnerability"],
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
        pronunciation: "/ˌkwɪn.təˈsen.ʃəl/",
        audioUrl:
            "https://audio-samples.github.io/samples/mp3/quintessential.mp3",
        usageFrequency: "Uncommon",
        synonyms: ["Classic", "Archetypal", "Typical"],
        antonyms: ["Atypical", "Unrepresentative", "Uncharacteristic"],
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
        pronunciation: "/ɪˈfem.ər.əl/",
        audioUrl: "https://audio-samples.github.io/samples/mp3/ephemeral.mp3",
        usageFrequency: "Uncommon",
        synonyms: ["Fleeting", "Transient", "Momentary"],
        antonyms: ["Permanent", "Enduring", "Eternal"],
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
        pronunciation: "/ˈwɒn.dəˌlʌst/",
        audioUrl: "https://audio-samples.github.io/samples/mp3/wanderlust.mp3",
        usageFrequency: "Common",
        synonyms: ["Travel-bug", "Restlessness", "Itchy feet"],
        antonyms: ["Homebody", "Settledness", "Contentment"],
      ),
    ];
  }
}
