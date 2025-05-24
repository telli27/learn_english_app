import '../models/word_models.dart';

/// Repository of all game data including levels and exercises
class GameData {
  /// Get all available game levels with their exercises
  static List<GameLevel> getLevels() {
    return [
      GameLevel(
        id: 1,
        title: 'Başlangıç',
        description: 'Temel kelimeler',
        difficulty: 'Kolay',
        exercises: _generateLevel1Exercises(),
      ),
      GameLevel(
        id: 2,
        title: 'Orta Seviye',
        description: 'Günlük kelimeler',
        difficulty: 'Orta',
        exercises: _generateLevel2Exercises(),
      ),
      GameLevel(
        id: 3,
        title: 'İleri',
        description: 'Kompleks kelimeler',
        difficulty: 'Zor',
        exercises: _generateLevel3Exercises(),
      ),
    ];
  }

  /// Generate exercises for Level 1
  static List<Exercise> _generateLevel1Exercises() {
    // Basic vocabulary divided into 5 exercises
    final List<List<WordPair>> wordSets = [
      // Exercise 1
      [
        WordPair(english: 'apple', turkish: 'elma'),
        WordPair(english: 'house', turkish: 'ev'),
        WordPair(english: 'car', turkish: 'araba'),
        WordPair(english: 'water', turkish: 'su'),
        WordPair(english: 'book', turkish: 'kitap'),
      ],
      // Exercise 2
      [
        WordPair(english: 'dog', turkish: 'köpek'),
        WordPair(english: 'cat', turkish: 'kedi'),
        WordPair(english: 'tree', turkish: 'ağaç'),
        WordPair(english: 'sun', turkish: 'güneş'),
        WordPair(english: 'moon', turkish: 'ay'),
      ],
      // Exercise 3
      [
        WordPair(english: 'red', turkish: 'kırmızı'),
        WordPair(english: 'blue', turkish: 'mavi'),
        WordPair(english: 'green', turkish: 'yeşil'),
        WordPair(english: 'yellow', turkish: 'sarı'),
        WordPair(english: 'black', turkish: 'siyah'),
      ],
      // Exercise 4
      [
        WordPair(english: 'bread', turkish: 'ekmek'),
        WordPair(english: 'cheese', turkish: 'peynir'),
        WordPair(english: 'milk', turkish: 'süt'),
        WordPair(english: 'egg', turkish: 'yumurta'),
        WordPair(english: 'meat', turkish: 'et'),
      ],
      // Exercise 5
      [
        WordPair(english: 'hand', turkish: 'el'),
        WordPair(english: 'head', turkish: 'baş'),
        WordPair(english: 'eye', turkish: 'göz'),
        WordPair(english: 'nose', turkish: 'burun'),
        WordPair(english: 'mouth', turkish: 'ağız'),
      ],
    ];

    // Create exercise objects
    return List.generate(wordSets.length, (index) {
      return Exercise(
        id: 100 + index + 1,
        levelId: 1,
        orderInLevel: index + 1,
        wordPairs: wordSets[index],
      );
    });
  }

  /// Generate exercises for Level 2
  static List<Exercise> _generateLevel2Exercises() {
    // Intermediate vocabulary divided into 6 exercises
    final List<List<WordPair>> wordSets = [
      // Exercise 1
      [
        WordPair(english: 'beautiful', turkish: 'güzel'),
        WordPair(english: 'difficult', turkish: 'zor'),
        WordPair(english: 'important', turkish: 'önemli'),
        WordPair(english: 'yesterday', turkish: 'dün'),
        WordPair(english: 'tomorrow', turkish: 'yarın'),
        WordPair(english: 'quickly', turkish: 'hızlıca'),
      ],
      // Exercise 2
      [
        WordPair(english: 'happy', turkish: 'mutlu'),
        WordPair(english: 'sad', turkish: 'üzgün'),
        WordPair(english: 'angry', turkish: 'kızgın'),
        WordPair(english: 'tired', turkish: 'yorgun'),
        WordPair(english: 'busy', turkish: 'meşgul'),
        WordPair(english: 'free', turkish: 'boş'),
      ],
      // Exercise 3
      [
        WordPair(english: 'city', turkish: 'şehir'),
        WordPair(english: 'country', turkish: 'ülke'),
        WordPair(english: 'road', turkish: 'yol'),
        WordPair(english: 'building', turkish: 'bina'),
        WordPair(english: 'airport', turkish: 'havalimanı'),
        WordPair(english: 'station', turkish: 'istasyon'),
      ],
      // Exercise 4
      [
        WordPair(english: 'doctor', turkish: 'doktor'),
        WordPair(english: 'teacher', turkish: 'öğretmen'),
        WordPair(english: 'student', turkish: 'öğrenci'),
        WordPair(english: 'engineer', turkish: 'mühendis'),
        WordPair(english: 'artist', turkish: 'sanatçı'),
        WordPair(english: 'police', turkish: 'polis'),
      ],
      // Exercise 5
      [
        WordPair(english: 'laptop', turkish: 'dizüstü bilgisayar'),
        WordPair(english: 'phone', turkish: 'telefon'),
        WordPair(english: 'camera', turkish: 'kamera'),
        WordPair(english: 'television', turkish: 'televizyon'),
        WordPair(english: 'internet', turkish: 'internet'),
        WordPair(english: 'computer', turkish: 'bilgisayar'),
      ],
      // Exercise 6
      [
        WordPair(english: 'monday', turkish: 'pazartesi'),
        WordPair(english: 'tuesday', turkish: 'salı'),
        WordPair(english: 'wednesday', turkish: 'çarşamba'),
        WordPair(english: 'thursday', turkish: 'perşembe'),
        WordPair(english: 'friday', turkish: 'cuma'),
        WordPair(english: 'weekend', turkish: 'hafta sonu'),
      ],
    ];

    // Create exercise objects
    return List.generate(wordSets.length, (index) {
      return Exercise(
        id: 200 + index + 1,
        levelId: 2,
        orderInLevel: index + 1,
        wordPairs: wordSets[index],
      );
    });
  }

