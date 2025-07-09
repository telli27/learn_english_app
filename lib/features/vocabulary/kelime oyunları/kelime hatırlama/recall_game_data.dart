import '../../models/word_models.dart';

/// Repository of recall game data including levels and exercises
class RecallGameData {
  /// Get all available recall game levels with their exercises
  static List<RecallGameLevel> getLevels() {
    return [
      RecallGameLevel(
        id: 1,
        title: 'beginner_title',
        description: 'basic_vocabulary',
        difficulty: 'easy_level',
        exercises: _generateLevel1Exercises(),
      ),
      RecallGameLevel(
        id: 2,
        title: 'intermediate_title',
        description: 'intermediate_vocabulary',
        difficulty: 'medium_level',
        exercises: _generateLevel2Exercises(),
      ),
      RecallGameLevel(
        id: 3,
        title: 'advanced_title',
        description: 'complex_words',
        difficulty: 'hard_level',
        exercises: _generateLevel3Exercises(),
      ),
    ];
  }

  /// Generate exercises for Level 1
  static List<RecallExercise> _generateLevel1Exercises() {
    // Basic vocabulary divided into 4 exercises
    final List<List<RecallWord>> wordSets = [
      // Exercise 1 - Basic nouns
      [
        RecallWord(english: 'apple', turkish: 'elma', hint: 'A fruit'),
        RecallWord(english: 'house', turkish: 'ev', hint: 'A place to live'),
        RecallWord(english: 'car', turkish: 'araba', hint: 'A vehicle'),
        RecallWord(english: 'water', turkish: 'su', hint: 'A drink'),
        RecallWord(english: 'book', turkish: 'kitap', hint: 'You read it'),
      ],
      // Exercise 2 - Animals
      [
        RecallWord(english: 'dog', turkish: 'köpek', hint: 'A pet that barks'),
        RecallWord(english: 'cat', turkish: 'kedi', hint: 'A pet that meows'),
        RecallWord(english: 'bird', turkish: 'kuş', hint: 'It can fly'),
        RecallWord(english: 'fish', turkish: 'balık', hint: 'Lives in water'),
        RecallWord(english: 'horse', turkish: 'at', hint: 'Used for riding'),
      ],
      // Exercise 3 - Colors
      [
        RecallWord(english: 'red', turkish: 'kırmızı', hint: 'Color of blood'),
        RecallWord(english: 'blue', turkish: 'mavi', hint: 'Color of the sky'),
        RecallWord(english: 'green', turkish: 'yeşil', hint: 'Color of grass'),
        RecallWord(
            english: 'yellow', turkish: 'sarı', hint: 'Color of the sun'),
        RecallWord(english: 'black', turkish: 'siyah', hint: 'Darkest color'),
      ],
      // Exercise 4 - Body parts
      [
        RecallWord(english: 'head', turkish: 'baş', hint: 'Top of your body'),
        RecallWord(
            english: 'hand', turkish: 'el', hint: 'You use it to grab things'),
        RecallWord(english: 'eye', turkish: 'göz', hint: 'Used for seeing'),
        RecallWord(
            english: 'nose', turkish: 'burun', hint: 'Used for smelling'),
        RecallWord(
            english: 'mouth',
            turkish: 'ağız',
            hint: 'Used for eating and speaking'),
      ],
    ];

    // Create exercise objects
    return List.generate(wordSets.length, (index) {
      return RecallExercise(
        id: 100 + index + 1,
        levelId: 1,
        orderInLevel: index + 1,
        words: wordSets[index],
        studyTimeSeconds: 20, // Easy level - short study time
        recallTimeSeconds: 40, // Easy level - more recall time
      );
    });
  }

  /// Generate exercises for Level 2
  static List<RecallExercise> _generateLevel2Exercises() {
    // Intermediate vocabulary divided into 4 exercises
    final List<List<RecallWord>> wordSets = [
      // Exercise 1 - Adjectives
      [
        RecallWord(
            english: 'beautiful',
            turkish: 'güzel',
            hint: 'Pleasant to look at'),
        RecallWord(english: 'difficult', turkish: 'zor', hint: 'Not easy'),
        RecallWord(
            english: 'important',
            turkish: 'önemli',
            hint: 'Having great significance'),
        RecallWord(english: 'expensive', turkish: 'pahalı', hint: 'High cost'),
        RecallWord(english: 'cheap', turkish: 'ucuz', hint: 'Low cost'),
        RecallWord(english: 'old', turkish: 'eski', hint: 'Not new'),
      ],
      // Exercise 2 - Emotions
      [
        RecallWord(english: 'happy', turkish: 'mutlu', hint: 'Feeling joy'),
        RecallWord(english: 'sad', turkish: 'üzgün', hint: 'Feeling sorrow'),
        RecallWord(english: 'angry', turkish: 'kızgın', hint: 'Feeling rage'),
        RecallWord(english: 'tired', turkish: 'yorgun', hint: 'Needing rest'),
        RecallWord(english: 'scared', turkish: 'korkmuş', hint: 'Feeling fear'),
        RecallWord(
            english: 'surprised',
            turkish: 'şaşırmış',
            hint: 'Unexpected reaction'),
      ],
      // Exercise 3 - Places
      [
        RecallWord(english: 'city', turkish: 'şehir', hint: 'Large urban area'),
        RecallWord(english: 'country', turkish: 'ülke', hint: 'Nation'),
        RecallWord(
            english: 'hospital', turkish: 'hastane', hint: 'Medical facility'),
        RecallWord(
            english: 'school',
            turkish: 'okul',
            hint: 'Educational institution'),
        RecallWord(
            english: 'restaurant', turkish: 'restoran', hint: 'Place to eat'),
        RecallWord(
            english: 'airport', turkish: 'havalimanı', hint: 'For air travel'),
      ],
      // Exercise 4 - Professions
      [
        RecallWord(
            english: 'doctor', turkish: 'doktor', hint: 'Medical professional'),
        RecallWord(
            english: 'teacher', turkish: 'öğretmen', hint: 'Educates others'),
        RecallWord(
            english: 'engineer',
            turkish: 'mühendis',
            hint: 'Designs or builds things'),
        RecallWord(
            english: 'lawyer', turkish: 'avukat', hint: 'Legal professional'),
        RecallWord(
            english: 'chef', turkish: 'aşçı', hint: 'Cooks professionally'),
        RecallWord(
            english: 'police', turkish: 'polis', hint: 'Law enforcement'),
      ],
    ];

    // Create exercise objects
    return List.generate(wordSets.length, (index) {
      return RecallExercise(
        id: 200 + index + 1,
        levelId: 2,
        orderInLevel: index + 1,
        words: wordSets[index],
        studyTimeSeconds: 25, // Medium level - moderate study time
        recallTimeSeconds: 50, // Medium level - moderate recall time
      );
    });
  }