  /// Generate exercises for Level 3
  static List<Exercise> _generateLevel3Exercises() {
    // Advanced vocabulary divided into 7 exercises
    final List<List<WordPair>> wordSets = [
      // Exercise 1
      [
        WordPair(english: 'achievement', turkish: 'başarı'),
        WordPair(english: 'development', turkish: 'gelişim'),
        WordPair(english: 'responsibility', turkish: 'sorumluluk'),
        WordPair(english: 'opportunity', turkish: 'fırsat'),
        WordPair(english: 'concentration', turkish: 'konsantrasyon'),
        WordPair(english: 'perspective', turkish: 'bakış açısı'),
        WordPair(english: 'environment', turkish: 'çevre'),
      ],
      // Exercise 2
      [
        WordPair(english: 'ambition', turkish: 'hırs'),
        WordPair(english: 'confidence', turkish: 'özgüven'),
        WordPair(english: 'determination', turkish: 'kararlılık'),
        WordPair(english: 'persistence', turkish: 'azim'),
        WordPair(english: 'enthusiasm', turkish: 'şevk'),
        WordPair(english: 'creativity', turkish: 'yaratıcılık'),
        WordPair(english: 'innovation', turkish: 'yenilik'),
      ],
      // Exercise 3
      [
        WordPair(english: 'democracy', turkish: 'demokrasi'),
        WordPair(english: 'government', turkish: 'hükümet'),
        WordPair(english: 'politics', turkish: 'siyaset'),
        WordPair(english: 'election', turkish: 'seçim'),
        WordPair(english: 'economy', turkish: 'ekonomi'),
        WordPair(english: 'society', turkish: 'toplum'),
        WordPair(english: 'culture', turkish: 'kültür'),
      ],
      // Exercise 4
      [
        WordPair(english: 'experiment', turkish: 'deney'),
        WordPair(english: 'research', turkish: 'araştırma'),
        WordPair(english: 'analysis', turkish: 'analiz'),
        WordPair(english: 'theory', turkish: 'teori'),
        WordPair(english: 'hypothesis', turkish: 'hipotez'),
        WordPair(english: 'conclusion', turkish: 'sonuç'),
        WordPair(english: 'discovery', turkish: 'keşif'),
      ],
      // Exercise 5
      [
        WordPair(english: 'agriculture', turkish: 'tarım'),
        WordPair(english: 'industry', turkish: 'endüstri'),
        WordPair(english: 'technology', turkish: 'teknoloji'),
        WordPair(english: 'manufacturing', turkish: 'imalat'),
        WordPair(english: 'transportation', turkish: 'ulaşım'),
        WordPair(english: 'commerce', turkish: 'ticaret'),
        WordPair(english: 'investment', turkish: 'yatırım'),
      ],
      // Exercise 6
      [
        WordPair(english: 'psychology', turkish: 'psikoloji'),
        WordPair(english: 'philosophy', turkish: 'felsefe'),
        WordPair(english: 'sociology', turkish: 'sosyoloji'),
        WordPair(english: 'anthropology', turkish: 'antropoloji'),
        WordPair(english: 'linguistics', turkish: 'dilbilim'),
        WordPair(english: 'archaeology', turkish: 'arkeoloji'),
        WordPair(english: 'history', turkish: 'tarih'),
      ],
      // Exercise 7
      [
        WordPair(english: 'sustainability', turkish: 'sürdürülebilirlik'),
        WordPair(english: 'biodiversity', turkish: 'biyoçeşitlilik'),
        WordPair(english: 'conservation', turkish: 'koruma'),
        WordPair(english: 'ecosystem', turkish: 'ekosistem'),
        WordPair(english: 'pollution', turkish: 'kirlilik'),
        WordPair(english: 'renewable', turkish: 'yenilenebilir'),
        WordPair(english: 'recycling', turkish: 'geri dönüşüm'),
      ],
    ];

    // Create exercise objects
    return List.generate(wordSets.length, (index) {
      return Exercise(
        id: 300 + index + 1,
        levelId: 3,
        orderInLevel: index + 1,
        wordPairs: wordSets[index],
      );
    });
  }
}