  /// Generate exercises for Level 3
  static List<RecallExercise> _generateLevel3Exercises() {
    // Advanced vocabulary divided into 4 exercises
    final List<List<RecallWord>> wordSets = [
      // Exercise 1 - Abstract concepts
      [
        RecallWord(
            english: 'achievement',
            turkish: 'başarı',
            hint: 'Something accomplished'),
        RecallWord(
            english: 'development',
            turkish: 'gelişim',
            hint: 'Process of growth'),
        RecallWord(
            english: 'responsibility',
            turkish: 'sorumluluk',
            hint: 'Being accountable'),
        RecallWord(
            english: 'opportunity',
            turkish: 'fırsat',
            hint: 'Favorable chance'),
        RecallWord(
            english: 'freedom',
            turkish: 'özgürlük',
            hint: 'State of being free'),
        RecallWord(
            english: 'knowledge', turkish: 'bilgi', hint: 'What one knows'),
        RecallWord(
            english: 'experience',
            turkish: 'deneyim',
            hint: 'Practical knowledge'),
      ],
      // Exercise 2 - Personal qualities
      [
        RecallWord(
            english: 'confidence',
            turkish: 'özgüven',
            hint: 'Belief in oneself'),
        RecallWord(
            english: 'patience',
            turkish: 'sabır',
            hint: 'Ability to wait calmly'),
        RecallWord(
            english: 'creativity',
            turkish: 'yaratıcılık',
            hint: 'Being imaginative'),
        RecallWord(
            english: 'honesty', turkish: 'dürüstlük', hint: 'Being truthful'),
        RecallWord(
            english: 'loyalty', turkish: 'sadakat', hint: 'Being faithful'),
        RecallWord(
            english: 'determination',
            turkish: 'kararlılık',
            hint: 'Firmness of purpose'),
        RecallWord(
            english: 'curiosity', turkish: 'merak', hint: 'Desire to learn'),
      ],
      // Exercise 3 - Science and academics
      [
        RecallWord(
            english: 'hypothesis',
            turkish: 'hipotez',
            hint: 'Scientific assumption'),
        RecallWord(
            english: 'theory',
            turkish: 'teori',
            hint: 'Scientific explanation'),
        RecallWord(
            english: 'analysis',
            turkish: 'analiz',
            hint: 'Detailed examination'),
        RecallWord(
            english: 'research',
            turkish: 'araştırma',
            hint: 'Systematic investigation'),
        RecallWord(
            english: 'experiment', turkish: 'deney', hint: 'Scientific test'),
        RecallWord(
            english: 'conclusion', turkish: 'sonuç', hint: 'Final judgment'),
        RecallWord(
            english: 'methodology',
            turkish: 'metodoloji',
            hint: 'System of methods'),
      ],
      // Exercise 4 - Environment
      [
        RecallWord(
            english: 'sustainability',
            turkish: 'sürdürülebilirlik',
            hint: 'Avoiding resource depletion'),
        RecallWord(
            english: 'pollution',
            turkish: 'kirlilik',
            hint: 'Environmental contamination'),
        RecallWord(
            english: 'conservation',
            turkish: 'koruma',
            hint: 'Preservation of resources'),
        RecallWord(
            english: 'ecosystem',
            turkish: 'ekosistem',
            hint: 'Biological community'),
        RecallWord(
            english: 'biodiversity',
            turkish: 'biyoçeşitlilik',
            hint: 'Variety of life'),
        RecallWord(
            english: 'renewable',
            turkish: 'yenilenebilir',
            hint: 'Can be replenished'),
        RecallWord(
            english: 'recycling',
            turkish: 'geri dönüşüm',
            hint: 'Processing used materials'),
      ],
    ];

    // Create exercise objects
    return List.generate(wordSets.length, (index) {
      return RecallExercise(
        id: 300 + index + 1,
        levelId: 3,
        orderInLevel: index + 1,
        words: wordSets[index],
        studyTimeSeconds: 30, // Hard level - longer study time
        recallTimeSeconds: 60, // Hard level - longer recall time
      );
    });
  }
}
